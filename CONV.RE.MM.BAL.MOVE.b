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
* <Rating>7545</Rating>
*-----------------------------------------------------------------------------
* Version 3 29/05/01  GLOBUS Release No. G12.0.00 29/06/01
* Version 9.1.0A released on 29/09/89
    $PACKAGE MM.Contract
    SUBROUTINE CONV.RE.MM.BAL.MOVE
***********************************************************************
*
* This module updates Consolidate Records for the movements in
* principal for the Money Market system
*
* 03/03/92 - HY9200669
*            Replace READLIST with call to EB.READLIST
*
***********************************************************************
*
* 13/09/02 - EN_10001120
*            Conversion of error messages to error codes.
* 21/11/02 - CI_10004844
*          - Included the insert of STANDARD.SELECTION & DAO.
*06/01/2003 - EN_10001563
*             I_RE.INIT.CON insert routine is made obsolete
*             modifications are done to make a call to
*             RE.INIT.CON
*
* 19.Aug.03 - CI_10011811
* MIS-MATCHES ON MM AND LD
*
* 19/01/06 - CI_10038283
*            Rename the field RE.CON.LOCAL.FIELD.NO to RE.CON.LOCAL.FIELD.NAM.
***********************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LMM.ACCOUNT.BALANCES
    $INSERT I_F.MM.MONEY.MARKET
    $INSERT I_F.LMM.HISTORY.LIST
    $INSERT I_F.LMM.INSTALL.CONDS
    $INSERT I_F.LMM.SCHEDULES.PAST
    $INSERT I_F.LMM.SCHEDULES ;* CI_10011811
    $INSERT I_F.RE.LMM.INT.PAYMENT
    $INSERT I_F.CONSOLIDATE.COND
    $INSERT I_F.CATEG.ENTRY
    $INSERT I_SCREEN.VARIABLES
    $INSERT I_F.RE.LMM.BALANCES
    $INSERT I_F.USER
    $INSERT I_F.DATES
    $INSERT I_F.STANDARD.SELECTION      ;* CI_10004844 S
    $INSERT I_F.DEPT.ACCT.OFFICER       ;* CI_10004844 E
    $INSERT I_RE.INIT.COMMON  ;* EN_10001563 S/E
*
************************************************************************
*
* Following variables are used  in the I_GOSUB.RE.KEY.GEN.CON routine
*
    DIM Y.MM.REC(MM.AUDIT.DATE.TIME), YR.LOCAL.FILE.1(MM.AUDIT.DATE.TIME)
    DIM YR.LOCAL.FILE.2(1),YR.LOCAL.FILE.3(1),YR.LOCAL.FILE.4(1)
    DIM YR.LOCAL.FILE.5(1),YR.LOCAL.FILE.6(1)
    YID.CON = "ASSET&LIAB" ; Y.MAX.DIM = MM.AUDIT.DATE.TIME
    MAT YR.LOCAL.FILE.2 = ""
    MAT YR.LOCAL.FILE.3 = ""
    MAT YR.LOCAL.FILE.4 = ""
    MAT YR.LOCAL.FILE.5 = ""
    MAT YR.LOCAL.FILE.6 = ""
    YLOCAL.FILENAMES = "MM.MONEY.MARKET"
    Y.RE.ROUTINE = "RE.MM.BAL.MOVE"
    YMAT.DATE = ""
    YMAT.DATE.PREV = ""
    YLIST.ID = "TEMP.LIST":TNO          ;* Used for savelist/readlist
*
***********************************************************************
*
*$INSERT I_RE.INIT.CON      ;* EN_10001563 S/E
    CALL RE.INIT.CON
*
* Insert routine stores Consolidation Condition details
*
***********************************************************************
*
MAIN.PROCESS:
*************
* Process Initialisation
*
    Y.FWD.CR.TYPE = "FORWARDCR"
    Y.FWD.DB.TYPE = "FORWARDDB"
    Y.CURR.CR.TYPE = "LIVECR"
    Y.CURR.DB.TYPE = "LIVEDB"
    Y.FID.CR.TYPE = "MMFIDCR"
    Y.FID.DB.TYPE = "MMFIDDB"
*
***  Call routine to intialise common area used for future currency
***  market calculations.
*
    Y.MVMT.ID = ""
    Y.CALL.TYPE = 1
    Y.CONTRACT.CCY.MKT = ''
    GOSUB FIND.MARKET:
*
* store TXN codes used for consol SPEC.ENTRY
*
    YSPL.ENT.TXN.REF.NEW = 'NW'         ;* for NEW contracts
    YSPL.ENT.TXN.REF.INC = 'IN'         ;* for principal INCrease
    YSPL.ENT.TXN.REF.REP = 'RP'         ;* for REPayment
    YSPL.ENT.TXN.REF.MAT = 'MAT'        ;* for MATurity
    YSPL.ENT.TXN.REF.CUS = 'CUS'        ;* for CUStomer info changes
    YSPL.ENT.TXN.REF.APP = 'APP'        ;* for entries relating to APPlication
    YT.FWD.AMT = "" ; YT.CURR.AMT = ""
    Y.HIS.NO = 1 ; Y.EOD.NO = 1
    YHIST.PROCESS = ""
    Y.ENDRUN = ""
    Y.CR.MVMT = ""
    Y.DB.MVMT = ""
    Y.CR.LCL.MVMT = ""
    Y.DB.LCL.MVMT = ""
    Y.SCHD.AMT = ""
    Y.MVMT.ENTRY = ""
    Y.MM.DETAILS = ""
    Y.TYPES = ""
    YCONS.SPL.ENT.TXN.CODES = ""
    YCONS.EXCHANGE.RATES = ""
    YKEY.FIELD.CHANGED = ""
    YEXCHANGE.RATE = ""
    Y.BASE.KEYS = ""
    Y.BASE.REMOVED.KEYS = ""
    YYAMT = "" ; YYTYPE = ""
    YY.LCLAMT = ""
    LOCAL7 = "MMMOVEMENT"
    LOCAL8 = 1
*
*  Array to store contracts with static changes
*
    Y.CHNGED.CONTRACTS = ""
    Y.OLD.KEYS = ""
    BATCH.DETAILS<1> = 3
*
* Open Money Market files
*
    GOSUB OPEN.MM.FILES
*
* List all dates between current rundate and next run-date
*
    GOSUB LIST.DATES
*
* Prepare two separate lists of Contract Nos from History file & EOD file
*
    GOSUB LIST.CONTRACT.NOS
*
* Store INSTALL.CONDITION details for Interest processing
*
    GOSUB READ.INSTL.CONDS
*
* store money market record field numbers included in the
* Consolidation key
*
    GOSUB STORE.MM.KEY.FIELDS
*
* Fetch First Contract No for processing
*
    GOSUB FETCH.KEY
*
* Stop run when no Money Market contracts to be processed
*
    IF Y.ENDRUN = "YES" THEN
*
*   Write the intermediate file (MM.CHANGED.DEALS)
*
        GOSUB WRITE.MM.CHANGED.DEALS
        BATCH.DETAILS<1> = 2
        RETURN
    END
*
* main loop
*
    LOOP UNTIL Y.ENDRUN = "YES"
* ENDRUN flag set in FETCH.KEY
* read Money Market main file and ACCBAL file
*
        GOSUB READ.MM.FILES
*
* Generate Consolidation Key for the Current Money Market record
*
        GOSUB GET.CONSOL.KEY
        YKEY.CURR = YKEY.CON
*
*** The following lines have been added on 26/06/91 to cater for a
*** reversed contract. GB9100209
**
        GOSUB READU.RE.LMM.BALANCES
*
*
****   If contract has been reversed, restore old schedule details.
*
        IF Y.MM.REC.FOUND = '' THEN
            IF Y.RE.LMM.BAL.REC <> '' THEN
                Y.MM.REC(MM.MATURITY.DATE) = Y.RE.LMM.BAL.REC<RE.RLB.MAT.DATE>
                Y.MM.REC(MM.VALUE.DATE) = Y.RE.LMM.BAL.REC<RE.RLB.VALUE.DATE>
                Y.MM.REC(MM.INTEREST.RATE) = Y.RE.LMM.BAL.REC<RE.RLB.INTER.RATE>
                Y.MM.REC(MM.INTEREST.KEY) = Y.RE.LMM.BAL.REC<RE.RLB.INTER.KEY>
                Y.MM.REC(MM.INTEREST.SPREAD.1) = Y.RE.LMM.BAL.REC<RE.RLB.INTER.SPREAD>
            END
        END
*
**** end of modification 26/06/91
* store flds reqd for schd.amt consolidation
*
        GOSUB STORE.MM.DET
*
        GOSUB ACCUM.MOVEMENTS
        IF YHIST.PROCESS THEN
            IF Y.MM.REC.FOUND THEN
                GOSUB PROCESS.STATIC.CHANGES
*
                IF YKEY.FIELD.CHANGED THEN
*
*  If the consol key has changed then the link file should not be updated
*
                    Y.BASE.KEYS = ""
*** Modified...
*                 Y.BASE.REMOVED.KEYS = ""
*
                END
            END
        END
*
        IF Y.RE.LMM.BAL.REC <> "" THEN
            IF Y.MM.REC.FOUND THEN
                GOSUB PROCESS.SCHEDULE.CHANGES:
            END
        END
*
        GOSUB UPDATE.RE.LMM.BALANCES:
        GOSUB UPDATE.CONSOL
        GOSUB FETCH.KEY
    REPEAT
*
*   Write the intermediate file (MM.CHANGED.DEALS)
*
    GOSUB WRITE.MM.CHANGED.DEALS
*
    BATCH.DETAILS<1> = 2
    RETURN
*
***********************************************************************
***************       END OF MAIN ROUTINE              ****************
***********************************************************************
FIND.MARKET:
*----------
    Y.APPL.ID = 'MM'
    Y.CALL.CCY.MKT = ''
    Y.TXN.CCY.MKT = Y.CONTRACT.CCY.MKT
    YERR.CODE = ''
    YERR.MSG = ''
    CALL FIND.CCY.MKT(Y.APPL.ID,
    Y.CALL.TYPE,
    Y.MVMT.ID,
    Y.CALL.CCY.MKT,
    Y.TXN.CCY.MKT,
    YERR.CODE,
    YERR.MSG)
