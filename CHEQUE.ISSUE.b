* @ValidationCode : MjoxNTIxMDcyODc1OkNwMTI1MjoxNjExOTI0NjU2NDQ0OnF1YXppcmFoYmVyLnJhYmJhbmk6OTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMS4yMDIwMTIyNi0wNjE4Ojg1NDo1NjE=
* @ValidationInfo : Timestamp         : 29 Jan 2021 18:20:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : quazirahber.rabbani
* @ValidationInfo : Nb tests success  : 9
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 561/854 (65.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202101.20201226-0618
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>6935</Rating>
*-----------------------------------------------------------------------------
* Version 9 15/11/00  GLOBUS Release No. G11.1.01 11/12/00

$PACKAGE CQ.ChqIssue
SUBROUTINE CHEQUE.ISSUE

******************************************************************
*
* 21/04/97 - GB9700339
*            EB.ACCOUNTING must be called instead of ACCOUNTING &
*            ACCOUNTING.AUT
*
* 16/03/98 - GB9800263
*            Allow foreign currency charges if configured to do so
*
* 09/12/98 - GB9801552
*            Initialise LCY.AMT
*
* 19/02/99 - GB9900129
*            Add new reserved fields.
*
*            This application must additionally check to see that if the
*            field CHEQUE.NOS.USED has been set to 'YES' the cheque nos.
*            being issued here do not exist in the field CHEQUE.NOS.USED
*
*            If the CHEQUE.REGISTER field on the ACCOUNT.PARAMETER record
*            has been set to 'YES' and the CHEQUE.TYPE of the cheques being
*            issued have not been linked to a TRANSACTION record then an
*            error must be thrown at the user. The concat file TRN.CHQ.TRNS
*            could be used to check this.
*
* 18/03/99 - GB9900471
*            The program must cater for a situation where no charges
*            are needed at all. This would be in the case of bank
*            drafts being issued.
*
* 23/03/99 - GB9900508
*            On reversing cheque issue records. The validation
*            checks whether any cheques have been presented or
*            stopped before allowing this to happen. This must
*            be changed to check for only those cheques on the
*            cheque issue record.
*            On reversal the cheque numbers on the cheque issue
*            record must be removed from the cheque recister.
*
* 30/03/99 - GB9900548
*            The application allows for issuing the same cheque numbers
*            to the same account again and again.
*            On reversal the cheque register record must not be removed
*            from the live file. Instead on every change performed
*            a history record must be written out always to maintain
*            a clear audit trail.
*
* 17/08/99 - GB9901117
*            Allow zero chargs to be entered
*
* 14/10/99 - GB9901421 Add audit info. on creation
*
* 06/09/01 - GLOBUS_EN_10000101
*            Enhanced Cheque.Issue to collect charges at each Status
*            and link to Soft Delivery
*            - Changed Cheque.Issue to standard template
*            - Changed all values captured in ER to capture in E
*            - GoTo Check.Field.Err.Exit has been changed to GoTo Check.Field.Exit
*            - All the variables are set in I_CI.COMMON
*
*            New fields added to the template are
*            - Cheque.Status
*            - Chrg.Code
*            - Chrg.Amount
*            - Tax.Code
*            - Tax.Amt
*            - Waive.Charges
*            - Class.Type       : -   Link to Soft Delivery
*            - Message.Class    : -      -  do  -
*            - Activity         : -      -  do  -
*            - Delivery.Ref     : -      -  do  -
*
* 22/10/01 - GLOBUS_CI_10000413
*            - Cheque.issue.account & cheque.register records are updated
*              only for status = 90.  This solves the problem of updating
*              both the records whenever there is a change in cheque.issue
*            - Changed the variable name ISSUE.END.DATE to CQ$ISSUE.END.DATE
*            - Reversal allowed only for cheque status = 90
*
* 23/10/01 - GLOBUS_BG_100000159
*            - Included the 3rd parameter in F.RELEASE
*            - Delivery message is produced while using comma version
*
* 14/02/02 - GLOBUS_EN_10000353
*          - Introduce STOCK.REGISTER, SERIES.ID & AUTO.CHEQUE.NUMBER
*          - for STOCK CONTROL enhancements.
*
* 18/03/02 - GLOBUS_BG_100000738
*            Bug fixes related to STOCK CONTROL enhancements.
*
* 05/04/02 - GLOBUS_BG_100000832
*            Bug fixes related to STOCK application.
*
* 08/04/02 - GLOBUS_CI_10001520
*            Junk characters are not suppressed in COMO of CARD.CHEQUE.EOD
*
* 16/05/02 - GLOBUS_CI_10001925
*            Sequence number validation for the CHEQUE.ISSUE id
*
* 20/09/02 - EN_10001178
*            Conversion of error messages to error codes.
*
* 18/10/02 - BG_100002425
*            Bug fixes for payment stop - performance improvement
*
* 12/02/04 - BG_100006210
*            Changes related to transaction management.
*
* 13/02/04 - CI_10017384
*            Wrong updatin of ISSUE.TO.DATE field in CHEQ.REG
* 30/03/04 - CI_10018599
*            Customer or Account Name is not displayed in DESKTOP
*
* 05/04/04 - BG_100006461
*            Bug fixes for crashing the CHEQUE.ISSUE application
*
* 07/04/04 - CI_10018812
*             system allows to input a cheque.issue record in one
*             company for an account that is in the other company
*
* 30/09/04 - CI_10023587/CI_10023588
*                  System not updating CHEQUE.REGISTER, if the
*                  chq issue is done in stages of 60,70,90 etc.
*
* 08/11/04 - CI_10024589
*                   Unable to input CHQ.TYPE:MNEMONIC in chq.issue id
*
* 10/11/04 - BG_100007614
*                  Bug fix for CI_10024589
*
* 08/12/04 - CI_10025505
*            Select statement of Cheques Presented and Cheques Stopped
*            records while reversing  a Cheque Issue record has been
*            modified to Loop statement for easy fetching of records.
*
* 23/12/04 - CI_10025789
*            The Sequence No of the CHEQUE.ISSUE ID has been
*            checked for numeric values only.
* 17/05/05 - CI_10030290
*             Unable to amend local ref field when status is 90.
* 24/06/06 - CI_10031611
*            Cheques should be issued in account's company only.
*
* 12/07/05 - EN_10002578
*            Unable to do CHEQUE.ISSUE in browser.
*
* 19/07/05 - BG_100009107
*            Unable to commit the txn through browser when charges are input in CHEQUE.ISSUE.
*
* 21/07/05 - CI_10032559
*            Use IN2ACC to validate account mnemonic or alternate account.
*
* 26/07/05 - CI_10032752
*            Cheques should be allowed to be issued only in it's account
*            company. But it can be seen from Other books as well.
*
* 22/09/05 - EN_10002679
*            Support for DE Preview in Browser.
*            Template level changes required to support this functionality
*            SAR-2005-05-10-0002
*
* 30/09/05 - CI_10035187
*            If any error message is returned from UPDATE.STOCK.REGISTER routine
*            then they are not handled properly in this routine.
*
* 18/11/05 - CI_10036574
*            Reverse CHEQUE.ISSUE,account record missing in CHEQUE.TYPE.ACCOUNT
*
* 02/03/06 - CI_10039402
*            The field LAST.EVENT.SEQ will retain the highest sequence number
*            input for the account.
*
* 04/08/06 - CI_10043160
*            Enrichment of account short title  for the ID of CHEQUE.ISSUE
*            is not displayed in browser.
*
* 06/08/06 - CI_10044637
*            When a cheque book is issued to  a customer's account,
*            the field .CHARGE.CODE. is getting closed into No-input
*
* 06/12/06 - BG_100012531
*            Problem with CHQ.NO.START field.
*
* 07/02/07 - EN_10003189
*            When LAST.EVENT.SEQ of CHEQUE.REGISTER reaches 99999 no new cheque issue
*            record is being allowed to input.
*
* 20/02/07 - EN_10003187
*            DAS Retail - Application Changes
*
* 27/06/07 - CI_10050047
*            Here T field validation are removed and moved to TT.FIELD.DEFINITIONS.
*
* 06/11/07 - CI_10052495
*            Not able to input a CHEQUE.ISSUE for an account which exist in other branch
*            eventhough the AUTO.COMP.CHANGE field is set to YES
*
* 02/01/08 - BG_100016496
*            CQ$CHG.DATA and CQ$J.CHARGES value is cleared.
*
* 26/03/09 - CI_10061661
*            CHEQUE.NOS in CHEQUE.REGISTER not inserted in sorted order.
*
* 18/07/09 - EN_10004226
*            Ref : SAR-2008-10-17-0009
*            Generate alert message while issueing the cheque book
*
* 19/08/10 - Task 78181
*            Ref : Defect 74957
*            If CHEQUE.ISSUE is inputted for the restored account , System will throw an
*            error message "RECORD ALREADY STORED IN HISTORY FILE"
*
* 20/10/10 - Task - 84420
*            Replace the enterprise(customer service api)code into  Banking framework related
*            routines which reads CUSTOMER.
*
* 31/01/11 - 120329
*            Banker's Draft Management.
*            CHEQUES.PRESENTED & CHEQUES.STOPPED is not replaced with a centralized
*            table called  CHEQUE.REGISTER.SUPPLEMENT.
*
* 01/03/11 - 161956
*            Don't do unnecessary reads for Internal cheques.
*
* 12/07/11 - Task : 243057
*            Ref : Defect 239031
*            The variable ID.COMPANY has not restored back. Hence request cheque book error occurs in browser.
*
* 07/09/11 - Task 272568
*            Ref : Defect 271473
*            Can view the cheque.issue details for authorised records even after changing
*            the ISSUE.CHEQUES to 'NO' in  customer record.
*
* 04/11/11 - Task : 303337
*            REF : 302587
*            CHEQUE.REGISTER locked while reading to find the LAST.EVENT.SEQ
*            F.READU used to read instead of F.READ
*
* 16/11/11 - 307887
*            Ref :305675
*            Delete,Print and View of Unauthrosed entries allowed for closed account if Account status in history
*            is closed in Account Application
*
* 13/12/11 - Task 323349
*            Uninitialised variable error for SAVE.COMPANY.
*
* 29/03/11 - Task 380865
*            changes made to check the CATEGORY of an ACCOUNT against the CHEQUE.TYPE category .when we try to
*            issue a cheque using CHEQUE.ISSUE.
*
* 10/08/12 - Task 461899
*            Validation added to amend NOTES field in already authorized CHEQUE.ISSUE record.
*
* 23/01/14 - Task 894819
*            Validation added to get own company code for each session hence no intermission of another session
*            which belongs to another branch this will avoid unnecessary GL balance.
*
* 17/07/14 - Defect 1021855 / Task 1060921
*            System will not allow user to issue cheque for a account whose arrangement activity is in INAU
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Issue as ST_ChqIssue and include $PACKAGE
*
* 13/03/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().
*
* 09/10/15 - Defect 1422942 / Task 1494749
*            Removed HUSH to update the jobs trace in the &COMO& file.
*
* 16/10/15 - Enhancement 1265068/ Task 1504013
*          - Routine incorporated
*
* 20/4/2017 - EN176879/ Task 2094719
*       Remove dependency of code in ST products
*
* 13/09/17 - Defect 2265614 / Task 2269250
*            System should not update negative values in the field ISSUED.TO.DATE of CHEQUE.REGISER record when
*            reversing CHEQUE.ISSUE record
*
* 17/08/18 - Defect 2702965/Task 2718557
*             CHEQUE.ISSUE.ACCOUNT records are created for records with all status. if no data is present in the CHEQUE.ISSUE.ACCOUNT the record
*               is deleted.
*
* 29/10/18 - Defect 2832734 / Task 2833021
*            To call UPDATE.STOCK.REGISTER for customer account cheques
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
* 28/08/19 - Defect 3306811 / Task 3311084
*            CHEQUE.REGISTER record is read without lock while viewing the CHEQUE.ISSUE record.
*
* 06/09/19 - Enhancement 3220240 / Task 3323431
*            Fix made to call UPD.RAT Api.
*
* 26/12/19 - Defect 3498711 / Task 3507893
*            Account record not passed to TEC events due to use of wrong variable
* 31/01/20 - Enhancement 3367949 / Task 3565098
*            Changing reference of routines that have been moved from ST to CG
* 14/01/21 - Enhancement 3784714 / Task 4154238
*            calculate Tax on the cheque issued charges and set to empry after authorized
************************************************************************************
    $USING CQ.ChqIssue
    $USING AC.AccountOpening
    $USING CQ.ChqFees
    $USING CQ.ChqConfig
    $USING CQ.ChqSubmit
    $USING EB.Utility
    $USING AC.Config
    $USING EB.Security
    $USING AC.EntryCreation
    $USING ST.Customer
    $USING ST.CurrencyConfig
    $USING CQ.ChqStockControl
    $USING EB.Versions
    $USING AA.Framework
    $USING ST.CompanyCreation
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.Template
    $USING EB.ErrorProcessing
    $USING EB.DataAccess
    $USING EB.Reports
    $USING AC.API
    $USING EB.DatInterface
    $USING EB.API
    $USING EB.AlertProcessing
    $USING EB.SystemTables
    $USING EB.Interface
    $INSERT I_DAS.CHEQUE.STATUS

*************************************************************************
    acInstalled = @FALSE
    EB.API.ProductIsInCompany('AC', acInstalled)

    GOSUB DEFINE.PARAMETERS

    V$FUNCTION.VAL = EB.SystemTables.getVFunction()
    IF LEN(V$FUNCTION.VAL) GT 1 THEN
        EB.SystemTables.setVFunction(V$FUNCTION.VAL)
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

            GOSUB CHECK.ID    ;* Special Editing of ID
            IF V$ERROR THEN
                GOTO MAIN.REPEAT
            END

            EB.TransactionControl.RecordRead()

            IF EB.SystemTables.getMessage() EQ 'REPEAT' THEN
                GOTO MAIN.REPEAT
            END

            EB.Display.MatrixAlter()

            GOSUB CHECK.RECORD          ;* Special Editing of Record
            IF V$ERROR THEN
                GOTO MAIN.REPEAT
            END

            LOOP
                GOSUB PROCESS.FIELDS    ;* ) For Input
                GOSUB PROCESS.MESSAGE   ;* ) Applications
            WHILE (EB.SystemTables.getMessage() EQ 'ERROR') REPEAT

        END

