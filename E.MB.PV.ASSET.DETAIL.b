* @ValidationCode : MjoxOTQyMDkzNzU1OkNwMTI1MjoxNTk1MzQzMDU3MzM5OmphYmluZXNoOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNToyODE6MjMy
* @ValidationInfo : Timestamp         : 21 Jul 2020 20:20:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jabinesh
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 232/281 (82.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*---------------------------------------------------------------------------------------
* <Rating>-184</Rating>
*---------------------------------------------------------------------------------------
* Subroutine to select the records of both PV.ASSET.DETAIL and PV.ASSET.DETAIL.HIS for a particular contract or for
* all based on the selection criteria
* attached in STANDARD.SELECTION for the NOFILE enquiry PV.ASSET.DETAIL
$PACKAGE PV.ModelBank
SUBROUTINE E.MB.PV.ASSET.DETAIL(Y.DATA)
**************************************************************************************************
* Modification History:
***********************
* 13/04/2015 - Defect - 1293675/ Task - 1314741
*              Incorrect variable used in PV.CUSTOMER.DETAIL.HIST opf.
*
* 15/06/2015 - Defect -  1369505 / Task - 1379106
*              Enquiry PV.ASSET.DETAIL show all records from history files, since
*              variable CONTRACT.ID is nullified before use in select query of history file.
*
* 01/02/2017 - Defect - 1998436 / Task - 2005022
*              Enquiry PV.ASSET.DETAIL shows manual amount at wrong dates where originally
*              no manual classification has been done.
*
* 23/10/2018 - Enhancement 2785696 / Task 2786384
*              Changes done to display Segment details
*
* 21/04/2020 - Enhancemnet 3688765 / Task 3688766
*              Capture position type details in the enquiry data of multi Gaap provisioning
*
* 16/06/2020 - Enhancement 3768971 / Task 3768972
*              Capture ccf cut off detail defined at contract level in the enquiry data.
**************************************************************************************************

    $USING PV.Config
    $USING EB.DataAccess
    $USING EB.Reports
    $USING PV.ModelBank


*MAIN PROCESSING

    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB SELECTFILES

RETURN
*---------------------------------------------------------------------------------------
INITIALISE:
*---------------------------------------------------------------------------------------
*Variables for opening PV.ASSET.DETAIL and PV.ASSET.DETAIL.HIS

    FN.PV.ASSET.DETAIL = 'F.PV.ASSET.DETAIL'
    F.PV.ASSET.DETAIL = ''

    FN.PV.ASSET.DETAILHIS = 'F.PV.ASSET.DETAIL.HIST'
    F.PV.ASSET.DETAILHIS = ''

*---------------------------------------------------------------------------------------

    SEL.CMD = ''
    SEL1.CMD = ''
    SEL.LIST = ''
    SEL1.LIST = ''
    NO.OF.SEL = ''
    NO.OF.SEL1 = ''
    SEL.ERR = ''
    SEL1.ERR = ''
    ASSETDETAIL.ID = ''
    ASSETDETAILHIS.ID = ''
    R.ASSETDETAIL = ''
    R.ASSETDETAILHIS = ''
    POS = ''
    POS1 = ''

*----------------------------------------------------------------------------------------
* Variables to hold the both PV.ASSET.DETAILS and PV.ASSET.DETAILS.HIS Details

    CONTRACT.ID = ''
    PROFILE.ID = ''
    CONTRACTID = ''
    CUSTOMER = ''
    PRODUCT = ''
    CURRENCY = ''
    PRODUCT.GROUP = ''
    LAST.CLASS.DATE = 'DUMMY'
    AUTO.CLASS = 'DUMMY'
    MANUAL.CLASS = 'DUMMY'
    AUTO.RISK.SEGMENT = '0'
    MANUAL.RISK.SEGMENT = '0'
    CALC.PROV.AMT = '0'
    CALC.PROV.AMT.LCY = '0'
    COLLATERAL.AMOUNT = '0'
    MAN.PROV.AMOUNT = '0'
    MAN.PROV.AMT.LCY = '0'
* Varibles to hold the amount multivalues of current and previous provisions, to be summed for display
    LAST.CALC.DATE = 'DUMMY'
    CUR.CALC.PROV.AMT = ''
    CUR.CALC.PROV.AMT.LCY = ''
    CUR.COLLATERAL.AMOUNT = ''
    CUR.MAN.PROV.AMOUNT = ''
    CUR.MAN.PROV.AMT.LCY = ''
    PR.CALC.PROV.AMT = ''
    PR.CALC.PROV.AMT.LCY = ''
    PR.COLLATERAL.AMOUNT = ''
    PR.MAN.PROV.AMOUNT = ''
    PR.MAN.PROV.AMT.LCY = ''

*-----------------------------------------------------------------------------------------

    ARRAY = ''
    ARRAY1 = ''
    Y.DATA = ''

*---------------------------------------------------------------------------------------
* Getting the Transaction Reference from the Selection Criteria

    LOCATE '@ID' IN EB.Reports.getEnqSelection()<2,1> SETTING CONTRACT.ID THEN
        CONTRACTID = EB.Reports.getEnqSelection()<4,CONTRACT.ID>
    END

RETURN

*---------------------------------------------------------------------------------------
OPENFILES:

    EB.DataAccess.Opf(FN.PV.ASSET.DETAIL,F.PV.ASSET.DETAIL)
    EB.DataAccess.Opf(FN.PV.ASSET.DETAILHIS,F.PV.ASSET.DETAILHIS)

RETURN

*---------------------------------------------------------------------------------------
SELECTFILES:
*---------------------------------------------------------------------------------------
* Selecting the PV.ASSET.DETAILS record based on the selection criteria

    IF CONTRACTID EQ '' THEN
        SEL.CMD = 'SELECT ':FN.PV.ASSET.DETAIL:' BY @ID'
    END ELSE
        SEL.CMD = 'SELECT ':FN.PV.ASSET.DETAIL:' WITH @ID EQ ':CONTRACTID
        SEL1.CMD = 'SELECT ':FN.PV.ASSET.DETAIL:" WITH @ID LIKE ":CONTRACTID:"*..."  ;* Command to select multi Gaap provision for the contract
    END

* Selecting Application Based on the contract Id.

    BEGIN CASE
        CASE CONTRACTID[1,2] EQ 'LD'
            CONTRACT.APPLN = "LD"
        CASE CONTRACTID[1,2] EQ 'AA'
            CONTRACT.APPLN = "AA"
        CASE CONTRACTID[1,2] EQ 'SL'
            CONTRACT.APPLN = "SL"
        CASE CONTRACTID[1,2] EQ 'MM'
            CONTRACT.APPLN = "MM"
        CASE CONTRACTID[1,2] EQ 'MD'
            CONTRACT.APPLN = "MD"
        CASE CONTRACTID[1,2] EQ 'LI' OR DCOUNT(CONTRACTID,'.') EQ '3'
            CONTRACT.APPLN = "LI"
        CASE NUM(CONTRACTID)
            CONTRACT.APPLN = "AC"
    END CASE
    
    GOSUB READ.LIVE.FILES     ;* Fetch customer provision details from live file
    
RETURN
*--------------------------------------------------------------------------------------
READ.LIVE.FILES:
*----------------

* Selecting the PV.CUSTOMER.DETAIL record based on the selection criteria
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.OF.SEL,SEL.ERR)
    
