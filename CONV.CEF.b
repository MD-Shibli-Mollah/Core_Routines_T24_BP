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

*-----------------------------------------------------------------------------
* <Rating>-14</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.CashFlow
      SUBROUTINE CONV.CEF(CE.ID)
*______________________________________________________________________________________
*
* Modification log:
* ----------------
* 27/07/06 - EN_10003005
*            New routine
*
* 30/01/09 - CI_10060355
*            Balancing entries leads to the difference in TRANS.JOURNAL when a
*            upgrade is done from lower release to higher release.
*______________________________________________________________________________________
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.STMT.ENTRY
$INSERT I_EOD.AC.CONV.ENTRY.COMMON
*______________________________________________________________________________________
*
      R.CATEG.ENT.FWD = ''
      YERR = ''
      CALL F.READ(FN.CATEG.ENT.FWD, CE.ID, R.CATEG.ENT.FWD, F.CATEG.ENT.FWD, YERR)

      CATEG.ENTRY.ID = R.CATEG.ENT.FWD
      R.CATEG.ENTRY = '' ; YERR = ''
      CALL F.READ(FN.CATEG.ENTRY, CATEG.ENTRY.ID, R.CATEG.ENTRY, F.CATEG.ENTRY, YERR)
      ENTRY.LIST = LOWER(R.CATEG.ENTRY)

      R.CET = CATEG.ENTRY.ID
      CALL F.WRITE('F.CATEG.ENT.TODAY', CE.ID, R.CET)
      CALL F.DELETE(FN.CATEG.ENT.FWD, CE.ID)

      ENTRY.LIST := @FM:'VD.CONV'

      CALL EB.PROCESS.SUSPENSE(ENTRY.LIST)
      NEW.ENTRY.LIST = ''

      Y.IDX = 0
      LOOP
         Y.IDX += 1
         ENTRY = RAISE(ENTRY.LIST<Y.IDX>)
      WHILE ENTRY DO
         IF ENTRY<AC.STE.CRF.TYPE> EQ 'CONTPL' THEN

*--         Allocate entry id for Spec entry.
            CURRTIME = ""                                       ;* Used for Id update
            TDATE = DATE()                                      ;* Date part
            CALL ALLOCATE.UNIQUE.TIME(CURRTIME)
            UNIQUE.ID = TDATE:CURRTIME
            CALL EB.ENTRY.REC.UPDATE(UNIQUE.ID, ENTRY, 'R')
         END ELSE

            NEW.ENTRY.LIST<-1> = LOWER(ENTRY)
         END
      REPEAT

      IF NEW.ENTRY.LIST THEN
         V = 11                                                 ;* Make sure that it is set
         CALL EB.ACCOUNTING("AC.VDCONV", "SAO", NEW.ENTRY.LIST, "")
      END

      RETURN
*______________________________________________________________________________________
*
   END
