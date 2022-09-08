* @ValidationCode : MjotNzQ2Njg1MTc1OkNwMTI1MjoxNjAxOTEzMzMyNzgxOmthamFheXNoZXJlZW46NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMC4yMDIwMDkxOS0wNDU5OjkwODozMTA=
* @ValidationInfo : Timestamp         : 05 Oct 2020 21:25:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kajaayshereen
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 310/908 (34.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 12 15/05/01  GLOBUS Release No. G13.2.00 03/03/03
*-----------------------------------------------------------------------------
* <Rating>4714</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.CATEG.ENT.BY.CONCAT(Y.ID.LIST)
*
* 03/03/92 - HY9200669
*            Replace READLIST with call to EB.READLIST
*
* 28/07/92 - GB9200733
*            Value dated accounting - include FWD value dated entries
*            for cash flow
*            Open new file F.CATEG.ENT.FWD
*            Read and add to list in READ.FWD.IDS
* 24/06/03 - EN_10001880
*            Multi.book processing. New files have been created to replace
*            CATEG.ENT.MONTH, namely CATEG.ENT.ACTIVITY and CATEG.ENT.MONTH.
*
*            CATEG.ENT.ACTIVITY is keyed on CATEGORY.YYYYMMDD.COMPANY.THREAD.SEQUENCE
*            and holds the list of categ ids
*            CATEG.ENT.MONTH is keyed on CATEGORY.YYYYMM.COMPANY, it holds the
*            list of days of activity in DAY.NO and the associated multi-valued
*            filed THREAD holds the list of sessions for each day
*
*            New routine GET.CATEG.MONTH.ENTRIES has been built to fetch the
*            list of categ ids from CATEG.MONTH and  CATEG.ENT.ACTIVITY for
*            a given CATEGORY and period.
*
*            If no start date is specified for the enquiry, the start
*            date is hard-coded to '19950101'
*            Once we get the list of entries ensure that we are processing
*            for the right company.
*
* 15/10/04 - CI_10023975
*            Select stmt. corrected to avoid crash (GET.TODAYS.ENTRIES para)
*
* 03/02/05 - CI_10026960
*            CATE.ENT.BOOK enquiry gives a wrong result when the LE or LT or EQ
*            Operators are used for the BOOKING.DATE operand.
*
* 01/04/05 - CI_10028822
*            System was changing the year when the month is equal to 12.
*
* 03/05/05 - CI_10029685
*            In CATEG.ENT.BOOK enquiry,when using the GE/GT operator for the
*            BOOKING.DATE, the entries which fall on the dates greater than the
*            given date, but on the SAME MONTH, is not getting displayed.
*            Results for NR operator also fails for some cases.
*
* 28/02/07 - EN_10003231
*            Modified to call DAS to select data.
*
* 01/05/07 - BG_100013739
*            Various DAS related fixes, SAVING AS not being accounted for.
*            Added code to OPEN.BAL.CALC: for HD0706590.
*
* 06/11/07 - CI_10052341
*            Code related to CATEG.ENT.FWD is removed as it is no more in use.
*            FWD entries will also be updated in CATEG.ENT.TODAY.
*
* 03/05/08 - EN_10003635
*            Update to CATEG.ENT.TODAY/LWORK is based on ENT.TODAY.UPDATE flag in ACCOUNT.PARAMETER.
*            CALL AC.GET.CATEG.ENT.TODAY.LWORK by passing CATEG.ENTRY.LIST with CATEG.TODAY.
*
* 12/09/08 - BG_100019925
*      Bug fixes for ENT.TODAY sar. When appending the list, check if the list is having
*            previously selected entries.
*
* 09/09/09 - CI_10066070
*            In case of netted entries, pick up the original entries from
*            CATEG.ENTRY.DETAIL.
*
* 22/10/09 - CI_10066970
*            Fix compilation error
*
* 12/02/10 - CI_10068881
*            MB.CATEG.ENT.BOOK drill down not working for few operands.
*
* 10/11/10 - Task - 106516(defect-105302)
*            Duplications are happend when set book date with operand GT or GE.
* 07/01/11 - Task - 127257(defect-126431)
*            Duplications are happend when set book date with operand RG.
*
* 21/05/12 - Task 404176
*            System does not display the PL entries when the value date of
*            categ entries falls on the holiday
*
* 27/03/2013 - DEFECT 591326 / TASK 602078
*              Year-end PL closing entries are not displayed in CATEG.ENT.BOOK enquiry.
*
* 10/04/14 - DEFECT 960628 / Task 967838
*            RANGE operand for BOOKING.DATE is not working with CATEG.ENT.BOOK enquiry.
*            It is because there is a check if the month is different, then the last day of the first
*            month alone is considered as END.DATE. This leads to wrong display of data.
*
* 15/07/2014 - DEFECT 1017849 / TASK 1058456
*              Correction for the defect 591326
*
* 25/09/2014 -  DEFECT 1105442 / TASK 1129495
*               Get the list of financial year end and arrive the year end date
*               for the requested start date
*
* 09/02/15 - Defect 1242833 / Task 1249352
*            While ACU/DBU is setup, retrieve categ entry records for the accounting companies
*            in addition to the current logged in business unit company.
*
* 23/04/15 - Defect 1312596 / Task 1325663
*            Change the sorting of entries from quick sort to using jbase functions splice and sort
*            so that performance is improved since there is no need to traverse through all the entries.
*
* 20/08/15 - Defect 1429976 / Task 1456919
*            Enquiry CATEG.ENT.BOOK times out due to a large number of entries
*
* 11/01/16 - Defect 1538490|Task 1592374
*             Open balance is not fetched properly in ACU/DBU set up
*
* 11/05/15 - Defect 2080495 / Task 2119129
*            Year end close out entries raised for PC is not included in the opening balance
*
* 20/02/18 - Defect 2461781 / Task 2467306
*            when BATCH and BRANCH holiday table is differenct and if any entry present with day Where it is holiday in BRANCH and working in BATCH
*            the system should consider even that entry while calculating open balance, so we need to send correct end date to the GET.CATEG.OPEN.BALANCES.
*
* 19/06/20 - Defect 3792405 / Task 3809737
*            The enquiry CATEG.ENT.BOOK populates - NO ENTRIES FOR PERIOD message  incorrectly.
*            The above message must be populated only when there are no entries in all the (Accounting) Companies.
*
* 01/10/20 - Defect 3995468 / Task 4005580
*            Booking date is validated before calling cdt, so that enquiry
*            won't fatalout when invalid date is passed.
*
****************************************************************************

    $USING AC.EntryCreation
    $USING ST.CompanyCreation
    $USING RE.Config
    $USING EB.DataAccess
    $USING EB.API
    $USING AC.ModelBank
    $USING RE.YearEnd
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.Utility
    $INSERT I_DAS.CATEGORY
    $INSERT I_DAS.CATEG.ENT.TODAY
*-----------------------------------------------------------------------
MAIN.PARA:
*=========
*
* Find the position of CATEGORY and BOOKING.DATE
*
    LOCATE "CATEGORY" IN EB.Reports.getDFields()<1> SETTING YCATEGORY.POS ELSE
        RETURN
    END
    LOCATE "BOOKING.DATE" IN EB.Reports.getDFields()<1> SETTING YDATE.POS ELSE
        RETURN
    END
*
    IF EB.Reports.getDLogicalOperands()<YDATE.POS> = '' OR EB.Reports.getDRangeAndValue()<YDATE.POS> = "" OR EB.Reports.getDRangeAndValue()<YDATE.POS> = "ALL" THEN
        RETURN
    END
*   If ACU/DBU setup, add Companies to list so that they can be used to get categ entries
    COMPANY.LIST = EB.SystemTables.getIdCompany()
    IF EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComAccountingCompany) THEN
        ACC.COMP.CNT = DCOUNT(EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComAccountingCompany), @VM)
        FOR ACC.COMP.POS = 1 TO ACC.COMP.CNT
            COMPANY.LIST<-1> = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComAccountingCompany)<1,ACC.COMP.POS>
        NEXT ACC.COMP.POS
    END
    COMPANY.ID.COUNT = DCOUNT(COMPANY.LIST, @FM)
    BOOK.DATES = ''
    GOSUB LIST.ACCT.NOS

    Y.PL.PREFIXES.LIST = ''
    RE.Config.GetPlGaapType (Y.PL.PREFIXES.LIST,'')

