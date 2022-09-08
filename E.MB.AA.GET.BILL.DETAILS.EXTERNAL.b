* @ValidationCode : MjotMTE2NDI3ODIyMjpDcDEyNTI6MTU1MjY0NTgyNjk2NTpzbWl0aGFiaGF0OjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDMuMjAxOTAyMTktMTI0MTo5OTo5OQ==
* @ValidationInfo : Timestamp         : 15 Mar 2019 16:00:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smithabhat
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 99/99 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.20190219-1241
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>483</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.MB.AA.GET.BILL.DETAILS.EXTERNAL(BILL.DETAILS)
 
*** <region name= Synopsis of the Routine>
***
** NOFILE enquiry routine to return the bill details of bills with System Bill Type as External for the arrangement.
** This routine returns the details in the same layout as AA.BILL.DETAILS
*
** When requested for sim, if the record is not there in the sim, SIM.READ will get it from
** live, so no need for any special processing
*
* Mandatory Input : Arrangement ID
* Return Parameter : Bill details of bills with System Bill Type as External in the same layout as AA.BILL.DETAILS
*
*-----------------------------------------------------------------------------
* @uses I_ENQUIRY.COMMON
* @class AA.ModelBank
* @package retaillending.AA
* @stereotype subroutine
* @author smithabhat@temenos.com
*-----------------------------------------------------------------------------
*
* TODO -
*
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
***
**
* 01/03/19 - Task        : 3013820
*            Enhancement : 2947623
*            New enquiry routine to return Bill Details record of bills with Sys Bill Type as External

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
**

    $USING AA.PaymentSchedule
    $USING EB.Reports
    $USING EB.DataAccess
    $USING EB.DatInterface

*** </region>
*-----------------------------------------------------------------------------

*
*** <region name= Main Process>
***
    GOSUB INITIALISE          ;* Initialise local variables

    GOSUB GET.BILL.IDS        ;* Get all Bill Ids from AA.ACCOUNT.DETAILS for the arrangement contract

    GOSUB PROCESS.BILL.DETAILS          ;* For each of the Bill Id, get the details from AA.BILL.DETAILS

RETURN
*** </region>
*-----------------------------------------------------------------------------


*** <region name= Initialise local variables>
***
INITIALISE:
  
    ARR.ID = "" ;* Arrangement Id, mandatory information
    SIM.REF = "" ;* Simulation reference, if the details are to be picked from a simulation

    LOCATE 'ARR.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARRPOS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARRPOS>          ;* Arrangement Id
    END

    LOCATE 'SIM.REF' IN EB.Reports.getEnqSelection()<2,1> SETTING SIMPOS THEN
        SIM.REF = EB.Reports.getEnqSelection()<4,SIMPOS>         ;* Simulation Reference
    END
 
    F.AA.ACCOUNT.DETAILS = ""
 
    F.AA.ACCOUNT.DETAILS.HIST = ""

    FN.AA.BILL.DETAILS = "F.AA.BILL.DETAILS"
    F.AA.BILL.DETAILS = ""
    EB.DataAccess.Opf(FN.AA.BILL.DETAILS, F.AA.BILL.DETAILS)

    FN.AA.BILL.DETAILS.HIST = "F.AA.BILL.DETAILS.HIST"
    F.AA.BILL.DETAILS.HIST = ""
    EB.DataAccess.Opf(FN.AA.BILL.DETAILS.HIST, F.AA.BILL.DETAILS.HIST)

    BILL.DETAILS = ""         ;* Entire Bill details record for the arrangement
    PAYMENT.DATES = ""        ;* To sort by PaymentDate

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get Bill Ids>
***
GET.BILL.IDS:
*
** Ensure we read the live/sim record of AA.ACCOUNT.DETAILS which has the BillIds
*

    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, "F.AA.ACCOUNT.DETAILS", ARR.ID, R.AA.ACCOUNT.DETAILS, SIM.ONLY, "", "")
    END ELSE
        R.AA.ACCOUNT.DETAILS = AA.PaymentSchedule.AccountDetails.Read(ARR.ID, "")
    END

*
** Ensure we read Hist record as well, for both live/sim
*

    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, "F.AA.ACCOUNT.DETAILS.HIST", ARR.ID, R.AA.ACCOUNT.DETAILS.HIST, SIM.ONLY, "", "")
    END ELSE
        R.AA.ACCOUNT.DETAILS.HIST = AA.PaymentSchedule.AccountDetailsHist.Read(ARR.ID, "")
    END

    BILL.IDS.HIST = ""
    IF R.AA.ACCOUNT.DETAILS.HIST<AA.PaymentSchedule.AccountDetailsHist.AdBillId,1> THEN      ;* There are some bill records that are archived
        BILL.IDS.HIST = RAISE(RAISE(R.AA.ACCOUNT.DETAILS.HIST<AA.PaymentSchedule.AccountDetailsHist.AdBillId>))  ;* Raise it to FM marker
    END

    BILL.IDS.LIVE = ""
    IF R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillId,1> THEN ;* There are some bill records in live
        BILL.IDS.LIVE = RAISE(RAISE(R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillId>))
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------


