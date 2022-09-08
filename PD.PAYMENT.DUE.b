* @ValidationCode : MjotMTY1MTYzNzg1NTpDcDEyNTI6MTU4NDA5NDI5MTMwNDpydmFyYWRoYXJhamFuOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDMuMDo3Nzc6NDgz
* @ValidationInfo : Timestamp         : 13 Mar 2020 15:41:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 483/777 (62.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PD.Contract
SUBROUTINE PD.PAYMENT.DUE

*************************************************************************
*                                                                       *
* Routine               :       PD.PAYMENT.DUE  (08 September 1995)     *
*                                                                       *
*************************************************************************
*                                                                       *
* Description     :       This is the main Payment Due contract which   *
*                         is used to hold details of all the overdue    *
*                         payments.                                     *
*                         It is keyed by PD followed by the ID of the   *
*                         underlying contract which has become overdue. *
*                                                                       *
*************************************************************************
*                                                                       *
* Modifications :                                                       *
*                                                                       *
* 28/07/97 - GB9700865                                                  *
*            Add SWAP as a valid application                            *
*            Also bug found during testing. Status of underlying        *
*            contract is not updated correctly when a full repayment is *
*            processed.                                                 *
*                                                                       *
* 15/08/97 - GB9700932                                                  *
*            Do not clear the REPAYMENT.ACCT as this may now be set     *
*            from the MAINTENANCE operation                             *
*                                                                       *
* 18/08/97 - GB9700954                                                  *
*            ING0113 Up to 9999 Interest key types                      *
*                                                                       *
* 08/10/97 - GB9701138                                                  *
*            New field ADVICE.CHGS                                      *
*
* 24/10/97 - GB9701238
*            New field PREVENT.RETRY to stop contracts being taken in
*            to the eod retry processing
*                                                                       *
* 01/12/98 - GB9801501
*            make online change of status work correctly.
*
* 01/12/98 - GB9801503
*            Make change on change for repayments work correctly
*
* 25/02/99 - GB9900255
*            Add LC as a valid application.
*
* 10/03/99 - GB9900421
*            format longer DRAWINGS type key correctly
*
* 28/09/00 - GB0002099
*            change RESERVED.8 to BACK.VALUE
*            Add new field START.DATE to indicate start date of pd i.e
*            booking date, used to update AC type history key
*            increase key length to cope with large account numbers
*
* 06/11/00 - GB0002505
*            Add MD as a valid application.
*
* 30/11/00 - GB0003020
*            PD interest capitalisation
* 20/12/00 - GB0003021
*            Introduced new fields:
*            1. SCHD.ACTIVITY
*            2. SCHD.CHG.CODE
*            3. ADVICE.FREQ
*            4. CONTRACT.GRP
*            Above fields are used to introduce the
*            following functionality:
*            1. Stop sending advice if the amount overdue is less
*            than SMALL.AMOUNT.
*            2. Send overdue advices on a regular basis rather than
*            on a change of status using ADVICE.FREQ and ADVICE.PD.START
*            3. Send chaser advices on a timed basis depending
*            on customer type with charges applied.
*
* 06/09/01 - GLOBUS_EN_10000032
*            Add BL as a valid application.
*
* 10/09/01 - GB0102010 / CI_10000092
*             If original settlement account is not live, then remove
*             that account from PD.ORIG.STLMNT.ACT field
*
* 24/09/01 - EN_10000044
*            Changes for LD.INTEREST.SUSPENSION
*            update the NAB.START.DATE in LMM.ACCOUNT.BALANCES
*            when PD maintained to NAB
*            Populate the worklist when PD fully paid off
*            and the status is CURR.
*
* 12/10/01 - BG_100000139
*            The new field MANUAL.NAB is set to 'YES', the PD is
*            maintained to NAB. If this field is set then the
*            CHANGE.STATUS flag is ignored
*
* 18/12/01 - CI_10000419
*            The id of the contract which has undergone a static change
*            is now written into a live file PD.ENT.TODAY.
*
* 16/01/02 - EN_10000386
*            The Manual Pds should also be taken for retry in eod.
*            This field will be inputtable only for maintenance operation
*
* 06/02/2002 - CI_10000930
*              For local reference ..C is included in 'N' parameter.
*
* 11/02/02 - EN_10000420
*            Update NAB.START.DATE and populate the worklist
*            when PD is fully write off.
*
* 14/02/02 - EN_10000414
*            New field LOAN.SPREAD added to hold the contract spread.
*
* 01/03/02 - CI_10001125
*            Open ADVICE.CHGS only when any OPERATION is entered.
*
* 01/04/02 - CI_10001455
*            Changing SCHD.AMOUNT as noinput field
* 31/07/02 - EN_10000880
*            Input PD via OFS.
*
*28/08/02 - CI_10003384
*           When amending a PD Contract that has been
*           already been WriteOFF(WOF)and has Outstanding
*           amount as ZERO,FATAL ERROR Occurs.
*
*
* 18/09/02 - EN_10001168
*            Conversion of error messages to error codes.
*
* 11/10/02 - CI_10004117
*            PD application fatals out when PD is typed in the globus
*            prompt saying missing file.control for Mg.balances
*
* 03/12/02 - CI_10005180
*            Input to PD is not allowed when underlying LD is in
*            $NAU status.This is done to avoid fatal error in LD.
*
* 24/01/03 - CI_10006437
*            Remove the REPAYMENT.ACCT from the PD record if the
*            account is closed.
* 05/02/03 - CI_10006665
*            The check for the status of the accounts in REPAYMENT.ACCT
*            and ORIG.STLMNT.ACCOUNT moved to a seperate paragraph
*            before calling MATRIX.ALTER
* 07/03/03 - BG_100003741
*           Wrong number of arguments in the call to DBR.
*
* 07/04/03 - EN_10001686
*            Enhancement to cater for LEGAL LOSS RATE in PD
* 09/05/03 - EN_10001735
*            Enhancement for AZ-PD.
* 29/05/03 - CI_10009523
*            Check if LD or MM is installed in the company before
*            doing an OPF to ACCBAL.
* 18/06/03 - BG_100004400
*            Only 'S' FUNCTION is allowed when PD is repaid thru anyn other
*            application
* 26/06/03 - CI_10010241
*            The TEXT field is used to take the decision of commiting
*            a PD record
* 15/07/03 - CI_10010817
*            The TEXT field is used to take the decision of deleting
*            a PD record
*
* 30/10/03 - CI_10014145
*            Maintenance operation allowed after PD moves to 'CUR'
*
* 11/01/04 - EN_10002146
*            PD Provision and Debt movement mini version.
*            Added three new fields ASSET.TYPE, PROVISION,
*            MOVE.TO.HIS. Included new status FWOF which
*            indicates financial write off, similar to wof.
*
* 18/05/04 - EN_10002267
*            PD Provision Enhancement. Added new fields-
*            PROVISION.AMOUNT,PROVISION.METHOD, WOF.REASON
*
*
* 26/06/04 - BG_100006721
*            Increasing the size of PROVISION field.
*
* 09/07/04 - BG_100006901
*            Including Currency specification in Provision.amount field.
*
* 22/09/04 - CI_10023367
*            Field length of CONTRACT.GRP increased to 15 as the length
*            of the field in APPL.GEN.CONDITION has been modified.
*
* 12/10/04 - BG_100007279
*            Replacement of READ statements with CACHE.READ
*
* 20/10/04 - EN_10002326
*            Browser bug fixes
*
* 08/02/05 - CI_10027164
*            If Repayment A/c is changed, the new a/c is not
*            considered during 'REPAYMENT'
*
* 14/02/05 - CI_10027367
*            Make OPERATION as HOT.FIELD. Remove unnecessary code
*            in field definitions.
*
* 24/02/05 - EN_10002437
*            Allow Zero ADJUSTMENTS in PD.
*
* 08/04/05 - CI_10029081
*            Call PM.SETUP.PARAM only when PM is installed.
*
* 22/04/05 - CI_10029502
*            Inputting PD.PAYMENT.DUE is not allowed
*            when PD.CAPTURE record status is INAU.
*
* 23/08/05 - CI_10033768
*            Open up Acct.Officer field during Maintenance operation
*            to allow user to change the same.

* 21/09/05 - CI_10034874
*            If NS is not installed, then automatically updated PD contracts
*            should be deleted .Otherwise such records should remain in
*            unauth stage itself after the unauth processing COB.
*
* 13/10/05 - BG_100009545
*            Make REPAY.DATE and TOT.REPAY.AMT as HOT.FIELD.
*
* 01/12/05 - BG_100009770
*            Check for errors after processing Crossval
*
* 07/02/06 - CI_10038781
*            When PD status change to CUR, REPAYMENT.ACCT field become
*            NOINPUT field.
*
* 08/02/06 - CI_10037737
*            Allow deletion of AZPD record only from the contract which has put
*            this record in INAU status (Eg:- TT, FT or AZ).
*
* 08/02/06 - EN_10002809
*            Creation of a new field EB.ACCRUAL.PARAM
*
* 20/02/06 - EN_10002821
*            Rounding off calculation for PD. New field introduced.
*
* 21/02/05 - CI_10039132
*            While input the PD.PAYMENT.DUE, system gets fatal out
*            if LD product not installed.
*
* 29/03/05 - CI_10040103
*            PD record is allowed to be input when the underlying LD
*            contract is in 'INAU' status.
*
* 27/07/06 - EN_10003022
*            Waving option for Grace period penalty interest and spread
*
* 24/08/06 - EN_10003055
*            New fields introuced for Rollovering
*            PD.BALANCES on repayment of instalment amount.
*
* 03/10/06 - BG_100012612
*            PD record in INAU - Exception record gets updated.
*            Authorise the PD record - Exception record filed moveents not updated.
*
* 23/10/06 - BG_100012612.
*            COde changes for moving fields in PD.ROLLOVER.DETAILS while authorising moved
*            to PD.ONLINE.REPAYMENT.This is doen to cater for repayments made through
*            AZ.ACOUNT,TELLER and FT.
*
* 18/02/07 - EN_10003207
*            Data Access Service - Application changes
*
* 21/11/07 - BG_100015877
*            Call to the routine PD.FIND.BACKWARD.DATE is removed as the routine
*            PD.FIND.BACKWARD.DATE is not available
*
* 30/01/08 - BG_10016882
*            Replacement of CACHE.READ of ACCOUNT with F.READ
*
* 06/05/08 - BG_100018301
*            Reducing compiler rating
*
* 07/05/08 - BG_100018375
*            Common variables for provision is not cleared when asset class is changed in more
*            than one contract in the same session
*
* 22/10/08 - CI_10058483
*            The input of the field PD.PORTFOLIO.NUMBER is allowed only when
*            the 'SECURITIES' module is installed
*
* 19/11/08 - CI_10058962
*            Error thrown for a Adjustment operation in PD is committed
*            after the validation.
* 11/12/08 - CI_10059581
*            System is not allowing the user to commit the PD record while doing
*            the 'WOF' operation where ASSET.CLASS is defined in PD contract.
*
* 30/07/09 - EN_10004213
*            SAR ref: SAR-2008-10-07-0010
*            New functionality for S-basis
*
* 14/08/09 - CI_10065400
*            RECORD.STATUS is not present during AUTH.ROUTINE in version.
*
* 22/10/09 - CI_10066953
*            when we default the REPAYMENT.DATE through the routine attached in the version
*            the system did not populate correctly the REAPY AMOUNT for the corresponding type.
*
* 05/04/10 - 33744/38866
*            C$REPAYMENT.DATA should be cleared during new input
*
* 05/10/10 - Task 94402
*            Defect - 93544
*            Pass the ID.NEW directly to check PD capture is in INAU or Not.
*
* 27/06/11 - Task: 234313
*            Defect: 232863 / CI_10073545
*            If there are any OVERRIDES a call to EXCEPTION.LOG should be made.
*
* 12/04/14 - Defect : 953013 / Task : 970057
*            When we perform an Adjustment operation on PD contract using version which has input routine attached to
*            trigger local override, system throws error message for adjustment amount after accepting local override.
*
* 08/05/14 - Defect : 982893 / Task : 992801
*             Make REPAY.TYPE as HOT.FIELD
*
* 03/11/14  - Enhancement 908020 / Task - 988392
*            Perform Loan Collection
*
* 20/12/16  - Defect : 1953588 / Task : 1961773
*            Stop the PD repayment, if there is any record in MG or MG.PAYMENT in INAU status.
*
* 27/08/19 - Task : 3304813 / Defect :3301886
*            The error message "New outs amount can't be same as Pay amt outs" is thrown
*            after accepting "account is inactive" warning message while performing adjustment operation.
*
* 26/12/19  - Defect : 3496562 / Task : 3508330
*            Issue while performing adjustment operation on PD application through UXP browser
*
* 10/02/20 - Enhancement 3568228  / Task 3580449
*            Changing reference of routines that have been moved from ST to CG
************************************************************************
    $INSERT I_DAS.PD.CAPTURE

    $USING PD.Config
    $USING PD.Contract
    $USING ST.Customer
    $USING ST.CurrencyConfig
    $USING ST.Config
    $USING ST.RateParameters
    $USING AC.AccountOpening
    $USING CG.ChargeConfig
    $USING LI.Config
    $USING DE.Config
    $USING LD.Contract
    $USING RE.Config
    $USING ST.CompanyCreation
    $USING ST.AssetProcessing
    $USING AC.Fees
    $USING EB.Interface
    $USING EB.Display
    $USING EB.TransactionControl
    $USING PD.Foundation
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    $USING MM.Foundation
    $USING PD.Interface
    $USING EB.Delivery
    $USING CL.Contract
    $USING PM.Config
    $USING EB.SystemTables
    $USING MG.Contract
    $USING MG.Payment
    $USING EB.SOAframework
    $USING EB.Iris

*
*************************************************************************

    GOSUB DEFINE.PARAMETERS

    tmp.V$FUNCTION = EB.SystemTables.getVFunction()
    IF LEN(tmp.V$FUNCTION) GT 1 THEN
        EB.SystemTables.setVFunction(tmp.V$FUNCTION)
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
                CONTINUE
            END

            EB.TransactionControl.RecordRead()

            IF EB.Interface.getOfsBrowser() THEN
                IF EB.Interface.getOfsOperation() AND EB.Interface.getOfsOperation() EQ 'BUILD' THEN    ;* Should be cleared during new input
                    PD.Foundation.setCRepaymentData('')
                END
            END ELSE
                PD.Foundation.setCRepaymentData('')
            END

            IF EB.SystemTables.getMessage() EQ 'REPEAT' THEN
                CONTINUE
            END

            GOSUB CHECK.LIVE.ACCOUNT    ;* CI_100006665 S/E

            EB.Display.MatrixAlter()

            GOSUB CHECK.RECORD          ;* Special Editing of Record

            IF V$ERROR THEN
                CONTINUE
            END

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

        tmp.MESSAGE = EB.SystemTables.getMessage()
    WHILE NOT(tmp.MESSAGE)
        EB.SystemTables.setMessage(tmp.MESSAGE)

        GOSUB CHECK.FIELDS    ;* Special Field Editing

        IF EB.SystemTables.getTSequ() NE '' THEN
            tmp=EB.SystemTables.getTSequ(); tmp<-1>=EB.SystemTables.getA() + 1; EB.SystemTables.setTSequ(tmp)
        END

    REPEAT

RETURN

*************************************************************************

PROCESS.MESSAGE:

* Processing after exiting from field input (PF5)

    IF EB.SystemTables.getMessage() EQ 'VAL' THEN
    
        EB.SystemTables.setMessage('')
        SAVE.PROV.PERC = EB.SystemTables.getRNew(PD.Contract.PaymentDue.Provision)      ;* Save the provision related values it should be restored back while running under browser
        SAVE.PROV.AMT = EB.SystemTables.getRNew(PD.Contract.PaymentDue.ProvisionAmount)
        SAVE.ASSET.CLASS = EB.SystemTables.getRNew(PD.Contract.PaymentDue.AssetClass)
        R.NEW.DYN = EB.SystemTables.getDynArrayFromRNew()
        MATPARSE R.NEW.SAVE FROM R.NEW.DYN
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
            IF EB.Interface.getOfsBrowser() AND (EB.SystemTables.getMessage() EQ 'ERROR') THEN    ;* Restore back the old values of provision related fields while running under browser and encountered a override
                EB.SystemTables.setRNew(PD.Contract.PaymentDue.Provision, SAVE.PROV.PERC)
                EB.SystemTables.setRNew(PD.Contract.PaymentDue.ProvisionAmount, SAVE.PROV.AMT)
                EB.SystemTables.setRNew(PD.Contract.PaymentDue.AssetClass, SAVE.ASSET.CLASS)
            END
            IF isUxpBrowser THEN
                OverrideFlag = EB.SOAframework.getSoaErrInfo()
            END ELSE
                OverrideFlag = EB.Interface.getOfsOverrides()<2>
            END
            IF EB.Interface.getOfsOverrides() OR OverrideFlag THEN       ;* After all processing, chk the response.
                FIND "NO" IN OverrideFlag SETTING OVERRIDE.POSITION THEN
                    MATBUILD R.NEW.SAVE.DYN FROM R.NEW.SAVE
                    EB.SystemTables.setDynArrayToRNew(R.NEW.SAVE.DYN)
                END
            END
            IF EB.Interface.getOfsWarnings() THEN
                FIND "NOANSWER"  IN EB.Interface.getOfsWarnings()<2> SETTING WARNING.POSITION THEN
                    MATBUILD R.NEW.SAVE.DYN FROM R.NEW.SAVE
                    EB.SystemTables.setDynArrayToRNew(R.NEW.SAVE.DYN)
                END
            END
            IF EB.SystemTables.getMessage() NE "ERROR" THEN
                PD.Foundation.setCRepaymentData('');* Clear it, not to retain old values for subsequent input/transaction
REM >          GOSUB AFTER.UNAU.WRITE          ;* Special Processing after write
            END
        END

    END

    IF EB.SystemTables.getMessage() EQ 'AUT' THEN
REM >    GOSUB AUTH.CROSS.VALIDATION          ;* Special Cross Validation
REM >    IF NOT(ERROR) THEN
        GOSUB BEFORE.AUTH.WRITE         ;* Special Processing before write
REM >    END

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

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************

CHECK.ID:

* Validation and changes of the ID entered.  Set ERROR to 1 if in error.

    PD.Foundation.CheckId()

    IF EB.SystemTables.getVFunction() = 'I' AND EB.SystemTables.getIdNew()[3,2] = 'LD' THEN         ;* CI_10005180 S
        Y.LD.ID = EB.SystemTables.getIdNew()[3,12]
        R.LD.REC = ''
        F.LD.LOANS.AND.DEPOSITS = ''
        R.LD.REC = LD.Contract.LoansAndDeposits.ReadNau(Y.LD.ID, ERR.TEXT)
        IF NOT(ERR.TEXT) THEN
            EB.SystemTables.setE("PD.PPD.INP.NOT.ALLWD.LD.NOT.AUTH")
            V$ERROR = 1
            EB.ErrorProcessing.Err()
        END
    END   ;* CI_10005180 S

    IF EB.SystemTables.getVFunction() = 'I' AND EB.SystemTables.getIdNew()[3,2] = 'MG' THEN         ;* CI_10005180 S
        Y.MG.ID = EB.SystemTables.getIdNew()[3,12]
        R.MG.REC = ''
        F.MG.MORTGAGE = ''
        R.MG.REC = MG.Contract.Mortgage.ReadNau(Y.MG.ID, ERR.TEXT)
        IF NOT(ERR.TEXT) THEN
            EB.SystemTables.setE("PD-PPD.INP.NOT.ALLWD.MG.NOT.AUTH")
            V$ERROR = 1
            EB.ErrorProcessing.Err()
        END ELSE
            F.MG.PAYMENT.CONTROL = ''
            R.MG.REC = MG.Payment.PaymentControl.Read(Y.MG.ID, ERR.TEXT)
            IF R.MG.REC<MG.Payment.PaymentControl.PcNauRecord> NE '' THEN
                EB.SystemTables.setE("PD-PPD.INP.NOT.ALLWD.MGPAY.NOT.AUTH")
                V$ERROR = 1
                EB.ErrorProcessing.Err()
            END
        END
    END

    IF EB.SystemTables.getVFunction() = 'I' THEN  ;* CI_10029502 S

        IF EB.SystemTables.getIdNew()[1,4] = "PDPD" THEN
            PD.ID = EB.SystemTables.getIdNew()
        END ELSE
            tmp.ID.NEW = EB.SystemTables.getIdNew()
            PD.ID = EB.SystemTables.getIdNew()[3,LEN(tmp.ID.NEW)]
            EB.SystemTables.setIdNew(tmp.ID.NEW)
        END

        TABLE.SUFFIX = "$NAU"
        THE.LIST = ''
        THE.ARGS = ''
        THE.LIST = dasPdCaptureContractRecordStatus
        THE.ARGS<1> = PD.ID
        EB.DataAccess.Das("PD.CAPTURE",THE.LIST, THE.ARGS,TABLE.SUFFIX)
        ID.LIST = THE.LIST

        IF ID.LIST THEN
            EB.SystemTables.setE("PD.RTN.INP.NOT.ALLD.PDC.NOT.AUTH")
            V$ERROR = 1
            EB.ErrorProcessing.Err()
        END
    END   ;* CI_10029502 E
*
    IF EB.SystemTables.getEtext() THEN
        V$ERROR = 1 ; EB.ErrorProcessing.Err()
    END
*
* Load all Provision common variable
    ST.AssetProcessing.LnLoadProvCommon('LOAD')    ;*EN_10002267-S/E  ;* BG_100018375

RETURN

*************************************************************************

CHECK.RECORD:

* Validation and changes of the Record.  Set ERROR to 1 if in error.

    PD.Foundation.setCPdId(EB.SystemTables.getIdNew())
    PD.Foundation.LoadCommon('')
*
    IF EB.SystemTables.getRNew(PD.Contract.PaymentDue.RecordStatus)[2,3] EQ 'NAU' THEN ;* EN_10001735 S
        NAME.INPUTT = FIELD(EB.SystemTables.getRNew(PD.Contract.PaymentDue.Inputter)<1,1>,'_',2)  ;* BG_100004400 S/E
        IF (NAME.INPUTT EQ 'AZ.AUTO' OR NAME.INPUTT EQ 'LD.AUTO') AND EB.SystemTables.getVFunction() NE 'S' THEN
            EB.SystemTables.setE('PD.PPD.FUNT.NOT.ALLOW.APP')
            GOTO CHECK.RECORD.EXIT
        END
    END   ;* EN_10001735 E

* Save the balances and rates records
*
    STORE.PD.BALANCES = PD.Foundation.getRPdBalances()
    STORE.PD.RATES = PD.Foundation.getRPdRates()
*
    tmp.ID.OLD = EB.SystemTables.getIdOld()
    IF NOT(tmp.ID.OLD) AND EB.SystemTables.getVFunction() = "I" THEN      ;* New record not allowed
        EB.SystemTables.setIdOld(tmp.ID.OLD)
        EB.SystemTables.setE("PD.PPD.NO.DUE.PAYMENTS.DEAL")
        GOTO CHECK.RECORD.EXIT
    END
*
** Reset the T parameters
*
    FOR X = PD.Contract.PaymentDue.Operation TO PD.Contract.PaymentDue.Override
        EB.SystemTables.setT(X, T.STORE(X))
    NEXT X
*
    BEGIN CASE
        CASE EB.SystemTables.getRNew(PD.Contract.PaymentDue.Operation) = ''       ;* Only the OPERATION is allowed
            FOR X = PD.Contract.PaymentDue.Customer TO PD.Contract.PaymentDue.Override
                tmp=EB.SystemTables.getT(X); tmp<3>='NOINPUT'; EB.SystemTables.setT(X, tmp)
            NEXT X
*
* GB9701138

* PREVENT.RETRY is inputtable only in maintenance operation.; EN_10000386 S/E
*
* ADVICE.CHGS field is opened only when an operation is entered ; *CI_10001125 - S/E

        CASE EB.SystemTables.getRNew(PD.Contract.PaymentDue.Operation) = 'MAINTENANCE'
            IF NOT(EB.SystemTables.getRNew(PD.Contract.PaymentDue.Status) MATCHES 'CUR':@VM:'FWOF') THEN         ;* CI_10014145 ; * EN_10002146 S/E
                tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.LimitReference); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.LimitReference, tmp)
                tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.RepaidStatus); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.RepaidStatus, tmp)
                tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.NetCustEntries); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.NetCustEntries, tmp)
                LOCATE 'SC' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING POS THEN ;* CI_10058356 S Check whether SC module is installed
                    tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.PortfolioNumber); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.PortfolioNumber, tmp)
                END
