* @ValidationCode : MjotOTU0NzExMDc2OkNwMTI1MjoxNTMwMTg1MDgzNTAwOm1taXRoaWxhOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODA2LjIwMTgwNTE5LTAwNTg6Mjoy
* @ValidationInfo : Timestamp         : 28 Jun 2018 16:54:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mmithila
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 2/2 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201806.20180519-0058
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PP.FeeDeterminationService
SUBROUTINE TPH.TXN.ZEROFEE.API(iAPIInputParameter,oChargeAmount)
*----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History : Enhancement 1887025/Task 2651098
*                        To define a FEE API which will return 0
*                        as Charges if defined in the PP.FEETYPE table
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Charge Amount will be 0

*    txnAmount = iAPIInputParameter<APIInputParameter.transactionAmt>
    oChargeAmount = ''
    oChargeAmount = 0
    
END