*** Selecting Multi Gaap provision for the provided contract.
*** Multi Gaap Asset detail Id contain Contract Id and Position type, both are seperated by '*' delimiter,
*** therefore the multi Gaap selection will be based on the contract Id with '*' delimiter.
    IF SEL.LIST AND SEL1.CMD THEN
        EB.DataAccess.Readlist(SEL1.CMD,SEL1.LIST,'',NO.OF.SEL1,SEL1.ERR)
        IF SEL1.LIST THEN
            SEL.LIST<-1> = SEL1.LIST
        END
    END

* Loop begins here

    LOOP
        REMOVE ASSETDETAIL.ID FROM SEL.LIST SETTING POS
    WHILE ASSETDETAIL.ID:POS

* Reading the PV.ASSET.DETAIL record for the particular Contract Id

        R.ASSETDETAIL = PV.Config.AssetDetail.Read(ASSETDETAIL.ID, ASSETDETAIL.ERR)

        PROFILE.ID = R.ASSETDETAIL<PV.Config.AssetDetail.PvadProfileId>
*** If the asset detial is GAAP specific, then position type should be extracted from the management id and the position detail updated in the seperate column
        MANAGEMENT.ID = R.ASSETDETAIL<PV.Config.AssetDetail.PvadManagementId>
        POSITION.TYPE = FIELD(MANAGEMENT.ID,'*',2)
        IF POSITION.TYPE THEN
            DLIM.CNT = COUNT(ASSETDETAIL.ID,'*')
            CONTRACTID = FIELD(ASSETDETAIL.ID,'*',1,DLIM.CNT)
        END ELSE
            CONTRACTID = ASSETDETAIL.ID
        END
        CUSTOMER = R.ASSETDETAIL<PV.Config.AssetDetail.PvadCustomer>
        PRODUCT = R.ASSETDETAIL<PV.Config.AssetDetail.PvadProduct>
        CURRENCY = R.ASSETDETAIL<PV.Config.AssetDetail.PvadCurrency>
        PRODUCT.GROUP = R.ASSETDETAIL<PV.Config.AssetDetail.PvadProductGroup>
        CCF.CUT.OFF = R.ASSETDETAIL<PV.Config.AssetDetail.PvadCcfCutOff>
        LAST.CLASS.DATE<1,-1> = R.ASSETDETAIL<PV.Config.AssetDetail.PvadLastClassDate>
        LAST.CLASS.DATE<1,-1> = R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrClassDte>
        AUTO.CLASS<1,-1> = R.ASSETDETAIL<PV.Config.AssetDetail.PvadAutoClass>
        AUTO.CLASS<1,-1> = R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrAutoClass>
        MANUAL.CLASS<1,-1> = R.ASSETDETAIL<PV.Config.AssetDetail.PvadManualClass>
        MANUAL.CLASS<1,-1> = R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrManClass>
        AUTO.RISK.SEGMENT<1,-1> = R.ASSETDETAIL<PV.Config.AssetDetail.PvadAutoRiskSegment>
        AUTO.RISK.SEGMENT<1,-1> = R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrAutoRiskSeg>
        MANUAL.RISK.SEGMENT<1,-1> = R.ASSETDETAIL<PV.Config.AssetDetail.PvadManualRiskSegment>
        MANUAL.RISK.SEGMENT<1,-1> = R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrManualRiskSeg>
        LAST.CALC.DATE<1,-1> = R.ASSETDETAIL<PV.Config.AssetDetail.PvadLastCalcDate>
        LAST.CALC.DATE<1,-1> = R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrCalcDate>
        
