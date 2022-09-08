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

* Version 3 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>790</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.CATEG.ENT.BY.CCY(Y.ID.LIST)
*-----------------------------------------------------------------------------
*
* 03/03/92 - HY9200669
*            Replace READLIST with call to EB.READLIST
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
*            If no start date has been specified for the enquiry, the start
*            date has been hard-coded to '19950101'
*
*            Once we have the list of entries then ensure we are processing
*            for the right company.
*
* 03/05/08 - EN_10003635
*            Update to CATEG.ENT.TODAY/LWORK is based on ENT.TODAY.UPDATE flag in ACCOUNT.PARAMETER.
*            CALL AC.GET.CATEG.ENT.TODAY.LWORK by passing CATEG.ENTRY.LIST with CATEG.TODAY.
*
* 12/09/08 - BG_100019925
*            Bug fixes for ENT.TODAY sar. When appending the list, check if the list is having
*            previously selected entries.
*
* 19/07/10 - Task : 67685
*            Routine missing in RTC. Putting it back.
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().
*
* 28/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 21/09/15 - Defect 1446226, Task 1475329
*            Enquiry CATEG.ENT.CCY shows the duplicate entries
*            since categ entries are already extracted for the corresponding previous value of YR.ENTRY.FILE
*            and are stored in Y.CONCAT.REC so no need to append YR.ENTRY.FILE in  GET.TODAYS.ENTRIES
*            hence removed the code YR.ENTRY.FILE := @FM:Y.CATEG.ENTRY.KEY
*            Also in MATCH.DATE.EQUAL the variable Y.END is cleared to work EQUAL case properly
*            Also in GET.ENTRIES.LT the Condition for checking company code corrected
*            Also in GET.ENTRIES.GE the Condition for itterating corrected
*            Also changed YMONTH EQ 12 to YMONTH GT 12 
*--------------------------------------------------------------------------------
    $INSERT I_DAS.CATEGORY

    $USING EB.DataAccess
    $USING EB.API
    $USING AC.EntryCreation
    $USING ST.CompanyCreation
    $USING EB.Reports
    $USING EB.SystemTables

*-----------------------------------------------------------------------
MAIN.PARA:
*=========
* Find the position of CATEGORY and BOOKING.DATE
*
    LOCATE "CATEGORY" IN EB.Reports.getDFields()<1> SETTING YCATEGORY.POS ELSE RETURN
    LOCATE "BOOKING.DATE" IN EB.Reports.getDFields()<1> SETTING YDATE.POS ELSE RETURN
    LOCATE "NARR.CCY" IN EB.Reports.getDFields()<1> SETTING YCCY.POS ELSE YCCY.POS = ""
*
    IF EB.Reports.getDLogicalOperands()<YDATE.POS> = '' OR EB.Reports.getDRangeAndValue()<YDATE.POS> = "" OR EB.Reports.getDRangeAndValue()<YDATE.POS> = "ALL" THEN
        RETURN
    END

    GOSUB OPEN.REQD.FILES
    GOSUB LIST.ACCT.NOS
* Sort the dates into order
    YCURRENCY = ""
    YOPERAND = EB.Reports.getDLogicalOperands()<YDATE.POS>
    YENQ.LIST.COPY = EB.Reports.getDRangeAndValue()<YDATE.POS>
    IF YCCY.POS THEN
        YCURRENCY = EB.Reports.getDRangeAndValue()<YCCY.POS>
        CONVERT "." TO "" IN YCURRENCY
    END
    YENQ.LIST = ""
    LOOP
        REMOVE YVALUE FROM YENQ.LIST.COPY SETTING YCODE
    UNTIL YVALUE = ''
        LOCATE YVALUE IN YENQ.LIST<1,1> BY 'AR' SETTING YPOS ELSE NULL
        INS YVALUE BEFORE YENQ.LIST<1,YPOS>
    REPEAT
    Y.CONCAT.REC = ""
* Store the local region
    YLOCAL.REGION = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry)
    IF YLOCAL.REGION = "" THEN
        YLOCAL.REGION = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalRegion)
    END ELSE
        YLOCAL.REGION := "00"
    END
    YFIRST.DAY.YEAR = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLastYearEnd)
    EB.API.Cdt(YLOCAL.REGION,YFIRST.DAY.YEAR,"+1C")
