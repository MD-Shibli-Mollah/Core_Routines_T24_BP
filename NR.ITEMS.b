* @ValidationCode : MjotNDkwMTAxNzcyOkNwMTI1MjoxNTg5MTc3NDY1ODExOmJoYXJhdGhzaXZhOjY6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDQuMDoxMDkzOjMzNw==
* @ValidationInfo : Timestamp         : 11 May 2020 11:41:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bharathsiva
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 337/1093 (30.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202004.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>11335</Rating>
*-----------------------------------------------------------------------------
* Version 13 07/06/01  GLOBUS Release No. G12.0.00 29/06/01

$PACKAGE NR.Contract
SUBROUTINE NR.ITEMS

************************************************************************
*                                                                      *
*  This program defines the items files and allows the user to enter   *
*  matching ids to manually match an item. All other fields are        *
*  non-input fields.                                                   *
*  Initially, the record is created by the statement transfer process  *
*  and records are only ever updated by either the automatic or manual *
*  matching process.                                                   *
*                                                                      *
*  GB9800026 - 06 Feb 1998                                             *
*  GB9800302 - 27 Mar 1998                                             *
*                                                                      *
*----------------------------------------------------------------------*
*                    M O D I F I C A T I O N S                         *
*----------------------------------------------------------------------*
*                                                                      *
* 29/05/98 - GB9800576                                                 *
*            Ensure unmatched split is created for the correct side    *
*            and sign (i.e. ledger/statement and debit/credit)         *
*                                                                      *
* 14/10/99 - GB9900964 Do not create a split rec unless match id's     *
*            and remainder gt tolerance. Was creating a split rec if   *
*            e.g. the notes field was changed                          *
*            In addition, s/r CHECK.FUNCTION was updated to disallow   *
*            copy/reversal in addition to verify                       *
*
* 11/04/02 - CI_10000591
*            When manual matching if there is a difference amount & when
*            the override "USD.XXX  to excess cents bucket" is set Yes
*            Excess.Cents fld has to be populated
*
* 11/04/02 - CI_10000638
*            UNAUTH.MATCHED.ID was not getting cleared at authorisation.
*
*15/MAY/02 - CI_10001901
*            Changed the Date field length to 11 from 8. This was done bcoz
*            if length is 8, Date is not displayed properly in Versions.
*
*12/09/02 - CI_10003646
*           CASE statement introduced by GB9900964 removed and code refined
*           to clear off UNAUTH.MATCHED.ID at authorisation stage.
*
* 21/09/02 - EN_10001197
*            Conversion of error messages to error codes.
*
* 22/01/03 - CI_10006338
*            When the amount format is ., in [D[D[D[D[D[D[D[D[[C[CUser, the amount is multipled
*            by 100.
* 27/01/03 - EN_10001513
*            Sub-Account processing  the item for sub account will be under the master account
* the sub-account will be added to the NR.ITEM
*
*
* 05/03/03 - CI_10007205
*            The ORIGINAL.REF and MATCHED.ID were the same in the SPLIT item
*            created in one to many matching.  This problem is solved by
*            making the ORIGINAL.REF in CREATE.SPLIT.ITEM para, to point to
*            ID.NEW.
*
* 01/04/03 - CI_10007845
*            During a one to many matching,when a stmt id is matched with ledger
*            and a statement item, a split for ledger item gets created.
*            In the para, CREATE.SPLIT.ITEM, assign R.SPLIT = R.NEW(NR.ITEM.STMT.OR.LEDGER)
*
* 12/05/03 - CI_10009036
*            Error Message is raised in 1 to 1 matching case
*            to enforce the user to match higher amt with smaller
*            amt and not vice versa, in order to ensure that split
*            entries is created with proper org.ref/amt details.
*
* 09/07/03 - CI_10010626
*            Changed the error message in cross validation done to ci_10009036.
*
* 24/07/03 - CI_1001127
*            When doing a one-many manual matching, the ACCT.OWNER.REF,
*            ACCT.INST.REC are populated incorrectly for the split items.
*            Code changed to rectify this.
*
* 21/10/03 - CI_10013874
*            In the CHECK.RECORD para, instead of assigning R.NEW(AF)<1,AV,AS>
*            to R.NR.ITEMS<NR.ITEM.AMOUNT> use COMI to storethe value and
*            Call IN2AMT
*
* 09/01/04 - EN_10002145
*            Company level Parameters in a MB environment - So, read
*            NR.PARAMETER with id as ID.COMPANY.
*
* 24/02/05 - CI_10027719
*            MATCHING.KEYS holds the TRANS.TYPE field of NR.PARAMETER
*            separated by VMs. Hence the LOCATE for TRANS.TYPE in
*            MATCHING.KEYS should also use VMs instead of FM.
*
* 19/04/08 - CI_10054836(CSS REF:HD0805823)
*            Maximum number of characters allowed for MATCHED.ID field is changed
*            from 10 to 27 as that of the Id of NR.ITEMS.
*
* 13/08/08 - CI_10057314
*            Formation of NR.INDEX id is corrected. TRANS.TYPE is appended only
*            if the same is present in NR.PARAMETER.
*
* 14/10/08 - CI_10058249
*            Enrichment made to display as per user set value in amount format
*            of user record.
*
* 04/11/08 - CI_10058663
*            Enrichment made to display even while inputting amount field.
*
* 20/04/09 - CI_10062301
*            While forming override message, the location of the field in the
*            STANDARD.SELECTION should be fetched correctly
*
* 30/04/09 - CI_10062559
*            Field DATE.MATCHED not cleared after revoking the matching process.
*
* 28/05/09 - CI_10063222
*            Validation is added to check the statement item whether it was
*            already used with another ledger item or not.
*
* 26/08/10 - Task 78588 / REF: Defect 75317
*            The field UNAUTH.MATCH.ID is not clearing even though the MATCH.ID field
*            value is changed from one item to another item. This causes the problem
*            of throwing error while MATCH this NR.ITEM which contains the value in the
*            UNAUTH.MATCH.ID to another NR.ITEM.
*
* 30/11/10 - Task 113911
*            Performance problem when the query runs on the STMT.OR.LEDGER in NR.ITEMS.
*
* 02/08/11 - Task - 163756, SI - 149432
*            Replacement of NR.AUTOMATCH single threaded to service.
*
* 25/06/13 - Defect :708326 Task :712968
*            All Hard coded OVERRIDE's are replaced to OVERRIDE records in NR.ITEMS
*
* 07/10/13 - Defect 749974 / Task - 753852
*    validation triggered twice in Browser, So R.OLD and R.NEW value set to match ID
*    in second time and error raised. But while validating through putty validation triggered one time.Hence error didn't raised.
*
* 04/10/13 - Task 800902
*            while opening the NR.ITEMS record from branch company, system throws the error
*            message as 'CANNOT READ NR.PARAMETER RECORD - XXXXXXXXX'
*
* 06/03/14 - Task 931569
*            While running a NR.PROCESS.MESSAGE service with multiple agents, some
*            NR.ITEMS record is missing.
*
* 19/09/13 - Task 937892
*            While matching the NR.LEDGER and NR.STATEMENT, system not showing the
*            'pick Item' option.
*
* 08/05/14 - Task 992451
*            Space in NR.INDEX id coverted to ? to avoid missing/ignoring part of the
*            id available after the space
*
*
* 28/05/14 - Task 1012164
*            Sequence number in NR.ITEM id made as variable length which vary from 18 to 22.R operation
*            to parse the right most 22 characerters removed and repalced with FIELD operation to parse the
*            sequence number after . operator.
*
* 09/02/15 - Defect 1224671 - Task 1231141
*            Fields related to MATCH in R.NEW are not cleared if the record is in INAU status to avoid
*            TXN CANCELLED error while committing NR.ITEMS record after changing the MATCHED.ID value
*            from INAU status.
*			 When more than one item is matched, UNAUTH.MATCH.ID field in all the old matched items are cleared,
*			 to make them enable to match with other items.
*
* 04/05/15 - Defect 1327510 / Task 1335156
*            This field "DEBIT.OR.CREDIT" is defined as numeric but contains values of �D� or �C. Hence causes
*            problem in the output of the enquiry NR.ITEMS.LEDGER in TAFJ.
*
* 06/05/15 - Defect 1321592 / Task 1336979
*            CheckFile operation for Matched ID field is removed.
*            Valid sequence number is allowed to be inputted in Matched Id field during Manual Matching
*            using a version or direct input in NR.ITEMS table.
*
* 11/08/16 - Defect 1806308 / Task 1820958
*            On validating NR.ITEMS record placed in Hold, "ALREADY MATCHED" error is thrown.
*            Validation modified to avoid the error while validating the records in Hold.
*
* 22/08/16 - Defect 1825438 / Task 1834327
*            The field "ACCOUNT.CURRENCY" is updated as Alphanumeric field so that the enquiry
*            works properly when ACCOUNT.CURRENCY is used as selection criteria.
*
* 02/06/17 - Defect 2140930 / Task 2146089
*            Fields FUNDS.CODE, TRANS.TYPE, ACC.OWNER.REF, ACC.INST.REF and SUPPLEMENTARY are
*            updated as Alphanumeric fields so that Long listing commmand displays NR.ITEMS
*            records without any error when any of these fields is used as selection criteria.
*
* 29/11/19 - Defect 3384218 / Task 3461188
*            Multi value position is assigned properly so that remaining split item is
*            calculated properly on manual matching of ledger items with statement items.
*
* 08/01/20 - Defect 3514546 / Task 3525837
*            When validating the NR.ITEMS record, the error message is truncated and not shown properly.
*
* 11/05/20 - Defect 3721792 / Task 3735024
*            No error is thrown when MATCHED.ID field in NR.ITEMS record is inputted with value "."
***************************************************************************************

    $USING AC.AccountOpening
    $USING ST.CurrencyConfig
    $USING EB.SystemTables
    $USING NR.Contract
    $USING ST.Config
    $USING EB.Security
    $USING ST.CompanyCreation
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.Template
    $USING EB.ErrorProcessing
    $USING EB.Utility
    $USING EB.OverrideProcessing
    $USING EB.API
    $USING EB.DataAccess


    GOSUB DEFINE.PARAMETERS

    IF LEN(EB.SystemTables.getVFunction()) GT 1 THEN
        GOTO V$EXIT
    END

    EB.Display.MatrixUpdate()

    GOSUB INITIALISE          ;* Special Initialising

*************************************************************************

* Main Program Loop

    LOOP

        EB.TransactionControl.RecordidInput()

    UNTIL (EB.SystemTables.getMessage() EQ 'RET')

        V$ERROR = ''

        IF EB.SystemTables.getMessage() EQ 'NEW FUNCTION' THEN
            GOSUB CHECK.FUNCTION        ;* Special Editing of Function

            IF EB.SystemTables.getVFunction() EQ 'E' OR EB.SystemTables.getVFunction() EQ 'L' THEN
                EB.Display.FunctionDisplay()
                EB.SystemTables.setVFunction('')
            END

        END ELSE

            GOSUB CHECK.ID    ;* Special Editing of ID
            IF V$ERROR THEN GOTO MAIN.REPEAT

            EB.TransactionControl.RecordRead()

            IF EB.SystemTables.getMessage() EQ 'REPEAT' THEN
                GOTO MAIN.REPEAT
            END

            EB.Display.MatrixAlter()

            GOSUB CHECK.RECORD          ;* Special Editing of Record
            IF V$ERROR THEN GOTO MAIN.REPEAT

*            GOSUB PROCESS.DISPLAY           ;* For Display applications

            LOOP
                GOSUB PROCESS.FIELDS    ;* ) For Input
                GOSUB PROCESS.MESSAGE   ;* ) Applications
            WHILE (EB.SystemTables.getMessage() EQ 'ERROR') REPEAT

        END

MAIN.REPEAT:
    REPEAT

V$EXIT:
RETURN          ;* From main program

*************************************************************************
*                      S u b r o u t i n e s                            *
*************************************************************************

PROCESS.FIELDS:

* Input or display the record fields.

* jump to the matched.to field irrespective of where it is on the
* screen (ie. first field or n'th field)

    EB.SystemTables.setTSequ(NR.Contract.Items.ItemMatchedId)

    LOOP
        IF EB.SystemTables.getScreenMode() EQ 'MULTI' THEN
            IF EB.SystemTables.getFileType() EQ 'I' THEN
                EB.Display.FieldMultiInput()
            END ELSE
                EB.Display.FieldMultiDisplay()
            END
        END ELSE
            IF EB.SystemTables.getFileType() EQ 'I' THEN
                EB.Display.FieldInput()
            END ELSE
                EB.Display.FieldDisplay()
            END
        END

    WHILE NOT(EB.SystemTables.getMessage())

        GOSUB CHECK.FIELDS    ;* Special Field Editing

        IF EB.SystemTables.getTSequ() NE '' THEN tmp=EB.SystemTables.getTSequ(); tmp<-1>=EB.SystemTables.getA() + 1; EB.SystemTables.setTSequ(tmp)

    REPEAT

RETURN

*************************************************************************

PROCESS.MESSAGE:

* Processing after exiting from field input (PF5)

    IF EB.SystemTables.getMessage() EQ 'VAL' THEN
        EB.SystemTables.setMessage('')
        BEGIN CASE
            CASE EB.SystemTables.getVFunction() EQ 'D'
                GOSUB CHECK.DELETE          ;* Special Deletion checks
            CASE EB.SystemTables.getVFunction() EQ 'R'
                GOSUB CHECK.REVERSAL        ;* Special Reversal checks
            CASE 1
                GOSUB CROSS.VALIDATION      ;* Special Cross Validation
        END CASE

        IF NOT(V$ERROR) THEN
            GOSUB BEFORE.UNAU.WRITE     ;* Special Processing before write
        END

        IF NOT(V$ERROR) THEN
            EB.TransactionControl.UnauthRecordWrite()
REM >       IF MESSAGE NE "ERROR" THEN
REM >          GOSUB AFTER.UNAU.WRITE          ;* Special Processing after write
REM >       END
        END

    END

    IF EB.SystemTables.getMessage() EQ 'AUT' THEN
REM >    GOSUB AUTH.CROSS.VALIDATION          ;* Special Cross Validation

        IF NOT(V$ERROR) THEN
            GOSUB BEFORE.AUTH.WRITE     ;* Special Processing before write
        END

        IF NOT(V$ERROR) THEN
            EB.TransactionControl.AuthRecordWrite()

REM >       IF MESSAGE NE "ERROR" THEN
REM >          GOSUB AFTER.AUTH.WRITE          ;* Special Processing after write
REM >       END
        END

    END

RETURN

*************************************************************************

PROCESS.DISPLAY:

* Display the record fields.

    IF EB.SystemTables.getScreenMode() EQ 'MULTI' THEN
        EB.Display.FieldMultiDisplay()
    END ELSE
        EB.Display.FieldDisplay()
    END

RETURN

*-----------------------------------------------------------------------


*--------
CHECK.ID:
*--------

* Validation and changes of the ID entered.  Set ERROR to 1 if in error.

    ID.NEW.VAL = EB.SystemTables.getIdNew()
    IF INDEX(ID.NEW.VAL,'.',1) THEN
        ACCOUNT.NO = FIELD(ID.NEW.VAL,'.',1)
        ITEM.SEQ = FIELD(ID.NEW.VAL,'.',2)
        EXCESS.BUCKET = ''

        EB.SystemTables.setComi(ACCOUNT.NO)
        EB.Template.In2ant('16','ANT')
        ACCOUNT.NO = EB.SystemTables.getComi()

        IF EB.SystemTables.getEtext() THEN
            EB.SystemTables.setE('NR.NRI.INVALID.AC.NO')
            EB.SystemTables.setEtext('')
        END

        IF NOT(NUM(ITEM.SEQ)) THEN
            BEGIN CASE
                CASE ITEM.SEQ = 'WE'
                    EXCESS.BUCKET = 1
                CASE ITEM.SEQ = 'THEY'
                    EXCESS.BUCKET = 1
                CASE 1
                    EB.SystemTables.setE('NR.NRI.INVALID.FORMAT.KEY,PLEASE.RETYPE')
                    EB.SystemTables.setEtext('E')
            END CASE
        END
    END ELSE
        EB.SystemTables.setE('NR.NRI.INVALID.FORMAT.KEY,PLEASE.RETYPE')
        EB.SystemTables.setEtext('')
    END

    IF EB.SystemTables.getE() THEN
        V$ERROR = 1
        EB.ErrorProcessing.Err()
    END ELSE
        IF NUM(ITEM.SEQ) THEN
            EB.SystemTables.setIdNew(ACCOUNT.NO:'.':ITEM.SEQ)
        END
    END

RETURN


*------------
CHECK.RECORD:
*------------

* Validation and changes of the Record.  Set ERROR to 1 if in error.

    MATCH.CHECKS = ''

    EB.SystemTables.setAf(NR.Contract.Items.ItemAmount)

    AF.POS = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(AF.POS) ELSE
        EB.SystemTables.setE('NR.NRI.REC.DOES.NOT.EXIST')
    END

    EB.SystemTables.setAf(NR.Contract.Items.ItemMatchedId)
    AF.POS = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(AF.POS) NE '' THEN
        MATCHED.IDS = DCOUNT(EB.SystemTables.getRNew(AF.POS)<1>,@VM)
        FOR CHECK.LOOP = 1 TO MATCHED.IDS
            NR.ITEMS.ID = EB.SystemTables.getRNew(AF.POS)<1,CHECK.LOOP>

            GOSUB GET.ITEM.DETAILS

            IF EB.SystemTables.getEtext() ELSE
                MATCH.CHECKS<1,-1> = NR.ITEMS.ID
                MATCH.CHECKS<2,-1> = R.NR.ITEMS<NR.Contract.Items.ItemAmount>

                SAVE.COMI = EB.SystemTables.getRNew(AF.POS)<1,CHECK.LOOP>         ;* CI_10013874 S/E
                EB.SystemTables.setComi(R.NR.ITEMS<NR.Contract.Items.ItemAmount>)
*               SAVE.AF = R.NEW(AF)<1,AV,AS>        ; * CI_10006338  S/E , CI_10013874(Commented)
*               R.NEW(AF)<1,AV,AS> = R.NR.ITEMS<NR.ITEM.AMOUNT>         ; * CI_10006338 S/E , CI_10013874(Commented)
                IF EB.SystemTables.getRUser()<EB.Security.User.UseAmountFormat> THEN
                    COMI.VAL = EB.SystemTables.getComi()
                    CONVERT ",." TO EB.SystemTables.getRUser()<EB.Security.User.UseAmountFormat> IN COMI.VAL
                    EB.SystemTables.setComi(COMI.VAL);* Convert the format to user format
                END
                EB.Template.In2amt('19','AMT')
                ENRIX = EB.SystemTables.getVDisplay() 'R#19':'  ':R.NR.ITEMS<NR.Contract.Items.ItemDebitOrCredit> 'L#4'
*               R.NEW(AF)<1,AV,AS> = SAVE.AF        ; * CI_10006338  S/E , CI_10013874(Commented)
                EB.SystemTables.setComi(R.NR.ITEMS<NR.Contract.Items.ItemValueDate>)
                EB.Utility.InTwod('11','D')
                ENRIX := EB.SystemTables.getVDisplay():' ':R.NR.ITEMS<NR.Contract.Items.ItemStmtOrLedger>

                LOCATE EB.SystemTables.getAf():'.':CHECK.LOOP IN EB.SystemTables.getTFieldno()<1> SETTING POS THEN
                    tmp=EB.SystemTables.getTEnri(); tmp<POS>=ENRIX; EB.SystemTables.setTEnri(tmp)
                END

                EB.SystemTables.setComi(SAVE.COMI);* CI_10013874 S/E
            END
        NEXT CHECK.LOOP
    END

END.CHECK.RECORD:

    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setEtext('')
        V$ERROR = 1
        EB.ErrorProcessing.Err()
    END

RETURN


*------------
CHECK.FIELDS:
*------------

    AF.POS = EB.SystemTables.getAf()
    COMI.VAL = EB.SystemTables.getComi()
    ID.NEW.VAL = EB.SystemTables.getIdNew()
    BEGIN CASE

        CASE AF.POS = NR.Contract.Items.ItemMatchedId

            IF COMI.VAL THEN
                CHECK.ACC = FIELD(COMI.VAL,'.',1)
                CHECK.SEQ = FIELD(COMI.VAL,'.',2)

                BEGIN CASE
                    CASE NOT(NUM(CHECK.ACC))
                        EB.SystemTables.setComi(CHECK.ACC)
                        EB.Template.In2ant('16','ANT')
                        COMI.VAL = EB.SystemTables.getComi()
                        CHECK.ACC = COMI.VAL

                        IF EB.SystemTables.getEtext() THEN
                            EB.SystemTables.setE('NR.NRI.INVALID.AC.NO')
                            GOTO FIELD.ERROR
                        END

* Case where sequence number alone is provided in Matched ID field

                    CASE COMI.VAL AND NOT(INDEX(COMI.VAL, '.', 1))
                        CHECK.ACC = FIELD(ID.NEW.VAL,'.',1)
                        CHECK.SEQ = COMI.VAL
                END CASE

                IF LEN(CHECK.ACC) LT LEN(FIELD(ID.NEW.VAL,'.',1)) THEN
                    CHECK.ACC = CHECK.ACC 'R%':LEN(ID.NEW.VAL)
                END

                IF LEN(CHECK.SEQ) LT 10 THEN
                    IF CHECK.SEQ = '' THEN
                        EB.SystemTables.setE('NR.NRI.INVALID.ITEM.PLEASE.RETYPE')
                        GOTO FIELD.ERROR
                    END ELSE
                        CHECK.SEQ = FIELD(CHECK.SEQ,'.',2)
                    END
                END

                COMI.VAL = CHECK.ACC:'.':CHECK.SEQ
                EB.SystemTables.setComi(COMI.VAL)

* alpha character added, because of uniVerse bug
* (e.g.  0000012345.0000000012 = 0000012345.0000000345 is
*  evaluated as being true)

                IF EB.SystemTables.getRNew(NR.Contract.Items.ItemUnauthMatchId) THEN
                    IF COMI.VAL:'x' NE EB.SystemTables.getRNew(NR.Contract.Items.ItemUnauthMatchId):'x' THEN
                        EB.SystemTables.setE('NR.NRI.ALRDY.SELECTED.MATCH')
                        GOTO FIELD.ERROR
                    END
                END

                MATCH.ERROR = ''
                NR.ITEMS.ID = COMI.VAL
                ORIGINAL.AMOUNT = EB.SystemTables.getRNew(NR.Contract.Items.ItemAmount)

                GOSUB TIDY.MATCH.CHECKS

                LOCATE COMI.VAL IN MATCH.CHECKS<1,1> SETTING POS THEN
                    IF EB.SystemTables.getROld(NR.Contract.Items.ItemMatchedId) NE '' THEN
                        EB.SystemTables.setE('NR.NRI.ALRDY.MATCHED.WITH.REC')
                        GOTO FIELD.ERROR
                    END
                END


                GOSUB GET.ITEM.DETAILS

                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    EB.SystemTables.setEtext('')
                    GOTO FIELD.ERROR
                END

                IF R.NR.ITEMS<NR.Contract.Items.ItemAmount> + SUM(MATCH.CHECKS<2>) GT EB.SystemTables.getRNew(NR.Contract.Items.ItemAmount) THEN
                    IF EB.SystemTables.getAv() GT 1 THEN
                        EB.SystemTables.setE('NR.NRI.AMT.EXCEEDED')
                        GOTO FIELD.ERROR
                    END
                END
                MATCH.ID = COMI.VAL
                GOSUB VALIDATE.MATCH
            
                IF MATCH.ERROR THEN
                    EB.SystemTables.setE(MATCH.ERROR)
                END ELSE
                    AV.POS = EB.SystemTables.getAv()
                    AS.POS = EB.SystemTables.getAs()
                    MATCH.CHECKS<1,AV.POS> = COMI.VAL
                    MATCH.CHECKS<2,AV.POS> = R.NR.ITEMS<NR.Contract.Items.ItemAmount>
                    MATCHED.TOTAL = SUM(MATCH.CHECKS<2>)
                    IF R.NR.ITEMS NE '' THEN
                        SAVE.COMI = COMI.VAL
                        AF.POS = EB.SystemTables.getAf()
                        SAVE.AF = EB.SystemTables.getRNew(AF.POS)<1,AV.POS,AS.POS>  ;* CI_10006338 S/E

                        EB.SystemTables.setComi(R.NR.ITEMS<NR.Contract.Items.ItemAmount>)
                        tmp=EB.SystemTables.getRNew(AF.POS); tmp<1,AV.POS,AS.POS>=R.NR.ITEMS<NR.Contract.Items.ItemAmount>; EB.SystemTables.setRNew(AF.POS, tmp);* CI_10006338 S/E
                        IF EB.SystemTables.getRUser()<EB.Security.User.UseAmountFormat> THEN
                            COMI.VAL = EB.SystemTables.getComi()
                            CONVERT ",." TO EB.SystemTables.getRUser()<EB.Security.User.UseAmountFormat> IN COMI.VAL    ;* Convert the format to user format
                            EB.SystemTables.setComi(COMI.VAL)
                        END
                        EB.Template.In2amt('19','AMT')
                        ENRIX = EB.SystemTables.getVDisplay() 'R#19':'  ':R.NR.ITEMS<NR.Contract.Items.ItemDebitOrCredit> 'L#4'

                        EB.SystemTables.setComi(R.NR.ITEMS<NR.Contract.Items.ItemValueDate>)
                        EB.Utility.InTwod('11','D')
                        ENRIX := EB.SystemTables.getVDisplay():' ':R.NR.ITEMS<NR.Contract.Items.ItemStmtOrLedger>

                        EB.SystemTables.setComi(SAVE.COMI)
                        tmp=EB.SystemTables.getRNew(AF.POS); tmp<1,AV.POS,AS.POS>=SAVE.AF; EB.SystemTables.setRNew(AF.POS, tmp);* CI_10006338 S/E
                        EB.SystemTables.setComiEnri(ENRIX)
                    END

                    AF.POS = EB.SystemTables.getAf()
                    CURRENT.VALUES = DCOUNT(EB.SystemTables.getRNew(AF.POS)<1>,@VM)
                    IF CURRENT.VALUES AND (EB.SystemTables.getAv() GT CURRENT.VALUES) THEN
                        tmp=EB.SystemTables.getRNew(AF.POS); tmp<1,AV.POS + 1>=''; EB.SystemTables.setRNew(AF.POS, tmp)
                        EB.Display.RebuildScreen()
                    END
                END
            END
    END CASE

FIELD.ERROR:

    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setTSequ("IFLD")
        EB.ErrorProcessing.Err()
    END

RETURN

*----------------
CROSS.VALIDATION:
*----------------


REM > CALL XX.CROSS.VALIDATION
*
    EB.SystemTables.setText('')
    EB.SystemTables.setEtext('')
    V$ERROR = ''

    EB.SystemTables.setAf(NR.Contract.Items.ItemMatchedId)

    AF.POS = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(AF.POS) NE '' THEN   ;* Changed to proper IF Condition for validating the AF value correctly
        MATCHED.IDS = DCOUNT(EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId),@VM)
        ORIGINAL.AMOUNT = EB.SystemTables.getRNew(NR.Contract.Items.ItemAmount)
        SHORT.AND.OVER = ''   ;* shortages and overages
* ie. excess cents

        MATCHED.ID = EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId)
        IF MATCHED.ID<1,MATCHED.IDS> = '' THEN
            DEL MATCHED.ID<1,MATCHED.IDS>
            EB.SystemTables.setRNew(NR.Contract.Items.ItemMatchedId,MATCHED.ID)
            MATCHED.IDS -= 1
        END

        FOR UPDATE.LOOP = 1 TO MATCHED.IDS
            NR.ITEMS.ID = EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId)<1,UPDATE.LOOP>
            MATCH.ERROR = ''
            EB.SystemTables.setAv(UPDATE.LOOP)

            GOSUB GET.ITEM.DETAILS

            IF EB.SystemTables.getEtext() THEN
                EB.ErrorProcessing.StoreEndError()
                RETURN
            END
            MATCH.ID = EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId)
            GOSUB VALIDATE.MATCH

            IF MATCH.ERROR THEN
                EB.SystemTables.setE(MATCH.ERROR)
                EB.SystemTables.setEtext(EB.SystemTables.getE())
                EB.ErrorProcessing.StoreEndError()
                EB.SystemTables.setE("")
                RETURN
            END
        NEXT UPDATE.LOOP

        IF ORIGINAL.AMOUNT NE SUM(MATCH.CHECKS<2>) THEN
            IF R.NR.PARAMETER<NR.Contract.Parameter.ParamSplitItems> NE 'Y' THEN
                EB.SystemTables.setE('NR.NRI.ITEM.SPLITTING.NOT.PERMITTED')
                EB.SystemTables.setEtext(EB.SystemTables.getE())
                EB.ErrorProcessing.StoreEndError()
                EB.SystemTables.setE("")
            END
        END

* CI_10009036 - STARTS
        IF ORIGINAL.AMOUNT LT R.NR.ITEMS<NR.Contract.Items.ItemAmount> THEN
            EB.SystemTables.setAv(1); EB.SystemTables.setAs('')
            EB.SystemTables.setE('NR.NRI.CANT.MATCH.HIGH.AMT.WITH.LOW.AMT')
            EB.SystemTables.setEtext(EB.SystemTables.getE())
            EB.ErrorProcessing.StoreEndError()
            EB.SystemTables.setE("")
        END
* CI_10009036 - ENDS

    END

    IF EB.SystemTables.getEndError() THEN         ;* Cross validation error
        RETURN      ;* Back to field input via UNAUTH.RECORD.WRITE
    END
*
*  Overrides should reside here.
*
REM > CALL XX.OVERRIDE

* initialise overrides

    AF.POS = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(AF.POS) THEN
        EB.SystemTables.setText('')
        CURR.OVER.NO = 0
        EB.OverrideProcessing.StoreOverride(CURR.OVER.NO)

        FOR UPDATE.LOOP = 1 TO MATCHED.IDS
            NR.ITEMS.ID = EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId)<1,UPDATE.LOOP>

            GOSUB GET.ITEM.DETAILS

            IF EB.SystemTables.getEtext() THEN
                EB.SystemTables.setText('NO')
                GOTO ABORT.CROSS.VAL
            END

* check different sources (i.e. statement against ledger and vice versa)

            ID.STMT.OR.LEDGER = EB.SystemTables.getRNew(NR.Contract.Items.ItemStmtOrLedger)
            MATCH.STMT.OR.LEDGER = R.NR.ITEMS<NR.Contract.Items.ItemStmtOrLedger>

            IF ID.STMT.OR.LEDGER NE MATCH.STMT.OR.LEDGER ELSE
                EB.SystemTables.setText('NR.NRI.TRYING.TO.MATCH.WITH')

                IF ID.STMT.OR.LEDGER = 'L' THEN
                    EB.SystemTables.setText(EB.SystemTables.getText() : @FM:'LEDGER':@VM:'LEDGER')
                END ELSE
                    EB.SystemTables.setText(EB.SystemTables.getText() : @FM:'STATEMENT':@VM:'STATEMENT')
                END
                EB.SystemTables.setText(EB.SystemTables.getText() : @VM:R.NR.ITEMS<NR.Contract.Items.ItemAccOwnerRef>)

                EB.OverrideProcessing.StoreOverride(CURR.OVER.NO)

                IF EB.SystemTables.getText() = 'NO' THEN GOTO ABORT.CROSS.VAL
            END

* check fields as defined in parameters file

            TRANS.TYPE = R.NR.ITEMS<NR.Contract.Items.ItemTransType>

            LOCATE TRANS.TYPE IN MATCHING.KEYS<1,1> SETTING POS ELSE
                LOCATE 'NULL' IN MATCHING.KEYS<1,1> SETTING POS ELSE
                    POS = 0
                END
            END

            IF POS THEN
                INDEX.KEYS = DCOUNT(MATCHING.KEYS<2,POS>,@SM)

                FOR COMPONENT = 1 TO INDEX.KEYS
                    MATCH.FIELD.NO.S = MATCHING.KEYS<2,POS,COMPONENT>
                    MATCH.FIELD.NO.L = MATCHING.KEYS<4,POS,COMPONENT>

                    IF MATCH.FIELD.NO.S = NR.Contract.Items.ItemAmount AND MATCH.FIELD.NO.L = NR.Contract.Items.ItemAmount ELSE
                        IF R.NR.ITEMS<MATCH.FIELD.NO.S> NE EB.SystemTables.getRNew(MATCH.FIELD.NO.L) THEN
                            SS.POS.1 = MATCHING.KEYS<3,POS,COMPONENT>
                            SS.POS.2 = MATCHING.KEYS<5,POS,COMPONENT>
                            EB.SystemTables.setText(' NR.DOES.NOT.MATCH ')
                            tmp=EB.SystemTables.getText(); tmp<2>=SS.FIELDS<EB.SystemTables.StandardSelection.SslSysFieldName,SS.POS.1>; EB.SystemTables.setText(tmp)
                            tmp=EB.SystemTables.getText(); tmp<2,4>=SS.FIELDS<EB.SystemTables.StandardSelection.SslSysFieldName,SS.POS.2>; EB.SystemTables.setText(tmp)

                            IF MATCH.FIELD.NO.S = NR.Contract.Items.ItemValueDate AND MATCH.FIELD.NO.L = NR.Contract.Items.ItemValueDate THEN
                                EB.SystemTables.setComi(R.NR.ITEMS<NR.Contract.Items.ItemValueDate>)
                                EB.Utility.InTwod('11','D')
                                tmp=EB.SystemTables.getText(); tmp<2,2>=EB.SystemTables.getVDisplay(); EB.SystemTables.setText(tmp)

                                EB.SystemTables.setComi(EB.SystemTables.getRNew(NR.Contract.Items.ItemValueDate))
                                EB.Utility.InTwod('11','D')
                                tmp=EB.SystemTables.getText(); tmp<2,5>=EB.SystemTables.getVDisplay(); EB.SystemTables.setText(tmp)
                            END ELSE
                                tmp=EB.SystemTables.getText(); tmp<2,2>=R.NR.ITEMS<MATCH.FIELD.NO.S>; EB.SystemTables.setText(tmp)
                                tmp=EB.SystemTables.getText(); tmp<2,5>=EB.SystemTables.getRNew(MATCH.FIELD.NO.S); EB.SystemTables.setText(tmp)
                            END

                            IF R.NR.ITEMS<NR.Contract.Items.ItemDebitOrCredit> = 'C' THEN
                                tmp=EB.SystemTables.getText(); tmp<2,3>='CR'; EB.SystemTables.setText(tmp)
                            END ELSE
                                tmp=EB.SystemTables.getText(); tmp<2,3>='DR'; EB.SystemTables.setText(tmp)
                            END

                            IF EB.SystemTables.getRNew(NR.Contract.Items.ItemDebitOrCredit) = 'C' THEN
                                tmp=EB.SystemTables.getText(); tmp<2,6>='CR'; EB.SystemTables.setText(tmp)
                            END ELSE
                                tmp=EB.SystemTables.getText(); tmp<2,6>='DR'; EB.SystemTables.setText(tmp)
                            END

                            EB.OverrideProcessing.StoreOverride(CURR.OVER.NO)

                            IF EB.SystemTables.getText() = 'NO' THEN GOTO ABORT.CROSS.VAL
                        END
                    END
                NEXT COMPONENT
            END
        NEXT UPDATE.LOOP

* check to see if an item split is created

        IF MATCH.CHECKS<1> NE '' AND EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId)<1,1> = '' ELSE

            GOSUB TIDY.MATCH.CHECKS

            NEW.MATCHED.IDS = DCOUNT(EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId),@VM)
            OLD.MATCHED.IDS = DCOUNT(EB.SystemTables.getROld(NR.Contract.Items.ItemMatchedId),@VM)

            IF NEW.MATCHED.IDS LT OLD.MATCHED.IDS ELSE
                REMAINDER = ORIGINAL.AMOUNT - SUM(MATCH.CHECKS<2>)
                IF REMAINDER LT 0 THEN REMAINDER = 0 - REMAINDER

                EB.API.RoundAmount(EB.SystemTables.getRNew(NR.Contract.Items.ItemAccountCurrency),REMAINDER,'','')

                IF REMAINDER THEN
                    IF (REMAINDER GT TOLERANCE) THEN
                        EB.SystemTables.setText('NR.ITEM.CREATED.FOR.REMAINING')
                        G$EXC.TOL = ''
                    END ELSE
                        EB.SystemTables.setText('NR.EXCESS.CENTS.BUCKET')
                        G$EXC.TOL = REMAINDER
                    END
                    tmp=EB.SystemTables.getText(); tmp<2>=EB.SystemTables.getRNew(NR.Contract.Items.ItemAccountCurrency):@VM:REMAINDER; EB.SystemTables.setText(tmp)

                    EB.OverrideProcessing.StoreOverride(CURR.OVER.NO)
*                  R.NEW(NR.ITEM.EXCESS.CENTS) = REMAINDER    ; * CI_10000591 S/E
                    EB.SystemTables.setRNew(NR.Contract.Items.ItemExcessCents, G$EXC.TOL);* CI_10000638 S/E
                END
            END
        END
    END

ABORT.CROSS.VAL:

    IF EB.SystemTables.getText() = "NO" THEN       ;* Said NO to override
        V$ERROR = 1
        EB.SystemTables.setMessage("ERROR");* Back to field input
        RETURN
    END
*
*  Contract processing code should reside here.
*
REM > CALL XX.         ;* Accounting, Schedule processing etc etc

    IF EB.SystemTables.getText() = "NO" THEN       ;* Said No to override
        EB.TransactionControl.TransactionAbort()          ;* Cancel current transaction
        V$ERROR = 1
        EB.SystemTables.setMessage("ERROR");* Back to field input
        RETURN
    END

*
* Additional updates should be performed here
*
REM > CALL XX...

RETURN

*************************************************************************

AUTH.CROSS.VALIDATION:


RETURN

*************************************************************************

CHECK.DELETE:

    EB.SystemTables.setText('')
    EB.SystemTables.setEtext('')
    V$ERROR = ''

    IF ( EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId) NE '' ) AND ( EB.SystemTables.getROld(NR.Contract.Items.ItemMatchedId) = '' ) THEN
        GOSUB REVOKE.MATCH
        EB.SystemTables.setRNew(NR.Contract.Items.ItemOverride, '')
    END

RETURN

*************************************************************************

CHECK.REVERSAL:

    IF INDEX('R',EB.SystemTables.getVFunction(),1) THEN
        EB.SystemTables.setE('NR.NRI.FUNT.NOT.ALLOW.APP')
        EB.ErrorProcessing.Err()
        EB.SystemTables.setVFunction('')
    END

RETURN

*************************************************************************

BEFORE.UNAU.WRITE:
    IF EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId) NE '' AND EB.SystemTables.getROld(NR.Contract.Items.ItemMatchedId) = '' THEN
        NEW.MATCHED.IDS = DCOUNT(EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId),@VM)
        FOR UPDATE.LOOP = 1 TO NEW.MATCHED.IDS
            NR.ITEMS.ID = EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId)<1,UPDATE.LOOP>
            GOSUB UPDATE.ITEMS.FILE
        NEXT UPDATE.LOOP
    END

    IF EB.SystemTables.getRNewLast(NR.Contract.Items.ItemMatchedId) AND EB.SystemTables.getRNewLast(NR.Contract.Items.ItemMatchedId) NE EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId) THEN
        UNAUTH.PROCESSING = 'Y'
        GOSUB REVOKE.MATCH
        UNAUTH.PROCESSING = ''
    END