MAIN.REPEAT:
    REPEAT

    IF SAVE.COMPANY AND SAVE.COMPANY NE EB.SystemTables.getIdCompany() THEN
        ST.CompanyCreation.LoadCompany(SAVE.COMPANY)
    END

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

        MESSAGE.VAL = EB.SystemTables.getMessage()
    WHILE NOT(MESSAGE.VAL)
        EB.SystemTables.setMessage(MESSAGE.VAL)

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
        IF EB.SystemTables.getVFunction()<> 'D' AND EB.SystemTables.getVFunction()<> 'R' THEN
            GOSUB CROSS.VALIDATION
        END
    END

    IF BROWSER.PREVIEW.ON THEN          ;* EN_10002679 - s
* Clear BROWSER.PREVIEW.ON once inside the template so that after preview
* it might exit from the template, otherwise there will be looping within the template.
        EB.SystemTables.setMessage('PREVIEW')
        BROWSER.PREVIEW.ON = 0
    END   ;* EN_10002679 - e

* EN_10000101 - s

    IF EB.SystemTables.getMessage() = 'PREVIEW' THEN
        IF EB.SystemTables.getVFunction()<> 'D' AND EB.SystemTables.getVFunction()<> 'R' THEN
            IF EB.SystemTables.getVFunction() MATCH 'I':@VM:'C' THEN
                GOSUB CROSS.VALIDATION
            END
            IF NOT(V$ERROR) THEN
                GOSUB DELIVERY.PREVIEW  ;* Activate print preview
            END
        END
        EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)
        AF1 = EB.SystemTables.getAf()
        EB.SystemTables.setComi(EB.SystemTables.getRNew(AF1))
        EB.SystemTables.setAv(0)
        EB.SystemTables.setAs(0)
        LOCATE EB.SystemTables.getAf() IN EB.SystemTables.getTFieldno()<1> SETTING DPOS THEN
            tmp=EB.SystemTables.getTSequ(); tmp<-1>='D':DPOS; EB.SystemTables.setTSequ(tmp)
        END
    END

* EN_10000101 - e

    IF EB.SystemTables.getMessage() EQ 'VAL' THEN
        EB.SystemTables.setMessage('')
        BEGIN CASE
            CASE EB.SystemTables.getVFunction() EQ 'D'
                GOSUB CHECK.DELETE          ;* Special Deletion checks
            CASE EB.SystemTables.getVFunction() EQ 'R'
                GOSUB CHECK.REVERSAL        ;* Special Reversal checks
            CASE 1
                GOSUB CROSS.VALIDATION      ;* Special Cross Validation
                IF NOT(V$ERROR) THEN
                    GOSUB OVERRIDES
                END
        END CASE
        IF NOT(V$ERROR) THEN
            GOSUB BEFORE.UNAU.WRITE     ;* Special Processing before write
        END
        IF NOT(V$ERROR) THEN
            EB.TransactionControl.UnauthRecordWrite()
*When there is change on change don't clear the STMT.NO. When the txn is comitted through browser the STMT.NO will be set to 'VAL'  ;*BG_100009107 S
*initially. The overrides are then displayed, after accepting the overrides stmt.no should be passed as null.
            IF NOT(EB.SystemTables.getRNewLast(1)) AND EB.SystemTables.getMessage() = 'ERROR'  THEN
                EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStmtNo, '')
            END     ;*BG_100009107 E
            IF EB.SystemTables.getMessage() NE "ERROR" THEN
                GOSUB AFTER.UNAU.WRITE  ;* Special Processing after write
            END
        END

    END


    IF EB.SystemTables.getMessage() EQ 'AUT' THEN
        GOSUB AUTH.CROSS.VALIDATION     ;* Special Cross Validation
        IF NOT(V$ERROR) THEN
            GOSUB BEFORE.AUTH.WRITE     ;* Special Processing before write
        END

        IF NOT(V$ERROR) THEN

            EB.TransactionControl.AuthRecordWrite()

            IF EB.SystemTables.getMessage() NE "ERROR" THEN
                GOSUB AFTER.AUTH.WRITE  ;* Special Processing after write
            END
        END

    END