* If the first date is in a prior year, then the first day
* of this year must be found.
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
    YSTART.MONTH = YFIRST.DAY.YEAR[5,2]
    YTHIS.YEAR.MONTH = EB.SystemTables.getToday()[1,6]
* Find last working day
    YLWORK.DAY = EB.SystemTables.getToday()
    EB.API.Cdt(YLOCAL.REGION,YLWORK.DAY,"-1W")
    YOPERAND = EB.Reports.getDLogicalOperands()<YDATE.POS>
    LOOP
        Y.CATEG.NO = YCATEG.LIST<1>
    UNTIL Y.CATEG.NO = "" DO
        DEL YCATEG.LIST<1>
        GOSUB GET.OPEN.BAL
        GOSUB BUILD.CONCAT.LIST
    REPEAT
*
    Y.ID.LIST = Y.CONCAT.REC
    RETURN
*
*------------------------------------------------------------------------
*
OPEN.REQD.FILES:
*===============
*
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

    TableName = 'CATEGORY'
    TheList = dasCategoryIdGtLtById
    TheArgs = '49999':@FM:'70000'
    TableSuffix = ''
    CATEG.ID.LIST = ''
    EB.DataAccess.Das(TableName, TheList, TheArgs, TableSuffix)
    CATEG.ID.LIST = TheList

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
*-----------------------------------------------------------------------
MATCH.EQUAL:
*===========
* For ALL Accounts
    YCATEG.LIST = CATEG.ID.LIST
    RETURN
*-----------------------------------------------------------------------------
MATCH.RANGE:
*===========
    Y.END = ""
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" OR Y.END = "END" DO
        DEL CATEG.ID.LIST<1>
        IF YCAT >= YENQ.LIST<1,1,1> AND YCAT <= YENQ.LIST<1,1,2> THEN
            YCATEG.LIST<-1> = YCAT
        END ELSE
            IF YCAT > YENQ.LIST<1,2> THEN Y.END = "END"
        END
    REPEAT
    RETURN
*
*-----------------------------------------------------------------------------
MATCH.LESS.THAN:
*===============
    Y.END = ""
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" OR Y.END = "END" DO
        DEL CATEG.ID.LIST<1>
        IF YCAT < YENQ.LIST<1,1> THEN
            YCATEG.LIST<-1> = YCAT
        END ELSE
            Y.END = "END"
        END
    REPEAT

    RETURN
*-----------------------------------------------------------------------------
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
*-----------------------------------------------------------------------------
MATCH.NOT:
*=========
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" DO
        LOCATE YCAT IN YENQ.LIST<1,1> SETTING YAC.LOC ELSE
        YCATEG.LIST<-1> = YCAT
    END
    DEL CATEG.ID.LIST<1>
    REPEAT

    RETURN
*-----------------------------------------------------------------------------
MATCH.LIKE:
*==========
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" DO
        IF INDEX(YCAT,YENQ.LIST<1,1>,1) > 0 THEN
            YCATEG.LIST<-1> = YCAT
        END
        DEL CATEG.ID.LIST<1>
    REPEAT

    RETURN
*-----------------------------------------------------------------------------
MATCH.UNLIKE:
*============
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" DO
        IF INDEX(YCAT,YENQ.LIST<1,1>,1) = 0 THEN
            YCATEG.LIST<-1> = YCAT
        END
        DEL CATEG.ID.LIST<1>
    REPEAT
    RETURN
*-----------------------------------------------------------------------------
MATCH.LE:
*========
    Y.END = ""
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = "" OR Y.END = "END" DO
        DEL CATEG.ID.LIST<1>
        IF YCAT <= YENQ.LIST<1,1> THEN
            YCATEG.LIST<-1> = YCAT
        END ELSE
            Y.END = "END"
        END
    REPEAT
    RETURN