RETURN

*************************************************************************

AFTER.UNAU.WRITE:


RETURN

*************************************************************************

AFTER.AUTH.WRITE:


RETURN

*************************************************************************

BEFORE.AUTH.WRITE:

    V.VAL = EB.SystemTables.getV()
    BEGIN CASE
        CASE EB.SystemTables.getRNew(V.VAL-8)[1,3] = "INA"        ;* Record status
REM > CALL XX.AUTHORISATION
        CASE EB.SystemTables.getRNew(V.VAL-8)[1,3] = "RNA"        ;* Record status
REM > CALL XX.REVERSAL

    END CASE
*
* If there are any OVERRIDES a call to EXCEPTION.LOG should be made
*
* IF R.NEW(V-9) THEN
*    EXCEP.CODE = "110" ; EXCEP.MESSAGE = "OVERRIDE CONDITION"
*    GOSUB EXCEPTION.MESSAGE
* END
*


    IF EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId) = '' AND EB.SystemTables.getROld(NR.Contract.Items.ItemMatchedId) NE '' THEN
        GOSUB REVOKE.MATCH
    END ELSE

        IF EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId) NE "" AND EB.SystemTables.getROld(NR.Contract.Items.ItemMatchedId) EQ "" THEN       ;* CI_10003646 -S/E

            GOSUB MATCH.PROCESSING

            IF EXCESS.BUCKET THEN
                EB.SystemTables.setRNew(NR.Contract.Items.ItemAmount, EB.SystemTables.getRNew(NR.Contract.Items.ItemAmount) - SUM(MATCH.CHECKS<2>))
                EB.SystemTables.setRNew(NR.Contract.Items.ItemMatchedId, '')
            END
        END         ;* CI_10003646 S/E

    END