*
    IF YERR.CODE THEN
        E = "MM.RTN..CCY.MKT":FM:YERR.MSG
        GOTO FATAL.ERROR:
    END
    RETURN
*
***********************************************************************
STORE.MM.DET:
*************
* Routine stores Money Market details for later use to update
* Consolidate records
*
* The required fields are separated by SMs and the sequence of concatenation
* is the same as the interest fields in CONSOLIDATE.ASST.LIAB file
* and hence null values are inserted when not applicable for
* money.market
*
    YT.MM.DET = Y.MM.REC(MM.VALUE.DATE):SM:Y.MM.REC(MM.MATURITY.DATE):SM:SM:Y.MM.REC(MM.INTEREST.RATE):SM
    YT.MM.DET := Y.MM.REC(MM.INTEREST.KEY):SM:Y.MM.REC(MM.INTEREST.SPREAD.1)
    RETURN
*
*************************************************************************
*
ACCUM.MOVEMENTS:
****************

    YT.BASE.REMOVED.KEY = ""
    YT.SCHD.AMT = ""
    YY.ENTRY = YKEY
    GOSUB ACCUM.BAL.MOVEMENTS
*
* INTEREST Processing
*
    Y.INT.REC.READ = ""
    YY.ENTRY = YKEY ;* for trans ref on spl entries
* spl ent txn code for interest flds is CAP
    YSPL.ENT.TXN.CODE = "CAP"
*
* raise entries if liq flag  <> 'D'
*
    IF Y.MM.REC(MM.LIQ.DEFER.INTEREST) <> 'D' THEN
*
*  Do not process interest if contract is fiduciary
*
        IF Y.FID.CONTRACT THEN
            NULL
        END ELSE
            IF Y.MM.BAL.REC<LD27.OUTS.OVER.DUE.INT> <> "" THEN
                GOSUB OVERDUE.INTEREST.PROCESS
            END
*
            IF Y.MM.BAL.REC<LD27.INT.PAYABLE.UCL> <> "" THEN
                GOSUB INT.PAYABLE.UNCLAIMED.PROCESS
            END
        END
    END
*
*
* Process details held in LMM.SCHEDULES.PAST file
*
    IF Y.FID.CONTRACT THEN
        NULL
    END ELSE
*
*  Skip processing of schedules past for fiduciary contracts
*
        GOSUB PROCESS.SCHEDULES.PAST
    END
*
* Write back or delete RE.LMM.INT.PAYMENT record
*
    IF Y.INT.REC.READ THEN
        Y.TEMP = Y.INT.PMNT.REC<RE.LIP.INTEREST.RECEIVE>
        Y.TEMP := Y.INT.PMNT.REC<RE.LIP.INTEREST.PAYABLE>
        Y.TEMP := Y.INT.PMNT.REC<RE.LIP.COMMISSION.RECVE>
        IF Y.TEMP <> "" THEN
            GOSUB WRITE.INT.PAYMENT
        END ELSE
            GOSUB DELETE.INT.PAYMENT
        END
    END
    RETURN
*
************************************************************************
*
ACCUM.BAL.MOVEMENTS:
********************
* Accumulation of TYPE wise balance amounts for the consolidate key
* Also translates special entry TXN code
*
*------------------------------------------------------------------------
    IF Y.MM.BAL.REC<LD27.DATE.FROM> = "" THEN
        GOTO ACCUM.BAL.MOVEMENTS.RETURN
    END
    YCOUNT.AV = COUNT(Y.MM.BAL.REC<LD27.DATE.FROM>,VM)+1
*
* Set base remove key if required
*
    IF Y.MM.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV> + 0 = 0 THEN
        IF Y.MM.BAL.REC<LD27.OUTS.CURR.PRINC,YCOUNT.AV> + 0 = 0 THEN
            IF Y.MM.BAL.REC<LD27.OUTS.OD.PRINC,YCOUNT.AV> + 0 = 0 THEN
                YT.BASE.REMOVED.KEY = YKEY
            END
        END
    END
*
***!      GOSUB READU.RE.LMM.BALANCES ;* GB9100209
*
    IF Y.MM.BAL.REC<LD27.TRANS.PRIN.AMT,1> > 0 THEN
        YREF.DBCR = "CR"
    END ELSE
        YREF.DBCR = "DB"
    END
*
* forward princ processing
*
    YT.FWD.AMT = Y.MM.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV> - Y.RE.LMM.BAL.REC<RE.RLB.OUTS.FWD.PRINC>
*
    IF YT.FWD.AMT <> "" AND YT.FWD.AMT <> 0 THEN
*
        Y.ACCBAL.AMT = Y.MM.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV>
        Y.RE.LMM.BAL.AMT = Y.RE.LMM.BAL.REC<RE.RLB.OUTS.FWD.PRINC>
        IF YT.BASE.REMOVED.KEY THEN
* maturity !
            YSPL.ENT.TXN.CODE = YSPL.ENT.TXN.REF.MAT
        END ELSE
            GOSUB GET.SPL.ENT.TXN.REF:
            YSPL.ENT.TXN.CODE = "F":YSPL.ENT.TXN.REF
        END
*
        IF YREF.DBCR = "CR" THEN
            YYTYPE = Y.FWD.CR.TYPE
        END ELSE
            YYTYPE = Y.FWD.DB.TYPE
        END
        YYAMT = YT.FWD.AMT
*
* if the outstanding forward principal has become zero then the local
* equivalent is to be taken from the stored amount in RE.LMM.BALANCES
* and clear the local equiv and exchange rate flds in RE.LMM.BALANCES
*
        IF Y.MM.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV> = 0 OR Y.MM.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV> = "" THEN
            YY.LCLAMT = Y.RE.LMM.BAL.REC<RE.RLB.OUTS.FWD.PRINC.LCL> * -1
*
***  Modification.. EB8800401.
*
            YEXCHANGE.RATE = Y.RE.LMM.BAL.REC<RE.RLB.EXCHANGE.RATE>
*
* when the fwd amt is zero clear lcl equiv and exchange rate stored in
* RE.LMM.BALANCES
*
            Y.RE.LMM.BAL.REC<RE.RLB.OUTS.FWD.PRINC.LCL> = ""
            Y.RE.LMM.BAL.REC<RE.RLB.EXCHANGE.RATE> = ""
        END ELSE
            GOSUB CALC.FWD.LCL.AMT
*
* update the lcl amt in RE.LMM.BALANCES with day's movment
*
            Y.RE.LMM.BAL.REC<RE.RLB.OUTS.FWD.PRINC.LCL> = Y.RE.LMM.BAL.REC<RE.RLB.OUTS.FWD.PRINC.LCL> + YY.LCLAMT
        END
        GOSUB UPDATE.CONSOL.STORE
        YY.LCLAMT = ""
        YEXCHANGE.RATE = ""
    END
*
* curr and od principals are treated together
* for MM
    YT.CURR.AMT = Y.MM.BAL.REC<LD27.OUTS.CURR.PRINC,YCOUNT.AV> + Y.MM.BAL.REC<LD27.OUTS.OD.PRINC,YCOUNT.AV> - (Y.RE.LMM.BAL.REC<RE.RLB.OUTS.CURR.PRINC> + Y.RE.LMM.BAL.REC<RE.RLB.OUTS.OD.PRINC>)
*
    IF YT.CURR.AMT <> "" AND YT.CURR.AMT <> 0 THEN
*
        Y.ACCBAL.AMT = Y.MM.BAL.REC<LD27.OUTS.CURR.PRINC,YCOUNT.AV> + Y.MM.BAL.REC<LD27.OUTS.OD.PRINC,YCOUNT.AV>
*
        Y.RE.LMM.BAL.AMT = Y.RE.LMM.BAL.REC<RE.RLB.OUTS.CURR.PRINC> + Y.RE.LMM.BAL.REC<RE.RLB.OUTS.OD.PRINC>
*
        IF YT.BASE.REMOVED.KEY THEN
* maturity !
            YSPL.ENT.TXN.CODE = YSPL.ENT.TXN.REF.MAT
        END ELSE
            GOSUB GET.SPL.ENT.TXN.REF:
            YSPL.ENT.TXN.CODE = "L":YSPL.ENT.TXN.REF
        END
*
*
        IF YREF.DBCR = "CR" THEN
            YYTYPE = Y.CURR.CR.TYPE
        END ELSE
            YYTYPE = Y.CURR.DB.TYPE
        END
        YYAMT = YT.CURR.AMT
*
* check for FIDUCIARY types
*
        IF Y.FID.CONTRACT THEN
            IF YREF.DBCR = "CR" THEN
                YYTYPE = Y.FID.CR.TYPE
            END ELSE
                YYTYPE = Y.FID.DB.TYPE
            END
*
* for fiduciaries the local equivalent should not be recalculated for
* every movement as they are reported as contingents
* local equivalent is to be taken from re.lmm.balances.file in case of
* part repayment or maturity. for initiation the local equialent is to be
* stored in re.lmm.balances.file
*
            IF Y.MM.REC(MM.CURRENCY) <> LCCY THEN
                IF Y.MM.BAL.REC<LD27.OUTS.CURR.PRINC,YCOUNT.AV> + Y.MM.BAL.REC<LD27.OUTS.OD.PRINC,YCOUNT.AV> = 0 THEN
                    YY.LCLAMT = Y.RE.LMM.BAL.REC<RE.RLB.OUTS.CUR.PRINC.LCL> * -1
                    YEXCHANGE.RATE = Y.RE.LMM.BAL.REC<RE.RLB.CURR.EXCH.RATE>
                    Y.RE.LMM.BAL.REC<RE.RLB.OUTS.CUR.PRINC.LCL> = ""
                    Y.RE.LMM.BAL.REC<RE.RLB.CURR.EXCH.RATE> = ""
                END ELSE
                    GOSUB CALC.CURR.LCL.AMT
                    Y.RE.LMM.BAL.REC<RE.RLB.OUTS.CUR.PRINC.LCL> = Y.RE.LMM.BAL.REC<RE.RLB.OUTS.CUR.PRINC.LCL> + YY.LCLAMT
                END
            END
        END
        GOSUB UPDATE.CONSOL.STORE
        YY.LCL.AMT = ""
        YEXCHANGE.RATE = ""
    END
