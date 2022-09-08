* @ValidationCode : Mjo4ODkwODUzMjc6Q3AxMjUyOjE1MzAxODUxNzIzODI6bW1pdGhpbGE6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDYuMjAxODA1MTktMDA1ODo2OjY=
* @ValidationInfo : Timestamp         : 28 Jun 2018 16:56:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mmithila
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 6/6 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201806.20180519-0058
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PP.FeeDeterminationService
SUBROUTINE TPH.TXN.FEETYPE.API(iAPIInputParameter,oChargeAmount)
*----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History : Enhancement 1887025/Task 2651098
*                        To define a FEE API which will return 1% of the transaction amount
*                        as Charges if defined in the PP.FEETYPE table
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Charge Amount will be 1% of Transaction Amount
    txnAmount = ''
    CONVERT @VM TO @FM IN iAPIInputParameter
    
    txnAmount = iAPIInputParameter<4>
    oChargeAmount = ''
    oChargeAmount = txnAmount*(1/100)
    
    CONVERT @FM TO @VM IN iAPIInputParameter

END