RETURN

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************

CHECK.ID:

* Validation and changes of the ID entered.  Set ERROR to 1 if in error.

    EB.SystemTables.setEtext('')
    ER = ''
    EB.SystemTables.setE('')
    V$ERROR = 0
    CQ.ChqIssue.setCqChgData('');*BG_100016496 - S/E
    CQ.ChqIssue.setCqJCharges('');*BG_100016496 - S/E
    CQ.ChqIssue.setCqIssuedThisPd(0)
    CQ.ChqIssue.setCqNumberIs(0)
    CQ.ChqIssue.setCqIssueStartDate('')
    CQ.ChqIssue.setCqIssueEndDate('');* CI_10000413
    CQ.ChqIssue.setCqIssueRollover(0)
    R.REG = ''
*

    ID.NEW.VAL = EB.SystemTables.getIdNew()
    CHEQUE.TYPE.ID = FIELD(ID.NEW.VAL,'.',1)
    CQ.ChqIssue.setCqChequeAccId(FIELD(ID.NEW.VAL,'.',2))
    CHEQUE.SEQ.ID = FIELD(ID.NEW.VAL,'.',3)
    USER.CHQ.SEQ = CHEQUE.SEQ.ID        ;* (User entered cheque.seq.no)
    IF LEN(CHEQUE.TYPE.ID) > 4 THEN
        CQ.ChqIssue.setCqChequeAccId(CHEQUE.TYPE.ID)
        CHEQUE.TYPE.ID = ''
    END

**CI_10018812 S
    R.ACC = ''
    SAVE.COMI = EB.SystemTables.getComi() ; EB.SystemTables.setComi(CQ.ChqIssue.getCqChequeAccId());* CI_10032559 S
    N.VAL = CQ.ChqIssue.getCqMaxLen():'.1'
    EB.Template.In2ant(N.VAL,'ACC')
    CQ.ChqIssue.setCqChequeAccId(EB.SystemTables.getComi()); EB.SystemTables.setComi(SAVE.COMI)
    IF EB.SystemTables.getEtext() THEN
        EB.SystemTables.setE('ST.CHR.INVALID.OR.MISS.AC')
        EB.ErrorProcessing.Err()
        EB.SystemTables.setE(''); EB.SystemTables.setEtext(''); V$ERROR = 1
        RETURN
    END   ;* CI_10032559 E
    ACC.ID = CQ.ChqIssue.getCqChequeAccId()
    R.REC = ''
    R.REC = AC.AccountOpening.Account.Read(ACC.ID, ACC.ER)
    R.ACC = R.REC
    CQ.ChqIssue.setCqCiAccount(R.REC)
    IF ACC.ER THEN
        GOSUB CHECK.HISTORY
        IF NOT(R.HIS.ACC) THEN
            EB.SystemTables.setE('ST.CHR.INVALID.OR.MISS.AC')
            EB.ErrorProcessing.Err()
            EB.SystemTables.setE('')
            V$ERROR = 1
            RETURN
        END
        CQ.ChqIssue.setCqCiAccount(R.HIS.ACC)
    END ELSE
* if account exist then get the ARR id from ACCOUNT application
        ARR.ID = CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.ArrangementId>
    END

* If AA is installed and Account is in arrangement account
    IF AA.INSTALLED AND ARR.ID THEN
        GOSUB AA.CHECK
        IF EB.SystemTables.getEtext() THEN
            EB.SystemTables.setE('FT-AA.IN.UNAUTH')
            EB.ErrorProcessing.Err()
            EB.SystemTables.setE(''); EB.SystemTables.setEtext(''); V$ERROR = 1
            RETURN
        END
    END
**CI_10018812 E
    REC.ID = EB.SystemTables.getIdNew()
    CHQ.ISS.REC = CQ.ChqIssue.ChequeIssue.Read(REC.ID, CHQ.ISS.ERR)   ;* EN_10003189 - S
**CI_10018812 E
    BEGIN CASE
        CASE CHEQUE.TYPE.ID AND CQ.ChqIssue.getCqChequeAccId() AND CHEQUE.SEQ.ID AND NOT(CHQ.ISS.REC)
            IF LEN(CHEQUE.SEQ.ID) GT 7 THEN
                EB.SystemTables.setE('ST-EXCEEDS.MAX.SEQUENCE.NO')
            END
            CHEQUE.SEQ.ID = FMT(CHEQUE.SEQ.ID,'7"0"R')

        CASE CHEQUE.TYPE.ID AND CQ.ChqIssue.getCqChequeAccId() AND CHEQUE.SEQ.ID        ;* EN_10003189 - E

        CASE CHEQUE.TYPE.ID AND NUM(CQ.ChqIssue.getCqChequeAccId()) AND CHEQUE.SEQ.ID = ''   ;*Don't read for internal accounts
* CI_10032559 - Validation has been removed.
            R.REG = ''
            ERR = ''
            REC.ID = CHEQUE.TYPE.ID:'.':CQ.ChqIssue.getCqChequeAccId()
            IF EB.SystemTables.getVFunction() EQ "S" THEN   ;* When the function is S, dont lock the record
                R.REG = CQ.ChqSubmit.ChequeRegister.Read(REC.ID, ERR)
            END ELSE
                CQ.ChqSubmit.ChequeRegisterLock(REC.ID,R.REG,ERR,RETRY,'')   ;* BG_100006461 S/E
            END

            IF NOT(ERR) THEN

                GOSUB GET.SEQUENCE.NO

            END ELSE
                HIS.ERR = ""
                R.REG = ""
                F.CHEQUE.REGISTER.HIS = ''
                EB.DataAccess.Opf("F.CHEQUE.REGISTER$HIS",F.CHEQUE.REGISTER.HIS)

                CHEQUE.ID = CHEQUE.TYPE.ID:'.':CQ.ChqIssue.getCqChequeAccId()
                EB.DataAccess.ReadHistoryRec(F.CHEQUE.REGISTER.HIS, CHEQUE.ID , R.REG ,HIS.ERR)

                GOSUB GET.SEQUENCE.NO
            END

        CASE CQ.ChqIssue.getCqChequeAccId() AND CHEQUE.SEQ.ID = '' AND CHEQUE.TYPE.ID = ''
            EB.SystemTables.setE("ST.CHI.MISS.CHQ.TYPE")

        CASE CHEQUE.TYPE.ID AND CQ.ChqIssue.getCqChequeAccId() = '' AND CHEQUE.SEQ.ID = ''
            EB.SystemTables.setE("ST.CHI.CHQ.AC.NO.MISS")

        CASE 1
            EB.SystemTables.setE("ST.CHI.INVALID.ID.CONSTRUCTION")
    END CASE


* EN_10000101 -s modification of ER to E
    IF EB.SystemTables.getE() THEN
        GOTO CHECK.ID.END
    END
* If comapny of a/c to be issued is different from current company load the corresponding a/c company through version
    IF CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.CoCode> NE EB.SystemTables.getIdCompany() AND CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.CoCode> THEN
        IF EB.SystemTables.getRVersion(EB.Versions.Version.VerAutoCompChange) EQ "YES" THEN
            NEW.COMPANY = CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.CoCode>
            ST.CompanyCreation.LoadCompany(NEW.COMPANY)
            EB.Display.RebuildScreen()
        END
    END   ;* CI_10052495  E

    CQ.ChqIssue.setCqChequeType('')
    TYPE.ER = ''
    R.REC = ''
    R.REC = CQ.ChqConfig.ChequeType.Read(CHEQUE.TYPE.ID, TYPE.ER)
    CQ.ChqIssue.setCqChequeType(R.REC)
    IF TYPE.ER#'' THEN
        EB.SystemTables.setE('ST.CHI.MISS.REC.CHEQUE.TYPE':@FM:'CHEQUE.TYPE')
        IF EB.SystemTables.getVFunction()='I' OR EB.SystemTables.getVFunction()='C' THEN
            GOTO CHECK.ID.END
        END ELSE
            ER = EB.SystemTables.getE()
            EB.Display.Txt(ER) ; EB.SystemTables.setE(ER); EB.SystemTables.setIdEnri(EB.SystemTables.getE()); RETURN
        END
    END
* EN_10000101 -e modifications

* EN_10000101 -s modification of ER to E
    CQ.ChqIssue.setCqChequeCharge('')
    CHARGE.ER = ''
    R.REC = ''
    R.REC = CQ.ChqFees.ChequeCharge.Read(CHEQUE.TYPE.ID, CHARGE.ER)
    CQ.ChqIssue.setCqChequeCharge(R.REC)
    IF CHARGE.ER#'' AND EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParChequeRegister> # "YES" THEN          ;* GB9900471
        EB.SystemTables.setE('ST.CHI.MISS.REC.CHEQUE.CHARGE':@FM:'CHEQUE.CHARGE')
        IF EB.SystemTables.getVFunction()='I' OR EB.SystemTables.getVFunction()='C' THEN
            GOTO CHECK.ID.END
        END ELSE
            ER = EB.SystemTables.getE()
            EB.Display.Txt(ER) ; EB.SystemTables.setE(ER); EB.SystemTables.setIdEnri(EB.SystemTables.getE()); RETURN
        END
    END
