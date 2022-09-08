* @ValidationCode : Mjo2NzQ5MTM5Nzk6Q3AxMjUyOjE0ODcwNjI1MzI0MTg6cHVuaXRoa3VtYXI6MjowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDEuMDoxOTM6MTM5
* @ValidationInfo : Timestamp         : 14 Feb 2017 14:25:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : punithkumar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 139/193 (72.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201701.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>372</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank
    SUBROUTINE GET.CATEG.OPEN.BALANCE(YOPERAND,YCATEGORY,YSTART.DATE,YEND.DATE,OPEN.BALANCE.LCY)

** Routine that calculates open balance from CONSOLIDATE.PRFT.LOSS instead of looping through the list
** of entries to calculate the open balances. This is called from the routine E.CATEG.ENT.BY.CONCAT.
** This is used to calculate balances only when queried for the current month or the previous month.
** The BALANCE.YTD value from the CPL is used. For current month add the amount from the current month's
** start date till the queried date to CPL YTD balance to get the open balance. For previous month,
** subtract the entries total for the queried date from the CPL YTD balance to get the open balance.
** In Arguments:
** ============
** YOPERAND      : Operand used in the enquiry
** YCATEGORY      : Category for which the query is run
** YSTART.DATE<1>    : Start date with which the entries needs to be selected
**         In case of CM, Current month's start date and for PM (previous month), the queried date
** YSTART.DATE<2>    : Current or previous month marker
** YEND.DATE         : End date with which entries needs to be selected
**         In case of CM it is the queried date and for PM it is the Previous month's end date
** Out Argument:
** ============
** OPEN.BALANCE.LCY  : Calculated Open balance for the category
*****************************************************************************************************
** Modification History:
** =====================
** 20/08/2015 - Defect 1429976 / Task 1456919
**  			Creation of the routine. Enquiry CATEG.ENT.BOOK times out due to a large number of entries
**
** 11/01/16 - Defect 1538490|Task 1592374
**  		  Open balance is not fetched properly in ACU/DBU set up
**
** 28/01/17 - Defect 1983224 / Task 2001215
**            while launching the enquiry if today's date is start of the month then add the fields BALANCE and
**            CREDIT/DEBIT MVMT to BALANCE.YTD to get the correct balance
*****************************************************************************************************

    $USING EB.SystemTables
    $USING RE.Consolidation
    $USING RE.Config
    $USING AC.EntryCreation
    $USING EB.DataAccess
    $USING EB.Service
    $USING EB.Utility
    $USING ST.CompanyCreation
    $INSERT I_DAS.CONSOLIDATE.PRFT.LOSS

    GOSUB INITIALISE
    GOSUB BUILD.CPL.LIST
    GOSUB CALCULATE.CPL.YTD
    GOSUB CALCULATE.ENTRY.BALANCE
    GOSUB CALCULATE.ACTUAL.OPEN.BALANCE

    RETURN

*****************************************************************************************************
INITIALISE:
**********
    YCPL.BAL.YTD = ''
    CPL.LIST = ''
    CPL.KEY.TO.BE.PROCESSED = ''
    OPEN.BALANCE.LCY = ''
    YENTRY.BALANCE = ''

    YMONTH = YSTART.DATE<2>   ;* Current or previous month marker
    YSTART.DATE = YSTART.DATE<1>        ;* Start date

** The date with which the enquiry is run is required to check whether the queried date's
** balances are to be included under open balance or not that is incase of operands like GE and GT

    IF YMONTH EQ 'CM' THEN    ;* In case of Current month the queried date is the end date
        QUERY.DATE = YEND.DATE
    END ELSE
        QUERY.DATE = YSTART.DATE        ;* In case of previous month the queried date is the start date
    END

    Y.PL.PREFIXES.LIST = ''
    RE.Config.GetPlGaapType (Y.PL.PREFIXES.LIST,'')

    R.CONSOLIDATE.COND = RE.Config.ConsolidateCond.Read('PROFIT&LOSS', COND.ERR)

    FN.CATEG.ENTRY = 'F.CATEG.ENTRY'
    F.CATEG.ENTRY = ''
    EB.DataAccess.Opf(FN.CATEG.ENTRY,F.CATEG.ENTRY)

    GOSUB GET.COND.CATEGORY.POSITION

    RETURN

*****************************************************************************************************
GET.COND.CATEGORY.POSITION:
***************************
** Get the position in which the PL.CATEGORY is mapped in CONSOLIDATE.COND in order to select the
** CPL keys for that particular category for which the enquiry is run.

    COND.FILE.NAME = R.CONSOLIDATE.COND<RE.Config.ConsolidateCond.ConFieldName>
    LOCATE 'PL.CATEGORY' IN COND.FILE.NAME<1,1> SETTING CATEGORY.POS ELSE
    RETURN
    END
    CATEGORY.POS = CATEGORY.POS + 1     ;* As PL is a mandatory component in the Key

    RETURN

*****************************************************************************************************
BUILD.CPL.LIST:
***************
    THE.ARGS = ''
    THE.LIST = EB.DataAccess.DasAllIds
    EB.DataAccess.Das('CONSOLIDATE.PRFT.LOSS',THE.LIST,THE.ARGS,'')  ;* Select all the CPL keys

    LOOP
        REMOVE CPL.ID FROM THE.LIST SETTING CPL.SEL.POS
    WHILE CPL.ID:CPL.SEL.POS

        CPL.CATEGORY = FIELD(CPL.ID,'.',CATEGORY.POS,1)     ;* Get the CATEGORY value from the CPL
        CPL.COMPANY = FIELD(CPL.ID,'.',14,1)	;* The co code is updated as the 14th parameter in the CPL


        ** Incase of multi book the key for the company for which the enquiry is run is to be selected
        IF EB.SystemTables.getCMultiBook() THEN
            IF CPL.CATEGORY EQ YCATEGORY AND CPL.COMPANY EQ EB.SystemTables.getIdCompany() THEN
                CPL.KEY.TO.BE.PROCESSED = 1
            END
        END ELSE
            IF CPL.CATEGORY EQ YCATEGORY THEN     ;* Check if the key has the same category as the one in the enquiry
                CPL.KEY.TO.BE.PROCESSED = 1
            END
        END
        IF CPL.KEY.TO.BE.PROCESSED THEN
            CPL.LIST<-1> = CPL.ID
            CPL.KEY.TO.BE.PROCESSED = ''
        END
    REPEAT
    RETURN

*****************************************************************************************************
CALCULATE.CPL.YTD:
*****************
** For all the selected CPL sum up the BALANCE.YTD field values of all the currencies to get the balance
** until the previous month end

*when the enquiry is launched on the first of a month(working day), since balance and the credit movement would have still not moved to BALANCE.YTD
*(which gets moved after Month first working day cob). so add the balance and movements with BALANCE.YTD to get correct YCPL.BAL.YTD
*The possibility of launching the enquiry during cob with and without the EOD.UPDATE.PL.YTD job being run has to be handled as well
    ADD.FLAG = "" ;*Flag to indicate whether balances are not merged still
    PRESENT.MONTH  = EB.SystemTables.getToday()[5,2]
    PREVIOUS.MONTH = EB.SystemTables.getRDates(EB.Utility.Dates.DatLastWorkingDay)[5,2]
    BEGIN CASE

        CASE (EB.SystemTables.getRDates(EB.Utility.Dates.DatCoBatchStatus) EQ 'B')
            ID.DATE = EB.SystemTables.getIdCompany():"-COB"   
            R.COB.DATE = EB.Utility.Dates.CacheRead(ID.DATE, '')         ;*take the company-COB date record to check for Start of month
            PRESENT.MNTH  = R.COB.DATE<EB.Utility.Dates.DatToday>[5,2]
            PREVIOUS.MNTH = R.COB.DATE<EB.Utility.Dates.DatLastWorkingDay>[5,2]

            IF PRESENT.MNTH NE PREVIOUS.MNTH THEN
                BATCH.ID = 'SYSTEM.END.OF.DAY1'
                BATCH.REC = ''
                READ.ERR = ''
                BATCH.REC = EB.Service.Batch.Read(BATCH.ID, READ.ERR)

                IF READ.ERR THEN    ;* Read the batch record For multi company whose BATCH.ID will be prefixed by co code
                    READ.ERR = ''
                    BATCH.ID = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialMne):"/":BATCH.ID
                    BATCH.REC = EB.Service.Batch.Read(BATCH.ID, READ.ERR)
                END

                JOB.ID = 'EOD.UPDATE.PL.YTD'
                JOB.FOUND = ''
                LOCATE JOB.ID IN BATCH.REC<EB.Service.Batch.BatJobName,1> SETTING JOB.FOUND THEN
                IF BATCH.REC<EB.Service.Batch.BatJobStatus,JOB.FOUND> NE '2' THEN
                    ADD.FLAG = 1 ;*still BALANCE.YTD is not updated
                END ELSE
                    ADD.FLAG = ""
                END
            END
        END

    CASE (EB.SystemTables.getRDates(EB.Utility.Dates.DatCoBatchStatus) EQ "O") AND (PRESENT.MONTH NE PREVIOUS.MONTH);*enquiry launched on first month working day online
        ADD.FLAG = 1

    CASE 1
        ADD.FLAG = ""

    END CASE

    LOOP
        REMOVE CPL.KEY FROM CPL.LIST SETTING CPL.POS
    WHILE CPL.KEY:CPL.POS
        R.CONSOL.PRFT.LOSS = RE.Consolidation.ConsolidatePrftLoss.Read(CPL.KEY, CPL.ERR)

        IF NOT(CPL.ERR) THEN

            TOT.CURR.CNT = DCOUNT(R.CONSOL.PRFT.LOSS<RE.Consolidation.ConsolidatePrftLoss.PtlCurrency>,@VM)
            FOR CURR.CNT = 1 TO TOT.CURR.CNT
                YCPL.BAL.YTD += R.CONSOL.PRFT.LOSS<RE.Consolidation.ConsolidatePrftLoss.PtlBalanceYtd,CURR.CNT>
                IF ADD.FLAG THEN ;*If BALANCES are still not merged
                    BALANCE = R.CONSOL.PRFT.LOSS<RE.Consolidation.ConsolidatePrftLoss.PtlBalance,CURR.CNT>
                    CR.MVMT = R.CONSOL.PRFT.LOSS<RE.Consolidation.ConsolidatePrftLoss.PtlCreditMovement,CURR.CNT>
                    DB.MVMT = R.CONSOL.PRFT.LOSS<RE.Consolidation.ConsolidatePrftLoss.PtlDebitMovement,CURR.CNT>
                    YCPL.BAL.YTD += BALANCE + CR.MVMT + DB.MVMT
                END
            NEXT CURR.CNT

        END
    REPEAT
    RETURN