*** <region name= Process Bill Details>
***
PROCESS.BILL.DETAILS:

** Process both archived and live Bills

    HISTORY = ""    ;* Flag to indicate if bill is to be read from .HIST or from LIVE
    BILL.IDS = BILL.IDS.LIVE
    GOSUB PARSE.BILL.DETAILS

    HISTORY = 1
    BILL.IDS = BILL.IDS.HIST
    GOSUB PARSE.BILL.DETAILS

RETURN

*** </region>
*-----------------------------------------------------------------------------


*** <region name= Parse Bill Details>
***
PARSE.BILL.DETAILS:

    LOOP
        REMOVE BILL.ID FROM BILL.IDS SETTING BILL.POS
    WHILE BILL.ID:BILL.POS

        GOSUB GET.BILL.RECORD ;* Read Bill record from simulation details/live - either archived or live
        
        GOSUB CHECK.SYSTEM.BILL.TYPE    ;* Read the Bill Type's System Bill Type
        
        IF EXTERNAL.BILL THEN      ;*  Process bills with System Bill Type as External

            GOSUB UPDATE.BILL.RECORD    ;* Update the Bill record to be returned to the enquiry
        END

    REPEAT

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get Bill Record>
***
GET.BILL.RECORD:

    IF HISTORY THEN ;* Archived Bill
        FN.BILL.DETAILS = FN.AA.BILL.DETAILS.HIST
        F.BILL.DETAILS = F.AA.BILL.DETAILS.HIST
    END ELSE        ;* Live Bill
        FN.BILL.DETAILS = FN.AA.BILL.DETAILS
        F.BILL.DETAILS = F.AA.BILL.DETAILS
    END

    R.AA.BILL.DETAILS = ""
    IF SIM.REF THEN ;* Get Bill details from simulation, if not, SIM.READ will get it from live
        EB.DatInterface.SimRead(SIM.REF, FN.BILL.DETAILS, BILL.ID, R.AA.BILL.DETAILS, SIM.ONLY, "", "")
    END ELSE        ;* Only live record is required
        EB.DataAccess.FRead(FN.BILL.DETAILS, BILL.ID, R.AA.BILL.DETAILS, F.BILL.DETAILS, "")
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Update Bill Record>
***
UPDATE.BILL.RECORD:

** Return Bill details record
    IF PAYMENT.DATES THEN
        LOCATE R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentDate> IN PAYMENT.DATES<1> BY "DR" SETTING NEXT.POS ELSE
            NULL
        END

        INS R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentDate> BEFORE PAYMENT.DATES<NEXT.POS>

    END ELSE
        PAYMENT.DATES = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentDate>
    END
    
    CONVERT @FM TO "*" IN R.AA.BILL.DETAILS
    
    IF BILL.DETAILS THEN ;* Avoid the null position in return array
        INS BILL.ID:"*":R.AA.BILL.DETAILS BEFORE BILL.DETAILS<NEXT.POS>
    END ELSE
        BILL.DETAILS = BILL.ID:"*":R.AA.BILL.DETAILS
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= CHECK.SYSTEM.BILL.TYPE>
*** <desc>Check System Bill Type /desc>
CHECK.SYSTEM.BILL.TYPE:

** To Process bills with System Bill Type as External check if Bill Type is External

    EXTERNAL.BILL = ''
    R.AA.BILL.TYPE = ''
    BILL.TYPE.EXTERNAL = ''
    SYS.BILL.TYPE = ''
    BILL.TYPE.EXTERNAL = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdBillType>  ;* Get the Bill Type from the Bill details
    R.AA.BILL.TYPE = AA.PaymentSchedule.BillType.CacheRead(BILL.TYPE.EXTERNAL, RET.ERROR)    ;* Read the Bill Type record
    SYS.BILL.TYPE = R.AA.BILL.TYPE<AA.PaymentSchedule.BillType.BtSysBillType>    ;* Fetch the System Bill type
    IF SYS.BILL.TYPE = 'EXTERNAL' THEN
        EXTERNAL.BILL = 1   ;* Set Flag if the Sys bill type is EXTERNAL
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

END