* EN_10000101 -e modifications

    IF CQ.ChqIssue.getCqChequeAccId() = '' THEN
        EB.SystemTables.setE('ST.CHI.CHQ.AC.MISS')
        GOTO CHECK.ID.END     ;* EN_10000101
    END


*     Store Value of Chq.Is.Restrict into Cq$Chq.Restrict
*     If Chq.Is.Restrict eq 'N' then do not allow to issue cheque
    ACC.ID = CQ.ChqIssue.getCqChequeAccId()
    IF NUM(ACC.ID) THEN       ;* Not needed to read for Internal accounts
        custId = CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.Customer>
        custRec = ''
        CALL CustomerService.getRecord(custId, custRec)
        CQ.ChqIssue.setCqChqRestrict(custRec<ST.Customer.Customer.EbCusIssueCheques>)
        IF (CQ.ChqIssue.getCqChqRestrict() EQ 'NO') AND (EB.SystemTables.getVFunction() MATCH "I":@VM:"C") THEN
            EB.SystemTables.setE("ST.CHI.ISSUE.CHQ.RESTRICT.CU")
            GOTO CHECK.ID.END
        END
    END

    CATG = CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.Category>   ;* changed as dynamic array
* EN_10000101 -e

    IF CQ.ChqIssue.getCqChequeType()<CQ.ChqConfig.ChequeType.ChequeTypeCategory,1> NE 'ALL' AND CQ.ChqIssue.getCqChequeType()<CQ.ChqConfig.ChequeType.ChequeTypeCategory,1> NE '' THEN
        LOCATE CATG IN CQ.ChqIssue.getCqChequeType()<CQ.ChqConfig.ChequeType.ChequeTypeCategory,1> SETTING POS ELSE
            EB.SystemTables.setE('ST.CHI.INVALID.AC.CAT')
            GOTO CHECK.ID.END
        END
    END

    IF CQ.ChqIssue.getCqChequeType()<CQ.ChqConfig.ChequeType.ChequeTypeAssignedCategory,1> NE '' THEN   ;* Should check with Assigned.category not with Category.
        LOCATE CATG IN CQ.ChqIssue.getCqChequeType()<CQ.ChqConfig.ChequeType.ChequeTypeAssignedCategory,1> SETTING POS ELSE
            EB.SystemTables.setE('ST.CHI.INVALID.AC.CAT')
            GOTO CHECK.ID.END ;* EN_10000101
        END
    END


* EN_10000101 -s modification of ER to E & CQ$CI.ACCOUNT to dynamic
    IF CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.Currency> <> EB.SystemTables.getLccy() THEN
        IF CQ.ChqIssue.getCqChequeType()<CQ.ChqConfig.ChequeType.ChequeTypeAllowFcyAcct>[1,1] = "N" THEN
            EB.SystemTables.setE("ST.CHI.AC.CCY.ONLY.LOCAL.TYPE":@FM:CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.Currency>)
            GOTO CHECK.ID.END
        END
    END
* EN_10000101 -e modifications

    CQ.ChqIssue.setCqRegister('')
    REG.ER = ''     ;* EN_10000101
    REC.ID = CHEQUE.TYPE.ID:'.':CQ.ChqIssue.getCqChequeAccId()
    R.REC = ''
    R.REC = CQ.ChqSubmit.ChequeRegister.Read(REC.ID, REG.ER)        ;* EN_10000101 - changed ER to REG.ER
    CQ.ChqIssue.setCqRegister(R.REC)
    IF REG.ER <> '' THEN      ;* EN_10000101 - ER to REG.ER
        HOLDING = 0
        CQ.ChqIssue.setCqIssuedThisPd(0)
        CQ.ChqIssue.setCqIssueStartDate('')
        CQ.ChqIssue.setCqIssueEndDate('');* CI_10000413
        REG.ER = '' ;* EN_10000101 - ER to REG.ER
    END ELSE
        HOLDING = CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegNoHeld>
        CQ.ChqIssue.setCqIssuedThisPd(CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuedThisPd>)
        CQ.ChqIssue.setCqIssueStartDate(CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuePdStart>)
        CQ.ChqIssue.setCqIssueEndDate('');* CI_10000413
    END

    R.UNAUREG = ''
    REC.ID = CHEQUE.TYPE.ID:'.':CQ.ChqIssue.getCqChequeAccId()
    R.UNAUREG = CQ.ChqSubmit.ChequeRegister.ReadNau(REC.ID, ERR)     ;* BG_100006461 S/E
    IF R.UNAUREG THEN
        EB.SystemTables.setE('ST.CHI.UNAUTH.REGISTER.ENTRY.EXISTS')
        GOTO CHECK.ID.END     ;* EN_10000101
    END

* UPDATE.HEADER handles the enrichment in Desktop,Browser & Classic.
* It is not necessary to be handled seperately.
    EB.SystemTables.setIdEnri(CQ.ChqIssue.getCqChequeType()<CQ.ChqConfig.ChequeType.ChequeTypeDescription,EB.SystemTables.getLngg()>);* CI_10043160 -S
    HDR = 40
    HDR<1,2> = 1
    HDR<1,3> = CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.ShortTitle>
    EB.Reports.UpdateHeader(HDR)   ;* CI_10043160 -E
    EB.SystemTables.setIdNew(CHEQUE.TYPE.ID:'.':CQ.ChqIssue.getCqChequeAccId():'.':CHEQUE.SEQ.ID)
**
**
* GLOBUS_CI_10001925 S
    ID.NEW.VAL = EB.SystemTables.getIdNew()
    IF NOT(NUM(FIELD(ID.NEW.VAL,'.',3))) THEN         ;* CI_10025789 S/E
        EB.SystemTables.setE('ST-MAX.AUTO.SEQ.REACHED');* EN_10003189 - S/E
        GOTO CHECK.ID.END
    END
* GLOBUS_CI_10001925 E

* EN_10000101 -s
CHECK.ID.END:
*------------
    IF EB.SystemTables.getE() THEN
        EB.ErrorProcessing.Err()
        V$ERROR = 1
    END
* EN_10000101 -e

RETURN

*************************************************************************

GET.SEQUENCE.NO:

    IF R.REG<CQ.ChqSubmit.ChequeRegister.ChequeRegLastEventSeq> THEN
        CHEQUE.SEQ.ID = FMT(R.REG<CQ.ChqSubmit.ChequeRegister.ChequeRegLastEventSeq>+1,'7"0"R')     ;* EN_10003189 - S/E
    END ELSE
        CHEQUE.SEQ.ID = '0000001'   ;* EN_10003189 - S/E
    END

RETURN

*************************************************************************

CHECK.RECORD:
* Validation and changes of the Record.  Set ERROR to 1 if in error.

* CI_10032752 S
* Cheques should be issued only in ACCOUNT's company.
    IF (CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.CoCode> NE EB.SystemTables.getIdCompany() ) AND NOT( EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCoCode)) THEN
        IF EB.SystemTables.getRVersion(EB.Versions.Version.VerAutoCompChange) NE "YES" THEN ;* CI_10052495 S/E
            EB.SystemTables.setE("AC.AC.INVALID.ID.COMP")
            GOTO CHECK.RECORD.END
        END
    END
* CI_10032752 E


* EN_10000101 modifications of ER to E & change of CQ$CI.ACCOUNT as dynamic array
    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCurrency, CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.Currency>)
* EN_10000101 -s modifications
    CQ.ChqIssue.setCqAcctCurr(CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.Currency>)
    CQ.ChqIssue.setCqAcctCust(CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.Customer>)


*  If Waive.Charges is NULL, set it to NO
    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsWaiveCharges) = '' THEN
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsWaiveCharges, 'NO')
    END

*  Store Currency.Market and Rate.Type for conversion type if account currency is not LCCY
    CQ.ChqIssue.setCqCcyMkt(CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgCurrencyMarket>)
    RATE.TYPE = CQ.ChqIssue.getCqChequeCharge()<CQ.ChqFees.ChequeCharge.ChequeChgRateType>

    IF CQ.ChqIssue.getCqCcyMkt() EQ '' THEN CQ.ChqIssue.setCqCcyMkt(1)

    IF CQ.ChqIssue.getCqAcctCurr() NE EB.SystemTables.getLccy() THEN

        JFCY = CQ.ChqIssue.getCqAcctCurr() : CQ.ChqIssue.getCqCcyMkt()
        BEGIN CASE
            CASE RATE.TYPE = 'BUY'
                JRATE.TYPE = 'BUY.RATE'
            CASE RATE.TYPE = 'SELL'
                JRATE.TYPE = 'SELL.RATE'
            CASE 1
                JRATE.TYPE = 'MID.REVAL.RATE'
        END CASE
        EB.SystemTables.setEtext('')
        ST.CurrencyConfig.UpdRat(JFCY, JRATE.TYPE)
 
        IF EB.SystemTables.getEtext() THEN
            EB.SystemTables.setText(EB.SystemTables.getEtext()); GOTO FATAL.ERROR
        END
  
        tmp=CQ.ChqIssue.getCqExchRate(); tmp<1>=JRATE.TYPE; CQ.ChqIssue.setCqExchRate(tmp)
        tmp=CQ.ChqIssue.getCqExchRate(); tmp<4>='Y'; CQ.ChqIssue.setCqExchRate(tmp)

    END