*****************************************************************************************************
CALCULATE.ENTRY.BALANCE:
************************
** Calculates entry balances to be either added or subtracted from the CPL YTD balance depending on whether
** the enquiry is run for the current or the previous month.

** For instance, TODAY is 20150820. The balance in CPL YTD will be till 20150731. If the enquiry is run for
** 20150803(current month) then it is required that the balances for the entries from 20150801 to 20150803
** are to be included. Hence the START.DATE will be the month start date and the END date will be the query date
** to be sent to GET.CATEG.MONTH.ENTRIES.

** Incase the enquiry is run with the date 20150727 (previous month) then it is required that the balances for the
** entries from 20150727 to 20150731 be subtracted from the CPL YTD balance to get the open balance.
** Hence the START.DATE will be the query date and the END.DATE will be the previous month's month end date.

    AC.EntryCreation.GetCategMonthEntries(YSTART.DATE,YEND.DATE,YCATEGORY,YCATEG.ENTRY.LIST)

    IF QUERY.DATE GT EB.SystemTables.getToday() THEN         ;* If the query is run for GT TODAY today's entries need to be processed
        GOSUB GET.TODAYS.ENTRIES
        YCATEG.ENTRY.LIST<-1> = YR.ENTRY.FILE
    END

    LOOP
        REMOVE YCATEG.ENTRY.ID FROM YCATEG.ENTRY.LIST SETTING CATEG.ENT.POS
    WHILE YCATEG.ENTRY.ID:CATEG.ENT.POS

        GOSUB READ.CATEG.ENTRY

        IF R.CATEG.REC<AC.EntryCreation.CategEntry.CatCompanyCode> EQ EB.SystemTables.getIdCompany() THEN        ;* Select entries only for ID.COMPANY

            IF YOPERAND MATCHES 1:@VM:2:@VM:9 THEN

                ** For EQ,RG and GE where the start date entries' balance should not be included in open balance
                ** In case of current month, we do not add up the entries with query date and hence should not be included
                ** In case of previous month, the entries = query date need to be subtracted from the CPL YTD and hence included

                BEGIN CASE

                    CASE YMONTH EQ 'CM'
                        IF BOOKING.DATE LT QUERY.DATE THEN      ;* Ensure the entries belonging to the query date is nt included
                            YENTRY.BALANCE += R.CATEG.REC<AC.EntryCreation.CategEntry.CatAmountLcy>        ;* QUERY.DATE is the end date here
                        END ELSE
                            Y.END = 'END'
                        END

                    CASE YMONTH EQ 'PM'
                        IF BOOKING.DATE GE QUERY.DATE THEN      ;* Ensure the entries belonging to query date are included to be subtracted
                            YENTRY.BALANCE += R.CATEG.REC<AC.EntryCreation.CategEntry.CatAmountLcy>        ;* QUERY.DATE is the start date here
                        END ELSE
                            Y.END = 'END'
                        END
                END CASE

            END ELSE

                ** For GT where the start date balance needs to be included in open balance
                ** In case of current month, we add up the entries with query date and hence should be included
                ** In case of previous month, the entries = query date need not be subtracted from the CPL YTD and hence not included

                BEGIN CASE

                    CASE YMONTH EQ 'CM'
                        IF BOOKING.DATE LE QUERY.DATE THEN      ;* Ensure the entries belonging to query date are included to be subtracted
                            YENTRY.BALANCE += R.CATEG.REC<AC.EntryCreation.CategEntry.CatAmountLcy>
                        END ELSE
                            Y.END = 'END'
                        END

                    CASE YMONTH EQ 'PM'
                        IF BOOKING.DATE GT QUERY.DATE THEN      ;* Ensure the entries belonging to the query date is n0t included
                            YENTRY.BALANCE += R.CATEG.REC<AC.EntryCreation.CategEntry.CatAmountLcy>
                        END ELSE
                            Y.END = 'END'
                        END

                END CASE
            END
        END
    REPEAT
    RETURN