* Get the count of provision types for the asset and sum up all the balance types to get the original provision amount
        CALC.PROV.CNT = DCOUNT(R.ASSETDETAIL<PV.Config.AssetDetail.PvadCalcProvType>,@VM)
        GOSUB CALC.CURR.PROV.AMT        ;* Calculate the current provision amount

* Get the count of previous provision types for the asset and sum up all the balance types to get the original provision amount
        PR.CALC.CNT = DCOUNT(R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrCalcDate>,@VM)
        FOR PR.CALC.POS = 1 TO PR.CALC.CNT
            PR.CALC.TYPE.CNT = DCOUNT(R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrCalcType,PR.CALC.POS>,@SM)
            GOSUB CALC.PR.PROV.AMT      ;* Calculate the current provision amount
        NEXT PR.CALC.POS

*----------------------------------------------------------------------------------------
* Forming the Final array which contains all the necessary details from PV.ASSET.DETAIL
* each data seperated by '*' to be returned from the routine

* For Reference, the positions in which each data will be hold in the array seperated by '~' are
*-----------------------------------------------------------------------------------------
* PV.ASSET.DETAIL Data
*-----------------------------------------------------------------------------------------
* POS<1> = CONTRACTID , POS<2> = CONTRACTAPPLN, POS<3> = PROFILE.ID, POS<4> = CUSTOMER , POS<5> = PRODUCT, POS<6> = CURRENCY
* POS<7> = PRODUCT GROUP , POS<8> = LAST CLASS DATE , POS<9> = AUTO.CLASS
* POS<10> = MANUAL.CLASS, POS<11> = LAST.CALC.DATE, POS<12> = CALC.PROV.AMOUNT
* POS<13> = CALC.PROV.AMOUNT.LCY , POS<14> = COLLATERAL.AMOUNT
* POS<15> =  MAN.PROV.AMOUNT , POS<16> = MAN.PROV.AMOUNT.LCY , POS<17> = POSITION.TYPE
* POS<18> = CCF.CUT.OFF
* Delete initial zero value in order to maintain the value position
        GOSUB DEL.FROM.ARRAY
        ARRAY = CONTRACTID:'~':CONTRACT.APPLN:'~':PROFILE.ID:'~':CUSTOMER:'~':PRODUCT:'~':CURRENCY:'~':PRODUCT.GROUP:'~':LAST.CLASS.DATE:'~':AUTO.CLASS:'~':MANUAL.CLASS:'~':AUTO.RISK.SEGMENT:'~':MANUAL.RISK.SEGMENT:'~':LAST.CALC.DATE:'~':CALC.PROV.AMT:'~':CALC.PROV.AMT.LCY:'~':COLLATERAL.AMOUNT:'~':MAN.PROV.AMOUNT:'~':MAN.PROV.AMT.LCY:'~':POSITION.TYPE:'~':CCF.CUT.OFF

        Y.DATA<-1> = ARRAY