*EN_10000101 -e

* GB9900471 (Starts)
    IF EB.SystemTables.getVFunction() = "R" THEN
* GB9900508 (Starts)

*EN_10000101 -s
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsActivity, '')
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsDeliveryRef, '')

        CQ.ChqIssue.setCqRangeField(''); START.NO = '' ; END.NO = ''

        IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart) THEN
*EN_10000101 -e
            CQ.ChqIssue.setCqRangeField(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart):"-":EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)+EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued)-1)
        END         ;*EN_10000101

        CHQ.PRE.IDS = ''
        ID.NEW.VAL = EB.SystemTables.getIdNew()
        CHQ.TYP = FIELD(ID.NEW.VAL,'.',1)
        CHQ.PRE = FIELD(ID.NEW.VAL,'.',1,2)
*CI_10025505/S
        NOS.ISSUE = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued)
        CHQ.START = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)
        ID.NEW.VAL = EB.SystemTables.getIdNew()
        CHQ.PRE.AC = FIELD(ID.NEW.VAL,'.',2)
        CHQ.END = CHQ.START + NOS.ISSUE - 1
        LOOP
        WHILE CHQ.START <= CHQ.END
            CHEQ.REG.SUPP.ID = CHQ.TYP:'.':CHQ.PRE.AC:'.':CHQ.START
            R.CHEQ.REG.SUPP = CQ.ChqSubmit.ChequeRegisterSupplement.Read(CHEQ.REG.SUPP.ID, READ.ER)

            IF R.CHEQ.REG.SUPP<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsStatus> EQ 'PRESENTED' THEN
                EB.SystemTables.setE("ST.CHI.SOME.CHEQUES.ALRDY.PRESENTED.CANT.REVERSE")
                GOTO CHECK.RECORD.END
                EXIT
            END
            CHQ.START+=1
        REPEAT
**CI_10025505/E

        CHQ.STP.IDS = ''
        NO.OF.IDS = ''
        ERR80 = ''
        ID.NEW.VAL = EB.SystemTables.getIdNew()
        ACC.NO = FIELD(ID.NEW.VAL,'.',2)
*CI_10025505/S
        CHQ.START = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)
        CHQ.END = CHQ.START + NOS.ISSUE - 1
        LOOP

        WHILE CHQ.START <= CHQ.END
            CHEQ.REG.SUPP.ID = CHQ.TYP:'.':ACC.NO:'.':CHQ.START
            R.CHEQ.REG.SUPP = CQ.ChqSubmit.ChequeRegisterSupplement.Read(CHEQ.REG.SUPP.ID, READ.ER)

            IF R.CHEQ.REG.SUPP<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsStatus> EQ 'STOPPED' THEN
                EB.SystemTables.setE("ST.CHI.SOME.CHEQUES.ALRDY.STOPPED.CANT.REVERSE")
                GOTO CHECK.RECORD.END
                EXIT
            END
            CHQ.START+=1

        REPEAT
*CI_10025505/E

        NO.OF.RETS = DCOUNT(CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegReturnedChqs>,@VM)
        FOR CNT = 1 TO NO.OF.RETS
            IF CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegReturnedChqs,CNT> >= EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart) AND CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegReturnedChqs,CNT> <= EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)+EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued) THEN
* GB9900508 (Ends)
                EB.SystemTables.setE("ST.CHI.SOME.CHEQUES.ALRDY.RETURNED.CANT.REVERSE")
                GOTO CHECK.RECORD.END   ;* EN_10000101
            END
        NEXT CNT    ;* GB9900508
    END
* GB9900471 (Ends)

* EN_10000101 -s
    IF EB.SystemTables.getVFunction() = "C" THEN
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsActivity, '')
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsDeliveryRef, '')
    END


CHECK.RECORD.END:
*----------------
    IF EB.SystemTables.getE() THEN
        EB.ErrorProcessing.Err()
        V$ERROR = 1
    END

* EN_10000101 -e

RETURN

*************************************************************************

CHECK.FIELDS:
*------------

    CQ.ChqIssue.ChequeIssueCheckFields()

    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setTSequ("IFLD")
        EB.ErrorProcessing.Err()
    END

RETURN
*-----------(Check.Fields)

*************************************************************************

CROSS.VALIDATION:
*----------------

    V$ERROR = ''
    EB.SystemTables.setEtext('')
    EB.SystemTables.setText('')
*
    CQ.ChqIssue.ChequeIssueCrossval()
*
* If END.ERROR has been set then a cross validation error has occurred
*
    IF EB.SystemTables.getEndError() THEN
        EB.SystemTables.setA(1)
        LOOP UNTIL EB.SystemTables.getTEtext()<EB.SystemTables.getA()> <> "" DO EB.SystemTables.setA(EB.SystemTables.getA()+1); REPEAT
        EB.SystemTables.setTSequ(EB.SystemTables.getA())
        V$ERROR = 1
        EB.SystemTables.setMessage('ERROR')
        EB.SystemTables.setP(0)
    END

RETURN          ;* Back to field input via UNAUTH.RECORD.WRITE
*-----------(Cross.Validation)

*************************************************************************

OVERRIDES:
*---------
*  Overrides should reside here.
*
    V$ERROR = ''
    EB.SystemTables.setEtext('')
    EB.SystemTables.setText('')
    CQ.ChqIssue.ChequeIssueOverride()          ;* EN_10000101
*
*
    IF EB.SystemTables.getText() = "NO" THEN       ;* Said NO to override
        V$ERROR = 1
        EB.SystemTables.setMessage("ERROR");* Back to field input

    END

RETURN
*-----------(Overrides)

*************************************************************************

AUTH.CROSS.VALIDATION:


RETURN

*************************************************************************

CHECK.DELETE:

*
** GB9700339
*
*  Financial entries are taken care in Cheque.Issue.Accounting                    ;*EN_10000101
*     IF R.NEW(CHEQUE.IS.STMT.NO)='VAL' THEN CALL EB.ACCOUNTING('CC','DEL','','') ;*EN_10000101

RETURN

*************************************************************************

CHECK.REVERSAL:

*
** GB9700339
*
*  EN_10000101 -s
*  Charges collected are not reversed. Charges are collected at various status.
*  Charge collected details are available in Cheque.Charge.Bal

*  If reversal of cheque.issue record, accounting entries will not be reversed
    IF EB.SystemTables.getVFunction() EQ 'R' THEN
* CI_10000413 -s
*  No reversal of records for cheque status other than 90
        IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) NE 90 THEN
            EB.SystemTables.setE('ST.CHI.REC.WITH.STATUS.90.CANT.REVERSED')
            EB.ErrorProcessing.Err()
            V$ERROR = 1
            EB.SystemTables.setMessage("ERROR")
        END ELSE
* CI_10000413 -e
            EB.SystemTables.setText('Financial entries will not be reversed')
            EB.Display.Rem()
        END         ;* CI_10000413
    END
*EN_10000101 -e

RETURN

*************************************************************************
DELIVERY.PREVIEW:

* EN_10000101 -s
    EB.SystemTables.setTEtext('')
    CQ.ChqIssue.ChequeIssueDeliveryPreview()

    IF EB.SystemTables.getE() THEN
        EB.ErrorProcessing.Err()
        V$ERROR = 1
    END

    EB.Display.RebuildScreen()
    EB.SystemTables.setMessage("ERROR")
* EN_10000101 -e

RETURN

*************************************************************************

BEFORE.UNAU.WRITE:
*
*  Contract processing code should reside here.
*
REM > CALL XX.      ;* Accounting, Schedule processing etc etc


** GLOBUS_EN_10000353 -S
** To update the STOCK.REGISTER and CHEQUE.TYPE.ACCOUNT file.


** GLOBUS_BG_100000738 -S

* CI_10030290 S
* Allow for amending NOTES/ Local ref field etc when STATUS is still 90.
* Hence call to update stock register is required only when there is a change.
* Stock should be updated in following cases only.
* 1. New cheque issue
* 2. Stock register changes
* 3. Reversal/ reversal delete.

    IF (EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsStockReg) = '' ) OR ( EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsStockReg)<> EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStockReg)) OR ((EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsStockReg) = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStockReg)) AND ( EB.SystemTables.getVFunction() ='R' OR (EB.SystemTables.getVFunction() ='D' AND EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsRecordStatus)[1,3] = 'RNA'))) THEN


        IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStockReg) NE "" THEN
            REC.ID = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStockReg)
            STO.REC = CQ.ChqStockControl.StockRegister.Read(REC.ID, ERR1)
            ID.NEW.VAL = EB.SystemTables.getIdNew()
            CHEQUE.TYPE.ID = FIELD(ID.NEW.VAL,'.',1)
            CHQ.TYPE.REC = CQ.ChqConfig.ChequeType.Read(CHEQUE.TYPE.ID, CHQ.ERR)
            IF (CHQ.TYPE.REC<CQ.ChqConfig.ChequeType.ChequeTypeInternal> NE 'YES') THEN ;* As by default null is also considerd as customer cheque, check if Internal is NE YES
                CQ.ChqStockControl.UpdateStockRegister(STO.REC,REC.ID,"")
            END

            IF EB.SystemTables.getEtext() THEN
                EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)
                EB.ErrorProcessing.StoreEndError()
                V$ERROR = 1   ;* CI_10035187 - S
                EB.SystemTables.setMessage("ERROR")
                RETURN        ;* CI_10035187 - E
            END
