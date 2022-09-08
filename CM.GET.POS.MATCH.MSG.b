* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-45</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CM.Contract
    SUBROUTINE CM.GET.POS.MATCH.MSG(CM.MESSAGE.ID, POSSIBLE.MATCH.LIST)
*
******************************************************************************
*
* Routine to get possible matches for the given message key.
*
* IN = CM.MESSAGE.ID        - There exists an entry in CM.MESSAGE.
* OUT = POSSIBLE.MATCH.LIST - List of possible message keys separated by @FM
*                             for the given message key.
*
******************************************************************************
* Modification History:
*
* 11/12/09 - EN_10004452
*            SAR Ref: 2009-09-22-0002
*            Local routine to get possible matches for the given message key.
*            This will not be called within the CM module. It can be called
*            locally to get possible matches for the given message key.
*
******************************************************************************

    $USING CM.Contract
    $USING EB.DataAccess
    $INSERT I_DAS.CM.PAR.UNMATCHED.ITEM
    $INSERT I_DAS.CM.PAR.UNMATCHED.ITEM.NOTES

*
    GOSUB INITIALISE
    GOSUB GET.CM.PAR.UNMATCH
    GOSUB EXTRACT.MSG.KEY
*
    RETURN
*
******************************************************************************
INITIALISE:
******************************************************************************
*
    ER = ''
    R.CM.MATCH.ITEM = ''
    R.CM.MATCH.ITEM = CM.Contract.MatchItem.Read(CM.MESSAGE.ID, ER)
    PARTIAL.MATCH.KEY = R.CM.MATCH.ITEM<CM.Contract.MatchItem.MatPartMatchKey>
*
    POSSIBLE.MATCH.LIST = ''
*
    RETURN
*
******************************************************************************
GET.CM.PAR.UNMATCH:
******************************************************************************
*
    EB.DataAccess.setDasmode(EB.DataAccess.dasReturnResults);* This will return the selected ids.

    ID.LIST = dasCmParUnmatchedItemLikeMatchKey   ;* Selection label and its criteria.
    THE.ARGS = PARTIAL.MATCH.KEY
    TABLE.SUFFIX = ''

    EB.DataAccess.Das('CM.PAR.UNMATCHED.ITEM', ID.LIST, THE.ARGS, TABLE.SUFFIX)

    PAR.MATCH.ITEM.LIST = ID.LIST       ;* Contains the list of IDs which contains the same partial key.
*
    RETURN
*
******************************************************************************
EXTRACT.MSG.KEY:
******************************************************************************
*
    LOOP
        REMOVE POS.MATCH.ID FROM PAR.MATCH.ITEM.LIST SETTING POS
    WHILE POS.MATCH.ID:POS
        POS.MATCH.ID = FIELD(POS.MATCH.ID,'||',1)
        IF POS.MATCH.ID NE CM.MESSAGE.ID THEN     ;* Own message key cannot be a possible match for itself.
            POSSIBLE.MATCH.LIST<-1> = POS.MATCH.ID
        END
    REPEAT
*
    RETURN
    END
