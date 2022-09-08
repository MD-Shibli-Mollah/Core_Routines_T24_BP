* @ValidationCode : Mjo5MjkxMzg3MTc6Q3AxMjUyOjE1OTczMjAyOTU3MzA6bXIuc3VyeWFpbmFtZGFyOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNToyODoyOA==
* @ValidationInfo : Timestamp         : 13 Aug 2020 17:34:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mr.suryainamdar
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 28/28 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPTNCL.Foundation
SUBROUTINE PPTNCL.PAY.ORDER.CHANNEL.VAL(PO.ID, R.PAYMENT.ORDER, COMP.ID, RESERVED.IN, SUXS.FAIL, ERR.DETS, RESERVED.OUT)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*13/08/2020 - Enhancement 3538767/Task 3808258-Payments-BHTunsian-Clearing specific API
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
    $USING PI.Contract
*--------------------------------------------------------------------------------------------------------------------------------------
    GOSUB INITIALISE ; *
    GOSUB PROCESS ; *

RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>  </desc>
    ERR.DETS = ''
    iNCC =''
    BenClearingcode=''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
* Get details from context fields.
    contextName = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoContextName>
    contextValue = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoContextValue>
    LOCATE 'OrginatorAcctType' IN contextName<1,1> SETTING POS THEN
        OrginatorAcctTypeVal = contextValue<1,POS>
        IF (OrginatorAcctTypeVal NE '1' AND OrginatorAcctTypeVal NE '2' AND OrginatorAcctTypeVal NE '3' ) THEN
            ERR.DETS<-1> = 'PI-ORGINATOR.ACCT.TYPE.INVALID':@VM:PI.Contract.PaymentOrder.PoContextValue:@VM:POS
        END
    END
    LOCATE 'OrginatorAcctNature' IN contextName<1,1> SETTING POS THEN
        OrginatorAcctNatureVal = contextValue<1,POS>
        IF ( OrginatorAcctNatureVal NE '0' AND OrginatorAcctNatureVal NE '1' ) THEN
            ERR.DETS<-1> = 'PI-ORGINATOR.ACCT.NATURE.INVALID':@VM:PI.Contract.PaymentOrder.PoContextValue:@VM:POS
        END
    END
    iNCC = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoAcctWithBankClearingCode>
    RIBAccount = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryAccountNo>
    BenClearingcode =RIBAccount[1,2]
    
    IF iNCC NE BenClearingcode THEN
        ERR.DETS<-1> = 'PI-ACCNT.WITH.CLEARING.CODE.INVALID':@VM:PI.Contract.PaymentOrder.PoAcctWithBankClearingCode
    END
    
RETURN
*-----------------------------------------------------------------------------
END