*
* GB9701138
* When A/c officer field is changed in the UL contract, the same is not effected in PD
* Hence allow the user to change the A/c officer field through Maintenance operation.
                tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.AccountOfficer); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.AccountOfficer, tmp);* CI_10033768 S/E
                tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.AdviceChgs); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.AdviceChgs, tmp)
                tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.PreventRetry); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.PreventRetry, tmp)
            END         ;* CI_10014145
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.Notes); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.Notes, tmp)
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.RepaymentAcct); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.RepaymentAcct, tmp);* CI_10038781 S/E

* BG_100000139 S
* If the status is NAB and the operation is maintanence then
* the field MANUAL.NAB is made as input
            IF EB.SystemTables.getRNew(PD.Contract.PaymentDue.Status) EQ 'NAB' THEN
                tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.ManualNab); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.ManualNab, tmp)
            END
* BG_100000139 E
            IF EB.SystemTables.getRNew(PD.Contract.PaymentDue.Status) EQ "FWOF" THEN        ;* EN_10002146 S
                tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.MoveToHis); tmp<3>=""; EB.SystemTables.setT(PD.Contract.PaymentDue.MoveToHis, tmp)
            END
*
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.AssetClass); tmp<3>=""; EB.SystemTables.setT(PD.Contract.PaymentDue.AssetClass, tmp)
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.WofReason); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.WofReason, tmp)
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.Provision); tmp<3>=""; EB.SystemTables.setT(PD.Contract.PaymentDue.Provision, tmp);* EN_10002146 E
*
        CASE EB.SystemTables.getRNew(PD.Contract.PaymentDue.Operation) = 'ADJUSTMENT'
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.NewOutsAmt); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.NewOutsAmt, tmp)
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.Notes); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.Notes, tmp)
*
* GB9701138
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.AdviceChgs); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.AdviceChgs, tmp)
* PREVENT.RETRY is inputtable only in maintenance operation.; EN_10000386 S/E
*
        CASE EB.SystemTables.getRNew(PD.Contract.PaymentDue.Operation) = 'REPAYMENT'
            FOR X = PD.Contract.PaymentDue.RepaymentDate TO PD.Contract.PaymentDue.TotRepayAmt
                tmp=EB.SystemTables.getT(X); tmp<3>=''; EB.SystemTables.setT(X, tmp)
            NEXT X
            FOR X = PD.Contract.PaymentDue.SchdType TO PD.Contract.PaymentDue.SchdProcDate
                tmp=EB.SystemTables.getT(X); tmp<3>="NOINPUT"; EB.SystemTables.setT(X, tmp)
            NEXT X
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.ChargeType); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.ChargeType, tmp)
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.ChargeAmt); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.ChargeAmt, tmp)
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.RepayAmt); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.RepayAmt, tmp)
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.Notes); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.Notes, tmp)
*
*
* GB9701138
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.AdviceChgs); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.AdviceChgs, tmp)
* PREVENT.RETRY is inputtable only in maintenance operation.; EN_10000386 S/E
*
        CASE EB.SystemTables.getRNew(PD.Contract.PaymentDue.Operation) = 'SCHEDULE'
            FOR X = PD.Contract.PaymentDue.SchdType TO PD.Contract.PaymentDue.SchdAdvSent
                IF X NE PD.Contract.PaymentDue.SchdAmount THEN ;* CI_10001455 - S
                    tmp=EB.SystemTables.getT(X); tmp<3>=''; EB.SystemTables.setT(X, tmp)
                END     ;* CI_10001455 - E
            NEXT X
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.Notes); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.Notes, tmp)
*
* GB9701138
            tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.AdviceChgs); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.AdviceChgs, tmp)
