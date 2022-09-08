* @ValidationCode : MjotMzk2MjY5MTQ2OkNwMTI1MjoxNTc4NTY0NDE5MDgwOm1oaW5kdW1hdGh5OjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDEuMjAxOTEyMjQtMTkzNTo1NDo1NA==
* @ValidationInfo : Timestamp         : 09 Jan 2020 15:36:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mhindumathy
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 54/54 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PW.ModelBank
SUBROUTINE E.MB.PW.VIEW.ACTIVITY.PROGRESS(YrDetails)
*-----------------------------------------------------------------------------
*
* Type: Nofile routine
* Attached to the enquiry PW.VIEW.ACTIVITY.PROGRESS
*
* Out Argument: YrDetails, returns that activity status, description and transaction details
*               of each activity in the current process.
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 17/12/2019 - Enhancement 3396943 / Task 3483737
*              Integration of BSG created screen to L1 PW
*
*-----------------------------------------------------------------------------
    $USING EB.API
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Reports
    $USING EB.Browser
    $USING PW.Foundation

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------

INITIALISE:

    fnPwProcess = 'F.PW.PROCESS'
    fvPwProcess = ''
    EB.DataAccess.Opf(fnPwProcess,fvPwProcess)

    fnPwProcessDefinitionCatalogue = 'F.PW.PROCESS.DEFINITION.CATALOGUE'
    fvPwProcessDefinitionCatalogue = ''
    EB.DataAccess.Opf(fnPwProcessDefinitionCatalogue,fvPwProcessDefinitionCatalogue)

    fnPwActivityTxn = 'F.PW.ACTIVITY.TXN'
    fvPwActivityTxn = ''
    EB.DataAccess.Opf(fnPwActivityTxn,fvPwActivityTxn)

    fnPwActivityCatalogue = 'F.PW.ACTIVITY.CATALOGUE'
    fvPwActivityCatalogue = ''
    EB.DataAccess.Opf(fnPwActivityCatalogue,fvPwActivityCatalogue)

    YrDetails = ''
    
    EB.Browser.SystemGetuservariables(yrVariableNames,yrVariableValues)

    LOCATE 'CURRENT.PROCESS' IN yrVariableNames SETTING yrPos THEN
        yrPwProcessId = yrVariableValues<yrPos>
    END

RETURN

*-----------------------------------------------------------------------------

PROCESS:
    yrPwProcessRec = PW.Foundation.Process.CacheRead(yrPwProcessId, yrProcErr)
    IF NOT(yrProcErr) THEN
        yrPwProcessDefinitionCatalogId = yrPwProcessRec<PW.Foundation.Process.ProcProcessDefinition>:"_V":yrPwProcessRec<PW.Foundation.Process.ProcVersion>
        yrPwProcessDefinitionCatalogRec = PW.Foundation.ProcessDefinitionCatalogue.CacheRead(yrPwProcessDefinitionCatalogId, yrDefErr)
        IF NOT(yrDefErr) THEN
            yrPwProcessDefinitionList = CHANGE(yrPwProcessDefinitionCatalogRec<PW.Foundation.ProcessDefinitionCatalogue.DefCatalogueActivity>,@VM,@FM)
            yrPwProcessActivity = yrPwProcessRec<PW.Foundation.Process.ProcActivity>
            GOSUB RETURN.DATA
        END
    END

RETURN

*-----------------------------------------------------------------------------

RETURN.DATA:

    LOOP
        REMOVE yrPwActivityCatalogueId FROM yrPwProcessDefinitionList SETTING actPos
    WHILE yrPwActivityCatalogueId:actPos
        yrActivityCatalogueRec = PW.Foundation.ActivityCatalogue.CacheRead(yrPwActivityCatalogueId, yrActErr)
        IF NOT(yrActErr) THEN
            yrPwActivityDescription = yrActivityCatalogueRec<PW.Foundation.ActivityCatalogue.ActCatalogueDescription>
        END
        LOCATE yrPwActivityCatalogueId IN yrPwProcessActivity<1,1> SETTING procPos THEN
            IF yrPwProcessRec<PW.Foundation.Process.ProcCompleted,procPos> EQ 'Y' THEN
                yrPwStatus = 'COMPLETE'
            END ELSE
                yrPwStatus = 'PENDING'
            END
            yrPwActivityTxnId = yrPwProcessRec<PW.Foundation.Process.ProcActivityTxn,procPos>
        END ELSE
            yrPwStatus = ''
            yrPwActivityDescription = ''
            yrPwActivityTxnId = ''
        END
        YrDetails<-1> = yrPwStatus:'*':yrPwActivityDescription:'*':yrPwActivityTxnId
    REPEAT

RETURN
*-----------------------------------------------------------------------------

END
