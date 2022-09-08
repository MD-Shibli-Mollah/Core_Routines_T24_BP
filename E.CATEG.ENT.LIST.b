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

* Version 3 07/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-112</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.CATEG.ENT.LIST(Y.ID.LIST)
*-----------------------------------------------------------------------------
*
* Subroutine to return list of entries for a specific PL category. Used
* by the enquiry system for printing and displaying.
*
* The entry ids are either on CATEG.ENT.TODAY or a combination of
* CATEG.ENT.TODAY & CATEG.MONTH,
* depending on Booking.Date
*
*-------------------------------------------------------------------------
* Modifications:
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
*
* 06/04/05 - EN_10002464
*            Include todays entries.
*
* 28/02/07 - EN_10003231
*            Modified to call DAS to select data.
*
* 01/05/07 - BG_100013739
*            Various DAS related fixes, SAVING AS not being accounted for.
*
* 03/05/08 - EN_10003635
*            Update to ENT.TODAY/LWORK is based on ENT.TODAY.UPDATE flag in ACCOUNT.PARAMETER.
*            CALL AC.GET.CATEG.ENT.TODAY.LWORK by passing CATEG.ENTRY.LIST with CATEG.TODAY and CATEG.LWORK.DAY
*            for getting CATEG.ENT.TODAY entries respectively.
*
* 12/09/08 - BG_100019925
*      Bug fixes for ENT.TODAY sar. When appending the list, check if the list is having
*            previously selected entries.
*
* 29/04/13 - Defect 620902 / Task 663187
*            Enquiry  MB.CATEG.ENT.BOOK.STD takes long time even though date range selection is given for a smaller period
*
* 15/04/15 - Defect 1261646 / Task 1317340
*			Correction to the defect 620902.
*
* 28/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-------------------------------------------------------------------------
*
    $USING EB.DataAccess
    $USING EB.OverrideProcessing
    $USING EB.ErrorProcessing
    $USING AC.EntryCreation
    $USING EB.SystemTables
    $USING EB.API
    $USING ST.CompanyCreation
    $USING EB.Reports

*-------------------------------------------------------------------------
*
* GB9600621 Display message here
*
    EB.SystemTables.setMessage('BUILDING ENTRY LIST')
    tmp.MESSAGE = EB.SystemTables.getMessage()
    EB.OverrideProcessing.DisplayMessage(tmp.MESSAGE, '3')

    GOSUB INITIALISATION
    YERR.COND = (NOT(YCATEGORY.POS) OR NOT(YDATE.POS))
    IF NOT(YERR.COND) THEN
        GOSUB BUILD.ENTRY.LIST
    END
*
    GOSUB DUMMY.LIST
*
* GB9600621 Now clear out the message
*
    EB.SystemTables.setMessage(' ')
    EB.OverrideProcessing.DisplayMessage(' ', '3')
*
    RETURN
*
*-------------------------------------------------------------------------
*
INITIALISATION:
*
    Y.ID.LIST = ''
    EB.Reports.setYCatNo('')
    YCATEGORY.POS = 0
    YDATE.POS = 0
    EB.Reports.setYcatOpenBal(0)

    CE.SS.REC = ""
    EB.API.GetStandardSelectionDets("CATEG.ENTRY", CE.SS.REC)

    FV.CATEG.ENTRY = ""
    EB.DataAccess.Opf("F.CATEG.ENTRY",FV.CATEG.ENTRY)
*
* Find the position of CATEGORY and BOOKING.DATE
*
    LOCATE "PL.CATEGORY" IN EB.Reports.getDFields()<1> SETTING YCATEGORY.POS ELSE
    RETURN
    END

    LOCATE "BOOKING.DATE.SEL" IN EB.Reports.getDFields()<1> SETTING YDATE.POS ELSE
    RETURN
    END

    LOCATE "CCY.SELECT" IN EB.Reports.getDFields()<1> SETTING CURRENCY.POS THEN
    EB.Reports.setYcurrencyPos(CURRENCY.POS)
    EB.Reports.setYccy(EB.Reports.getDRangeAndValue()<CURRENCY.POS>)
    END ELSE
    EB.Reports.setYccy(EB.SystemTables.getLccy())
    EB.Reports.setYcurrencyPos(0)
    END
*
    IF EB.Reports.getDLogicalOperands()<YDATE.POS> = '' OR EB.Reports.getDRangeAndValue()<YDATE.POS> = "" OR EB.Reports.getDRangeAndValue()<YDATE.POS> = "ALL" THEN
        RETURN
    END

    YCATEG.LIST = EB.Reports.getDRangeAndValue()<YCATEGORY.POS>
    IF DCOUNT(YCATEG.LIST, @VM) GT 1 THEN
        RETURN   ;* Only one category allowed
    END
