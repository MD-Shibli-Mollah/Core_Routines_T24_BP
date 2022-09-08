* @ValidationCode : MjoxOTM0MDA1NzQ5OkNwMTI1MjoxNTU0Mjk0NDYzNzIyOnNhc2lrdW1hcnY6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNC4yMDE5MDMyMy0wMzU4OjM4MDoxNDc=
* @ValidationInfo : Timestamp         : 03 Apr 2019 17:57:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sasikumarv
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 147/380 (38.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190323-0358
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>572</Rating>
*-----------------------------------------------------------------------------
* Version 5 25/10/00  GLOBUS Release No. G11.0.00 29/06/00

$PACKAGE PC.Contract
SUBROUTINE PC.PERIOD

* 05/10/01 - GLOBUS_BG_100000114
*            jBASE changes.
*            OPEN.SEQ with a ELSE clause in jbase is not
*            able to handle the condition of opening the PATH.
*            Soln is to add the ON ERROR clause along with the
*            ELSE clause.
*
* 21/09/02 - EN_10001196
*            Conversion of error messages to error codes.
*
* 31/10/03 - CI_10014225
*          - When using function "C", the PC.PERIOD is accepting
*          - Invalid Date
*
* 29/07/05 - BG_100009139
*            Added MB code.
*            In a MB env, only the lead companies are allowed to input
*            in the field COMPANY. When the lead company is input, PC.PERIOD.XREF
*            should be populated with book companies as well.
*            Ref: SAR-2005-05-06-0014
*
* 07/10/05 - CI_10035389 / REF:HD0514007
*          - When using version with Autom.fields, PC.PERIOD allows backdated record.
*
* 03/11/06 - BG_100012366
*            OPENSEQ is failing in jbase higher releases(4.1).Hence commenting out.
*
* 05/03/07 - EN_10003242
*            Modified to call DAS to select data.
*
* 14/02/08 - CI_10053712 (CSS REF:HD0802955)
*            In CHECK.FIELDS para PC.PCP.PERIOD.CLOSED.CANNOT.CHANGE.FURTHER is changed to
*            PC.PCP.PERIOD.CLOSED.CANT.CHANGE.FURTHER
*            Since both the error codes contain similar error message.
*
* 23/07/13 - Defect 730171 / Task 737686
*            Validation for the field DBASE.PATH has be modifed to accept any valid file
*            or a path (No \ or / are expected).
*
* 22/03/14 - Defect 907468 / Task 948779
*           When PC.PERIOD is created for a lead company with books from a lead company
*           without books the PC.PERIOD.XREF file gets updated only for the lead company
*           not for the book companies
*
* 12/01/15 - Enhancement - 1163835/Task  1215789
*            To Add Local Reference field.
*
* 26/09/17 - Defect 2192414/ Task 2286172
*            made system to throw validation error always against the field PERIOD.STATUS while previous PC.PERIOD is still in OPEN status
*            by introducing Cross Validation
*
* 03/04/19 - Task 3067669
*            Validate DBPATH.NAME only for Jbase environment
*
*************************************************************************
    $USING PC.Contract
    $USING AC.EntryCreation
    $USING EB.Utility
    $USING ST.CompanyCreation
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING EB.DataAccess

    $INSERT I_DAS.PC.PERIOD
    $INSERT I_DAS.PC.STMT.ADJUSTMENT
    $INSERT I_DAS.PC.CATEG.ADJUSTMENT

*************************************************************************

    GOSUB DEFINE.PARAMETERS


    IF LEN(EB.SystemTables.getVFunction()) GT 1 THEN

        RETURN
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

            EB.TransactionControl.RecordRead()

            GOSUB CHECK.ID    ;* Special Editing of ID
            IF V$ERROR THEN
                EB.ErrorProcessing.Err()
                CONTINUE ;* Continue to get the new id
            END

            IF EB.SystemTables.getMessage() EQ 'REPEAT' THEN
                CONTINUE ;* Continue to get the new id
            END

            EB.Display.MatrixAlter()

REM >       GOSUB CHECK.RECORD              ;* Special Editing of Record
REM >       IF ERROR THEN GOTO MAIN.REPEAT

REM >       GOSUB PROCESS.DISPLAY           ;* For Display applications

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

        IF EB.SystemTables.getTSequ() NE '' THEN
            tmp=EB.SystemTables.getTSequ(); tmp<-1>=EB.SystemTables.getA() + 1; EB.SystemTables.setTSequ(tmp)
        END

    REPEAT

RETURN

*************************************************************************

PROCESS.MESSAGE:

* Processing after exiting from field input (PF5)

    IF EB.SystemTables.getMessage() = 'DEFAULT' THEN
        EB.SystemTables.setMessage('ERROR');* Force the processing back
        IF EB.SystemTables.getVFunction() <> 'D' AND EB.SystemTables.getVFunction() <> 'R' THEN
REM >       GOSUB CROSS.VALIDATION
        END
    END

    IF EB.SystemTables.getMessage() = 'PREVIEW' THEN
        EB.SystemTables.setMessage('ERROR');* Force the processing back
        IF EB.SystemTables.getVFunction() <> 'D' AND EB.SystemTables.getVFunction() <> 'R' THEN
REM >       GOSUB CROSS.VALIDATION
REM >       IF NOT(ERROR) THEN
REM >          GOSUB DELIVERY.PREVIEW
REM >       END
        END
    END

    IF EB.SystemTables.getMessage() EQ 'VAL' THEN
        EB.SystemTables.setMessage('')
        BEGIN CASE
            CASE EB.SystemTables.getVFunction() EQ 'D'
REM >          GOSUB CHECK.DELETE              ;* Special Deletion checks
            CASE EB.SystemTables.getVFunction() EQ 'R'
REM >          GOSUB CHECK.REVERSAL            ;* Special Reversal checks
            CASE 1
                GOSUB CROSS.VALIDATION          ;* Special Cross Validation
                IF NOT(V$ERROR) THEN
                    GOSUB OVERRIDES
                END
        END CASE
REM >    IF NOT(ERROR) THEN
REM >       GOSUB BEFORE.UNAU.WRITE         ;* Special Processing before write
REM >    END
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
            GOSUB BEFORE.AUTH.WRITE
        END

        IF NOT(V$ERROR) THEN

            EB.TransactionControl.AuthRecordWrite()

REM >            IF MESSAGE NE "ERROR" THEN
REM >               GOSUB AFTER.AUTH.WRITE
REM >            END
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

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************
*
CHECK.ID:

    IF NOT(EB.SystemTables.getIdOld()) AND EB.SystemTables.getVFunction() <> 'S' THEN
        IF EB.SystemTables.getIdNew() NE EB.SystemTables.getRDates(EB.Utility.Dates.DatPeriodEnd) THEN
            EB.SystemTables.setE('PC.PCP.NEW.PERIOD':@FM:EB.SystemTables.getRDates(EB.Utility.Dates.DatPeriodEnd))
        END
    END

    IF EB.SystemTables.getE() THEN
        V$ERROR = 1
    END
*
RETURN
*
*************************************************************************

CHECK.RECORD:

* Validation and changes of the Record.  Set ERROR to 1 if in error.


RETURN

*************************************************************************

CHECK.FIELDS:

    BEGIN CASE
        CASE EB.SystemTables.getAf() = PC.Contract.Period.PerPeriodStatus
            COMP.FLG = '' ; COMP.ID = ''
            IF NOT(EB.SystemTables.getROld(PC.Contract.Period.PerPeriodStatus)) AND  EB.SystemTables.getComi() = 'CLOSED' THEN
                EB.SystemTables.setE('PC.PCP.STATUS.DISALLOWED.WHEN.DEFINING.NEW.PERIOD')
            END

            IF EB.SystemTables.getROld(PC.Contract.Period.PerPeriodStatus) = 'OPEN' THEN

                P.LIST       = dasPcPeriodOpenIdLtById
                THE.ARGS     = EB.SystemTables.getIdNew()
                TABLE.SUFFIX = ''
                EB.DataAccess.Das('PC.PERIOD',P.LIST,THE.ARGS,TABLE.SUFFIX)
                PCNT = DCOUNT(P.LIST, @FM)

                IF P.LIST NE '' THEN
                    EB.SystemTables.setE('PC.PCP.PERIOD/S.PRIOR.STILL.OPEN':@FM:EB.SystemTables.getIdNew())
                END ELSE

* check for outstanding entries that have not been posted
* must check both stmt and categ adjustment files.

                    GOSUB SETUP.POST.CHECK
                END
            END

* GB0002245 S
            IF EB.SystemTables.getROld(PC.Contract.Period.PerPeriodStatus) = 'CLOSED' THEN
                IF EB.SystemTables.getComi() AND (EB.SystemTables.getComi() NE EB.SystemTables.getROld(EB.SystemTables.getAf())) THEN
* GB0002245 E
                    EB.SystemTables.setE('PC.PCP.PERIOD.CLOSED.CANT.CHANGE.FURTHER')
                END
            END

        CASE EB.SystemTables.getAf() = PC.Contract.Period.PerCompany
            EB.SystemTables.setE('')

            IF NOT(EB.SystemTables.getComi()) THEN ;* If no value nothing to validate
                RETURN
            END

            ER = ''
            R.COMP = ST.CompanyCreation.Company.CacheRead(EB.SystemTables.getComi(), ER)
            IF ER THEN
                ER = ''
                EB.SystemTables.setE('PC.PCP.INVALID.COMP')
                RETURN
            END

            LEAD.CO.CODE = R.COMP<ST.CompanyCreation.Company.EbComFinancialCom>
            IF EB.SystemTables.getCMultiBook() AND LEAD.CO.CODE <> EB.SystemTables.getComi() THEN
                EB.SystemTables.setE('PC.PCP.MUST.BE.LEAD.COMP')
            END

            LOCATE  EB.SystemTables.getComi() IN EB.SystemTables.getRNew(PC.Contract.Period.PerCompany)<1,1> SETTING YUP THEN
                EB.SystemTables.setE('PC.PCP.YOU.HAVE.ENT.COMP.ALRDY')
            END

        CASE EB.SystemTables.getAf() = PC.Contract.Period.PerCompStatus
            COMP.FLG = '' ; COMP.ID = ''
* GB0002245 S
            IF EB.SystemTables.getROld(PC.Contract.Period.PerPeriodStatus) = 'CLOSED' THEN
                IF EB.SystemTables.getComi() AND (EB.SystemTables.getComi() NE EB.SystemTables.getROld(EB.SystemTables.getAf())) THEN
                    EB.SystemTables.setE('PC.PCP.PERIOD.CLOSED.CANT.CHANGE.FURTHER')
                    RETURN
                END
* GB0002245 E
            END

            IF NOT(EB.SystemTables.getROld(PC.Contract.Period.PerCompStatus)) THEN
                IF EB.SystemTables.getComi() = 'CLOSED' THEN
                    EB.SystemTables.setE('PC.PCP.STATUS.DISALLOWED.WHEN.DEFINING.NEW.PERIOD')
                END
            END ELSE
                IF EB.SystemTables.getROld(PC.Contract.Period.PerCompStatus)<1,EB.SystemTables.getAv()> = 'OPEN' THEN
                    COMP.FLG = 1
                    COMP.ID = EB.SystemTables.getROld(PC.Contract.Period.PerCompany)<1,EB.SystemTables.getAv()>
                    GOSUB SETUP.POST.CHECK
                END
            END

        CASE EB.SystemTables.getAf() = PC.Contract.Period.PerDbasePathname
* GB0002245 S
            GOSUB VALIDATE.DB.PATH ; ** Validate weather the entered path is valid
    END CASE

    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setTSequ("IFLD")
        EB.ErrorProcessing.Err()
    END

RETURN

*************************************************************************

VALIDATE.DB.PATH:
* Validate weather the entered path is valid

    IF EB.SystemTables.getROld(PC.Contract.Period.PerPeriodStatus) = 'CLOSED' THEN
        IF EB.SystemTables.getComi() AND (EB.SystemTables.getComi() NE EB.SystemTables.getROld(EB.SystemTables.getAf())) THEN
            EB.SystemTables.setE('PC.PCP.PERIOD.CLOSED.CANT.CHANGE.FURTHER')
        END
    END

** GB0002245 E

    VALID.PATH = 1
    FLD.DATA = EB.SystemTables.getComi()
    CONVERT '\' TO '/' IN FLD.DATA

* In Relational data base, PC Data base path will not contain any '/' or '\', so condition to check NO.SEP is removed.
* OPENPATH will open any given absolute or relative path
* e.g. 1. 'BP'
*      2. '../../bnk.data'
*      3. 'C:/Temenos/bnk.data'
* Condition modified to support all the data base, just to check whether the entered path or file is valid.

    IF NOT(EB.SystemTables.getRunningInTafj()) THEN ;*check database path only for TAFC
        OPENPATH FLD.DATA TO TEMP.OPEN ELSE
            EB.SystemTables.setE('PC.PCP.INVALID.PATHNAME.SPECIFIED')
        END
    END
*OPENSEQ FLD.DATA TO TEMP.OPEN ON ERROR FAILS = 1 ELSE FAILS = 1     ;* GLOBUS_BG_100000114 S/E

RETURN

*************************************************************************

SETUP.POST.CHECK:

* Elaborate check to see whether there are postings outstanding
* that have not been applied to the PC database yet
*  .eg Given that ....
* a single posting made to period 20000131 , will bear impact on all
* open periods after and including this period , one cannot close
* a company , or a period which this posting affects , until that
* posting has been applied to the PC database else we land up with
* a situation where a single posting may have been applied to one
* period or company , and not to another hence chaos

    FNAME = '' ; FNAME.1 = '' ; FNAME.2 = '' ; FNAME.3 = ''
    FOR POST.CHK = 1 TO 2

        THE.ARGS = EB.SystemTables.getIdNew()
        IF POST.CHK = 1 THEN
            FNAME = FN.PC.STMT.ADJUSTMENT.LOC
            FNAME.1 = F.PC.STMT.ADJUSTMENT.LOC
            FNAME.2 = FN.STMT.ENTRY.LOC
            FNAME.3 = F.STMT.ENTRY.LOC
            P.LIST = dasPcStmtAdjustmentStartPeriodLeById
            EB.DataAccess.Das('PC.STMT.ADJUSTMENT',P.LIST,THE.ARGS,'')
        END ELSE
            FNAME = FN.PC.CATEG.ADJUSTMENT.LOC
            FNAME.1 = F.PC.CATEG.ADJUSTMENT.LOC
            FNAME.2 = FN.CATEG.ENTRY.LOC
            FNAME.3 = F.CATEG.ENTRY.LOC
            P.LIST = dasPcCategAdjustmentStartPeriodLeById
            EB.DataAccess.Das('PC.CATEG.ADJUSTMENT',P.LIST,THE.ARGS,'')
        END

* Select all entries in PC.STMT/CATEG.ADJUSTMENT with a period LE
* the period in question , as these files are keyed with the period
* that is FIRST impacted by the posting . Obviously , there may be
* other periods as well , but we'll find this out once we get to
* the actual entry in STMT/CATEG entry from the PC.PERIOD.END fld
* As soon as we find a relevant unapplied posting , we display the
* error and get out .

        PCNT = DCOUNT(P.LIST,@FM)

        IF PCNT > 0 THEN
            GOSUB CHECK.POST.FLAG
            IF EB.SystemTables.getE() THEN
                EXIT
            END
        END
    NEXT POST.CHK

RETURN
*************************************************************************

CHECK.POST.FLAG:

    FOR CHK.LP = 1 TO PCNT
        CHK.ID = TRIM(FIELD(P.LIST<CHK.LP>,'-',3))
        CHK.REC = '' ; ERRTXT = ''
* read entry from either stmt/categ entry
        EB.DataAccess.FRead(FNAME.2,CHK.ID,CHK.REC,FNAME.3,ERRTXT)
        IF ERRTXT NE '' THEN
            EB.SystemTables.setText('ERROR READING ':FNAME.2:' ID = ':CHK.ID)
            EB.ErrorProcessing.FatalError('PC.PERIOD')
        END

* Field positions for STMT.ENTRY and CATEG.ENTRY are same hence removed the file based conditions
* condition CHK.REC<AC.STE.PC.APPLIED,CHK.ARR> NE 'Y' is common for period end and company specific check and taken as the prime condition
        FOR CHK.ARR = 1 TO DCOUNT(CHK.REC<AC.EntryCreation.StmtEntry.StePcPeriodEnd>,@VM)
            IF CHK.REC<AC.EntryCreation.StmtEntry.StePcPeriodEnd,CHK.ARR> <= EB.SystemTables.getIdNew() THEN
                IF CHK.REC<AC.EntryCreation.StmtEntry.StePcApplied,CHK.ARR> NE 'Y' THEN
                    IF NOT(COMP.FLG) THEN     ;* period close check
                        EB.SystemTables.setE('PC.PCP.UNAPPLIED.ADJUSTMENTS.PERIOD.EXIST':@FM:CHK.REC<AC.EntryCreation.StmtEntry.StePcPeriodEnd,CHK.ARR>)
                        RETURN
                    END
* Once COMP.PLAG is not set the above condition will be satisfied and returned no need
* to but the company check as else case, thus avoiding one level of nesting

                    IF CHK.REC<AC.EntryCreation.StmtEntry.SteCompanyCode> = COMP.ID THEN  ;* company close check
                        EB.SystemTables.setE('PC.PCP.ADJUSTMENTS.TO.COMPANY':@FM:COMP.ID:@VM:CHK.REC<AC.EntryCreation.StmtEntry.StePcPeriodEnd,CHK.ARR>)
                        RETURN
                    END
                END
            END ELSE
                EXIT
            END
        NEXT CHK.ARR
    NEXT CHK.LP

RETURN

*************************************************************************

CROSS.VALIDATION:
 
*
    V$ERROR = ''
    EB.SystemTables.setEtext('')
    EB.SystemTables.setText('')
*
REM > CALL XX.CROSSVAL
*
    IF EB.SystemTables.getROld(PC.Contract.Period.PerPeriodStatus) = 'OPEN' THEN

        P.LIST       = dasPcPeriodOpenIdLtById
        THE.ARGS     = EB.SystemTables.getIdNew()
        TABLE.SUFFIX = ''
        EB.DataAccess.Das('PC.PERIOD',P.LIST,THE.ARGS,TABLE.SUFFIX)
        
        IF P.LIST NE '' THEN   ;*check whether previous PC.PERIOD is still OPEN status
            EB.SystemTables.setAf(PC.Contract.Period.PerPeriodStatus)
            EB.SystemTables.setEtext("PC-PERIOD/S.PRIOR.STILL.OPEN":@FM:EB.SystemTables.getIdNew()) ;*If PC periods not closed in a chronological order throw error
            EB.ErrorProcessing.StoreEndError()
        END
    END
* If END.ERROR has been set then a cross validation error has occurred
*
    IF EB.SystemTables.getEndError() THEN
        EB.SystemTables.setA(1)
        LOOP UNTIL EB.SystemTables.getTEtext()<EB.SystemTables.getA()> <> "" DO EB.SystemTables.setA(EB.SystemTables.getA()+1); REPEAT
        EB.SystemTables.setTSequ('D')
        tmp=EB.SystemTables.getTSequ(); tmp<-1>=EB.SystemTables.getA(); EB.SystemTables.setTSequ(tmp)
        V$ERROR = 1
        EB.SystemTables.setMessage('ERROR')
    END

RETURN          ;* Back to field input via UNAUTH.RECORD.WRITE

*************************************************************************

OVERRIDES:
*
* Overrides go here

REM > ERROR = '' ; ETEXT = '' ; TEXT = ''
REM > CALL XX.OVERRIDE(CURR.NO)

REM >      IF TEXT = 'NO' THEN
REM >         ERROR = 1
REM >         MESSAGE = 'ERROR'
REM >      END

RETURN

*************************************************************************

AUTH.CROSS.VALIDATION:


RETURN

*************************************************************************

CHECK.DELETE:


RETURN

*************************************************************************

CHECK.REVERSAL:


RETURN

*************************************************************************

BEFORE.UNAU.WRITE:
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

AFTER.UNAU.WRITE:

RETURN

*************************************************************************

AFTER.AUTH.WRITE:

RETURN

*************************************************************************

BEFORE.AUTH.WRITE:

* Auto populate or delete PC.PERIOD.XREF application , depending on
* the changes that have been applied to PC.PERIOD (current applic)

    PERIOD.ID = EB.SystemTables.getIdNew()

    R.COMPANY.CHECK = ''

* Removed the multi book check because when a PC.PERIOD is created for a
* lead company with books from lead company without books the PC.PERIOD.XREF
* does not get updated for the book companies as the read was done only if
* the variable C$MULTI.BOOK is set. It will be set only when the lead company
* in which the user has logged in has book companies
    ER = ''
    R.COMPANY.CHECK = ST.CompanyCreation.CompanyCheck.Read('FINANCIAL', ER)
    BEGIN CASE
        CASE EB.SystemTables.getRNew(EB.SystemTables.getV()-8)[1,3] = "INA"
* Either a new period , or company has been amended

            FOR CO.CNT = 1 TO DCOUNT(EB.SystemTables.getRNew(PC.Contract.Period.PerCompany),@VM)
                XREF.ID = EB.SystemTables.getRNew(PC.Contract.Period.PerCompany)<1,CO.CNT>
                BOOK.COMP.IDS = ''
                LOCATE XREF.ID IN R.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocCompanyCode,1> SETTING COMP.POS THEN
                    BOOK.COMP.IDS = R.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocUsingCom,COMP.POS>
                    CHANGE @SM TO @FM IN BOOK.COMP.IDS
                END
                I = 0
                LOOP
                WHILE XREF.ID

                    ERTXT = '' ; XREF.REC = ''
                    XREF.REC = PC.Contract.PeriodXref.Read(XREF.ID, ERTXT)
                    IF NOT(ERTXT) THEN      ;* must be new period
                        LOCATE PERIOD.ID IN XREF.REC<PC.Contract.PeriodXref.XrefPeriodEnd,1> BY 'AL' SETTING FND ELSE
                            XREF.REC<PC.Contract.PeriodXref.XrefPeriodEnd> = INSERT(XREF.REC<PC.Contract.PeriodXref.XrefPeriodEnd>,1,FND,0,PERIOD.ID)
                        END
                    END ELSE      ;* entirely new company
                        XREF.REC<PC.Contract.PeriodXref.XrefPeriodEnd,1> = PERIOD.ID
                    END
                    PC.Contract.PeriodXref.Write(XREF.ID, XREF.REC)
                    I+=1
                    XREF.ID = BOOK.COMP.IDS<I>
                REPEAT
            NEXT CO.CNT

        CASE EB.SystemTables.getRNew(EB.SystemTables.getV()-8)[1,3] = "RNA"
* Period record reversed , thus amend PC.PERIOD.XREF accordingly

            FOR CO.CNT = 1 TO DCOUNT(EB.SystemTables.getRNew(PC.Contract.Period.PerCompany),@VM)
                XREF.ID = EB.SystemTables.getRNew(PC.Contract.Period.PerCompany)<1,CO.CNT>
                BOOK.COMP.IDS = ''
                LOCATE XREF.ID IN R.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocCompanyCode,1> SETTING COMP.POS THEN
                    BOOK.COMP.IDS = R.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocUsingCom,COMP.POS>
                    CHANGE @SM TO @FM IN BOOK.COMP.IDS
                END
                I = 0
                LOOP
                WHILE XREF.ID
                    ERTXT = '' ; XREF.REC = ''
                    XREF.REC = PC.Contract.PeriodXref.Read(XREF.ID, ERTXT)
                    IF NOT(ERTXT) THEN
                        LOCATE PERIOD.ID IN XREF.REC<PC.Contract.PeriodXref.XrefPeriodEnd,1> BY 'AL' SETTING FND THEN
                            XREF.REC<PC.Contract.PeriodXref.XrefPeriodEnd> = DELETE(XREF.REC<PC.Contract.PeriodXref.XrefPeriodEnd>,1,FND,0)
                        END
                        PC.Contract.PeriodXref.Write(XREF.ID, XREF.REC)
                    END
                    I+=1
                    XREF.ID = BOOK.COMP.IDS<I>
                REPEAT
            NEXT CO.CNT

    END CASE
*
* If there are any OVERRIDES a call to EXCEPTION.LOG should be made
*
* IF R.NEW(V-9) THEN
*    EXCEP.CODE = "110" ; EXCEP.MESSAGE = "OVERRIDE CONDITION"
*    GOSUB EXCEPTION.MESSAGE
* END
*

RETURN

*************************************************************************

CHECK.FUNCTION:

* Validation of function entered.  Set FUNCTION to null if in error.

    IF INDEX('V',EB.SystemTables.getVFunction(),1) THEN
        EB.SystemTables.setE('PC.PCP.FUNT.NOT.ALLOW.APP')
        EB.ErrorProcessing.Err()
        EB.SystemTables.setVFunction('')
    END

RETURN

*************************************************************************
*
EXCEPTION.MESSAGE:
*
	EXCEP.MESSAGE = ''
    EB.ErrorProcessing.ExceptionLog("U",APP.CODE,APPLN,APPLN,EXCEP.CODE,"",EB.SystemTables.getFullFname(),EB.SystemTables.getIdNew(),EB.SystemTables.getRNew(EB.SystemTables.getV()-7),EXCEP.MESSAGE,ACCT.OFFICER)

*
RETURN

*************************************************************************

INITIALISE:

    GOSUB OPEN.XREF.PERIOD
    APP.CODE = ""   ;* Set to product code ; e.g FT, FX
    ACCT.OFFICER = ""         ;* Used in call to EXCEPTION. Should be relevant A/O
    EXCEP.CODE = ""

RETURN

*************************************************************************

DEFINE.PARAMETERS:

    EB.SystemTables.clearF()
    EB.SystemTables.clearN()
    EB.SystemTables.clearT()
    EB.SystemTables.setIdT("")
    EB.SystemTables.clearCheckfile()
    EB.SystemTables.clearConcatfile()

    EB.SystemTables.setIdCheckfile(""); EB.SystemTables.setIdConcatfile("")
    Z = 0

    EB.SystemTables.setIdF('PERIOD.END'); EB.SystemTables.setIdN('11..C'); tmp=EB.SystemTables.getIdT(); tmp<1>='D'; EB.SystemTables.setIdT(tmp)

    Z += 1 ; EB.SystemTables.setF(Z, "PERIOD.STATUS"); EB.SystemTables.setN(Z, "8.1.C"); tmp=EB.SystemTables.getT(Z); tmp<2>='OPEN_CLOSED'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, "XX<COMPANY"); EB.SystemTables.setN(Z, "10.1.C"); tmp=EB.SystemTables.getT(Z); tmp<1>="COM"; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, "XX>COMP.STATUS"); EB.SystemTables.setN(Z, '8.1.C'); tmp=EB.SystemTables.getT(Z); tmp<2>='OPEN_CLOSED'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, "DBASE.PATHNAME"); EB.SystemTables.setN(Z, '35.1.C'); EB.SystemTables.setT(Z, 'A')
    Z += 1 ; EB.SystemTables.setF(Z, 'RESERVED.1'); EB.SystemTables.setN(Z, ''); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, "XX.LOCAL.REF"); EB.SystemTables.setN(Z, "35"); EB.SystemTables.setT(Z, "A"); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'RESERVED.3'); EB.SystemTables.setN(Z, ''); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)

    EB.SystemTables.setV(Z + 9); EB.SystemTables.setPrefix('PC.PER')

