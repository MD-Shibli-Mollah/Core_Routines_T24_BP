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
* <Rating>-56</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.CHG.TO.NOS
*-----------------------------------------------------------------------------

* Attached to the enquiry INACTIVE.ACCTS.
* This Routine is used to populate the O.DATA variable with the difference of
* months between the system date and our date(ie the latest transaction date).

*-----------------------------------------------------------------------------
* Modification History:
* 16/09/08 - BG_100019949
*            Routine restructured
* 02/02/2009 - BG_100021826.
*              Latest Txn Date should also get cycled with Inactive Month specified in the Company
*              If the Number of months is greater than 99,then the Actual no of months is stored before CFQ.
* 27/03/2009 - BG_10022947
*              Null value check changed
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.API

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN

*-----------------------------------------------------------------------------
INITIALISE:
*-----------------------------------------------------------------------------
* Initialise the variables

    ENQ.DATE = ''
    ENQ.ACT.DATE = ''
    OUR.COMI = ''
    SAVE.COMI = ''
    CALC.DATE = ''
    NO.OF.MONTH = ''
    APPROX.MONTH = ''
    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
* If the latest transanction date is not present then the next date from the account
* opening balance date is found USING the function CFQ

* Dates are taken from O.DATA
    tmpODATA = EB.Reports.getOData()
    ENQ.DATE = FIELD(tmpODATA,"*",1)

* If no date is present before *,then find the next date using CFQ

    IF NOT(ENQ.DATE) THEN
        ENQ.DATE = FIELD(tmpODATA,"*",2)
    END   ;*BG_100021826 S/E

    ENQ.DATE = TRIM(ENQ.DATE,"","D")
    ENQ.ACT.DATE = ENQ.DATE[7,2]

    SYS.DATE = EB.SystemTables.getToday()
    IF ENQ.DATE LT SYS.DATE  THEN       ;*BG_100021826 S

        GOSUB CALCULATE.DIFFERENCE

        * If there is difference then the approximate difference of months is added
        * in the date format and the next date is found

        OUR.COMI = ENQ.DATE:"M":NO.OF.MONTH:ENQ.ACT.DATE
        SAVE.COMI = EB.SystemTables.getComi()
        EB.SystemTables.setComi(OUR.COMI)

        EB.API.Cfq()

        OUR.COMI = EB.SystemTables.getComi()
        EB.SystemTables.setComi(SAVE.COMI)

        CALC.DATE = OUR.COMI[1,8]

        * If the system date is greater than our date then the difference of months is
        * given to O.DATA,Otherwise the month is decremented by 1

        IF SYS.DATE GE CALC.DATE THEN
            *BG_100021826/S - use Actual no. of months for display

            EB.Reports.setOData(ACTUAL.NO.OF.MONTH)
            *BG_100021826/E
        END ELSE
            *BG_100021826/S - use Actual no. of months for display
            ACTUAL.NO.OF.MONTH -= 1
            EB.Reports.setOData(ACTUAL.NO.OF.MONTH)
            *BG_100021826/E
        END
    END ELSE        ;*BG_100021826 E
        EB.Reports.setOData('')
    END
    RETURN

*-----------------------------------------------------------------------------
CALCULATE.DIFFERENCE:
*-----------------------------------------------------------------------------

*  Difference in system date and our date is found using CDD

    NO.OF.DAYS = "C"
    EB.API.Cdd('',ENQ.DATE,SYS.DATE,NO.OF.DAYS)
    APPROX.MONTH = NO.OF.DAYS / 30
    NO.OF.MONTH = FIELD(APPROX.MONTH,".",1)

*BG_100021826/S - Actual no. of months stored for display in the ENQUIRY
    ACTUAL.NO.OF.MONTH = NO.OF.MONTH
    IF NO.OF.MONTH GT 99 THEN
        NO.OF.MONTH = 99
    END
*BG_100021826/E
    NO.OF.MONTH = FMT(NO.OF.MONTH,"2'0'R")
    RETURN
    END
*-----------------------------------------------------------------------------
