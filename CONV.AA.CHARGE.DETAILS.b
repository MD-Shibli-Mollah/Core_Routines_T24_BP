* @ValidationCode : MjoyMDgyMzY1OTIwOkNwMTI1MjoxNTMwNjgwMjY4Mzk1OmtrYXZpdGE6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDYuMjAxODA1MTktMDA1ODoxMDE6NDU=
* @ValidationInfo : Timestamp         : 04 Jul 2018 10:27:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kkavita
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 45/101 (44.5%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201806.20180519-0058
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-126</Rating>
*-----------------------------------------------------------------------------

$PACKAGE AA.ActivityCharges
SUBROUTINE CONV.AA.CHARGE.DETAILS(YID, R.RECORD, FN.FILE)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* Conversion Routine to update Pay Date from Activity History
* record to AA.CHARGE.DETAILS file.
*
*-----------------------------------------------------------------------------
** @package retaillending.AA
* @stereotype subroutine
* @ author tamaria@temenos.com
*-----------------------------------------------------------------------------
*
* 13/04/16 - Task : 1695612
*            Defect : 1694524
*            Field movement should be done first and then update PAY.DATE
*
* 03/07/18 - Task : 2658060
*            Defect : 2646204
*            APP.METHOD field value should update correctly in R09 to R16 upgrade
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.CHARGE.DETAILS
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_AA.APP.COMMON

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>
   
    GOSUB INITIALISE
    GOSUB STORE.ACCOUNT.DETAILS
    GOSUB DO.CONVERSION

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initilaise</desc>
INITIALISE:

    ARRANGEMENT.ID = FIELD(YID, AA$SEP, 1)

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Store Account Details>
*** <desc>Store the Account Details Record</desc>
STORE.ACCOUNT.DETAILS:

    AA.CHARGE.DETAILS = R.RECORD

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Do Conversion>
*** <desc>Main control logic in the sub-routine</desc>
DO.CONVERSION:

    GOSUB GET.AA.ARRANGEMENT  ;* Get Arrangement record
    GOSUB GET.LOG.RECORD      ;* Get activity history record
    GOSUB DO.CHARGE.DETAILS.CONVERSION  ;* Do actual conversion

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get Activity log Record>
*** <desc>Get the Activity History Record</desc>
GET.LOG.RECORD:

    ACTIVITY.LOG.REC = ''
    REQD.MODE = ''
    CALL AA.READ.ACTIVITY.HISTORY(ARRANGEMENT.ID, REQD.MODE, "", ACTIVITY.LOG.REC)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Arrangement Record>
*** <desc>Get the Arrangement Record</desc>
GET.AA.ARRANGEMENT:

    R.ARRANGEMENT = ''
    RET.ERR = ''
    CALL AA.GET.ARRANGEMENT(ARRANGEMENT.ID, R.ARRANGEMENT, RET.ERR)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Do Charge Details Conversion>
*** <desc>Do Charge Details Conversion</desc>
DO.CHARGE.DETAILS.CONVERSION:
*

    NO.PAYMENT.DATE = DCOUNT(AA.CHARGE.DETAILS<AA.CHG.DET.PAYMENT.DATE>,VM)     ;* Count of Payment dates
    PAYMENT.DATES  = AA.CHARGE.DETAILS<AA.CHG.DET.PAYMENT.DATE>

    BEGIN CASE
        CASE PAYMENT.DATES
            GOSUB MOVE.CHARGE.DETAILS
            GOSUB STORE.ACCOUNT.DETAILS
            GOSUB UPDATE.CHARGE.DETAILS
            
        CASE 1
            GOSUB MOVE.CHARGE.DETAILS

    END CASE

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Update Charge Details>
*** <desc> </desc>
UPDATE.CHARGE.DETAILS:

    FOR CNT = 1 TO NO.PAYMENT.DATE
        PERIOD.END.DATE = PAYMENT.DATES<CNT>
        IF CNT GT 1 THEN
            PERIOD.START.DATE = PAYMENT.DATES<CNT-1>
        END ELSE
            PERIOD.START.DATE = R.ARRANGEMENT<AA.ARR.START.DATE>
        END
        GOSUB GET.PERIOD.START.END.DATE.POS       ;* Find out the period in activity log
        GOSUB UPDATE.AAA.REF  ;* Update pay date
    NEXT CNT

    GOSUB RESTORE.ACCOUNT.DETAILS

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Move Charge details>
*** <desc> </desc>
MOVE.CHARGE.DETAILS:

*After upgrade from R09 to dev, APP.METHOD field value moved to DEF.BILL.AMT.LCY field incorrectly
*because the code mapping is done according to R10 AA.CHARGE.DETAILS fields, where 2 extra fields added
*to fix this counting the no of fields and based on that updating AA.CHARGE.DETAILS table

    R.RECORD = AA.CHARGE.DETAILS
    NO.OF.FIELDS=DCOUNT(R.RECORD,@FM)
    
    R.RECORD<11> = ''
    R.RECORD<12> = AA.CHARGE.DETAILS<11>
    R.RECORD<13> = AA.CHARGE.DETAILS<12>
    IF NO.OF.FIELDS EQ "14" THEN
        R.RECORD<14> = ''
        R.RECORD<15> = ''
        R.RECORD<16> = AA.CHARGE.DETAILS<13>
        R.RECORD<17> = AA.CHARGE.DETAILS<14>
    END ELSE
        R.RECORD<14> = AA.CHARGE.DETAILS<13>
        R.RECORD<15> = AA.CHARGE.DETAILS<14>
        R.RECORD<16> = AA.CHARGE.DETAILS<15>
        R.RECORD<17> = AA.CHARGE.DETAILS<16>
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get effective date>
*** <desc>Get effective date position</desc>
GET.PERIOD.START.END.DATE.POS:

    LOCATE PERIOD.START.DATE IN ACTIVITY.LOG.REC<AA.AH.EFFECTIVE.DATE,1> SETTING ST.POS THEN
        NULL
    END

    LOCATE PERIOD.END.DATE IN ACTIVITY.LOG.REC<AA.AH.EFFECTIVE.DATE,1> SETTING END.POS THEN
        NULL
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Update pay date>
*** <desc>Update pay date in charge details</desc>
UPDATE.AAA.REF:

    ACT.CNT = DCOUNT(AA.CHARGE.DETAILS<AA.CHG.DET.ARR.ACTIVITY.ID> , VM)

    FOR ACT = 1 TO ACT.CNT
        ACTIVITY.ID = AA.CHARGE.DETAILS<AA.CHG.DET.ARR.ACTIVITY.ID,ACT>
        GOSUB GET.EFF.DATE
        BILL.TYPES = AA.CHARGE.DETAILS<AA.CHG.DET.BILL.TYPE,ACT>
        APP.METHODS = AA.CHARGE.DETAILS<AA.CHG.DET.APP.METHOD,ACT>
        BILL.POS = 0
        LOOP
            BILL.POS += 1
            BILL.TYPE = BILL.TYPES<1,1,BILL.POS>
            APP.METHOD = APP.METHODS<1,1,BILL.POS>
        WHILE BILL.TYPE
            IF APP.METHOD = 'DEFER' THEN
                AA.CHARGE.DETAILS<AA.CHG.DET.PAY.DATE,ACT,BILL.POS> = ACTIVITY.LOG.REC<AA.AH.EFFECTIVE.DATE,DATE.POS>
            END
        REPEAT
    NEXT ACT

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Activity effective date>
*** <desc>Get Activity Effective Date</desc>
GET.EFF.DATE:
    FOR POS = END.POS TO ST.POS
        LOCATE ACTIVITY.ID IN ACTIVITY.LOG.REC<AA.AH.ACTIVITY.REF, POS , 1> SETTING ACT.POS THEN
            DATE.POS = POS
            EXIT    ;* Exit if Date found
        END
    NEXT POS
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Restore Record>
*** <desc>Restore Updated Charge Details Record</desc>
RESTORE.ACCOUNT.DETAILS:

    R.RECORD  = AA.CHARGE.DETAILS

RETURN
*** </region>
*-----------------------------------------------------------------------------

END