RETURN

OPEN.XREF.PERIOD:


    F.PC.STMT.ADJUSTMENT.LOC = ''
    FN.PC.STMT.ADJUSTMENT.LOC = 'F.PC.STMT.ADJUSTMENT'
    EB.DataAccess.Opf(FN.PC.STMT.ADJUSTMENT.LOC,F.PC.STMT.ADJUSTMENT.LOC)

    F.PC.CATEG.ADJUSTMENT.LOC = ''
    FN.PC.CATEG.ADJUSTMENT.LOC = 'F.PC.CATEG.ADJUSTMENT'
    EB.DataAccess.Opf(FN.PC.CATEG.ADJUSTMENT.LOC,F.PC.CATEG.ADJUSTMENT.LOC)

    F.STMT.ENTRY.LOC = ''
    FN.STMT.ENTRY.LOC = 'F.STMT.ENTRY'
    EB.DataAccess.Opf(FN.STMT.ENTRY.LOC,F.STMT.ENTRY.LOC)

    F.CATEG.ENTRY.LOC = ''
    FN.CATEG.ENTRY.LOC = 'F.CATEG.ENTRY'
    EB.DataAccess.Opf(FN.CATEG.ENTRY.LOC,F.CATEG.ENTRY.LOC)

RETURN

*************************************************************************

END
