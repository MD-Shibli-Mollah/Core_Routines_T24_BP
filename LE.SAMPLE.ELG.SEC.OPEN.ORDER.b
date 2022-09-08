* @ValidationCode : MjotMTk2NDE2MjEwMDpDcDEyNTI6MTUzODA0MzI3MzI0MDp2cmFqYWxha3NobWk6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgwNy4yMDE4MDYyMS0wMjIxOjE1OjE1
* @ValidationInfo : Timestamp         : 27 Sep 2018 15:44:33
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vrajalakshmi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 15/15 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LE.Framework
SUBROUTINE LE.SAMPLE.ELG.SEC.OPEN.ORDER(ApplnId, ApplnRec, eligibility, errorMsg, reservedOne)
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
    $USING SC.SctOrderCapture
    $USING EB.SystemTables
    $USING EB.LocalReferences

    GOSUB initialise
    GOSUB determineEligibility
    
RETURN

initialise:
**********************************
    LocalRef = ''
    TapIdPos = ''
    TapFieldValue = ''
    eligibility = "YES"
    
RETURN

determineEligibility:
**********************************
    EB.LocalReferences.GetLocRef(ApplnId, "TAP.REF.ID", TapIdPos) ;*fetch tap ref id value
    LocalRef = ApplnRec<SC.SctOrderCapture.SecOpenOrder.ScSooLocalRef>
    TapFieldValue = LocalRef<1,TapIdPos>
    
    IF TapFieldValue NE '' THEN
        eligibility = "NO" ;*If TAP.REF.ID field is updated you can skip the check
    END
    
RETURN

END