*-----------------------------------------------------------------------------
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
*-----------------------------------------------------------------------------
MATCH.NR:
*========
    LOOP
        YCAT = CATEG.ID.LIST<1>
    UNTIL YCAT = ""
        DEL CATEG.ID.LIST<1>
        IF YCAT < YENQ.LIST<1,1> AND YCAT > YENQ.LIST<1,2> THEN
            YCATEG.LIST<-1> = YCAT
        END
    REPEAT
    RETURN
*-----------------------------------------------------------------------
MATCH.DATE.EQUAL:
*================
* There may be more than 1 date in the list
    YENQ.LIST = YENQ.LIST
    LOOP
        REMOVE YBOOK.DATE FROM YENQ.LIST SETTING YCODE ;* Get the booking date from the list specified
    UNTIL YBOOK.DATE = ''
        FROM.DATE = YBOOK.DATE
        TO.DATE = YBOOK.DATE
        Y.END = ''
        AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE) ;* Get list of categ ids from CATEG.MONTH and CATEG.ENT.ACTIVITY
        GOSUB GET.ENTRIES.EQ

        IF YBOOK.DATE GT YLWORK.DAY THEN
            GOSUB GET.TODAYS.ENTRIES
            GOSUB GET.ENTRIES.EQ
        END
    REPEAT
    RETURN
*
*------------------------------------------------------------------------
*
GET.ENTRIES.EQ:
*==============
* Read in each entry and check the booking date against the chosen date
    LOOP
        REMOVE YENTRY.KEY FROM YR.ENTRY.FILE SETTING YTYPE
    UNTIL YENTRY.KEY = '' OR Y.END = "END"
        YR.CATEG.ENTRY = AC.EntryCreation.tableCategEntry(YENTRY.KEY, ERR)

        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> NE EB.SystemTables.getIdCompany() THEN
            CONTINUE ;*  * For Multi-book have to ensure we are processing for the right company
        END
        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> EQ YBOOK.DATE THEN
            IF NOT(YCURRENCY) THEN
                Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.KEY:'*':YOPENING.BAL
                ENTRY.FOUND = 1
            END ELSE
                IF INDEX(YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatNarrative>,YCURRENCY,1) > 0 THEN
                    Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.KEY:'*':YOPENING.BAL
                    ENTRY.FOUND = 1
                END
            END
        END ELSE
            IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> GT YBOOK.DATE THEN
                Y.END = "END"
            END
        END
    REPEAT
    RETURN
*-----------------------------------------------------------------------
MATCH.DATE.RANGE:
*================
*
    YSTARTING.DATE = YENQ.LIST<1,1>
    IF YENQ.LIST<1,2> NE '' THEN
        YENDING.DATE = YENQ.LIST<1,2>
    END ELSE
        YENDING.DATE = YSTARTING.DATE
    END
    Y.END = ""

    YR.ENTRY.FILE = ''
    FROM.DATE = YSTARTING.DATE
    TO.DATE = YENDING.DATE
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB GET.ENTRIES.RG

    IF YENDING.DATE GT YLWORK.DAY THEN
        GOSUB GET.TODAYS.ENTRIES
        GOSUB GET.ENTRIES.RG
    END
    RETURN
*-----------------------------------------------------------------------------
GET.ENTRIES.RG:
*==============
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = '' OR Y.END = 'END'
        YR.CATEG.ENTRY = ''
        YR.CATEG.ENTRY = AC.EntryCreation.tableCategEntry(YENTRY.ID, ERR)
        * For Multi-book have to ensure we are processing for the right company
        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> NE EB.SystemTables.getIdCompany() THEN
            CONTINUE
        END
        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> GT YENDING.DATE THEN
            Y.END = 'END'
        END ELSE
            IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> GE YSTARTING.DATE THEN
                IF NOT(YCURRENCY) THEN
                    Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                    ENTRY.FOUND = 1
                END ELSE
                    IF INDEX(YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatNarrative>,YCURRENCY,1) > 0 THEN
                        Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                        ENTRY.FOUND = 1
                    END
                END
            END
        END

    REPEAT

    RETURN