** GLOBUS_BG_100000832 -E
        END         ;* CI_10030290 S/E
    END

** GLOBUS_BG_100000738 -E

** GLOBUS_EN_10000353 - E


* EN_10000101 -s
** Validation added to amend NOTES.
*
    IF EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)<> '' AND (EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) GE EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)) THEN
        NULL
    END ELSE
        CQ.ChqIssue.ChequeIssueAccounting()
    END

*
* Additional updates should be performed here
*
*     Update Cheque.Charge.Bal.Hold with the charges collected
    CQ.ChqIssue.setCqFunction('VAL')
    REC.ID = EB.SystemTables.getIdNew()
    R.REC = EB.SystemTables.getDynArrayFromRNew()
    MATPARSE R.NEW.REC FROM R.REC
    CQ$ACCT.CURR.VAL = CQ.ChqIssue.getCqAcctCurr()
    CQ.ChqFees.ChequeChargeBalUpdate(REC.ID, MAT R.NEW.REC, CQ$CHARGE.ACCT, CQ$ACCT.CURR.VAL)
    MATBUILD R.REC FROM R.NEW.REC
    EB.SystemTables.setDynArrayToRNew(R.REC)
    CQ.ChqIssue.setCqAcctCurr(CQ$ACCT.CURR.VAL)
    IF EB.SystemTables.getText() = "NO" THEN       ;* Said No to override
        EB.TransactionControl.TransactionAbort()          ;* Cancel current transaction
        V$ERROR = 1
        EB.SystemTables.setMessage("ERROR");* Back to field input
        RETURN
    END
* EN_10000101 -e

RETURN

*************************************************************************

AFTER.UNAU.WRITE:


RETURN


*-----------------------------------------------------------------------------------------
AFTER.AUTH.WRITE:

RETURN

*-----------------------------------------------------------------------------------------
BEFORE.AUTH.WRITE:
*-----------------
*EN_10000101-s
*     Update Cheque.Charge.Bal and delete from Cheque.Charge.Bal.Hold
    CQ.ChqIssue.setCqFunction('AUT')
    REC.ID = EB.SystemTables.getIdNew()
    R.REC = EB.SystemTables.getDynArrayFromRNew()
    MATPARSE R.NEW.REC FROM R.REC
    CQ$ACCT.CURR.VAL = CQ.ChqIssue.getCqAcctCurr()
    CQ.ChqFees.ChequeChargeBalUpdate(REC.ID, MAT R.NEW.REC, CQ$CHARGE.ACCT, CQ$ACCT.CURR.VAL)
    MATBUILD R.REC FROM R.NEW.REC
    EB.SystemTables.setDynArrayToRNew(R.REC)
    CQ.ChqIssue.setCqAcctCurr(CQ$ACCT.CURR.VAL)
*EN_10000101-e


    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsStmtNo)='VAL' THEN
        AC.API.EbAccounting('CC','AUT','','')
    END

* CI_10030290 S
    IF EB.SystemTables.getVFunction() = 'R' OR  (EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsRecordStatus)[1,3] = 'RNA')  THEN
        REV.FLAG = 1
    END ELSE
        REV.FLAG =0
    END
* CI_10030290 E
    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsRecordStatus)[1,3] = 'RNA' THEN     ;* GB9900471
        IF EB.SystemTables.getVFunction() = "D" THEN
            GOSUB UPDATE.CHQ.ISSUE.ACCOUNT                                                                  ;* Task 2718557 : CHEQUE.ISSUE.ACCOUNT created for cheques with all status.
            GOSUB REGISTER.ADD
        END ELSE
            GOSUB REGISTER.SUB
        END
    END ELSE
        IF EB.SystemTables.getVFunction() # 'R' THEN        ;* GB9900471
            IF EB.SystemTables.getVFunction() = "D" THEN
                GOSUB REGISTER.SUB
            END ELSE
                IF EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ '' THEN        ;* Task 2718557 : CHEQUE.ISSUE.ACCOUNT created for cheques with all status.
                    GOSUB UPDATE.CHQ.ISSUE.ACCOUNT
                END
                IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ 90 THEN          ;* System not updating if chq issue is done in stages of 60,70 and then 90 as id.old will be present in this scenario. CI_10023387 - S/E
                    GOSUB REGISTER.ADD
                END ;**CI_10017384 S/E
            END
        END
    END   ;* GB9900471

    CQ.ChqSubmit.UpdateChequeTypeAccount()     ;*CI_10036574S/E

* EN_10000101 -s
    IF EB.SystemTables.getVFunction() NE "R" THEN ;* BG_100000159
        IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsRecordStatus)[1,3] NE 'RNA' THEN          ;* BG_100000159
            BAL.CHG.CODE = ''
            BAL.CHG.AMT = ''
            BAL.TAX.AMT = ''
            CHG.DATE = ''

            CQ.ChqIssue.ChequeIssueDelivChgDets(CHARGE.ARRAY,BAL.CHG.CODE,BAL.CHG.AMT,BAL.TAX.AMT,CHG.DATE)
            IF CHARGE.ARRAY THEN
                CQ.ChqIssue.ChequeIssueDelivery(CHARGE.ARRAY)
            END ELSE
                EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsActivity, '')
                EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsDeliveryRef, '')
            END
        END
    END   ;* BG_100000159

*   Read customer Record
    custId = CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.Customer>
    custRec = ''
    CALL CustomerService.getRecord(custId, custRec)
    CUSTOMER.REC = custRec
*   Update Customer application if the cheque is issued for the 1st time to his account
    IF CQ.ChqIssue.getCqChqRestrict() EQ '' THEN
        IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) EQ 90 THEN
            CUSTOMER.REC<ST.Customer.Customer.EbCusIssueCheques> = 'YES'
            REC.ID = CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.Customer>
            ST.Customer.CustomerWrite(REC.ID, CUSTOMER.REC,'')
        END
    END

    GOSUB GENERATE.ALERT.MESSAGE

*    Reinitialise charges
    GOSUB REINIT.CHARGES

* EN_10000101 -e
    V.VAL = EB.SystemTables.getV()
    BEGIN CASE
        CASE EB.SystemTables.getRNew(V.VAL-8)[1,3] = "INA"        ;* Record status
REM > CALL XX.AUTHORISATION
        CASE EB.SystemTables.getRNew(V.VAL-8)[1,3] = "RNA"        ;* Record status
REM > CALL XX.REVERSAL

    END CASE

RETURN
*-----------(Before.Auth.Write)

*************************************************************************
* Task 2718557 : CHEQUE.ISSUE.ACCOUNT created for cheques with all status.
UPDATE.CHQ.ISSUE.ACCOUNT:

    R.CHQ.ISS.ACC = ''
    ER = '' ; RETRY = ''
    REC.ID = CQ.ChqIssue.getCqChequeAccId()
    R.CHQ.ISS.ACC = CQ.ChqIssue.ChequeIssueAccount.ReadU(REC.ID, ER, RETRY)
    ID.NEW.VAL = EB.SystemTables.getIdNew()
    R.CHQ.ISS.ACC = INSERT(R.CHQ.ISS.ACC,1,0,0,ID.NEW.VAL)
    CQ.ChqIssue.ChequeIssueAccount.Write(REC.ID, R.CHQ.ISS.ACC)

*************************************************************************

CHECK.FUNCTION:

* Validation of function entered.  Set FUNCTION to null if in error.

    V$FUNCTION.VAL = EB.SystemTables.getVFunction()
    inputBlock = @FALSE
    IF INDEX('I',V$FUNCTION.VAL,1) AND NOT(acInstalled) THEN
        inputBlock = @TRUE
    END
    IF INDEX('V',V$FUNCTION.VAL,1) OR INDEX('H',V$FUNCTION.VAL,1) OR inputBlock THEN        ;* EN_10000101
        EB.SystemTables.setE('ST.CHI.FUNT.NOT.ALLOW.APP')
        EB.ErrorProcessing.Err()
        EB.SystemTables.setVFunction('')
    END

RETURN

*************************************************************************

INITIALISE:
*----------
    DIM R.NEW.REC(EB.SystemTables.SysDim)
    SAVE.COMPANY = EB.SystemTables.getIdCompany()
    MAT R.NEW.REC = ''

    CHEQUE.TYPE.ID='' ; CQ.ChqIssue.setCqChequeAccId('');* used in id validation
    CHEQUE.SEQ.ID=''
    ACCOUNT=''      ;* used in name validation
    ER=''
    CQ.ChqIssue.setCqLcyAmt("");* GB9800263

*EN_1000426
    METRICS.VALUE = ""        ;*Used for storing the R.OLD values while generating the alert message

*EN_10000101 -s
    CQ.ChqIssue.setCqCiAccount('')
    TEMP.REC = '' ; TEMP.ERR = ''