*
* Sort the dates into order
*
    YOPERAND = EB.Reports.getDLogicalOperands()<YDATE.POS>
    YENQ.LIST.COPY = EB.Reports.getDRangeAndValue()<YDATE.POS>
    YENQ.LIST = ""
    ENQ.ERROR = ''
    DATE.TO.VAL = ''
    LOOP
        REMOVE YVALUE FROM YENQ.LIST.COPY SETTING YCODE
    UNTIL YVALUE = ''
        LOCATE YVALUE IN YENQ.LIST<1,1> BY 'AR' SETTING YPOS ELSE
            NULL
        END
        DATE.TO.VAL = YVALUE
        GOSUB VALIDATE.DATE
        INS YVALUE BEFORE YENQ.LIST<1,YPOS>
    REPEAT
    Y.CONCAT.REC = ""

    IF ENQ.ERROR THEN
        EB.Reports.setEnqError(ENQ.ERROR)
        RETURN
    END

* Read the PL.CLOSE.DATES to get the list of financial year end dates
    PL.CLOSE.DATES.ID = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialCom) ;* read the dates for lead company
    R.PL.CLOSE.DATES = ''
    YERR = ''
    R.PL.CLOSE.DATES = RE.YearEnd.PlCloseDates.CacheRead(PL.CLOSE.DATES.ID, YERR)

    Startdate = YENQ.LIST<1,1>

    LOCATE Startdate:'CL' IN R.PL.CLOSE.DATES<1> BY "AR" SETTING PL.CLOSE.DATES.POS THEN
    END

    YFIRST.DAY.YEAR = R.PL.CLOSE.DATES<PL.CLOSE.DATES.POS - 1>[1,8] ;* Get the previouse financial year end for the requested date

    FOUND.IN.PL.CLOSE.DATES = 0
    IF NOT(YFIRST.DAY.YEAR) THEN
* Not found in the PL.CLOSE.DATES
        YFIRST.DAY.YEAR = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLastYearEnd)
    END ELSE
* Found the financial year end date
        FOUND.IN.PL.CLOSE.DATES = 1
    END

*
* Store the local region EB8900271
*
    YLOCAL.REGION = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry)
    IF YLOCAL.REGION = "" THEN
        YLOCAL.REGION = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalRegion)
    END ELSE
        YLOCAL.REGION := "00"
    END

    EB.API.Cdt(YLOCAL.REGION,YFIRST.DAY.YEAR,"+1C") ;* Get the First calender day for the requested financial year

    SAVE.YFIRST.DAY.YEAR = ""
    SAVE.YFIRST.DAY.YEAR = YFIRST.DAY.YEAR

*
* EB8901371. If the first date is in a prior year, then the first day
* of this year must be found.
*
    IF NOT(FOUND.IN.PL.CLOSE.DATES) THEN
* if financial year end date is not found then go with the old process
        LOOP
        UNTIL YENQ.LIST<1,1> GE YFIRST.DAY.YEAR
            IF (MOD(YFIRST.DAY.YEAR[3,2],4) = 0 AND YFIRST.DAY.YEAR[5,4] GT "0229") OR (MOD(YFIRST.DAY.YEAR[3,2],4) = 1 AND YFIRST.DAY.YEAR[5,4] LE "0229") THEN
                NO.DAYS = "-366C"
            END ELSE
                NO.DAYS = "-365C"
            END
            EB.API.Cdt(YLOCAL.REGION,YFIRST.DAY.YEAR,NO.DAYS)
        REPEAT
*
    END
    YSTART.MONTH = YFIRST.DAY.YEAR[5,2]
    YTHIS.YEAR.MONTH = EB.SystemTables.getToday()[1,6]
*
* Find last working day
*
    YLWORK.DAY = EB.SystemTables.getToday()
    EB.API.Cdt(YLOCAL.REGION,YLWORK.DAY,"-1W")
    YOPERAND = EB.Reports.getDLogicalOperands()<YDATE.POS>
    LOOP
        Y.CAT.NO = YCATEG.LIST<1>
    UNTIL Y.CAT.NO = "" DO
        DEL YCATEG.LIST<1>
        YOPEN.BAL = 0 ;* Initialisation moved here, to calculate total open bal
        ENTRY.FOUND = 0

        IF EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComAccountingCompany) THEN
            GOSUB BUILD.DATA
        END ELSE
            GOSUB GET.OPEN.BAL
            GOSUB BUILD.CONCAT.LIST
        END
    REPEAT
*
    Y.ID.LIST = Y.CONCAT.REC
RETURN
*
*-------------------------------------------------------------------------
*
BUILD.DATA:
***********
    SAVE.ID.COMPANY = EB.SystemTables.getIdCompany() ;* Save id of current logged in company
    SAVE.OPEN.BAL = ''  ;* Initialise a variable to save open balance of each accouting company
* If ACU/DBU setup, iterate through company list to get opening balance
* and then iterate again to get categ entries
* For a single looping, opening balance is not shown correctly in screen
    FOR COMP.ID.POS = 1 TO COMPANY.ID.COUNT
        ENTRY.COMPANY = COMPANY.LIST<COMP.ID.POS>
        GOSUB LOAD.REQD.COMPANY
* Business unit with accounting companies will not have entries, so
* it results in first record that shows No records
* Skip the check if it is business unit
        IF EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComAccountingCompany) ELSE
            GOSUB GET.OPEN.BAL
            IF CPL.START.DATE OR CPL.END.DATE THEN      ;* Only if GET.CATEG.OPEN.BALANCE is called the open balance needs to be saved
                SAVE.OPEN.BAL += YOPEN.BAL                              ;* For the entry wise selection, YOPEN.BAL remains the same and initialised in the main para
            END
        END
    NEXT COMP.ID.POS
    IF CPL.START.DATE OR CPL.END.DATE THEN      ;* Reassign the saved balance to YOPEN.BAL variable for opening balance
        YOPEN.BAL = SAVE.OPEN.BAL
    END