*--------------------------------------------------------------------------------------
* All the Variables holding the data are made null to hold new data in the next Loop
        GOSUB RE.INITIALISE
        GOSUB READ.HIST.FILES     ;* Fetch customer provision details from history file
    REPEAT

*loop ends here
RETURN
*---------------------------------------------------------------------------------------
READ.HIST.FILES:
*----------------
* Selecting the PV.ASSET.DETAIL.HIS record based on the sequence number of the live record

    HIS.IDS.MAX = R.ASSETDETAIL<PV.Config.AssetDetail.PvadSeqNo>
    LOOP
    WHILE HIS.IDS.MAX

*Reading the PV.ASSET.DETAIL.HIS record for the particular Contract Id
        ASSETDETAILHIS.ID = ASSETDETAIL.ID:";":HIS.IDS.MAX
        R.ASSETDETAILHIS = PV.Config.AssetDetailHist.Read(ASSETDETAILHIS.ID, ASSETDETAILHIS.ERR)

        PROFILE.ID = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadProfileId>
        CUSTOMER = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadCustomer>
        PRODUCT = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadProduct>
        CURRENCY = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadCurrency>
        PRODUCT.GROUP = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadProductGroup>
        CCF.CUT.OFF = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadCcfCutOff>
        LAST.CLASS.DATE<1,-1> = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrClassDte>
        AUTO.CLASS<1,-1> = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrAutoClass>
        MANUAL.CLASS<1,-1> = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrManClass>
        AUTO.RISK.SEGMENT<1,-1> = R.ASSETDETAILHIS<PV.Config.AssetDetailHist.PvadhPrAutoRiskSeg>
        MANUAL.RISK.SEGMENT<1,-1> = R.ASSETDETAILHIS<PV.Config.AssetDetailHist.PvadhPrManualRiskSeg>
        LAST.CALC.DATE<1,-1> = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrCalcDate>
* Get the count of previous provision types for the asset and sum up all the balance types to get the original provision amount
        PR.CALC.CNT = DCOUNT(R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrCalcDate>,@VM)
        FOR PR.CALC.POS = 1 TO PR.CALC.CNT
            PR.CALC.TYPE.CNT = DCOUNT(R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrCalcType,PR.CALC.POS>,@SM)
            GOSUB CALC.HIST.PR.PROV.AMT
        NEXT PR.CALC.POS

*----------------------------------------------------------------------------------------
* Forming the Final array which contains all the necessary details from PV.ASSET.DETAIL.HIS
* each data seperated by '*' to be returned from the routine

