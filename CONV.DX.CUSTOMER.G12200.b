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
    $PACKAGE DX.Customer
SUBROUTINE CONV.DX.CUSTOMER.G12200(DX.CUSTOMER.ID,R.DX.CUSTOMER,F.DX.CUSTOMER)

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DX.CUSTOMER

* Clears the customer automatic closeout fields.

R.DX.CUSTOMER<DX.CU.AU.CT.CLASS> = ""
R.DX.CUSTOMER<DX.CU.AU.SETT.TYPE> = ""
R.DX.CUSTOMER<DX.CU.AU.SETT.DELAY> = ""

RETURN
END