* PREVENT.RETRY is inputtable only in maintenance operation.; EN_10000386 S/E
*
    END CASE


    tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.WaiveGraPe); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.WaiveGraPe, tmp);* EN_10003022 S
    tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.WaiveGraPs); tmp<3>=''; EB.SystemTables.setT(PD.Contract.PaymentDue.WaiveGraPs, tmp);* EN_10003022 E


    IF EB.SystemTables.getRNew(PD.Contract.PaymentDue.Operation)<> '' THEN   ;* EN_10002326 S
        tmp=EB.SystemTables.getT(PD.Contract.PaymentDue.Operation); tmp<3>='NOINPUT'; EB.SystemTables.setT(PD.Contract.PaymentDue.Operation, tmp)
    END   ;* EN_10002326 E

*  Enrichment is done here
*
    ENRI.AF = PD.Contract.PaymentDue.PenaltyKey
    YENRI = ''
    IF EB.SystemTables.getRNew(ENRI.AF) THEN
        REQ.RATE = ''
        INT.REC = ''
        INT.DTE = EB.SystemTables.getToday()
        RET.CDE = 0
        tmp.R.NEW.PD.Contract.PaymentDue.Currency = EB.SystemTables.getRNew(PD.Contract.PaymentDue.Currency)
        tmp.R.NEW.ENRI.AF = EB.SystemTables.getRNew(ENRI.AF)
        MM.Foundation.GetInterest(tmp.R.NEW.ENRI.AF,tmp.R.NEW.PD.Contract.PaymentDue.Currency,INT.DTE,INT.REC,RET.CDE)
        EB.SystemTables.setRNew(ENRI.AF, tmp.R.NEW.ENRI.AF)
        EB.SystemTables.setRNew(PD.Contract.PaymentDue.Currency, tmp.R.NEW.PD.Contract.PaymentDue.Currency)
        IF RET.CDE NE 0 THEN
            REQ.RATE = INT.REC<ST.RateParameters.BasicInterest.EbBinInterestRate>
        END
        tmp.R.NEW.ENRI.AF = EB.SystemTables.getRNew(ENRI.AF)
        EB.DataAccess.Dbr('BASIC.RATE.TEXT':@FM:ST.RateParameters.BasicRateText.EbBrtDescription:@FM:'L.A.S',tmp.R.NEW.ENRI.AF,YENRI)
        EB.SystemTables.setRNew(ENRI.AF, tmp.R.NEW.ENRI.AF)
        tmp.ETEXT = EB.SystemTables.getEtext()
        IF NOT(tmp.ETEXT) THEN
            EB.SystemTables.setEtext(tmp.ETEXT)
            LOCATE ENRI.AF IN EB.SystemTables.getTFieldno()<1> SETTING YPOS THEN
                IF REQ.RATE THEN
                    tmp=EB.SystemTables.getTEnri(); tmp<YPOS>=YENRI:' ':REQ.RATE:'%'; EB.SystemTables.setTEnri(tmp)
                END ELSE
                    tmp=EB.SystemTables.getTEnri(); tmp<YPOS>=YENRI; EB.SystemTables.setTEnri(tmp)
                END
            END
        END
    END
