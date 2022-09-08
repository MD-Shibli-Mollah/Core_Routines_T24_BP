* @ValidationCode : MjoxNzc3MzIxMjEwOkNwMTI1MjoxNTUyMzg2NTAwMjkzOnNyZGVlcGlnYToxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwMi4yMDE5MDExMS0wMzQ3Ojg3OjU5
* @ValidationInfo : Timestamp         : 12 Mar 2019 15:58:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : srdeepiga
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 59/87 (67.8%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201902.20190111-0347
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*----------------------------------------------------------------------
*-----------------------------------------------------------------------------
* <Rating>-118</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LD.Delivery
SUBROUTINE E.LD.INT.LIST(MAT HANDOFF.REC,ERR.MSG)

***********************************************************************
*
* This Subroutine is attached as a Mapping routine in 320.LD.1 to populate
* the interest amount in 9th array
*
*
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
*
* 05/03/13 - Defect : 646802 Task : 647912
*            Changes done to read from Loan & Deposits live file.
*
* 18/04/13 - Defect : 653294  Task : 653311
*            Changes done to read from Loan & Deposits live and NAU file.
*
* 02/05/18 - Defect : 2537284 / Task : 2574024
*            System hangs while processing the Interest schedules for LD contract
*            defined with Interest Due date as Business Frequency with Advices setup.
*
* 30/11/2018 - Enhancement: 2822515
*              Task :  2847828
*              Componentisation changes.
*
*** </region>
*-----------------------------------------------------------------------------
***********************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATES
    $INSERT I_F.LMM.ACCOUNT.BALANCES
    $INSERT I_F.LMM.SCHEDULES
    $INSERT I_F.LD.LOANS.AND.DEPOSITS
    $INSERT I_F.SPF
    $INSERT I_TSA.COMMON
    $INSERT I_F.TSA.STATUS

***********************************************************************

MAIN.ROUTINE:
*------------

    GOSUB INIT
    GOSUB INITIALISE
    IF R.CONTRACT THEN
        GOSUB PROCESS.SCH
    END

MAIN.ROUTINE.EXIT:
*-----------------
RETURN
************************************************************************
INIT:
*----

    F.LMM.ACCOUNT.BALANCES = 'F.LMM.ACCOUNT.BALANCES'
    FV.LMM.ACCOUNT.BALANCES = ''
    CALL OPF(F.LMM.ACCOUNT.BALANCES, FV.LMM.ACCOUNT.BALANCES)

    F.LD.LOANS.AND.DEPOSITS = 'F.LD.LOANS.AND.DEPOSITS'
    FV.LD.LOANS.AND.DEPOSITS = ''
    CALL OPF(F.LD.LOANS.AND.DEPOSITS, FV.LD.LOANS.AND.DEPOSITS)

    F.LD.LOANS.AND.DEPOSITS$NAU = 'F.LD.LOANS.AND.DEPOSITS$NAU'
    FV.LD.LOANS.AND.DEPOSITS$NAU = ''
    CALL OPF(F.LD.LOANS.AND.DEPOSITS$NAU, FV.LD.LOANS.AND.DEPOSITS$NAU)
RETURN
************************************************************************
INITIALISE:
*----------
    LMM.ID = HANDOFF.REC(3)<1>
    ID = LMM.ID : "00"
    CALL F.READ(F.LMM.ACCOUNT.BALANCES,ID,R.LMM.REC,FV.LMM.ACCOUNT.BALANCES,LMM.ACC.ERR)
    ACCBAL.REC = R.LMM.REC    ;* Main file is account balances

    COB.PROCESSING = (R.SPF.SYSTEM<SPF.OP.MODE> EQ 'B' AND R.TSA.STATUS<TS.TSS.CURRENT.SERVICE>[1,3] EQ 'COB')

    R.RECORD = ''
    NO.OF.DAYS = ""

    PROCESS.DATE = R.DATES(EB.DAT.TODAY)
    PROCESS.JULDATE = R.DATES(EB.DAT.JULIAN.DATE)
    GOSUB READ.CONTRACT.ARRAY

INITIALISE.EXIT:
*---------------
RETURN
************************************************************************

PROCESS.SCH:
*-----------
** Take each schedule and extract the elevant details
    SAVE.APPLN = APPLICATION ;* Save the Application Common value.
    APPLICATION = "LD.LOANS.AND.DEPOSITS" ;* Assign Application as LD as LD.WORKING.DAY routine is called to cycle the Interest due date with BSNSS frequency till Mat.date from LD.BUILD.FUTURE.SCHEDULES routine.
    EXPANDED.DETAILS = ""
    FUTURE.IDX = ""
    INTEREST.AMT = 0
    R.EB.BALANCES = ''
    LD.ID = ''
    LD.ID = ID[1,12]:@FM:'':@FM:'ENQUIRY'
    CALL LD.BUILD.FUTURE.SCHEDULES(LD.ID, R.CONTRACT, ACCBAL.REC, FUTURE.SCHEDULE.DATES, EXPANDED.DETAILS, OTS.BALANCES,R.EB.BALANCES)
    NO.OF.DAYS = DCOUNT(FUTURE.SCHEDULE.DATES<1>,@VM)
    SCH.DATE.DIETER = ""

    Y.STATUS = R.CONTRACT<LD.STATUS>
    FOR FUTURE.IDX = 1 TO NO.OF.DAYS
        SCH.DATE.DIETER = FUTURE.SCHEDULE.DATES<1,FUTURE.IDX>
        SCH.DATE = ""
        CALL JULDATE(SCH.DATE.DIETER, SCH.DATE)
        IF SCH.DATE.DIETER GE PROCESS.DATE THEN
            GOSUB PROCESS.SCH.REST
        END
    NEXT FUTURE.IDX
    APPLICATION = SAVE.APPLN ;*Restore the Application Common Value.

PROCESS.SCH.EXIT:
*----------------
RETURN
*
*************************************************************************
PROCESS.SCH.REST:
*----------------
* Take the  complete details from the future schedule records and
* update as required

    SCHEDULES.REC = RAISE(EXPANDED.DETAILS<FUTURE.IDX>)     ;* Extract the expanded record
    NO.OF.SCHEDS = DCOUNT(SCHEDULES.REC<LD9.SCHED.TYPE>,@VM)
    IF SCHEDULES.REC<LD9.TYPE.I> THEN
        SCH.TYPE = "INT"
        IF R.CONTRACT<LD.STATUS> EQ 'FWD' AND SCH.DATE.DIETER = R.CONTRACT<LD.VALUE.DATE> THEN
            SCH.AMT = -R.CONTRACT<LD.TOT.INTEREST.AMT>
        END ELSE
            SCH.AMT = SCHEDULES.REC<LD9.INTEREST.AMT>
        END
        INTEREST.AMT = SCH.AMT * -1
        HANDOFF.REC(9)<1,-1> = INTEREST.AMT
    END

PROCESS.SCH.REST.EXIT:
*---------------------
RETURN
************************************************************************
READ.CONTRACT.ARRAY:
*------------------

    CONTRACT.NO = ID[1,12]

* Read the unauthorised record online to get the latest version

    R.CONTRACT = ''

    BEGIN CASE

        CASE COB.PROCESSING  ;* Read live record
            READ R.CONTRACT FROM FV.LD.LOANS.AND.DEPOSITS, CONTRACT.NO ELSE
                NULL
            END

        CASE 1 ;* Read NAU file if not found then read live record
            READ R.CONTRACT FROM FV.LD.LOANS.AND.DEPOSITS$NAU, CONTRACT.NO ELSE
                READ R.CONTRACT FROM FV.LD.LOANS.AND.DEPOSITS, CONTRACT.NO ELSE
                    NULL
                END
            END

    END CASE

READ.CONTRACT.ARRAY.EXIT:
*------------------------
RETURN

END

*************************************************************************