*
ACCUM.BAL.MOVEMENTS.RETURN:
    RETURN
*
*------------------------------------------------------------------------
GET.SPL.ENT.TXN.REF:
*-------------------
* checks the movement by comparing the amts from ACCBAL & RE.LMM.BALANCES
* and translates the spl entry txn ref
*------------------------------------------------------------------------
*
    IF Y.ACCBAL.AMT < 0 THEN
        Y.ACCBAL.AMT = Y.ACCBAL.AMT * -1
    END
    IF Y.RE.LMM.BAL.AMT < 0 THEN
        Y.RE.LMM.BAL.AMT = Y.RE.LMM.BAL.AMT * -1
    END
*
    IF Y.RE.LMM.BAL.AMT = "" OR Y.RE.LMM.BAL.AMT = 0 THEN
        IF Y.ACCBAL.AMT <> "" OR Y.ACCBAL.AMT <> 0 THEN
            YSPL.ENT.TXN.REF = "NW"
        END
    END ELSE
        IF Y.ACCBAL.AMT > Y.RE.LMM.BAL.AMT THEN
            YSPL.ENT.TXN.REF = "IN"
        END ELSE
            YSPL.ENT.TXN.REF = "RP"
        END
    END
*
    RETURN
*
************************************************************************
*
*CREATE.BALANCE.MOVEMENTS:
**************************
**
*      IF YT.FWD.AMT <> "" AND YT.FWD.AMT <> 0  THEN
*      END
**
*      IF YT.CURR.AMT <> ""  AND YT.CURR.AMT <> 0 THEN
*         IF YREF.DBCR = "CR"  THEN YYTYPE = Y.CURR.CR.TYPE
*            ELSE YYTYPE = Y.CURR.DB.TYPE
*         YYAMT = YT.CURR.AMT
*         GOSUB UPDATE.CONSOL.STORE
*      END
**
*      RETURN
*
***********************************************************************
*
CALC.CURR.LCL.AMT:
*================
*
* Routine used for only fiduciaries
* Part movements are possible - the exchange rate used for calculation
* is the stored rate from the first transaction date
* For a new contract the mid rate used and also stored in
* RE.LMM.BALANCES
*
    YY.LCLAMT = ""
    Y.CCY = FIELD(YKEY.CURR,".",4)
    Y.CCY.MKT = FIELD(YKEY.CURR,".",2)
    IF Y.CCY <> LCCY THEN
        YCHECK.AMT = Y.RE.LMM.BAL.REC<RE.RLB.OUTS.CURR.PRINC> + Y.RE.LMM.BAL.REC<RE.RLB.OUTS.OD.PRINC>
        IF YCHECK.AMT = 0 THEN
*                                   new contract
            YEXCHANGE.RATE = ""
            CALL MIDDLE.RATE.CONV.CHECK(YYAMT,Y.CCY,YEXCHANGE.RATE,Y.CCY.MKT,YY.LCLAMT,"","")
            Y.RE.LMM.BAL.REC<RE.RLB.CURR.EXCH.RATE> = YEXCHANGE.RATE
        END ELSE
            YEXCHANGE.RATE = Y.RE.LMM.BAL.REC<RE.RLB.CURR.EXCH.RATE>
            CALL MIDDLE.RATE.CONV.CHECK(YYAMT,Y.CCY,YEXCHANGE.RATE,Y.CCY.MKT,YY.LCLAMT,"","")
        END
    END
    RETURN
*
***********************************************************************
*
CALC.FWD.LCL.AMT:
*================
*
* Routine used only for Forward contract amounts
* Part movements are possible - the exchange rate used for calculation
* is the stored rate from the first transaction date
* For a new contract the mid rate used and also stored in
* RE.LMM.BALANCES
*
    YY.LCLAMT = ""
    Y.CCY = FIELD(YKEY.CURR,".",4)
    Y.CCY.MKT = FIELD(YKEY.CURR,".",2)
    IF Y.CCY <> LCCY THEN
        YCHECK.AMT = Y.RE.LMM.BAL.REC<RE.RLB.OUTS.FWD.PRINC> + 0
        IF YCHECK.AMT = 0 THEN
*                                   new contract
            YEXCHANGE.RATE = ""
            CALL MIDDLE.RATE.CONV.CHECK(YYAMT,Y.CCY,YEXCHANGE.RATE,Y.CCY.MKT,YY.LCLAMT,"","")
            Y.RE.LMM.BAL.REC<RE.RLB.EXCHANGE.RATE> = YEXCHANGE.RATE
        END ELSE
            YEXCHANGE.RATE = Y.RE.LMM.BAL.REC<RE.RLB.EXCHANGE.RATE>
            CALL MIDDLE.RATE.CONV.CHECK(YYAMT,Y.CCY,YEXCHANGE.RATE,Y.CCY.MKT,YY.LCLAMT,"","")
        END
    END
    RETURN
*
*------------------------------------------------------------------------
*
UPDATE.RE.LMM.BALANCES:
*======================
*
* This paragraph is called from ACCUM.BAL.MOVEMENTS and so
* F.LMM.ACCOUNT.BALANCES record is assumed to have been read
*
    Y.WRITE.INDIC = ""
    YT.FWD.AMT = Y.MM.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV>
    YT.CURR.AMT = Y.MM.BAL.REC<LD27.OUTS.CURR.PRINC,YCOUNT.AV>
    YT.OD.AMT = Y.MM.BAL.REC<LD27.OUTS.OD.PRINC,YCOUNT.AV>
*
    IF YT.FWD.AMT <> "" AND YT.FWD.AMT <> 0 THEN
        Y.WRITE.INDIC = 1
    END
    IF YT.CURR.AMT <> "" AND YT.CURR.AMT <> 0 THEN
        Y.WRITE.INDIC = 1
    END
    IF YT.OD.AMT <> "" AND YT.OD.AMT <> 0 THEN
        Y.WRITE.INDIC = 1
    END
*
    IF Y.WRITE.INDIC THEN
        Y.RE.LMM.BAL.REC<RE.RLB.OUTS.CURR.PRINC> = YT.CURR.AMT
        Y.RE.LMM.BAL.REC<RE.RLB.OUTS.FWD.PRINC> = YT.FWD.AMT
        Y.RE.LMM.BAL.REC<RE.RLB.OUTS.OD.PRINC> = YT.OD.AMT
        Y.RE.LMM.BAL.REC<RE.RLB.DATE.FROM> = Y.MM.BAL.REC<LD27.DATE.FROM,YCOUNT.AV>
        Y.RE.LMM.BAL.REC<RE.RLB.MAT.DATE> = Y.MM.REC(MM.MATURITY.DATE)
        Y.RE.LMM.BAL.REC<RE.RLB.VALUE.DATE> = Y.MM.REC(MM.VALUE.DATE)
        Y.RE.LMM.BAL.REC<RE.RLB.INTER.RATE> = Y.MM.REC(MM.INTEREST.RATE)
        Y.RE.LMM.BAL.REC<RE.RLB.INTER.KEY>= Y.MM.REC(MM.INTEREST.KEY)
        Y.RE.LMM.BAL.REC<RE.RLB.INTER.SPREAD>= Y.MM.REC(MM.INTEREST.SPREAD.1)
*
* lcl amt and exchange rate are stored while processing fwd princ
* movements
*
        GOSUB WRITE.RE.LMM.BALANCES
    END ELSE
        GOSUB DELETE.RE.LMM.BALANCES
*
* Base record key in consol.concatfile can now be removed
*
    END
    RETURN
*
***********************************************************************
*
UPDATE.CONSOL.STORE:
********************
    LOCATE YYTYPE IN Y.TYPES<1> SETTING YLOC ELSE
        Y.TYPES<YLOC> = YYTYPE
        IF YYAMT > 0 THEN
            Y.CR.MVMT<YLOC> = YYAMT
            Y.DB.MVMT<YLOC> = 0
            Y.CR.LCL.MVMT<YLOC> = YY.LCLAMT
            Y.DB.LCL.MVMT<YLOC> = 0
        END ELSE
            Y.DB.MVMT<YLOC> = YYAMT
            Y.CR.MVMT<YLOC> = 0
            Y.DB.LCL.MVMT<YLOC> = YY.LCLAMT
            Y.CR.LCL.MVMT<YLOC> = 0
        END
        Y.MVMT.ENTRY<YLOC> = YY.ENTRY
        YCONS.SPL.ENT.TXN.CODES<YLOC> = YSPL.ENT.TXN.CODE
        YCONS.EXCHANGE.RATES<YLOC> = YEXCHANGE.RATE
        GOSUB UPDATE.MM.ENTRIES
        YLOC = ""
    END
    IF YLOC <> "" THEN
        IF YYAMT > 0 THEN
            Y.CR.MVMT<YLOC> = Y.CR.MVMT<YLOC> + YYAMT
            Y.CR.LCL.MVMT<YLOC> = Y.CR.LCL.MVMT<YLOC> + YY.LCLAMT
        END ELSE
            Y.DB.MVMT<YLOC> = Y.DB.MVMT<YLOC> + YYAMT
            Y.DB.LCL.MVMT<YLOC> = Y.DB.LCL.MVMT<YLOC> + YY.LCLAMT
        END
        GOSUB UPDATE.MM.ENTRIES
    END
    RETURN
*
***********************************************************************
*
UPDATE.MM.ENTRIES:
******************
* TYPE location is set in YLOC when this routine is entered
* This routine is called by UPDATE.CONSOL.STORE
*
    IF YYTYPE = Y.FWD.CR.TYPE OR YYTYPE = Y.FWD.DB.TYPE OR YYTYPE = Y.CURR.CR.TYPE OR YYTYPE = Y.CURR.DB.TYPE OR YYTYPE = Y.FID.CR.TYPE OR YYTYPE = Y.FID.DB.TYPE THEN
        LOCATE YT.MM.DET IN Y.MM.DETAILS<YLOC,1> SETTING YLOCV ELSE
            Y.MM.DETAILS<YLOC,YLOCV> = YT.MM.DET
            Y.SCHD.AMT<YLOC,YLOCV> = YYAMT
            YLOCV = ""
        END
        IF YLOCV <> "" THEN
            Y.SCHD.AMT<YLOC,YLOCV> = Y.SCHD.AMT<YLOC,YLOCV> + YYAMT
        END
