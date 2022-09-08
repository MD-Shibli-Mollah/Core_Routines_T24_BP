* @ValidationCode : MjotMjExNDc5MjM4MjpDcDEyNTI6MTUzODAzOTY4MjE1Mjp2cmFqYWxha3NobWk6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgwNy4yMDE4MDYyMS0wMjIxOjk6OQ==
* @ValidationInfo : Timestamp         : 27 Sep 2018 14:44:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vrajalakshmi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 9/9 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LE.Framework
SUBROUTINE LE.SAMPLE.ELG.SWAP(ApplnId, ApplnRec, eligibility, errorMsg, reservedOne)
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

*-----------------------------------------------------------------------------
    $USING SW.Contract
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
    IF ApplnRec<SW.Contract.Swap.SwapType> = "IRS" OR ApplnRec<SW.Contract.Swap.SwapType> = "CIRS" THEN
        eligibility = "YES" ;*if swap type is IRS OR CIRS
    END
   
RETURN

END