* Iterate to build the entry list
    
    FOR COMP.ID.POS = 1 TO COMPANY.ID.COUNT
        ENTRY.COMPANY = COMPANY.LIST<COMP.ID.POS>
        GOSUB LOAD.REQD.COMPANY
        IF EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComAccountingCompany) ELSE
            GOSUB BUILD.CONCAT.LIST
        END
    NEXT COMP.ID.POS
* Load the saved company
    ENTRY.COMPANY = SAVE.ID.COMPANY
    GOSUB LOAD.REQD.COMPANY
* Sort the entries from accounting companies by booking date since they are
* sorted only for each company and listed at this point
    GOSUB SORT.ENT.BY.BOOK.DATE

RETURN
*
*-------------------------------------------
LOAD.REQD.COMPANY:
*****************
    IF ENTRY.COMPANY AND ENTRY.COMPANY NE EB.SystemTables.getIdCompany() THEN
        ST.CompanyCreation.LoadCompany(ENTRY.COMPANY)
    END
RETURN
*
*------------------------------------------------------------------------
*
LIST.ACCT.NOS:
*=============
    YCATEG.LIST = ""
    YOPERAND = EB.Reports.getDLogicalOperands()<YCATEGORY.POS>
    YENQ.LIST = EB.Reports.getDRangeAndValue()<YCATEGORY.POS>
*
    IF YOPERAND = 1 AND YENQ.LIST <> "ALL" THEN
        YCATEG.LIST = YENQ.LIST
        CONVERT @SM TO @FM IN YCATEG.LIST
        RETURN
    END
*
    CATEG.ID.LIST = dasCategoryIdGtLtById
    THE.ARGS = '49999' : @FM : '70000'
    TABLE.SUFFIX = ''
    EB.DataAccess.Das ('CATEGORY',CATEG.ID.LIST, THE.ARGS,TABLE.SUFFIX)
*
    ON YOPERAND GOSUB MATCH.EQUAL,
    MATCH.RANGE,
    MATCH.LESS.THAN,
    MATCH.GREATER.THAN,
    MATCH.NOT,
    MATCH.LIKE,
    MATCH.UNLIKE,
    MATCH.LE,
    MATCH.GE,
    MATCH.NR
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.EQUAL:
*===========
*
* For ALL Accounts
*
    YCATEG.LIST = CATEG.ID.LIST
RETURN
*
MATCH.RANGE:
*===========
    Y.END = ""
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" OR Y.END = "END" DO
        DEL CATEG.ID.LIST<1>
        IF YCAT >= YENQ.LIST<1,1,1> AND YCAT <= YENQ.LIST<1,1,2> THEN
***!            YCATEG.LIST<-1> = YCAT
            IF YCATEG.LIST THEN
                YCATEG.LIST := @FM:YCAT
            END ELSE
                YCATEG.LIST = YCAT
            END
        END ELSE
            IF YCAT > YENQ.LIST<1,2> THEN
                Y.END = "END"
            END
        END
    REPEAT
RETURN
*
MATCH.LESS.THAN:
*===============
    Y.END = ""
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" OR Y.END = "END" DO
        DEL CATEG.ID.LIST<1>
        IF YCAT < YENQ.LIST<1,1> THEN
***!            YCATEG.LIST<-1> = YCAT
            IF YCATEG.LIST THEN
                YCATEG.LIST := @FM:YCAT
            END ELSE
                YCATEG.LIST = YCAT
            END
        END ELSE
            Y.END = "END"
        END
    REPEAT
RETURN
*
MATCH.GREATER.THAN:
*==================
    Y.END = ""
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" OR Y.END = "END" DO
        IF YCAT > YENQ.LIST<1,1> THEN
            YCATEG.LIST = CATEG.ID.LIST
            Y.END = "END"
        END ELSE
            DEL CATEG.ID.LIST<1>
        END
    REPEAT
RETURN
*
MATCH.NOT:
*=========
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" DO
        LOCATE YCAT IN YENQ.LIST<1,1> SETTING YAC.LOC ELSE
***!            YCATEG.LIST<-1> = YCAT
            IF YCATEG.LIST THEN
                YCATEG.LIST := @FM:YCAT
            END ELSE
                YCATEG.LIST = YCAT
            END
        END
        DEL CATEG.ID.LIST<1>
    REPEAT
RETURN
*
MATCH.LIKE:
*==========
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" DO
        IF INDEX(YCAT,YENQ.LIST<1,1>,1) > 0 THEN
***!            YCATEG.LIST<-1> = YCAT
            IF YCATEG.LIST THEN
                YCATEG.LIST := @FM:YCAT
            END ELSE
                YCATEG.LIST = YCAT
            END
        END
        DEL CATEG.ID.LIST<1>
    REPEAT
RETURN
*
MATCH.UNLIKE:
*============
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" DO
        IF INDEX(YCAT,YENQ.LIST<1,1>,1) = 0 THEN
***!            YCATEG.LIST<-1> = YCAT
            IF YCATEG.LIST THEN
                YCATEG.LIST := @FM:YCAT
            END ELSE
                YCATEG.LIST = YCAT
            END
        END
        DEL CATEG.ID.LIST<1>
    REPEAT
RETURN
*
MATCH.LE:
*========
    Y.END = ""
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" OR Y.END = "END" DO
        DEL CATEG.ID.LIST<1>
        IF YCAT <= YENQ.LIST<1,1> THEN
***!            YCATEG.LIST<-1> = YCAT
            IF YCATEG.LIST THEN
                YCATEG.LIST := @FM:YCAT
            END ELSE
                YCATEG.LIST = YCAT
            END
        END ELSE
            Y.END = "END"
        END
    REPEAT
RETURN
*
MATCH.GE:
*========
    Y.END = ""
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" OR Y.END = "END" DO
        IF YCAT >= YENQ.LIST<1,1> THEN
            YCATEG.LIST = CATEG.ID.LIST
            Y.END = "END"
        END ELSE
            DEL CATEG.ID.LIST<1>
        END
    REPEAT
RETURN
*
MATCH.NR:
*========
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = ""
        DEL CATEG.ID.LIST<1>
        IF YCAT < YENQ.LIST<1,1> AND YCAT > YENQ.LIST<1,2> THEN
***!            YCATEG.LIST<-1> = YCAT
            IF YCATEG.LIST THEN
                YCATEG.LIST := @FM:YCAT
            END ELSE
                YCATEG.LIST = YCAT
            END
        END
    REPEAT
RETURN
*
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
*
MATCH.DATE.EQUAL:
*================
*
* There may be more than 1 date in the list
*
    YENQ.LIST = YENQ.LIST
    Y.END = ''
    LOOP
*
* Get the booking date from the list specified
*
        REMOVE YBOOK.DATE FROM YENQ.LIST SETTING YCODE
    UNTIL YBOOK.DATE = ''
* EN_100001880 S
        FROM.DATE = YBOOK.DATE
        TO.DATE = YBOOK.DATE