RETURN


*--------------
CHECK.FUNCTION:
*--------------

* Validation of function entered.  Set FUNCTION to null if in error.
*--- 14/10/99 - GB9900964 Updated to disallow copy/reversals in addition to verify

    IF INDEX('RVC',EB.SystemTables.getVFunction(),1) THEN
        EB.SystemTables.setE('NR.NRI.FUNT.NOT.ALLOW.APP')
        EB.ErrorProcessing.Err()
        EB.SystemTables.setVFunction('')
    END

RETURN

*-----------------
EXCEPTION.MESSAGE:
*-----------------

    V.VAL = EB.SystemTables.getV()
    ID.NEW.VAL = EB.SystemTables.getIdNew()
    FUL.FNAME = EB.SystemTables.getFullFname()
    APPLN = EB.SystemTables.getApplication()
    EXCEP.MESSAGE = ''
    EB.ErrorProcessing.ExceptionLog("U",APP.CODE,APPLN,APPLN,EXCEP.CODE,'',FUL.FNAME,ID.NEW.VAL,EB.SystemTables.getRNew(V.VAL-7),EXCEP.MESSAGE,'')


RETURN


* read items file

*----------------
GET.ITEM.DETAILS:
*----------------

    R.NR.ITEMS = ''

    ETXT = ''
    R.NR.ITEMS = NR.Contract.Items.Read(NR.ITEMS.ID, ETXT)
    EB.SystemTables.setEtext(ETXT)

    IF EB.SystemTables.getEtext() THEN
        EB.SystemTables.setEtext('NR.NRI.CANT.READ.NR.ITEMS.REC':@FM:NR.ITEMS.ID)
    END