*****************************************************************************************************
READ.CATEG.ENTRY:
*****************

    R.CATEG.REC = ''
    ERR = ''
    R.CATEG.REC = AC.EntryCreation.CategEntry.Read(YCATEG.ENTRY.ID, ERR)
    IF ERR THEN
        R.CATEG.REC = ''
    END

* Retrieve the Position type record.

    POSITION.TYPE = R.CATEG.REC<AC.EntryCreation.CategEntry.CatPositionType>
    LOCATE POSITION.TYPE IN Y.PL.PREFIXES.LIST<1,1> SETTING PL.POS ELSE
    PL.POS = ''
    END
    ENTRY.SYSTEM.ID = R.CATEG.REC<AC.EntryCreation.CategEntry.CatSystemId>
    IF ENTRY.SYSTEM.ID[2] = "BL" AND LEN(ENTRY.SYSTEM.ID) > 2 THEN    ;* Self balancing
        ENTRY.SYSTEM.ID = ENTRY.SYSTEM.ID[1, LEN(ENTRY.SYSTEM.ID)-2]
    END

    BEGIN CASE
        CASE R.CATEG.REC<AC.EntryCreation.CategEntry.CatSuspnseValueDate>   ;* Future processing date real PL entry
            BOOKING.DATE = R.CATEG.REC<AC.EntryCreation.CategEntry.CatSuspnseValueDate>

        CASE ENTRY.SYSTEM.ID MATCHES Y.PL.PREFIXES.LIST<3,PL.POS>         ;* contingent PL
            BOOKING.DATE = R.CATEG.REC<AC.EntryCreation.CategEntry.CatValueDate>

        CASE 1
            BOOKING.DATE = R.CATEG.REC<AC.EntryCreation.CategEntry.CatBookingDate>
    END CASE

    RETURN

