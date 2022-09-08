* @ValidationCode : MjotMTQ0MjYzNTU5OkNwMTI1MjoxNTM4MDM5NjgyMTM4OnZyYWphbGFrc2htaToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODA3LjIwMTgwNjIxLTAyMjE6OTo5
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
SUBROUTINE LE.SAMPLE.ELG.SEC.TRADE(ApplnId, ApplnRec, eligibility, errorMsg, reservedOne)
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
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING SC.SctTrading
    $USING EB.SystemTables

    GOSUB initialise
    GOSUB determineEligibility

RETURN

initialise:
**********************************     
    eligibility = 'NO'
    
RETURN
********************************** 
determineEligibility:
    
    IF ApplnRec<SC.SctTrading.SecTrade.SbsCuOrderNos> EQ '' THEN
        eligibility = "YES" ;*if the reference numbers which belong to the open orders belonging to the client which have generated the sec.trade is null
    END
    
RETURN
    
END