*-----------------------------------------------------------------------
MATCH.DATE.LESS.THAN:
*====================
    Y.END = ''
    YR.ENTRY.FILE = ''
    YYEAR = YTHIS.YEAR.MONTH[1,4] ; YMONTH = YTHIS.YEAR.MONTH[5,2] ;* Get the date just before this year month
    YMONTH -= 1 ; YMONTH = FMT(YMONTH,"2'0'R")
    IF YMONTH EQ 0 THEN
        YMONTH = FMT(12,"2'0'R")
        YYEAR -= 1
    END


* Take the minimum date that exist for the CATEG.MONTH from 19950101 to previous month
    FROM.DATE = MIN.DATE      ;* MUST CHECK WHICH DATE TO PUT
    TO.DATE = YYEAR:YMONTH    ;* Previous month this year
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB EXTRACT.ENTRY.IDS


    FROM.DATE = YTHIS.YEAR.MONTH ;* Then for this month
    TO.DATE = YTHIS.YEAR.MONTH
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB GET.ENTRIES.LT
    IF YENQ.LIST<1,1> GT YLWORK.DAY THEN
        GOSUB GET.TODAYS.ENTRIES
        GOSUB GET.ENTRIES.LT
    END
    RETURN
*-----------------------------------------------------------------------------
GET.ENTRIES.LT:
*==============
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = "" OR Y.END = "END"
        YR.CATEG.ENTRY = ""
        YR.CATEG.ENTRY = AC.EntryCreation.tableCategEntry(YENTRY.ID, ERR)

        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> NE EB.SystemTables.getIdCompany() THEN
            CONTINUE ;* For Multi-book have to ensure we are processing for the right company
        END

        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> LT YENQ.LIST<1,1> THEN
            IF NOT(YCURRENCY) THEN
                Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                ENTRY.FOUND = 1
            END ELSE
                IF INDEX(YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatNarrative>,YCURRENCY,1) > 0 THEN
                    Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                    ENTRY.FOUND = 1
                END
            END
        END ELSE
            Y.END = "END"
        END

    REPEAT

    RETURN
*
*-----------------------------------------------------------------------
*
MATCH.DATE.NOT:
*==============
* Will retrieve all entries
    Y.END = ''
    FROM.DATE = MIN.DATE ;*  Take from minimum date
    TO.DATE = ''
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB GET.ENTRIES.NOT
    GOSUB GET.TODAYS.ENTRIES
    GOSUB GET.ENTRIES.NOT

    RETURN
*-----------------------------------------------------------------------------
GET.ENTRIES.NOT:
*===============
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ''
        YR.CATEG.ENTRY = ''
        YR.CATEG.ENTRY = AC.EntryCreation.tableCategEntry(YENTRY.ID, ERR)
        * For Multi-book have to ensure we are processing for the right company
        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> = EB.SystemTables.getIdCompany() THEN

            LOCATE YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> IN YENQ.LIST<1,1> SETTING YCOUNT ELSE
            Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
            ENTRY.FOUND = 1
        END
    END

    REPEAT

    RETURN
*-----------------------------------------------------------------------
MATCH.DATE.LIKE:
*===============
*
    RETURN
*
MATCH.DATE.UNLIKE:
*=================
*
    RETURN
*-----------------------------------------------------------------------
MATCH.DATE.LE:
*=============

    Y.END = ''
    YR.ENTRY.FILE = ''

    YYEAR = YTHIS.YEAR.MONTH[1,4] ; YMONTH = YTHIS.YEAR.MONTH[5,2] ;* Get the date just before this year month
    YMONTH -= 1 ; YMONTH = FMT(YMONTH,"2'0'R")
    IF YMONTH EQ 0 THEN
        YMONTH = FMT(12,"2'0'R")
        YYEAR -= 1
    END

* Take the minimum date that exist for the CATEG.MONTH from 19950101 to previous month
    FROM.DATE = MIN.DATE      ;* MUST CHECK WHICH DATE TO PUT
    TO.DATE = YYEAR:YMONTH    ;* Previous month this year

    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB EXTRACT.ENTRY.IDS

* Then for this month
    FROM.DATE = YTHIS.YEAR.MONTH
    TO.DATE = YTHIS.YEAR.MONTH
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB GET.ENTRIES.LE

    IF YENQ.LIST<1,1> GT YLWORK.DAY THEN
        GOSUB GET.TODAYS.ENTRIES
        GOSUB GET.ENTRIES.LE
    END
    RETURN