*
    ENRI.AF = PD.Contract.PaymentDue.LimitReference
    YENRI = ''
    IF EB.SystemTables.getRNew(ENRI.AF) THEN
        tmp.R.NEW.ENRI.AF = EB.SystemTables.getRNew(ENRI.AF)
        EB.DataAccess.Dbr('LIMIT.REFERENCE':@FM:LI.Config.LimitReference.RefDescription:@FM:'L', FIELD(tmp.R.NEW.ENRI.AF,'.',1),YENRI)
        EB.SystemTables.setRNew(ENRI.AF, tmp.R.NEW.ENRI.AF)
        tmp.ETEXT = EB.SystemTables.getEtext()
        IF NOT(tmp.ETEXT) THEN
            EB.SystemTables.setEtext(tmp.ETEXT)
            LOCATE ENRI.AF IN EB.SystemTables.getTFieldno()<1> SETTING YPOS THEN
                tmp=EB.SystemTables.getTEnri(); tmp<YPOS>=YENRI; EB.SystemTables.setTEnri(tmp)
            END
        END
    END
*
    ENRI.AF = PD.Contract.PaymentDue.OrigLimitRef
    YENRI = ''
    IF EB.SystemTables.getRNew(ENRI.AF) THEN
        tmp.R.NEW.ENRI.AF = EB.SystemTables.getRNew(ENRI.AF)
        EB.DataAccess.Dbr('LIMIT.REFERENCE':@FM:LI.Config.LimitReference.RefDescription:@FM:'L', FIELD(tmp.R.NEW.ENRI.AF,'.',1),YENRI)
        EB.SystemTables.setRNew(ENRI.AF, tmp.R.NEW.ENRI.AF)
        tmp.ETEXT = EB.SystemTables.getEtext()
        IF NOT(tmp.ETEXT) THEN
            EB.SystemTables.setEtext(tmp.ETEXT)
            LOCATE ENRI.AF IN EB.SystemTables.getTFieldno()<1> SETTING YPOS THEN
                tmp=EB.SystemTables.getTEnri(); tmp<YPOS>=YENRI; EB.SystemTables.setTEnri(tmp)
            END
        END
    END
*
CHECK.RECORD.EXIT:
    IF EB.SystemTables.getE() THEN
        EB.ErrorProcessing.Err() ; V$ERROR = 1
    END
