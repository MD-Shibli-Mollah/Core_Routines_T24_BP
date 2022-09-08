* @ValidationCode : MjotMTkyNDA2NDkyNDpDcDEyNTI6MTU1NzQ2OTQ4MzU1ODpzdWphdGFzaW5naDozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA0LjIwMTkwMzIzLTAzNTg6NjE6MTk=
* @ValidationInfo : Timestamp         : 10 May 2019 11:54:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sujatasingh
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 19/61 (31.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190323-0358
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* <Rating>-65</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.GET.SPECIAL.NARR
*-----------------------------------------------------------------------------
*
* Subroutine to extract the Stmt narrative from the STMT.ENTRY & from the
* STMT.NARR.FORMAT which is formatted and passed from the conversion routine E.GET.NARRATIVE
*
*************************************************************************
* Modification History
*
* 20/02/14 - Defect 788937 / Task 920943
*            New line delimiter TM not working, hence from the conversion routine
*            E.GET.NARRATIVE the formatted values are passed to the R.RECORD with the old narrative values.
*
* 07/03/14 - Defect 788937 / Task 934280
*            Displays the STMT.ENTRY id if the TRANSACTION does not contain any STMT.NARR.FORMAT in the field NARR.TYPE.
*            Hence if the STMT.ENTRY does not contain any STMT.NARR.FORMAT attached then it will not reassign the R.RECORD.
*
*02/04/14 - Defect 940751 / Task 956803
*            STMT.ENT.BOOK Display an empty line for normal FT when <NL> is defined in STMT.NARR.FORMAT
*            Hence putting a validation over the variable OLD.RECORD and NARR. If null then no need to include in R.RECORD
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 03/08/16 - DEFECT 1735586 // TASK 1816019
*            Performance changes - F.READ changed to CACHE.READ
*
* 09/05/19 - Defect 3113707 / Task 3121239
*            When a special narrative has been set for a field in a STMT.ENTRY, then system is doing an unnecessary
*            read on STMT.ENTRY leading to performance issue.
*            Validation added to check if the variable Y.STMT.ID.END is not null.
*
*************************************************************************
    $USING EB.Reports
    $USING AC.EntryCreation
    $USING ST.Config

*************************************************************************
*
*  Displays the STMT.ENTRY id if the TRANSACTION does not contain any STMT.NARR.FORMAT in the field NARR.TYPE ,
*  hence if it does not contain any STMT.NARR.FORMAT then RETURN from this routine .

    GOSUB STMT.CHECK
    GOSUB TRANS.CODE.CHECK
    IF STMT.VALID OR (NOT(TRANS.CODE MATCHES '1N0N')) OR TRANS.INVALID THEN
        EB.Reports.setOData('')
        RETURN
    END ELSE
        NARR = EB.Reports.getOData()
        GOSUB PROCESS
    END

RETURN
 
*************************************************************************
STMT.CHECK:
*************************************************************************
* If the entry does not contain narrative in the transaction then it will
* contain STMT.ID in it , hence if the O.DATA is STMT.ID return from the routine

    NARR = ""
    STMT.VALID = 0
    TRANS.INVALID = 0
    tmp.O.DATA = EB.Reports.getOData()
    Y.STMT.ID.START = FIELD(tmp.O.DATA,'.',1)
    Y.STMT.ID.END = FIELD(tmp.O.DATA,'.',2)
* Validation added to check if the variable Y.STMT.ID.END is not null.
    IF (NUM(Y.STMT.ID.START) AND NUM(Y.STMT.ID.END) AND Y.STMT.ID.END NE '') OR EB.Reports.getOData()[1,2] EQ 'S!' THEN
        GOSUB READ.ENTRY
        IF NOT(ERR.STMT) THEN
            STMT.VALID = 1
        END
    END

RETURN

*************************************************************************
READ.ENTRY:
*************************************************************************

    tmp.O.DATA = EB.Reports.getOData()
    R.STMT.ENTRY = AC.EntryCreation.tableStmtEntry(tmp.O.DATA, ERR.STMT)

RETURN

*************************************************************************
TRANS.CODE.CHECK:
*************************************************************************
* If the transaction for this entry does not contain NARR.TYPE
* do not process narrative format.

    TRANS.CODE = EB.Reports.getRRecord()<4>
    IF NOT(TRANS.CODE) THEN
        TRANS.INVALID = 1
    END ELSE
        R.NARR = ST.Config.Transaction.CacheRead(TRANS.CODE,ERR)
        IF NOT(R.NARR<ST.Config.Transaction.AcTraNarrType>) THEN
            TRANS.INVALID = 1
        END
    END

RETURN

*************************************************************************
PROCESS:
*************************************************************************

    NARR.COUNT = 0
*
    OLD.RECORD = EB.Reports.getRRecord()<6>

* Formatted narrative passed from the O.DATA are
* passed to the R.RECORD<AC.STE.NARRATIVE>
    NARR.COUNT = DCOUNT(EB.Reports.getRRecord()<6>,@VM)
    Y.NARR.COUNT = DCOUNT(NARR,@VM)

* VM.COUNT value is passed by counting the actual narrative
* and the formatted narrative from the STMT.NARR.FORMAT.
    IF NARR.COUNT GT 0 THEN
        EB.Reports.setVmCount(NARR.COUNT)
    END ELSE
        EB.Reports.setVmCount(1)
    END
    tmp=EB.Reports.getRRecord(); tmp<6>=''; EB.Reports.setRRecord(tmp)
    IF NARR THEN
        IF OLD.RECORD THEN
            tmp=EB.Reports.getRRecord(); tmp<6>=OLD.RECORD:@VM:NARR; EB.Reports.setRRecord(tmp)
        END ELSE
            tmp=EB.Reports.getRRecord(); tmp<6>=NARR; EB.Reports.setRRecord(tmp)
        END
    END ELSE
        IF OLD.RECORD THEN
            tmp=EB.Reports.getRRecord(); tmp<6>=OLD.RECORD; EB.Reports.setRRecord(tmp)
        END
    END


* O.DATA passed as null to avoid duplication of the narrative which is passed to the R.RECORD .
    IF NARR THEN
        EB.Reports.setOData('')
    END
*
RETURN
*

*************************************************************************
END