* Get list of categ ids from CATEG.MONTH and CATEG.ENT.ACTIVITY
        AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CAT.NO,YR.ENTRY.FILE)

        IF YBOOK.DATE GT YLWORK.DAY THEN
            GOSUB GET.TODAYS.ENTRIES
        END
        GOSUB GET.ENTRIES.EQ
    REPEAT
RETURN
*
*------------------------------------------------------------------------
*
GET.ENTRIES.EQ:
*==============
*
    LOOP
*
* Read in each entry and check the booking date against the chosen date
*
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YTYPE
    UNTIL YENTRY.ID = '' OR Y.END = "END"

        GOSUB READ.CATEG.ENTRY

* Check if we are processing the categ.entry for the right company (Multi-book)
        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> = EB.SystemTables.getIdCompany() THEN

            PROCESS.ENTRY = ''

            BEGIN CASE
                CASE FROM.DATE NE TO.DATE
                    IF BOOKING.DATE GE FROM.DATE AND BOOKING.DATE LE TO.DATE THEN
                        PROCESS.ENTRY = 1
                    END

                CASE 1
                    IF BOOKING.DATE EQ YBOOK.DATE THEN
                        PROCESS.ENTRY = 1
                    END
            END CASE

            IF PROCESS.ENTRY THEN
                GOSUB BUILD.NET.ENTRY.LIST
                IF DETAIL.NOT.FOUND THEN
                    YCAT.DATA = Y.CAT.NO:"*":YENTRY.ID:"*":YOPEN.BAL:"*":"CATEG.ENTRY"
                    GOSUB CONSOLIDATE.BOOKING.DATES ; * Add entry's booking date to list
                    IF Y.CONCAT.REC THEN
                        Y.CONCAT.REC := @FM:YCAT.DATA
                    END ELSE
                        Y.CONCAT.REC = YCAT.DATA
                    END
                    ENTRY.FOUND = 1
                END
            END ELSE
                IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> GT YBOOK.DATE THEN
                    Y.END = "END"
                END
            END
        END
    REPEAT
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.RANGE:
*================
*
    YSTART.DATE = YENQ.LIST<1,1>
    IF YENQ.LIST<1,2> NE '' THEN
        YEND.DATE = YENQ.LIST<1,2>
    END ELSE
        YEND.DATE = YSTART.DATE
    END

    Y.END = ""
* EN_100001880 S
    YR.ENTRY.FILE = ''
    FROM.DATE = YSTART.DATE
    TO.DATE = YEND.DATE
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CAT.NO,YR.ENTRY.FILE)
    IF YEND.DATE GT YLWORK.DAY THEN
        GOSUB GET.TODAYS.ENTRIES
    END
    GOSUB GET.ENTRIES.RG

RETURN
*
GET.ENTRIES.RG:
*==============
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = '' OR Y.END = 'END'

        GOSUB READ.CATEG.ENTRY

* For Multi-book have to ensure we are processing for the right company
        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> = EB.SystemTables.getIdCompany() THEN
            IF BOOKING.DATE GT TO.DATE THEN
                Y.END = 'END'
            END ELSE
                IF BOOKING.DATE GE YSTART.DATE THEN
                    GOSUB BUILD.NET.ENTRY.LIST
                    IF DETAIL.NOT.FOUND THEN
                        YCAT.DATA = Y.CAT.NO:"*":YENTRY.ID:"*":YOPEN.BAL:"*":"CATEG.ENTRY"
                        GOSUB CONSOLIDATE.BOOKING.DATES ; * Add entry's booking date to list
                        IF Y.CONCAT.REC THEN
                            Y.CONCAT.REC := @FM:YCAT.DATA
                        END ELSE
                            Y.CONCAT.REC = YCAT.DATA
                        END
                        ENTRY.FOUND = 1
                    END
                END
            END
        END
    REPEAT
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.LESS.THAN:
*====================
*
    Y.END = ''
    YR.ENTRY.FILE = ''

* EN_100001880 S
* Get the date just before this year month

    YYEAR = YENQ.LIST[1,4]
    YMONTH = YENQ.LIST[5,2]
    YMONTH -= 1
    YMONTH = FMT(YMONTH,"2'0'R")
    IF YMONTH EQ 0 THEN
        YMONTH = FMT(12,"2'0'R")
        YYEAR -= 1
    END


* Take the minimum date that exist for the CATEG.MONTH from 19950101 to previous month
    FROM.DATE = MIN.DATE      ;* MUST CHECK WHICH DATE TO PUT
    TO.DATE = YENQ.LIST

    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CAT.NO,YR.ENTRY.FILE)

* Get todays and forward dated entries
    IF YENQ.LIST<1,1> GT YLWORK.DAY THEN
        GOSUB GET.TODAYS.ENTRIES
    END
    GOSUB GET.ENTRIES.LT

RETURN
*
GET.ENTRIES.LT:
*==============
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = "" OR Y.END = "END"

        GOSUB READ.CATEG.ENTRY

* For Multi-book have to ensure we are processing for the right company
        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> = EB.SystemTables.getIdCompany() THEN
            IF YR.CATEG.ENTRY NE '' THEN
                IF BOOKING.DATE LT YENQ.LIST<1,1> THEN
                    GOSUB BUILD.NET.ENTRY.LIST
                    IF DETAIL.NOT.FOUND THEN
                        YCAT.DATA = Y.CAT.NO:"*":YENTRY.ID:"*":YOPEN.BAL:"*":"CATEG.ENTRY"
                        GOSUB CONSOLIDATE.BOOKING.DATES ; * Add entry's booking date to list
                        IF Y.CONCAT.REC THEN
                            Y.CONCAT.REC := @FM:YCAT.DATA
                        END ELSE
                            Y.CONCAT.REC = YCAT.DATA
                        END
                        ENTRY.FOUND = 1
                    END
                END ELSE
                    Y.END = "END"
                END
            END
        END
    REPEAT
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.NOT:
*==============
*
*
* EN_100001880 E
    Y.END = ''
* Will retrieve all entries
*
* Take from minimum date
    FROM.DATE = MIN.DATE
    TO.DATE = ''
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CAT.NO,YR.ENTRY.FILE)

* Get todays and future entries
    GOSUB GET.TODAYS.ENTRIES

    GOSUB GET.ENTRIES.NOT    ;*Task-127257 to avoid duplicates

RETURN
*
GET.ENTRIES.NOT:
*===============
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ''

        GOSUB READ.CATEG.ENTRY

        IF YR.CATEG.ENTRY THEN

* For Multi-book have to ensure we are processing for the right company
            IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> = EB.SystemTables.getIdCompany() THEN
                START.DATE = YENQ.LIST<1,1>
                END.DATE = YENQ.LIST<1,1>

                EB.API.Cdt('',END.DATE,'+01W')      ;*Get the next working date

                IF END.DATE[5,2] NE START.DATE[5,2] THEN    ;* If the Next working date is not in this month then take the month end as period end date
                    END.DATE = START.DATE[1,6]:'32'
                END
                EB.API.Cdt('',END.DATE,'-01C')

