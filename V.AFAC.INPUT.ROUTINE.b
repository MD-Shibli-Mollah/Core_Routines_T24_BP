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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE V.AFAC.INPUT.ROUTINE

    $USING CR.Operational
    $USING PW.Foundation
    $USING CR.ModelBank
    $USING EB.Browser
    $USING EB.DataAccess
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN


INITIALISE:
	PW.Foundation.setFnPwProcess('F.PW.PROCESS')
    FV.PW.PROCESS = ''
    tmp.FN.PW.PROCESS = PW.Foundation.getFnPwProcess()
    EB.DataAccess.Opf(tmp.FN.PW.PROCESS,FV.PW.PROCESS)
    PW.Foundation.setFnPwProcess(tmp.FN.PW.PROCESS)
    	
    FV.CR.OPPORTUNITY = ''

    FV.CR.OPPORTUNITY.DEFINITION = ''

    YR.PW.ACTIVITY.TXN.ID = PW.Foundation.getActivityTxnId()
    YR.CUSTOMER.NO = EB.SystemTables.getRNew(CR.ModelBank.AfAccount.Af01Customer)

    EB.Browser.SystemGetuservariables(YR.VARIABLE.NAMES,YR.VARIABLE.VALUES)
    LOCATE 'CURRENT.CR.OPPOR.ID' IN YR.VARIABLE.NAMES SETTING YR.POS.1 THEN
    YR.CR.OPPOR.ID = YR.VARIABLE.VALUES<YR.POS.1>
    END

    RETURN


PROCESS:

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

    YR.CR.OPPORTUNITY.REC = CR.Operational.Opportunity.Read(YR.CR.OPPOR.ID, YR.ERR3)
    IF NOT(YR.ERR3) THEN
        YR.CR.OPPOR.DEF.ID = YR.CR.OPPORTUNITY.REC<CR.Operational.Opportunity.OpOpporDefId>
        YR.CR.SOURCE.ID = YR.CR.OPPORTUNITY.REC<CR.Operational.Opportunity.OpEventSourceId>
        YR.CR.CUSTOMER = YR.CR.OPPORTUNITY.REC<CR.Operational.Opportunity.OpCustomer>
        IF YR.CR.CUSTOMER = YR.CUSTOMER.NO AND YR.CR.OPPOR.DEF.ID = YR.PW.PROCESS.PROCESS.DEFINITION THEN
            YR.CR.OPPORTUNITY.DEFINITION.REC = CR.Operational.OpportunityDefinition.Read(YR.CR.OPPOR.DEF.ID, YR.ERR4)
            IF NOT(YR.ERR4) THEN
                YR.CR.OPPOR.DESC = YR.CR.OPPORTUNITY.DEFINITION.REC<CR.Operational.OpportunityDefinition.OdDescription>
                EB.SystemTables.setRNew(CR.ModelBank.AfAccount.Af01CrOpporId, YR.CR.OPPOR.ID)
                EB.SystemTables.setRNew(CR.ModelBank.AfAccount.Af01CrOpporDesc, YR.CR.OPPOR.DESC)
                EB.SystemTables.setRNew(CR.ModelBank.AfAccount.Af01CrSourceId, YR.CR.SOURCE.ID)
            END
        END
    END

    RETURN

    END
