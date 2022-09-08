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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SE.TestFramework
    SUBROUTINE FT.STEST.INAO.OVERRIDE


*The routine will be attached in the Input routine field of version FUNDS.TRANSFER,.
*The purpose of this routine is to trigger the override FT-STEST.ACCT.NAO.OVERDRAFT.
*The override will be defined in override.class of a particular user
*and hence the funds transfer will be moved to INAO when authorised by any other user.

*----------------------------------------------------------------------------

*** </region>*** <region name= Modification History>
*** <desc>Modification History </desc>

* 09/02/15 - Defect 1233358 / Task 1249292
*            Routine to trigger override when inputted through the version FUNDS.TRANSFER,
*
*** </region>

*-----------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE

    TEXT="FT-STEST.ACCT.NAO.OVERDRAFT"
    CALL STORE.OVERRIDE(CURR.NO)

    RETURN