*
RETURN
*
* CI_10006665 S
CHECK.LIVE.ACCOUNT:
******************
* GB0102011 S
* Check the original settlement account if it is not live, then remove
* account from the multi value set.
*
    IF ((EB.SystemTables.getIdOld() AND EB.SystemTables.getVFunction() = "I" ) OR EB.SystemTables.getVFunction() = "S") AND (EB.SystemTables.getRNew(PD.Contract.PaymentDue.OrigStlmntAct)) THEN
        NO.AC = DCOUNT(EB.SystemTables.getRNew(PD.Contract.PaymentDue.OrigStlmntAct),@VM)
        FOR NO.AC.I = 1 TO NO.AC
            STL.ACC.NO = EB.SystemTables.getRNew(PD.Contract.PaymentDue.OrigStlmntAct)<1,NO.AC.I>
            ACC.REC = ''
            IO.ERR  = ''
            ACC.REC = AC.AccountOpening.Account.Read(STL.ACC.NO, IO.ERR)         ;* BG_10016882 S/E
            IF IO.ERR THEN
                tmp.RNEW = EB.SystemTables.getRNew(PD.Contract.PaymentDue.OrigStlmntAct)
                DEL tmp.RNEW<1,NO.AC.I>
                EB.SystemTables.setRNew(PD.Contract.PaymentDue.OrigStlmntAct,tmp.RNEW)

                NO.AC.I -= 1
                NO.AC -= 1
            END
        NEXT NO.AC.I
    END
* GB0102011 e
*

* G10310023 - S
    IF ((EB.SystemTables.getIdOld() AND EB.SystemTables.getVFunction() = "I") OR EB.SystemTables.getVFunction() = "S") AND (EB.SystemTables.getRNew(PD.Contract.PaymentDue.RepaymentAcct)) THEN
        REP.ACC = EB.SystemTables.getRNew(PD.Contract.PaymentDue.RepaymentAcct)        ;* CI_10027164 S/E
        ACC.REC = ''
        IO.ERR  = ''
        ACC.REC = AC.AccountOpening.Account.Read(REP.ACC, IO.ERR)      ;* BG_10016882 S/E
        IF IO.ERR THEN
            EB.SystemTables.setRNew(PD.Contract.PaymentDue.RepaymentAcct, "")
        END
    END
RETURN

* G10310023 - E
* CI_10006665 - E

*************************************************************************

CHECK.FIELDS:

* EN_10001735 S
    PD.Interface.OnlineRepayment('PD.CHECK.FIELDS','','','','') ;* EN_10001735 S/E
* EN_10001735 E
*
    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setTSequ('IFLD')
        EB.ErrorProcessing.Err()
    END
*
RETURN

*************************************************************************

CROSS.VALIDATION:

*
*  Normal cross validation code should reside here.
*
* EN_10001735 S
*
    EB.SystemTables.setText('');* CI_10241
    V$ERROR = ''
    PD.Interface.OnlineRepayment('PD.CROSSVAL','','','','')     ;* EN_10001735 S/E
    IF EB.SystemTables.getText() EQ 'NO' THEN      ;* CI_10241 +
        V$ERROR = 1
        EB.SystemTables.setText('')
    END   ;* CI_10241 -
RETURN
* EN_10001735 E

*************************************************************************

AUTH.CROSS.VALIDATION:


RETURN

*************************************************************************

CHECK.DELETE:
    V$ERROR = ''    ;* CI_10010817 +
    EB.SystemTables.setText('');* CI_10010817 -

    PD.Interface.OnlineRepayment('CHECK.DELETE','','','','')    ;* EN_10001735 S/E

    IF EB.SystemTables.getText() EQ 'NO' THEN      ;* CI_10010817 +
        V$ERROR = 1
        EB.SystemTables.setText('')
    END   ;* CI_10010817 -
RETURN

*************************************************************************

CHECK.REVERSAL:


RETURN

*************************************************************************

BEFORE.UNAU.WRITE:
    IF EB.Interface.getOfsOperation() NE 'VALIDATE' THEN ;*CI_10058963-S/E
        PD.Interface.OnlineRepayment('BEFORE.UNAU.WRITE','','','','')     ;* EN_10001735 S/E
    END
    IF EB.SystemTables.getText() EQ 'NO' THEN      ;* CI_10010817 +
        V$ERROR = 1
        EB.SystemTables.setText('')
    END   ;* CI_10010817 -
RETURN

*************************************************************************

AFTER.UNAU.WRITE:


RETURN

*************************************************************************

AFTER.AUTH.WRITE:


RETURN

*************************************************************************

BEFORE.AUTH.WRITE:
* Create the PD.REPAYMENT record
*
* EN_10001735 S
    SAVE.RECORD.STATUS = EB.SystemTables.getRNew(PD.Contract.PaymentDue.RecordStatus)
    PD.Interface.OnlineRepayment('BEFORE.AUTH.WRITE','','','','')         ;* EN_10001735 S/E
    EB.SystemTables.setRNew(PD.Contract.PaymentDue.RecordStatus, SAVE.RECORD.STATUS)

    IF EB.SystemTables.getRNew(PD.Contract.PaymentDue.Override) THEN          ;* If there are any OVERRIDES a call to EXCEPTION.LOG should be made
        EXCEP.APP = "PD"
        EXCEP.CODE="110"
        EXCEP.MESSAGE = "OVERRIDE CONDITION"
        tmp.R.NEW.PD.Contract.PaymentDue.AccountOfficer = EB.SystemTables.getRNew(PD.Contract.PaymentDue.AccountOfficer)
        tmp.R.NEW.PD.Contract.PaymentDue.CurrNo = EB.SystemTables.getRNew(PD.Contract.PaymentDue.CurrNo)
        tmp.ID.NEW = EB.SystemTables.getIdNew()
        tmp.FULL.FNAME = EB.SystemTables.getFullFname()
        EB.ErrorProcessing.ExceptionLog("U", EXCEP.APP,"PD.PAYMENT.DUE","PD.PAYMENT.DUE",EXCEP.CODE,"",tmp.FULL.FNAME,tmp.ID.NEW,tmp.R.NEW.PD.Contract.PaymentDue.CurrNo,EXCEP.MESSAGE,tmp.R.NEW.PD.Contract.PaymentDue.AccountOfficer)
        EB.SystemTables.setFullFname(tmp.FULL.FNAME)
        EB.SystemTables.setIdNew(tmp.ID.NEW)
        EB.SystemTables.setRNew(PD.Contract.PaymentDue.CurrNo, tmp.R.NEW.PD.Contract.PaymentDue.CurrNo)
        EB.SystemTables.setRNew(PD.Contract.PaymentDue.AccountOfficer, tmp.R.NEW.PD.Contract.PaymentDue.AccountOfficer)
    END

* For Loan Collection.

    PRODUCT.CODE = 'CL'
    VALID.PRODUCT = '' ;
    PRODUCT.INSTALLED = '' ;
    COMPANY.HAS.PRODUCT = ''
    ERROR.TEXT = ''

* Check 'CL' product is valid and Installed .

    EB.Delivery.ValProduct(PRODUCT.CODE,VALID.PRODUCT,PRODUCT.INSTALLED,COMPANY.HAS.PRODUCT,ERROR.TEXT)

    IF VALID.PRODUCT AND PRODUCT.INSTALLED AND NOT(ERROR.TEXT) THEN
        CALL.APPLICATION = 'PD'
        UL.CONTRACT.ID = PD.Foundation.getCPdId()
        UL.CONTRACT.REC = PD.Foundation.getRPdPaymentDue()
        IF UL.CONTRACT.ID[3,2] MATCHES 'LD':@VM:'PD' THEN
            CL.Contract.ProcessContract(CALL.APPLICATION,UL.CONTRACT.ID,UL.CONTRACT.REC,"","","","","","")
        END
    END

RETURN
* EN_10001735 E
*************************************************************************

CHECK.FUNCTION:

* Validation of function entered.  Set FUNCTION to null if in error.

    tmp.V$FUNCTION = EB.SystemTables.getVFunction()
    IF INDEX('VHCR',tmp.V$FUNCTION,1) THEN
        EB.SystemTables.setVFunction(tmp.V$FUNCTION)
        EB.SystemTables.setE('PD.PPD.FUNT.NOT.ALLOW.APP')
        EB.ErrorProcessing.Err()
        EB.SystemTables.setVFunction('')
    END

RETURN

*************************************************************************

INITIALISE:

    DIM T.STORE(PD.Contract.PaymentDue.AuditDateTime)
    FOR X = PD.Contract.PaymentDue.Operation TO PD.Contract.PaymentDue.Override
        T.STORE(X) = EB.SystemTables.getT(X)
    NEXT X
*
    PD.Foundation.setCPdId('')
    PD.Foundation.LoadCommon('')
*
    LOCATE 'PM' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING POS THEN         ;*CI_10029081 -S/E
        PM.Config.SetupParam()
    END   ;*CI_10029081 -S/E
*
* BG_100000139 S
    STORE.ACCBAL.REC = ''
* BG_100000139 E

