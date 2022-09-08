* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>726</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvValuationUpdates
      SUBROUTINE CONV.POS.ASSET.12.2.1
*
*     Last updated by Andreas (dev) at 14:22:03 on 11/11/93
*
*********************************************************************************
* This routine will rebuild all the SC.POS.ASSET records for all portfolios
* by updating the file with only security transctions which have been
* authorised. Any unauthorised records will be ignored.
*
* PIF GB9301371
*
* Written by  : A. Kyriacou
* Date        : 11/11/93
*
*********************************************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.SC.POS.ASSET
$INSERT I_F.COMPANY
*
      F.POS.ASSET = ''
      CALL OPF('F.SC.POS.ASSET',F.POS.ASSET)
*
* CONVERT FILES FOR ALL COMPANIES RUNNING SECURITIES
*
      OLD.V = V
      BATCH.RUN = R.SPF.SYSTEM<3>
      R.SPF.SYSTEM<3> = 'B'
      ORIG.COMPANY = ID.COMPANY
      F.COMPANY = ''
      CALL OPF("F.COMPANY",F.COMPANY)
      COMPANY.IDS = ''
      SELECT F.COMPANY
      LOOP
         READNEXT K.COMP ELSE NULL
      WHILE K.COMP DO
         R.COMP = '' ; ER = ''
         CALL F.READ('F.COMPANY',K.COMP,R.COMP,F.COMPANY,ER)
         IF NOT(ER) THEN
            LOCATE 'SC' IN R.COMP<EB.COM.APPLICATIONS,1> SETTING POS ELSE POS = 0
            IF R.COMP<EB.COM.CONSOLIDATION.MARK> = 'N' AND POS THEN
               COMPANY.IDS<-1> = K.COMP
            END
         END ELSE ER = ''
      REPEAT
      NO.COMPS = DCOUNT(COMPANY.IDS,@FM)
      PRINT @(10,10):'CONVERTING SC.POS.ASSET RECORDS ......PLEASE WAIT'
*
      FOR YCOMP = 1 TO NO.COMPS
         F.SC.VAL.POSNS = ''
         CALL OPF('F.SC.VAL.POSITIONS',F.SC.VAL.POSNS)
         F.POS.MOVE = ''
         CALL OPF('F.SC.POS.MOVEMENT',F.POS.MOVE)
*
* MAIN PROCESS.
*
         SELECT F.SC.VAL.POSNS
*
         LOOP
            READNEXT K.VAL.POSNS ELSE NULL
         WHILE K.VAL.POSNS DO
            READ R.VAL.POSNS FROM F.SC.VAL.POSNS,K.VAL.POSNS ELSE R.VAL.POSNS = ''
            YR.POS.MOVE.ARRAY = ''
*
            LOOP
            WHILE R.VAL.POSNS<1> NE '' DO
               GOSUB UPDATE.POS.MOVE
               MATPARSE R.NEW FROM R.POS.ASSET, FM
               V = 33
               DEL R.VAL.POSNS<1>
            REPEAT
            IF YR.POS.MOVE.ARRAY THEN
               READU R.POS.MOVE FROM F.POS.MOVE,K.VAL.POSNS ELSE R.POS.MOVE = ''
               R.POS.MOVE<-1> = YR.POS.MOVE.ARRAY
               WRITE R.POS.MOVE TO F.POS.MOVE,K.VAL.POSNS
               CALL SC.OL.VAL.SEC('ALL')
            END
*
         REPEAT
      NEXT YCOMP
      CALL LOAD.COMPANY(ORIG.COMPANY)
*
      R.SPF.SYSTEM<3> = BATCH.RUN
      V = OLD.V
      RETURN                             ; * Exit program
*
********************
UPDATE.POS.MOVE:
********************
*
      K.POS.ASSET = R.VAL.POSNS<1>
      YR.SAST = FIELD(K.POS.ASSET,'.',2)
      READ R.POS.ASSET FROM F.POS.ASSET,K.POS.ASSET ELSE R.POS.ASSET = ''
      YSEC.NOS = R.POS.ASSET<SC.PAS.SECURITY.NO>
      IF YSEC.NOS NE '' THEN
         IF INDEX(YSEC.NOS,'-',1) AND NUM(YSEC.NOS[1,2]) THEN
            CONVERT VM TO FM IN YSEC.NOS
            NO.RECS = DCOUNT(YSEC.NOS,FM)
            FOR XX = 1 TO NO.RECS
               YSEC.NOS<XX> := VM:YR.SAST
            NEXT XX
            YR.POS.MOVE.ARRAY<-1> = YSEC.NOS
         END
      END
*
      RETURN
*
*****************
* END OF CODING.
*****************
   END