RETURN


* read index (concat) file

*-----------------
GET.INDEX.DETAILS:
*-----------------

    R.NR.INDEX = ''

    ETXT = ''
    R.NR.INDEX = NR.Contract.Index.Read(NR.INDEX.ID, ETXT)
    EB.SystemTables.setEtext(ETXT)

RETURN


* read account file

*-------------------
GET.ACCOUNT.DETAILS:
*-------------------

    R.ACCOUNT = ''

    ETXT = ''
    R.ACCOUNT = AC.AccountOpening.Account.Read(ACCOUNT.NO, ETXT)
    EB.SystemTables.setEtext(ETXT)

RETURN


* update both items records matched with the matched references

*-----------------
UPDATE.ITEMS.FILE:
*-----------------

    R.NR.ITEMS = ''
    SAVE.NR.ITEMS = ''
    V$RELEASE = 0

    ETXT = ''
    R.NR.ITEMS = NR.Contract.Items.ReadU(NR.ITEMS.ID, ETXT, 'E')
    EB.SystemTables.setEtext(ETXT)

    IF EB.SystemTables.getEtext() THEN
        EB.DataAccess.FRelease('F.NR.ITEMS',NR.ITEMS.ID,F.NR.ITEMS)
        RETURN
    END

    ETXT = ''
    ID.NEW.VAL = EB.SystemTables.getIdNew()
    SAVE.NR.ITEMS = NR.Contract.Items.ReadU(ID.NEW.VAL, ETXT, 'E')
    EB.SystemTables.setEtext(ETXT)

    SAVE.LIVE.MATCH = (R.NR.ITEMS<NR.Contract.Items.ItemMatchedId> NE '')
    SAVE.UNAU.MATCH = (R.NR.ITEMS<NR.Contract.Items.ItemUnauthMatchId> NE '')

    ORIG.LIVE.MATCH = (SAVE.NR.ITEMS<NR.Contract.Items.ItemMatchedId> NE '')
    ORIG.UNAU.MATCH = (SAVE.NR.ITEMS<NR.Contract.Items.ItemUnauthMatchId> NE '')

    BEGIN CASE
        CASE EB.SystemTables.getEtext()
            V$RELEASE = 1
        CASE ORIG.LIVE.MATCH AND SAVE.LIVE.MATCH
            V$RELEASE = 1
        CASE ORIG.UNAU.MATCH
            V$RELEASE = (EB.SystemTables.getMessage() NE 'AUT')
        CASE 1
    END CASE


    IF V$RELEASE THEN

        EB.DataAccess.FRelease('F.NR.ITEMS',NR.ITEMS.ID,F.NR.ITEMS)

        ID.NEW.VAL = EB.SystemTables.getIdNew()
        EB.DataAccess.FRelease('F.NR.ITEMS',ID.NEW.VAL ,F.NR.ITEMS)
        EB.SystemTables.setIdNew(ID.NEW.VAL)

    END ELSE

        DATE.NOW = OCONV(DATE(),'D2/')
        DATE.NOW = DATE.NOW[7,2]:DATE.NOW[1,2]:DATE.NOW[4,2]
        DATE.NOW := EB.SystemTables.getTimeStamp()[1,2]:EB.SystemTables.getTimeStamp()[4,2]

        IF EB.SystemTables.getMessage() NE 'AUT' THEN
            IF EB.SystemTables.getVFunction() NE 'D' THEN
                LOCATE EB.SystemTables.getIdNew() IN R.NR.ITEMS<NR.Contract.Items.ItemUnauthMatchId,1> SETTING POS ELSE
                    R.NR.ITEMS<NR.Contract.Items.ItemUnauthMatchId,-1> = EB.SystemTables.getIdNew()
                END
            END
        END ELSE
            IF ORIGINAL.AMOUNT LT R.NR.ITEMS<NR.Contract.Items.ItemAmount> THEN
                R.NR.ITEMS<NR.Contract.Items.ItemAmount> = ORIGINAL.AMOUNT
            END
            R.NR.ITEMS<NR.Contract.Items.ItemUnauthMatchId> = ''
            R.NR.ITEMS<NR.Contract.Items.ItemMatchedId,-1> = EB.SystemTables.getIdNew()
            R.NR.ITEMS<NR.Contract.Items.ItemDateMatched> = EB.SystemTables.getToday()
            R.NR.ITEMS<NR.Contract.Items.ItemDateTime> = DATE.NOW
            R.NR.ITEMS<NR.Contract.Items.ItemAuthoriser> = EB.SystemTables.getTno():'_':EB.SystemTables.getOperator()
        END

        NR.Contract.Items.Write(NR.ITEMS.ID, R.NR.ITEMS)

        IF EB.SystemTables.getMessage() = 'AUT' AND NOT(EXCESS.BUCKET) THEN
            IF ORIGINAL.AMOUNT NE EB.SystemTables.getRNew(NR.Contract.Items.ItemAmount) THEN
                EB.SystemTables.setRNew(NR.Contract.Items.ItemOriginalAmount, ORIGINAL.AMOUNT)
            END
            EB.SystemTables.setRNew(NR.Contract.Items.ItemAmount, R.NR.ITEMS<NR.Contract.Items.ItemAmount>)
            EB.SystemTables.setRNew(NR.Contract.Items.ItemMatchedId, NR.ITEMS.ID)
            EB.SystemTables.setRNew(NR.Contract.Items.ItemDateMatched, EB.SystemTables.getToday())
            EB.SystemTables.setRNew(NR.Contract.Items.ItemUnauthMatchId, '')
        END
    END

