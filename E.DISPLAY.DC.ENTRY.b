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

* Version 2 25/10/00  GLOBUS Release No. G15.0.01 31/08/04
*-----------------------------------------------------------------------------
* <Rating>-51</Rating>
    $PACKAGE DC.Contract
    SUBROUTINE E.DISPLAY.DC.ENTRY
*
* Subroutine to convert concat record to multi.valued for
* display by enquiries and to extract STMT or CATEG entries
*
* -----------------------------------------------------------------------
* Modification Log:
* 24/08/02 - CI_10003317
*          - The total mumber of entries was displayed wrongly.
*          - when there was a long narrative. This was because,
*          - when VM were converted into SM and Narrative field is
*          - a multi-value field, it considered it as a another line.
*          - Thus resulting in a wrong number of entry.total.
*
* 07/04/05 - CI_10029037
*            I-descriptor added to show co code in report for multibook
*            As a result the co code idescriptor value is added to the
*            R.RECORD which could overwrite some of the values in this
*            concat. So change to get the list directly from disk
*            Ensures no blank values and correct entry count
*
* 21/02/07 - BG_100013081
*            CODE.REVIEW changes.
*
* 03/08/11 - Task 251357
*            Fix done to retrive data and display in enquiry for STMT.ENTRY.DETAIL
*
*------------------------------------------------------------------------

    $USING AC.EntryCreation
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Reports

*
*------------------------------------------------------------------------
*
** We must read the record from disk as R.RECORD will have been appended
** with Idescriptors afterthe last dictionary value whihc could overwrite
** one of the values.
*
    F.DATA.FILE = EB.Reports.getFDataFile()
    READ ENTRY.LIST FROM F.DATA.FILE, EB.Reports.getId() ELSE
        ENTRY.LIST = ''       ;* BG_100013081 - S
    END   ;* BG_100013081 - E

    CONVERT @FM TO @VM IN ENTRY.LIST
    tmp=EB.Reports.getRRecord(); tmp<1>=ENTRY.LIST; EB.Reports.setRRecord(tmp)
    EB.Reports.setVmCount(DCOUNT(ENTRY.LIST,@VM));* No of entries to display

    LAST.INFO.ATT = AC.EntryCreation.CategEntry.CatCrfTxnCode ;* I-descriptors after this
*
* Select file to be read
*
    FOR X = 1 TO EB.Reports.getVmCount()
        Y.ID = EB.Reports.getRRecord()<1,X>
        YKEY = Y.ID[1,1]
        Y.ID = Y.ID[2,99]
        IF YKEY = "S" THEN
            YF.FILE = "F.STMT.ENTRY"
        END ELSE
            YF.FILE = "F.CATEG.ENTRY"
        END
        *
        * Read the correct record and store in R.RECORD
        *
        GOSUB READ.FILE
        IF Y.REC EQ "" THEN
            GOSUB CHECK.DETAIL
            GOSUB READ.FILE
        END
        IF Y.REC NE "" THEN
            CONVERT @VM:@SM TO '' IN Y.REC        ;* CI_10003317 S/E
            CONVERT @FM TO @VM IN Y.REC
            FOR Z = 1 TO LAST.INFO.ATT
                tmp=EB.Reports.getRRecord(); tmp<Z+1,X>=Y.REC<1,Z>; EB.Reports.setRRecord(tmp)
            NEXT Z
        END
    NEXT X
*
    RETURN
*
READ.FILE:
*=========

    F.FILE.PATH = ''
    EB.DataAccess.Opf(YF.FILE,F.FILE.PATH)
    EB.SystemTables.setFFile(F.FILE.PATH)
*
    Y.REC = ""
    READ Y.REC FROM F.FILE.PATH, Y.ID ELSE
        Y.REC = ""  ;* BG_100013081 - S
    END   ;* BG_100013081 - E
    RETURN
*------------------------------------------------------------------------
CHECK.DETAIL:
*============
    IF YKEY = "S" THEN
        YF.FILE = "F.STMT.ENTRY.DETAIL"
    END ELSE
        YF.FILE = "F.CATEG.ENTRY.DETAIL"
    END
    RETURN
*---------------------------------------------------------------------------
    END
