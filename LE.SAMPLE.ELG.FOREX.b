* @ValidationCode : MjotOTYxODEzMzM4OkNwMTI1MjoxNTQ0MDEyMzExMTQ1OnN2YW1zaWtyaXNobmE6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2OjE2OjE2
* @ValidationInfo : Timestamp         : 05 Dec 2018 17:48:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/16 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LE.Framework
SUBROUTINE LE.SAMPLE.ELG.FOREX(ApplnId, ApplnRec, eligibility, errorMsg, reservedOne)
*-----------------------------------------------------------------------------
* Incoming Arguments:
*-----------------------------------------------------------------------------
* ApplnId        - Holds the Application id
* ApplnRec       - Hold the Application record

*-----------------------------------------------------------------------------
* Outgoing Arguments:
*-----------------------------------------------------------------------------
* eligibility       - Holds the eligibility for the customer(YES/NO)
* errorMsg          - Holds the value of returned error
* reservedOne       - Reserved
*
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 05/12/2018 - Defect 2888196 / Task 2888706
*              LE Validations (OC.CUSTOMER validation) to be skipped for Internal FX deals
*-----------------------------------------------------------------------------
    $USING FX.Contract
    $USING EB.SystemTables

    GOSUB initialise
    GOSUB determineEligibility
    
RETURN

initialise:
**********************************
    eligibility = 'NO'
     
RETURN

determineEligibility:
**********************************
    BEGIN CASE
                       
        CASE ApplnRec<FX.Contract.Forex.DealSubType> EQ 'IN'
            eligibility = "NO" ;*Not eligible for internal deals
        
        CASE ApplnRec<FX.Contract.Forex.OptionCurrency> NE ''
            eligibility = "YES" ;*eligible if option currency is not defined
            
        CASE ApplnRec<FX.Contract.Forex.MetalType> NE '' OR (ApplnRec<FX.Contract.Forex.Allocation> EQ "ALLOC" OR ApplnRec<FX.Contract.Forex.Allocation> EQ "UNALL")
            eligibility = "YES" ;*metal type not defined or allocation is ALLOC or UNALL
            
        CASE ApplnRec<FX.Contract.Forex.DealType>[1,2] EQ "FW" OR  ApplnRec<FX.Contract.Forex.DealType>[1,2] EQ "SW"
            eligibility = "YES" ;*if deal type starts with FW or SW
            
    END CASE
    
RETURN

END
