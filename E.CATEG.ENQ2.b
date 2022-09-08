* @ValidationCode : MjotMTgyOTQwNzA2OkNwMTI1MjoxNTg3NjI2Mzk1MTM0OmJoYXJhdGhzaXZhOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDQuMDoyOToyNw==
* @ValidationInfo : Timestamp         : 23 Apr 2020 12:49:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bharathsiva
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 27/29 (93.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202004.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 4 25/10/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-26</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.CATEG.ENQ2
*-----------------------------------------------------------------------------
* MODIFICATION
*
* 09/09/09 - CI_10066070
*            In case of netted entries, read original entries from
*            CATEG.ENTRY.DETAIL.
*
* 28/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 22/04/2020 - Defect 3695479 / Task 3706825
*              While running the enquiry CATEG.ENT.BOOK, it throws output with warning message.
*-----------------------------------------------------------------------------
*
    $USING EB.Reports
    $USING EB.SystemTables
    $USING AC.EntryCreation

MAIN.PARA:
*=========
*
* Select file to be read
*
    R.TMP.RECORD = ""              ;* Initialise the Variable
    YKEY = EB.Reports.getOData()
    Y.ID = FIELD(YKEY,"*",2)
    Y.AC.NO = FIELD(YKEY,"*",1)
*
* Read the correct record and store in R.RECORD
*
    GOSUB READ.FILE
    EB.Reports.setRRecord("")
    IF Y.REC <> "" THEN
        R.TMP.RECORD<1> = Y.REC<AC.EntryCreation.CategEntry.CatPlCategory>
        R.TMP.RECORD<2> = Y.REC<AC.EntryCreation.CategEntry.CatCustomerId>
        R.TMP.RECORD<3> = EB.SystemTables.getLccy()
        R.TMP.RECORD<4> = Y.REC<AC.EntryCreation.CategEntry.CatValueDate>
        R.TMP.RECORD<5> = Y.REC<AC.EntryCreation.CategEntry.CatTransactionCode>
        R.TMP.RECORD<6> = Y.REC<AC.EntryCreation.CategEntry.CatTransReference>
        R.TMP.RECORD<7> = Y.REC<AC.EntryCreation.CategEntry.CatBookingDate>
*
        R.TMP.RECORD<8> = Y.REC<AC.EntryCreation.CategEntry.CatAmountLcy>
        IF R.TMP.RECORD<6>[1,2] = 'LD' THEN
            R.TMP.RECORD<9> = Y.REC<AC.EntryCreation.CategEntry.CatTheirReference>
        END ELSE
            R.TMP.RECORD<9> = ''
        END
        EB.Reports.setRRecord(R.TMP.RECORD)
    END

RETURN
*-----------------------------------------------------------------------------
*
READ.FILE:
*=========
    Y.REC = ""
    Y.REC = AC.EntryCreation.tableCategEntry(Y.ID, ERR)
    IF Y.REC = "" THEN
        Y.REC = AC.EntryCreation.tableCategEntryDetail(Y.ID, ERR)
    END
RETURN
*-----------------------------------------------------------------------------
END
