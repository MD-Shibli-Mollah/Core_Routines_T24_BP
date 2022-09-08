* @ValidationCode : MjoxOTk0OTg2NjY3OkNwMTI1MjoxNjA0MzE0MDM4ODYwOnJhbmdhaGFyc2hpbmlyOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NToyOToyOQ==
* @ValidationInfo : Timestamp         : 02 Nov 2020 16:17:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rangaharshinir
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 29/29 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.DE.CONV.PRICING.DATE(InValue,HeaderRec,MvNo,OutValue,ErrorMsg)
*-----------------------------------------------------------------------------
*** Program Description
* This conversion will be attached in DFP
* it returns the repricing date of the incoming property's activity
* Interest Property - ADVANCE.CHANGE
* Exchange Rate Property - RATE.FIX
*
*** <region name= Arguments>
*** <desc>/desc>
* Arguments
*
* Input
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 30/10/20  - Enhancement : 4051785
*             Task : 4051788
*             Conversion routine to get the repricing date
*
*
** 02/11/20 - Enhancement : 4051785
*             Task : 4057349
*             Change of Activity Action to Rate.Fix for interest properties
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts

    $USING AA.ProductFramework
    $USING AA.Framework
    $USING DE.Config
    $USING AC.AccountOpening

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise            ;* Initialise variables
    IF Property THEN
        GOSUB DoProcess             ;* Main processing
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise all local variables required</desc>
Initialise:
    
    OutValue = ''
    AccountNumber = ''
    AccountRec = ''
    ArrangementId = ''
    ArrRecord = ''
    ProductLine = ''
    PropertyRec = ''
    ActivityActionSuffix = 'RATE.FIX'
    RepricingActivity = ''
    SchedActRec = ''
    ActPos = ''
    Property = InValue
    RepricingDate = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DoProcess>
*** <desc>Main Logic</desc>
DoProcess:

    AccountNumber = HeaderRec<DE.Config.IHeader.HdrAcno.>
    AccountRec = AC.AccountOpening.Account.Read(AccountNumber, '')
    ArrangementId = AccountRec<AC.AccountOpening.Account.ArrangementId>
    AA.Framework.GetArrangement(ArrangementId, ArrRecord, '')
    ProductLine = ArrRecord<AA.Framework.Arrangement.ArrProductLine>
    AA.Framework.LoadStaticData("F.AA.PROPERTY",Property,PropertyRec,"")
    
    RepricingActivity = ProductLine:AA.Framework.Sep:ActivityActionSuffix:AA.Framework.Sep:Property
    
    AA.ModelBank.GetRepricingDate(ArrangementId, RepricingActivity, '', RepricingDate)
    
    OutValue = OCONV(ICONV(RepricingDate,"D4"),"D4E")   ;* Format date from YYYY/MM/DD to "DD MM YYYY"
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

END