*-----------------------------------------------------------------------------
GET.ENTRIES.LE:
*==============
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = "" OR Y.END = "END"
        YR.CATEG.ENTRY = ""
        YR.CATEG.ENTRY = AC.EntryCreation.tableCategEntry(YENTRY.ID, ERR)

        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> NE EB.SystemTables.getIdCompany() THEN
            CONTINUE ;* For Multi-book have to ensure we are processing for the right company
        END
        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> LE YENQ.LIST<1,1> THEN
            IF NOT(YCURRENCY) THEN
                Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                ENTRY.FOUND = 1
            END ELSE
                IF INDEX(YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatNarrative>,YCURRENCY,1) > 0 THEN
                    Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                    ENTRY.FOUND = 1
                END
            END
        END ELSE
            Y.END = "END"
        END
    REPEAT

    RETURN
*-----------------------------------------------------------------------
MATCH.DATE.GREATER.THAN:
*=======================
*
    YMONTH = YENQ.LIST<1,1>[5,2] ; YYEAR = YENQ.LIST<1,1>[1,4]
    YR.ENTRY.FILE = ''

* Check for the date input first
    FROM.DATE = YENQ.LIST<1,1>
    TO.DATE = YENQ.LIST<1,1>
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB GET.ENTRIES.GT

* Now as from the yearmonth after the date input to this year month
    YMONTH += 1 ; YMONTH = FMT(YMONTH,"2'0'R")
    IF YMONTH GT 12 THEN
        YMONTH = FMT(1,"2'0'R")
        YYEAR += 1
    END

    FROM.DATE = YYEAR:YMONTH
    TO.DATE = ""
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB EXTRACT.ENTRY.IDS

    GOSUB GET.TODAYS.ENTRIES
    GOSUB GET.ENTRIES.GT
    RETURN
*-----------------------------------------------------------------------------
GET.ENTRIES.GT:
*==============
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ""
        YR.CATEG.ENTRY = ""
        YR.CATEG.ENTRY = AC.EntryCreation.tableCategEntry(YENTRY.ID, ERR)
        * For Multi-book have to ensure we are processing for the right company
        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> NE EB.SystemTables.getIdCompany() THEN
            CONTINUE
        END

        IF NOT(YCURRENCY) THEN
            IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> GT YENQ.LIST<1,1> THEN
                Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                ENTRY.FOUND = 1
            END
        END ELSE
            IF INDEX(YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatNarrative>,YCURRENCY,1) > 0 THEN
                Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                ENTRY.FOUND = 1
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
    YMONTH = YENQ.LIST<1,1>[5,2] ; YYEAR = YENQ.LIST<1,1>[1,4]
    YR.ENTRY.FILE = ''
* Check for the date input first
    FROM.DATE = YENQ.LIST<1,1>
    TO.DATE = YENQ.LIST<1,1>
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB GET.ENTRIES.GE

* Now as from the yearmonth after the date input to this year month
    YMONTH += 1 ; YMONTH = FMT(YMONTH,"2'0'R")
    IF YMONTH GT 12 THEN
        YMONTH = FMT(1,"2'0'R")
        YYEAR += 1
    END

    FROM.DATE = YYEAR:YMONTH
    TO.DATE = ""
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB EXTRACT.ENTRY.IDS
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
        YR.CATEG.ENTRY = ""
        YR.CATEG.ENTRY = AC.EntryCreation.tableCategEntry(YENTRY.ID, ERR)

        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> NE EB.SystemTables.getIdCompany() THEN
            CONTINUE ; * For Multi-book have to ensure we are processing for the right company
        END
        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> GE YENQ.LIST<1,1> THEN
            IF NOT(YCURRENCY) THEN
                Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                ENTRY.FOUND = 1
            END ELSE
                IF INDEX(YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatNarrative>,YCURRENCY,1) > 0 THEN
                    Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                    ENTRY.FOUND = 1
                END
            END
        END
    REPEAT
    RETURN
