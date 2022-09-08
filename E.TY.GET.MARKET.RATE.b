* @ValidationCode : MjotMTk2NzUyMzEwNjpjcDEyNTI6MTUwNzcxNDM1Njk0OTpzdGhlamFzd2luaTo0OjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwOC4yMDE3MDcxNy0yMjM4OjUzOjUz
* @ValidationInfo : Timestamp         : 11 Oct 2017 15:02:36
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : sthejaswini
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 53/53 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201708.20170717-2238
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE TY.RateParameters
SUBROUTINE E.TY.GET.MARKET.RATE(RevalRate)
*-----------------------------------------------------------------------------
*
* Modification History :
*
* 01/08/2017 - EN 2207363 / TK 2207366
*              TY.Positions - Enquiry for Market Rate
*
* 26/09/2017 - EN 2259114 / Tk 2263374
*              Market rate enquiry to fetch details for all ccy / ccy Pair
*
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING TY.RateParameters
*-----------------------------------------------------------------------------

    GOSUB GetSelectionFields

RETURN  ;* of routine
*-----------------------------------------------------------------------------
**** <region name= GetSelectionFields>
*** <desc> </desc>
GetSelectionFields:
    RevalRate = ''
    
    LOCATE "RATE.SOURCE" IN EB.Reports.getDFields()<1> SETTING FIELD.POS THEN
        RateSource  = EB.Reports.getDRangeAndValue()<FIELD.POS>
    END
    LOCATE "RATE.PROVIDER" IN EB.Reports.getDFields()<1> SETTING FIELD.POS THEN
        RateProvider  = EB.Reports.getDRangeAndValue()<FIELD.POS>
    END

    LOCATE "CURRENCY" IN EB.Reports.getDFields()<1> SETTING FIELD.POS THEN
        CurrencyVal  = EB.Reports.getDRangeAndValue()<FIELD.POS>
    END

    LOCATE "ASSET.TYPE" IN EB.Reports.getDFields()<1> SETTING FIELD.POS THEN
        AssetType  = EB.Reports.getDRangeAndValue()<FIELD.POS>
    END

    LOCATE "DATE.OR.PERIOD" IN EB.Reports.getDFields()<1> SETTING FIELD.POS THEN
        DateOrRest  = EB.Reports.getDRangeAndValue()<FIELD.POS>
    END

    LOCATE "RATE.INDICATOR" IN EB.Reports.getDFields()<1> SETTING FIELD.POS THEN
        BidOfferInd  = EB.Reports.getDRangeAndValue()<FIELD.POS>
    END

    LOCATE "INTERPOLATION.MKR" IN EB.Reports.getDFields()<1> SETTING FIELD.POS THEN
        InterpolationMkr  = EB.Reports.getDRangeAndValue()<FIELD.POS>
    END

    NoOfCurrency = DCOUNT(CurrencyVal,@SM) ;* list of currency selection values
    FOR CcyCount=1 TO NoOfCurrency
        Currency = CurrencyVal<1,1,CcyCount>
        IF LEN(Currency) GT 3 THEN  ;* it is Currency Pair
            Ccy = Currency[1,3]:@FM:Currency[4,3]  ;* Separate the currencies by FM
        END ELSE
            Ccy = Currency[1,3]
        END
    
**store selection criteria details
        tmpRateSource = RateSource
        tmpRateProvider = RateProvider
        tmpAssetType = AssetType
        tmpDateOrRest = DateOrRest
        tmpBidOfferInd = BidOfferInd
        tmpInterpolationMkr = InterpolationMkr

        GOSUB GetRevalRate ;*fetch details of each ccy/ccy pair
        
**restore selection criteria details
        RateSource = tmpRateSource
        RateProvider = tmpRateProvider
        AssetType = tmpAssetType
        DateOrRest = tmpDateOrRest
        BidOfferInd = tmpBidOfferInd
        InterpolationMkr = tmpInterpolationMkr
    NEXT CcyCount
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= GetRevalRate>
*** <desc> </desc>
GetRevalRate:
 
* Initialise outcoming parameters
    DaysSinceToday = ''
    MktRate = ''
    InputErr = ''
    
    TY.RateParameters.TyDetermineRate(RateSource, RateProvider, Ccy, CcyMkt, AssetType, DateOrRest, BidOfferInd, InterpolationMkr, DaysSinceToday, MktRate, InputErr)

* RateSource * RateProvider * Currency * AssetType * DateOrRest * BidOfferInd * InterpolationMkr  * Rate * DaysSinceToday

    RevalRate<-1> = RateSource:"*":RateProvider:"*":Currency:"*":AssetType:"*":DateOrRest:"*":BidOfferInd:"*":InterpolationMkr:"*":MktRate:"*":DaysSinceToday


RETURN
*** </region>

*-----------------------------------------------------------------------------

END ;* of routine