*     Store Cheque.Status ids and description in an array
    CQ.ChqIssue.setCqStsIdListDesc(''); STS.REC = '' ; STS.ID.DESC = ''

* EN_10003187 S
    THE.LIST = 'ALL.IDS'
    EB.DataAccess.Das("CHEQUE.STATUS",THE.LIST,'','')

    CQ.ChqIssue.setCqStsIdListDesc(THE.LIST)
    CQ$STS.ID.LIST.DESC.VAL = CQ.ChqIssue.getCqStsIdListDesc()
    TTL.STS = DCOUNT(CQ$STS.ID.LIST.DESC.VAL,@FM)
* EN_10003187 E
    FOR CNT = 1 TO TTL.STS
        REC.ID = CQ.ChqIssue.getCqStsIdListDesc()<CNT,1>
        STS.REC = CQ.ChqConfig.ChequeStatus.Read(REC.ID, STS.READ.ERR)
        STS.ID.DESC<CNT> = STS.REC<CQ.ChqConfig.ChequeStatus.ChequeStsDescription>
    NEXT CNT

    ISSUE.DATE = ''
    CHQ.STS.DESC = ''         ;* (Cheque.Status Description)
    CQ.ChqIssue.setCqAcctCurr('');* (Account Currency)
    CQ.ChqIssue.setCqAcctCust('');* (Account Customer)
    CQ$CHARGE.ACCT = ''       ;* (Charge Customer)
    CQ.ChqIssue.setCqChqRestrict('');* (Customer.Issue.Cheque)
    CQ.ChqIssue.setCqCcyMkt('');* (Currency.Market for conversion - from Cheque.Charge)
    RATE.TYPE = ''  ;* (Type of exchange Mid/Buy/Sell - from Cheque.Charge)
    CQ.ChqIssue.setCqExchRate('');* (Exchange rate )
    CQ.ChqIssue.setCqCharges('')
    CQ.ChqIssue.setCqChargeDate('')
    CQ.ChqIssue.setCqCustCond('')
    CQ.ChqIssue.setCqCheckingException('')
    CURR.NO = ''
    CHQ.ISS.REC = ''          ;* EN_10003189 - S
    CHQ.ISS.ERR = ''          ;* EN_10003189 - E
*EN_10000101 -e

    BROWSER.PREVIEW.ON = (EB.Interface.getOfsMessage()='PREVIEW')  ;*EN_10002679 - S/E
* CI_10030290 S
    CQ.ChqIssue.setCqChargeCodeArray('')
    CQ.ChqIssue.setCqChargeAmountArray('')
* CI_10030290 E

    AA.INSTALLED = ''
    ARRANGEMENT.ID = '' ;*holds the arrangement id of the cheque account
* Application instalation must be checked in the COMPANY record.
    LOCATE 'AA' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING AA.INSTALLED ELSE
        AA.INSTALLED = 0
    END

RETURN

*************************************************************************

DEFINE.PARAMETERS:  * SEE 'I_RULES' FOR DESCRIPTIONS *

    CQ.ChqIssue.ChequeIssueFieldDefinitions()

RETURN

*************************************************************************

REGISTER.ADD:
*------------

* CI_10000413 -s

    IF (EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)<> 90) OR ( EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) = 90 AND NOT(REV.FLAG))  THEN
        RETURN      ;* CI_10030290 S/E
    END


* call statement required to get the values of CQ$ISSUE.START.DATE,
* CQ$ISSUE.END.DATE & CQ$ISSUE.ROLLOVER
    CQ.ChqIssue.ChequeIssueChargesVal()
* CI_10000413 -e

    TEMP.NO.ISSUED = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued)
    ER = '' ; RETRY = ''
    CQ.ChqIssue.setCqRegister('')
    REC.ID = CHEQUE.TYPE.ID:'.':CQ.ChqIssue.getCqChequeAccId()
    R.REC = ''
    CQ.ChqSubmit.ChequeRegisterLock(REC.ID, R.REC,ER, RETRY,'')
    CQ.ChqIssue.setCqRegister(R.REC)
    IF CHEQUE.SEQ.ID = 1 THEN
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuePdStart>=CQ.ChqIssue.getCqIssueStartDate(); CQ.ChqIssue.setCqRegister(tmp)
    END
    IF CQ.ChqIssue.getCqIssueRollover() THEN
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuePdStart>=CQ.ChqIssue.getCqIssueEndDate(); CQ.ChqIssue.setCqRegister(tmp);* CI_10000413
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuedLastPd>=CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuedThisPd>; CQ.ChqIssue.setCqRegister(tmp)
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuedThisPd>=0; CQ.ChqIssue.setCqRegister(tmp)
    END
    tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuedToDate>=CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuedToDate> + TEMP.NO.ISSUED; CQ.ChqIssue.setCqRegister(tmp)
    tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuedThisPd>=CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuedThisPd> + TEMP.NO.ISSUED; CQ.ChqIssue.setCqRegister(tmp)
    tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegNoHeld>=CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegNoHeld> + TEMP.NO.ISSUED; CQ.ChqIssue.setCqRegister(tmp)
    TEMPLOC = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)+TEMP.NO.ISSUED-1
    IF LEN(TEMPLOC) < LEN(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)) THEN
        TEMPLOC = FMT(TEMPLOC,LEN(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)):'"0"R')
    END
* GB9900471 (Starts)
    CQ.ChqIssue.setCqRangeField(CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegChequeNos>)
    START.NO = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)
    END.NO = TEMPLOC
    RESULT = ''
    RESULT<2> = 1
    RANGE.FIELD = CQ.ChqIssue.getCqRangeField()
    EB.API.MaintainRanges(RANGE.FIELD,START.NO,END.NO,"INS",RESULT,CHQ.ERROR)
    CQ.ChqIssue.setCqRangeField(RANGE.FIELD)
    tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegChequeNos>=CQ.ChqIssue.getCqRangeField(); CQ.ChqIssue.setCqRegister(tmp)
* GB9900471 (Ends)

** GLOBUS_EN_10000353 -S
    ID.NEW.VAL = EB.SystemTables.getIdNew()
    CHQ.TYP.ID = FIELD(ID.NEW.VAL,".",1)
    CHQ.TYP.REC = CQ.ChqConfig.ChequeType.Read(CHQ.TYP.ID, CHQ.TYP.ERR)

    MIN.HOLD = CHQ.TYP.REC<CQ.ChqConfig.ChequeType.ChequeTypeMinHolding>
    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsAutoChequeNumber) NE "" THEN
        CHEQ.NUMBER = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsAutoChequeNumber)
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegAutoChequeNo,1>=CHEQ.NUMBER; CQ.ChqIssue.setCqRegister(tmp)
        FOR I = 1 TO MIN.HOLD - 1
            tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegAutoChequeNo,I+1>=CHEQ.NUMBER + I; CQ.ChqIssue.setCqRegister(tmp);* GLOBUS_BG_100000887
        NEXT I
    END

** GLOBUS_EN_10000353 -E


*--- 14/10/99 GB9901421 Add audit info. on creation
    tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegCurrNo>=CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegCurrNo> + 1; CQ.ChqIssue.setCqRegister(tmp)
    tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegInputter>=EB.SystemTables.getTno():"_":EB.SystemTables.getOperator(); CQ.ChqIssue.setCqRegister(tmp)
    tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegAuthoriser>=EB.SystemTables.getTno():"_":EB.SystemTables.getOperator(); CQ.ChqIssue.setCqRegister(tmp)
    tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegCoCode>=EB.SystemTables.getIdCompany(); CQ.ChqIssue.setCqRegister(tmp)
    tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegDeptCode>=EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>; CQ.ChqIssue.setCqRegister(tmp)
    EB.SystemTables.setTimeStamp(TIMEDATE())
    X = OCONV(DATE(),"D-")
    X = X[9,2]:X[1,2]:X[4,2]:EB.SystemTables.getTimeStamp()[1,2]:EB.SystemTables.getTimeStamp()[4,2]
    tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegDateTime>=X; CQ.ChqIssue.setCqRegister(tmp)
*--- GB9901421 ends

    IF CHEQUE.SEQ.ID GE CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegLastEventSeq> OR CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegLastEventSeq> = '9999999' OR LEN(CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegLastEventSeq>) GT 7 THEN       ;* EN_10003189 - S/E // CI_10039402 S/E
* Retain the highest EVENT.SEQUENCE number entered for an account.
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegLastEventSeq>=CHEQUE.SEQ.ID; CQ.ChqIssue.setCqRegister(tmp)
    END   ;* CI_10039402 S/E
    R.REC = CQ.ChqIssue.getCqRegister()
    REC.ID = CHEQUE.TYPE.ID:'.':CQ.ChqIssue.getCqChequeAccId()
    CQ.ChqSubmit.ChequeRegisterWrite(REC.ID, R.REC,'')

RETURN
*
*************************************************************************
*
REGISTER.SUB:
*------------
    IF (EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)<> 90) OR ( EB.SystemTables.getROld(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus) = 90 AND NOT(REV.FLAG))  THEN
        RETURN      ;* CI_10030290 S/E
    END

    TEMP.NO.ISSUED = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued)
    ER = '' ; RETRY = ''
    CQ.ChqIssue.setCqRegister('')
    REC.ID = CHEQUE.TYPE.ID:'.':CQ.ChqIssue.getCqChequeAccId()
    R.REC = CQ.ChqIssue.getCqRegister()
    CQ.ChqSubmit.ChequeRegisterLock(REC.ID,R.REC, ER, RETRY,'')
    CQ.ChqIssue.setCqRegister(R.REC)                                                ;* Set CHEQUE.REGISTER record
    IF ER = '' THEN
