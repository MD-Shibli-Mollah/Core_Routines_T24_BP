* @ValidationCode : MjotMzA2ODg1MDI6Q3AxMjUyOjE1Njc3NTAzNzI0Njg6c3JhdmlrdW1hcjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMTotMTotMQ==
* @ValidationInfo : Timestamp         : 06 Sep 2019 11:42:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 15/11/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue
SUBROUTINE CHEQUE.ISSUE.OVERRIDE
*-----------------------------------------------------------------------------------------
*
* Routine to process the overrides for a XXXX contract.
*
*-----------------------------------------------------------------------------------------
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
* 26/02/02 - GLOBUS_EN_10000353
*            Enable an override if min holding is greater than
*            the number of cheques issued.
*
* 17/04/03 - CI_10008394
*            Override message changed.
*
*
* 22/04/03 - BG_100004088
*            Conversion of error messages to error codes
*
* 27/10/03 - CI_10014007/CI_10014002/CI_10014012/CI_10014023
*            Override message was not properly displayed and it is modified accordingly
*            with two override records namely AC.RTN.CIO.ACC.DEBIT.BAL and
*            AC.RTN.CIO.FIRCQ.Chq.BK.ISS.CUS
*
* 14/04/04 - CI_10019026
*            Since the field number issued is not inputtable field when
*            cheque status is other than 90. The override msg
*            AC.RTN.CIO.NUM.ISS.LT.MIN.HOLDGS' should not appear.
*
* 27/01/05 - CI_10026744
*            Overrides are created and modified for the missed Text's.
*
* 31/01/11 - 120329
*            Banker's Draft Management.
*            The override "Cheque book issed for the first time for this customer" is
*            not valid for internal cheques.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Issue as ST_ChqIssue and include $PACKAGE
*
* 14/08/15 - Enhancement 1265068 / Task 1387491
*           - Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
* 06/09/19 - Enhancement 3220240 / Task 3323431
*            Correction of Error record.
*
*-----------------------------------------------------------------------------------------
    $USING AC.AccountOpening
    $USING EB.Utility
    $USING CQ.ChqConfig
    $USING EB.API
    $USING EB.OverrideProcessing
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING CQ.ChqIssue

*-----------------------------------------------------------------------------------------

    GOSUB INITIALISE

    GOSUB PROCESS.OVERRIDES

*
* If there are any OVERRIDES a call to EXCEPTION.LOG should be made
*
*     IF R.NEW(V-9) THEN
*        EXCEP.CODE = "110"
*        EXCEP.MESSAGE = "OVERRIDE CONDITION"
*        GOSUB EXCEPTION.MESSAGE
*     END
*
RETURN
*-----------(Main - Override)



*-----------------------------------------------------------------------------------------
PROCESS.OVERRIDES:
*-----------------
* Place Overrides Here
*
* Set text to be the key to the override you
* want to use form the OVERRIDE file
*
* Set AF/AV/AS to be the Field you wish GLOBUS
* to return to if the user rejects the override.
*
* AF = XX.RETURN.FIELD
* TEXT = "SAMPLE.OVERRIDE.KEY"
* GOSUB DO.OVERRIDE

    GOSUB PROCESS.MSG

* All CALL STORE.OVERRIDE(CURR.NO) sts are changed as GOSUB DO.OVERRIDE
    IF CQ.ChqIssue.getCqChargeDate()#'' THEN
        BEGIN CASE
            CASE CQ.ChqIssue.getCqChargeDate() GT EB.SystemTables.getRDates(EB.Utility.Dates.DatForwValueMinimum)
                EB.SystemTables.setText("AC.RTN.CIO.FRD.VAL.DATE.EXCEED")
                EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate)
                GOSUB DO.OVERRIDE
            CASE CQ.ChqIssue.getCqChargeDate() LT EB.SystemTables.getRDates(EB.Utility.Dates.DatBackValueMinimum)
                EB.SystemTables.setText("AC.RTN.CIO.BAK.VAL.DATE.EXCEED")
                EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate)
                GOSUB DO.OVERRIDE
        END CASE
        CHARGE.DATE = CQ.ChqIssue.getCqChargeDate()
        DAYTYPE='' ; EB.API.Awd('',CHARGE.DATE,DAYTYPE)
        CQ.ChqIssue.setCqChargeDate(CHARGE.DATE)
        IF DAYTYPE='H' THEN
            EB.SystemTables.setText("AC.RTN.CIO.DATE.NOT.WORK.DAY")
            EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate)
            GOSUB DO.OVERRIDE
        END
    END

*EN_10000101 -s
*     If Cheque is issued to an account of this customer.
    CHQ.RESTRICT = CQ.ChqIssue.getCqChqRestrict()
    IF NOT(CHQ.RESTRICT) AND CQ.ChqIssue.getCqAcctCust() THEN
        EB.SystemTables.setText("AC.RTN.CIO.FIRST.CHQ.BK.ISS.CUS")
        GOSUB DO.OVERRIDE
    END

* If issue of cheque is restricted to this customer
    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued) THEN       ; **CI_10019026 S/E
        IF CQ.ChqIssue.getCqChqRestrict() EQ 'NO' THEN
            EB.SystemTables.setText("AC.RTN.CIO.ISS.CHQ.BK.RESTR.CUS")
            GOSUB DO.OVERRIDE
        END
    END                                ; **CI_10019026 S/E

*  If the account is having a debit balance
    IF CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.WorkingBalance> LT 0 AND CQ.ChqIssue.getCqCiAccount()<AC.AccountOpening.Account.WorkingBalance> NE '' THEN