*
        LOCATE YKEY IN Y.BASE.KEYS<YLOC,1> BY "AL" SETTING YLOCV ELSE
            INS YKEY BEFORE Y.BASE.KEYS<YLOC,YLOCV>
        END
*
        IF YT.BASE.REMOVED.KEY <> "" THEN
            LOCATE YT.BASE.REMOVED.KEY IN Y.BASE.REMOVED.KEYS<YLOC,1> BY "AL" SETTING YLOCV ELSE
                INS YT.BASE.REMOVED.KEY BEFORE Y.BASE.REMOVED.KEYS<YLOC,YLOCV>
            END
        END
*
    END
    RETURN
*
*************************************************************************
*
OVERDUE.INTEREST.PROCESS:
*************************
    IF Y.INT.REC.READ = "" THEN
        GOSUB READ.INT.PAYMENT
    END
    YYAMT = Y.MM.BAL.REC<LD27.OUTS.OVER.DUE.INT> - Y.INT.PMNT.REC<RE.LIP.INTEREST.RECEIVE>
    IF YYAMT <> 0 THEN
*
*** Use FIND.CCY.MKT routine to get currency market for MM interest.
*
        Y.CALL.TYPE = '4'
        Y.MVMT.ID = 'INTEREST'
        GOSUB FIND.MARKET:
        YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.IR..CUR>:'.':Y.CALL.CCY.MKT
        GOSUB UPDATE.CONSOL.STORE
    END
    Y.INT.PMNT.REC<RE.LIP.INTEREST.RECEIVE> = Y.MM.BAL.REC<LD27.OUTS.OVER.DUE.INT>
    RETURN
*
*************************************************************************
*
INT.PAYABLE.UNCLAIMED.PROCESS:
******************************
    IF Y.INT.REC.READ = "" THEN
        GOSUB READ.INT.PAYMENT
    END
    YYAMT = Y.MM.BAL.REC<LD27.INT.PAYABLE.UCL> - Y.INT.PMNT.REC<RE.LIP.INTEREST.PAYABLE>
    IF YYAMT <> 0 THEN
*
*** Use FIND.CCY.MKT routine to get currency market for MM interest.
*
        Y.CALL.TYPE = '4'
        Y.MVMT.ID = 'INTEREST'
        GOSUB FIND.MARKET:
        YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.IP..CUR>:'.':Y.CALL.CCY.MKT
        GOSUB UPDATE.CONSOL.STORE
    END
    Y.INT.PMNT.REC<RE.LIP.INTEREST.PAYABLE> = Y.MM.BAL.REC<LD27.INT.PAYABLE.UCL>
    RETURN
*
*************************************************************************
*
PROCESS.SCHEDULES.PAST:
***********************
    Y.PROCESS.DATE = 0
    LOOP
        Y.PROCESS.DATE += 1
    UNTIL Y.JULDATES<Y.PROCESS.DATE> = ""
        Y.SCHD.KEY = YKEY:Y.JULDATES<Y.PROCESS.DATE>:"00"
        GOSUB READ.SCHD.PAST
        IF Y.SCHD.PAST.REC <> "" THEN
*
* Record now identified
*
            IF Y.SCHD.PAST.REC<LD28.INTEREST.REC.AMT> THEN
                IF Y.SCHD.PAST.REC<LD28.INTEREST.REC.AMT> < 0 THEN
                    GOSUB SCHD.INT.RECD.PROCESS
                END ELSE
                    IF Y.SCHD.PAST.REC<LD28.INTEREST.REC.AMT> > 0 THEN
                        GOSUB SCHD.INT.PMNT.PROCESS
                    END
                END
            END
*
        END
    REPEAT
    RETURN
*
*************************************************************************
*
SCHD.INT.RECD.PROCESS:
**********************
*
* raise entries if liq flag <> 'D'
*
    IF Y.SCHD.PAST.REC<LD28.INT.LIQ.DEFER> <> 'D' THEN
        IF Y.INT.REC.READ = "" THEN
            GOSUB READ.INT.PAYMENT
        END
*
        YYAMT = Y.SCHD.PAST.REC<LD28.INTEREST.REC.AMT> + Y.INT.PMNT.REC<RE.LIP.INTEREST.RECEIVE>
        IF YYAMT <> 0 THEN
            YYAMT = -YYAMT
*
*** Use FIND.CCY.MKT routine to get currency market for MM interest.
*
            Y.CALL.TYPE = '4'
            Y.MVMT.ID = 'INTEREST'
            GOSUB FIND.MARKET:
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.IR..CUR>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
        Y.INT.PMNT.REC<RE.LIP.INTEREST.RECEIVE> = ""
    END
    RETURN
*
*************************************************************************
*
SCHD.INT.PMNT.PROCESS:
**********************
*
* check if liq is not deferred
*
    IF Y.SCHD.PAST.REC<LD28.INT.LIQ.DEFER> <> 'D' THEN
        IF Y.INT.REC.READ = "" THEN
            GOSUB READ.INT.PAYMENT
        END
*
        YYAMT = Y.SCHD.PAST.REC<LD28.INTEREST.REC.AMT> + Y.INT.PMNT.REC<RE.LIP.INTEREST.PAYABLE>
        IF YYAMT <> 0 THEN
            YYAMT = -YYAMT
*
*** Use FIND.CCY.MKT routine to get currency market for MM interest.
*
            Y.CALL.TYPE = '4'
            Y.MVMT.ID = 'INTEREST'
            GOSUB FIND.MARKET:
            YYTYPE = Y.INSTL.REC<LD30.PL.O.SET.IP..CUR>:'.':Y.CALL.CCY.MKT
            GOSUB UPDATE.CONSOL.STORE
        END
        Y.INT.PMNT.REC<RE.LIP.INTEREST.PAYABLE> = ""
    END
    RETURN
*
*************************************************************************
*
UPDATE.CONSOL:
**************
    IF Y.TYPES <> "" THEN
        Y.PARAMS.CON = ""
        Y.PARAMS.CON<1> = YKEY.CURR
        Y.PARAMS.CON<2> = FIELD(YKEY.CURR,".",4)
        Y.CCY.MKT = FIELD(YKEY.CURR,".",2)
        Y.COUNT.AV = COUNT(Y.TYPES,FM)+1
        FOR YI = 1 TO Y.COUNT.AV
            Y.PARAMS.CON<3> = Y.TYPES<YI>
            Y.CCY.MKT = FIELD(Y.PARAMS.CON<3>,'.',2)
            IF Y.CCY.MKT = '' THEN
                Y.CCY.MKT = FIELD(YKEY.CURR,".",2)
            END
            Y.PARAMS.CON<4> = Y.DB.MVMT<YI>
            Y.PARAMS.CON<5> = Y.CR.MVMT<YI>
            Y.PARAMS.CON<6> = ""
            Y.PARAMS.CON<7> = ""
            IF Y.PARAMS.CON<2> <> LCCY THEN
*
* LOCAL equivalents are already calculated and stored for FORWARD deals and FIDUCIARY deals
*
                IF Y.PARAMS.CON<3> = Y.FWD.CR.TYPE OR Y.PARAMS.CON<3> = Y.FWD.DB.TYPE OR Y.PARAMS.CON<3> = Y.FID.CR.TYPE OR Y.PARAMS.CON<3> = Y.FID.DB.TYPE THEN
                    Y.PARAMS.CON<6> = Y.DB.LCL.MVMT<YI>
                    Y.PARAMS.CON<7> = Y.CR.LCL.MVMT<YI>
                    Y.PARAMS.CON<20> = YCONS.EXCHANGE.RATES<YI>
                END ELSE
*
* Calculate local equivalents for other types
*
                    IF Y.PARAMS.CON<4> <> 0 AND Y.PARAMS.CON<4> <> "" THEN
                        Y.LOCAL.EQ.AMT = ""
                        YEXCHANGE.RATE = ""
                        CALL MIDDLE.RATE.CONV.CHECK(Y.PARAMS.CON<4>,Y.PARAMS.CON<2>,YEXCHANGE.RATE,Y.CCY.MKT,Y.LOCAL.EQ.AMT,"","")
                        IF ETEXT <> "" THEN
                            E = "MM.RTN.CCY.CONV.ERR":FM:YKEY.CURR:VM:Y.PARAMS.CON<4>:VM:ETEXT
                            GOTO FATAL.ERROR
                        END ELSE
                            Y.PARAMS.CON<6> = Y.LOCAL.EQ.AMT
                            Y.PARAMS.CON<20> = YEXCHANGE.RATE
                        END
                    END
                    IF Y.PARAMS.CON<5> <> 0 AND Y.PARAMS.CON<5> <> "" THEN
                        Y.LOCAL.EQ.AMT = ""
                        YEXCHANGE.RATE = ""
                        CALL MIDDLE.RATE.CONV.CHECK(Y.PARAMS.CON<5>,Y.PARAMS.CON<2>,YEXCHANGE.RATE,Y.CCY.MKT,Y.LOCAL.EQ.AMT,"","")
                        IF ETEXT <> "" THEN
                            E = "MM.RTN.CCY.CONV.ERR":FM:YKEY.CURR:VM:Y.PARAMS.CON<5>:VM:ETEXT
                            GOTO FATAL.ERROR
                        END ELSE
                            Y.PARAMS.CON<7> = Y.LOCAL.EQ.AMT
                            Y.PARAMS.CON<20> = YEXCHANGE.RATE
                        END
                    END
                END
            END