RETURN


* main match processing
*
* where a one-to-many match is performed, match the 'one' with the
* first of 'many', but only for the same amount. Then create new items
* records for each match id (i.e. effectively one to one). finally, if
* you have a remaining amount, create an unmatched split

*----------------
MATCH.PROCESSING:
*----------------

    EB.SystemTables.setText('')
    EB.SystemTables.setEtext('')
    V$ERROR = ''

** CI_10003646 -S
*--- 14/10/99 GB9900964 Case statements introduced.
*      BEGIN CASE
*         CASE (R.NEW(NR.ITEM.MATCHED.ID) NE R.OLD(NR.ITEM.MATCHED.ID)) AND (REMAINDER GT TOLERANCE)

** CI_100033646 -E

    NO.OF.MATCHES = DCOUNT(EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId),@VM)
    TIDY.INDEX = 1
    UNMATCHED.SPLIT = 0
    REAL.DIFFERENCE = 0       ;* GB9800576
    MATCHED.IDS = EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId)
    ORIGINAL.AMOUNT = EB.SystemTables.getRNew(NR.Contract.Items.ItemAmount)
    UPDATE.MATCH.CHECKS = (MATCH.CHECKS = '')
    FOR UPDATE.LOOP = 1 TO NO.OF.MATCHES
        IF UPDATE.LOOP = 1 THEN
            NR.ITEMS.ID = EB.SystemTables.getIdNew()

            IF EXCESS.BUCKET ELSE
                GOSUB GET.ITEM.DETAILS
                GOSUB UPDATE.INDEX.FILE
            END

        END

        NR.ITEMS.ID = MATCHED.IDS<1,UPDATE.LOOP>

        GOSUB GET.ITEM.DETAILS
        GOSUB UPDATE.INDEX.FILE

        IF UPDATE.LOOP = 1 THEN
            GOSUB UPDATE.ITEMS.FILE
        END ELSE
            GOSUB CREATE.SPLIT.ITEM
        END

        IF UPDATE.MATCH.CHECKS THEN
            MATCH.CHECKS<2,-1> = R.NR.ITEMS<NR.Contract.Items.ItemAmount>
        END
    NEXT UPDATE.LOOP

* now work out whether the difference (if there is one) is inside
* the defined tolerance

    GOSUB GET.ACCOUNT.DETAILS

    TOLERANCE = 0 + R.ACCOUNT<AC.AccountOpening.Account.RecoTolerance>
    DIFFERENCE = ORIGINAL.AMOUNT - SUM(MATCH.CHECKS<2>)

    REAL.DIFFERENCE = DIFFERENCE        ;* GB9800576

    IF DIFFERENCE LT 0 THEN DIFFERENCE = 0 - DIFFERENCE

    IF DIFFERENCE LE TOLERANCE THEN
        IF DIFFERENCE THEN
            NR.ITEMS.ID = MATCHED.IDS<1,NO.OF.MATCHES>
            GOSUB GET.ITEM.DETAILS
            GOSUB TOLERANCE.PROCESSING
        END
    END ELSE
        UNMATCHED.SPLIT = 1
        TIDY.INDEX = 0

        IF REAL.DIFFERENCE LT 0 THEN
            NR.ITEMS.ID = MATCHED.IDS<1,NO.OF.MATCHES>
        END ELSE
            NR.ITEMS.ID = EB.SystemTables.getIdNew()
        END

        GOSUB GET.ITEM.DETAILS
        GOSUB CREATE.SPLIT.ITEM

        NR.ITEMS.ID = SPLIT.ITEM.ID

        GOSUB GET.ITEM.DETAILS
        GOSUB UPDATE.INDEX.FILE
    END

** CI_10003646 -S

*         CASE 1
* CI_10000638 S
* Remove the UNAUTH.MATCHED.ID from all   authorised transactions

    IF EB.SystemTables.getMessage() = "AUT" THEN

        MATCHED.IDS<1,-1> = LIST.IDS
*        MATCHED.IDS = R.NEW(NR.ITEM.MATCHED.ID)
        NO.OF.MATCH = DCOUNT(MATCHED.IDS, @VM)
        FOR NO.REP = 1 TO NO.OF.MATCH
            NR.ITEMS.ID = MATCHED.IDS<1,NO.REP>

*           NR.ITEMS.ID = R.NEW(NR.ITEM.MATCHED.ID)<1,NO.REP>
* CI_10000638 E

            TIDY.INDEX = 1
*           NR.ITEMS.ID = ID.NEW
            GOSUB GET.ITEM.DETAILS
            GOSUB UPDATE.INDEX.FILE
* CI_10000638 S

            IF R.NR.ITEMS<NR.Contract.Items.ItemUnauthMatchId> NE "" THEN

                R.NR.ITEMS<NR.Contract.Items.ItemUnauthMatchId> = ''
                R.NR.ITEMS<NR.Contract.Items.ItemDateMatched> = EB.SystemTables.getToday()
                DATE.NOW = OCONV(DATE(),'D2/')
                DATE.NOW = DATE.NOW[7,2]:DATE.NOW[1,2]:DATE.NOW[4,2]
                DATE.NOW := EB.SystemTables.getTimeStamp()[1,2]:EB.SystemTables.getTimeStamp()[4,2]
                R.NR.ITEMS<NR.Contract.Items.ItemDateTime> = DATE.NOW
                R.NR.ITEMS<NR.Contract.Items.ItemAuthoriser> = EB.SystemTables.getTno():'_':EB.SystemTables.getOperator()
                NR.Contract.Items.Write(NR.ITEMS.ID, R.NR.ITEMS)
            END
        NEXT NO.REP

* CI_10000638 E
*      END CASE

    END

** CI_100003646 -E

RETURN


* revoke match processing (i.e. unmatch)

*------------
REVOKE.MATCH:
*------------

    BEGIN CASE
        CASE EB.SystemTables.getRNewLast(NR.Contract.Items.ItemMatchedId)
            OLD.MATCHED.IDS = EB.SystemTables.getRNewLast(NR.Contract.Items.ItemMatchedId)
        CASE EB.SystemTables.getROld(NR.Contract.Items.ItemMatchedId)
            OLD.MATCHED.IDS = EB.SystemTables.getROld(NR.Contract.Items.ItemMatchedId)
        CASE 1
            OLD.MATCHED.IDS = EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId)
    END CASE

    NO.OF.MATCHES = DCOUNT(OLD.MATCHED.IDS,@VM)
    FOR REVOKE.LOOP = 1 TO NO.OF.MATCHES
        OLD.ID = OLD.MATCHED.IDS<1,REVOKE.LOOP>
        ETXT = ''
        R.NR.ITEMS = NR.Contract.Items.ReadU(OLD.ID, ETXT, 'E')
        EB.SystemTables.setEtext(ETXT)

        IF ETXT ELSE
            BUCKET = R.NR.ITEMS<NR.Contract.Items.ItemExcessCentBucket>
            REMAINDER = R.NR.ITEMS<NR.Contract.Items.ItemExcessCents>

            PREVIOUS.AMOUNT = R.NR.ITEMS<NR.Contract.Items.ItemAmount> + REMAINDER
            EB.API.RoundAmount(EB.SystemTables.getRNew(NR.Contract.Items.ItemAccountCurrency),PREVIOUS.AMOUNT,'','')

            R.NR.ITEMS<NR.Contract.Items.ItemAmount> = PREVIOUS.AMOUNT
            R.NR.ITEMS<NR.Contract.Items.ItemMatchedId> = ''
            R.NR.ITEMS<NR.Contract.Items.ItemDateMatched> = ''
            R.NR.ITEMS<NR.Contract.Items.ItemUnauthMatchId> = ''
            R.NR.ITEMS<NR.Contract.Items.ItemExcessCents> = ''
            R.NR.ITEMS<NR.Contract.Items.ItemExcessCentBucket> = ''
            R.NR.ITEMS<NR.Contract.Items.ItemOverride> = ''

            IF R.NR.ITEMS<NR.Contract.Items.ItemAmount> = R.NR.ITEMS<NR.Contract.Items.ItemOriginalAmount> THEN
                R.NR.ITEMS<NR.Contract.Items.ItemOriginalAmount> = ''
            END
            NR.Contract.Items.Write(OLD.ID, R.NR.ITEMS)
        END

