* @ValidationCode : Mjo3MjExMTgwODpDcDEyNTI6MTUyMjIxNzI2OTk2NzphcmNoYW5hcHJhc2FkOjI6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODAxLjIwMTcxMjIzLTAxNTE6NDI6Mjg=
* @ValidationInfo : Timestamp         : 28 Mar 2018 11:37:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : archanaprasad
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 28/42 (66.6%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201801.20171223-0151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-42</Rating>
*-----------------------------------------------------------------------------
* A new routine (E.MB.GET.INTEREST.RATE) has been introduced to Show the interest rate in Overview screen.
* This new routine is called from an existing enquiry (AA.DETAILS.INTEREST).
*------------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.MB.GET.INTEREST.RATE

    *-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done in the routine </desc>
    * 03/04/2013  - Defect 627602
    *               Task  639818
    *               In simualtion overview Interest details are displayed reading from Live Record
    *               need to get the details from SIM record
    *
    * 30/09/13   - Task : 796460
    *            - Defect : 794191
    *            - Interest Tier Narration is shown incorrectly in AA Overview Screen
    *
    * 18/02/16 - Defect: 1629082
    *			 Task: 1635671
    *            When is margin rate is left NULL only % is shown instead of 0%.
    *
    * 14/08/17 - Task : 2234356
    *            Def  : 2230164
    *            If we trigger more than one CHANGE.PRODUCT activity with different MARGIN rates then
    *            the system showing MARGIN.RATE value from the latest condition instead of the respective simulation reference.
    *
    * 21/03/18 - Defect: 2481505
    *            Task: 2513327
    *            Incorrect interest margin in future dated simulation screen
    *
    *-----------------------------------------------------------------------------

    $USING AA.Interest
    $USING AA.ProductFramework
    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Reports


    GOSUB INIT
    GOSUB GET.ID
    GOSUB PROCESS
    RETURN

    *------------------------------------------------------------------------------
INIT:
    *------------------------------------------------------------------------------

    ARR.ID = '' ; TOT.RATE = ''; NO.OF.REC = ""; I = 1 ; MARGIN.OPER = "" ;
    ARR.ID = EB.Reports.getOData() ; effectiveDate = EB.SystemTables.getToday() ; SIM.REF = "" ; MARGIN.RATE = "" ;
    idArrangementComp = FIELD(ARR.ID,"-",1)
    idProperty = FIELD(ARR.ID,"-",2)
    SIM.REF = FIELD(ARR.ID,"-",3)       ;* To check whether this enquiry is called from Simulation overview
    R.SIM.CAP=''
    RETURN

    *------------------------------------------------------------------------------
GET.ID:
    *------------------------------------------------------------------------------

    IF SIM.REF THEN   ;* If enquity is called from simulation overview need to concate simulation ref with the arrangement id.
        AA.ProductFramework.GetPropertyClass(idProperty,idPropertyClass)
         
        idArrangementComp = idArrangementComp : "///": SIM.REF        ;* Need to pass the simulation reference (4th Argument Separated by /) to get the current product condition.
        R.SIM = AA.Framework.SimulationRunner.Read(SIM.REF, RET.ERR)   ;*Read the SIM Runner Record to get the SIM Capture Ref     
        SIM.CAP.ID=R.SIM<AA.Framework.SimulationRunner.SimSimCaptureRef,1>        
        R.SIM.CAP = AA.Framework.SimulationCapture.Read(SIM.CAP.ID, SIM.CAP.ERR)    ;* Get the simulation capture Record        
        effectiveDate = R.SIM.CAP<AA.Framework.SimulationCapture.ArrActEffectiveDate> ;*Get the SIM act effective date
        
        AA.Framework.GetArrangementConditions(idArrangementComp,idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions,returnError)
        returnConditions = RAISE(returnConditions)
        
    END ELSE
        returnConditions = EB.Reports.getRRecord()
    END
    RETURN

    *------------------------------------------------------------------------------
PROCESS:
    *------------------------------------------------------------------------------
    MARGIN.OPER = returnConditions<AA.Interest.Interest.IntMarginOper,EB.Reports.getVc()>          ;* Selection based on the multivalue field
    MARGIN.RATE = returnConditions<AA.Interest.Interest.IntMarginRate,EB.Reports.getVc()>
    NO.OF.REC = DCOUNT(MARGIN.OPER,@SM)

    FOR I =1 TO NO.OF.REC
        IF MARGIN.RATE<1,1,I> EQ "" THEN
            MARGIN.RATE<1,1,I> = "0"
        END

        BEGIN CASE
            CASE MARGIN.OPER<1,1,I> EQ "ADD"
                TOT.RATE := " +" : " " : MARGIN.RATE<1,1,I> :"%"

            CASE MARGIN.OPER<1,1,I> EQ "SUB"
                TOT.RATE := " -" : " " : MARGIN.RATE<1,1,I> :"%"

            CASE MARGIN.OPER<1,1,I> EQ "MULTIPLY"
                TOT.RATE := " *" : " " : MARGIN.RATE<1,1,I> :"%"

        END CASE
    NEXT I
    EB.Reports.setOData(TOT.RATE)
    RETURN
END