* CI_10008394 - S/E
* CI_10014007 -S         TEXT = "(": CQ$CHEQUE.ACC.ID :")" : "AC.RTN.CIO.ACC.DEBIT.BAL"
        EB.SystemTables.setText("AC.RTN.CIO.ACC.DEBIT.BAL":@FM:CQ.ChqIssue.getCqChequeAccId())
* CI_10014007 -E
        GOSUB DO.OVERRIDE
    END


    NOT.OK = 0
    COUNT.CODES = DCOUNT(EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode),@VM)
    CHARGE.CODE.ARRAY = CQ.ChqIssue.getCqChargeCodeArray()
    COUNT.CODES.DEFAULT = DCOUNT(CHARGE.CODE.ARRAY,@FM)
    IF COUNT.CODES EQ COUNT.CODES.DEFAULT THEN
        FOR XYZ = 1 TO COUNT.CODES
            LOCATE EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChgCode)<1,XYZ> IN CQ.ChqIssue.getCqChargeCodeArray()<1> SETTING CODES.POS ELSE
                NOT.OK = 1
            END
        NEXT XYZ
    END ELSE
        NOT.OK = 1
    END

    IF NOT.OK THEN
        EB.SystemTables.setText("AC.RTN.CIO.CHG.NOT.EQ.DEF.CHG")
        GOSUB DO.OVERRIDE
    END

    CHQ.STS.REC= '' ; STS.ERR = ''
    CHQ.STATUS = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)
    CHQ.STS.REC = CQ.ChqConfig.ChequeStatus.Read(CHQ.STATUS, STS.ERR)

    CLASS.TYPE.DEFAULT = CHQ.STS.REC<CQ.ChqConfig.ChequeStatus.ChequeStsClassType>
    MESSAGE.CLASS.DEFAULT = CHQ.STS.REC<CQ.ChqConfig.ChequeStatus.ChequeStsMessageClass>

    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsClassType) NE CLASS.TYPE.DEFAULT THEN
        EB.SystemTables.setText("AC.RTN.CIO.CLS.TYP.NE.DEF.CLS.TYP"); * CI_10026744 S/E
        GOSUB DO.OVERRIDE
    END
    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsMessageClass) NE MESSAGE.CLASS.DEFAULT THEN
        EB.SystemTables.setText("AC.RTN.CIO.MSG.CLS.NE.DEF.MSG.CLS"); * CI_10026744 S/E
        GOSUB DO.OVERRIDE
    END
* EN_10000101 -e

** GLOBUS_EN_10000353 -S

* IF MIN.HOLD IS GREATER THAN NUMBER ISSUED THEN PROMPT AN OVERRIDE

    tmp.ID.NEW = EB.SystemTables.getIdNew()
    CHQ.TYP.ID = FIELD(tmp.ID.NEW,".",1)
    CHQ.TYP.REC = CQ.ChqConfig.ChequeType.Read(CHQ.TYP.ID, CHQ.TYP.ERR)

    MIN.HOLD = CHQ.TYP.REC<CQ.ChqConfig.ChequeType.ChequeTypeMinHolding>
    IF EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued) THEN       ; **CI_10019026 S/E
        IF MIN.HOLD GE EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued) THEN
            EB.SystemTables.setText("AC.RTN.CIO.NUM.ISS.LT.MIN.HOLDGS")
            EB.SystemTables.setAf(CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued); EB.SystemTables.setAv(""); EB.SystemTables.setAs("")
            GOSUB DO.OVERRIDE
        END
    END                                ; *CI_10019026 S/E
** GLOBUS_EN_10000353 -E
RETURN
*-----------(Process.OverRides)


*-----------------------------------------------------------------------------------------
PROCESS.MSG:

RETURN
*-----------(Process.Msg)

*-----------------------------------------------------------------------------------------
DO.OVERRIDE:
*-----------
    EB.OverrideProcessing.StoreOverride(CURR.NO)
    IF EB.SystemTables.getText() = 'NO' THEN
        GOTO PROGRAM.ABORT
    END

RETURN
*-----------(Do.OverRide)



*-----------------------------------------------------------------------------------------
INITIALISE:
*----------
    APP.CODE = ""                      ; * Set to product code ; e.g FT, FX
    ACCT.OFFICER = ""                  ; * Used in call to EXCEPTION. Should be relevant A/O
    EXCEP.CODE = ""

    CURR.NO = 0
    EB.OverrideProcessing.StoreOverride(CURR.NO)

RETURN
*-----------(Initialise)


*-----------------------------------------------------------------------------------------
EXCEPTION.MESSAGE:
*-----------------
    APP.NAME = EB.SystemTables.getApplication()
    FILE.NAME = EB.SystemTables.getFullFname()
    tmp.V = EB.SystemTables.getV()
    CURR.NO = EB.SystemTables.getRNew(tmp.V-7)
    ID = EB.SystemTables.getIdNew()
    EB.ErrorProcessing.ExceptionLog("U",APP.CODE,APP.NAME,APP.NAME,EXCEP.CODE,"",FILE.NAME,ID,CURR.NO,EXCEP.MESSAGE,ACCT.OFFICER)

RETURN
*-----------(Exception.Message)

*-----------------------------------------------------------------------------------------
PROGRAM.ABORT:
*-------------
* If the user said no, get the hell out...

RETURN TO PROGRAM.ABORT

RETURN
*-----------(Program.Abort)


*-----------------------------------------------------------------------------------------
END
*-----(End of routine Cheque.Issue.Override)
