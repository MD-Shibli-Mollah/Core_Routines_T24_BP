* @ValidationCode : MjoxNjExODUzMjQzOkNwMTI1MjoxNjA4NjIyOTI4OTM4OmRpdnlhc2FyYXZhbmFuOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NTo0NjoxMg==
* @ValidationInfo : Timestamp         : 22 Dec 2020 13:12:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : divyasaravanan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 12/46 (26.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.DE.CONV.FACILITY.CCY.AMOUNT(InValue, HeaderRec, MvNo, OutValue, ErrorMsg)
*-----------------------------------------------------------------------------
*
* Conversion routine to convert the amount from drawing currency to facility currency
*
*** <region name= Arguments>
*** <desc>/desc>
* Arguments
*
* Input
*
* Invalue       - Amount to be converted
* HeaderRec     - Header record
*
* Output
*
* OutValue      - Converted amount
* ErrorMsg      - Error message, if any
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 18/12/20 - Defect  : 4138776
*            Task    : 4140105
*            To convert the drawing amount into facility ccy amount
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>

    $USING DE.Outward
    $USING DE.Config
    $USING AA.Framework
    $USING AC.AccountOpening
    $USING AA.ExchangeRate
    $USING AA.ActivityMessaging
    
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
    
    DIM RDetail(500)
    MAT RDetail = ''

    OutValue = ''
    Returnerror = ''
       
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DoProcess>
*** <desc>Main Logic</desc>
DoProcess:
    
    tmp.FDO = DE.Outward.getFDeOMsg()
    tmp.Rkey = DE.Outward.getRKey()
    MATREAD RDetail FROM tmp.FDO,tmp.Rkey ELSE
        RETURN
    END

    DeMessageId = HeaderRec<DE.Config.IHeader.HdrMessageType>
    RDeMessage = DE.Config.tableMessage(DeMessageId,DeErr)
    
    InAmount = InValue ;* Amount to be converted to Facility ccy
    DrawingAccountId = HeaderRec<DE.Config.IHeader.HdrAcno.> ;* Get the account number
    EffectiveDate = HeaderRec<DE.Config.IHeader.HdrValueDate> ;* Get effective date
    
    RAccount = AC.AccountOpening.Account.Read(DrawingAccountId, Returnerror) ;* Read ACCOUNT application
    ArrangementId = RAccount<AC.AccountOpening.Account.ArrangementId> ;* Get arrangement id
    
    DeMsgFldName = 'MASTER REFERENCE'
    GOSUB GetFieldValue
    MasterArrId = DeMsgFieldData
    
    DeMsgFldName = 'EXCHANGE RATE'
    GOSUB GetFieldValue
    ExchangeRate = DeMsgFieldData

    IF NOT(Returnerror) THEN
        GOSUB ConvertCcyAmount ;* To convert the incoming amount into facility ccy amount
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetFieldValue>
*** <desc>To get field data</desc>
GetFieldValue:

    LOCATE DeMsgFldName IN RDeMessage<DE.Config.Message.MsgFieldName,1> SETTING Pos THEN
        DeMsgFieldData = RDetail(Pos)
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ConvertCcyAmount>
*** <desc>To convert the incoming amount into facility ccy amount</desc>
ConvertCcyAmount:

* Convert the incoming amount from Drawing Ccy to Facility Ccy
    ArrangementId<1> = ArrangementId
    ArrangementId<2> = MasterArrId
    OutAmount = ''
    LocalAmount = ''
    RetError = ''
    OutCurrency = ''
    UtilisationAmount = ''
    AA.Framework.ConvertFacilityCcyAmount(ArrangementId, InAmount, EffectiveDate, ExchangeRate, '', OutCurrency, OutAmount, LocalAmount, UtilisationAmount, RetError)
    
    RetAmount = ''
    AA.ActivityMessaging.ConvertAmountCcyFormat(OutAmount, OutCurrency, RetAmount)

    OutValue = RetAmount ;* Amount converted to Facility Ccy
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

END

