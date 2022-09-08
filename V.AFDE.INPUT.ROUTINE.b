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
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AD.ModelBank
    SUBROUTINE V.AFDE.INPUT.ROUTINE

    $USING CR.Operational
    $USING PW.Foundation
    $USING PW.ModelBank
    $USING EB.Browser
    $USING SL.Foundation
    $USING EB.API
    $USING EB.SystemTables


    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN


INITIALISE:

    FV.PW.PROCESS = ''

    FV.CR.OPPORTUNITY = ''

    FV.CR.OPPORTUNITY.DEFINITION = ''

    YR.PW.ACTIVITY.TXN.ID = PW.Foundation.getActivityTxnId()
    YR.CUSTOMER.NO = EB.SystemTables.getRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoCustomer)

    YR.PW.AF.DEPOSIT.TERM.1 = EB.SystemTables.getRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoTermOne)
    YR.PW.AF.DEPOSIT.TERM.2 = EB.SystemTables.getRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoTermTwo)
    YR.PW.AF.DEPOSIT.START.DATE = EB.SystemTables.getRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoStartDate)

    YR.COMI.SAVE = EB.SystemTables.getComi()

    EB.Browser.SystemGetuservariables(YR.VARIABLE.NAMES,YR.VARIABLE.VALUES)
    LOCATE 'CURRENT.CR.OPPOR.ID' IN YR.VARIABLE.NAMES SETTING YR.POS.1 THEN
    YR.CR.OPPOR.ID = YR.VARIABLE.VALUES<YR.POS.1>
    END

    RETURN


PROCESS:

    GOSUB PROCESS.CUSTOMER
    GOSUB PROCESS.MATURITY
    GOSUB PROCESS.OPPORTUNITY


    RETURN


PROCESS.CUSTOMER:

    tmp.FN.PW.ACTIVITY.TXN = PW.Foundation.getFnPwActivityTxn()
    YR.PW.ACTIVITY.TXN.REC = PW.Foundation.ActivityTxn.Read(YR.PW.ACTIVITY.TXN.ID, YR.ERR1)
    PW.Foundation.setFnPwActivityTxn(tmp.FN.PW.ACTIVITY.TXN)
    IF NOT(YR.ERR1) THEN
        YR.PW.ACTIVITY.TXN.PROCESS = YR.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnProcess>
        YR.PW.PROCESS.REC = PW.Foundation.Process.Read(YR.PW.ACTIVITY.TXN.PROCESS, YR.ERR2)
        IF NOT(YR.ERR2) THEN
            YR.PW.PROCESS.PROCESS.DEFINITION = YR.PW.PROCESS.REC<PW.Foundation.Process.ProcProcessDefinition>
            YR.PW.PROCESS.REC<PW.Foundation.Process.ProcCustomer> = YR.CUSTOMER.NO
            PW.Foundation.ProcessWrite(YR.PW.ACTIVITY.TXN.PROCESS, YR.PW.PROCESS.REC,'')
        END
    END

    RETURN