* CI_10000419 S
    F$PD.ENT.TODAY = 'F.PD.ENT.TODAY'
    F.PD.ENT.TODAY = ''
* CI_10000419 E
* EN_10000420 S
    LOCATE 'MG' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING POS THEN         ;* CI_10004117 S/E
        MG.BALANCES.FILE = "F.MG.BALANCES"
        F.MG.BALANCES = ""
    END   ;* CI_10004117 S/E
*
* CI_10009523 -S
    LOCATE 'LD' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING LD.POS THEN
* CI_10009523 -E

        ACCOUNT.BALANCES.FILE = 'F.LMM.ACCOUNT.BALANCES'
        F.ACCOUNT.BALANCES = ""
* CI_10009523 - S
    END   ;* CI_10009523- E

* CI_10034874 S
* Check if NS is installed in the company.

    LOCATE 'NS' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING  NS.INSTALLED  ELSE
        NS.INSTALLED = ''
    END
* CI_10034874 E
    FN.LIST = 'F.NAB.TO.CUR.LIST'
    FV.LIST = ''

    FN.PD.CAPTURE$NAU = 'F.PD.CAPTURE$NAU'
    F.PD.CAPTURE$NAU = ''

    FN.ACCOUNT = 'F.ACCOUNT'  ;* BG_10016882 S
    F.ACCOUNT = ''

* EN_10000420 E
    DIM R.NEW.SAVE(EB.SystemTables.SysDim)
    
    EB.Iris.IrisGetisiris(isUxpBrowser)

RETURN
************************************************************************
GET.LAST.CAP.DATE:

    Y.CE.CAP.UPD.REQD = 0
    Y.CS.CAP.UPD.REQD = 0
*
* Call to the routine PD.FIND.BACKWARD.DATE is removed as the routine ;*BG_100015877
* PD.FIND.BACKWARD.DATE is not available

    IF PD.Foundation.getRPdPaymentDue()<PD.Contract.PaymentDue.CeLastCapDate> EQ '' THEN
        LOCATE 'CE' IN PD.Foundation.getRPdPaymentDue()<PD.Contract.PaymentDue.PayType,1,1> SETTING POS THEN
            EB.SystemTables.setComi(PD.Foundation.getRPdParameter()<PD.Config.Parameter.ParPeCapFreq>)
            Y.CE.CAP.UPD.REQD = 1
            tmp=PD.Foundation.getRPdPaymentDue(); tmp<PD.Contract.PaymentDue.CeLastCapDate>=EB.SystemTables.getComi()[1,8]; PD.Foundation.setRPdPaymentDue(tmp)
        END
*
        LOCATE 'CS' IN PD.Foundation.getRPdPaymentDue()<PD.Contract.PaymentDue.PayType,1,1> SETTING POS1 ELSE
            POS1 = ''
        END
        IF POS1 THEN
            tmp=PD.Foundation.getRPdPaymentDue(); tmp<PD.Contract.PaymentDue.CsLastCapDate>=EB.SystemTables.getComi()[1,8]; PD.Foundation.setRPdPaymentDue(tmp)
            Y.CS.CAP.UPD.REQD = 1
        END ELSE
            GOSUB PROCESS.CONTRACT.METHOD.2
        END
*
        IF Y.CE.CAP.UPD.REQD THEN
            tmp.C$PD.BALANCES.IDS = PD.Foundation.getCPdBalancesIds()
            NO.BAL.RECS = DCOUNT(tmp.C$PD.BALANCES.IDS, @FM)
            PD.Foundation.setCPdBalancesIds(tmp.C$PD.BALANCES.IDS)
            FOR Y.COUNT = NO.BAL.RECS TO 1 STEP -1
                IF NO.BAL.RECS GE 1 THEN
                    tmp=PD.Foundation.getRPdBalances(); tmp<Y.COUNT,PD.Config.Balances.BalCeLastCapDate>=PD.Foundation.getRPdPaymentDue()<PD.Contract.PaymentDue.CeLastCapDate>; PD.Foundation.setRPdBalances(tmp)
                    IF Y.CS.CAP.UPD.REQD THEN
                        tmp=PD.Foundation.getRPdBalances(); tmp<Y.COUNT,PD.Config.Balances.BalCsLastCapDate>=PD.Foundation.getRPdPaymentDue()<PD.Contract.PaymentDue.CsLastCapDate>; PD.Foundation.setRPdBalances(tmp)
                    END
                END
            NEXT Y.COUNT
        END
    END

RETURN

*********************************************************************
PROCESS.CONTRACT.METHOD.2:
**************************

    IF PD.Foundation.getRPdParameter()<PD.Config.Parameter.ParContractMethod> EQ '2' THEN
        Y.PS.CALC.BASIS = PD.Foundation.getRPdParameter()<PD.Config.Parameter.ParPsCalcBasis>
        LOOP
            REMOVE Y.PS.COMP FROM Y.PS.CALC.BASIS SETTING YPOS
            Y.EXIT.LOOP = 1
        WHILE Y.PS.COMP AND Y.EXIT.LOOP
            LOCATE Y.PS.COMP IN PD.Foundation.getRPdPaymentDue()<PD.Contract.PaymentDue.PayType,1> SETTING SUCESS ELSE
                SUCESS = ''
            END
            IF SUCESS AND Y.CE.CAP.UPD.REQD THEN
                tmp=PD.Foundation.getRPdPaymentDue(); tmp<PD.Contract.PaymentDue.CsLastCapDate>=EB.SystemTables.getComi()[1,8]; PD.Foundation.setRPdPaymentDue(tmp)
                Y.CS.CAP.UPD.REQD = 1
                Y.EXIT.LOOP = 0
            END
        REPEAT
    END

RETURN

*************************************************************************

DEFINE.PARAMETERS:  * SEE 'I_RULES' FOR DESCRIPTIONS *


    EB.SystemTables.clearF() ; EB.SystemTables.clearN() ; EB.SystemTables.clearT()
    EB.SystemTables.clearCheckfile() ; EB.SystemTables.clearConcatfile()
    EB.SystemTables.setIdCheckfile(""); EB.SystemTables.setIdConcatfile("")
*
*       PREFIX = 'PD.'
*
    EB.SystemTables.setIdF('CONTRACT.NUMBER'); EB.SystemTables.setIdN('31.1');* GB0002099
    EB.SystemTables.setIdT('A'); tmp=EB.SystemTables.getIdT(); tmp<4>='L####/#####/####################'; EB.SystemTables.setIdT(tmp);* GB0002099
    EB.SystemTables.setIdConcatfile('AR')
*
    Z = 0
*
    Z += 1 ; EB.SystemTables.setF(Z, 'OPERATION'); EB.SystemTables.setN(Z, '11..C'); EB.SystemTables.setT(Z, '');* EN_10002326 S/E
    tmp=EB.SystemTables.getT(Z); tmp<2>='MAINTENANCE_ADJUSTMENT_REPAYMENT_SCHEDULE'; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<9>="HOT.FIELD"; EB.SystemTables.setT(Z, tmp);* CI_10027367 S/E ; * Make it HOT.FIELD for browser
*
    Z += 1 ; EB.SystemTables.setF(Z, 'CUSTOMER'); EB.SystemTables.setN(Z, '10'); EB.SystemTables.setT(Z, 'CUS')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, 'CUSTOMER':@FM:ST.Customer.Customer.EbCusShortName:@FM:'L')
*
    Z += 1 ; EB.SystemTables.setF(Z, 'CURRENCY'); EB.SystemTables.setN(Z, '3'); EB.SystemTables.setT(Z, 'CCY')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, 'CURRENCY':@FM:ST.CurrencyConfig.Currency.EbCurCcyName:@FM:'L')
*
    Z += 1 ; EB.SystemTables.setF(Z, 'CURRENCY.MARKET'); EB.SystemTables.setN(Z, '2'); EB.SystemTables.setT(Z, '')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, 'CURRENCY.MARKET':@FM:ST.CurrencyConfig.CurrencyMarket.EbCmaDescription:@FM:'L')
*
    Z += 1 ; EB.SystemTables.setF(Z, 'POSITION.TYPE'); EB.SystemTables.setN(Z, '2'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, 'FX.POS.TYPE':@FM:RE.Config.FxPosType.FxPtDescription:@FM:'L.A.S')
*
    Z += 1 ; EB.SystemTables.setF(Z, 'DEALER.DESK'); EB.SystemTables.setN(Z, '002'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, 'DEALER.DESK':@FM:ST.Config.DealerDesk.FxDdDescription:@FM:'L')