*
            Y.PARAMS.CON<8> = ""
            Y.PARAMS.CON<9> = ""
            Y.PARAMS.CON<10> = ""
            Y.PARAMS.CON<11> = ""
            Y.PARAMS.CON<12> = ""
            Y.PARAMS.CON<13> = ""
            Y.PARAMS.CON<14> = ""
            YCOUNT = COUNT(Y.MM.DETAILS<YI>,VM)+1
            FOR YJ = 1 TO YCOUNT
                Y.PARAMS.CON<8,YJ> = Y.MM.DETAILS<YI,YJ,1>
                Y.PARAMS.CON<9,YJ> = Y.MM.DETAILS<YI,YJ,2>
                Y.PARAMS.CON<10,YJ> = Y.MM.DETAILS<YI,YJ,3>
                Y.PARAMS.CON<11,YJ> = Y.MM.DETAILS<YI,YJ,4>
                Y.PARAMS.CON<12,YJ> = Y.MM.DETAILS<YI,YJ,5>
                Y.PARAMS.CON<13,YJ> = Y.MM.DETAILS<YI,YJ,6>
                Y.PARAMS.CON<14,YJ> = Y.SCHD.AMT<YI,YJ>
            NEXT
*
            IF Y.CONSOL.KEY.GENERATED THEN
                Y.PARAMS.CON<15> = Y.BASE.KEYS<YI>
            END ELSE
                Y.PARAMS.CON<15> = ""
            END
*
            Y.PARAMS.CON<16> = Y.BASE.REMOVED.KEYS<YI>
            Y.PARAMS.CON<17> = Y.MVMT.ENTRY<YI>
            Y.PARAMS.CON<18> = Y.MM.REC(MM.CUSTOMER.ID)
            Y.PARAMS.CON<19> = YCONS.SPL.ENT.TXN.CODES<YI>
            Y.PARAMS.CON<21> = Y.MM.REC(MM.DEPT.CODE)
            Y.PARAMS.CON<22> = Y.MM.REC(MM.CATEGORY)
*
* Update CONSOLIDATE.ASST.LIAB file for this TYPE
*
            CALL RE.CONSOL.UPDATE(Y.PARAMS.CON,"ASSET&LIAB","")
        NEXT
    END
*
* Initialise values for next Consolidate Key
*
*      YKEY.PREV = YKEY.CURR
    YMAT.DATE.PREV = YMAT.DATE
*
* This YMAT.DATE was used in the consolidation parameters for
* updating FINAL.MAT.DATE field which is no longer required
* ( AMD.DT:01.05.1986)
*
    Y.CR.MVMT = ""
    Y.DB.MVMT = ""
    Y.CR.LCL.MVMT = ""
    Y.DB.LCL.MVMT = ""
    Y.TYPES = ""
    YCONS.SPL.ENT.TXN.CODES = ""
    YCONS.EXCHANGE.RATES = ""
    Y.MVMT.ENTRY = ""
    Y.MM.DETAILS = ""
    Y.SCHD.AMT = ""
    Y.BASE.KEYS = ""
    Y.BASE.REMOVED.KEYS = ""
*
    RETURN
*
************************************************************************
*
LIST.DATES:
***********
* List dates from start date till end date
* Start date = today , if last working day is of the same month as TODAY
*                            OR
*              first day of the month , if last working day is of
*              previous month
* End date = till next run date if next run date is of same month as
*             TODAY
*                             OR
*            last day of the month ,if next working day is of next month
*
*------------------------------------------------------------------------
*
* CI_10011811 /S

    F.RE.MM.BALANCES.NAME = "F.RE.LMM.BALANCES"
    F.RE.MM.BALANCES = ''

    CALL OPF(F.RE.MM.BALANCES.NAME, F.RE.MM.BALANCES)

    SELECT.COMMAND = "SELECT ": F.RE.MM.BALANCES.NAME :" WITH MAT.DATE LT ":R.DATES(EB.DAT.LAST.WORKING.DAY) " AND WITH @ID LIKE MM..."

    Y.MM.BAL.IDS = ""
    Y.RE.LMM.TOT = 0
    CALL EB.READLIST(SELECT.COMMAND, Y.MM.BAL.IDS, "RE.LMM", Y.RE.LMM.TOT, "")

    FOR Y.CTR = 1 TO Y.RE.LMM.TOT
        YKEY.BAL = Y.MM.BAL.IDS<Y.CTR>
        READ Y.RE.MM.BAL.REC FROM F.RE.MM.BALANCES, YKEY.BAL ELSE Y.MM.BAL.REC = ""
        IF Y.RE.MM.BAL.REC THEN
            IF ABS(Y.RE.MM.BAL.REC<RE.RLB.OUTS.FWD.PRINC>) GT 0 OR ABS(Y.RE.MM.BAL.REC<RE.RLB.OUTS.CURR.PRINC>) GT 0 OR ABS(Y.RE.MM.BAL.REC<RE.RLB.OUTS.OD.PRINC>) GT 0 OR ABS(Y.RE.MM.BAL.REC<RE.RLB.OUTS.FWD.PRINC.LCL>) GT 0 THEN

                YT.DATE = Y.RE.MM.BAL.REC<RE.RLB.MAT.DATE>
                YT.JULDATE = ""
                CALL JULDATE(YT.DATE,YT.JULDATE)

                POS = ''
                LOCATE YT.JULDATE IN Y.JULDATES<1> SETTING POS ELSE POS = 99999

                IF POS = 99999 THEN
                    Y.JULDATES<-1> = YT.JULDATE
                END
            END
        END
    NEXT

    RETURN

* CI_10011811 /E  * Replaced with the new set code by checking the MAT DATES which need to be changed
* Originally it was considering the Last working date and Next working date of the DATES file
*
***********************************************************************
*
LIST.CONTRACT.NOS:
******************
* List Contract Numbers to be processed for the Current date
*
* CI_10011811 /S

    F.LMM.SCHEDULES.NAME = "F.LMM.SCHEDULES" ; F.LMM.SCHEDULES = ""
    CALL OPF(F.LMM.SCHEDULES.NAME, F.LMM.SCHEDULES)
*
    F.LMM.SCHEDULES.NAME.PAST = "F.LMM.SCHEDULES.PAST" ; F.LMM.SCHEDULES.PAST = ""
    CALL OPF(F.LMM.SCHEDULES.NAME.PAST, F.LMM.SCHEDULES.PAST)

* CI_10011811 /E
*

*
    Y.EOD.CNOS = "" ; Y.HIS.CNOS = ""
    YI = 1

    LOOP UNTIL Y.JULDATES<YI> = ""

* CI_10011811 /S

        PRINT "Building list from schedules for ":Y.JULDATES<YI>
        SEL.STMT = "SELECT ":F.LMM.SCHEDULES.NAME:" WITH SCHED.DT = ":Y.JULDATES<YI>:" AND WITH @ID LIKE MM..."
        EXECUTE SEL.STMT

        LOOP
            READNEXT SCHED.ID ELSE SCHED.ID = ''
        WHILE SCHED.ID
            MM.ID = SCHED.ID[1,12]
            Y.EOD.CNOS<-1> = MM.ID
        REPEAT

        PRINT "Building list from Past schedules for ":Y.JULDATES<YI>
        SEL.STMT = "SELECT ":F.LMM.SCHEDULES.NAME.PAST:" WITH @ID LIKE ...":Y.JULDATES<YI>:"00 AND WITH @ID LIKE MM..."
        EXECUTE SEL.STMT

        LOOP
            READNEXT SCHED.ID ELSE SCHED.ID = ''
        WHILE SCHED.ID
            MM.ID = SCHED.ID[1,12]
            Y.EOD.CNOS<-1> = MM.ID
        REPEAT

*-* CI_10011811 / E

        YI += 1
    REPEAT
*
    Y.LMM.HIS.FILE = "F.LMM.HISTORY.TODAY" ; F.LMM.HISTORY.TODAY = ""
    CALL OPF(Y.LMM.HIS.FILE,F.LMM.HISTORY.TODAY)
*
*###      EXECUTE "DELETE.LIST ":YLIST.ID
*###      EXECUTE 'SSELECT ':Y.LMM.HIS.FILE:" WITH @ID LIKE MM..."
*###      EXECUTE "SAVE.LIST ":YLIST.ID
*###      READLIST Y.HIS.CNOS FROM YLIST.ID ELSE Y.HIS.CNOS = ""
*
*##!      LOOP
*##!         READNEXT YID ELSE NULL
*##!      WHILE YID DO
*##!         IF YID[1,2] = 'MM'  THEN
*##!            Y.HIS.CNOS<-1> = YID
*##!         END
*##!      REPEAT
*
    SELECT.COMMAND = 'SSELECT ':Y.LMM.HIS.FILE:" WITH @ID LIKE MM..."
    Y.HIS.CNOS = ""
    CALL EB.READLIST(SELECT.COMMAND, Y.HIS.CNOS, "MM.HIS", "", "")
*
    RETURN
*
*************************************************************************
*
FETCH.KEY:
**********
    YHIST.PROCESS = ""
*
* YHIST.PROCESS will be set to '1' if key is picked up
* from history contract nos. list
*
    IF Y.EOD.CNOS<Y.EOD.NO> <> "" THEN
        IF Y.HIS.CNOS<Y.HIS.NO> <> "" THEN
            BEGIN CASE
            CASE Y.EOD.CNOS<Y.EOD.NO> > Y.HIS.CNOS<Y.HIS.NO>
                YKEY = Y.HIS.CNOS<Y.HIS.NO>
                Y.HIS.NO += 1
                YHIST.PROCESS = 1
            CASE Y.EOD.CNOS<Y.EOD.NO> < Y.HIS.CNOS<Y.HIS.NO>
                YKEY = Y.EOD.CNOS<Y.EOD.NO>
                Y.EOD.NO += 1
            CASE OTHERWISE
                YKEY = Y.EOD.CNOS<Y.EOD.NO>
                Y.EOD.NO += 1
                Y.HIS.NO += 1
                YHIST.PROCESS = 1
            END CASE
        END ELSE
            YKEY = Y.EOD.CNOS<Y.EOD.NO>
            Y.EOD.NO += 1
        END
    END ELSE
        IF Y.HIS.CNOS<Y.HIS.NO> <> "" THEN
            YKEY = Y.HIS.CNOS<Y.HIS.NO>
            Y.HIS.NO += 1
            YHIST.PROCESS = 1
        END ELSE
            Y.ENDRUN = "YES"
        END
    END
