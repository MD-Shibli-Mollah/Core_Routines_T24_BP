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
* <Rating>-11</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE V.CR.PRODUCT.DEFAULT
*-----------------------------------------------------------------------------
*<doc>
* V.CR.PRODUCT.DEFAULT validation routine is a validation routine. This will default
* PRODUCT from CR.OPPORTUNITY.DEFINITION file to PW.AF.DEPOSIT.
* @author karthickm@temenos.com
* @stereotype application
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 04/06/12 - EN 393557 - Task 401305
*            ARC-CRM Real-time opportunity generation
*            New validation routine
*
* ----------------------------------------------------------------------------
* <region name= Inserts>

    $USING PW.ModelBank
    $USING CR.Operational
    $USING EB.SystemTables

* </region>
*-----------------------------------------------------------------------------
* Do processing
    IF EB.SystemTables.getRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoCrOpporDefn) THEN
        Y.CR.OPPOR.ID =  EB.SystemTables.getRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoCrOpporDefn)
        R.CR.OPPOR.DEF = CR.Operational.OpportunityDefinition.Read(Y.CR.OPPOR.ID, YERR)
        * Default value from product field of F.CR.OPPORTUNITY.DEFINITION
        EB.SystemTables.setRNew(PW.ModelBank.PwAfDeposit.PwAfZerTwoAaProduct, R.CR.OPPOR.DEF<CR.Operational.OpportunityDefinition.OdProduct>)
    END
    RETURN