*
*-----------------------------------------------------------------------
*
GET.TODAYS.ENTRIES:
*==================
*
    Y.CATEG.ENTRY.KEY = "CATEG.TODAY"
    AC.EntryCreation.GetCategEntTodayLwork('','',Y.CATEG.NO,Y.CATEG.ENTRY.KEY)
    IF Y.CATEG.ENTRY.KEY <> "" THEN
        YR.ENTRY.FILE = Y.CATEG.ENTRY.KEY
    END
*
    RETURN
*
*-----------------------------------------------------------------------
MATCH.DATE.NR:
*=============
* Get the entries from the beginning to the year month prior the start (not range)

    YSTARTING.DATE = YENQ.LIST<1,1>
    IF YENQ.LIST<1,2> NE '' THEN
        YENDING.DATE = YENQ.LIST<1,2>
    END ELSE
        YENDING.DATE = YENQ.LIST<1,1>
    END

    Y.END = ''
    YR.ENTRY.FILE = ''


    YYEAR = YSTARTING.DATE[1,4] ; YMONTH = YSTARTING.DATE[5,2] ;* Get the date just before this year month
    YMONTH -= 1 ; YMONTH = FMT(YMONTH,"2'0'R")
    IF YMONTH EQ 0 THEN
        YMONTH = FMT(12,"2'0'R")
        YYEAR -= 1
    END
* Take the minimum date that exist for the CATEG.MONTH from 19950101 to month prior start date
    FROM.DATE = MIN.DATE      ;* MUST CHECK WHICH DATE TO PUT
    TO.DATE = YYEAR:YMONTH    ;* Previous month this year
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB EXTRACT.ENTRY.IDS

* Get entries for start (not range) date
    YR.ENTRY.FILE = ''
    Y.END = ''
    FROM.DATE = YSTARTING.DATE
    TO.DATE = YSTARTING.DATE
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB GET.ENTRIES.NR.PRE

* Get entries for  end (not range) date
    YR.ENTRY.FILE = ''
    Y.END = ''
    FROM.DATE = YENDING.DATE
    TO.DATE = YENDING.DATE
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB GET.ENTRIES.NR.POST

* Now get the enries from month after end not range date to this year month

    YR.ENTRY.FILE = ""
    Y.END = ""
    YYEAR = YENDING.DATE[1,4] ; YMONTH = YENDING.DATE[5,2]

    YMONTH += 1 ; YMONTH = FMT(YMONTH,"2'0'R")
    IF YMONTH GT 12 THEN
        YMONTH = FMT(1,"2'0'R")
        YYEAR += 1
    END

    FROM.DATE = YYEAR:YMONTH
    TO.DATE = ''
    AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.ENTRY.FILE)
    GOSUB EXTRACT.ENTRY.IDS

    IF YENDING.DATE LE YLWORK.DAY THEN
        GOSUB GET.TODAYS.ENTRIES
        GOSUB EXTRACT.ENTRY.IDS
    END

    RETURN
*-----------------------------------------------------------------------------
GET.ENTRIES.NR.PRE:
*==================
*
    Y.END = ''
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = '' OR Y.END = 'END'
        YR.CATEG.ENTRY = ""
        YR.CATEG.ENTRY = AC.EntryCreation.tableCategEntry(YENTRY.ID, ERR)

        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> NE EB.SystemTables.getIdCompany() THEN
            CONTINUE ; * For Multi-book have to ensure we are processing for the right company
        END

        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> LT YSTARTING.DATE THEN
            IF NOT(YCURRENCY) THEN
                Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                ENTRY.FOUND = 1
            END ELSE
                IF INDEX(YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatNarrative>,YCURRENCY,1) > 0 THEN
                    Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                    ENTRY.FOUND = 1
                END
            END
        END ELSE
            Y.END = 'END'
        END
    REPEAT

    RETURN