*               Change the condition to OR to correctly pick the entries
*               Since booking date cannot satisfy both conditions at same time
                IF BOOKING.DATE LT START.DATE OR BOOKING.DATE GT END.DATE THEN
                    GOSUB BUILD.NET.ENTRY.LIST
                    IF DETAIL.NOT.FOUND THEN
                        YCAT.DATA = Y.CAT.NO:"*":YENTRY.ID:"*":YOPEN.BAL:"*":"CATEG.ENTRY"
                        GOSUB CONSOLIDATE.BOOKING.DATES ; * Add entry's booking date to list
                        IF Y.CONCAT.REC THEN
                            Y.CONCAT.REC := @FM:YCAT.DATA
                        END ELSE
                            Y.CONCAT.REC = YCAT.DATA
                        END
                        ENTRY.FOUND = 1
                    END
                END
            END
        END
    REPEAT
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.LIKE:
*===============
*
RETURN
*
MATCH.DATE.UNLIKE:
*=================
*
RETURN
*
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
*
MATCH.DATE.LE:
*=============
*

    Y.END = ''
    YR.ENTRY.FILE = ''

* EN_100001880 S
* Get the date just before this year month

    YYEAR = YENQ.LIST[1,4]
    YMONTH = YENQ.LIST[5,2]
    YMONTH -= 1
    YMONTH = FMT(YMONTH,"2'0'R")
    IF YMONTH EQ 0 THEN
        YMONTH = FMT(12,"2'0'R")
        YYEAR -= 1
    END


* Take the minimum date that exist for the CATEG.MONTH from 19950101 to previous month
    FROM.DATE = MIN.DATE      ;* MUST CHECK WHICH DATE TO PUT
    TO.DATE = YENQ.LIST

    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CAT.NO,YR.ENTRY.FILE)

    IF YENQ.LIST<1,1> GT YLWORK.DAY THEN
        GOSUB GET.TODAYS.ENTRIES
    END
    GOSUB GET.ENTRIES.LE
RETURN
*
GET.ENTRIES.LE:
*==============
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = "" OR Y.END = "END"

        GOSUB READ.CATEG.ENTRY

        END.DATE = YENQ.LIST<1,1>

        EB.API.Cdt('',END.DATE,'+01W')    ;*Get the next working date

        IF END.DATE[5,2] NE YENQ.LIST<1,1>[5,2] THEN        ;* If the Next working date is not in this month then take the month end as period end date
            END.DATE = YENQ.LIST<1,1>[1,6]:'32'
        END

        EB.API.Cdt('',END.DATE,'-01C')

        IF YR.CATEG.ENTRY NE '' THEN
* For Multi-book have to ensure we are processing for the right company
            IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> = EB.SystemTables.getIdCompany() THEN
                IF BOOKING.DATE LE END.DATE THEN
                    GOSUB BUILD.NET.ENTRY.LIST
                    IF DETAIL.NOT.FOUND THEN
                        YCAT.DATA = Y.CAT.NO:"*":YENTRY.ID:"*":YOPEN.BAL:"*":"CATEG.ENTRY"
                        GOSUB CONSOLIDATE.BOOKING.DATES ; * Add entry's booking date to list
                        IF Y.CONCAT.REC THEN
                            Y.CONCAT.REC := @FM:YCAT.DATA
                        END ELSE
                            Y.CONCAT.REC = YCAT.DATA
                        END
                        ENTRY.FOUND = 1
                    END
                END ELSE
                    Y.END = "END"
                END
            END
        END
    REPEAT
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.GREATER.THAN:
*=======================
*
    YR.ENTRY.FILE = ''
    YMONTH = YENQ.LIST<1,1>[5,2]
    YYEAR = YENQ.LIST<1,1>[1,4]
* Check for the date input first
    FROM.DATE = YENQ.LIST<1,1>
    TO.DATE = ""
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CAT.NO,YR.ENTRY.FILE)

* Get todays and forward dated entries
    GOSUB GET.TODAYS.ENTRIES
    GOSUB GET.ENTRIES.GT
RETURN
*
GET.ENTRIES.GT:
*==============
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ""

        GOSUB READ.CATEG.ENTRY

* For Multi-book have to ensure we are processing for the right company
        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> = EB.SystemTables.getIdCompany() THEN
            IF BOOKING.DATE GT YENQ.LIST<1,1> THEN
                GOSUB BUILD.NET.ENTRY.LIST
                IF DETAIL.NOT.FOUND THEN
                    YCAT.DATA = Y.CAT.NO:"*":YENTRY.ID:"*":YOPEN.BAL:"*":"CATEG.ENTRY"
                    GOSUB CONSOLIDATE.BOOKING.DATES ; * Add entry's booking date to list
                    IF Y.CONCAT.REC THEN
                        Y.CONCAT.REC := @FM:YCAT.DATA
                    END ELSE
                        Y.CONCAT.REC = YCAT.DATA
                    END
                    ENTRY.FOUND = 1
                END
            END
        END
    REPEAT
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.GE:
*=============
*
    YMONTH = YENQ.LIST<1,1>[5,2]
    YYEAR = YENQ.LIST<1,1>[1,4]
    YR.ENTRY.FILE = ''

* Check for the date input first
    FROM.DATE = YENQ.LIST<1,1>
    TO.DATE = ''
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CAT.NO,YR.ENTRY.FILE)

* Get todays entries and future entries

    GOSUB GET.TODAYS.ENTRIES
    GOSUB GET.ENTRIES.GE
RETURN
*
GET.ENTRIES.GE:
*==============
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ""

        GOSUB READ.CATEG.ENTRY

* For Multi-book have to ensure we are processing for the right company
        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> = EB.SystemTables.getIdCompany() THEN
            IF BOOKING.DATE GE YENQ.LIST<1,1> THEN
                GOSUB BUILD.NET.ENTRY.LIST
                IF DETAIL.NOT.FOUND THEN
                    YCAT.DATA = Y.CAT.NO:"*":YENTRY.ID:"*":YOPEN.BAL:"*":"CATEG.ENTRY"
                    GOSUB CONSOLIDATE.BOOKING.DATES ; * Add entry's booking date to list
                    IF Y.CONCAT.REC THEN
                        Y.CONCAT.REC := @FM:YCAT.DATA
                    END ELSE
                        Y.CONCAT.REC = YCAT.DATA
                    END
                    ENTRY.FOUND = 1
                END
            END
        END
    REPEAT
RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.NR:
*=============
*
    YSTART.DATE = YENQ.LIST<1,1>
    IF YENQ.LIST<1,2> NE '' THEN
        YEND.DATE = YENQ.LIST<1,2>
    END ELSE
        YEND.DATE = YENQ.LIST<1,1>
    END
* Get the entries from the beginning to the year month prior the start (not range)
    Y.END = ''
    YR.ENTRY.FILE = ''

* EN_100001880 S
* Get the date just before this year month
    YYEAR = YSTART.DATE[1,4]
    YMONTH = YSTART.DATE[5,2]
    YMONTH -= 1
    YMONTH = FMT(YMONTH,"2'0'R")
    IF YMONTH EQ 0 THEN
        YMONTH = FMT(12,"2'0'R")
        YYEAR -= 1
    END
* Take the minimum date that exist for the CATEG.MONTH from 19950101 to month prior start date
    FROM.DATE = MIN.DATE      ;* MUST CHECK WHICH DATE TO PUT
    TO.DATE = YYEAR:YMONTH    ;* Previous month this year
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CAT.NO,YR.ENTRY.FILE)
* EN_100001880 E
    GOSUB EXTRACT.ENTRY.IDS

