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
* <Rating>-15</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE V.TCIB.ONCHANGE.CUSTOMER.VAL
*---------------------------------------------------------------------------------------------------
* Attached to : Version control Channel Permission as a Validation routine to related customer field
* Incoming : N/A
* Outgoing : N/A
*-------------------------------------------------------------------------------
*DESCRIPTION    : To nullify the values on selection of the customer
*-------------------------------------------------------------------------------
* Modification History :
* 01/07/14 - Enhancement 1001222/Task 1001223
* TCIB : User management enhancements and externalisation
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*-------------------------------------------------------------------------------

    $USING EB.ARC
    $USING EB.SystemTables
*
*-----------------------------------------------------------------------------

    IF EB.SystemTables.getComi() NE EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerRelatedCustomer)<1,EB.SystemTables.getAv()> THEN           ;*to cross check the difference
        AvVar = EB.SystemTables.getAv()
        tmp=EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProductGroups); tmp<1,AvVar>=""; EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerProductGroups, tmp);*nullify the product groups
        tmp=EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProductGroupSel); tmp<1,AvVar>=""; EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerProductGroupSel, tmp);*nullify the product group selection
        tmp=EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerDisplayProducts); tmp<1,AvVar>=""; EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerDisplayProducts, tmp);*nullify the display products
        tmp=EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProduct); tmp<1,AvVar>=""; EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerProduct, tmp);*nullify the product
        tmp=EB.SystemTables.getRNew(EB.ARC.ChannelPermission.AiPerProductSel); tmp<1,AvVar>=""; EB.SystemTables.setRNew(EB.ARC.ChannelPermission.AiPerProductSel, tmp);*nullify the product selection
    END

    RETURN

    END
