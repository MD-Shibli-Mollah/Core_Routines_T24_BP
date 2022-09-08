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
* <Rating>-19</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE E.CR.CUST.DEFAULT
*-----------------------------------------------------------------------------------------------------------------
*** <region name= Modification History>

*  M O D I F I C A T I O N S
* ***************************
* 21/01/15 - Task 1200551
*            Ref : Enhancement 1200539
*            Client Contact Experience
*
*  To Default Mnemonic and Short Name from id
*  when creating prospect
*** </region>
*----------------------------------------------------------------

    $USING ST.Customer
    $USING EB.SystemTables


*-----------------------------------------------------------------------------

    GOSUB PROCESS

    RETURN

*----------------------------------------------------------------------------------------------------------------
PROCESS:
********

    EB.SystemTables.setRNew(ST.Customer.Customer.EbCusMnemonic, "C":EB.SystemTables.getIdNew())
    EB.SystemTables.setRNew(ST.Customer.Customer.EbCusShortName, "C":EB.SystemTables.getIdNew())
*     R.NEW(EB.CUS.NATIONALITY) = R.COMPANY(EB.COM.LOCAL.COUNTRY)
*     R.NEW(EB.CUS.RESIDENCE) = R.COMPANY(EB.COM.LOCAL.COUNTRY)

    RETURN

*----------------------------------------------------------------------------------------------------------------
    END
