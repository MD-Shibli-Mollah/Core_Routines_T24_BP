* @ValidationCode : MjotMzUwMzA4OTAwOkNwMTI1MjoxNjA0NDAwOTU2MjgzOnJhbmdhaGFyc2hpbmlyOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NTo0NTo0NQ==
* @ValidationInfo : Timestamp         : 03 Nov 2020 16:25:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rangaharshinir
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 45/45 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.DE.USER.SETTLE.FLAG(MAT HandRec,ErrMsg)
*-----------------------------------------------------------------------------
*This is a delivery mapping routine which will return the
*settlement flags
*the settlement flags are updated in 9th array of the handoff
*1st position - the flag is YES when payin account is given in the settlement property
*2nd position - the flag is NO when payin beneficiary is given in the settlement property
*
*Arguments
*
*Input
* HAND.REC
*    - Handoff Records passed as input
*
* Output
*    - the schedule details are passed in the Handoff Record 9.
*      Error Message is returned in case of any mishappenings.
*
*-----------------------------------------------------------------------------
*
*** <region name= Modificaion History>
*
* 24/10/20 - Task : 4042370
*            Enhancement  : 3774161
*            To update the settlement flags in the handoff
*
******************************************************************

    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AA.Settlement
    $USING DE.Outward

*
    GOSUB Initialise
    GOSUB FormHandoff
*
RETURN
******************************************************************
Initialise:
************

    ApplicationList = ''
    AppPos = ''
    HandoffPos = ''
    AmendmentFee = ''
    RArrangement = ''
    CurrPos = ''
    Properties = ''
    PropertyClassList = ''
    PropClassPos = ''
    SettlementProp = ''
    SettlePropPos = ''
    SettlementRec = ''
    SettlePayinAcct = ''
    SettlePayinBen = ''
*
RETURN
******************************************************************
FormHandoff:
*****************

    ApplicationList = DE.Outward.getHandoffRecs(7)
    
    LOCATE "AA.LOC.CHARGE.DETAILS" IN ApplicationList SETTING AppPos THEN
        HandoffPos = 10 + AppPos
    END
    
    AmendmentFee = DE.Outward.getHandoffRecs(HandoffPos)<2>
    
    RArrangement = DE.Outward.getHandoffRecs(1)
    
    LOCATE 'CURRENT' IN RArrangement<AA.Framework.Arrangement.ArrProductStatus,1> SETTING CurrPos THEN
    END

    Properties = RArrangement<AA.Framework.Arrangement.ArrProperty, CurrPos>
    
    Properties = RAISE(Properties)
        
    AA.ProductFramework.GetPropertyClass(Properties, PropertyClassList)
    
    LOCATE 'SETTLEMENT' IN PropertyClassList<1,1> SETTING PropClassPos THEN
        SettlementProp = Properties<1,PropClassPos>
    END
    
    LOCATE SettlementProp IN ApplicationList SETTING SettlePropPos THEN
        HandoffPos = 10 + SettlePropPos
    END

    SettlementRec = DE.Outward.getHandoffRecs(HandoffPos)

    SettlePayinAcct = SettlementRec<AA.Settlement.Settlement.SetPayinAccount>
    SettlePayinBen = SettlementRec<AA.Settlement.Settlement.SetPayinBeneficiary>

    BEGIN CASE
        CASE AmendmentFee AND AmendmentFee GT 0 AND SettlePayinAcct
            HandRec(9)<1> = "Yes"

        CASE AmendmentFee AND AmendmentFee GT 0 AND SettlePayinBen
            HandRec(9)<2> = "Yes"
    END CASE
        
*
RETURN
*-----------------------------------------------------------------------------
END
