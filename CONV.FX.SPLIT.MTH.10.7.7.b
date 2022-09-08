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

* Version 7 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>1156</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.Trading
      SUBROUTINE CONV.FX.SPLIT.MTH.10.7.7
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT(). 
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY.CHECK
*$INSERT I_F.FOREIGN.EXCHANGE
$INSERT I_F.FOREX
$INSERT I_F.DATES
$INSERT I_F.FILE.CONTROL
*
** FX.SPLIT.MONTH was released as an INT file. It should have been
** FIN. This will only contain data at a split month end on the
** first working day of the month, so if run at any other time
** this program should do nothing at all. In a single company
** set up all records will be copied from the old F. to the
** Fxxx. file. In a multi company set up there will probably
** be problems as there is no way of telling whether the FX ids
** on the old file are with which company.
*
      OPEN "","F.FX.SPLIT.MONTH" TO OLD.FXSM ELSE RETURN
      CALL HUSHIT(1)
      EXECUTE "SELECT F.FX.SPLIT.MONTH"
      EXECUTE "SAVE.LIST FXSPL"
      CALL HUSHIT(0)
*
** Read the FILE CONTROL record for FX.SPLIT.MTH
*
      READU YFILE.CONT.REC FROM F.FILE.CONTROL, "FX.SPLIT.MONTH" THEN
         IF YFILE.CONT.REC<EB.FILE.CONTROL.CLASS> = "FIN" THEN
            TEXT = "CONVERSION ALREADY RUN"
            CALL REM
            RELEASE F.FILE.CONTROL,"FX.SPLIT.MONTH"
            RETURN
         END ELSE
            YFILE.CONT.REC<EB.FILE.CONTROL.CLASS> = "FIN"
            WRITE YFILE.CONT.REC TO F.FILE.CONTROL, "FX.SPLIT.MONTH"
         END
      END ELSE
         TEXT = "CANNOT READ FILE CONTROL FOR FX SPLIT MONTH"
      END
*
      YIDS = ""
      CALL EB.READLIST("",YIDS,"FX.SPLIT.MTH","","")
*
      NUL = ""
      FIRST.DAY.OF.MONTH = TODAY[1,6]:"01"
      NEXT.DATE = R.DATES(EB.DAT.NEXT.WORKING.DAY)
      IF R.INTERCO.PARAMETER THEN        ; * Multi co
*
* Rebuild FX.SPLIT.MONTH for all companies from scratch. Do the
* same processing as FX.START.OF.DAY. If the maturity date is lass
* then the next working day (or option date) and on or since the
* 1st of the month, add to the list.
*
         ORIG.COMP = ID.COMPANY          ; * Save for resetting at the end
         F.COMPANY.CHECK = ""
         CALL OPF("F.COMPANY.CHECK",F.COMPANY.CHECK)
         READ YFIN.COMPANIES FROM F.COMPANY.CHECK, "FINANCIAL" THEN
            YCO.IDS = YFIN.COMPANIES<EB.COC.COMPANY.CODE>
            YCO.IDS := VM:YFIN.COMPANIES<EB.COC.USING.COM>
            CONVERT SM TO VM IN YCO.IDS
            LOOP
               REMOVE YCO.CODE FROM YCO.IDS SETTING YDELIM
               IF YCO.CODE THEN
                  CALL LOAD.COMPANY(YCO.CODE)
*
** Create the file for the company
*
                  YERR = ""
                  CALL EBS.CREATE.FILE("FX.SPLIT.MONTH", "", YERR)
                  IF YERR THEN
                     CRT @(8,22):YERR
                  END ELSE
*
                     F.FX.SPLIT.MONTH = ""
                     CALL OPF("F.FX.SPLIT.MONTH",F.FX.SPLIT.MONTH)
                     F.FOREX = "" ; YF.FOREX = "F.FOREX"
                     CALL OPF(YF.FOREX,F.FOREX)
*
                     CALL HUSHIT(1)
                     EXECUTE "SELECT ":YF.FOREX
                     EXECUTE "SAVE.LIST FX":ID.COMPANY
                     CALL HUSHIT(0)
*
                     PRINT @(5,5):"Processing company ":ID.COMPANY
                     YFX.CONTRACTS = ""
                     CALL EB.READLIST("",YFX.CONTRACTS,"FX.SPLIT","","")
                     IF YFX.CONTRACTS THEN
                        LOOP
                           REMOVE YFX.ID FROM YFX.CONTRACTS SETTING YD2
                           CRT @(5,7):"Contract ID ":YFX.ID
                           READ YFX.REC FROM F.FOREX, YFX.ID THEN      ; * Check dates
                              IF YFX.REC<FX.OPTION.DATE> OR (YFX.REC<FX.VALUE.DATE.BUY> GE FIRST.DAY.OF.MONTH AND YFX.REC<FX.VALUE.DATE.BUY> < NEXT.DATE) OR (YFX.REC<FX.VALUE.DATE.SELL> GE FIRST.DAY.OF.MONTH AND YFX.REC<FX.VALUE.DATE.SELL> < NEXT.DATE) THEN
                                 WRITE NUL TO F.FX.SPLIT.MONTH,YFX.ID
                              END
                           END ELSE NULL
                        WHILE YD2
                        REPEAT
                     END
                  END
*
               END
            WHILE YDELIM
            REPEAT
*
            CALL LOAD.COMPANY(ORIG.COMP)
            CLEARFILE OLD.FXSM
*
         END ELSE NULL
*
      END ELSE
*
         YERR = ""
         CALL EBS.CREATE.FILE("FX.SPLIT.MONTH", "", YERR)
         IF YERR THEN
            CRT @(8,22):YERR
         END ELSE
*
            F.FX.SPLIT.MONTH = ""
            CALL OPF("F.FX.SPLIT.MONTH",F.FX.SPLIT.MONTH)
*
            IF YIDS THEN
               LOOP
                  REMOVE YFX.ID FROM YIDS SETTING YD
                  READ YREC FROM OLD.FXSM, YFX.ID THEN
                     CRT @(5,5):"Processing ":@(-4):YFX.ID
                     WRITE YREC TO F.FX.SPLIT.MONTH, YFX.ID  ; * Add to new file
                     DELETE OLD.FXSM, YFX.ID       ; * Delete from old file
                  END ELSE NULL
               WHILE YD
               REPEAT
            END
         END
*
      END
*
      RETURN
*
   END
