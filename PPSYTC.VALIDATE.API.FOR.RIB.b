* @ValidationCode : MjotMzk4MjcyMDkxOkNwMTI1MjoxNTg3MTE0Njc3NTQ0OnNhcm1lbmFzOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDIuMjAyMDAxMTctMjAyNjoyMDoxNQ==
* @ValidationInfo : Timestamp         : 17 Apr 2020 14:41:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sarmenas
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 15/20 (75.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*------------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYTC.VALIDATE.API.FOR.RIB(PO.ID,R.PAYMENT.ORDER,COMP.ID,RESERVED.IN,SUXS.FAIL,ERR.DETS,RESERVED.OUT)
*-----------------------------------------------------------------------------
* Modification History :
*2/3/2020 - Enhancement 3131018/ Task 3130941 - Routine which will be triggered when Reachability check field in PAYMENT.ORDER.PRODUCT is set to 'BIC' value
*24/03/2020 - Enhancement 3540611/Task 3638768- Payments-Afriland - SYSTAC (CEMAC) - Direct Debits
* ----------------------------------------------------------------------------
* <region name= Inserts>
* </region>
*-----------------------------------------------------------------------------
    $USING PI.Contract
        
    GOSUB INITIALISE
    GOSUB PROCESS
    
RETURN
  
*-----------------------------------------------------------------------------
INITIALISE:
*   initialise the variables here
    BEN.ACCT.RIB = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryAccountNo>
    beneficiaryBIC = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryBic>
    validationResult = ''

RETURN
*-----------------------------------------------------------------------------
PROCESS:
    
    IF BEN.ACCT.RIB EQ "" THEN
        ERR.DETS = 'PPSYTC-BEN.ACCT.RIB.MISSING':@VM:PI.Contract.PaymentOrder.PoBeneficiaryAccountNo
        RETURN
    END
    
    PPSYTC.ClearingFramework.ppsystcRibValidation(BEN.ACCT.RIB,validationResult)
                
    IF validationResult EQ '2' THEN
        ERR.DETS = 'PPSYTC-RIB.INVALID':@VM:PI.Contract.PaymentOrder.PoBeneficiaryAccountNo
    END ELSE IF validationResult EQ '3' THEN
        ERR.DETS = 'PPSYTC-BEN.ACCT.RIB.LENGTH.INVALID':@VM:PI.Contract.PaymentOrder.PoBeneficiaryAccountNo
    END ELSE IF validationResult EQ '4' THEN
        ERR.DETS = 'PPSYTC-BANKCODE.INVALID':@VM:PI.Contract.PaymentOrder.PoBeneficiaryAccountNo
    END
RETURN
*-----------------------------------------------------------------------------
END
   