PROCESS.MATURITY:

    IF YR.PW.AF.DEPOSIT.TERM.1 THEN
        YR.PW.AF.DEPOSIT.TERM = FIELD(YR.PW.AF.DEPOSIT.TERM.1,' ',1)
    END ELSE
        IF YR.PW.AF.DEPOSIT.TERM.2 THEN
            YR.PW.AF.DEPOSIT.TERM = FIELD(YR.PW.AF.DEPOSIT.TERM.2,' ',1)
        END
    END

    YR.PW.AF.DEPOSIT.START.DATE.YEAR = YR.PW.AF.DEPOSIT.START.DATE[1,4]
    YR.PW.AF.DEPOSIT.START.DATE.MONTH = YR.PW.AF.DEPOSIT.START.DATE[5,2]
    YR.PW.AF.DEPOSIT.START.DATE.DAY = YR.PW.AF.DEPOSIT.START.DATE[7,2]

    IF YR.PW.AF.DEPOSIT.TERM LE 12 THEN
        IF LEN(YR.PW.AF.DEPOSIT.TERM) = 1 THEN
            YR.PW.AF.DEPOSIT.TERM.VALUE = '0':YR.PW.AF.DEPOSIT.TERM
        END ELSE
            YR.PW.AF.DEPOSIT.TERM.VALUE = YR.PW.AF.DEPOSIT.TERM
        END
        YR.PW.AF.DEPOSIT.MATURITY.DATE = YR.PW.AF.DEPOSIT.START.DATE
        GOSUB PROCESS.MATURITY.SUB
    END ELSE
        IF YR.PW.AF.DEPOSIT.TERM GE 24 THEN
            YR.PW.AF.DEPOSIT.TERM.VALUE = 12
            YR.PW.AF.DEPOSIT.MATURITY.DATE = YR.PW.AF.DEPOSIT.START.DATE
            GOSUB PROCESS.MATURITY.SUB
            GOSUB PROCESS.MATURITY.SUB
            IF YR.PW.AF.DEPOSIT.TERM GE 36 THEN
                GOSUB PROCESS.MATURITY.SUB
                IF YR.PW.AF.DEPOSIT.TERM EQ 48 THEN
                    GOSUB PROCESS.MATURITY.SUB
                END
            END
        END
    END
    YR.COUNTRY.CODE = EB.SystemTables.getIdCompany()[1,2]
    SL.Foundation.CheckHoliday(YR.PW.AF.DEPOSIT.MATURITY.DATE,'FWD',YR.COUNTRY.CODE,'',YR.PW.AF.DEPOSIT.MATURITY.DATE)
    EB.SystemTables.setRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoMaturityDate, YR.PW.AF.DEPOSIT.MATURITY.DATE)
    EB.SystemTables.setRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoTerm, YR.PW.AF.DEPOSIT.TERM[1,2]:'M')

    EB.SystemTables.setComi(YR.COMI.SAVE)

    RETURN


PROCESS.MATURITY.SUB:

    YR.PW.AF.DEPOSIT.MATURITY.DATE = YR.PW.AF.DEPOSIT.MATURITY.DATE[1,8]:'M':YR.PW.AF.DEPOSIT.TERM.VALUE:YR.PW.AF.DEPOSIT.START.DATE.DAY
    EB.SystemTables.setComi(YR.PW.AF.DEPOSIT.MATURITY.DATE)
    EB.API.Cfq()
    YR.PW.AF.DEPOSIT.MATURITY.DATE = EB.SystemTables.getComi()

    RETURN


PROCESS.OPPORTUNITY:

    YR.CR.OPPORTUNITY.REC = CR.Operational.Opportunity.Read(YR.CR.OPPOR.ID, YR.ERR3)
    IF NOT(YR.ERR3) THEN
        YR.CR.OPPOR.DEF.ID = YR.CR.OPPORTUNITY.REC<CR.Operational.Opportunity.OpOpporDefId>
        YR.CR.SOURCE.ID = YR.CR.OPPORTUNITY.REC<CR.Operational.Opportunity.OpEventSourceId>
        YR.CR.CUSTOMER = YR.CR.OPPORTUNITY.REC<CR.Operational.Opportunity.OpCustomer>
        IF YR.CR.CUSTOMER = YR.CUSTOMER.NO AND YR.CR.OPPOR.DEF.ID = YR.PW.PROCESS.PROCESS.DEFINITION THEN
            YR.CR.OPPORTUNITY.DEFINITION.REC = CR.Operational.OpportunityDefinition.Read(YR.CR.OPPOR.DEF.ID, YR.ERR4)
            IF NOT(YR.ERR4) THEN
                YR.CR.OPPOR.DESC = YR.CR.OPPORTUNITY.DEFINITION.REC<CR.Operational.OpportunityDefinition.OdDescription>
                EB.SystemTables.setRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoCrOpporId, YR.CR.OPPOR.ID)
                EB.SystemTables.setRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoCrOpporDesc, YR.CR.OPPOR.DESC)
                EB.SystemTables.setRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoCrSourceId, YR.CR.SOURCE.ID)
            END
        END
    END

    RETURN

    END
