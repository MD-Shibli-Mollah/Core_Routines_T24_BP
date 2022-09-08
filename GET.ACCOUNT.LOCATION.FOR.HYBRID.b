* @ValidationCode : MjotMTA5OTE5MjMzODpDcDEyNTI6MTYxMjM1NTc1MDU2MTpwcnRoYXJ1bjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTEuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 03 Feb 2021 18:05:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : prtharun
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PP.AccountandCustomerInterfaceService
SUBROUTINE GET.ACCOUNT.LOCATION.FOR.HYBRID(iInputHook,oAccValDetails,oHookError)
*-----------------------------------------------------------------------------
* This routine is configured in PP.COMPANY.PROPERTIES as Acc Validation Hook API
* This API routine will return the accountDDASystem values for the configured accounts
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 11/12/2020 - Task 3788565 - New API routine for external system as Hybrid
*-----------------------------------------------------------------------------

    GOSUB initialise
    GOSUB process

RETURN
*-----------------------------------------------------------------------------
initialise:
    
    oAccValDetails<PP.AccountandCustomerInterfaceService.OutAccountValDetails.accountValSystem> = 'External'
    oAccValDetails<PP.AccountandCustomerInterfaceService.OutAccountValDetails.accountDDASystem> = 'External'
        
RETURN
*-----------------------------------------------------------------------------
process:
    IF iInputHook<PP.AccountandCustomerInterfaceService.InputHook.accountNumber> MATCHES "3002904792":@VM:"3002904791":@VM:"3002905061":@VM:"3002905062":@VM:"3002904781":@VM:"3002904771":@VM:"03002905031":@VM:"EUR144230009":@VM:"3002905011":@VM:"3002905072":@VM:"3002905031" THEN
        oAccValDetails<PP.AccountandCustomerInterfaceService.OutAccountValDetails.accountValSystem> = 'T24'
        oAccValDetails<PP.AccountandCustomerInterfaceService.OutAccountValDetails.accountDDASystem> = ''
    END
   
    
RETURN
*-----------------------------------------------------------------------------
END