* For Reference, the positions in which each data will be hold in the array seperated by '~' are
*-----------------------------------------------------------------------------------------
* PV.ASSET.DETAIL.HIS Data
*-----------------------------------------------------------------------------------------
* POS<1> = CONTRACTID , POS<2> = CONTRACTAPPLN, POS<3> = PROFILE.ID, POS<4> = CUSTOMER , POS<5> = PRODUCT, POS<6> = CURRENCY
* POS<7> = PRODUCT GROUP , POS<8> = LAST CLASS DATE , POS<9> = AUTO.CLASS
* POS<10> = MANUAL.CLASS,POS<11> = AUTO.RISK.SEGMENT, POS<12> = MANUAL.RISK.SEGMENT , POS<13> = LAST.CALC.DATE, POS<14> = CALC.PROV.AMOUNT
* POS<15> = CALC.PROV.AMOUNT.LCY , POS<16> = COLLATERAL.AMOUNT
* POS<17> =  MAN.PROV.AMOUNT , POS<18> = MAN.PROV.AMOUNT.LCY , POS<19> = POSITION.TYPE
* POS<20> = CCF.CUT.OFF
* Delete initial zero value in order to maintain the value position
        GOSUB DEL.FROM.ARRAY
        ARRAY1 = CONTRACTID:'~':CONTRACT.APPLN:'~':PROFILE.ID:'~':CUSTOMER:'~':PRODUCT:'~':CURRENCY:'~':PRODUCT.GROUP:'~':LAST.CLASS.DATE:'~':AUTO.CLASS:'~':MANUAL.CLASS:'~':AUTO.RISK.SEGMENT:'~':MANUAL.RISK.SEGMENT:'~':LAST.CALC.DATE:'~':CALC.PROV.AMT:'~':CALC.PROV.AMT.LCY:'~':COLLATERAL.AMOUNT:'~':MAN.PROV.AMOUNT:'~':MAN.PROV.AMT.LCY:'~':POSITION.TYPE:'~':CCF.CUT.OFF

        Y.DATA<-1> = ARRAY1

*--------------------------------------------------------------------------------------
* All the Variables holding the data are made null to hold new data in the next Loop
        GOSUB RE.INITIALISE
        HIS.IDS.MAX -= 1
    REPEAT

* Loop ends here
RETURN
*---------------------------------------------------------------------------------------
CALC.CURR.PROV.AMT:
*-------------------
* For each provision loop through all individual balance types to sum up the amounts

    FOR PROV.TYPE.POS = 1 TO CALC.PROV.CNT
        GOSUB SUM.CURR.PROV.AMT         ;* Sum up individual provision amounts
    NEXT PROV.TYPE.POS
* Assigning the current provission amount to enquiry display variables
    CALC.PROV.AMT<1,-1> = CUR.CALC.PROV.AMT
    CALC.PROV.AMT.LCY<1,-1> = CUR.CALC.PROV.AMT.LCY
    COLLATERAL.AMOUNT<1,-1> = CUR.COLLATERAL.AMOUNT
    MAN.PROV.AMOUNT<1,-1> = CUR.MAN.PROV.AMOUNT
    MAN.PROV.AMT.LCY<1,-1> = CUR.MAN.PROV.AMT.LCY

RETURN
*---------------------------------------------------------------------------------------
SUM.CURR.PROV.AMT:
*------------------
* For each individual provision amount add then to the enquiry variables only it it has
* values in them, so as to display null values else amount will be displayed with zero

    IF R.ASSETDETAIL<PV.Config.AssetDetail.PvadCalcProvAmt,PROV.TYPE.POS> NE '' THEN
        CUR.CALC.PROV.AMT+ = R.ASSETDETAIL<PV.Config.AssetDetail.PvadCalcProvAmt,PROV.TYPE.POS>
    END

    IF R.ASSETDETAIL<PV.Config.AssetDetail.PvadCalcProvAmtLcy,PROV.TYPE.POS> NE '' THEN
        CUR.CALC.PROV.AMT.LCY+ = R.ASSETDETAIL<PV.Config.AssetDetail.PvadCalcProvAmtLcy,PROV.TYPE.POS>
    END

    IF R.ASSETDETAIL<PV.Config.AssetDetail.PvadCollateralAmount,PROV.TYPE.POS> NE '' THEN
        CUR.COLLATERAL.AMOUNT+ = R.ASSETDETAIL<PV.Config.AssetDetail.PvadCollateralAmount,PROV.TYPE.POS>
    END

    IF R.ASSETDETAIL<PV.Config.AssetDetail.PvadManProvAmt,PROV.TYPE.POS> NE '' THEN
        CUR.MAN.PROV.AMOUNT+ = R.ASSETDETAIL<PV.Config.AssetDetail.PvadManProvAmt,PROV.TYPE.POS>
    END

    IF R.ASSETDETAIL<PV.Config.AssetDetail.PvadManProvAmtLcy,PROV.TYPE.POS> NE '' THEN
        CUR.MAN.PROV.AMT.LCY+ = R.ASSETDETAIL<PV.Config.AssetDetail.PvadManProvAmtLcy,PROV.TYPE.POS>
    END

