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
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
* This routine is attached to the enquiry AA.DETAILS.ACCOUNT.DATES
* Input  - In O.DATA we will get the value. The value should be Arrangement number followed by "RENEWAL"
* This should be defined in the enquiry
* Output - Initiation Type & Change Activity has been appended & saved in O.DATA
*
***********************************************************
* MODIFICATION HISTORY
* 26-05-2014     Defect : 1002920
*                Task   : 1009250
*                Modification done to display label in Simulation Overview
***********************************************************
    $PACKAGE AA.ModelBank
    SUBROUTINE E.GET.CHANGE.PRODUCT


    $USING AA.ChangeProduct
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING EB.Reports


    GOSUB INIT
    GOSUB PROCESS
    RETURN

INIT:
    EB.Reports.setId("");
    EB.Reports.setId(EB.Reports.getOData());
    ARR.ID = "" ; CHG.ACT = "" ; PROPERTY = "" ; idPropertyClass = "" ; effectiveDate = "";
    ACTIVITY.CLASS = "" ; ACT.CLASS.RECORD = "" ;SIM.ID = '' ; ARR.COND.ID = '';
    propertyList = ""
    propertyClassList = ""
    returnIds = "" ; returnConditions = "" ; returnError = ""
    tmp.ID = EB.Reports.getId()
    ARR.ID = FIELD(tmp.ID,"-",1)
    EB.Reports.setId(tmp.ID)
    tmp.ID = EB.Reports.getId()
    PROPERTY = FIELD(tmp.ID,"-",2)
    EB.Reports.setId(tmp.ID)

    SIM.ID = FIELD(ARR.ID,"%",2)
    IF SIM.ID THEN
        ARR.ID<1>= FIELD(ARR.ID,'%',1)
        ARR.COND.ID = ARR.ID
        ARR.ID<6> = SIM.ID  ;* To get the simulated arrangement property list (need to send the simulation reference as 6th argument)
        ARR.COND.ID =ARR.COND.ID : "///": SIM.ID ;*Need to pass the simulation reference (4th Argument Separated by /) to get the current product condition.
    END ELSE
        ARR.COND.ID = FIELD(ARR.ID,'%',1)
    END

    AA.Framework.GetArrangementProperties(ARR.ID, "", "", propertyList)
    AA.ProductFramework.GetPropertyClass(propertyList, propertyClassList)

    idPropertyClass = "CHANGE.PRODUCT"
    LOCATE idPropertyClass IN propertyClassList<1,1> SETTING PROP.CLS.POS THEN
    PROPERTY = propertyList<1,PROP.CLS.POS>
    END

    RETURN

PROCESS:

    AA.Framework.GetArrangementConditions(ARR.COND.ID,idPropertyClass, PROPERTY, effectiveDate, returnIds, returnConditions, returnError)
    returnConditions= RAISE(returnConditions)
    CHG.ACT = returnConditions<AA.ChangeProduct.ChangeProduct.CpChangeActivity> ; * Getting the value of CHANGE.ACTIVITY for the arrangement
    AA.ProductFramework.GetActivityClass(CHG.ACT, ACTIVITY.CLASS, ACT.CLASS.RECORD)
    CHG.ACT = FIELD(ACTIVITY.CLASS,"-",2) ;
    EB.Reports.setOData(returnConditions<AA.ChangeProduct.ChangeProduct.CpInitiationType> : "*" : CHG.ACT);

    RETURN
    END