* recover excess cents if applicable

        FOR REVOKE = 1 TO 2
            IF REVOKE = 1 THEN
                NR.ITEMS.ID = FIELD(OLD.ID,'.',1):'.':BUCKET
            END ELSE
                ID.NEW.VAL = EB.SystemTables.getIdNew()
                NR.ITEMS.ID = FIELD(ID.NEW.VAL,'.',1):'.'
                NR.ITEMS.ID := EB.SystemTables.getRNew(NR.Contract.Items.ItemExcessCentBucket)
                REMAINDER = EB.SystemTables.getRNew(NR.Contract.Items.ItemExcessCents)
            END

            R.NR.ITEMS = ''

            ETXT = ''
            R.NR.ITEMS = NR.Contract.Items.ReadU(NR.ITEMS.ID, ETXT, 'E')
            EB.SystemTables.setEtext(ETXT)

            IF EB.SystemTables.getEtext() ELSE
                R.NR.ITEMS<NR.Contract.Items.ItemAmount> -= REMAINDER
                NR.Contract.Items.Write(NR.ITEMS.ID, R.NR.ITEMS)
            END
        NEXT REVOKE

* now remove anything from R.NEW

        REMAINDER = EB.SystemTables.getRNew(NR.Contract.Items.ItemExcessCents)


        PREVIOUS.AMOUNT = EB.SystemTables.getRNew(NR.Contract.Items.ItemAmount) + REMAINDER
        EB.API.RoundAmount(EB.SystemTables.getRNew(NR.Contract.Items.ItemAccountCurrency),PREVIOUS.AMOUNT,'','')

* Do not null values in R.NEW if the record is in INAU status

        IF UNAUTH.PROCESSING NE 'Y' THEN
            EB.SystemTables.setRNew(NR.Contract.Items.ItemAmount, PREVIOUS.AMOUNT)
            EB.SystemTables.setRNew(NR.Contract.Items.ItemMatchedId, '')
            EB.SystemTables.setRNew(NR.Contract.Items.ItemDateMatched, '')
            EB.SystemTables.setRNew(NR.Contract.Items.ItemUnauthMatchId, '')
            EB.SystemTables.setRNew(NR.Contract.Items.ItemExcessCents, '')
            EB.SystemTables.setRNew(NR.Contract.Items.ItemExcessCentBucket, '')


            EB.SystemTables.setRNew(NR.Contract.Items.ItemOverride, '')

            IF EB.SystemTables.getRNew(NR.Contract.Items.ItemAmount) = EB.SystemTables.getRNew(NR.Contract.Items.ItemOriginalAmount) THEN
                EB.SystemTables.setRNew(NR.Contract.Items.ItemOriginalRef, '')
                EB.SystemTables.setRNew(NR.Contract.Items.ItemOriginalAmount, '')
            END
        END

    NEXT REVOKE.LOOP

RETURN


* build matching key to see if a match exists. the actual index record
* is built when the items records are created in the transfer porocess

*--------------
VALIDATE.MATCH:
*--------------

    RecStatus = EB.SystemTables.getRNewLast(NR.Contract.Items.ItemRecordStatus)   ;* Get the record status of R.NEW.LAST record
    IF RecStatus[1,2] EQ 'IN' OR RecStatus[2,3] EQ 'HLD' THEN
        StatusFlag = @FALSE   ;* Flag to indicate the record is read from unauth or hold
    END

    IF EB.SystemTables.getMessage() NE 'AUT' AND MATCH.ID NE EB.SystemTables.getROld(NR.Contract.Items.ItemMatchedId) AND StatusFlag THEN
        IF EB.SystemTables.getROld(NR.Contract.Items.ItemMatchedId) = '' THEN
            IF (R.NR.ITEMS<NR.Contract.Items.ItemMatchedId> NE '') OR (R.NR.ITEMS<NR.Contract.Items.ItemUnauthMatchId> NE '') THEN
                MATCH.ERROR = 'ALREADY MATCHED'
                GOTO END.VALIDATE.MATCH
            END
        END ELSE
            MATCH.ERROR = 'ALREADY MATCHED'
            GOTO END.VALIDATE.MATCH
        END
    END

* check account numbers match

    ID.NEW.VAL = EB.SystemTables.getIdNew()
    ID.ACCOUNT.NO = FIELD(ID.NEW.VAL,'.',1)
    MATCH.ACCOUNT.NO = FIELD(NR.ITEMS.ID,'.',1)

    IF ID.ACCOUNT.NO = MATCH.ACCOUNT.NO ELSE
        MATCH.ERROR = 'INVALID - & WITH &'
        MATCH.ERROR := @FM:ID.ACCOUNT.NO:@VM:MATCH.ACCOUNT.NO

        GOTO END.VALIDATE.MATCH
    END

    GOSUB GET.ACCOUNT.DETAILS

    TOLERANCE = R.ACCOUNT<AC.AccountOpening.Account.RecoTolerance>

* check different sides (i.e. debit against credit or vice versa)

    ID.DEBIT.OR.CREDIT = EB.SystemTables.getRNew(NR.Contract.Items.ItemDebitOrCredit)
    MATCH.DEBIT.OR.CREDIT = R.NR.ITEMS<NR.Contract.Items.ItemDebitOrCredit>

    IF ID.DEBIT.OR.CREDIT NE MATCH.DEBIT.OR.CREDIT ELSE
        MATCH.ERROR = 'INVALID - & WITH &'

        IF ID.DEBIT.OR.CREDIT = 'C' THEN
            MATCH.ERROR := @FM:'CREDIT':@VM:'CREDIT'
        END ELSE
            MATCH.ERROR := @FM:'DEBIT':@VM:'DEBIT'
        END

        GOTO END.VALIDATE.MATCH
    END

END.VALIDATE.MATCH:

RETURN

* create split item for remaining amount

*-----------------
CREATE.SPLIT.ITEM:
*-----------------

* build new split record

    R.SPLIT = ''
    ACCOUNT.NO = FIELD(NR.ITEMS.ID,'.',1)

    FOR SPLIT.LOOP = NR.Contract.Items.ItemStatementNumber TO NR.Contract.Items.ItemUnauthMatchId
        BEGIN CASE
            CASE SPLIT.LOOP = NR.Contract.Items.ItemOriginalRef
** CI_10007205 -S
*               R.SPLIT<SPLIT.LOOP> = NR.ITEMS.ID
                R.SPLIT<SPLIT.LOOP> = EB.SystemTables.getIdNew()
** CI_10007205 -E

            CASE SPLIT.LOOP = NR.Contract.Items.ItemDebitOrCredit
                IF UNMATCHED.SPLIT THEN
                    R.SPLIT<SPLIT.LOOP> = R.NR.ITEMS<SPLIT.LOOP>
                END ELSE
                    IF R.NR.ITEMS<SPLIT.LOOP> = 'C' THEN
                        R.SPLIT<SPLIT.LOOP> = 'D'
                    END ELSE
                        R.SPLIT<SPLIT.LOOP> = 'C'
                    END
                END

            CASE SPLIT.LOOP = NR.Contract.Items.ItemStmtOrLedger

** CI_10007845 -S
*  IF UNMATCHED.SPLIT THEN
*     R.SPLIT<SPLIT.LOOP> = R.NR.ITEMS<SPLIT.LOOP>
*  END ELSE
*    IF R.NR.ITEMS<SPLIT.LOOP> = 'L' THEN
*        R.SPLIT<SPLIT.LOOP> = 'S'
*     END ELSE
*       R.SPLIT<SPLIT.LOOP> = 'L'
*     END
*  END

                R.SPLIT<SPLIT.LOOP> = EB.SystemTables.getRNew(NR.Contract.Items.ItemStmtOrLedger)

** CI_10007845 -E


            CASE SPLIT.LOOP = NR.Contract.Items.ItemOriginalAmount
                R.SPLIT<SPLIT.LOOP> = ORIGINAL.AMOUNT

            CASE SPLIT.LOOP = NR.Contract.Items.ItemAmount
                IF UNMATCHED.SPLIT THEN
                    EB.API.RoundAmount(EB.SystemTables.getRNew(NR.Contract.Items.ItemAccountCurrency),DIFFERENCE,'','')

                    R.SPLIT<SPLIT.LOOP> = DIFFERENCE
                END ELSE
                    R.SPLIT<SPLIT.LOOP> = R.NR.ITEMS<SPLIT.LOOP>
                END

            CASE SPLIT.LOOP = NR.Contract.Items.ItemMatchedId
                IF UNMATCHED.SPLIT ELSE
                    R.SPLIT<SPLIT.LOOP> = NR.ITEMS.ID
                END

            CASE SPLIT.LOOP = NR.Contract.Items.ItemNotes
                R.SPLIT<SPLIT.LOOP> = 'ITEM SPLIT CREATED BY MANUAL MATCHING'

            CASE SPLIT.LOOP = NR.Contract.Items.ItemDateMatched
                R.SPLIT<SPLIT.LOOP> = EB.SystemTables.getToday()

            CASE 1
                IF UNMATCHED.SPLIT THEN     ;* CI_10011127 S/E
                    R.SPLIT<SPLIT.LOOP> = R.NR.ITEMS<SPLIT.LOOP>
** CI_10011127 -S
                END ELSE
                    R.SPLIT<SPLIT.LOOP> = EB.SystemTables.getRNew(SPLIT.LOOP)
                END
** CI_10011127 -E
        END CASE
    NEXT SPLIT.LOOP

    DATE.NOW = OCONV(DATE(),'D2/')
    DATE.NOW = DATE.NOW[7,2]:DATE.NOW[1,2]:DATE.NOW[4,2]
    DATE.NOW := EB.SystemTables.getTimeStamp()[1,2]:EB.SystemTables.getTimeStamp()[4,2]

    R.SPLIT<NR.Contract.Items.ItemRecordStatus> = ''
    R.SPLIT<NR.Contract.Items.ItemCurrNo> += 1
    R.SPLIT<NR.Contract.Items.ItemInputter> = EB.SystemTables.getTno():'_':EB.SystemTables.getOperator()
    R.SPLIT<NR.Contract.Items.ItemDateTime> = DATE.NOW
    R.SPLIT<NR.Contract.Items.ItemCoCode> = EB.SystemTables.getIdCompany()
    R.SPLIT<NR.Contract.Items.ItemDeptCode> = EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>
    R.SPLIT<NR.Contract.Items.ItemAuthoriser> = EB.SystemTables.getTno():'_':EB.SystemTables.getOperator()

    Y.DATE = DATE()
    Y.SESSION.NO = EB.SystemTables.getCTTwoFouSessionNo()
    MISN   = ''
    EB.API.AllocateUniqueTime(MISN)
    Y.SEQ.ID = MISN
    CHANGE '.' TO '' IN Y.SEQ.ID
    Y.UNIQUE.ID   = Y.SESSION.NO:Y.DATE:Y.SEQ.ID
    SPLIT.ITEM.ID = ACCOUNT.NO : '.' :Y.UNIQUE.ID
    R.DUMMY = ''