*-----------------------------------------------------------------------------
GET.ENTRIES.NR.POST:
*===================
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE
    UNTIL YENTRY.ID = ''
        YR.CATEG.ENTRY = ""
        YR.CATEG.ENTRY = AC.EntryCreation.tableCategEntry(YENTRY.ID, ERR)

        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> NE EB.SystemTables.getIdCompany() THEN
            CONTINUE ;* For Multi-book have to ensure we are processing for the right company
        END
        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> GT YENDING.DATE THEN
            IF NOT(YCURRENCY) THEN
                Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                ENTRY.FOUND = 1
            END ELSE
                IF INDEX(YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatNarrative>,YCURRENCY,1) > 0 THEN
                    Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                    ENTRY.FOUND = 1
                END
            END
        END
    REPEAT
    RETURN
*-----------------------------------------------------------------------
EXTRACT.ENTRY.IDS:
*=================
*
    LOOP
        REMOVE YENTRY.ID FROM YR.ENTRY.FILE SETTING YCODE2
    UNTIL YENTRY.ID = ''
        YR.CATEG.ENTRY = ""
        YR.CATEG.ENTRY = AC.EntryCreation.tableCategEntry(YENTRY.ID, ERR)

        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> NE EB.SystemTables.getIdCompany() THEN
            CONTINUE ;* For Multi-book have to ensure we are processing for the right company
        END
        IF YCURRENCY THEN
            IF INDEX(YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatNarrative>,YCURRENCY,1) > 0 THEN
                Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
                ENTRY.FOUND = 1
            END
        END ELSE
            Y.CONCAT.REC<-1> = Y.CATEG.NO:'*':YENTRY.ID:'*':YOPENING.BAL
            ENTRY.FOUND = 1
        END
    REPEAT

    RETURN
*-----------------------------------------------------------------------
BUILD.CONCAT.LIST:
*=================
    FROM.DATE = ''
    TO.DATE = ''
* Set a minimum date in when using LT, LE
    MIN.DATE = "19950101"

    YMATCH.PART1 = "'":Y.CATEG.NO:".'6N"
    YMATCH.PART = '"':YMATCH.PART1:'"'

    ENTRY.FOUND = 0
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
        Y.CONCAT.REC<-1> = Y.CATEG.NO:"*":"*":YOPENING.BAL
    END
    RETURN
*-----------------------------------------------------------------------
GET.OPEN.BAL:
*============
*
    IF YOPERAND MATCHES 3:@VM:5:@VM:6:@VM:7:@VM:8:@VM:10 THEN
        YOPENING.BAL = 0
    END ELSE
        YOPENING.BAL = 0 ; Y.END = "" ; YACTUAL.MONTH = YSTART.MONTH
        YFIN.YEAR = YFIRST.DAY.YEAR[1,4] ;* Get entries from beginning of Financial year to this year month
        Y.END = ''
        YR.CATEG.MONTH = ''
        FROM.DATE = YFIRST.DAY.YEAR
        TO.DATE = ''
        AC.EntryCreation.GetCategMonthEntries(FROM.DATE,TO.DATE,Y.CATEG.NO,YR.CATEG.MONTH)

        GOSUB OPEN.BAL.CALC
    END
    RETURN
*-----------------------------------------------------------------------
OPEN.BAL.CALC:
*=============
*
    LOOP
        REMOVE Y.CATEG.ENTRY.ID FROM YR.CATEG.MONTH SETTING YCODE
    UNTIL Y.CATEG.ENTRY.ID = "" OR Y.END = "END"
        YR.CATEG.ENTRY = ""
        YR.CATEG.ENTRY = AC.EntryCreation.tableCategEntry(Y.CATEG.ENTRY.ID , ERR)

        IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatCompanyCode> NE EB.SystemTables.getIdCompany() THEN
            CONTINUE ;* For Multi-book have to ensure we are processing for the right company
        END

        IF YOPERAND MATCHES 1:@VM:2:@VM:9 THEN
            IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> LT YENQ.LIST<1,1> THEN
                YOPENING.BAL += YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatAmountLcy>
            END ELSE
                Y.END ="END"
            END
        END ELSE
            IF YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatBookingDate> LE YENQ.LIST<1,1> THEN
                YOPENING.BAL += YR.CATEG.ENTRY<AC.EntryCreation.CategEntry.CatAmountLcy>
            END ELSE
                Y.END = "END"
            END
        END

    REPEAT

    RETURN
*-----------------------------------------------------------------------
    END