* GB9900548 (Starts)
        CHQ.REG.HIS.ID = CHEQUE.TYPE.ID:'.':CQ.ChqIssue.getCqChequeAccId():";":CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegCurrNo>
        R.REC = CQ.ChqIssue.getCqRegister()
        CQ.ChqSubmit.ChequeRegisterWrite(CHQ.REG.HIS.ID, R.REC,'HIS')
* GB9900548 (Ends)
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuedToDate>=CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuedToDate> - TEMP.NO.ISSUED; CQ.ChqIssue.setCqRegister(tmp)
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuedThisPd>=CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuedThisPd> - TEMP.NO.ISSUED; CQ.ChqIssue.setCqRegister(tmp)
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegNoHeld>=CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegNoHeld> - TEMP.NO.ISSUED; CQ.ChqIssue.setCqRegister(tmp)
        IF CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegNoHeld> < 0 THEN
            tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegNoHeld>=0; CQ.ChqIssue.setCqRegister(tmp)
        END

* GB9900471 (Starts)
        CQ.ChqIssue.setCqRangeField(CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegChequeNos>)
        START.NO = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)
        END.NO = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChqNoStart)+EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued)-1
        RANGE.FIELD = CQ.ChqIssue.getCqRangeField()
        EB.API.MaintainRanges(RANGE.FIELD,START.NO,END.NO,"DEL",RESULT,CHQ.ERROR)
        CQ.ChqIssue.setCqRangeField(RANGE.FIELD)
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegChequeNos>=CQ.ChqIssue.getCqRangeField(); CQ.ChqIssue.setCqRegister(tmp)
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegCurrNo>=CQ.ChqIssue.getCqRegister()<CQ.ChqSubmit.ChequeRegister.ChequeRegCurrNo> + 1; CQ.ChqIssue.setCqRegister(tmp)
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegInputter>=EB.SystemTables.getTno():"_":EB.SystemTables.getOperator(); CQ.ChqIssue.setCqRegister(tmp)
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegAuthoriser>=EB.SystemTables.getTno():"_":EB.SystemTables.getOperator(); CQ.ChqIssue.setCqRegister(tmp)
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegCoCode>=EB.SystemTables.getIdCompany(); CQ.ChqIssue.setCqRegister(tmp)
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegDeptCode>=EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>; CQ.ChqIssue.setCqRegister(tmp)
        EB.SystemTables.setTimeStamp(TIMEDATE())
        X = OCONV(DATE(),"D-")
        X = X[9,2]:X[1,2]:X[4,2]:EB.SystemTables.getTimeStamp()[1,2]:EB.SystemTables.getTimeStamp()[4,2]
        tmp=CQ.ChqIssue.getCqRegister(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegDateTime>=X; CQ.ChqIssue.setCqRegister(tmp)
        REC.ID = CHEQUE.TYPE.ID:'.':CQ.ChqIssue.getCqChequeAccId()
        R.REC = CQ.ChqIssue.getCqRegister()
        CQ.ChqSubmit.ChequeRegisterWrite(REC.ID, R.REC,'')
* GB9900471 (Ends)
        R.CHQ.ISS.ACC = ''
        ER = '' ; RETRY = ''
*BG_100006210 S
        REC.ID = CQ.ChqIssue.getCqChequeAccId()
        R.CHQ.ISS.ACC = CQ.ChqIssue.ChequeIssueAccount.Read(REC.ID, ER)
        IF NOT(ER) THEN       ;*BG_100006210 E
            R.CHQ.ISS.ACC = CQ.ChqIssue.ChequeIssueAccount.ReadU(REC.ID, ER, RETRY)
            LOCATE EB.SystemTables.getIdNew() IN R.CHQ.ISS.ACC<1> SETTING POS ELSE
                POS = 0
            END
            IF POS THEN
                DEL R.CHQ.ISS.ACC<POS>
            END
            IF R.CHQ.ISS.ACC EQ '' THEN                                         ;* Task 2718557 : CHEQUE.ISSUE.ACCOUNT is deleted when no data is present.
                CQ.ChqIssue.ChequeIssueAccount.Delete(REC.ID)
            END ELSE
                CQ.ChqIssue.ChequeIssueAccount.Write(REC.ID, R.CHQ.ISS.ACC)
            END
* GB9900471 Release the record
        END
    END
RETURN
*
************************************************************************
GENERATE.ALERT.MESSAGE:
*---------------------

*   EN_10004226
*   generate alert message while authorising the CHEQUE.ISSUE
    DIM LINKED.VALUE(8)

    GOSUB GET.HEADER.DETAILS

    METRICS.VALUE = EB.SystemTables.getDynArrayFromROld()
    AFTER.IMG.REC = EB.SystemTables.getDynArrayFromRNew()

*   Build linked file
    LINKED.VALUE(0) = ''
    LINKED.VALUE(1) = AFTER.IMG.REC
    LINKED.VALUE(2) = METRICS.VALUE
    LINKED.VALUE(3) = CUSTOMER.REC
    LINKED.VALUE(4) = R.ACC
    LINKED.VALUE(5) = CHQ.TYP.REC
    LINKED.VALUE(6) = ''
    LINKED.VALUE(7) = ''
    LINKED.VALUE(8) = COMPANY:@FM:CUS.COMPANY:@FM:DEPARTMENT:@FM:LANGUAGE:@FM:TRANSACTION.REF:@FM:CUSTOMER.ID:@FM:CQ.ChqIssue.getCqChequeAccId():@FM:VALUE.DATE
    REC.ID = CQ.ChqIssue.getCqChequeAccId()
    EB.AlertProcessing.TecRecordEvent('CHEQUE.ISSUE',REC.ID,METRICS.VALUE,AFTER.IMG.REC,MAT LINKED.VALUE,'AUTH','','')

RETURN
*************************************************************************
GET.HEADER.DETAILS:

*   details to populate in DE.O.HEADER
    COMPANY    = CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.CoCode>    ;*Customer company code
    CUS.COMPANY = CUSTOMER.REC<ST.Customer.Customer.EbCusCoCode>          ;*Customer company code
    DEPARTMENT  = CUSTOMER.REC<ST.Customer.Customer.EbCusDeptCode>        ;*Customer department
    LANGUAGE   =  CUSTOMER.REC<ST.Customer.Customer.EbCusLanguage>         ;*Customer language
    TRANSACTION.REF = EB.SystemTables.getIdNew()        ;*Transaction reference number
    CUSTOMER.ID = CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.Customer>  ;*Customer number
    VALUE.DATE = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsIssueDate)  ;*Processing date

RETURN
***************************************************************************
* EN_10000101 -s
*Reinitialise Charges and Charge Code to null
*----------------------------------------------------------------
REINIT.CHARGES:
*--------------
    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode, '')
    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount, '')
    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode, '')
    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt, '')
    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxId, '')
    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmount, '')

    IF EB.SystemTables.getAf() NE CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus THEN
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsCharges, '')
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate, '')
    END

RETURN
*-----------(Reinit.Charges)
*----------------------------------------------------------------

*----------------------------------------------------------------
FATAL.ERROR:
*-----------
    EB.ErrorProcessing.FatalError('CHEQUE.ISSUE')

RETURN
*-----------(Fatal.Error)
*----------------------------------------------------------------

* EN_10000101 -e
*--------------
CHECK.HISTORY:
*-------------
    HIS.ACCNO = CQ.ChqIssue.getCqChequeAccId()
    R.HIS.ACC = ''
    ACC.HIS.ERR = ''
*Read record from history if V$FUNCTION is D or S or P
    V$FUNCTION.VAL = EB.SystemTables.getVFunction()
    IF  INDEX('DSP',V$FUNCTION.VAL,1) THEN
        EB.SystemTables.setVFunction(V$FUNCTION.VAL)
        F.ACCOUNT.HIS=''
        EB.DataAccess.Opf("F.ACCOUNT$HIS",F.ACCOUNT.HIS)
        EB.DataAccess.ReadHistoryRec(F.ACCOUNT.HIS,HIS.ACCNO,R.HIS.ACC,ACC.HIS.ERR)
    END
RETURN
*-------------------------------------------------------------------------------
AA.CHECK:
********
* when arrangement activity is input, even in unauth status account is present in live.
* To prevent issueing cheques to those accounts, corresponding arrangement is read and
* checked if its in UNAUTH status

    R.AA.ARRANGEMENT = AA.Framework.Arrangement.Read(ARR.ID, ERR)
    IF NOT(ERR) THEN
        ARR.STATUS = R.AA.ARRANGEMENT<AA.Framework.ArrangementSim.ArrArrStatus>
    END
    IF ARR.STATUS EQ 'UNAUTH' THEN
        EB.SystemTables.setEtext('FT-AA.IN.UNAUTH')
    END

RETURN
*-------------------------------------------------------------------------------
END