*
    RETURN
*
*************************************************************************
*
OPEN.MM.FILES:
**************
    Y.MM.BAL.FILE = "F.LMM.ACCOUNT.BALANCES"
    F.LMM.ACCOUNT.BALANCES = ""
    CALL OPF(Y.MM.BAL.FILE,F.LMM.ACCOUNT.BALANCES)
*
    Y.MM.FILE = "F.MM.MONEY.MARKET"
    F.MM.MONEY.MARKET = ""
    CALL OPF(Y.MM.FILE,F.MM.MONEY.MARKET)
*
    Y.RE.LMM.BAL.FILE = "F.RE.LMM.BALANCES"
    F.RE.LMM.BALANCES = ""
    CALL OPF(Y.RE.LMM.BAL.FILE,F.RE.LMM.BALANCES)
*
    Y.INT.PMNT.FILE = "F.RE.LMM.INT.PAYMENT"
    F.RE.LMM.INT.PAYMENT = ""
    CALL OPF(Y.INT.PMNT.FILE,F.RE.LMM.INT.PAYMENT)
*
    Y.INSTL.COND.FILE = "F.LMM.INSTALL.CONDS"
    F.LMM.INSTALL.CONDS = ""
    CALL OPF(Y.INSTL.COND.FILE,F.LMM.INSTALL.CONDS)
*
* open install conds of previous day
*
    Y.RE.INSTL.COND.FILE = "F.RE.LMM.INSTALL.CONDS"
    F.RE.LMM.INSTALL.CONDS = ""
    CALL OPF(Y.RE.INSTL.COND.FILE,F.RE.LMM.INSTALL.CONDS)
*
*
    Y.SCHD.PAST.FILE = "F.LMM.SCHEDULES.PAST"
    F.LMM.SCHEDULES.PAST = ""
    CALL OPF(Y.SCHD.PAST.FILE,F.LMM.SCHEDULES.PAST)
*
    Y.HIST.LIST.FILE = "F.LMM.HISTORY.LIST"
    F.LMM.HISTORY.LIST = ""
    CALL OPF(Y.HIST.LIST.FILE,F.LMM.HISTORY.LIST)
*
    Y.MM.HIS.FILE = "F.MM.MONEY.MARKET$HIS"
    F.MM.MONEY.MARKET$HIS = ""
    CALL OPF(Y.MM.HIS.FILE,F.MM.MONEY.MARKET$HIS)
*
    Y.RE.MM.CHANGED.DEALS = "F.RE.MM.CHANGED.DEALS"
    F.RE.MM.CHANGED.DEALS = ""
    CALL OPF(Y.RE.MM.CHANGED.DEALS,F.RE.MM.CHANGED.DEALS)
*
    RETURN
*
*************************************************************************
*
READ.MM.FILES:
**************
    Y.MM.REC.FOUND = 1
    MATREAD Y.MM.REC FROM F.MM.MONEY.MARKET,YKEY ELSE
        MAT Y.MM.REC = ""
        Y.MM.REC.FOUND = ""
    END
*
    YKEY.BAL = YKEY:"00"
    READ Y.MM.BAL.REC FROM F.LMM.ACCOUNT.BALANCES,YKEY.BAL ELSE Y.MM.BAL.REC = ""
    IF NOT(Y.MM.REC.FOUND) THEN
*
* For MM contracts reversed on the same day
*
        GOSUB READ.MM.HIS.RECORD
    END
*
*  Identify whether the contract is fiduciary contract or not
*
    Y.FID.CONTRACT = 0
    YCHECK.CATEGORY = Y.MM.REC(MM.CATEGORY)
    IF (YCHECK.CATEGORY >= 21040 AND YCHECK.CATEGORY <= 21044) OR (YCHECK.CATEGORY >= 21085 AND YCHECK.CATEGORY <= 21089) THEN
        Y.FID.CONTRACT = 1
    END
*
*   Initialise currency market variable to be used for ccy mkt routine.
*
    Y.CONTRACT.CCY.MKT = Y.MM.REC(MM.CURRENCY.MARKET)
    RETURN
*
*************************************************************************
*
READ.MM.HIS.RECORD:
*==================
    Y.MM.TEMP.REC = ""
    YHIS.NO = 1
    YREC.INDIC = 1
*
* Search history records in steps of 10 history nos. to locate the range
*
    LOOP
        YHIS.SNO = YHIS.NO * 10
        YHIS.KEY = YKEY:";":YHIS.SNO
        READ Y.MM.TEMP.REC FROM F.MM.MONEY.MARKET$HIS, YHIS.KEY ELSE
            Y.MM.TEMP.REC = ""
            YREC.INDIC = ""
        END
    UNTIL YREC.INDIC = "" DO
        YHIS.NO += 1
    REPEAT
*
* Now locate and read the last history record
*
    LOOP
        YREC.INDIC = ""
        YHIS.KEY = YKEY:";":YHIS.SNO
        Y.MM.TEMP.REC = ""
        READ Y.MM.TEMP.REC FROM F.MM.MONEY.MARKET$HIS, YHIS.KEY ELSE
            YREC.INDIC = 1
        END
        YHIS.SNO -= 1
    UNTIL YREC.INDIC = "" OR YHIS.SNO = 0 DO
    REPEAT
*
    IF YREC.INDIC = "" THEN
        MATPARSE Y.MM.REC FROM Y.MM.TEMP.REC,FM
    END ELSE
        E ="MM.RTN.CONTR.MISS.MM.MONEY.MARKET.FILE":FM:YKEY
        GOTO FATAL.ERROR
    END
    RETURN
*
*------------------------------------------------------------------------
*
READ.INSTL.CONDS:
*****************
* Read install conds record from RE.LMM.INSTALL.CONDS file which has
* install conds as of previous day. This is to handle changes in
* install conds record
* Record Key to be used here is '1'
*
    READ Y.INSTL.REC FROM F.RE.LMM.INSTALL.CONDS,"1" ELSE
* if not found use today's install conds rec
        READ Y.INSTL.REC FROM F.LMM.INSTALL.CONDS,"1" ELSE
            E = "MM.RTN.1.MISSING.KEY":FM:"1":VM:Y.INSTL.COND.FILE
            GOTO FATAL.ERROR
        END
    END
    RETURN
*
*************************************************************************
*
READ.INT.PAYMENT:
***********************
    READU Y.INT.PMNT.REC FROM F.RE.LMM.INT.PAYMENT,YKEY.BAL ELSE
        Y.INT.PMNT.REC = ""
        Y.INT.PMNT.REC<RE.LIP.CURRENCY> = Y.MM.BAL.REC<LD27.CURRENCY>
    END
    Y.INT.REC.READ = 1
    RETURN
*
*************************************************************************
*
READ.SCHD.PAST:
***************
    READ Y.SCHD.PAST.REC FROM F.LMM.SCHEDULES.PAST,Y.SCHD.KEY ELSE Y.SCHD.PAST.REC = ""
    RETURN
*
*************************************************************************
*
READU.RE.LMM.BALANCES:
**********************
    Y.RE.LMM.BAL.REC = ""
    READU Y.RE.LMM.BAL.REC FROM F.RE.LMM.BALANCES, YKEY.BAL ELSE
        Y.RE.LMM.BAL.REC = ""
    END
    RETURN
*
************************************************************************
*
WRITE.INT.PAYMENT:
******************
    WRITE Y.INT.PMNT.REC TO F.RE.LMM.INT.PAYMENT,YKEY.BAL
    RETURN
*
*************************************************************************
*
WRITE.RE.LMM.BALANCES:
**********************
    WRITE Y.RE.LMM.BAL.REC ON F.RE.LMM.BALANCES, YKEY.BAL
    RETURN
*
*************************************************************************
*
DELETE.RE.LMM.BALANCES:
***********************
    DELETE F.RE.LMM.BALANCES, YKEY.BAL
    RETURN
*
*************************************************************************
*
DELETE.INT.PAYMENT:
*******************
    DELETE F.RE.LMM.INT.PAYMENT,YKEY.BAL
    RETURN
*
*************************************************************************
*
GET.CONSOL.KEY:
***************
*
    Y.CONSOL.KEY.GENERATED = ""
    IF Y.MM.BAL.REC<LD27.CONSOL.KEY> <> "" THEN
        YKEY.CON = Y.MM.BAL.REC<LD27.CONSOL.KEY>
        YMAT.DATE = ""
    END ELSE
        GOSUB GEN.CONSOL.KEY
        YHIST.PROCESS = ""
        Y.MM.BAL.REC<LD27.CONSOL.KEY> = YKEY.CON
        GOSUB WRITE.LMM.ACCOUNT.BALANCES
        Y.CONSOL.KEY.GENERATED = 1
    END
    RETURN
*
*************************************************************************
*
GEN.CONSOL.KEY:
*==============
*
    MAT YR.LOCAL.FILE.1 = MAT Y.MM.REC
    Y.LOCAL.FILE.ID = YKEY
    YKEY.CON = "MM":".":Y.MM.REC(MM.CURRENCY.MARKET):".":Y.MM.REC(MM.POSITION.TYPE):".":Y.MM.REC(MM.CURRENCY)
*
    $INSERT I_GOSUB.RE.KEY.GEN.CON
*
REM CONSOLIDATE KEY GENERATED IS NOW STORED IN YKEY.CON
*
    RETURN
*
*************************************************************************
*
PROCESS.STATIC.CHANGES:
*======================
*
* Read Today's history list file
*
    YHIST.KEY = YKEY:TODAY
    GOSUB READ.HIST.LIST
*
* Initialise memory variables used to check changes in key fields
* and interest fields
*
    YKEY.FIELD.CHANGED = ""
    YKEY.NEW = YKEY.CURR
*
* Check for changes in the consolidation entries
*
    YCOUNT.HIS.RECS = COUNT(Y.HIST.LIST.REC<LD26.CURRENT.NO>,VM)+1
    FOR YX = YCOUNT.HIS.RECS TO 1 STEP -1