* update the split record

    ETXT = ''
    R.DUMMY = NR.Contract.Items.ReadU(SPLIT.ITEM.ID, ETXT, 'E')
    EB.SystemTables.setEtext(ETXT)

    NR.Contract.Items.Write(SPLIT.ITEM.ID, R.SPLIT)

* now update the record that matches the split

    IF UNMATCHED.SPLIT ELSE
        ETXT = ''
        R.NR.ITEMS = NR.Contract.Items.ReadU(NR.ITEMS.ID, ETXT, 'E')
        EB.SystemTables.setEtext(ETXT)

        R.NR.ITEMS<NR.Contract.Items.ItemMatchedId> = SPLIT.ITEM.ID
        R.NR.ITEMS<NR.Contract.Items.ItemDateMatched> = EB.SystemTables.getToday()
        R.NR.ITEMS<NR.Contract.Items.ItemDateTime> = DATE.NOW
        R.NR.ITEMS<NR.Contract.Items.ItemAuthoriser> = 'SY_NR.ITEMS'

        NR.Contract.Items.Write(NR.ITEMS.ID, R.NR.ITEMS)

        LIST.IDS<1,-1> = SPLIT.ITEM.ID  ;* CI_10003646

    END

RETURN


* update index file

*------------------
UPDATE.INDEX.FILE:
*------------------

    NR.INDEX.ID = '.':R.NR.ITEMS<NR.Contract.Items.ItemDebitOrCredit>
    NR.INDEX.ID := '.':R.NR.ITEMS<NR.Contract.Items.ItemStmtOrLedger>

    TRANS.TYPE = R.NR.ITEMS<NR.Contract.Items.ItemTransType>

    LOCATE TRANS.TYPE IN MATCHING.KEYS<1,1> SETTING POS ELSE
        LOCATE 'NULL' IN MATCHING.KEYS<1,1> SETTING POS THEN
            TRANS.TYPE = 'NULL'         ;* If TRANS.TYPE is not specified in NR.PARAMETER, mark it as NULL
        END ELSE
            POS = 0
        END
    END

    IF POS THEN
        IF TRANS.TYPE = '' OR TRANS.TYPE = 'NULL' ELSE
            NR.INDEX.ID := '.':TRANS.TYPE
        END

        INDEX.KEYS = DCOUNT(MATCHING.KEYS<2,POS>,@SM)

        FOR COMPONENT = 1 TO INDEX.KEYS
            IF R.NR.ITEMS<NR.Contract.Items.ItemStmtOrLedger> EQ 'S' THEN
                MATCH.FIELD.NO = MATCHING.KEYS<2,POS,COMPONENT>
            END ELSE
                MATCH.FIELD.NO = MATCHING.KEYS<4,POS,COMPONENT>
            END

            NR.INDEX.ID := '.':R.NR.ITEMS<MATCH.FIELD.NO>
        NEXT COMPONENT
    END

*  create index records for internal account matching

    GOSUB GET.ACCOUNT.DETAILS

    IF R.NR.ITEMS<NR.Contract.Items.ItemStmtOrLedger> = 'L' THEN
        RECONCILE.ACCOUNTS = R.ACCOUNT<AC.AccountOpening.Account.StmtRecoWith>
    END ELSE
        RECONCILE.ACCOUNTS = R.ACCOUNT<AC.AccountOpening.Account.LedgRecoWith>
    END

    IF RECONCILE.ACCOUNTS THEN
        RECONCILE.ACCOUNTS = ACCOUNT.NO:@VM:RECONCILE.ACCOUNTS
    END ELSE
        RECONCILE.ACCOUNTS = ACCOUNT.NO
    END

    NUMBER.OF.ACCOUNTS = DCOUNT(RECONCILE.ACCOUNTS<1>,@VM)

    FOR INDEX.LOOP = 1 TO NUMBER.OF.ACCOUNTS
        NR.INDEX.KEY = RECONCILE.ACCOUNTS<1,INDEX.LOOP>:NR.INDEX.ID
        CONVERT " " TO "?" IN NR.INDEX.KEY
        ETXT = ''
        R.NR.INDEX = NR.Contract.Index.ReadU(NR.INDEX.KEY, ETXT, 'E')
        EB.SystemTables.setEtext(ETXT)

        IF TIDY.INDEX THEN
            LOCATE NR.ITEMS.ID IN R.NR.INDEX<1> SETTING POS THEN
                DEL R.NR.INDEX<POS>
            END
        END ELSE
            R.NR.INDEX<-1> = NR.ITEMS.ID
        END

        IF TIDY.INDEX AND R.NR.INDEX = '' THEN
            NR.Contract.Index.Delete(NR.INDEX.KEY)
        END ELSE
            NR.Contract.Index.Write(NR.INDEX.KEY, R.NR.INDEX)
        END

    NEXT INDEX.LOOP

RETURN


************************************************
*                                              *
* rules for determining overages and shortages *
* are as follows :-                            *
*                                              *
*      LEDGER          STATEMENT               *
*-------------------------------------------   *
* (a)  100.00            99.75    [ +0.25 ]    *
* (b)   99.75           100.00    [ -0.25 ]    *
*                                              *
* When match side is Ledger                    *
*                                              *
*     (a) they credit 0.25                     *
*     (b) they debit  0.25                     *
*                                              *
* When match side is statement                 *
*                                              *
*     (a) we debit    0.25                     *
*     (b) we credit   0.25                     *
*                                              *
************************************************

*--------------------
TOLERANCE.PROCESSING:
*--------------------

    IF ORIGINAL.AMOUNT GT R.NR.ITEMS<NR.Contract.Items.ItemAmount> THEN
        TOL.STMT.LEDG = EB.SystemTables.getRNew(NR.Contract.Items.ItemStmtOrLedger)
        TOL.DR.OR.CR = EB.SystemTables.getRNew(NR.Contract.Items.ItemDebitOrCredit)
        UPDATE.OTHER = 0
    END ELSE
        TOL.STMT.LEDG = R.NR.ITEMS<NR.Contract.Items.ItemStmtOrLedger>
        TOL.DR.OR.CR = R.NR.ITEMS<NR.Contract.Items.ItemDebitOrCredit>
        UPDATE.OTHER = 1
    END

    IF TOL.STMT.LEDG = 'L' THEN
        IF TOL.DR.OR.CR = 'D' THEN
            BUCKET = 'WE.DEBIT'
        END ELSE
            BUCKET = 'WE.CREDIT'
        END
    END ELSE
        IF TOL.DR.OR.CR = 'D' THEN
            BUCKET = 'THEY.DEBIT'
        END ELSE
            BUCKET = 'THEY.CREDIT'
        END
    END

    EB.API.RoundAmount(EB.SystemTables.getRNew(NR.Contract.Items.ItemAccountCurrency),DIFFERENCE,'','')

* update record with excess cents amount

    IF UPDATE.OTHER THEN
        ETXT = ''
        DUMMY = NR.Contract.Items.ReadU(NR.ITEMS.ID, ETXT, 'E')
        EB.SystemTables.setEtext(ETXT)

        ORIG.AMOUNT = R.NR.ITEMS<NR.Contract.Items.ItemAmount> + DIFFERENCE
        EB.API.RoundAmount(R.NR.ITEMS<NR.Contract.Items.ItemAccountCurrency>,ORIG.AMOUNT,'','')

        R.NR.ITEMS<NR.Contract.Items.ItemOriginalAmount> = ORIG.AMOUNT
        R.NR.ITEMS<NR.Contract.Items.ItemExcessCents> = DIFFERENCE
        R.NR.ITEMS<NR.Contract.Items.ItemExcessCentBucket> = BUCKET

        NR.Contract.Items.Write(NR.ITEMS.ID, R.NR.ITEMS)

    END ELSE
        EB.SystemTables.setRNew(NR.Contract.Items.ItemExcessCents, DIFFERENCE)
        EB.SystemTables.setRNew(NR.Contract.Items.ItemExcessCentBucket, BUCKET)
    END

* and now put the excess cents into the excess cents bucket

    R.NR.ITEMS = ''
    NR.ITEMS.ID = FIELD(NR.ITEMS.ID,'.',1):'.':BUCKET

    ETXT = ''
    R.NR.ITEMS = NR.Contract.Items.ReadU(NR.ITEMS.ID, ETXT, 'E')
    EB.SystemTables.setEtext(ETXT)

    IF EB.SystemTables.getEtext() THEN
        R.NR.ITEMS<NR.Contract.Items.ItemNotes> = 'AUTOMATICALLY CREATED BY SYSTEM'
    END

    EXCESS.CENTS.AMOUNT = R.NR.ITEMS<NR.Contract.Items.ItemAmount> + DIFFERENCE

    EB.API.RoundAmount(EB.SystemTables.getRNew(NR.Contract.Items.ItemAccountCurrency),EXCESS.CENTS.AMOUNT,'','')

    R.NR.ITEMS<NR.Contract.Items.ItemAmount> = EXCESS.CENTS.AMOUNT
    R.NR.ITEMS<NR.Contract.Items.ItemAccountCurrency> = EB.SystemTables.getRNew(NR.Contract.Items.ItemAccountCurrency)

    NR.Contract.Items.Write(NR.ITEMS.ID, R.NR.ITEMS)

RETURN


*-----------------
TIDY.MATCH.CHECKS:
*-----------------

    IF EB.SystemTables.getRNew(NR.Contract.Items.ItemMatchedId) NE MATCH.CHECKS<1> THEN
        AF.POS = EB.SystemTables.getAf()
        R.NEW.IDS = DCOUNT(EB.SystemTables.getRNew(AF.POS)<1>,@VM)
        CHECK.IDS = DCOUNT(MATCH.CHECKS<1>,@VM)
        TEMP.IDS = MATCH.CHECKS

        FOR CHECK.LOOP = 1 TO CHECK.IDS
            LOCATE MATCH.CHECKS<1,CHECK.LOOP> IN EB.SystemTables.getRNew(AF.POS)<1,1> SETTING POS ELSE
                DEL TEMP.IDS<1,CHECK.LOOP>
                DEL TEMP.IDS<2,CHECK.LOOP>
            END
        NEXT CHECK.LOOP

        MATCH.CHECKS = TEMP.IDS
        MATCHED.TOTAL = SUM(MATCH.CHECKS<2>)
    END

RETURN


* initialise file variables and define matching fields

*----------
INITIALISE:
*----------

