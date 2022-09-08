* @ValidationCode : MjotMjAzNTAzMTM3OkNwMTI1MjoxNDg4MTcyNDExMzAwOnR1cmFzaG1pOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMDozMDozMA==
* @ValidationInfo : Timestamp         : 27 Feb 2017 10:43:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : turashmi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 30/30 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.GET.FLOAT.RATE
*-------------------------------------
* Description
*
* This is a conversion enquiry routine that accepts
* a floating key to return it's corresponding Basic Rate
* +/- Margin Rate
*---------------------------------------
*-----------------------------------------------------------------------------
*
* Modification History :
*
* 20/01/17 - Task : 1993306
*            Def  : 1980937
*            Tiered Negative Rate on AA Overview screen do not match with actual AA.ARR.INTEREST
*-----------------------------------------------------------------------------

    $INSERT I_DAS.BASIC.INTEREST

    $USING ST.RateParameters
    $USING EB.DataAccess
    $USING EB.Reports

*----------------------------------------
*
    GOSUB INITIALISE
    GOSUB PROCESS
*
    RETURN
*----------------------------------------
INITIALISE:
*-----------
*
    FV.BI = ''
*
    BI.INDX = EB.Reports.getOData()['~',1,1]
    BI.CCY = EB.Reports.getOData()['~',2,1]
    BI.DATE = EB.Reports.getOData()['~',3,1]
    BI.DATE = BI.DATE['.',1,1]
*
    BI.KEY = BI.INDX:BI.CCY:BI.DATE
*
    ID.LIST = ""
    THE.LIST = dasBasicInterestIdLikeByDsndId
    THE.ARGS = BI.INDX:BI.CCY:'...'
    TABLE.SUFFIX = ""
    EB.DataAccess.Das("BASIC.INTEREST",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    ID.LIST = THE.LIST
*
    RETURN
*------------------------------------------------------------------
PROCESS:
*
    LOCATE BI.KEY IN ID.LIST<1> BY 'DR' SETTING BI.POS ELSE
    END
*
    ID.REC = ID.LIST<BI.POS>
    R.BASIC.INT = ''
    READ.ERR = ''
    R.BASIC.INTEREST = ''
    R.BASIC.INTEREST = ST.RateParameters.BasicInterest.Read(ID.REC, READ.ERR)
    RATE = R.BASIC.INTEREST<ST.RateParameters.BasicInterest.EbBinInterestRate>
             
    IF RATE EQ '' THEN
        RATE = R.BASIC.INTEREST<ST.RateParameters.BasicInterest.EbBinNegIntRate>
    END
    
    EB.Reports.setOData(RATE)
*
    RETURN
*----------------------------------------
