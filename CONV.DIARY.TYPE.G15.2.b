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
* <Rating>100</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccEventCapture
    SUBROUTINE CONV.DIARY.TYPE.G15.2(DIARY.TYPE.ID,R.DIARY.TYPE,F.DIARY.TYPE)

    $INSERT I_F.DIARY.TYPE

* If CASH.REMAIN field is set to Y, remaining cash after reinvestment gets credited to customer.
* In this release, new parameter called CUST.OR.BANK is introduced. If CUST.OR.BANK is customer,
* amount gets credited to customer. If it is BANK, bank's gets credited.

* So, new field CUST.OR.BANK is assigned to CUSTOMER to retain existing functionality.

    IF R.DIARY.TYPE<24> EQ 'Y' THEN R.DIARY.TYPE<87> = 'CUSTOMER'

    RETURN

END
