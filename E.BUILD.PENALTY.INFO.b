* @ValidationCode : MjoxNTAxMzIyMTg6Q3AxMjUyOjE1ODM5MjY2NDg2ODE6cnZhcmFkaGFyYWphbjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Mar 2020 17:07:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
*  <Rating>588</Rating>
*-----------------------------------------------------------------------------
$PACKAGE IC.ModelBank
SUBROUTINE E.BUILD.PENALTY.INFO
*
*------------------------------------------------------------------------
*
* This routine will be used by the enquiry WITHDRAWAL.AVAILABLE.CHECK to
* build the field O.DATA which will be used to display the relevant
* enquiry fields.
*
*------------------------------------------------------------------------
*
* 30/04/97 - GB9700339
*            A new sub-routine to be used to build the information
*            required for the enquiry WITHDRAWAL.AVAILABLE.CHECK
*
* 04/07/97 - GB9700682
*            If the availability bucket is not found even in the first
*            position the position pointer is set to zero. This must be
*            actually set to 1 so as to point to the current availability
*
* 08/10/19 - Task 3375978
*            Removal ST references which has been moved to CQ
*
*
* 08/08/19 - Enhancement 3266291 / Task 3266271
*            Changing reference of routines that have been moved from ST to CG*------------------------------------------------------------------------
*

    $USING AC.AccountOpening
    $USING AC.BalanceUpdates
    $USING CG.ChargeConfig
    $USING EB.API
    $USING EB.SystemTables
    $USING EB.Reports
    $USING IC.ModelBank
    $USING AC.Config
*
*------------------------------------------------------------------------
*
    
    GOSUB INITIALISATION
    GOSUB FIND.AVAILABLE.AMT
    IF CHARGEABLE.AMT THEN             ; * Only if there is a chargeable amount do further processing
        GOSUB READ.ACCT.GROUP.CONDITION
        IF PENALTY.CODE THEN            ; * If penalty code not defined penalty charge not applicable
            GOSUB CALL.CALCULATE.CHARGE
        END
    END

RETURN

*
*------------------------------------------------------------------------
*
INITIALISATION:

** Extract the selection fields here
*
    LOCATE "ACCOUNT.NO" IN EB.Reports.getEnqSelection()<2,1> SETTING ACC.POSN ELSE NULL
    LOCATE "VALUE.DATE" IN EB.Reports.getEnqSelection()<2,1> SETTING VAL.POSN ELSE NULL
    LOCATE "TXN.AMT" IN EB.Reports.getEnqSelection()<2,1> SETTING AMT.POSN ELSE NULL
    LOCATE "TXN.CODE" IN EB.Reports.getEnqSelection()<2,1> SETTING CODE.POSN ELSE NULL

    ACCOUNT.NO = EB.Reports.getEnqSelection()<4,ACC.POSN>
    VALUE.DATE = EB.Reports.getEnqSelection()<4,VAL.POSN>
    TXN.AMT = EB.Reports.getEnqSelection()<4,AMT.POSN>
    TXN.CODE = EB.Reports.getEnqSelection()<4,CODE.POSN>

    IF VALUE.DATE = "" THEN
        VALUE.DATE = EB.SystemTables.getToday()
    END

*
* Determine the market for this particular account. If no market has been
* set up (See Initialisation) then FIND.CCY.MKT will use the marekt
* defined on the account record.
*
    APP.ID = 'AC' ; CALL.TYPE = 1 ; CCY.MKT = ''
    MVMT.ID = 'CHARGES' ; RETURN.CODE = '' ; ERROR.MESSAGE = ''
    DEFAULT.MKT = EB.Reports.getRRecord()<AC.AccountOpening.Account.CurrencyMarket>
    EB.API.FindCcyMkt(APP.ID,CALL.TYPE,MVMT.ID,CCY.MKT,DEFAULT.MKT,RETURN.CODE,ERROR.MESSAGE)
*
** Extract the fields required from the account record before
** initialising it to nulls
*
    CUSTOMER.ID = EB.Reports.getRRecord()<AC.AccountOpening.Account.Customer>
    ACC.CCY = EB.Reports.getRRecord()<AC.AccountOpening.Account.Currency>
    ACC.GROUP = EB.Reports.getRRecord()<AC.AccountOpening.Account.ConditionGroup>