* Get entries for start range month and filter for NR.PRE
    YR.ENTRY.FILE = ''
    Y.END = ''
    FROM.DATE = YSTART.DATE[1,6]
    TO.DATE = YSTART.DATE[1,6]
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CAT.NO,YR.ENTRY.FILE)
    GOSUB GET.ENTRIES.NR.PRE

* Get entries for  end range month and filter for NR.POST
    YR.ENTRY.FILE = ''
    Y.END = ''
    FROM.DATE = YEND.DATE[1,6]
    TO.DATE = YEND.DATE[1,6]
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CAT.NO,YR.ENTRY.FILE)
    GOSUB GET.ENTRIES.NR.POST

* Now get the enries from month after end not range date to this year month

    YR.ENTRY.FILE = ""
    Y.END = ""
    YYEAR = YEND.DATE[1,4]
    YMONTH = YEND.DATE[5,2]

    YMONTH += 1
    YMONTH = FMT(YMONTH,"2'0'R")
    IF YMONTH > 12 THEN
        YMONTH = FMT(1,"2'0'R")
        YYEAR += 1
    END

    FROM.DATE = YYEAR:YMONTH
    TO.DATE = ''
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CAT.NO,YR.ENTRY.FILE)

    IF YEND.DATE LE YLWORK.DAY THEN
        GOSUB GET.TODAYS.ENTRIES
    END

    GOSUB EXTRACT.ENTRY.IDS   ;*Task-127257 to avoid duplicates

RETURN
*----------------------------------------------------------------------------
GET.TODAYS.ENTRIES:
*==================
*
    Y.CATEG.ENTRY.KEY = "CATEG.TODAY"
    THE.ARGS = Y.CAT.NO
    AC.EntryCreation.GetCategEntTodayLwork("","",THE.ARGS,Y.CATEG.ENTRY.KEY)
    IF Y.CATEG.ENTRY.KEY <> "" THEN
        IF YR.ENTRY.FILE THEN
            YR.ENTRY.FILE := @FM:Y.CATEG.ENTRY.KEY
        END ELSE
            YR.ENTRY.FILE = Y.CATEG.ENTRY.KEY
        END
    END
RETURN
*
*----------------------------------------------------------------------------
GET.ENTRIES.NR.PRE:
*==================
*
    Y.END = ''
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = '' OR Y.END = 'END'

        ERR = ''
        YR.CATEG.ENTRY = ''
        YR.CATEG.ENTRY = AC.EntryCreation.CategEntry.Read(YENTRY.ID, ERR)
        IF ERR THEN
            YR.CATEG.ENTRY = ''
        END
        IF YR.CATEG.ENTRY THEN

* For Multi-book have to ensure we are processing for the right company
            IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> = EB.SystemTables.getIdCompany() THEN

                IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> LT YSTART.DATE THEN
                    BOOKING.DATE = YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate>
                    GOSUB BUILD.NET.ENTRY.LIST
                    IF DETAIL.NOT.FOUND THEN
                        YCAT.DATA = Y.CAT.NO:"*":YENTRY.ID:"*":YOPEN.BAL:"*":"CATEG.ENTRY"
                        GOSUB CONSOLIDATE.BOOKING.DATES ; * Add entry's booking date to list
                        IF Y.CONCAT.REC THEN
                            Y.CONCAT.REC := @FM:YCAT.DATA
                        END ELSE
                            Y.CONCAT.REC = YCAT.DATA
                        END
                        ENTRY.FOUND = 1
                    END
                END ELSE
                    Y.END = 'END'
                END
            END

        END
    REPEAT
RETURN
*
GET.ENTRIES.NR.POST:
*===================
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ''

        ERR = ''
        YR.CATEG.ENTRY = ''
        YR.CATEG.ENTRY = AC.EntryCreation.CategEntry.Read(YENTRY.ID, ERR)
        IF ERR THEN
            YR.CATEG.ENTRY = ''
        END
        IF YR.CATEG.ENTRY THEN

* For Multi-book have to ensure we are processing for the right company
            IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> = EB.SystemTables.getIdCompany() THEN

                IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> GT YEND.DATE THEN
                    BOOKING.DATE = YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate>
                    GOSUB BUILD.NET.ENTRY.LIST
                    IF DETAIL.NOT.FOUND THEN
                        YCAT.DATA = Y.CAT.NO:"*":YENTRY.ID:"*":YOPEN.BAL:"*":"CATEG.ENTRY"
                        GOSUB CONSOLIDATE.BOOKING.DATES ; * Add entry's booking date to list
                        IF Y.CONCAT.REC THEN
                            Y.CONCAT.REC := @FM:YCAT.DATA
                        END ELSE
                            Y.CONCAT.REC = YCAT.DATA
                        END
                        ENTRY.FOUND = 1
                    END
                END
            END

        END
    REPEAT
RETURN
*
*-----------------------------------------------------------------------
*
BUILD.NET.ENTRY.LIST:
*====================

    NET.ENTRY = COUNT(YENTRY.ID,'!')
    DETAIL.NOT.FOUND = 0
    IF NET.ENTRY THEN
        CATEG.CNT = 1
        DETAIL.SEQ.NO = ''
        DETAIL.SEQ.NO = INT(YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatStmtNo>/200) + 1
        LOOP
        UNTIL (CATEG.CNT > DETAIL.SEQ.NO)
            CATEG.XREF.ID = YENTRY.ID:'-':CATEG.CNT
            R.CATEG.ENTRY.DETAIL.XREF = ''
            YERR = ''
            R.CATEG.ENTRY.DETAIL.XREF = AC.EntryCreation.CategEntryDetailXref.Read(CATEG.XREF.ID, YERR)
            CATEG.CNT + = 1
            IF NOT(YERR) THEN
                GOSUB READ.CATEG.ENTRY.DETAIL
            END ELSE
                DETAIL.NOT.FOUND = 1
                EXIT
            END
        REPEAT
    END ELSE
        CATEG.ENT.ID = YENTRY.ID
        APPLN = "CATEG.ENTRY"
        GOSUB BUILD.CONCAT.REC
    END

RETURN
*
*-----------------------------------------------------------------------
*
READ.CATEG.ENTRY.DETAIL:
*=======================
*
* Remove the id from list and read the record from categ.entry.detail file
*
    APPLN = "CATEG.ENTRY.DETAIL"
    LOOP
        REMOVE CATEG.ENT.ID FROM R.CATEG.ENTRY.DETAIL.XREF SETTING POS
    WHILE CATEG.ENT.ID : POS
        GOSUB BUILD.CONCAT.REC
    REPEAT

RETURN
*
*-----------------------------------------------------------------------
BUILD.CONCAT.REC:
*================

    YCAT.DATA = Y.CAT.NO:"*":CATEG.ENT.ID:"*":YOPEN.BAL:"*":APPLN
    GOSUB CONSOLIDATE.BOOKING.DATES ; * Add entry's booking date to list
    ENT.POS = ''
    IF Y.CONCAT.REC THEN
        Y.CONCAT.REC := @FM:YCAT.DATA
    END ELSE
        Y.CONCAT.REC = YCAT.DATA
    END
    ENTRY.FOUND = 1

