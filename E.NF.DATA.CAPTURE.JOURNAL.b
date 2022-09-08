* @ValidationCode : Mjo4NjA1NjQ5OTg6Q3AxMjUyOjE1OTQ3ODgwOTk3NTQ6Y2tpcnViYWthcmFuOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDcuMDoxMzY6MTIz
* @ValidationInfo : Timestamp         : 15 Jul 2020 10:11:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ckirubakaran
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 123/136 (90.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>67</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DC.ModelBank
SUBROUTINE E.NF.DATA.CAPTURE.JOURNAL(DC.ENTRY)
*-----------------------------------------------------------------------------
* MODIFICATION HISTORY:
**********************
* 15/12/15 - Defect - 1404664 / Task 1569515
*            BATCH TOTAL (LCY) in Enquiry DATA.CAPTURE.JOURNAL will now also display the LCY equivalent of FCY txn's.
*
* 15/09/16 - Defect 1748523 / Task 1859926
*            BATCH field of DC.ENTRY (I-Desc) field is not showing results as it exists as junk from base.
*            When @ID is given is selection field, values are not fetched correctly changes done to correct it.
*
* 14/07/20 - Defect 3788317 / Task 3855075
*            When previous data/ entry id is given in selection criteria the enquiry is not fetchinng records
*            Code change is done to fetch proper data
*
*------------------------------------------------------------------------------

    $USING AC.EntryCreation
    $USING AC.AccountOpening
    $USING ST.Config
    $USING DC.Contract
    $USING EB.SystemTables
    $USING EB.Reports
    $USING DC.ModelBank
    $USING EB.DataAccess

    F.DC.ENTRY = ''
    FN.DC.ENTRY = 'F.DC.ENTRY'
    EB.DataAccess.Opf(FN.DC.ENTRY,F.DC.ENTRY)

    OPER.LIST = 'EQ':@FM:'RG':@FM:'LT':@FM:'GT':@FM:'NE':@FM:'LIKE':@FM:'UNLIKE':@FM:'LE':@FM:'GE':@FM:'NR'

    D.FLDS = EB.Reports.getDFields()
    D.RANGE.AND.VAL = EB.Reports.getDRangeAndValue()
    D.LOGICAL.OP = EB.Reports.getDLogicalOperands()
*
    DC.ENTRY.ID = ""
    ID.POS = ""
    LOCATE "@ID" IN D.FLDS<1> SETTING ID.POS THEN
        DC.ENTRY.ID = D.RANGE.AND.VAL<ID.POS>
        DC.ENTRY.OP.POS = D.LOGICAL.OP<ID.POS>
        DC.ENTRY.OP = OPER.LIST<DC.ENTRY.OP.POS>
    END

    SE.BATCH = 'SELECT ': FN.DC.ENTRY

    IF DC.ENTRY.ID THEN
        SE.BATCH : = ' WITH @ID ':DC.ENTRY.OP:' ':DC.ENTRY.ID
    END

* When @id is given as selection criteria then no need to check for other fields, when @id is not given as selection criteria then check for other fields
    IF NOT(DC.ENTRY.ID) THEN
        GOSUB CHECK.FOR.SELECTION.FIELDS ;* Check if other fields are given in the selection criteria
    END

    EB.DataAccess.Readlist(SE.BATCH,SELECTED.DC,'',NO.OF.REC,'')

    IF NO.OF.REC LE 0 THEN
        EB.Reports.setEnqError('No Items Selected')
    END

    FOR II = 1 TO NO.OF.REC
        R.REC = DC.Contract.Entry.Read(SELECTED.DC<II>, '')
        IF R.REC THEN
            Y.DC.ENTRY = SELECTED.DC<II>['-',2,1]
            GOSUB HEAD.DETAILS
            TOTAL.COUNT = 0
            TOTAL.COUNT = DCOUNT(R.REC,@FM)
            LCY.DR.AMOUNT = 0
            LCY.CR.AMOUNT = 0
            FCY.DR.AMOUNT = 0
            FCY.CR.AMOUNT = 0
            GOSUB GET.DETAILS
        END
    NEXT II

RETURN

HEAD.DETAILS:
***************
    HEAD.LIST = 'Transaction Code':'*':'Account/PLCategory':'*':'Title':'*':'Value Date':'*':'Time':'*':'Cr/Dr Indicator':'*':'Currency':'*':'Currency Amount':'*':'Narrative'
RETURN

GET.DETAILS:
**************
    FOR RR = 1 TO DCOUNT(R.REC,@FM)
        ENTRY.TYPE = ''
        ENTRY.ID = ''
        ENTRY.TYPE = R.REC<RR>[1,1]
        ENTRY.ID = R.REC<RR>[2,LEN(R.REC<RR>)]
        BEGIN CASE
            CASE ENTRY.TYPE = 'S'
                GOSUB READ.STMT.ENTRY
                IF RR = 1 THEN
                    DC.ENTRY<-1> = Y.DC.ENTRY:'*':COMPANY.ID:'*':HEAD.LIST
                END
                DC.ENTRY<-1> = Y.DC.ENTRY:'*':COMPANY.ID:'*':STMT.DETAILS
            CASE ENTRY.TYPE = 'C'
                GOSUB READ.CATEG.ENTRY
                IF RR = 1 THEN
                    DC.ENTRY<-1> = Y.DC.ENTRY:'*':COMPANY.ID:'*':HEAD.LIST
                END
                DC.ENTRY<-1> = Y.DC.ENTRY:'*':COMPANY.ID:'*':CATEG.DETAILS
        END CASE
    NEXT RR
RETURN

READ.STMT.ENTRY:
*******************
    STMT.DETAILS = ''
    R.STMT.REC = AC.EntryCreation.StmtEntry.Read(ENTRY.ID, '')

    IF R.STMT.REC = '' THEN
        R.STMT.REC = AC.EntryCreation.StmtEntryDetail.Read(ENTRY.ID, '')
    END
    COMPANY.ID = R.STMT.REC<2>
    AMOUNT.CCY = ''
    AMOUNT.LCY = ''
    CCY.TYPE = ''
    AMOUNT.LCY = R.STMT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>
    IF R.STMT.REC<AC.EntryCreation.StmtEntry.SteCurrency> EQ EB.SystemTables.getLccy() THEN
        AMOUNT.CCY = R.STMT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>
        CCY.TYPE = EB.SystemTables.getLccy()
    END ELSE
        AMOUNT.CCY = R.STMT.REC<AC.EntryCreation.StmtEntry.SteAmountFcy>
    END

    IF AMOUNT.CCY LT 0 THEN
        CR.DR.IND = 'D'
    END ELSE
        CR.DR.IND = 'C'
    END
    TIME.ENTRY = R.STMT.REC<AC.EntryCreation.StmtEntry.SteDateTime>
    TIME.DISP = TIME.ENTRY[7,2]:':':TIME.ENTRY[2]
    R.ACC.REC = AC.AccountOpening.Account.Read(R.STMT.REC<AC.EntryCreation.StmtEntry.SteAccountNumber>, '')
    TITLE = R.ACC.REC<AC.AccountOpening.Account.AccountTitleOne,1>
    CONVERT '*' TO '' IN TITLE
    STMT.DETAILS = R.STMT.REC<AC.EntryCreation.StmtEntry.SteTransactionCode>:'*':R.STMT.REC<AC.EntryCreation.StmtEntry.SteAccountNumber>:'*':TITLE:'*':R.STMT.REC<AC.EntryCreation.StmtEntry.SteValueDate>:'*':TIME.DISP:'*':CR.DR.IND:'*':R.STMT.REC<AC.EntryCreation.StmtEntry.SteCurrency>:'*':AMOUNT.CCY:'*':R.STMT.REC<AC.EntryCreation.StmtEntry.SteNarrative,1>:'*':CCY.TYPE:'*':TOTAL.COUNT:'*':AMOUNT.LCY

RETURN

READ.CATEG.ENTRY:
*******************
    CATEG.DETAILS = ''
    R.CATEG.REC = AC.EntryCreation.CategEntry.Read(ENTRY.ID, '')
    IF R.CATEG.REC = '' THEN
        R.CATEG.REC = AC.EntryCreation.CategEntryDetail.Read(ENTRY.ID, '')
    END
    AMOUNT.CCY = ''
    CCY.TYPE = ''
    AMOUNT.LCY = ''
    COMPANY.ID = R.CATEG.REC<2>
    AMOUNT.LCY = R.CATEG.REC<AC.EntryCreation.CategEntry.CatAmountLcy>
    IF R.CATEG.REC<AC.EntryCreation.CategEntry.CatCurrency> EQ EB.SystemTables.getLccy() THEN
        AMOUNT.CCY = R.CATEG.REC<AC.EntryCreation.CategEntry.CatAmountLcy>
        CCY.TYPE = EB.SystemTables.getLccy()
    END ELSE
        AMOUNT.CCY = R.CATEG.REC<AC.EntryCreation.CategEntry.CatAmountFcy>
    END
    IF AMOUNT.CCY LT 0 THEN
        CR.DR.IND = 'D'
    END ELSE
        CR.DR.IND = 'C'
    END
    TIME.ENTRY = R.CATEG.REC<AC.EntryCreation.CategEntry.CatDateTime>
    TIME.DISP = TIME.ENTRY[7,2]:':':TIME.ENTRY[2]
    R.CAT.REC = ST.Config.Category.Read(R.CATEG.REC<AC.EntryCreation.CategEntry.CatPlCategory>, '')
    TITLE = R.CAT.REC<ST.Config.Category.EbCatDescription,1>
    CONVERT '*' TO '' IN TITLE
    CATEG.DETAILS = R.CATEG.REC<AC.EntryCreation.CategEntry.CatTransactionCode>:'*':R.CATEG.REC<AC.EntryCreation.CategEntry.CatPlCategory>:'*':TITLE:'*':R.CATEG.REC<AC.EntryCreation.CategEntry.CatValueDate>:'*':TIME.DISP:'*':CR.DR.IND:'*':R.CATEG.REC<AC.EntryCreation.CategEntry.CatCurrency>:'*':AMOUNT.CCY:'*':R.CATEG.REC<AC.EntryCreation.CategEntry.CatNarrative,1>:'*':CCY.TYPE:'*':TOTAL.COUNT:'*':AMOUNT.LCY

RETURN
*-----------------------------------------------------------------------------
*** <region name= CHECK.FOR.SELECTION.FIELDS>
*** <desc>Check if any fields are given in selection criteria other than @id </desc>
CHECK.FOR.SELECTION.FIELDS:

*removed this selection criteria as records created less than TODAY is not fetched
* change the code to loop the selection fields and form the new query

    FIRST.TIME ='1'
    LOOP
        REMOVE Y.NAME FROM D.FLDS SETTING Y.NAME.POS
        REMOVE Y.VALUES FROM D.RANGE.AND.VAL SETTING Y.VALUES.POS
        REMOVE Y.OPERAND FROM D.LOGICAL.OP SETTING  Y.OPERAND.POS
    WHILE Y.NAME : Y.VALUES.POS
        IF Y.VALUES NE '' THEN
            IF FIRST.TIME THEN
                SE.BATCH : = ' WITH '
            END ELSE
                SE.BATCH : = 'AND '
            END
            SE.BATCH : =  Y.NAME : ' ' : OPER.LIST<Y.OPERAND> : ' "' : Y.VALUES : '"'
            
            FIRST.TIME ='0'
        END
    REPEAT
       
    IF FIRST.TIME THEN
        SE.BATCH : = ' WITH DATE EQ ': EB.SystemTables.getToday()
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
