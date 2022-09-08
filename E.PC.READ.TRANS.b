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
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
* Version 2 25/10/00  GLOBUS Release No. 200508 30/06/05

    $PACKAGE PC.Contract
    SUBROUTINE E.PC.READ.TRANS
*-----------------------------------------------------------------------------

* This routine runs from the enquiry PC.TRANSACTION.JNL and will
* fetch data from either STMT/CATEG entry and populate R.RECORD
* The id's will be passed in O.DATA as   S*<ENTRYID> or C*<ID>

*     S*<ID> - points to a stmt entry
*     C*<ID> - points to a categ entry

*-----------------------------------------------------------------------------
    $USING AC.EntryCreation
    $USING EB.DataAccess
    $USING EB.Reports
    $USING PC.Contract


    tmp.O.DATA = EB.Reports.getOData()
    IF INDEX(tmp.O.DATA,"*",1) THEN        ; * value passed in is ok
        ENTRY.POINTER = TRIM(FIELD(tmp.O.DATA,'*',1))           ; * S or C
        ENTRY.ID = TRIM(FIELD(tmp.O.DATA,'*',2))
    END ELSE
        EB.Reports.setRRecord('')
        RETURN
    END

    BEGIN CASE

        CASE ENTRY.POINTER EQ 'S'
            GOSUB GET.STMT.REC

        CASE ENTRY.POINTER EQ 'C'
            GOSUB GET.CATEG.REC

        CASE 1

    END CASE

    RETURN

GET.STMT.REC:

    EB.Reports.setRRecord("")
    STMT.RECORD = AC.EntryCreation.StmtEntry.Read(ENTRY.ID, ERR)
    EB.Reports.setRRecord(STMT.RECORD)
    IF ERR THEN
        EB.Reports.setRRecord('')
    END
    RETURN

GET.CATEG.REC:

    EB.Reports.setRRecord('')
    CATEG.RECORD = EB.Reports.getRRecord()
    CATEG.RECORD = AC.EntryCreation.CategEntry.Read(ENTRY.ID, ERTXT)
    EB.Reports.setRRecord(CATEG.RECORD)

    IF ERTXT THEN
        EB.Reports.setRRecord('')
    END

    RETURN
*-----------------------------------------------------------------------------

    END
