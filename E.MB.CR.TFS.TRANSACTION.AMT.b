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
* <Rating>-38</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE E.MB.CR.TFS.TRANSACTION.AMT(TRANSACTION.ID)
*-----------------------------------------------------------------------------
*<doc>
    !** Simple
* @author karthickm@temenos.com
* @stereotype routine
* @package CR
*!
*</doc>
*-----------------------------------------------------------------------------
* Attached to the EB Context Record TELLER.FINANCIAL.SERVICES*RT.
* It is used to find the total net balance of the account after completion of txn.
* It is used in the rule engine
*-----------------------------------------------------------------------------
* Modification History :
*
* 06/08/12 - EN 393557 - Task 454207
*            ARC-CRM Real-time opportunity generation
*
* ----------------------------------------------------------------------------
* <region name= Inserts>

    $USING TT.TellerFinancialService

* * </region>
*-----------------------------------------------------------------------------
*** <region name= Main section>
    GOSUB INITIALISE
    GOSUB PROCESS   ;* Main section
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc> Initialisation of variables </desc>
INITIALISE:
    Y.TRANSACTION.ID = TRANSACTION.ID
    R.TFS = TT.TellerFinancialService.TellerFinancialServices.Read(Y.TRANSACTION.ID, ERR.TFS)
    ACC.ID = R.TFS<TT.TellerFinancialService.TellerFinancialServices.TfsPrimaryAccount>
    RT.ACC.NO = R.TFS<TT.TellerFinancialService.TellerFinancialServices.TfsRtAccountNo>
    RUNNING.TOTAL = R.TFS<TT.TellerFinancialService.TellerFinancialServices.TfsRunningTotal>
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> Calculate account balance </desc>
PROCESS:
    RT.ACC.NO = CONVERT(@VM,@FM,RT.ACC.NO)
    RUNNING.TOTAL = CONVERT(@VM,@FM,RUNNING.TOTAL)
    LOCATE ACC.ID IN RT.ACC.NO SETTING ACC.POS THEN
    TRANSACTION.ID = RUNNING.TOTAL<ACC.POS> ;* set account balance after txn to return variable
    END
    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
