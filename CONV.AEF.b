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
* <Rating>-42</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.CashFlow
      SUBROUTINE CONV.AEF(ACCT.NO)
*______________________________________________________________________________________
*
* This conversion will convert all existing ACCT.ENT.FWD records future value dated entries
* into ACCT.ENT.TODAY file. This is routine will be called from EOD.AC.CONV.ENTRY job when
* the file AC.CONV.ENTRY gets updated with VDSUSPENSE record id.
*
* Modification log:
* ----------------
* 27/07/06 - EN_10003005
*            New routine
*
* 24/11/08 - CI_10059064
*            Balancing entries raised for the SO entries leads to the difference
*            in TRANS.JOURNAL when an upgrade is done from lower release to higher
*            release.
*______________________________________________________________________________________
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.STMT.ENTRY
$INSERT I_F.ACCOUNT
$INSERT I_EOD.AC.CONV.ENTRY.COMMON
*______________________________________________________________________________________
*
      GOSUB INITIALISE

      LOOP
         Y.IDX += 1
         STMT.ENTRY.ID = R.ACCT.ENT.FWD<Y.IDX>
      WHILE STMT.ENTRY.ID DO
         BEGIN CASE
            CASE STMT.ENTRY.ID[1,1] = "F"                   ;* Fwd entry
               R.NEW.AEF := @FM:STMT.ENTRY.ID               ;* Add back into ACCT.ENT.FWD

            CASE OTHERWISE                                  ;* Future value dated entry
               R.STMT.ENTRY = '' ; YERR = ''
               CALL F.READ(FN.STMT.ENTRY, STMT.ENTRY.ID, R.STMT.ENTRY, F.STMT.ENTRY, YERR)
               ENTRY.LIST := @FM: LOWER(R.STMT.ENTRY)

*--            Update processing date existing value dated stmt.entries.
               R.STMT.ENTRY<AC.STE.PROCESSING.DATE> = R.STMT.ENTRY<AC.STE.VALUE.DATE>

*--            Update ACCT.ENT.TODAY, ECB, and CONSOL.UPDATE.WORK files
               ENTRY.TYPE = 'S'
               ENTRY.TYPE<2> = 1
               CALL EB.ENTRY.REC.UPDATE(STMT.ENTRY.ID, R.STMT.ENTRY, ENTRY.TYPE)

         END CASE
      REPEAT

      DEL R.NEW.AEF<1>                                       ;* Since we started with @FM
      IF R.NEW.AEF THEN
         CALL F.WRITE(FN.ACCT.ENT.FWD, ACCT.NO, R.NEW.AEF)
      END ELSE
         CALL F.DELETE(FN.ACCT.ENT.FWD, ACCT.NO)
      END

      ENTRY.LIST := @FM:'VD.CONV'
      DEL ENTRY.LIST<1>                                      ;* Since we started with @FM
      CALL EB.PROCESS.SUSPENSE(ENTRY.LIST)
      V = 11                                                 ;* Make sure that it is set
      CALL EB.ACCOUNTING("AC.VDCONV", "SAO", ENTRY.LIST, "")

      CO.CODE = ID.COMPANY.SAVE
      GOSUB CHECK.COMPANY                                     ;* Load company in case of multi-book

      RETURN
*______________________________________________________________________________________
*
*** <region name= INITIALISE>
INITIALISE:
*---------

      R.ACCT.ENT.FWD = ''
      YERR = ''
      CALL F.READ(FN.ACCT.ENT.FWD, ACCT.NO, R.ACCT.ENT.FWD, F.ACCT.ENT.FWD, YERR)


      R.ACCT = '' ; Y.ER = ''
      CALL F.READ(FN.ACCOUNT, ACCT.NO, R.ACCT, F.ACCOUNT, Y.ER)
      ID.COMPANY.SAVE = ID.COMPANY
      CO.CODE = R.ACCT<AC.CO.CODE>
      GOSUB CHECK.COMPANY                                     ;* Load company in case of multi-book

      Y.IDX = 0
      ENTRY.LIST = ''
      R.NEW.AEF = ''

      RETURN
*** </region>
*______________________________________________________________________________________
*
*** <region name= CHECK.COMPANY>
CHECK.COMPANY:
*-------------

      IF C$MULTI.BOOK THEN
         IF ID.COMPANY NE CO.CODE THEN
            CALL LOAD.COMPANY(CO.CODE)
         END
      END

      RETURN
*** </region>
*______________________________________________________________________________________
*
   END
