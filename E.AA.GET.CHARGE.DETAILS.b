* @ValidationCode : MjotMjEyNzU5MDQwMjpDcDEyNTI6MTU4MTkyMDczNzkxODpubWFydW46NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMS4yMDE5MTIyNC0xOTM1OjMyNjoyMjM=
* @ValidationInfo : Timestamp         : 17 Feb 2020 11:55:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nmarun
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 223/326 (68.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-213</Rating>
*---------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.CHARGE.DETAILS(RET.LIST)
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 06/01/14 - Task : 852569
*            Defect : 850802
*            If the enquiry E.AA.GET.CHARGE.DETAILS is launched then we form the out array for that bill alone.
*
* 17/03/14 - Task : 944931
*            Defect : 938848
*            Bill Adjustment Narrative, Simulation Details, Adjustment Details were not shown in the charge details Overview Screen.
*
* 17/03/14 - Task : 1085200
*            Defect : 1084194
*            Simulated Charge details is not displayed under the charges tab of simulation arrangement overview screen.
*
* 21/12/17 - Task : 2389360
*            Defect : 2371368
*            Charge Enquiry ( AA.DETAILS.CHARGE.DATE & AA.DETAILS.CHARGE.TYPE ) is displaying worng payment date
*
* 31/01/18 - Task : 2442977
*            Enhancement : 2319413
*            Bill status also passed in return list due to requirement from Pricing and Fees enhancement
*
* 30/01/20 - Task   : 3563234
*            Defect : 3537133
*            Don't add the deferred charge details in the Return Array list.  The deferred charges are doesn't required to
*            display on the enquiry output since this charge would be included as part of Periodic charge payment.
*
*** </region>
*-----------------------------------------------------------------------------

    $USING EB.Reports
    $USING AA.ActivityCharges
    $USING AA.PaymentSchedule
    $USING AA.BalanceMaintenance
    $USING EB.DataAccess
    $USING AA.Framework
    $USING EB.Foundation
    $USING AA.ProductFramework
    $INSERT I_DAS.AA.CHARGE.DETAILS


    GOSUB INIT
    GOSUB GET.ENQ.SELECTION
    GOSUB PROCESS

RETURN

***********************************************************************
INIT:
************************************************************************

    ACT.ID.COUNT = ""
    LOG.LIST = ""
    RET.LIST = ""
    TABLE.SUFFIX = ""
    GET.PROPERTY = ""
    THE.LIST = DAS.CHARGE.DETAILS$IDLK

    TOT.BILL = ""
    BILL.CNT = ""
    ZERO = ""
    TOT.REC.CNT = 0

    FN.AA.BILL.DETAILS = "F.AA.BILL.DETAILS"
    F.AA.BILL.DETAILS = ""
    R.AA.BILL.DETAILS = ""
    ERR.AA.BILL.DETAILS = ""
    EB.DataAccess.Opf(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    R.SIMULATION.DETAILS = ''
    ERR.SIMULATION.DETAILS = ''
    F.SIMULATION.DETAILS = ''

    FN.AA.CHARGE.DETATILS = 'F.AA.CHARGE.DETAILS'
    F.AA.CHARGE.DETATILS = ''
    EB.DataAccess.Opf(FN.AA.CHARGE.DETATILS,F.AA.CHARGE.DETATILS)

    FN.BALANCE.MAINTENANCE = 'F.AA.ARR.BALANCE.MAINTENANCE'
    F.BALANCE.MAINTENANCE = ''
    RECORD.ID = ""
    RET.ERR =""
    EB.DataAccess.Opf(FN.BALANCE.MAINTENANCE, F.BALANCE.MAINTENANCE)

    F.BALANCE.MAINTENANCE.NAU = ''

    FN.AA.PROCESS.DETAILS.LOC = "F.AA.PROCESS.DETAILS"
    F.AA.PROCESS.DETAILS.LOC = ""
    EB.DataAccess.Opf(FN.AA.PROCESS.DETAILS.LOC,F.AA.PROCESS.DETAILS.LOC)


RETURN

***********************************************************************
GET.ENQ.SELECTION:
**********************************************************************
* Section to get the Selection Fields Values passed in the enquiry request.

    SIM.CHARGE.DETAILS.IDS = ""
    SIM.BILLS = ""
    ENQSEL.BILL.ID = ""
    RET.ERROR = ""
    SIM.CHARGE.DETAILS.LIST = ""

    LOCATE "ARRANGEMENT.ID" IN EB.Reports.getEnqSelection()<2,1> SETTING ARR.POS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARR.POS>
    END

    LOCATE "BILL.ID" IN EB.Reports.getEnqSelection()<2,1> SETTING ARR.BILL.POS THEN
        ENQSEL.BILL.ID = EB.Reports.getEnqSelection()<4,ARR.BILL.POS>
    END

    THE.ARGS = ARR.ID ; TABLE.SUFFIX = ""
    EB.DataAccess.Das('AA.CHARGE.DETAILS',THE.LIST,THE.ARGS,TABLE.SUFFIX)

    AA.CHARGE.DETAILS.LIST = SORT(THE.LIST)

    LOCATE "SIM.REF" IN EB.Reports.getEnqSelection()<2,1> SETTING SIM.POS THEN       ;* Locate Simulation Reference. if it exist then request details from sim files.
        SIM.ID = EB.Reports.getEnqSelection()<4,SIM.POS>
        GOSUB GET.SIMULATION.DETAILS
    END

RETURN

GET.SIMULATION.DETAILS:
***********************

    R.SIMULATION.DETAILS = EB.Foundation.SimulationDetails.Read(SIM.ID, ERR.SIMULATION.DETAILS)          ;* Read Simulation Details files to load simulation details

    IF ERR.SIMULATION.DETAILS THEN
        RETURN
    END

    FILE.LIST = R.SIMULATION.DETAILS<1>

    LOCATE FN.AA.CHARGE.DETATILS IN FILE.LIST<1,1> SETTING FILEPOS THEN         ;* Locate AA Charge Details file in Sim image record and get the list of Id's processed during Simulation.
        SIM.CHARGE.DETAILS.IDS = RAISE(R.SIMULATION.DETAILS<2,FILEPOS>)
        SIM.CHARGE.DETAILS.FUNCTION = RAISE(R.SIMULATION.DETAILS<3,FILEPOS>)    ;*Flag indicates the type of I/O. this is requried as there is a possibility of a charge reversed during RR.
        SIM.CHARGE.DETAILS.RECORDS = RAISE(R.SIMULATION.DETAILS<4,FILEPOS>)     ;* Holds the image of AA.CHARGE.DETAILS records that are processed during simulation.
    END

    LOCATE FN.AA.BILL.DETAILS IN FILE.LIST<1,1> SETTING FILEPOS THEN  ;* Locate AA Bill Details file to get the list of bills processed  during simulation.
        SIM.BILLS = RAISE(R.SIMULATION.DETAILS<2,FILEPOS>)
        SIM.BILL.RECORDS = RAISE(R.SIMULATION.DETAILS<4,FILEPOS>)
    END

* Process Details & Balance Maintenance images taken from simulation below as
* this is applicable for any adjust activities that are process during simulation by either User or RR.
    LOCATE FN.AA.PROCESS.DETAILS.LOC IN FILE.LIST<1,1> SETTING FILEPOS THEN
        SIM.PROC.DETAILS.IDS =  RAISE(R.SIMULATION.DETAILS<2,FILEPOS>)
        SIM.PROC.DETAILS.RECORDS = RAISE(R.SIMULATION.DETAILS<4,FILEPOS>)
    END

    LOCATE FN.BALANCE.MAINTENANCE IN FILE.LIST<1,1> SETTING FILEPOS THEN
        SIM.BM.IDS = RAISE(R.SIMULATION.DETAILS<2,FILEPOS>)
        SIM.BM.RECORDS = RAISE(R.SIMULATION.DETAILS<4,FILEPOS>)
    END

* This loop is basically to filter the AA Charge Details Ids. we have got the list of id's exist in AA.CHARGE.DETAILS using DAS
* Additionaly simulation might have also created new records or updated existing records. So Not to duplicate check the Id's
* and add it to list variable AA.CHARGE.DETAILS.LIST.

    SIM.CHRG.CNT = DCOUNT(SIM.CHARGE.DETAILS.IDS,@VM)
    SIM.CHRG.INT = 1

    LOOP
    WHILE SIM.CHRG.INT LE SIM.CHRG.CNT
        SIM.CHARGE.ID = SIM.CHARGE.DETAILS.IDS<1,SIM.CHRG.INT>
        LOCATE SIM.CHARGE.ID IN AA.CHARGE.DETAILS.LIST BY "AL" SETTING CHGPOS THEN
            AA.CHARGE.DETAILS.LIST<CHGPOS> = SIM.CHARGE.ID
            SIM.CHARGE.DETAILS.LIST<1,CHGPOS> = "SIM"       ;* Flag to Indicate its SIM
            SIM.CHARGE.DETAILS.LIST<2,CHGPOS> = SIM.CHARGE.DETAILS.FUNCTION<1,SIM.CHRG.INT>
            SIM.CHARGE.DETAILS.LIST<3,CHGPOS> = SIM.CHARGE.DETAILS.RECORDS<1,SIM.CHRG.INT>
        END ELSE
            AA.CHARGE.DETAILS.LIST = INSERT(AA.CHARGE.DETAILS.LIST, CHGPOS ; SIM.CHARGE.ID)
            SIM.CHARGE.DETAILS.LIST = INSERT(SIM.CHARGE.DETAILS.LIST, 1, CHGPOS ; "SIM")
            SIM.CHARGE.DETAILS.LIST = INSERT(SIM.CHARGE.DETAILS.LIST, 2, CHGPOS ; SIM.CHARGE.DETAILS.FUNCTION<1,SIM.CHRG.INT>)
            SIM.CHARGE.DETAILS.LIST = INSERT(SIM.CHARGE.DETAILS.LIST, 3, CHGPOS ; SIM.CHARGE.DETAILS.RECORDS<1,SIM.CHRG.INT>)
        END
        SIM.CHRG.INT ++
    REPEAT

RETURN

*********************************************************************
PROCESS:
********************************************************************

* 1. This Process section builds the Necessary data for Charge Details related enquiries based on the User Requested.
* 2. Since we merged the Charge details Id's in AA.CHARGE.DETAILS.LIST, we need to check whether that perticular Id exist in
*    Sim List then get the details from SIM else from the live file AA.CHARGE.DETAILS.
* 3. For Sim we need to check the record flag as the record in sim is a deleted image so we need to check the record flag
*    before  building the data for enquiry output.

    CHRG.INT = 1

    LOOP
        REMOVE CHARGE.ID FROM AA.CHARGE.DETAILS.LIST SETTING CHGPOS
    WHILE CHARGE.ID : CHGPOS

        IF SIM.CHARGE.DETAILS.LIST<1,CHRG.INT> EQ "SIM" THEN
            IF SIM.CHARGE.DETAILS.LIST<2,CHRG.INT> EQ "DELETE" ELSE
                R.AA.CHR.DETAILS = RAISE(RAISE(SIM.CHARGE.DETAILS.LIST<3,CHRG.INT>))
                GOSUB BUILD.CHARGE.DETAILS
            END
        END ELSE
            R.AA.CHR.DETAILS = AA.ActivityCharges.ChargeDetails.Read(CHARGE.ID, AA.CHR.ERR)
            GOSUB BUILD.CHARGE.DETAILS
        END

        CHRG.INT ++
    REPEAT

    IF EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFixedSort> NE "PROPERTY" THEN
        GOSUB SORT.BY.PAYMENT.DATE.DSND
    END

RETURN

SORT.BY.PAYMENT.DATE.DSND:
**************************
* Bubble Sorting to sort the return list of records for enquiry in decending order based on Payment Date.
* Do this only if the FIXED.SORT is not defined as PROPERTY at the enquiry level, because this nofile
* routine is used in two enquires Charges - By Type(Sort Based on Property) & Charges - By Date (Sort Based on Payment Date).

    FOR TOT.REC.INT = 1 TO TOT.REC.CNT - 1
        FOR TEMP.REC.INT = TOT.REC.INT + 1 TO TOT.REC.CNT
            IF RET.LIST<TOT.REC.INT>['*', 1, 1] LT RET.LIST<TEMP.REC.INT>['*', 1, 1] THEN
                TEMP.RECORD = RET.LIST<TOT.REC.INT>
                RET.LIST<TOT.REC.INT> = RET.LIST<TEMP.REC.INT>
                RET.LIST<TEMP.REC.INT> = TEMP.RECORD
            END
        NEXT TEMP.REC.INT
    NEXT TOT.REC.INT

RETURN

BUILD.CHARGE.DETAILS:
*********************

    DAYS = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetPaymentDate>
    CONVERT @VM TO @FM IN DAYS
    NO.OD.DAYS = DCOUNT(DAYS,@FM)

    LOOP.CNT = 0
    LOOP
        LOOP.CNT += 1
        PAY.DATE = DAYS<NO.OD.DAYS>
    WHILE PAY.DATE
        TOT.BILL = DCOUNT(R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetBillId,NO.OD.DAYS>,@SM)      ;* Total bil ids should be calculated based on payment dates.
        FOR BILL.CNT = 1 TO TOT.BILL
            GOSUB INIT.ENQUIRY.RETURN.VARS        ;* Initialise all the enquiry data variables here to avoid data mismatch.
            PAYMENT.DATE = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetPaymentDate,NO.OD.DAYS>
            PROPERTY = FIELD(CHARGE.ID,"-",2)
            BILL.ID = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetBillId,NO.OD.DAYS,BILL.CNT>
            LOCATE BILL.ID IN SIM.BILLS<1,1> SETTING SIM.BILLS.POS THEN
                BILL.ID := "%" : SIM.ID ; SIM.FLAG = 1      ;* if the Bill Id exist in SIM then we need to append the simulation reference followed by "%".
            END ELSE
                SIM.FLAG = 0  ;* Flag to indicate the details need to fetched from SIM. This is useful in later section.
            END

*** If the Selection doesn't contain the Bill, then it means we need to build all the details pertaining to that ARR.
*** If the Selection contain a Bill Id, then it means we need to build only details pertaining to that bill of ARR.
            IF NOT(ENQSEL.BILL.ID) OR (ENQSEL.BILL.ID EQ BILL.ID) THEN
                GOSUB BUILD.RETURN.CHARGE.DETAILS
            END
        
        NEXT BILL.CNT
        NO.OD.DAYS -= 1
    REPEAT

    IF EB.Reports.getEnqSelection()<1> EQ 'AA.BILL.DETAILS.AB' THEN
        GOSUB BUILD.ENQCHARGE.DETAILS
    END
    
RETURN

BUILD.RETURN.CHARGE.DETAILS:
*****************************

    OS.AMT = ""             ;* Initialise the OS Amount for each Bill. Otherwise previous Bill OS amount would be carry forward to next ISSUED Bill.
    OS.AMT.LCY = ""         ;* Initialise the OS Amount for each Bill. Otherwise previous Bill OS amount would be carry forward to next ISSUED Bill.
        
    GOSUB GET.CHARGE.DETAILS
    GOSUB GET.BILL.ADJ.DETAILS
    
    IF UPDATE.STORE.DATA THEN
        GOSUB STORE.DATA
    END
                    
RETURN
    
GET.CHARGE.DETAILS:
*******************
* Section to get the enquiry data pertaining to AA.CHARGE.DETAILS.
    
    UPDATE.STORE.DATA = "1"
    
    IF SIM.FLAG THEN          ;* If the Sim Flag is set then no need to read the $SIM file as the record image is already available in SIM.BILL.RECORDS variable.
        R.AA.BILL.DETAILS = RAISE(RAISE(SIM.BILL.RECORDS<1,SIM.BILLS.POS>))
    END ELSE
        AA.PaymentSchedule.GetBillDetails(ARR.ID,BILL.ID, R.AA.BILL.DETAILS, RET.ERROR)  ;* Record need to be get from Live file as it will not be in sim file.
    END

    AMOUNT = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetAmount,NO.OD.DAYS,BILL.CNT>
    AMOUNT.LCY = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetAmountLcy,NO.OD.DAYS,BILL.CNT>

* This will be the Case when no waive on charge. So Assign Default Amount with Amount if it is null.
* Assiging the DEF.AMOUNT with AMOUNT will be useful in the enquiry as we need to show the final amount after negotiation.
* Similarly for LCY as well.

    IF NOT(R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetDefaultAmt,NO.OD.DAYS,BILL.CNT>) THEN
        DEF.AMOUNT = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetAmount,NO.OD.DAYS,BILL.CNT>
    END ELSE
        DEF.AMOUNT = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetDefaultAmt,NO.OD.DAYS,BILL.CNT>
    END

    IF NOT(R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetDefaultAmtLcy,NO.OD.DAYS,BILL.CNT>) THEN
        DEF.AMOUNT.LCY = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetAmountLcy,NO.OD.DAYS,BILL.CNT>
    END ELSE
        DEF.AMOUNT.LCY = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetDefaultAmtLcy,NO.OD.DAYS,BILL.CNT>
    END

    WAIVE.AMT =  R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetWaiveAmount,NO.OD.DAYS,BILL.CNT>
    WAIVE.AMT.LCY =  R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetWaiveAmountLcy,NO.OD.DAYS,BILL.CNT>
    REASON  = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetWaiveReason,NO.OD.DAYS,BILL.CNT>


RETURN

STORE.DATA:
***********

* The ADDS function is used for amount related variables to add the existing value of it with zero.
* ADDS function will result with zero if both the varibles doesn't contain a value.
* This is done to avoid showing null instead of zero.
* Since the MV/SV display is not working for these enquiries, changed the VM & SM to # before appending it to Out variable.
* A seperate conversion routine is developed and attached to those MV fields to set the VM.COUNT and O.DATA dynamically at enquiry level.

    TOT.REC.CNT ++  ;* This variable will hold the total no of records count that is displayed in Charge details overview.

    IF  EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFixedSort> EQ "PROPERTY" THEN
* If the enquiry is having the fixed sort as PROPERTY then first field in the return list is the PROPERTY else DATE has to be given.
        RET.LIST<TOT.REC.CNT> = PROPERTY : "*" : PAYMENT.DATE : "*" : BILL.ID : "*" : ADDS(AMOUNT,ZERO) : "*" : ADDS(AMOUNT.LCY,ZERO) : "*" :
        RET.LIST    := ADDS(DEF.AMOUNT,ZERO) : "*" : ADDS(DEF.AMOUNT.LCY,ZERO) : "*" : ADDS(WAIVE.AMT,ZERO) : "*" : ADDS(WAIVE.AMT.LCY,ZERO) : "*" :
        RET.LIST    := REASON : "*" : ADDS(ADJ.AMT.TOTAL,ZERO) : "*" : ADDS(ADJ.AMT.TOTAL.LCY,ZERO) : "*" : ADJUST.AMT : "*" :
        RET.LIST    := ADJUST.AMT.LCY : "*" : ADJ.REASON : "*" : ADDS(OS.AMT,ZERO) : "*" : ADDS(OS.AMT.LCY,ZERO): "*" : BILL.STATUS
    END ELSE
        RET.LIST<TOT.REC.CNT> = PAYMENT.DATE : "*" : PROPERTY : "*" : BILL.ID : "*" : ADDS(AMOUNT,ZERO) : "*" : ADDS(AMOUNT.LCY,ZERO) : "*" :
        RET.LIST    := ADDS(DEF.AMOUNT,ZERO) : "*" : ADDS(DEF.AMOUNT.LCY,ZERO) : "*" : ADDS(WAIVE.AMT,ZERO) : "*" : ADDS(WAIVE.AMT.LCY,ZERO) : "*" :
        RET.LIST    := REASON : "*" : ADDS(ADJ.AMT.TOTAL,ZERO) : "*" : ADDS(ADJ.AMT.TOTAL.LCY,ZERO) : "*" : ADJUST.AMT : "*" :
        RET.LIST    := ADJUST.AMT.LCY : "*" : ADJ.REASON : "*" : ADDS(OS.AMT,ZERO) : "*" : ADDS(OS.AMT.LCY,ZERO): "*" : BILL.STATUS
    END

RETURN

INIT.ENQUIRY.RETURN.VARS:
*************************
* Section to initialise the enquiry data variables.

    PROPERTY = ""
    PAYMENT.DATE = ""
    BILL.ID = ""
    AMOUNT = ""
    AMOUNT.LCY = ""
    DEF.AMOUNT = ""
    DEF.AMOUNT.LCY = ""
    WAIVE.AMT = ""
    WAIVE.AMT.LCY = ""
    REASON = ""
    ADJ.REASON = ""
    ADJUST.AMT = ""
    ADJUST.AMT.LCY = ""
    ADJ.AMT.TOTAL = ""
    ADJ.AMT.TOTAL.LCY = ""

    WRITE.OFF.REFS = ""
    WRITEOFF.AMT.LCYS = ""
    WRITEOFF.AMTS = ""
    ADJUST.REFS = ""
    ADJUST.AMTS = ""
    ADJUST.AMT.LCYS = ""
    BILL.STATUS = ""

RETURN

GET.BM.DETAILS.SIM:
*******************
* Section to get the arrangement condition of BALANCE.MAINTENANCE property from Simulation Details as this is SIM.
    LOCATE ADJUST.REF IN SIM.PROC.DETAILS.IDS<1,1> SETTING RECPOS THEN
        RECORD.ID = RAISE(RAISE(SIM.PROC.DETAILS.RECORDS<1,RECPOS>))
        LOCATE RECORD.ID IN SIM.BM.IDS<1,1> SETTING RECPOS THEN
            R.BALANCE.MAINTENANCE = RAISE(RAISE(SIM.BM.RECORDS<1,RECPOS>))
        END
    END

RETURN

GET.BM.DETAILS.LIV:
*******************
* Section to get the arrangement condition of BALANCE.MAINTENANCE property from Simulation Details as this is LIV.

    AA.Framework.MaintainProcessDetails(ADJUST.REF, "LOAD", RECORD.STATUS, PROCESS.DETAILS.LIST)
    AA.Framework.ParseProcessDetails(PROCESS.DETAILS.LIST, APPLICATIONS, FUNCTIONS, PROCESS.IDS, PROCESS.ACTIONS)
    RECORD.ID = PROCESS.IDS<1,1>

    R.BALANCE.MAINTENANCE = ''

    R.BALANCE.MAINTENANCE = AA.BalanceMaintenance.ArrBalanceMaintenance.ReadNau(RECORD.ID, RET.ERR)

    IF NOT(R.BALANCE.MAINTENANCE) THEN
        R.BALANCE.MAINTENANCE = AA.BalanceMaintenance.ArrBalanceMaintenance.Read(RECORD.ID, RET.ERR)
    END

RETURN

GET.BILL.ADJ.DETAILS:
*********************
* Get the Total Adjust Amount and list of adjustments performed from the Bill of a Particular charge property
* as this will contain correct details on per bill.
* AA.BILL.DETAILS file will hold the list of Adjustment Reference, adjustment amount & it's local currency equivalent
* specific to a property of a bill. Since waive has to be shown in -ve in enquiry but it will be in +ve in AA.CHARGE.DETAILS file
* To have a common logic, Adjust amounts passed out of this routine will also be same as Waive Amount. hence -1 is multipled with Adjustment amount.

    LOCATE PROPERTY IN R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty,1> SETTING PROPOS THEN
        GOSUB BUILD.BILL.ADJ.DETAILS
    END ELSE
        GOSUB CHECK.PERIODIC.CHARGES.PROPERTY            ;* Check whether Bill property is Periodic Charge property
        BILL.STATUS = "NOT.ISSUED"  ;* if no bill present assign the bill status as not issued
    END

    ADJ.AMT.TOTAL = SUM(ADJUST.AMTS) * (-1)  ;
    ADJ.AMT.TOTAL.LCY = SUM(ADJUST.AMT.LCYS) * (-1)      ;* Multiply it with -1 as we need to show the details in enquiry in otherway.

    ADJUST.AMTS = ADDS(ADJUST.AMTS,ZERO) ;
    ADJUST.AMT.LCYS = ADDS(ADJUST.AMT.LCYS,ZERO)

    ADJ.CNT = DCOUNT(ADJUST.REFS,@SM)

    LOOP
        ADJUST.REF = ADJUST.REFS<1,1,ADJ.CNT>
    WHILE ADJ.CNT GT 0 AND ADJUST.REF
        ADJUST.REF = ADJUST.REF['-',1,1]
        IF SIM.FLAG THEN
            GOSUB GET.BM.DETAILS.SIM
        END ELSE
            GOSUB GET.BM.DETAILS.LIV
        END

        GOSUB GET.BILL.ADJ.NARRATIVE
        ADJUST.AMT := "#" : ADJUST.AMTS<1,1,ADJ.CNT>
        ADJUST.AMT.LCY := "#" : ADJUST.AMT.LCYS<1,1,ADJ.CNT>
        ADJ.CNT --
    REPEAT

    ADJ.REASON = ADJ.REASON[2,-1]
    ADJUST.AMT = ADJUST.AMT[2,-1]
    ADJUST.AMT.LCY =ADJUST.AMT.LCY[2,-1]

RETURN

CHECK.PERIODIC.CHARGES.PROPERTY:
********************************

*** In case of the DEFER charges, the charge property will not be located in the Bill details record.
*** Bill details would have the Periodic Charge Property.
*** This block of Code is to identify whether current Charge is collected as part of Periodic Charges payment.
*** If so, there is no need to display this DEFER charge in the charge details enquiry output.
*** Anyhow Periodic Charge would be displayed on the enquiry output which would include the DEFER charge as well.

*** we really don't know which amount to be displayed as OS.AMT for DEFER charges. So decided to ignore the DEFER type bills.

    PC.PROPERTY = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty,1>
    PC.PROPERTY.CLASS = ""
    AA.ProductFramework.GetPropertyClass(PC.PROPERTY, PC.PROPERTY.CLASS)
    IF PC.PROPERTY.CLASS EQ "PERIODIC.CHARGES" THEN
        UPDATE.STORE.DATA = ""                 ;* Don't update defered charge details in return array list
    END
    
RETURN

BUILD.BILL.ADJ.DETAILS:
***********************

* Outstanding Amount & its equivalent local currency amount extracted from bill as the charge details file will not hold these details.
    OS.AMT = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount,PROPOS>
    OS.AMT.LCY = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmtLcy,PROPOS>

    ADJUST.REFS = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAdjustRef,PROPOS>
    ADJUST.AMTS = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAdjustAmt,PROPOS>
    ADJUST.AMT.LCYS = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAdjustAmtLcy,PROPOS>
    BILL.STATUS = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillStatus,PROPOS>   ;* corresponding bill status
*  Write Off details to be shown in Adjustments as been switched off as this is not required now.
*  If required in future uncommenting the below three lines is sufficient to display the write off details.
*    WRITE.OFF.REFS = R.AA.BILL.DETAILS<AA.BD.WRITEOFF.REF,PROPOS>
*    WRITEOFF.AMTS = R.AA.BILL.DETAILS<AA.BD.WRITEOFF.AMT,PROPOS> * (-1)
*    WRITEOFF.AMT.LCYS = R.AA.BILL.DETAILS<AA.BD.WRITEOFF.AMT.LCY,PROPOS> * (-1)

* We append the Adjustment Reference at the end because loop will go in a reverse order as the values in these fields are updated as latest first/oldest last.
    BEGIN CASE
        CASE ADJUST.REFS AND WRITE.OFF.REFS
            ADJUST.REFS = WRITE.OFF.REFS : @SM : ADJUST.REFS
            ADJUST.AMTS = WRITEOFF.AMTS : @SM : ADJUST.AMTS
            ADJUST.AMT.LCYS = WRITEOFF.AMT.LCYS : @SM : ADJUST.AMT.LCYS
        CASE WRITE.OFF.REFS AND NOT(ADJUST.REFS)
            ADJUST.REFS = WRITE.OFF.REFS
            ADJUST.AMTS = WRITEOFF.AMTS
            ADJUST.AMT.LCYS = WRITEOFF.AMT.LCYS
    END CASE

RETURN

GET.BILL.ADJ.NARRATIVE:
***********************
* This section is to get the Adjustment Narrative.
* Check if Narrative is provided per bill in Balance Maintenance,If Yes then return it in ADJ.REASON variable.
* If it is not provided by user then check the overall adjustment Narrative and return it in ADJ.REASON, no need to check it is prvided or not.

    LOCATE BILL.ID['%',1,1] IN R.BALANCE.MAINTENANCE<AA.BalanceMaintenance.BalanceMaintenance.BmBillRef,1> SETTING BILLPOS THEN
        IF R.BALANCE.MAINTENANCE<AA.BalanceMaintenance.BalanceMaintenance.BmBillAdjNarr,BILLPOS> THEN
            ADJ.REASON := "#" : R.BALANCE.MAINTENANCE<AA.BalanceMaintenance.BalanceMaintenance.BmBillAdjNarr,BILLPOS>
        END ELSE
            ADJ.REASON := "#" : R.BALANCE.MAINTENANCE<AA.BalanceMaintenance.BalanceMaintenance.BmAdjustDesc>        ;* Need to assign correct description for amount, so values prefixed with # and finally removed the first #.
        END
    END ELSE
        ADJ.REASON := "#" : R.BALANCE.MAINTENANCE<AA.BalanceMaintenance.BalanceMaintenance.BmAdjustDesc>  ;* Need to assign correct description for amount, so values prefixed with # and finally removed the first #.
    END

RETURN
*-----------------------------------------------------------------------------
BUILD.ENQCHARGE.DETAILS:
***********************
    
    ACTIVITY.ID = ''
    ACTIVITY.IDS = ''
    NO.OF.ACTIVITY.IDS = ''
    TOT.PAY.DATE = ''
    
    ACTIVITY.IDS = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetArrActivityId>
    CONVERT @VM TO @FM IN ACTIVITY.IDS
    NO.OF.ACTIVITY.IDS = DCOUNT(ACTIVITY.IDS,@FM)

    LOOP.CNT = 0
    LOOP
        LOOP.CNT += 1
        ACTIVITY.ID = ACTIVITY.IDS<NO.OF.ACTIVITY.IDS>
    WHILE ACTIVITY.ID
        TOT.PAY.DATE = DCOUNT(R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetPayDate,NO.OF.ACTIVITY.IDS>,@SM)      ;* Total PAY DATE should be calculated.
        FOR PAY.DATE.CNT = 1 TO TOT.PAY.DATE
            IF R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetBillId,NO.OF.ACTIVITY.IDS,PAY.DATE.CNT> EQ '' THEN
                GOSUB INIT.ENQUIRY.RETURN.VARS        ;* Initialise all the enquiry data variables here to avoid data mismatch.
                PAYMENT.DATE = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetPayDate,NO.OF.ACTIVITY.IDS,PAY.DATE.CNT>
                PROPERTY = FIELD(CHARGE.ID,"-",2)
                AMOUNT = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetBillAmt,NO.OF.ACTIVITY.IDS,PAY.DATE.CNT>
                AMOUNT.LCY = R.AA.CHR.DETAILS<AA.ActivityCharges.ChargeDetails.ChgDetBillAmtLcy,NO.OF.ACTIVITY.IDS,PAY.DATE.CNT>
                BILL.STATUS = "NOT.ISSUED"  ;* if no bill present assign the bill status as not issued
                GOSUB STORE.DATA
            END
        NEXT PAY.DATE.CNT
        NO.OF.ACTIVITY.IDS -= 1
    REPEAT
    
RETURN
*-----------------------------------------------------------------------------
END