RETURN
*
*-----------------------------------------------------------------------
*
EXTRACT.ENTRY.IDS:
*=================
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ''
        YSTMT.CHK = 1

        ERR = ''
        Y.CATEG.ENTRY = ''
        Y.CATEG.ENTRY = AC.EntryCreation.CategEntry.Read(YENTRY.ID, ERR)
        IF ERR THEN
            YSTMT.CHK = ""
        END
        IF YOPERAND EQ 3 AND Y.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> GE YENQ.LIST<1,1>  THEN
* if it is less than then retrieve only booking date less than given date
* skip others.
            YSTMT.CHK = ""
        END
        IF YSTMT.CHK THEN

***!            Y.CONCAT.REC<-1> = Y.CAT.NO:'*':YENTRY.ID:'*':YOPEN.BAL
            BOOKING.DATE = Y.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate>
            YCAT.DATA = Y.CAT.NO:"*":YENTRY.ID:"*":YOPEN.BAL:"*":"CATEG.ENTRY"
            GOSUB CONSOLIDATE.BOOKING.DATES ; * Add entry's booking date to list
            IF Y.CONCAT.REC THEN
                Y.CONCAT.REC := @FM:YCAT.DATA
            END ELSE
                Y.CONCAT.REC = YCAT.DATA
            END
            ENTRY.FOUND = 1
        END
    REPEAT
RETURN
*
*-----------------------------------------------------------------------
*
BUILD.CONCAT.LIST:
*=================
* EN_100001880 S
    FROM.DATE = ''
    TO.DATE = ''
* Set a minimum date in when using LT, LE
    MIN.DATE = "19950101"
* EN_100001880 E
    YMATCH.PART1 = "'":Y.CAT.NO:".'6N"
    YMATCH.PART = '"':YMATCH.PART1:'"'

    ON YOPERAND GOSUB MATCH.DATE.EQUAL,
    MATCH.DATE.RANGE,
    MATCH.DATE.LESS.THAN,
    MATCH.DATE.GREATER.THAN,
    MATCH.DATE.NOT,
    MATCH.DATE.LIKE,
    MATCH.DATE.UNLIKE,
    MATCH.DATE.LE,
    MATCH.DATE.GE,
    MATCH.DATE.NR
    
    IF NOT(ENTRY.FOUND) THEN
        IF ACC.COMP.CNT THEN ;* When there are Accounting Companies present for the Parent Company.
            IF (COMP.ID.POS EQ ACC.COMP.CNT+1) THEN   ;* When there are no entries found in all the companies including Parent Company
                Y.CONCAT.REC<-1> = Y.CAT.NO:"*":"*":YOPEN.BAL
            END
        END ELSE
            Y.CONCAT.REC<-1> = Y.CAT.NO:"*":"*":YOPEN.BAL
        END
    END
RETURN
*
*----------------------------------------------------------------------
*
GET.OPEN.BAL:
*============
*
    PREV.MONTH = ''
    CURR.FIN.YEAR.FLAG = ''
    CPL.START.DATE = ''
    CPL.END.DATE = ''
*   YOPEN.BAL = ''      ;* This is initialised in the main para as for ACU/DBU the open balance of all the companies need to be summed
    IF YOPERAND MATCHES 3:@VM:5:@VM:6:@VM:7:@VM:8:@VM:10 THEN
* LT NE LK UL LE NR
    END ELSE
* EQ RG GT GE
        Y.END = ""

** In case where the financial year end is not from Jan - Dec and the current month is Jan 2015
** previous month would be december and hence it has to be DEC 2014

        IF EB.SystemTables.getToday()[5,2] EQ '01' THEN
            PREV.MONTH = EB.SystemTables.getToday()[1,4]-1:"12"
        END ELSE
            PREV.MONTH = EB.SystemTables.getToday()[1,6]-1
        END

** Check if the enquiry is run only for the current financial year
        IF SAVE.YFIRST.DAY.YEAR[1,4] EQ YFIRST.DAY.YEAR[1,4] THEN
            CURR.FIN.YEAR.FLAG = '1'
        END

        BEGIN CASE

            CASE YENQ.LIST<1,1>[1,6] EQ SAVE.YFIRST.DAY.YEAR[1,6]    ;* In case of first month of the financial year
                GOSUB GET.OPEN.BAL.FROM.ENTRIES

            CASE YENQ.LIST<1,1>[1,6] EQ EB.SystemTables.getToday()[1,6]    ;* Current month entries
                CPL.START.DATE<1> = EB.SystemTables.getToday()[1,6]:'01'   ;* Start date is the current month's starting date
                CPL.START.DATE<2> = 'CM'    ;* Current month marker
                CPL.END.DATE = YENQ.LIST<1,1>         ;* End date is the query date
                AC.ModelBank.getCategOpenBalance(YOPERAND,Y.CAT.NO,CPL.START.DATE,CPL.END.DATE,YOPEN.BAL)

            CASE YENQ.LIST<1,1>[1,6] EQ PREV.MONTH AND CURR.FIN.YEAR.FLAG    ;* Previous month entries(belonging to the current financial year)
                CPL.START.DATE<1> = YENQ.LIST<1,1>    ;* Start date is the query date
                CPL.START.DATE<2> = 'PM'    ;* Previous month marker
                CPL.END.DATE = EB.SystemTables.getToday()[1,6]:'01'
                EB.API.Cdt(YLOCAL.REGION,CPL.END.DATE,'-01C') ;* Get Previous month end date to be the end date, -1C used because there could be scenario where BATCH is working but BRANCH is Holiday
                AC.ModelBank.getCategOpenBalance(YOPERAND,Y.CAT.NO,CPL.START.DATE,CPL.END.DATE,YOPEN.BAL)

            CASE 1
                GOSUB GET.OPEN.BAL.FROM.ENTRIES

        END CASE
    END
RETURN
*-----------------------------------------------------------------------
*
GET.OPEN.BAL.FROM.ENTRIES:
*=========================
*
    YACTUAL.MONTH = YSTART.MONTH
    YFIN.YEAR = YFIRST.DAY.YEAR[1,4]
* Get entries from beginning of Financial year to this year month
    Y.END = ''
    YR.CATEG.MONTH = ''
    FROM.DATE = YFIRST.DAY.YEAR
    TO.DATE = ''
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CAT.NO,YR.CATEG.MONTH)
    IF YENQ.LIST<1,1> GT EB.SystemTables.getToday() THEN
        GOSUB GET.TODAYS.ENTRIES
        YR.CATEG.MONTH<-1> = YR.ENTRY.FILE
        YR.ENTRY.FILE = ''
    END

    GOSUB OPEN.BAL.CALC

RETURN
*
*-----------------------------------------------------------------------
*
*
OPEN.BAL.CALC:
*=============
*
* Add the close out entry into opening balance which fetching the next year entries.
*
*
    PERIOD.WORKING.DATE = YENQ.LIST<1,1>

    DAYTYPE = ''
    EB.API.Awd (YLOCAL.REGION,PERIOD.WORKING.DATE,DAYTYPE) ;* Check for holiday
    IF DAYTYPE[1,1] NE 'W' THEN