*****************************************************************************************************
GET.TODAYS.ENTRIES:
*******************
** Incase of cases where the operand is GT TODAY, then today's entries need to be included in the open
** balance

    Y.CATEG.ENTRY.KEY = "CATEG.TODAY"
    THE.ARGS = YCATEGORY
    AC.EntryCreation.GetCategEntTodayLwork("","",THE.ARGS,Y.CATEG.ENTRY.KEY)
    IF Y.CATEG.ENTRY.KEY <> "" THEN
        IF YR.ENTRY.FILE THEN
            YR.ENTRY.FILE := @FM:Y.CATEG.ENTRY.KEY
        END ELSE
            YR.ENTRY.FILE = Y.CATEG.ENTRY.KEY
        END
    END
    RETURN

*****************************************************************************************************
CALCULATE.ACTUAL.OPEN.BALANCE:
******************************
** Calculates the actual open balance for the category by summing up the CPL YTD balance and the entries
** balances in case of current month and by subtracting the entry balance from the YTD CPL balance.

    BEGIN CASE

        CASE YMONTH EQ 'CM'
            OPEN.BALANCE.LCY = YCPL.BAL.YTD + YENTRY.BALANCE

        CASE YMONTH EQ 'PM'
            OPEN.BALANCE.LCY = YCPL.BAL.YTD - YENTRY.BALANCE

    END CASE

    RETURN

*****************************************************************************************************
    END
