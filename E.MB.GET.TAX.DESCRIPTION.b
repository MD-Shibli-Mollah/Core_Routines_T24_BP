* @ValidationCode : MjotMzk1NjA0ODY0OkNwMTI1MjoxNTg0MDk5NzA5NDUyOnJ2YXJhZGhhcmFqYW46MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMy4wOjUzOjUy
* @ValidationInfo : Timestamp         : 13 Mar 2020 17:11:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 52/53 (98.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.MB.GET.TAX.DESCRIPTION
*-----------------------------------------------------------------------------
* Input : Tax Code or Tax Property from AA.DETAILS.TAX enquiry
* Output : Description from the TAX/TAX.TYPE application
*
* 05/02/14 - Task 902195
*            Defect 854537
*            Conversion routine newly introduced to return a description
*
* 08/06/16 - Task   : 1758904
*			 Defect : 1745262
*            No data displayed on Tax on OVERVIEW screen for AR.Logic for banded tax rate is included
*
* 01/22/18 - Enhancement : 2388930
*            Task        : 2388933
*            removal of null values from CURRENT.COND.CODE.ID array
*
* 10/02/20 - Enhancement 3568228  / Task 3580449
*            Changing reference of routines that have been moved from ST to CG
*-----------------------------------------------------------------------------
*****************************************************
    $INSERT I_DAS.TAX
    $INSERT I_DAS.TAX.NOTES
    $USING CG.ChargeConfig
    $USING EB.DataAccess
    $USING EB.Reports
    $USING EB.SystemTables
    $USING AA.Tax
*****************************************************
    GOSUB INIT
    IF CURRENT.COND.CODE.ID THEN    ;* Proceed only if tax condition/code is available
        GOSUB FETCH.TAX.RECORD
        GOSUB GET.TAX.INFO
    END
    
RETURN
*****************************************************
INIT:
*****************************************************
    IF EB.Reports.getS() AND EB.Reports.getS() NE 1 THEN                           ;* Description should be displayed only for each tax property(VM). Hence need to display only for the fist tax rate(SM)
        EB.Reports.setOData("")
        RETURN
    END
    
    EB.Reports.setOData("")      ;* Clear O.DATA to assign tax description at the end
    

*** Combine both tax condition and tax code! and get the tax details based on tax code!
    CURRENT.COND.CODE.ID = EB.Reports.getRRecord()<AA.Tax.Tax.TaxTaxCondition>
    CURRENT.COND.CODE.ID<1,-1> = EB.Reports.getRRecord()<AA.Tax.Tax.TaxTaxCode>
    CURRENT.COND.CODE.ID<1,-1> = EB.Reports.getRRecord()<AA.Tax.Tax.TaxPropTaxCond>
    CURRENT.COND.CODE.ID<1,-1> = EB.Reports.getRRecord()<AA.Tax.Tax.TaxPropTaxCode>
    CURRENT.COND.CODE.ID = CHANGE(CURRENT.COND.CODE.ID,@SM,@VM) ;* All markers are changed to VM since we are not bothered whether tax code/condition is a subvalue/multivalue
    
    GOSUB REMOVE.NULL.VALUES;*remove null values from CURRENT.COND.CODE.ID array
    TOTAL.TAX.COUNT = DCOUNT(CURRENT.COND.CODE.ID,@VM)

    
    
    CURRENT.COND.CODE.ID = CURRENT.COND.CODE.ID<1,EB.Reports.getVc()>           ;* Each tax condition is processed at a time.
    
    IF EB.Reports.getVmCount() AND EB.Reports.getVmCount() LT TOTAL.TAX.COUNT THEN     ;* VM.COUNT should always have maximum count of all the conditons to display all values properly
        
        EB.Reports.setVmCount(TOTAL.TAX.COUNT)
    END
    
RETURN


*****************************************************
REMOVE.NULL.VALUES:
*****************************************************
   
    TOTAL.TAX.COUNT = DCOUNT(CURRENT.COND.CODE.ID,@VM)
    
    FOR I = 1 TO TOTAL.TAX.COUNT
        IF  CURRENT.COND.CODE.ID<1,I> EQ '' THEN;*if there is a null item
            DEL CURRENT.COND.CODE.ID<1,I>;*removing the null value
            I = I -1;*decresing the counter to check the value of next item that has same index as the one deleted one now
            TOTAL.TAX.COUNT = DCOUNT(CURRENT.COND.CODE.ID,@VM);*updating total number to avoid infinite loop
        END
    NEXT I
    
    
RETURN

*****************************************************
FETCH.TAX.RECORD:
*****************************************************
    F.TAX = ""

    F.TAX.TYPE = ""

    THE.LIST = dasTaxIdLikeById
    THE.ARGS = CURRENT.COND.CODE.ID:'....'

    EB.DataAccess.Das("TAX",THE.LIST,THE.ARGS,"")

    CONVERT @FM TO '*' IN THE.LIST
    TAX.CNT = DCOUNT(THE.LIST,'*')

    TAX.R.ID = FIELD(THE.LIST,'*',TAX.CNT)

RETURN
*****************************************************
GET.TAX.INFO:
*****************************************************
    REC.TAX = CG.ChargeConfig.Tax.Read(TAX.R.ID, ERR.TAX)
    IF REC.TAX THEN
        EB.Reports.setOData(REC.TAX<CG.ChargeConfig.Tax.EbTaxDescription,EB.SystemTables.getLngg()>)
    END ELSE
        R.TAX.TYPE = CG.ChargeConfig.TaxTypeCondition.Read(CURRENT.COND.CODE.ID, TAX.TYPE.ERR)
        IF R.TAX.TYPE THEN
            EB.Reports.setOData(R.TAX.TYPE<CG.ChargeConfig.TaxTypeCondition.TaxTtcDescription,EB.SystemTables.getLngg()>)
        END
    END

RETURN

*****************************************************

END
