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
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.InterestAndCapitalisation
    SUBROUTINE CONV.COMB.ACCTDT.UPD.R7(ID.ACCOUNT, R.ACCOUNT, FN.ACCOUNT)
*----------------------------------------------------------------------------
* Wrapper routine for conversion of ACCOUNT in R7.
*
* Modification History:
*
* 29/02/08 - BG_100017390
*            Wrapper rtn for conversion to avoid repeated select on files
*            during conversion.
*-----------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.ACCOUNT.PARAMETER
    $INSERT I_F.STMT.ENTRY


* Call conversion rtn to change record keys etc here

    CALL CONV.ACCOUNT.R7.200609(ID.ACCOUNT, R.ACCOUNT, FN.ACCOUNT)

* Call the rtn to update interest dates here

    CALL CONV.ACCOUNT.DATE.UPD(ID.ACCOUNT, R.ACCOUNT, FN.ACCOUNT)

    RETURN

END
