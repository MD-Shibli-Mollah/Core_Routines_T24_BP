* @ValidationCode : MjoxNzE4MDYxOTIyOmNwMTI1MjoxNTkwMDM2ODA2ODMyOmhhYXJpbmlyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNS4wOi0xOi0x
* @ValidationInfo : Timestamp         : 21 May 2020 10:23:26
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : haarinir
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202005.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CK.Consent
SUBROUTINE CK.AUTO.CONSENT.CREATION(customerId,allowConsentCreation,reserved1,reserved2)
*-----------------------------------------------------------------------------
*
* Sample Api that can be used to decide if auto create consent cannot be done or not
*
* IN - customerId
* OUT - allowConsentCreation ( YES/NO) 
*
* If Customer is GDPR eligible then this api returns "YES" otherwise "NO"
*-----------------------------------------------------------------------------
* Modification History :
*
* 15/5/2020 - Enchancement 3236166 / Task 3752798
*             Sample api that returns YES OR NO based on customer type
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING ST.Customer
    $USING CK.Consent

    allowConsentCreation = "NO"
    CustomerRec = ST.Customer.Customer.Read(customerId,CustErr)
  
    IF NOT(CustErr) AND CustomerRec<ST.Customer.Customer.EbCusResidence> EQ "EU" AND CustomerRec<ST.Customer.Customer.EbCusSector> EQ "1127" THEN ;*if customer type is active
        allowConsentCreation = "YES"
    END
    

RETURN
END
 
