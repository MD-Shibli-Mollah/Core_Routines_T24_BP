* @ValidationCode : MjoxMjExMDAwMDY4OkNwMTI1MjoxNDkxMzAxNjk4NjUyOmFiY2l2YW51amE6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMDoxNToxNA==
* @ValidationInfo : Timestamp         : 04 Apr 2017 15:58:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : abcivanuja
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 14/15 (93.3%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*------------------------------------------------------------------------------
    $PACKAGE FT.ClearingService
*------------------------------------------------------------------------------
    SUBROUTINE T24ClearingServiceImpl.emitAcInwardEntry(iAcInwardEntry, responseDetails)
*-----------------------------------------------------------------------------
*-------------------------------------------------------------------------------
** Generated Service Adaptor
* @author abcivanuja@temenos.com
* @stereotype subroutine
* @package FT.ClearingService
*!
* In/out parameters:
* iAcInwardEntry - AcInwardEntry (List), IN
* oError - Error if any (List), OUT
* responseDetails - ResponseDetails, OUT
*
*------------------------------------------------------------------------------
    $INSERT I_responseDetails
    $INSERT I_ClearingService_AcInwardEntry

*------------------------------------------------------------------------------
    IF iAcInwardEntry = '' THEN  ;* return when no record is passed
        RETURN
    END
    GOSUB initialise
    GOSUB finalise

    RETURN
*-----------------------------------------------------------------------------
initialise:
*
;* initialise variables
    CALL SetServiceCommon
    response = ''
    responseDetails = ''
    responseDetails.serviceName = "T24ClearingServiceImpl.emitAcInwardEntry"
*
    RETURN

*------------------------------------------------------------------------------
finalise:
;* event emission
    CALL SetServiceResponse(responseDetails)  ;* call service response to emit event
*
    RETURN

*------------------------------------------------------------------------------

    END