* if it is a holiday then check for next working day
* to check close out entries to be included in opening balance or not.
*
        EB.API.Cdt(YLOCAL.REGION,PERIOD.WORKING.DATE,'+1W')
    END

    YFIRST.WDAY.YEAR = YFIRST.DAY.YEAR
    DAYTYPE = ''
    EB.API.Awd (YLOCAL.REGION,YFIRST.WDAY.YEAR,DAYTYPE) ;* Check for holiday
    IF DAYTYPE[1,1] NE 'W' THEN
* if it is a holiday then check for next working day
* to check close out entries to be included in opening balance or not.
*
        EB.API.Cdt(YLOCAL.REGION,YFIRST.WDAY.YEAR,'+1W')
    END

    LOOP
        REMOVE YENTRY.ID FROM YR.CATEG.MONTH SETTING YCODE
    UNTIL YENTRY.ID = "" OR Y.END = "END"

        GOSUB READ.CATEG.ENTRY

        IF YR.CATEG.ENTRY NE "" THEN
* For Multi-book have to ensure we are processing for the right company
            IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> = EB.SystemTables.getIdCompany() THEN

                IF YOPERAND MATCHES 1:@VM:2:@VM:9 THEN
* for EQ RG GE
                    IF BOOKING.DATE LT YENQ.LIST<1,1> THEN
                        IF BOOKING.DATE GE YFIRST.DAY.YEAR THEN
* Include the amount in opening balance
                            YOPEN.BAL += YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatAmountLcy>
                        END
                        BEGIN CASE
                            CASE YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatSystemId>[1,3] EQ 'PL.' AND BOOKING.DATE LE PERIOD.WORKING.DATE AND YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatAccountingDate> EQ YFIRST.DAY.YEAR
                                NULL
                            CASE YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatSystemId>[1,3] EQ 'PL.' AND BOOKING.DATE LE PERIOD.WORKING.DATE
* Exclude the close out entries amount from the opening balance
                                YOPEN.BAL -= YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatAmountLcy>
                        END CASE
                    END ELSE
                        IF YFIRST.WDAY.YEAR GE YENQ.LIST<1,1> AND BOOKING.DATE LE PERIOD.WORKING.DATE AND YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatSystemId>[1,3] EQ 'PL.' THEN
* Exclude the close out entries when 1st working day of the financial year is greater then the requested date
                            YOPEN.BAL -= YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatAmountLcy>
                        END ELSE
                            Y.END ="END"
                        END
                    END
                END ELSE
                    IF BOOKING.DATE LE YENQ.LIST<1,1> THEN
                        BEGIN CASE
                            CASE BOOKING.DATE GE YFIRST.DAY.YEAR AND YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatSystemId>[1,3] EQ 'PL.' AND YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatAccountingDate> EQ YFIRST.DAY.YEAR
                                YOPEN.BAL += YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatAmountLcy>

                            CASE BOOKING.DATE GE YFIRST.DAY.YEAR AND YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatSystemId>[1,3] NE 'PL.'
                                YOPEN.BAL += YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatAmountLcy>
                        END CASE
                    END ELSE
                        IF BOOKING.DATE LE PERIOD.WORKING.DATE AND YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatSystemId>[1,3] EQ 'PL.' THEN
                            YOPEN.BAL -= YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatAmountLcy>
                        END ELSE
                            Y.END ="END"
                        END
                    END

                END

            END
        END
    REPEAT
RETURN
*
*-----------------------------------------------------------------------
*
READ.CATEG.ENTRY:
*================
    YR.CATEG.ENTRY = ""


    ERR = ''
    YR.CATEG.ENTRY = ''
    YR.CATEG.ENTRY = AC.EntryCreation.CategEntry.Read(YENTRY.ID, ERR)
    IF ERR THEN
        YR.CATEG.ENTRY = ""
    END

    POSITION.TYPE = YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatPositionType>

* Retrieve the Position type record.
    LOCATE POSITION.TYPE IN Y.PL.PREFIXES.LIST<1,1> SETTING PL.POS ELSE
        PL.POS = ''
    END

    ENTRY.SYSTEM.ID = YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatSystemId>
    IF ENTRY.SYSTEM.ID[2] = "BL" AND LEN(ENTRY.SYSTEM.ID) > 2 THEN          ;* Self balancing
        ENTRY.SYSTEM.ID = ENTRY.SYSTEM.ID[1, LEN(ENTRY.SYSTEM.ID)-2]
    END

    BEGIN CASE

        CASE YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatSuspnseValueDate>      ;* Future processing date real PL entry
            BOOKING.DATE = YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatSuspnseValueDate>

        CASE ENTRY.SYSTEM.ID MATCHES Y.PL.PREFIXES.LIST<3,PL.POS>     ;* contingent PL
            BOOKING.DATE = YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatValueDate>

        CASE 1
            BOOKING.DATE = YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate>

    END CASE

RETURN
*
*-----------------------------------------------------------------------
*** <region name= SORT.ENT.BY.BOOK.DATE>
*** <desc>Sort Entries by booking dates for ACU/DBU accounting companies </desc>
SORT.ENT.BY.BOOK.DATE:
**********************
    CONCAT.REC = Y.CONCAT.REC

* Sort the entries based on the booking dates obtained
    SORT.DELIM="#"
* Use splice to join the booking dates and the corresponding entry records
* by marker wise. E.g., In both records, first record split by field marker
* will be combined with the delimiter in-between into first record of the result.
    PRE.SORT.REC=SPLICE(BOOK.DATES,SORT.DELIM,CONCAT.REC)
    SORT.REC=SORT(PRE.SORT.REC) ;* Sort the joined record. Since booking date is at the start of record, it sorts by date.
    CONCAT.REC=FIELDS(SORT.REC,SORT.DELIM,2) ;* Split the record to remove the booking dates and get the entries required for the enquiry

    Y.CONCAT.REC = CONCAT.REC

RETURN
*** </region>
*
*-----------------------------------------------------------------------
*
*** <region name= CONSOLIDATE.BOOKING.DATES>
*** <desc>Include booking dates for all entries so they can be sorted in case of accounting companies </desc>
CONSOLIDATE.BOOKING.DATES:
**************************
    IF BOOK.DATES THEN
        BOOK.DATES<-1> = BOOKING.DATE
    END ELSE
        BOOK.DATES = BOOKING.DATE
    END

RETURN
*** </region>
*-----------------------------------------------------------------------
*
VALIDATE.DATE:
*-------------
* Check whether date is valid
    SAVE.COMI = ''
    SAVE.COMI = EB.SystemTables.getComi()
    EB.SystemTables.setComi(DATE.TO.VAL)
    EB.Utility.InTwod("11", "D")
    IF EB.SystemTables.getEtext() THEN
        ENQ.ERROR<-1> = EB.SystemTables.getEtext()
    END
    EB.SystemTables.setComi(SAVE.COMI)
    
RETURN
*-------------------------------------------------------------------------------------

END