*MODIFIED AS PER EB87 324
        IF Y.HIST.LIST.REC<LD26.FILE.NAME,YX> MATCHES "0X'MM.MONEY.MARKET'" THEN
            Y.HIS.REC.NO = Y.HIST.LIST.REC<LD26.CURRENT.NO,YX> - 1
            IF Y.HIS.REC.NO = 0 THEN
                YX = 1
            END ELSE
                Y.MM.HIS.KEY = YKEY:";":Y.HIS.REC.NO
                GOSUB READ.MM.HIS.FILE
                GOSUB CHECK.CONSOLIDATION.CHANGE
            END
        END
    NEXT
*
    IF YKEY.FIELD.CHANGED THEN
*
* When there is change in consolidation key fields
*
        GOSUB GEN.CONSOL.KEY
        YKEY.NEW = YKEY.CON
        IF YKEY.NEW <> YKEY.CURR THEN
*
* Account for balance and interest changes
*
            GOSUB PROCESS.BAL.AND.INT.CHANGE
            Y.MM.BAL.REC<LD27.CONSOL.KEY> = YKEY.NEW
*
* Save calculated consol. key
*
            GOSUB WRITE.LMM.ACCOUNT.BALANCES
*
*  Save the account balance key & old cponsol key
*
            LOCATE YKEY.BAL IN Y.CHNGED.CONTRACTS<1,1> BY "AL" SETTING YPOSITION ELSE
                INS YKEY.BAL BEFORE Y.CHNGED.CONTRACTS<1,YPOSITION>
                INS YKEY.CURR BEFORE Y.OLD.KEYS<1,YPOSITION>
            END
        END
    END
*
    RETURN
*
*************************************************************************
*
READ.HIST.LIST:
*==============
    READ Y.HIST.LIST.REC FROM F.LMM.HISTORY.LIST, YHIST.KEY ELSE
        E = "MM.RTN.RECORD.MISS":FM:YHIST.KEY:VM:Y.HIST.LIST.FILE
        GOTO FATAL.ERROR
    END
    RETURN
*
*************************************************************************
*
READ.MM.HIS.FILE:
*================
    READ Y.MM.HIS.REC FROM F.MM.MONEY.MARKET$HIS,Y.MM.HIS.KEY ELSE
        E = "MM.RTN.HIS.REC.MISS":FM:Y.MM.HIS.KEY:VM:Y.MM.HIS.FILE
        GOTO FATAL.ERROR
    END
    RETURN
*
*************************************************************************
*
STORE.MM.KEY.FIELDS:
*===================
    Y.MM.KEY.FIELDS = ""
    YAV = 1
    LOOP
        YCON.FILE = YR.CONSOLIDATE.COND(RE.CON.LOCAL.FILE.NAME)<1,YAV>
    UNTIL YCON.FILE = "" DO
        IF YCON.FILE = "MM.MONEY.MARKET" THEN
            YFD.NO = YR.CONSOLIDATE.COND(RE.CON.LOCAL.FIELD.NAM)<1,YAV>
            IF INDEX(YFD.NO,"/",1) THEN
*
*  Do not store key fields if of the form Amount / Ccy or Date / Date
*
                NULL
            END ELSE
                Y.MM.KEY.FIELDS = INSERT(Y.MM.KEY.FIELDS,-1,0,0,YFD.NO)
            END
        END
        YAV += 1
    REPEAT
    RETURN
*
*************************************************************************
*
WRITE.LMM.ACCOUNT.BALANCES:
*==========================
    WRITE Y.MM.BAL.REC TO F.LMM.ACCOUNT.BALANCES,YKEY.BAL
    RETURN
*
*************************************************************************
*
WRITE.MM.CHANGED.DEALS:
*======================
*
    Y.CHANGED.CONTRACT.REC = ""
    Y.CHANGED.CONTRACT.REC<1> = Y.CHNGED.CONTRACTS
    Y.CHANGED.CONTRACT.REC<2> = Y.OLD.KEYS
    WRITE Y.CHANGED.CONTRACT.REC ON F.RE.MM.CHANGED.DEALS, "MONEY.MARKET"
    RETURN
*
*************************************************************************
*
CHECK.CONSOLIDATION.CHANGE:
*==========================
* Set indicator if any of consol.key fields has changed
*
    YAF = 1
    LOOP
        YCHEK.FIELD = Y.MM.KEY.FIELDS<YAF>
    UNTIL YKEY.FIELD.CHANGED = "Y" OR YCHEK.FIELD = "" DO
        IF Y.MM.HIS.REC<YCHEK.FIELD> <> "_" THEN
            YKEY.FIELD.CHANGED = "Y"
        END
        YAF += 1
    REPEAT
    RETURN
*
*************************************************************************
*
PROCESS.BAL.AND.INT.CHANGE:
*==========================
*
* Entries for Balance fields
*
    YCOUNT.AV = COUNT(Y.MM.BAL.REC<LD27.DATE.FROM>,VM)+1
    YH.AMOUNT = Y.MM.BAL.REC<LD27.OUTS.FWD.PRINC,YCOUNT.AV>
    IF YH.AMOUNT <> "" AND YH.AMOUNT <> 0 THEN
        IF YH.AMOUNT > 0 THEN YH.TYPE = Y.FWD.CR.TYPE
        ELSE YH.TYPE = Y.FWD.DB.TYPE
*
* Local equivalent of forward principal should be available in
* record var. Y.RE.LMM.BAL.REC
*
        YH.LCLAMT = Y.RE.LMM.BAL.REC<RE.RLB.OUTS.FWD.PRINC.LCL>
        YH.SCHD.AMOUNT = YH.AMOUNT
        GOSUB RAISE.CONSOL.ENTRIES
        YH.LCLAMT = ""
    END
    YH.AMOUNT = Y.MM.BAL.REC<LD27.OUTS.CURR.PRINC,YCOUNT.AV> + Y.MM.BAL.REC<LD27.OUTS.OD.PRINC,YCOUNT.AV> + 0
    IF YH.AMOUNT <> 0 THEN
        IF YH.AMOUNT > 0 THEN YH.TYPE = Y.CURR.CR.TYPE
        ELSE YH.TYPE = Y.CURR.DB.TYPE
*
* check for FIDUCIARY types
*
        IF Y.FID.CONTRACT THEN
            IF YH.AMOUNT > 0 THEN
                YH.TYPE = Y.FID.CR.TYPE
            END ELSE
                YH.TYPE = Y.FID.DB.TYPE
            END
            YH.LCLAMT = Y.RE.LMM.BAL.REC<RE.RLB.OUTS.CUR.PRINC.LCL>
        END
        YH.SCHD.AMOUNT = YH.AMOUNT
        GOSUB RAISE.CONSOL.ENTRIES
        YH.LCLAMT = ''
    END
*
* Entries for Interest fields
*
    IF Y.FID.CONTRACT THEN
*
*   Skip interest processing for fiduciary contracts
*
        NULL
    END ELSE
        YH.AMOUNT = Y.MM.BAL.REC<LD27.OUTS.ACCRUED.INT> + Y.MM.BAL.REC<LD27.OUTS.OVER.DUE.INT> + 0
        IF YH.AMOUNT <> 0 THEN
*
*** Use FIND.CCY.MKT routine to get currency market for MM interest.
*
            Y.CALL.TYPE = '4'
            Y.MVMT.ID = 'INTEREST'
            GOSUB FIND.MARKET:
            YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.IR..CUR>:'.':Y.CALL.CCY.MKT
            YH.SCHD.AMOUNT = 0
            GOSUB RAISE.CONSOL.ENTRIES
        END
*
        YH.AMOUNT = Y.MM.BAL.REC<LD27.OUTS.CUR.ACC.I.PAY> + Y.MM.BAL.REC<LD27.INT.PAYABLE.UCL>
        IF YH.AMOUNT <> 0 THEN
*
*** Use FIND.CCY.MKT routine to get currency market for MM interest.
*
            Y.CALL.TYPE = '4'
            Y.MVMT.ID = 'INTEREST'
            GOSUB FIND.MARKET:
            YH.TYPE = Y.INSTL.REC<LD30.PL.O.SET.IP..CUR>:'.':Y.CALL.CCY.MKT
            YH.SCHD.AMOUNT = 0
            GOSUB RAISE.CONSOL.ENTRIES
        END
    END
*
    RETURN