*
    Z += 1 ; EB.SystemTables.setF(Z, 'ACCOUNT.OFFICER'); EB.SystemTables.setN(Z, '4'); EB.SystemTables.setT(Z, 'DAO')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, 'DEPT.ACCT.OFFICER':@FM:ST.Config.DeptAcctOfficer.EbDaoName:@FM:'L')
*
    Z += 1 ; EB.SystemTables.setF(Z, 'CATEGORY'); EB.SystemTables.setN(Z, '6'); EB.SystemTables.setT(Z, '')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, 'CATEGORY':@FM:ST.Config.Category.EbCatShortName:@FM:'L')
*
    Z += 1 ; EB.SystemTables.setF(Z, 'INTEREST.BASIS'); EB.SystemTables.setN(Z, '3'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, 'INTEREST.BASIS':@FM:ST.RateParameters.InterestBasis.IbDescription:@FM:'L')
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX.ORIG.STLMNT.ACT'); EB.SystemTables.setN(Z, '16'); EB.SystemTables.setT(Z, 'ANT')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, 'ACCOUNT':@FM:AC.AccountOpening.Account.ShortTitle:@FM:'L')
*
    Z += 1 ; EB.SystemTables.setF(Z, 'PENALTY.RATE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'R')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'PENALTY.KEY'); EB.SystemTables.setN(Z, '4'); EB.SystemTables.setT(Z, '');* GB9700954
    EB.SystemTables.setCheckfile(Z, 'BASIC.RATE.TEXT':@FM:ST.RateParameters.BasicRateText.EbBrtDescription:@FM:'L')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'PENALTY.SPREAD'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'R')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'PARAMETER.RECORD'); EB.SystemTables.setN(Z, '6'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'ORIG.LIMIT.REF'); EB.SystemTables.setN(Z, '10'); EB.SystemTables.setT(Z, '')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>='2'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'LIMIT.REFERENCE'); EB.SystemTables.setN(Z, '10..C'); EB.SystemTables.setT(Z, '')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>='2'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'LIMIT.AMOUNT'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'TOTAL.AMT.TO.REPAY'); EB.SystemTables.setN(Z, '019'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'TOTAL.OVERDUE.AMT'); EB.SystemTables.setN(Z, '019'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'TOTAL.OVERDUE.TAX'); EB.SystemTables.setN(Z, '019'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX<TOT.OVRDUE.TYPE'); EB.SystemTables.setN(Z, '12'); EB.SystemTables.setT(Z, 'A')
    EB.SystemTables.setCheckfile(Z, 'PD.AMOUNT.TYPE':@FM:PD.Config.AmountType.AmtTypDescription:@FM:'L')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX>TOT.OD.TYPE.AMT'); EB.SystemTables.setN(Z, '019'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'FINAL.DUE.DATE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'D')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX<PAYMENT.DTE.DUE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'D')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<8,1>='NOMODIFY'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-PAYMENT.AMOUNT'); EB.SystemTables.setN(Z, '019'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-PAYMENT.AMT.TAX'); EB.SystemTables.setN(Z, '019'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-OUTSTANDING.AMT'); EB.SystemTables.setN(Z, '019'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-XX<PAY.TYPE'); EB.SystemTables.setN(Z, '12'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<8,2>='NOMODIFY'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, 'PD.AMOUNT.TYPE':@FM:PD.Config.AmountType.AmtTypDescription:@FM:'L')
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-XX-PAY.AMT.ORIG'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-XX-PAY.AMT.OUTS'); EB.SystemTables.setN(Z, '019'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-XX-PAY.AMT.OSTX'); EB.SystemTables.setN(Z, '019'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-XX-REPAID.AMT'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-XX-ADJUSTED.AMT'); EB.SystemTables.setN(Z, '20'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,1>='-'; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-XX>NEW.OUTS.AMT'); EB.SystemTables.setN(Z, '019..C'); EB.SystemTables.setT(Z, 'AMT');* EN_10002437 S/E
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX>REPAID.STATUS'); EB.SystemTables.setN(Z, '4..C'); EB.SystemTables.setT(Z, '')
    tmp=EB.SystemTables.getT(Z); tmp<2>='PRE_GRA_PDO_NAB_RPD_FWOF_WOF'; EB.SystemTables.setT(Z, tmp);* EN_10002146 S/E
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX<SCHD.TYPE'); EB.SystemTables.setN(Z, '8..C'); EB.SystemTables.setT(Z, 'A')
    EB.SystemTables.setCheckfile(Z, 'PD.SCHEDULE.TYPE':@FM:PD.Config.ScheduleType.SchTypDescription:@FM:'L')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-SCHD.DATE.FREQ'); EB.SystemTables.setN(Z, '16..C'); EB.SystemTables.setT(Z, 'FQO')
    tmp=EB.SystemTables.getT(Z); tmp<4>='LDDDD DD  D #####'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-SCHD.END.DATE'); EB.SystemTables.setN(Z, '11..C'); EB.SystemTables.setT(Z, 'D')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-SCHD.AMOUNT'); EB.SystemTables.setN(Z, '19..C'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-SCHD.RATE'); EB.SystemTables.setN(Z, '11..C'); EB.SystemTables.setT(Z, 'R')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-SCHD.SPREAD'); EB.SystemTables.setN(Z, '11..C'); EB.SystemTables.setT(Z, 'R')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-XX.SCHD.NARR'); EB.SystemTables.setN(Z, '35..C'); EB.SystemTables.setT(Z, 'S')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-SCHD.ADV.SENT'); EB.SystemTables.setN(Z, '3..C'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<2>='YES_CAN'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-SCHD.PROC.DATE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'D')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
* GB0003021 S
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-SCHD.ACTIVITY'); EB.SystemTables.setN(Z, '3'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX>SCHD.CHG.CODE'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
* GB0003021 E
*
    Z += 1 ; EB.SystemTables.setF(Z, 'REPAYMENT.DATE'); EB.SystemTables.setN(Z, '11..C'); EB.SystemTables.setT(Z, 'D')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<9>="HOT.FIELD"; EB.SystemTables.setT(Z, tmp);* To calculate Accruals again
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX.REPAYMENT.REF'); EB.SystemTables.setN(Z, '35'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'REPAYMENT.ACCT'); EB.SystemTables.setN(Z, '16..C'); EB.SystemTables.setT(Z, 'ANT')
    EB.SystemTables.setCheckfile(Z, 'ACCOUNT':@FM:AC.AccountOpening.Account.ShortTitle:@FM:'L')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'TOT.REPAY.AMT'); EB.SystemTables.setN(Z, '19..C'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<9>="HOT.FIELD"; EB.SystemTables.setT(Z, tmp);* To distribute the amounts correctly
*
    Z += 1 ; EB.SystemTables.setF(Z, 'TOT.AFTER.DEDUCT'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX<CHARGE.TYPE'); EB.SystemTables.setN(Z, '11..C'); EB.SystemTables.setT(Z, 'CHG')
    tmp=EB.SystemTables.getT(Z); tmp<2>='CHG':@VM:'COM'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX>CHARGE.AMT'); EB.SystemTables.setN(Z, '19..C'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX<CHARGE.TAX.CODE'); EB.SystemTables.setN(Z, '2'); EB.SystemTables.setT(Z, '')
    EB.SystemTables.setCheckfile(Z, 'TAX':@FM:CG.ChargeConfig.Tax.EbTaxDescription:@FM:'L.A..D')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-CHARGE.TAX.AMT'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-CHARGE.TAX.LCY'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=EB.SystemTables.getLccy(); EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX>CHARGE.TAX.XRTE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'R')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX<REPAY.TYPE'); EB.SystemTables.setN(Z, '12..C'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<8,1>='NOMODIFY'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, 'PD.AMOUNT.TYPE':@FM:PD.Config.AmountType.AmtTypDescription:@FM:'L')
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-REPAY.AMT'); EB.SystemTables.setN(Z, '019..C'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<9>="HOT.FIELD"; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-REPAY.DEFAULT'); EB.SystemTables.setN(Z, "1"); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-REPAY.TAX.CODE'); EB.SystemTables.setN(Z, '2..C'); EB.SystemTables.setT(Z, '')
    EB.SystemTables.setCheckfile(Z, 'TAX':@FM:CG.ChargeConfig.Tax.EbTaxDescription:@FM:'L.A..D')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-REPAY.TAX.AMT'); EB.SystemTables.setN(Z, '019'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-REPAY.TAX.LCY'); EB.SystemTables.setN(Z, '019'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=EB.SystemTables.getLccy(); EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-REPAY.TAX.XRATE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'R')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-XX<REPAY.DATE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'D')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-XX-RD.AMT'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-XX-RD.TAX'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'XX>XX>RD.TAX.LCY'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT')
    tmp=EB.SystemTables.getT(Z); tmp<2,2>=EB.SystemTables.getLccy(); EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,3>='D'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'NET.CUST.ENTRIES'); EB.SystemTables.setN(Z, '3..C'); EB.SystemTables.setT(Z, '')
    tmp=EB.SystemTables.getT(Z); tmp<2>='NO_YES'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'PORTFOLIO.NUMBER'); EB.SystemTables.setN(Z, '3..C'); EB.SystemTables.setT(Z, '')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'CONSOL.KEY'); EB.SystemTables.setN(Z, '70'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'STATUS'); EB.SystemTables.setN(Z, '4'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<2>='CUR_GRA_PDO_NAB_RPD_WOF_FWOF_MAT'; EB.SystemTables.setT(Z, tmp);* EN_10002146 S/E
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX.NOTES'); EB.SystemTables.setN(Z, '35'); EB.SystemTables.setT(Z, 'ANY')
    tmp=EB.SystemTables.getT(Z); tmp<7>='TEXT'; EB.SystemTables.setT(Z, tmp)
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX.LOCAL.REF'); EB.SystemTables.setN(Z, '35..C'); EB.SystemTables.setT(Z, 'A');* CI_10000930 S/E
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX<MESSAGE.TYPE'); EB.SystemTables.setN(Z, '4'); EB.SystemTables.setT(Z, '')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, 'DE.MESSAGE':@FM:DE.Config.Message.MsgDescription:@FM:'L')
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX-MESSAGE.DATE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'D')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX>DELIVERY.REF'); EB.SystemTables.setN(Z, '17'); EB.SystemTables.setT(Z, 'AA')
    tmp=EB.SystemTables.getT(Z); tmp<4>='L#########-##############'; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*      CHECKFILE(Z) = 'DE.O.HEADER':FM:DE.HDR.DISPOSITION:FM:'L'