*
** Initialise the record to nulls
*
    EB.Reports.setRRecord("")
    

RETURN
*
*------------------------------------------------------------------------
*
FIND.AVAILABLE.AMT:
*-----------------

    CHARGEABLE.AMT = ""
    READ.ERR = ""
    R.ACCT.AVAILABILITY = AC.BalanceUpdates.AcctAvailability.Read(ACCOUNT.NO, READ.ERR)

    IF NOT(READ.ERR) THEN
        LOCATE VALUE.DATE IN R.ACCT.AVAILABILITY<AC.BalanceUpdates.AcctAvailability.AvaValueDate> BY "DR" SETTING VAL.DATE.POS ELSE VAL.DATE.POS -=1
        IF NOT(VAL.DATE.POS) THEN
            VAL.DATE.POS = 1
        END
        IF R.ACCT.AVAILABILITY<AC.BalanceUpdates.AcctAvailability.AvaAvailableAmt,VAL.DATE.POS> THEN
            IF (R.ACCT.AVAILABILITY<AC.BalanceUpdates.AcctAvailability.AvaAvailableAmt,VAL.DATE.POS> > 0) AND (R.ACCT.AVAILABILITY<AC.BalanceUpdates.AcctAvailability.AvaAvailableAmt,VAL.DATE.POS> < TXN.AMT) THEN          ; * +ve available amount & less than the amount that needs to be withdrawn
                CHARGEABLE.AMT = TXN.AMT - R.ACCT.AVAILABILITY<AC.BalanceUpdates.AcctAvailability.AvaAvailableAmt,VAL.DATE.POS>
            END ELSE                     ; * If -ve available amount the whole withdrawal amount is chargeable
                IF R.ACCT.AVAILABILITY<AC.BalanceUpdates.AcctAvailability.AvaAvailableAmt,VAL.DATE.POS> < 0 THEN
                    CHARGEABLE.AMT = TXN.AMT
                END
            END
        END ELSE
            CHARGEABLE.AMT = TXN.AMT
        END
    END

RETURN
*
*------------------------------------------------------------------------
*
READ.ACCT.GROUP.CONDITION:
*------------------------

    READ.ERR = ""
    R.ACCT.GROUP.CONDITION = ""
    R.ACCT.GROUP.CONDITION = AC.Config.AcctGroupCondition.Read(ACC.GROUP:ACC.CCY, READ.ERR)

    PENALTY.CODE = ""
    IF NOT(READ.ERR) THEN
        LOCATE TXN.CODE IN R.ACCT.GROUP.CONDITION<AC.Config.AcctGroupCondition.AcctGrpWdlTxnCode,1> SETTING TXN.CODE.POSN ELSE
            LOCATE "DEFAULT" IN R.ACCT.GROUP.CONDITION<AC.Config.AcctGroupCondition.AcctGrpWdlTxnCode,1> SETTING TXN.CODE.POSN ELSE TXN.CODE.POSN = ""
        END
        IF TXN.CODE.POSN THEN
            PENALTY.CODE = R.ACCT.GROUP.CONDITION<AC.Config.AcctGroupCondition.AcctGrpPenaltyCode,TXN.CODE.POSN>
        END
    END
RETURN
*
*------------------------------------------------------------------------
*
CALL.CALCULATE.CHARGE:
*--------------------
*
** Calculate the penalty applicable
*
    PASS.DATA = PENALTY.CODE
    CG.ChargeConfig.CalculateCharge(CUSTOMER.ID,CHARGEABLE.AMT,ACC.CCY,CCY.MKT,'','','',PASS.DATA,'','','')

    IF PASS.DATA THEN
        FOR I = 1 TO 6
            tmp=EB.Reports.getRRecord(); tmp<I>=PASS.DATA<I>; EB.Reports.setRRecord(tmp)
        NEXT I
        EB.Reports.setVmCount(DCOUNT(EB.Reports.getRRecord()<1>,@VM))
        tmp=EB.Reports.getRRecord(); tmp<-1>=EB.SystemTables.getLccy(); EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<-1>=ACC.CCY; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<-1>=VALUE.DATE; EB.Reports.setRRecord(tmp)
    END

RETURN
END
