* @ValidationCode : MjotMTQwMjEyOTI3NDpDcDEyNTI6MTYwNDQwODE0MTgyMDpkaXZ5YXNhcmF2YW5hbjoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTIxLTA2NTU6MzQ6MzQ=
* @ValidationInfo : Timestamp         : 03 Nov 2020 18:25:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : divyasaravanan
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 34/34 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.DE.CONV.NEWOFFER.MATURITY.DATE(ArrangementId, HeaderRec, MvNo, OutMaturityDate, ErrorMsg)
*-----------------------------------------------------------------------------
*
* Conversion routine to return the maturity date of the New.Offer arrangement
*
*** <region name= Arguments>
*** <desc>/desc>
* Arguments
*
* Input
*
* ArrangementId - Arrangement Id
* HeaderRec     - Header record
*
* Output
*
* OutMaturityDate - Maturity date for the given arrangement
* ErrorMsg        - Error message, if any
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 30/10/20 - Enhancement : 4051905
*            Task        : 4051908
*            To calculate and return the maturity date of the New offer arrangement
*
* 03/11/20 - Enhancement : 4051905
*            Task        : 4060815
*            Raise the arrangement conditions record to get the values
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts

    $USING DE.Outward
    $USING DE.Config
    $USING AA.Framework
    $USING AA.Account
    $USING AA.TermAmount
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise            ;* Initialise variables
    GOSUB DoProcess             ;* Main processing
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise all local variables required</desc>
Initialise:
    
    MaturityDate = ''
    Returnerror = ''
    OutMaturityDate = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DoProcess>
*** <desc>Main Logic</desc>
DoProcess:

    BaseDate = HeaderRec<DE.Config.IHeader.HdrValueDate>
    
    RAccount = ''
    AA.Framework.GetArrangementConditions(ArrangementId, 'ACCOUNT', '', BaseDate, '', RAccount, Returnerror)
    RAccount = RAISE(RAccount)
    
    IF NOT(Returnerror) THEN
        BusDayCentres = RAccount<AA.Account.Account.AcBusDayCentres>
        IF RAccount<AA.Account.Account.AcOtherBusDayCentre> THEN ;* Add arrangement currency country code to bus day centres
            AA.Account.GetArrCurrencyCode(RAccount,ArrangementId,BusDayCentres, Returnerror)
        END
        DateConv = RAccount<AA.Account.Account.AcDateConvention>
        DateAdj = RAccount<AA.Account.Account.AcDateAdjustment>
    END
    
    RTermAmount = ''
    AA.Framework.GetArrangementConditions(ArrangementId, 'TERM.AMOUNT', '', BaseDate, '', RTermAmount, Returnerror)
    RTermAmount = RAISE(RTermAmount)
    
    GOSUB GetMaturityDate
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetMaturityDate>
*** <desc>Get Maturity Date</desc>
GetMaturityDate:
    
    DateConvention = 'CALENDAR'
    TermDetails = RTermAmount<AA.TermAmount.TermAmount.AmtTerm>
    
    AA.TermAmount.GetTermEndDate(TermDetails, "", "", DateConvention, "", "", "", BaseDate, TermEndDate, Returnerror)
    
    IF RTermAmount<AA.TermAmount.TermAmount.AmtMatDateConvention> EQ 'YES' AND DateAdj EQ 'PERIOD' THEN
        AA.TermAmount.DetermineMaturityDate(TermEndDate, BusDayCentres, DateConv, MaturityDate)  ;*Determine maturity date for non working days based on date convention
    END ELSE
        MaturityDate = TermEndDate
    END

    OutMaturityDate  = OCONV(ICONV(MaturityDate ,"D4"),"D4E")   ;* Format date from YYYY/MM/DD to "DD MON YYYY"

RETURN
*** </region>
*-----------------------------------------------------------------------------

END