*
* GB9701138
    Z += 1 ; EB.SystemTables.setF(Z, 'ADVICE.CHGS'); EB.SystemTables.setN(Z, '3..C'); EB.SystemTables.setT(Z, '')
    tmp=EB.SystemTables.getT(Z); tmp<2>='NO_YES'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'PREVENT.RETRY'); EB.SystemTables.setN(Z, '3'); EB.SystemTables.setT(Z, '')
    tmp=EB.SystemTables.getT(Z); tmp<2>='YES'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'BACK.VALUE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'D'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp);* GB0002099
*
    Z += 1 ; EB.SystemTables.setF(Z, 'START.DATE'); EB.SystemTables.setN(Z, 11); EB.SystemTables.setT(Z, 'D'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp);* GB0002099
*
* GB0003021 S
    Z += 1 ; EB.SystemTables.setF(Z, 'ADVICE.FREQ'); EB.SystemTables.setN(Z, '16'); EB.SystemTables.setT(Z, 'FQU')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<4>='RDDDD DD  D #####'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'CONTRACT.GRP'); EB.SystemTables.setN(Z, '15'); EB.SystemTables.setT(Z, 'A');* CI_10023367
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
* GB0003021 E
*
* GB0003020 S
    Z += 1 ; EB.SystemTables.setF(Z, 'CE.LAST.CAP.DATE'); EB.SystemTables.setN(Z, '8'); EB.SystemTables.setT(Z, 'D')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'CS.LAST.CAP.DATE'); EB.SystemTables.setN(Z, 8); EB.SystemTables.setT(Z, 'D')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'MANUAL.NAB'); EB.SystemTables.setN(Z, '3'); tmp=EB.SystemTables.getT(Z); tmp<2>='YES_'; EB.SystemTables.setT(Z, tmp);* BG_100000139 S/E
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
*
* EN_10000414 - S
* Changed the RESERVED.1 field to LOAN.SPREAD and intorduced 10 reserved fields

    Z += 1 ; EB.SystemTables.setF(Z, 'LOAN.SPREAD'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'R')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)

    Z += 1 ; EB.SystemTables.setF(Z, 'AUTO.SPREAD'); EB.SystemTables.setN(Z, '3..C'); tmp=EB.SystemTables.getT(Z); tmp<2>='YES_'; EB.SystemTables.setT(Z, tmp);
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp);* EN_1686

    Z += 1 ; EB.SystemTables.setF(Z, 'ASSET.CLASS'); EB.SystemTables.setN(Z, '3..C'); EB.SystemTables.setT(Z, 'A');* EN_10002146 S
    EB.SystemTables.setCheckfile(Z, 'LN.ASSET.CLASS':@FM:ST.AssetProcessing.LnAssetClass.LnAssclsShortDesc:@FM:'L')

    Z += 1 ; EB.SystemTables.setF(Z, 'PROVISION'); EB.SystemTables.setN(Z, '011..C'); EB.SystemTables.setT(Z, 'R');* BG_100006721

    Z += 1 ; EB.SystemTables.setF(Z, 'MOVE.TO.HIS'); EB.SystemTables.setN(Z, '3'); tmp=EB.SystemTables.getT(Z); tmp<2>="YES_"; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp);* EN_10002146 E

* RESERVED6- RESERVED4 - New fields added for PROVISION development.
    Z += 1 ; EB.SystemTables.setF(Z, 'PROVISION.AMOUNT'); EB.SystemTables.setN(Z, '15');EB.SystemTables.setT(Z, 'AMT');*EN_10002267-S
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<2,2>=PD.Contract.PaymentDue.Currency; EB.SystemTables.setT(Z, tmp);* BG_100006901
    Z += 1 ; EB.SystemTables.setF(Z, 'PROVISION.METHOD'); EB.SystemTables.setN(Z, '6..C'); tmp=EB.SystemTables.getT(Z); tmp<2>='AUTO_MANUAL'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'WOF.REASON'); EB.SystemTables.setN(Z, '2'); EB.SystemTables.setT(Z, 'A')
    EB.SystemTables.setCheckfile(Z, "PD.WOF.REASON":@FM:PD.Config.WofReason.WofShortDesc:"L");*EN_10002267-E

    Z += 1 ; EB.SystemTables.setF(Z, 'ACCRUAL.PARAM'); EB.SystemTables.setN(Z, '35'); tmp=EB.SystemTables.getT(Z); tmp<1>='A'; EB.SystemTables.setT(Z, tmp);* EN_10002809 S
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, "EB.ACCRUAL.PARAM":@FM:AC.Fees.EbAccrualParam.EbApDescription:@FM:'L');* EN_10002809 E

    Z += 1 ; EB.SystemTables.setF(Z, 'ROUNDING.RULE'); EB.SystemTables.setN(Z, '35..C'); EB.SystemTables.setT(Z, 'A'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOCHANGE'; EB.SystemTables.setT(Z, tmp);*EN_10002821 -S
    EB.SystemTables.setCheckfile(Z, "EB.ROUNDING.RULE":@FM:ST.Config.EbRoundingRule.EbRdgrDescription:@FM:".A");*EN_10002821 -E
* EN_10003022 S
    Z += 1 ; EB.SystemTables.setF(Z, 'WAIVE.GRA.PE'); EB.SystemTables.setN(Z, '3..C'); tmp=EB.SystemTables.getT(Z); tmp<2>='YES_'; EB.SystemTables.setT(Z, tmp);
    tmp=EB.SystemTables.getT(Z); tmp<3>=''; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'WAIVE.GRA.PS'); EB.SystemTables.setN(Z, '3..C'); tmp=EB.SystemTables.getT(Z); tmp<2>='YES_'; EB.SystemTables.setT(Z, tmp);
    tmp=EB.SystemTables.getT(Z); tmp<3>=''; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'XX<INSTAL.DATE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'D'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp);*EN_10003055 -S
    Z += 1 ; EB.SystemTables.setF(Z, 'XX>INSTAL.AMT'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp);*EN_10003055 -E
    Z += 1 ; EB.SystemTables.setF(Z, 'RESERVED.3'); EB.SystemTables.setN(Z, ''); EB.SystemTables.setT(Z, '');
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'RESERVED.2'); EB.SystemTables.setN(Z, ''); EB.SystemTables.setT(Z, '');
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'RESERVED.1'); EB.SystemTables.setN(Z, ''); EB.SystemTables.setT(Z, '');
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp);* EN_10003022 E
* EN_10000414 - E
*
* GB0003020 E
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX.STMT.NO'); EB.SystemTables.setN(Z, '29'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    Z += 1 ; EB.SystemTables.setF(Z, 'XX.OVERRIDE'); EB.SystemTables.setN(Z, '35'); EB.SystemTables.setT(Z, 'A')
    tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
*
    EB.SystemTables.setV(Z + 9)

* If FIELD.VAL is set to "YES" this code is not necessary

RETURN

*************************************************************************

END