*
* Sort the dates into order
*
    YOPERAND = EB.Reports.getDLogicalOperands()<YDATE.POS>
    YENQ.LIST.COPY = EB.Reports.getDRangeAndValue()<YDATE.POS>
    YENQ.LIST = ""
    LOOP
        REMOVE YVALUE FROM YENQ.LIST.COPY SETTING YCODE
    UNTIL YVALUE = ''
        LOCATE YVALUE IN YENQ.LIST<1,1> BY 'AR' SETTING YPOS ELSE
        NULL
    END
    INS YVALUE BEFORE YENQ.LIST<1,YPOS>
    REPEAT
    EB.Reports.setYstartDate(YENQ.LIST<1,1>)
    IF EB.Reports.getOperandList()<YOPERAND> = "GT" THEN
        tmp.YSTART.DATE = EB.Reports.getYstartDate()
        EB.API.Cdt("", tmp.YSTART.DATE, "+1C")      ;* Inclusive from next day
        EB.Reports.setYstartDate(tmp.YSTART.DATE)
    END
    EB.Reports.setYendDate(YENQ.LIST<1,2>)

* GB9600621 If the end date is null then default it if the operand
* is not = . This allows the GT and GE operands to work in the routine
* E.CATEG.ENQ.STD

    IF EB.Reports.getYendDate() = '' AND YOPERAND <> 1 THEN
        EB.Reports.setYendDate(EB.SystemTables.getToday())
    END
*
    Y.CONCAT.REC = ""
    YCATEG.LIST = EB.Reports.getDRangeAndValue()<YCATEGORY.POS>
*
* Store the local region EB8900271
*
    YLOCAL.REGION = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry)
    IF YLOCAL.REGION = "" THEN
        YLOCAL.REGION = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalRegion)
    END ELSE
        YLOCAL.REGION := "00"
    END
    YFIRST.DAY.YEAR = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLastYearEnd)
    EB.API.Cdt(YLOCAL.REGION,YFIRST.DAY.YEAR,"+1C")
*
** Form a list of year end dates for the enquiry period
*
    EB.Reports.setYearStartDates("")
    START.YEAR = EB.Reports.getYstartDate()[1,4] -1    ;* Find end of LAST year to get start of this year
    LOOP
        tmp = START.YEAR:"0101":EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialYearEnd)[5]
        EB.SystemTables.setComi(tmp)
        EB.API.Cfq()
        ST.DATE = EB.SystemTables.getComi()[1,8] ;
        EB.API.Cdt("", ST.DATE, "+1C")
        tmp=EB.Reports.getYearStartDates(); tmp<-1>=ST.DATE[1,6]; EB.Reports.setYearStartDates(tmp)
    UNTIL START.YEAR GE EB.Reports.getYendDate()[1,4]
        START.YEAR += 1
    REPEAT
*
* EB8901371. If the first date is in a prior year, then the first day
* of this year must be found.
*
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
*
* Find last working day
*
    YLWORK.DAY = EB.SystemTables.getToday()
    EB.API.Cdt(YLOCAL.REGION,YLWORK.DAY,"-1W")
*
    RETURN
*
*-----------------------------------------------------------------
BUILD.ENTRY.LIST:
*
    YOPERAND = EB.Reports.getDLogicalOperands()<YDATE.POS>
    EB.Reports.setYCatNo(YCATEG.LIST<1>)
    GOSUB GET.CATEG.MTHS
    GOSUB GET.CATEG.ENT.TODAY
    RETURN
*
*-------------------------------------------------------------------------
DUMMY.LIST:
*
    IF Y.ID.LIST = '' THEN
        DUMMY.ID = 'DUMMY.ID':EB.SystemTables.getTno()
        DUMMY.REC = ''
        DUMMY.REC<AC.EntryCreation.CategEntry.CatPlCategory> = EB.Reports.getYCatNo()
        DUMMY.REC<AC.EntryCreation.CategEntry.CatCurrency> = EB.Reports.getYccy()
        DUMMY.REC<AC.EntryCreation.CategEntry.CatBookingDate> = EB.Reports.getYstartDate()
        WRITE DUMMY.REC TO FV.CATEG.ENTRY, DUMMY.ID
            Y.ID.LIST = DUMMY.ID
        END
        *
        RETURN
        *
        *---------------------------------------------------------------------------
GET.CATEG.MTHS:
        *============
        *
        YFIN.YEAR = YFIRST.DAY.YEAR[1,4]
        START.DATE = YFIN.YEAR:YSTART.MONTH
        IF YENQ.LIST<1,2> NE '' THEN
            END.DATE = EB.Reports.getYendDate()[1,6]
        END ELSE
            END.DATE = EB.SystemTables.getToday()[1,6]
        END
        Y.ID.LIST = ''
        tmp.Y.CAT.NO = EB.Reports.getYCatNo()
        AC.EntryCreation.GetCategMonthEntries(START.DATE,END.DATE,tmp.Y.CAT.NO,Y.ID.LIST)

        RETURN
        *
        *---------------------------------------------------------------------------
GET.CATEG.ENT.TODAY:
        *==================

        ID.LIST = "CATEG.TODAY"
        THE.ARGS = EB.Reports.getYCatNo()
        AC.EntryCreation.GetCategEntTodayLwork("","",THE.ARGS,ID.LIST)
        IF ID.LIST <> "" THEN
            IF Y.ID.LIST THEN
                Y.ID.LIST := @FM:ID.LIST
            END ELSE
                Y.ID.LIST = ID.LIST
            END
        END
        RETURN
        *
        *---------------------------------------------------------------------
PROGRAM.ABORT:
        *------------
        *
        EB.ErrorProcessing.FatalError("E.CATEG.ENT.LIST")
        RETURN
        *-----------------------------------------------------------------------------
    END
