* @ValidationCode : MjoyMDQ4MTI1NTE1OkNwMTI1MjoxNDkzMzY1NDI3NDQ5OmpvaG5zb246LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwMy4yMDE3MDIyMi0wMTM1Oi0xOi0x
* @ValidationInfo : Timestamp         : 28 Apr 2017 13:13:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : johnson
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201703.20170222-0135
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-25</Rating>
*
*-----------------------------------------------------------------------------
    $PACKAGE MG.ModelBank
    SUBROUTINE E.MG.BALANCE.ENQUIRY

*  This routine is used by the enquiry module to call MG.FORWARD.VIEW.
*  In order to use this the enquiry must be called via a "W" type
*  program so that the "forward date" can be R.NEW.
*
*  INPUT
*
*  OUTPUT
*  ------
*  R.RECORD  : Enquiry common variable which will be loaded with the
*              contents od R.WORK.BALANCES.
*
*******************************************************************
* 01/03/00 - GB0000005
*            The variable O.DATA is now updated with the Principal
*            Amount instead of the Outstanding Principal.
*
* 20/03/01 - GB0100807
*            The forward dated principal increase is shown in the enquiry
*
* 23/04/01 - GB0102029
*            Include past principal increases also, and show them
*            in a different line
*
* 10/08/01 - BG_10000010
*            Pif GB0102029 replicated in Dimensions for G12.0.01
*
* 24/08/01 - EN_10000067
*            Interest capitalized during deferred period by adding
*            the accrued interest for the deferred period to the
*            principal due of the MG contract and schedules would be
*            defined based on this new capital amount. Capitalisation
*            is flagged by the value in the new field(MG.DEF.INT.CAP)
*            in MG.MORTGAGE contract.
*            A new field (#500) is added to R.RECORD that contains
*            the PRINCIPAL.BALANCE value as a source for the
*            MG.FUTURE.BALANCES enquiry.
*
* 12/02/02 - CI_10000705
*            Cycling of Add pay dates.
*
* 23/10/02 - CI_10004312
*            When authorize the MG contract after executing
*            the MG.FUTURE.BALANCE enquiry the MG contract gets
*            updated with wrong values in the fields CUSTOMER and
*            CONTRACT.TYPE. These fields are updated with dates.
*            (This happens when enq is run in desktop)
*
*
* 12/11/02 - CI_10004652
*            Wrong updation in MG.PAYMENT.CONTROL,when enquiry is
*            run under desktop.
* 11/12/02 - CI_10005236/CI_10005138
*            In ENQUIRY(MG.FUTURE.BALANCES and MG.CLOSING.BALANCES)
*            CAP.INT value is not displayed in the repayment period,
*            when Repayment is done.
*
*  23/12/02 - CI_10005736
*            Under desktop, when MG.PAYMENT of MG1 is kept at INAU
*            and enquiry is run for MG2 and authorising the MG.PAY
*            MENT of MG1, results in overwritten of MG2 to MG1.
*
* 13/01/03 - CI_10006195
*            Under desktop, when MG.PAYMENT of MG1 is kept at INAU
*            and enquiry is run for MG2 and authorising the MG.PAY
*            MENT of MG1, results in overwrittend of field EFF.INT and
*            Committed.int in MG2 to MG1
*
* 27/08/03 - CI_10012057
*            CONTRACT$ID has no value and hence ETEXT is set while
*            trying to read PD.PAYMENT.DUE using the MG id through
*            CONTRACT$ID, in MG.PERFORM.ACCRUALS.
*
* 14/10/03 - CI_10012981
*            Enq show capitalised interest on next redemption, when
*            def.int.cap is defined for the current redemption period.
*
* 17/02/04 - CI_10017433
*            While the print option is given at the MG.FUTURE.BALANCES
*            enquiry that is invoked from MG.BALANCE.ENQUIRY the system
*            crashes out given CDT error.
*
* 14/05/04 - EN_10002260
*            Multibook Changes
*
* 08/09/04 - EN_10002338
*            Next Working day for MG schedules
*
* 14/06/05 - CI_10031094
*            Enquiry issues for an unauthorised contract.
*
* 21/06/05 - CI_10031243
*            After crossing one Schedule, deferment of interest
*            causes incorrect display.
*
* 21/03/06 - CI_10039858
*            When the enquiry MG.FUTURE.BALANCES is run for a MG contract
*            in INAU status with principal increase done, the enquiry
*            displays two principal increases.
*
* 20/07/06 - CI_10042808
*            When a principal decrease is made in a MG contract through
*            a MG.PAYMENT which is kept in INAU status, the system is not
*            showing correct future balance in MG.FUTURE.BALANCES Enquiry.
*
* 28/05/08 - BG_100018583
*            Reducing the compiler rating.
*
* 18/03/09 - CI_10062043
*            Wrong display of the MG.FUTURE.BALANCES when a backdated
*            MG.PAYMENT is done for the previous repayment date.
*
* 13/07/16 - Task : 1793313 / Defect : 1786679
*            System would print the same result of enquiry output in the HOLD file .
*
* 26/04/17 - Task :  2104165 / Defect :2104154
*            Regression Inconsistency defects.
*
* 28/04/17 - Task : 2105723 / Defect : 2105582
*            MG_ModelBank failed in 201704 TAFC Compilation
*
*******************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.MG.MORTGAGE
    $INSERT I_F.MG.PARAMETER
    $INSERT I_F.MG.BALANCES
    $INSERT I_F.MG.PAYMENT
    $INSERT I_F.MG.ADVICES
    $INSERT I_F.MG.SCHEDULES
    $INSERT I_F.MG.PAYMENT.CONTROL
    $INSERT I_MG.COMMON
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.MG.BALANCE.ENQUIRY
    
*********************************************************************

* SAVE and STORE the common variable values, to avoid  common variable
* to be used by some other applications, when executed under desktop.

    GOSUB INITIALISE          ;* BG_100018583 S/E
    IF APPLICATION NE "MG.BALANCE.ENQUIRY" THEN
        F.MG.MORTGAGE = ""
        CALL OPF("F.MG.MORTGAGE",F.MG.MORTGAGE)
*
        IF ETEXT THEN
            RETURN
        END         ;* BG_100018583 S/E

        MG.ERR = ''
        F.MG.MORTGAGE$NAU = ""
        CALL OPF("F.MG.MORTGAGE$NAU", F.MG.MORTGAGE$NAU)
        IF ETEXT THEN
            RETURN
        END         ;* BG_100018583 S/E
*
        GOSUB MG.MORTGAGE.REC ;* BG_100018583 S/E

        F$MG.PAYMENT = ''     ;* CI_10042808  S
        F$MG.PAYMENT.FILE = "F.MG.PAYMENT$NAU"
        CALL OPF(F$MG.PAYMENT.FILE, F$MG.PAYMENT) ;* CI_10042808 E
*
        MAT R$PARAMETER = ''  ;* EN_10002260 S
        F.MG.PARAMETER = ''
        MG.PARAM.ID = ''
        CALL EB.READ.PARAMETER('F.MG.PARAMETER','N',MAT R$PARAMETER,'',MG.PARAM.ID,F.MG.PARAMETER,YERR)       ;* EN_10002135 S/E ; * BG_10006150 S/E
        IF YERR THEN
            RETURN
        END
    END
*
    GOSUB CHECK.APPLICATION   ;* BG_100018583 S/E


* As of now the def.int fields are arranged in ascending order whereas the BAL.REPAYMENT fields
* are arranged in descending order & this results in incorrect enquiry display. Hence
* sort & send the def int fields(49-51), in R$BALANCES, inorder to display the Repayments correctly
* along with their deffered amts after crossing a repayment schedule with deferred interest.
*

    TEMP.I =  DCOUNT(R$BALANCES(MG.BAL.DEF.IN.EFF.DATE),VM) ;* CI_10031243 S
    FOR NO.I = TEMP.I TO 1 STEP -1
        DEF.INT.DATE<1,-1> = R$BALANCES(MG.BAL.DEF.IN.EFF.DATE)<1,NO.I>
        DEF.INT.AMT<1,-1> = R$BALANCES(MG.BAL.DEF.INT.AMT)<1,NO.I>
        DEF.TAX.AMT<1,-1> = R$BALANCES(MG.BAL.DEF.TAX.AMT)<1,NO.I>
    NEXT NO.I
    R$BALANCES(MG.BAL.DEF.IN.EFF.DATE) = DEF.INT.DATE
    R$BALANCES(MG.BAL.DEF.INT.AMT) = DEF.INT.AMT
    R$BALANCES(MG.BAL.DEF.TAX.AMT) = DEF.TAX.AMT  ;* CI_10031243 E
*
    IF MAT.DATE GT R$BALANCES(MG.BAL.ACCR.TO.DATE) THEN
* Call MG.FORWARD.VIEW with mode.
        CALL MG.FORWARD.VIEW( MAT.DATE:FM:'ENQ', MAT R.WORK.BALANCES, "", FWD.ERROR)      ;* CI_10000705 S/E
    END ELSE
        MAT R.WORK.BALANCES = MAT R$BALANCES
    END

* Before we do any furhter processing determine the prin balance on
* the requested start date as it may be needed by then enquiry. It is
* easier to do it now before we remove any of the unwanted detail

    IF VAL.DATE LT R.WORK.BALANCES(MG.BAL.RECORD.START.DATE) THEN
        START.DATE = R.WORK.BALANCES(MG.BAL.RECORD.START.DATE)
    END ELSE
        START.DATE = VAL.DATE
    END
    LOCATE START.DATE IN R.WORK.BALANCES(MG.BAL.PRIN.EFF.DATE)<1,1> BY "DR" SETTING POS ELSE
        NULL
    END
*    O.DATA = R.WORK.BALANCES(MG.BAL.PRIN.BALANCE)<1,POS>
    O.DATA = R$MORTGAGE(MG.PRINCIPAL.AMOUNT)      ;* GB0000005 SE
    START.SAVE.BAL = O.DATA   ;* EN_10000067 S/E

* Remove all unwanted details based on the START.DATE passed in the
* MG.BALANCE.ENQUIRY record.

    BEGIN CASE
    CASE VAL.DATE GE R.WORK.BALANCES(MG.BAL.RECORD.START.DATE)
        STRIP.DATA = 1
    CASE MAT.DATE LE R.WORK.BALANCES(MG.BAL.ACCR.TO.DATE)<1,1>
        STRIP.DATA = 1
    CASE 1
        STRIP.DATA = ""
    END CASE
    IF STRIP.DATA THEN
        START.DATE = VAL.DATE
        END.DATE = MAT.DATE
    END

    GOSUB REVERSE.TIME.ORDER

* Set the RECORD.START.DATE and END.INT.PERIOD to the dates requested so
* that we can access these form the enquiry.

    IF VAL.DATE GT R.WORK.BALANCES(MG.BAL.RECORD.START.DATE) THEN
        R.WORK.BALANCES(MG.BAL.RECORD.START.DATE) = VAL.DATE
    END
    R.WORK.BALANCES(MG.BAL.END.INT.PERIOD) = MAT.DATE

*
* When a backdated MG.PAYMENT for the previous repayment date is done with DEF.CAP.INT the number of multivalues
* beween the Repayment fields and the DEFERRED CAP fields would be different and hence there will be a position
* mismatch in displaying the cap int amount. Insert the values deferred int fields to solve the differences of multivalue.
*
    NO.OF.DATES =  DCOUNT(R.WORK.BALANCES(MG.BAL.PAYMENT.DATE),VM)
    NO.DEF.DATES = DCOUNT(R.WORK.BALANCES(MG.BAL.DEF.IN.EFF.DATE),VM)
    IF DEF.INT.DATE AND (NO.OF.DATES NE NO.DEF.DATES) THEN
        FOR II = 1 TO NO.OF.DATES
            PAY.BAL.DATE = R.WORK.BALANCES(MG.BAL.PAYMENT.DATE)<1,II>
            IF PAY.BAL.DATE NE R.WORK.BALANCES(MG.BAL.DEF.IN.EFF.DATE)<1,II> THEN
                INS PAY.BAL.DATE BEFORE R.WORK.BALANCES(MG.BAL.DEF.IN.EFF.DATE)<1,II>
                INS '0' BEFORE R.WORK.BALANCES(MG.BAL.DEF.INT.AMT)<1,II>
                INS '0' BEFORE R.WORK.BALANCES(MG.BAL.DEF.TAX.AMT)<1,II>
            END
        NEXT II
    END
    FOR XX = 1 TO MG.BAL.REDEM.DATE     ;* EN_10002338
        R.RECORD<XX> = R.WORK.BALANCES(XX)
    NEXT XX
*
    Y1COUNT = DCOUNT(R.RECORD<MG.BAL.PAYMENT.DATE>, VM)     ;* GB0100807 S  Forward dated principal increase is also incorporated in the R.RECORD.
*
    PRIN.EFF.DATE = R$BALANCES(MG.BAL.PRIN.EFF.DTE)         ;* GB0102029 S
    PRIN.INCREASE = R$BALANCES(MG.BAL.PRIN.INCREASE)        ;* GB0102029 E

    PRIN.INCR.DATES = R$MORTGAGE(MG.PRIN.EFF.DATE)          ;* CI_10039858 S
    PRIN.INCR.AMTS  = R$MORTGAGE(MG.PRIN.INCREASE)
    IF NOT(RUNNING.UNDER.BATCH) AND R$MORTGAGE(MG.RECORD.STATUS)[2,2] EQ 'NA' THEN
        LOCATE TODAY IN PRIN.INCR.DATES<1,1> SETTING DPOS THEN        ;* Principal increase date with effective TODAY will not be cleared during 'INAU' stage. It would also be updated in MG.BALANCES already. So need not take this date once again here.
            DEL PRIN.INCR.DATES<1,DPOS>
            DEL PRIN.INCR.AMTS<1,DPOS>
        END
    END

    PRIN.EFF.DATE<-1> = PRIN.INCR.DATES
    PRIN.INCREASE<-1> = PRIN.INCR.AMTS  ;* CI_10039858 E

    LOOP
        REMOVE YDATE FROM PRIN.EFF.DATE SETTING POS
        REMOVE YPRIN FROM PRIN.INCREASE SETTING POS2
    WHILE YDATE
        YPRIN = YPRIN * -1
        YCOUNT = 1
        LOOP
        WHILE YDATE GT R.RECORD<MG.BAL.PAYMENT.DATE,YCOUNT> AND YCOUNT LE Y1COUNT
            YCOUNT += 1
        REPEAT
        INS YDATE BEFORE R.RECORD<MG.BAL.PAYMENT.DATE,YCOUNT>
        INS YPRIN BEFORE R.RECORD<MG.BAL.PRINCIPAL.RCVD,YCOUNT>
        INS '0' BEFORE R.RECORD<MG.BAL.INTEREST.RCVD,YCOUNT>          ;* CI_10005138 S/E
        INS '0' BEFORE R.RECORD<MG.BAL.REPAYMENT.AMT,YCOUNT>
        INS '0' BEFORE R.RECORD<MG.BAL.TAX.RCVD,YCOUNT>
        INS '0' BEFORE R.RECORD<MG.BAL.MG.PAYMENT.NO,YCOUNT>
        INS '0' BEFORE R.RECORD<MG.BAL.DEF.INT.AMT,YCOUNT>  ;* CI_10005138 S
        INS '0' BEFORE R.RECORD<MG.BAL.DEF.TAX.AMT,YCOUNT>  ;* CI_10005138 E
    REPEAT          ;* GB0100807 E
*

* Before returning to the enquiry we need to tell it the maximum number
* of multivalues and subvalues that it is likely to encounter when
* displaying the current record. The largest number of sub and multi
* values will appear in the accrual fields.

    SAVE.BAL = START.SAVE.BAL ;* EN_10000067 S
    NO.OF.RECS = DCOUNT(R.RECORD<MG.BAL.PAYMENT.DATE>,VM)
    FOR YCOUNT = 1 TO NO.OF.RECS
        PRIN.RCVD.AMT = R.RECORD<MG.BAL.PRINCIPAL.RCVD,YCOUNT>
        SAVE.BAL = START.SAVE.BAL
        DEF.INT.AMT = 0
        DEF.TX.AMT = 0
        DEF.INT.AMT = R.RECORD<MG.BAL.DEF.INT.AMT,YCOUNT>
        DEF.TX.AMT = R.RECORD<MG.BAL.DEF.TAX.AMT,YCOUNT>
        PBALANCE = SAVE.BAL - PRIN.RCVD.AMT + DEF.INT.AMT + DEF.TX.AMT
        R.RECORD<500,-1> = PBALANCE
        START.SAVE.BAL = PBALANCE
    NEXT YCOUNT     ;* EN_10000067 E

    SM.COUNT = COUNT(R.RECORD<MG.BAL.ACCR.PRIN>, SM) + 1
    VM.COUNT = COUNT(R.RECORD<MG.BAL.ACCR.PRIN>, VM) + 1

    MAT R$MORTGAGE = MAT SAVE.R$MORTGAGE          ;* CI_10005736 S/E
    MAT R$BALANCES = MAT SAVE.R$BALANCES          ;* CI_10006195 S/E
    MAT R$PAYMENT = MAT SAVE.R$PAYMENT 
    CONTRACT$ID = SAVE.CONTRACT$ID      ;* CI_12057
    APPLICATION = APPLICATION.SAVE
    RETURN

**************************************************************************
*
INITIALISE:
***********


    DIM SAVE.R$MORTGAGE(MG.AUDIT.DATE.TIME)       ;* CI_10005736 S
    MAT SAVE.R$MORTGAGE = MAT R$MORTGAGE          ;* CI_10005736 E
    DIM SAVE.R$BALANCES(MG.BAL.CHARGE.TAX.AMT)        ;* CI_10006195 S; * EN_10002338
    MAT SAVE.R$BALANCES = MAT R$BALANCES          ;* CI_10006195 E
    DIM SAVE.R$PAYMENT(MG.PAY.AUDIT.DATE.TIME)
    MAT SAVE.R$PAYMENT = MAT R$PAYMENT

    MAT R$MORTGAGE = ""       ;* Clear it, there is a chance of this being corrup
    MAT R$BALANCES = ""
    MAT R$PAYMENT = ""

    DIM R.WORK.BALANCES(MG.BAL.CHARGE.TAX.AMT)        ;* EN_10002338
    MAT R.WORK.BALANCES = ""

    DIM TEMP.REC(MG.BAL.CHARGE.TAX.AMT)     ;* EN_10002338
    MAT TEMP.REC = ""
    SAVE.CONTRACT$ID = CONTRACT$ID      ;* CI_12057 +
    CONTRACT$ID = ID          ;* CI_12057 -
    F.MG.BALANCE.ENQUIRY = '' ;* CI_10017433 S
    CALL OPF("F.MG.BALANCE.ENQUIRY",F.MG.BALANCE.ENQUIRY)   ;* CI_10017433 E

    F.MG.PAYMENT.CONTROL = '' ;* CI_10042808 S
    FN.MG.PAYMENT.CONTROL = "F.MG.PAYMENT.CONTROL"
    CALL OPF(FN.MG.PAYMENT.CONTROL,F.MG.PAYMENT.CONTROL)    ;* CI_10042808 E


    DEF.INT.DATE = '' ; DEF.INT.AMT = ''; DEF.TAX.AMT = ''  ;* CI_10031243 S/E
*
    R.MG = "" ; ETEXT = ""
    APPLICATION.SAVE = ''
    APPLICATION.SAVE = APPLICATION
    
    IF NOT(APPLICATION MATCHES "ENQUIRY.SELECT":@VM:"MG.BALANCE.ENQUIRY") THEN
       APPLICATION = "ENQUIRY.SELECT"
    END

    RETURN
**************************************************************************
*
MG.MORTGAGE.REC:
****************

    IF NOT(RUNNING.UNDER.BATCH) THEN    ;* Make sure we are not reading this in batch
        CALL F.MATREAD("F.MG.MORTGAGE$NAU", ID, MAT R$MORTGAGE, MG.AUDIT.DATE.TIME, F.MG.MORTGAGE$NAU, MG.ERR)
    END

    IF R$MORTGAGE(MG.RECORD.STATUS)[2,2] NE "NA" THEN       ;* If the contract is authorised read the authorised contract
        CALL F.MATREAD("F.MG.MORTGAGE",ID,MAT R$MORTGAGE,MG.AUDIT.DATE.TIME,F.MG.MORTGAGE,MG.ERR)   ;* EN_10000067 ; * CI-10004652
    END

    MAT.DATE = R$MORTGAGE(MG.MATURITY.DATE)
    VAL.DATE = R$MORTGAGE(MG.VALUE.DATE)
*
    F$MG.BALANCES = ""
    CALL OPF("F.MG.BALANCES",F$MG.BALANCES)
    CALL F.MATREAD("F.MG.BALANCES", ID, MAT R$BALANCES, 50, F$MG.BALANCES, E)   ;* CI-10004652
*
    F$MG.PARAMETER = ''
    F$MG.PARAMETER.FILE = "F.MG.PARAMETER"
    CALL OPF(F$MG.PARAMETER.FILE, F$MG.PARAMETER)
    RETURN
**************************************************************************
*
CHECK.APPLICATION:
******************

    IF APPLICATION EQ 'MG.BALANCE.ENQUIRY' THEN   ;* CI_10004312 S
*  The date values that got passed to MG.FORWARD.VIEW is directly
*  read from MG.BALANCE.ENQUIRY file.
        IO.ERR = '' ;* CI_10017433 S
        MG.BAL.REC = ''
        CALL F.READ("F.MG.BALANCE.ENQUIRY",ID,MG.BAL.REC,F.MG.BALANCE.ENQUIRY,IO.ERR)
        IF NOT(IO.ERR) THEN
            IF MG.BAL.REC<MG.BE.START.DATE> AND MG.BAL.REC<MG.BE.END.DATE> THEN
                VAL.DATE = MG.BAL.REC<MG.BE.START.DATE>
                MAT.DATE = MG.BAL.REC<MG.BE.END.DATE>
            END
        END         ;* CI_10017433 E
    END   ;* CI_10004312 E

    PAYMENT.CONTROL.REC = ""  ;* CI_10042808  S
    IO.ERR = ''
    CALL F.READ(FN.MG.PAYMENT.CONTROL, CONTRACT$ID, PAYMENT.CONTROL.REC ,F.MG.PAYMENT.CONTROL,IO.ERR)
    IF PAYMENT.CONTROL.REC<MG.PC.NAU.RECORD> THEN
        MAT R$PAYMENT = ''
        MGP.ID = ID :".": PAYMENT.CONTROL.REC<MG.PC.NAU.RECORD>
        CALL F.MATREAD("F.MG.PAYMENT$NAU", MGP.ID, MAT R$PAYMENT, MG.PAY.AUDIT.DATE.TIME, F$MG.PAYMENT.FILE, E)
    END   ;* CI_10042808  E
    RETURN
*
**************************************************************************
*
*                             INTERNAL ROUTINES
**************************************************************************


STRIP.UNWANTED.DATA:
*===================

* Process each group of fields on R.WORK.BALANCES in turn. This is done by an
* internal routine. For each group of MV fields define the controlling
* date field and the start and end fields of the group and handoff to
* the subroutine SPLIT.MV.FIELDS.

* Contract.type/date feilds

    DATE.FLD = MG.BAL.TYPE.EFF.DATE
    START.FLD = MG.BAL.CONTRACT.TYPE
    END.FLD = MG.BAL.TYPE.EFF.DATE
    GOSUB SPLIT.MV.FIELDS

* principal balance fields

    DATE.FLD = MG.BAL.PRIN.EFF.DATE
    START.FLD = MG.BAL.PRIN.BALANCE
    END.FLD = MG.BAL.PRIN.EFF.DATE
    GOSUB SPLIT.MV.FIELDS

* Interest rate fields

    DATE.FLD = MG.BAL.INT.EFF.DATE
    START.FLD = MG.BAL.INT.RATE
    END.FLD = MG.BAL.INT.EFF.DATE
    GOSUB SPLIT.MV.FIELDS

* Interest accrual fields.

    DATE.FLD = MG.BAL.ACCR.FROM.DATE
    START.FLD = MG.BAL.ACCR.PRIN
    END.FLD = MG.BAL.ACCR.ACT.AMT
    GOSUB SPLIT.MV.FIELDS

    LAST.FROM.DATE = R.WORK.BALANCES(MG.BAL.ACCR.FROM.DATE)<1,LPOS>

* Payment details fields

    DATE.FLD = MG.BAL.PAYMENT.DATE
    START.FLD = MG.BAL.PAYMENT.DATE
    END.FLD = MG.BAL.ADD.PAY.5.RCVD
    GOSUB SPLIT.MV.FIELDS

* Remove all categ.entry ids as they are not required

    R.WORK.BALANCES(MG.BAL.ENTRY.IDS) = ""

    RETURN


SPLIT.MV.FIELDS:
*===============

    LOCATE END.DATE IN R$BALANCES(DATE.FLD)<1,1> BY "DR" SETTING HPOS THEN
        IF R.WORK.BALANCES(DATE.FLD)<1,HPOS + 1> = END.DATE THEN
            HPOS += 1
        END
    END ELSE
        NULL
    END

* When removing data from the live record if we do not locate the
* required date exactly then for the contract.type, prin.balance,
* interest.rate and accrual fields we must take the values for the
* set immediately prior to the split date. If we do not do this then
* the opening values of these fields will not be known. However this is
* not required nor is it desirable for the repayment fields.

    LOCATE START.DATE IN R.WORK.BALANCES(DATE.FLD)<1,1> BY "DR" SETTING LPOS THEN
        IF R.WORK.BALANCES(DATE.FLD)<1, LPOS + 1> = START.DATE THEN
            LPOS += 1
        END
    END ELSE
        IF DATE.FLD = MG.BAL.PAYMENT.DATE THEN
            LPOS -= 1
        END
    END

* Find the position of the value marks where we need to split the
* record. We can the perform a string extraction to do the split
* which is the fastest.

    FOR XX = START.FLD TO END.FLD

* If HPOS is 1 then then the whole field is required so don't bother
* with the string extraction. If HPOS is greater than the number of MVs,
* ie the history end date is less that the last date in the field,
* then we don't want anything. In this case the index function will
* return a 0 as the VM required does not exist so we can skip the string
* extraction.

        IF HPOS LE 1 THEN
            R.WORK.BALANCES(XX) = R.WORK.BALANCES(XX)
        END ELSE
            HIST.INDEX = INDEX(R.WORK.BALANCES(XX), VM, HPOS-1) + 1
            IF HIST.INDEX GT 1 THEN
                R.WORK.BALANCES(XX) = R.WORK.BALANCES(XX)[HIST.INDEX, 999]
            END
        END

* If LPOS is less than 1 ie this is a payment field and the last payment
* was before the live start date (contract has matured) then no data
* should be present on the live record so set then field to null.
* If the value mark we are looking for does not exist, ie the live start
* date is less than the last date in the field, then take the whole field
* as it is all required. If we do not do this then the INDEX function
* will return a -1 and the field will be lost.

        IF LPOS LT 1 THEN
            R.WORK.BALANCES(XX) = ""
        END ELSE
            LIVE.INDEX = INDEX(R.WORK.BALANCES(XX), VM, LPOS) - 1
            IF LIVE.INDEX GT 0 THEN
                R.WORK.BALANCES(XX) = R.WORK.BALANCES(XX)[1, LIVE.INDEX]
            END
        END
    NEXT XX

    RETURN


REVERSE.TIME.ORDER:
*==================

* Data on the MG.BALANCES file is stored in reverse chronological order
* which is O.K. for updating but not so good for display purposes.
* therefore reverse the order of each group of MV fields.

    MAT TEMP.REC = MAT R.WORK.BALANCES

    START.GROUP = MG.BAL.CONTRACT.TYPE
    END.GROUP = MG.BAL.TYPE.EFF.DATE
    GOSUB REVERSE.ORDER

    START.GROUP = MG.BAL.PRIN.BALANCE
    END.GROUP = MG.BAL.PRIN.EFF.DATE
    GOSUB REVERSE.ORDER

    START.GROUP = MG.BAL.INT.EFF.DATE
    END.GROUP = MG.BAL.INT.RATE
    GOSUB REVERSE.ORDER

    START.GROUP = MG.BAL.ACCR.FROM.DATE
    END.GROUP = MG.BAL.ACCR.ACT.AMT
    GOSUB REVERSE.ORDER

    START.GROUP = MG.BAL.PAYMENT.DATE
    END.GROUP = MG.BAL.ADD.PAY.5.RCVD
    GOSUB REVERSE.ORDER

    START.GROUP = MG.BAL.DEF.IN.EFF.DATE          ;* CI_10012981 S
    END.GROUP = MG.BAL.DEF.TAX.AMT
    GOSUB REVERSE.ORDER       ;* CI_10012981 E

    MAT R.WORK.BALANCES = MAT TEMP.REC
    RETURN


REVERSE.ORDER:
*=============

    NO.OF.MVS = COUNT(R.WORK.BALANCES(START.GROUP), VM) + (R.WORK.BALANCES(START.GROUP) NE "")
    FOR XX = START.GROUP TO END.GROUP
        TEMP.REC(XX) = ""
        FOR YY = 1 TO NO.OF.MVS
            INS R.WORK.BALANCES(XX)<1,YY> BEFORE TEMP.REC(XX)<1,1>
        NEXT YY
    NEXT XX

    RETURN


******
END