RETURN
*---------------------------------------------------------------------------------------
CALC.PR.PROV.AMT:
*-----------------
* For each provision loop through all individual balance types to sum up the amounts

    FOR PR.CALC.TYPE.POS = 1 TO PR.CALC.TYPE.CNT
        GOSUB SUM.PR.PROV.AMT
    NEXT PR.CALC.TYPE.POS
* Assigning the previous provission amount to enquiry display variables
    CALC.PROV.AMT<1,-1> = PR.CALC.PROV.AMT ; PR.CALC.PROV.AMT = ''
    CALC.PROV.AMT.LCY<1,-1> = PR.CALC.PROV.AMT.LCY ; PR.CALC.PROV.AMT.LCY = ''
    COLLATERAL.AMOUNT<1,-1> = PR.COLLATERAL.AMOUNT ; PR.COLLATERAL.AMOUNT = ''
    MAN.PROV.AMOUNT<1,-1> = PR.MAN.PROV.AMOUNT ; PR.MAN.PROV.AMOUNT = ''
    MAN.PROV.AMT.LCY<1,-1> = PR.MAN.PROV.AMT.LCY ; PR.MAN.PROV.AMT.LCY = ''

RETURN
*---------------------------------------------------------------------------------------
SUM.PR.PROV.AMT:
*----------------
* For each individual provision amount add then to the enquiry variables only it it has
* values in them, so as to display null values else amount will be displayed with zero

    IF R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrCalcAmt,PR.CALC.POS,PR.CALC.TYPE.POS> NE '' THEN
        PR.CALC.PROV.AMT+ = R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrCalcAmt,PR.CALC.POS,PR.CALC.TYPE.POS>
    END

    IF R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrCalcAmtLcy,PR.CALC.POS,PR.CALC.TYPE.POS> NE '' THEN
        PR.CALC.PROV.AMT.LCY+ = R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrCalcAmtLcy,PR.CALC.POS,PR.CALC.TYPE.POS>
    END

    IF  R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrCollAmt,PR.CALC.POS,PR.CALC.TYPE.POS>NE '' THEN
        PR.COLLATERAL.AMOUNT+ = R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrCollAmt,PR.CALC.POS,PR.CALC.TYPE.POS>
    END

    IF R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrManAmt,PR.CALC.POS,PR.CALC.TYPE.POS> NE '' THEN
        PR.MAN.PROV.AMOUNT+ = R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrManAmt,PR.CALC.POS,PR.CALC.TYPE.POS>
    END

    IF R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrManAmtLcy,PR.CALC.POS,PR.CALC.TYPE.POS> NE '' THEN
        PR.MAN.PROV.AMT.LCY+ = R.ASSETDETAIL<PV.Config.AssetDetail.PvadPrManAmtLcy,PR.CALC.POS,PR.CALC.TYPE.POS>
    END

RETURN
*---------------------------------------------------------------------------------------
CALC.HIST.PR.PROV.AMT:
*---------------------
* For each provision loop through all individual balance types to sum up the amounts

    FOR PR.CALC.TYPE.POS = 1 TO PR.CALC.TYPE.CNT
        GOSUB SUM.HIST.PR.PROV.AMT
    NEXT PR.CALC.TYPE.POS
* Assigning the previous provission amount to enquiry display variables
    CALC.PROV.AMT<1,-1> = PR.CALC.PROV.AMT ; PR.CALC.PROV.AMT = ''
    CALC.PROV.AMT.LCY<1,-1> = PR.CALC.PROV.AMT.LCY ; PR.CALC.PROV.AMT.LCY = ''
    COLLATERAL.AMOUNT<1,-1> = PR.COLLATERAL.AMOUNT ; PR.COLLATERAL.AMOUNT = ''
    MAN.PROV.AMOUNT<1,-1> = PR.MAN.PROV.AMOUNT ; PR.MAN.PROV.AMOUNT = ''
    MAN.PROV.AMT.LCY<1,-1> = PR.MAN.PROV.AMT.LCY ; PR.MAN.PROV.AMT.LCY = ''