*
*************************************************************************
*
PROCESS.SCHEDULE.CHANGES:
*------------------------
*
*  Check whether the interest fields ( Int.rate, Interest key, Interest
*  spread etc. have chenged and raise appropriate entries.
*
    YINT.FIELD.CHANGED = ""
    YCHANGE.VALUE.DATE = Y.RE.LMM.BAL.REC<RE.RLB.VALUE.DATE>
    YCHANGE.MAT.DATE = Y.RE.LMM.BAL.REC<RE.RLB.MAT.DATE>
    YCHANGE.INT.RATE = Y.RE.LMM.BAL.REC<RE.RLB.INTER.RATE>
    YCHANGE.INT.KEY = Y.RE.LMM.BAL.REC<RE.RLB.INTER.KEY>
    YCHANGE.INT.SPREAD = Y.RE.LMM.BAL.REC<RE.RLB.INTER.SPREAD>
    YKEY.NEW = YKEY.CURR
*
    IF YCHANGE.VALUE.DATE <> Y.MM.REC(MM.VALUE.DATE) THEN
        YINT.FIELD.CHANGED = 1
    END
*
    IF YCHANGE.MAT.DATE <> Y.MM.REC(MM.MATURITY.DATE) THEN
        YINT.FIELD.CHANGED = 1
    END
*
    IF YCHANGE.INT.RATE <> Y.MM.REC(MM.INTEREST.RATE) THEN
        YINT.FIELD.CHANGED = 1
    END
*
    IF YCHANGE.INT.KEY <> Y.MM.REC(MM.INTEREST.KEY) THEN
        YINT.FIELD.CHANGED = 1
    END
*
    IF YCHANGE.INT.SPREAD <> Y.MM.REC(MM.INTEREST.SPREAD.1) THEN
        YINT.FIELD.CHANGED = 1
    END
*
    IF YINT.FIELD.CHANGED THEN
        GOSUB PROCESS.BAL.RATE.CHANGE:
    END
    RETURN
*
*
PROCESS.BAL.RATE.CHANGE:
*=======================
*
    YCOUNT.AV = COUNT(Y.MM.BAL.REC<LD27.DATE.FROM>,VM)+1
    YAV = YCOUNT.AV
    LOOP
        IF YAV <> 0 THEN YDATE = Y.MM.BAL.REC<LD27.DATE.FROM,YAV>
    UNTIL YDATE < TODAY OR YAV = 0 DO
        YAV -= 1
    REPEAT
*
    IF YAV <> 0 THEN
        Y.SCHD.AMOUNT = Y.MM.BAL.REC<LD27.OUTS.FWD.PRINC,YAV> + 0
        IF Y.SCHD.AMOUNT <> 0 THEN
            IF Y.SCHD.AMOUNT > 0 THEN YH.TYPE = Y.FWD.CR.TYPE
            ELSE YH.TYPE = Y.FWD.DB.TYPE
            GOSUB RAISE.INT.ENTRIES
        END
*
        Y.SCHD.AMOUNT = Y.MM.BAL.REC<LD27.OUTS.CURR.PRINC,YAV> + Y.MM.BAL.REC<LD27.OUTS.OD.PRINC,YAV> + 0
        IF Y.SCHD.AMOUNT <> 0 THEN
            IF Y.SCHD.AMOUNT > 0 THEN YH.TYPE = Y.CURR.CR.TYPE
            ELSE YH.TYPE = Y.CURR.DB.TYPE
*
* check for FIDUCIARY types
*
            YCHECK.CATEGORY = Y.MM.REC(MM.CATEGORY)
            IF (YCHECK.CATEGORY >= 21040 AND YCHECK.CATEGORY <= 21044) OR (YCHECK.CATEGORY >= 21085 AND YCHECK.CATEGORY <= 21089) THEN
                IF Y.SCHD.AMOUNT > 0 THEN
                    YH.TYPE = Y.FID.CR.TYPE
                END ELSE
                    YH.TYPE = Y.FID.DB.TYPE
                END
            END
            GOSUB RAISE.INT.ENTRIES
        END
    END
*
    RETURN
*
*************************************************************************
*
RAISE.CONSOL.ENTRIES:
*====================
    FOR YENT = 1 TO 2
        Y.PARAMS.CON = ""
        IF YENT = 1 THEN
            Y.PARAM.KEY = YKEY.CURR
            Y.AMT.SIGN = -1
            Y.KEY.TO.BE.REMOVED = YKEY
        END ELSE
            Y.PARAM.KEY = YKEY.NEW
            Y.AMT.SIGN = 1
            Y.KEY.TO.BE.REMOVED = ""
        END
*
        IF YH.TYPE = Y.FWD.CR.TYPE OR YH.TYPE = Y.FWD.DB.TYPE OR YH.TYPE = Y.CURR.CR.TYPE OR YH.TYPE = Y.CURR.DB.TYPE OR YH.TYPE = Y.FID.CR.TYPE OR YH.TYPE = Y.FID.DB.TYPE THEN
            Y.LINK.FILE.KEY = YKEY
        END ELSE
            Y.KEY.TO.BE.REMOVED = ""
            Y.LINK.FILE.KEY = ""
        END
*
        Y.PARAMS.CON<1> = Y.PARAM.KEY
        Y.PARAMS.CON<2> = FIELD(Y.PARAM.KEY,".",4)
        Y.PARAMS.CON<3> = YH.TYPE
        Y.CCY.MKT = FIELD(YH.TYPE,'.',2)
        IF Y.CCY.MKT = '' THEN
            Y.CCY.MKT = FIELD(Y.PARAM.KEY,".",2)
        END
        Y.PARAM.AMT = YH.AMOUNT * Y.AMT.SIGN
*
        Y.LOCAL.EQ.AMT = ""
        YEXCHANGE.RATE = ""
        IF Y.PARAMS.CON<2> <> LCCY THEN
            IF YH.TYPE = Y.FID.CR.TYPE OR YH.TYPE = Y.FID.DB.TYPE THEN
                Y.LOCAL.EQ.AMT = YH.LCLAMT * Y.AMT.SIGN
                YEXCHANGE.RATE = Y.RE.LMM.BAL.REC<RE.RLB.CURR.EXCH.RATE>
            END ELSE
                IF YH.TYPE = Y.FWD.CR.TYPE OR YH.TYPE = Y.FWD.DB.TYPE THEN
                    Y.LOCAL.EQ.AMT = YH.LCLAMT * Y.AMT.SIGN
                    YEXCHANGE.RATE = Y.RE.LMM.BAL.REC<RE.RLB.EXCHANGE.RATE>
                END ELSE
                    CALL MIDDLE.RATE.CONV.CHECK(Y.PARAM.AMT,Y.PARAMS.CON<2>,YEXCHANGE.RATE,Y.CCY.MKT,Y.LOCAL.EQ.AMT,"","")
                    IF ETEXT <> "" THEN
                        E = "MM.RTN.CCY.CONV.ERR":FM:Y.PARAM.KEY:VM:Y.PARAM.AMT:VM:ETEXT
                        GOTO FATAL.ERROR
                    END
                END
            END
        END
*
        IF Y.PARAM.AMT > 0 THEN
            Y.PARAMS.CON<4> = ""
            Y.PARAMS.CON<5> = Y.PARAM.AMT
            Y.PARAMS.CON<6> = ""
            Y.PARAMS.CON<7> = Y.LOCAL.EQ.AMT
        END ELSE
            Y.PARAMS.CON<4> = Y.PARAM.AMT
            Y.PARAMS.CON<5> = ""
            Y.PARAMS.CON<6> = Y.LOCAL.EQ.AMT
            Y.PARAMS.CON<7> = ""
        END
        Y.PARAMS.CON<20> = YEXCHANGE.RATE
*
        IF YH.SCHD.AMOUNT <> 0 THEN
            Y.PARAMS.CON<8> = Y.MM.REC(MM.VALUE.DATE)
            Y.PARAMS.CON<9> = Y.MM.REC(MM.MATURITY.DATE)
            Y.PARAMS.CON<10> = ""
            Y.PARAMS.CON<11> = Y.MM.REC(MM.INTEREST.RATE)
            Y.PARAMS.CON<12> = Y.MM.REC(MM.INTEREST.KEY)
            Y.PARAMS.CON<13> = Y.MM.REC(MM.INTEREST.SPREAD.1)
            Y.PARAMS.CON<14> = YH.SCHD.AMOUNT * Y.AMT.SIGN
        END
*
        Y.PARAMS.CON<15> = Y.LINK.FILE.KEY
        Y.PARAMS.CON<16> = Y.KEY.TO.BE.REMOVED
        Y.PARAMS.CON<17> = YKEY
        Y.PARAMS.CON<18> = Y.MM.REC(MM.CUSTOMER.ID)
        Y.PARAMS.CON<19> = YSPL.ENT.TXN.REF.APP
        Y.PARAMS.CON<21> = Y.MM.REC(MM.DEPT.CODE)
        Y.PARAMS.CON<22> = Y.MM.REC(MM.CATEGORY)
        CALL RE.CONSOL.UPDATE(Y.PARAMS.CON,"ASSET&LIAB","")
    NEXT
*
    RETURN
*
************************************************************************
*
RAISE.INT.ENTRIES:
*=================
    Y.PARAMS.CON = ""
    IF YKEY.FIELD.CHANGED THEN
        Y.PARAM.KEY = YKEY.CURR
    END ELSE
        Y.PARAM.KEY = YKEY.NEW
    END
    Y.PARAMS.CON<1> = Y.PARAM.KEY
    Y.PARAMS.CON<2> = FIELD(Y.PARAM.KEY,".",4)
*
************************************************************************
* Y.PARAM.MAT.DATE is no longer required in the parameters (AMD.DT:01.05.1986)
*
*      IF Y.MAT.DATE.INCLUDED.IN.KEY THEN
*         Y.PARAMS.CON<3> = Y.PARAM.MAT.DATE
*      END
*************************************************************************
*
    Y.PARAMS.CON<3> = YH.TYPE
    Y.PARAMS.CON<15> = ""
    Y.PARAMS.CON<17> = YKEY
    Y.PARAMS.CON<18> = Y.MM.REC(MM.CUSTOMER.ID)
    Y.PARAMS.CON<19> = "SCH"
    Y.PARAMS.CON<20> = ""
    Y.PARAMS.CON<21> = Y.MM.REC(MM.DEPT.CODE)
    Y.PARAMS.CON<22> = Y.MM.REC(MM.CATEGORY)
    Y.PARAMS.CON<8,1> = YCHANGE.VALUE.DATE
    Y.PARAMS.CON<9,1> = YCHANGE.MAT.DATE
    Y.PARAMS.CON<10,1> = ""
    Y.PARAMS.CON<11,1> = YCHANGE.INT.RATE
    Y.PARAMS.CON<12,1> = YCHANGE.INT.KEY
    Y.PARAMS.CON<13,1> = YCHANGE.INT.SPREAD
    Y.PARAMS.CON<14,1> = Y.SCHD.AMOUNT * (-1)
    Y.PARAMS.CON<8,2> = Y.MM.REC(MM.VALUE.DATE)
    Y.PARAMS.CON<9,2> = Y.MM.REC(MM.MATURITY.DATE)
    Y.PARAMS.CON<10,2> = ""
    Y.PARAMS.CON<11,2> = Y.MM.REC(MM.INTEREST.RATE)
    Y.PARAMS.CON<12,2> = Y.MM.REC(MM.INTEREST.KEY)
    Y.PARAMS.CON<13,2> = Y.MM.REC(MM.INTEREST.SPREAD.1)
    Y.PARAMS.CON<14,2> = Y.SCHD.AMOUNT
    CALL RE.CONSOL.UPDATE(Y.PARAMS.CON,"ASSET&LIAB","")
*
    RETURN
*
*************************************************************************
*
FATAL.ERROR:
************
    TEXT = E ; CALL FATAL.ERROR("CONV.RE.MM.BAL.MOVE")
*
*************************************************************************
*
END
