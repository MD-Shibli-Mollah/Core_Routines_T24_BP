* @ValidationCode : MjotMTk3MTUwMDc2MjpDcDEyNTI6MTYwODA5NzY1MjM3MjptZWVuYWtzaGlwOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMS4yMDIwMTAyOS0xNzU0Oi0xOi0x
* @ValidationInfo : Timestamp         : 16 Dec 2020 11:17:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : meenakship
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PP.SwiftOutService
SUBROUTINE PP.SUPPRESS.OUT.SWIFT.MSG(iTransactionContext,oHookApiResponse) 
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
*15-Dec-2020: MT103 Outgoing suppression hookApi

    GOSUB Initialise ; *
    GOSUB Process ; *
    
RETURN

*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc> </desc>
    oHookApiResponse = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= Process>
Process:
*** <desc> </desc>
    oHookApiResponse = 'Y'
RETURN
*** </region>

END