RETURN
*---------------------------------------------------------------------------------------
SUM.HIST.PR.PROV.AMT:
*--------------------
* For each individual provision amount add then to the enquiry variables only it it has
* values in them, so as to display null values else amount will be displayed with zero

    IF R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrCalcAmt,PR.CALC.POS,PR.CALC.TYPE.POS> NE '' THEN
        PR.CALC.PROV.AMT+ = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrCalcAmt,PR.CALC.POS,PR.CALC.TYPE.POS>
    END

    IF R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrCalcAmtLcy,PR.CALC.POS,PR.CALC.TYPE.POS> NE '' THEN
        PR.CALC.PROV.AMT.LCY+ = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrCalcAmtLcy,PR.CALC.POS,PR.CALC.TYPE.POS>
    END

    IF R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrCollAmt,PR.CALC.POS,PR.CALC.TYPE.POS> NE '' THEN
        PR.COLLATERAL.AMOUNT+ = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrCollAmt,PR.CALC.POS,PR.CALC.TYPE.POS>
    END

    IF R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrManAmt,PR.CALC.POS,PR.CALC.TYPE.POS> NE '' THEN
        PR.MAN.PROV.AMOUNT+ = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrManAmt,PR.CALC.POS,PR.CALC.TYPE.POS>
    END

    IF R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrManAmtLcy,PR.CALC.POS,PR.CALC.TYPE.POS> NE '' THEN
        PR.MAN.PROV.AMT.LCY+ = R.ASSETDETAILHIS<PV.Config.AssetDetail.PvadPrManAmtLcy,PR.CALC.POS,PR.CALC.TYPE.POS>
    END

RETURN
*---------------------------------------------------------------------------------------
RE.INITIALISE:
*--------------
* Re Initialise all local variabled for resue

    CONTRACT.ID = ''
    PROFILE.ID = ''
    CUSTOMER = ''
    PRODUCT = ''
    CURRENCY = ''
    PRODUCT.GROUP = ''
    LAST.CLASS.DATE = 'DUMMY'
    AUTO.CLASS = 'DUMMY'
    MANUAL.CLASS = 'DUMMY'
    AUTO.RISK.SEGMENT = '0'
    MANUAL.RISK.SEGMENT = '0'
    CALC.PROV.AMT = '0'
    CALC.PROV.AMT.LCY = '0'
    COLLATERAL.AMOUNT = '0'
    MAN.PROV.AMOUNT = '0'
    MAN.PROV.AMT.LCY = '0'
    LAST.CALC.DATE = 'DUMMY'
    CUR.CALC.PROV.AMT = ''
    CUR.CALC.PROV.AMT.LCY = ''
    CUR.COLLATERAL.AMOUNT = ''
    CUR.MAN.PROV.AMOUNT = ''
    CUR.MAN.PROV.AMT.LCY = ''
    PR.CALC.PROV.AMT = ''
    PR.CALC.PROV.AMT.LCY = ''
    PR.COLLATERAL.AMOUNT = ''
    PR.MAN.PROV.AMOUNT = ''
    PR.MAN.PROV.AMT.LCY = ''
    ARRAY = ''
    ARRAY1 = ''

RETURN
*---------------------------------------------------------------------------------------
DEL.FROM.ARRAY:
*--------------
* Delete the first position array since it is only to ensure the position of dates and calssification
* value does not changes due to appending to arrays

    DEL CALC.PROV.AMT<1,1>
    DEL CALC.PROV.AMT.LCY<1,1>
    DEL COLLATERAL.AMOUNT<1,1>
    DEL MAN.PROV.AMOUNT<1,1>
    DEL MAN.PROV.AMT.LCY<1,1>
    DEL LAST.CLASS.DATE<1,1>
    DEL AUTO.CLASS<1,1>
    DEL MANUAL.CLASS<1,1>
    DEL AUTO.RISK.SEGMENT<1,1>
    DEL MANUAL.RISK.SEGMENT<1,1>
    DEL LAST.CALC.DATE<1,1>
    
RETURN
*---------------------------------------------------------------------------------------
END