*--- GB9900964 29/10/99
    TOLERANCE = ''
    REMAINDER = ''
    LIST.IDS = ""   ;* CI_100003646 S/E
    APP.CODE = 'NR'
    EB.SystemTables.setApplication('NR.ITEMS')
    EXCEP.CODE = ""
    MATCHING.KEYS = ''
    MATCH.ID = ''
    UNAUTH.PROCESSING = ''
    RecStatus = ''
    StatusFlag = @TRUE

* build matching details from parameters file and standard selection definition

    PARAMETER.KEY = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialCom)
    ST.CompanyCreation.EbReadParameter('F.NR.PARAMETER', 'N', '', R.NR.PARAMETER, PARAMETER.KEY, F.NR.PARAMETER,ER)

    IF ER THEN
        EB.SystemTables.setE('CANNOT READ NR.PARAMETER RECORD - ':PARAMETER.KEY)
*       CALL FATAL.ERROR(APPLICATION)    ; * CI_10010626S/E
        EB.ErrorProcessing.Err()    ;* CI_10010626 S/E
    END

* process standard selection

    EB.API.GetStandardSelectionDets('NR.ITEMS',SS.FIELDS)

    TRANS.TYPES = DCOUNT(R.NR.PARAMETER<NR.Contract.Parameter.ParamMatchFldStmt>,@VM)

    FOR OLOOP = 1 TO TRANS.TYPES

        MATCHING.FIELD.NAMES.S = DCOUNT(R.NR.PARAMETER<NR.Contract.Parameter.ParamMatchFldStmt,OLOOP>,@SM)
        MATCHING.FIELD.NAMES.L = DCOUNT(R.NR.PARAMETER<NR.Contract.Parameter.ParamMatchFldLedger,OLOOP>,@SM)

        IF R.NR.PARAMETER<NR.Contract.Parameter.ParamTransType,OLOOP> = '' THEN
            MATCHING.KEYS<1,OLOOP> = 'NULL'
        END ELSE
            MATCHING.KEYS<1,OLOOP> = R.NR.PARAMETER<NR.Contract.Parameter.ParamTransType,OLOOP>
        END

        FOR ILOOP = 1 TO MATCHING.FIELD.NAMES.S
            MATCH.FIELD.NAME = R.NR.PARAMETER<NR.Contract.Parameter.ParamMatchFldStmt,OLOOP,ILOOP>

            LOCATE MATCH.FIELD.NAME IN SS.FIELDS<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN
                MATCHING.KEYS<2,OLOOP,-1> = SS.FIELDS<EB.SystemTables.StandardSelection.SslSysFieldNo,POS>
                MATCHING.KEYS<3,OLOOP,-1> = POS
            END
        NEXT ILOOP

        FOR ILOOP = 1 TO MATCHING.FIELD.NAMES.L
            MATCH.FIELD.NAME = R.NR.PARAMETER<NR.Contract.Parameter.ParamMatchFldLedger,OLOOP,ILOOP>

            LOCATE MATCH.FIELD.NAME IN SS.FIELDS<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN
                MATCHING.KEYS<4,OLOOP,-1> = SS.FIELDS<EB.SystemTables.StandardSelection.SslSysFieldNo,POS>
                MATCHING.KEYS<5,OLOOP,-1> = POS
            END
        NEXT ILOOP

    NEXT OLOOP

RETURN


*-----------------
DEFINE.PARAMETERS:
*-----------------


    DIM F(EB.SystemTables.SysDim)
    DIM N(EB.SystemTables.SysDim)
    DIM T(EB.SystemTables.SysDim)
    DIM CHECKFILE(EB.SystemTables.SysDim)

    MAT F = "" ; MAT N = "" ; MAT T = ""
    MAT CHECKFILE = ""

    ID.F = "NR.ITEM" ; ID.N = "39" ; ID.T = "S"
    ID.T<4> = ''

    EB.SystemTables.SetIdProperties(ID.F,ID.N,ID.T,'','')

    Z = 0

    Z += 1 ; F(Z) = 'STATEMENT.NUMBER' ; N(Z) = '5'
    Z += 1 ; F(Z) = 'PAGE.NUMBER' ; N(Z) = '3'
    Z += 1 ; F(Z) = 'STMT.OR.LEDGER' ; N(Z) = '1'
    Z += 1 ; F(Z) = 'ORIGINAL.AMOUNT' ; N(Z) = '19'
    Z += 1 ; F(Z) = 'ORIGINAL.REF' ; N(Z) = '39'
    Z += 1 ; F(Z) = 'ACCOUNT.CURRENCY' ; N(Z) = '3'
    Z += 1 ; F(Z) = 'XX.MATCHED.ID' ; N(Z) = '39..C'
**CI_10001901 -S
    Z += 1 ; F(Z) = 'VALUE.DATE' ; N(Z) = '11'
    Z += 1 ; F(Z) = 'ENTRY.DATE' ; N(Z) = '11'
**CI_10001901 -E
    Z += 1 ; F(Z) = 'DEBIT.OR.CREDIT' ; N(Z) = '2'
    Z += 1 ; F(Z) = 'FUNDS.CODE' ; N(Z) = '1'
    Z += 1 ; F(Z) = 'AMOUNT' ; N(Z) = '19'
    Z += 1 ; F(Z) = 'TRANS.TYPE' ; N(Z) = '4'
    Z += 1 ; F(Z) = 'ACC.OWNER.REF' ; N(Z) = '16'
    Z += 1 ; F(Z) = 'ACC.INST.REF' ; N(Z) = '16'
    Z += 1 ; F(Z) = 'SUPPLEMENTARY' ; N(Z) = '34'
    Z += 1 ; F(Z) = 'XX.NARRATIVE' ; N(Z) = '65'
    Z += 1 ; F(Z) = 'REVERSAL' ; N(Z) = '2'
    Z += 1 ; F(Z) = 'XX.NOTES' ; N(Z) = '50'
    Z += 1 ; F(Z) = 'RESPONSIBILITY' ; N(Z) = '4..C'
    Z += 1 ; F(Z) = 'EXCESS.CENTS' ; N(Z) = '19'
    Z += 1 ; F(Z) = 'EXCESS.CENT.BUCKET' ; N(Z) = '11'
**CI_10001901 -S
    Z += 1 ; F(Z) = 'DATE.MATCHED' ; N(Z) = '11'
**CI_10001901 -E
    Z += 1 ; F(Z) = 'MATCHED.TO' ; N(Z) = '39..C'
    Z += 1 ; F(Z) = 'XX.UNAUTH.MATCH.ID' ; N(Z) = '39'
    Z += 1 ; F(Z) = 'XX.LOCAL.REF' ; N(Z) = '35'
    Z += 1 ; F(Z) = 'SUB.ACCOUNT' ; N(Z) = ''     ;* EN_10001513
    Z += 1 ; F(Z) = 'RESERVED9' ; N(Z) = ''
    Z += 1 ; F(Z) = 'RESERVED8' ; N(Z) = ''
    Z += 1 ; F(Z) = 'RESERVED7' ; N(Z) = ''
    Z += 1 ; F(Z) = 'RESERVED6' ; N(Z) = ''
    Z += 1 ; F(Z) = 'RESERVED5' ; N(Z) = ''
    Z += 1 ; F(Z) = 'RESERVED4' ; N(Z) = ''
    Z += 1 ; F(Z) = 'RESERVED3' ; N(Z) = ''
    Z += 1 ; F(Z) = 'RESERVED2' ; N(Z) = ''
    Z += 1 ; F(Z) = 'RESERVED1' ; N(Z) = ''
    Z += 1 ; F(Z) = 'XX.OVERRIDE' ; N(Z) = '35'

    T(NR.Contract.Items.ItemStatementNumber)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemPageNumber)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemStmtOrLedger)<1> = 'A'
    T(NR.Contract.Items.ItemStmtOrLedger)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemOriginalAmount) = 'AMT':@FM:@FM:'NOINPUT'
    T(NR.Contract.Items.ItemOriginalRef)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemMatchedId) = 'REC':@FM:@FM:@FM:@FM:'R'
    T(NR.Contract.Items.ItemAccountCurrency)<1> = 'A'
    T(NR.Contract.Items.ItemAccountCurrency)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemValueDate) = 'D':@FM:@FM:'NOINPUT'
    T(NR.Contract.Items.ItemEntryDate) = 'D':@FM:@FM:'NOINPUT'
    T(NR.Contract.Items.ItemDebitOrCredit)<1> = 'A' ; * This field contains values 'D' or 'C'.
    T(NR.Contract.Items.ItemDebitOrCredit)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemFundsCode)<1> = 'A'   ;* Holds Alphanumeric values
    T(NR.Contract.Items.ItemFundsCode)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemAmount) = 'AMT':@FM:@FM:'NOINPUT'
    T(NR.Contract.Items.ItemTransType)<1> = 'A'   ;* Holds Alphanumeric values
    T(NR.Contract.Items.ItemTransType)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemAccOwnerRef)<1> = 'A'   ;* Holds Alphanumeric values
    T(NR.Contract.Items.ItemAccOwnerRef)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemAccInstRef)<1> = 'A'   ;* Holds Alphanumeric values
    T(NR.Contract.Items.ItemAccInstRef)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemSupplementary)<1> = 'A'   ;* Holds Alphanumeric values
    T(NR.Contract.Items.ItemSupplementary)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemNarrative)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemReversal)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemNotes) = 'ANY'
    T(NR.Contract.Items.ItemResponsibility) = 'DAO'
    T(NR.Contract.Items.ItemExcessCents)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemExcessCentBucket)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemDateMatched) = 'D':@FM:@FM:'NOINPUT'
    T(NR.Contract.Items.ItemMatchedTo)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemUnauthMatchId)<3> = 'EXTERN'
    T(NR.Contract.Items.ItemLocalRef) = 'A'
    T(NR.Contract.Items.ItemSubAccount)<3> = 'NOINPUT'         ;* EN_10001513
    T(NR.Contract.Items.ItemReserved9)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemReserved8)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemReserved7)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemReserved6)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemReserved5)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemReserved4)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemReserved3)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemReserved2)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemReserved1)<3> = 'NOINPUT'
    T(NR.Contract.Items.ItemOverride) = 'A':@FM:@FM:'NOINPUT'

    CHECKFILE(NR.Contract.Items.ItemAccountCurrency) = 'CURRENCY':@FM:ST.CurrencyConfig.Currency.EbCurCcyName:@FM:'L'
    CHECKFILE(NR.Contract.Items.ItemResponsibility) = 'DEPT.ACCT.OFFICER':@FM:ST.Config.DeptAcctOfficer.EbDaoName:@FM
    CHECKFILE(NR.Contract.Items.ItemMatchedTo) = 'NR.ITEMS':@FM:NR.Contract.Items.ItemAccOwnerRef:@FM
    CHECKFILE(NR.Contract.Items.ItemUnauthMatchId) = 'NR.ITEMS':@FM:NR.Contract.Items.ItemAccOwnerRef:@FM
    CHECKFILE(NR.Contract.Items.ItemSubAccount) = 'ACCOUNT':@FM:AC.AccountOpening.Account.ShortTitle:@FM   ;* EN_10001513

    V = Z + 9

    EB.SystemTables.SetFieldProperties(MAT F, MAT N, MAT T,'',MAT CHECKFILE, V)

RETURN

END
