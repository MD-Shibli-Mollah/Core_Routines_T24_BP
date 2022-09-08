* @ValidationCode : MjotMTEzNTYxODMzNDpDcDEyNTI6MTU4MzkyOTIxNjI3MTpydmFyYWRoYXJhamFuOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Mar 2020 17:50:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>93</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqSubmit
SUBROUTINE EOD.CHEQUE.REORDER(CHQ.REG.ID)

*----------------------------------------------------------------------------------
*  EOD job process to reorder cheque.issue request if Used.To.Date (in Chque.Register)
*  is less than or equal to Min.Holding (in Cheque.Type). A new request will be made
*  with the status equal to in Request.Status field in Cheque.Type.
*
*  This new request will be made only if
*     (a) Auto.Request is 'YES' in Cheque.Type          and
*     (b) Cheque.Issue does not have a record with less than 90
*
*  Input Parameter - Cheque.Register.ID
*
* 22/10/01 - GLOBUS_CI_10000413
*            No updation of cheque.issue.account & cheque.register records
*            for status # 90.
*
* 23/10/01 - GLOBUS_BG_100000159
*            - Charges are debited to cheque issue account and not to charge account
*            - Changed variable EXCH.RATE to CQ$EXCH.RATE
*            - Reading cheque.type & cheque.charge record correctly for the given cheque type
*
* 14/02/02 - GLOBUS_EN_10000353
*            Enhancement for stock control
*            If AUTO.CHEQUE.NUMBER is populated and not equal to REQUESTED
*            read for that cheque number in CHEQUES.PRESENTED. If foound set
*            a found flag. If the AUTO.CHEQUE.NUMBER field has more than
*            1 value delete the entry. If AUTO.CHEQUE.NUMBER has only one enty
*            replace with 'REQUESTED'.
*            If AUTO.CHEQUE.NUMBER is not populated get NO.HELD and if NO.HELD
*            LE MIN.HOLDING set found flag. If found.flag find out the lastest
*            cheque issue record and if the status is not requested then
*            create a new cheque issue record with status equal to requested.
*
* 15/04/02 - GLOBUS_BG_100000887
*            Bug fixes in STOCK control application.
* 10/01/03 - GLOBUS_BG_10003164
*            Common variables CT.ID.LIST and CI.ID.LIST are loaded
*
* 22/03/04 - CI_10018333
*            Do not process new cheque issue when the NO.HELD -
*            in cheque register is greater than
*            MIN.HOLDING in cheque.type
*
* 16/09/04 - BG_100007243
*            Call to F.READ of CHEQUE.TYPE,CHEQUE.ISSUE and CHEQUE.REGISTER has been replaced
*            by CACHE.READ to improve performance.
*
* 07/02/07 - EN_10003189
*            When LAST.EVENT.SEQ of CHEQUE.REGISTER reaches 99999, no new cheque issue record
*            is being allowed to input.
*
* 20/02/07 - EN_10003213
*            The file EOD.CHQ.LIST is no longer being used. PRE.PROCESS routine will check all
*            the conditions and if the conditions satisfy then will return the id. If it
*            returns NULL then no processing will be carried out. The .LIST and .DESC
*            common variables are assigned in PRE.PROCESS routine. If AUTO.REORDER.TYPE is
*            "" then apart from checking CHEQUES.PRESENTED, CHEQUES.STOPPED and
*            RETURNED.CHEQUES are also checked to see if the cheque number is being used
*            anywhere.
*
*
* 01/07/09 - CI_10064156
*            Performance issue
*            1. Repetitive reads on CHEQUE.TYPE, CHEQUE.REGISTER and CHEQUE.CHARGE removed.
*            2. CHARGE processing to be removed when no chg.code is found to do the cheque issue charges.
*            3. CHARGE accounting is also to be skipped if no charge code found.
*
* 30/06/10 - D-60989 / T-63037
*            Lock in CHEQUE.REGISTER makes other sessions time out during OFS bulk clearing
* 22/10/10 - Task - 84420
*            Replace the enterprise(customer service api)code into  Banking framework related
*            routines which reads CUSTOMER.
*
* 31/01/11 - 120329
*            Banker's Draft Management.
*            CHEQUE.REGISTER.SUPPLEMENT is table is used instead of CHEQUES.PRESENTED.
*
* 08/08/11 - Task 257419
*            Performance issue
*            1.Instead of F.READ on CHEQUE.STATUS have used CACHE.READ
*            2.Instead of CACHE.READ on CHEQUE.ISSUE have used F.READ.
*
* 12/01/12 - Task 335791
*            Change the reads to Service api calls.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Submit as ST_ChqSubmit and include $PACKAGE
*
* 16/10/15 - Enhancement 1265068/ Task 1504013
*          - Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
* 31/01/20 - Enhancement 3367949 / Task 3565098
*            Check CG module availability for charges
*
*----------------------------------------------------------------------------------

    $USING CQ.ChqIssue
    $USING CQ.ChqConfig
    $USING CQ.ChqFees
    $USING AC.AccountOpening
    $USING ST.Customer
    $USING EB.Security
    $USING CG.ChargeConfig
    $USING ST.CurrencyConfig
    $USING EB.TransactionControl
    $USING AC.API
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING CQ.ChqSubmit
    CHECK.ID = '' ; CHECK.ID = CHQ.REG.ID         ;* EN_10003213 - S
    CQ.ChqSubmit.EodChequeReorderPreProcess(CHECK.ID)
    IF CHECK.ID = '' THEN
        RETURN
    END   ;* EN_10003213 - E

    DIM CHQ.REC(CQ.ChqIssue.ChequeIssue.ChequeIsAuditDateTime)
    DIM R.NEW.REC(EB.SystemTables.SysDim)
    MAT R.NEW.REC = ''
    MAT CHQ.REC = ''
    GOSUB RAISE.CHEQUE.REQUEST          ;* Raise a request if request is not been made

RETURN
*----------- (Main.Process)


*-----------------------------------------------------------------------------
RAISE.CHEQUE.REQUEST:
*--------------------
    FOUND.FLAG =''
*     Get Cheque.Issue ID sequence from Cheque.Register

    CHQ.TYPE = FIELD(CHQ.REG.ID,".",1)

    CQ.ChqSubmit.setAutoReorderTyp(CQ.ChqSubmit.getChqTypRec()<CQ.ChqConfig.ChequeType.ChequeTypeAutoReorderType>)
    MIN.HOLD = CQ.ChqSubmit.getChqTypRec()<CQ.ChqConfig.ChequeType.ChequeTypeMinHolding>
    ALLOW.FCY = CQ.ChqSubmit.getChqTypRec()<CQ.ChqConfig.ChequeType.ChequeTypeAllowFcyAcct>
    IF CQ.ChqSubmit.getAutoReorderTyp() THEN
        FOUND.FLAG = 0

        AUTO.CHQ.CNT = DCOUNT(CQ.ChqSubmit.getChqRegRec()<CQ.ChqSubmit.ChequeRegister.ChequeRegAutoChequeNo>,@VM)
        IF AUTO.CHQ.CNT EQ 0 AND CQ.ChqSubmit.getAutoReorderTyp() NE "CHEQUE.NUMBER" THEN
**CI_10018333 S
            NO.HELD = CQ.ChqSubmit.getChqRegRec()<CQ.ChqSubmit.ChequeRegister.ChequeRegNoHeld>
            IF NO.HELD GT MIN.HOLD THEN
                RETURN
            END
**CI_10018333 E
        END ELSE
            AUTO.CHQ.NO = CQ.ChqSubmit.getChqRegRec()<CQ.ChqSubmit.ChequeRegister.ChequeRegAutoChequeNo><1,1>

            FOR I.CNT = 1 TO AUTO.CHQ.CNT
                AUTO.CHQ.NO = CQ.ChqSubmit.getChqRegRec()<CQ.ChqSubmit.ChequeRegister.ChequeRegAutoChequeNo><1,I.CNT>
                IF AUTO.CHQ.NO NE "REQUESTED" THEN

                    CRS.ID = CHQ.REG.ID:".":AUTO.CHQ.NO
                    R.CHEQ.REG.SUPP = CQ.ChqSubmit.ChequeRegisterSupplement.Read(CRS.ID, ER)
                    IF R.CHEQ.REG.SUPP<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsStatus> EQ 'PRESENTED' OR R.CHEQ.REG.SUPP<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsStatus> EQ 'CLEARED' THEN
                        FOUND.FLAG = 1
                        EXIT  ;* exit the loop if any of the auto.cheque.no is presented
                    END
                END ELSE
                    RETURN
                END
            NEXT I.CNT
            IF FOUND.FLAG THEN
                tmp=CQ.ChqSubmit.getChqRegRec(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegAutoChequeNo>=""; CQ.ChqSubmit.setChqRegRec(tmp)
                tmp=CQ.ChqSubmit.getChqRegRec(); tmp<CQ.ChqSubmit.ChequeRegister.ChequeRegAutoChequeNo,-1>="REQUESTED"; CQ.ChqSubmit.setChqRegRec(tmp)
                REG.REC = CQ.ChqSubmit.getChqRegRec()
                CQ.ChqSubmit.ChequeRegister.Write(CHQ.REG.ID, REG.REC)
            END
        END
    END   ;* GLOBUS_BG_100000887

    IF CQ.ChqSubmit.getAutoReorderTyp() EQ "CHEQUE.NUMBER" AND NOT(FOUND.FLAG) THEN
        RETURN      ;* GLOBUS_BG_100000887
    END

* filter conditions

    LAST.EVENT.SEQ = CQ.ChqSubmit.getChqRegRec()<CQ.ChqSubmit.ChequeRegister.ChequeRegLastEventSeq> +1
    CQ.ChqSubmit.setNewSeq(FMT(LAST.EVENT.SEQ, '7"0"R'));* EN_10003189 - S
    NEW.SEQ.VAL = CQ.ChqSubmit.getNewSeq()
    IF NOT(NUM(NEW.SEQ.VAL)) THEN
        GOSUB WRITE.EXCEPTION.LOG
        RETURN
    END   ;* EN_10003189 - E
    CQ.ChqSubmit.setNewId(CHQ.REG.ID:'.':CQ.ChqSubmit.getNewSeq())

* A read on the account is moved to EOD.CHEQUE.REORDER.PRE.PROCESS
*     If Cheque.Type.Allow.Fcy.Acct = 'NO' and Account.Currency not equal to LCCY,
*     do not raise cheque request and charge entries
    IF (ALLOW.FCY = 'NO')  AND ( CQ.ChqSubmit.getYrTwoAccount()<AC.AccountOpening.Account.Currency> NE EB.SystemTables.getLccy())  THEN
        RETURN
    END

*     Check if Cheque can be issued to this customer
*     If Cheque>Chq.Is.Restrict = 'NO' then do not issue cheque
    CQ.ChqSubmit.setIssue('')
    customerKey = CQ.ChqSubmit.getYrTwoAccount()<AC.AccountOpening.Account.Customer>
    fieldName = "ISSUE.CHEQUES"
    fieldNumber = ST.Customer.Customer.EbCusIssueCheques
    fieldOption = ''
    dataField = ''
    CALL CustomerService.getProperty(customerKey, fieldName, fieldNumber, fieldOption, dataField)
    CQ.ChqSubmit.setIssue(dataField)
    IF CQ.ChqSubmit.getIssue() EQ 'NO' THEN
        RETURN      ;* Return & do not raise cheque request
    END

*     Read Cheque.Charge Record
    CHG.REC = CQ.ChqFees.ChequeCharge.CacheRead(CHQ.TYPE, CC.READ.ERR) ;*BG_100007243 S
    CHG.REC = CQ.ChqSubmit.getChqChgRec()
    CHRG.ACCT = CQ.ChqSubmit.getChequeAccId()
    CQ.ChqSubmit.setYrAccount(CQ.ChqSubmit.getYrTwoAccount())
    ACCT.CURR = CQ.ChqSubmit.getYrAccount()<AC.AccountOpening.Account.Currency>
*  If currency of Yr.Account is not lccy then set the exch.rate
    IF CQ.ChqSubmit.getYrAccount()<AC.AccountOpening.Account.Currency> NE EB.SystemTables.getLccy() THEN
        GOSUB GET.EXCH.RATE
    END ELSE
* BG_100000159 -s
*         EXCH.RATE = ''                  ; * BG_100000159 - commented
        tmp=CQ.ChqIssue.getCqExchRate(); tmp<1>=''; CQ.ChqIssue.setCqExchRate(tmp)
        tmp=CQ.ChqIssue.getCqExchRate(); tmp<4>=''; CQ.ChqIssue.setCqExchRate(tmp)
* BG_100000159 - e
    END

* Read Cheque.Issue and Write with new issue values
    CHQ.ISS.ID = CQ.ChqSubmit.getNewId()
    CHQ.IS.REC = CQ.ChqIssue.ChequeIssue.Read(CHQ.ISS.ID, CI.READ.ERR)
* Update Record
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsIssueDate> = ''
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsNumberIssued> = ''
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsCurrency> = CQ.ChqSubmit.getYrAccount()<AC.AccountOpening.Account.Currency>
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsCharges> = ''
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChargeDate> = ''
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus> = CQ.ChqSubmit.getChqTypRec()<CQ.ChqConfig.ChequeType.ChequeTypeRequestStatus>

*     Select Cheque.Charge IDs and Charges List

    REQ.STS = CQ.ChqSubmit.getChqTypRec()<CQ.ChqConfig.ChequeType.ChequeTypeRequestStatus>
    LOCATE REQ.STS IN CQ.ChqSubmit.getChqChgRec()<CQ.ChqFees.ChequeCharge.ChequeChgChequeStatus,1> SETTING JSH.POS THEN
        CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChgCode> = RAISE(CQ.ChqSubmit.getChqChgRec()<CQ.ChqFees.ChequeCharge.ChequeChgChargeCode><1,JSH.POS>)
    END ELSE
        CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChgCode> = ''
    END
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount> = ''
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode> = ''
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt> = ''
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsWaiveCharges> = 'NO'
    
* Build charge array, prepare accounting only if charge code is found
    IF CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChgCode> THEN
        GOSUB CHECK.CHRG.CODE
        GOSUB PREPARE.ACCOUNTING.ENTRIES

* Reinit Charges
        CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChgCode> = ''
        CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount> = ''
        CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode> = ''
        CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt> = ''
    END
* Write Cheque.Issue, Cheque.Register, Cheque.Issue.Account Records
    GOSUB WRITE.CHEQUE.RECORDS
    RUNNING.UNDER.BATCH.VAL = EB.SystemTables.getRunningUnderBatch()
    IF NOT(RUNNING.UNDER.BATCH.VAL) THEN
        EB.TransactionControl.JournalUpdate('EOD.CHEQUE.REORDER')
    END

*    END                                ; * GLOBUS_EN_10000353

RAISE.CHEQUE.REQUEST.EXIT:
*-------------------------
RETURN
*-----------(Raise.Cheque.Request)


*-----------------------------------------------------------------------------
WRITE.CHEQUE.RECORDS:
*--------------------
*     Write into Cheque.Issue and Cheque.Issue.Account
*     Update audit fields
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsCurrNo> = 1
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsInputter> = EB.SystemTables.getTno():"_EOD.REORDER"
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsAuthoriser> = EB.SystemTables.getTno():"_EOD.REORDER"
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsCoCode> = EB.SystemTables.getIdCompany()
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsDeptCode> = EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>
    EB.SystemTables.setTimeStamp(TIMEDATE())
    CQ.ChqSubmit.setJX(OCONV(DATE(),"D-"))
    CQ.ChqSubmit.setDt(CQ.ChqSubmit.getJX()[9,2]:CQ.ChqSubmit.getJX()[1,2]:CQ.ChqSubmit.getJX()[4,2]:EB.SystemTables.getTimeStamp()[1,2]:EB.SystemTables.getTimeStamp()[4,2])
    CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsDateTime> = CQ.ChqSubmit.getDt()
    CHQ.ISS.ID = CQ.ChqSubmit.getNewId()
    CQ.ChqIssue.ChequeIssueWrite(CHQ.ISS.ID,CHQ.IS.REC,'')

RETURN
*-----------------------------------------------------------------------------
CHECK.CHRG.CODE:
*---------------
    CNT.CHRG = DCOUNT(CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChgCode>,@VM)
    CQ.ChqIssue.setCqJCharges(''); J.CHARGE.DATE = '' ; J.TTL.CHARGES = 0 ; J.TTL.TAX = 0
    BUILD.ENTRY = ''
    CHG.DATA= ''
    CQ.ChqIssue.setCqCustCond('')
    EXCH.RATE = ''
*  Initialise Tax details from R.NEW
    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode, '')
    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt, '')

    FOR CNT = 1 TO CNT.CHRG
        CHG.DATA<1,CNT> = CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChgCode,CNT>
        CHG.DATA<2,CNT> = ''

        EXCH.RATE<1,CNT> = CQ.ChqIssue.getCqExchRate()<1>
        EXCH.RATE<4> = CQ.ChqIssue.getCqExchRate()<4>
    NEXT CNT

    ACT.CUST = CQ.ChqSubmit.getYrAccount()<AC.AccountOpening.Account.Customer>
    ACT.CURR = CQ.ChqSubmit.getYrAccount()<AC.AccountOpening.Account.Currency>

* CALCULATE.CHARGE currently doesn't return the tax amt in LCY correctly when an
* userdefined EXCH rate is passed.  It is calculated with MID rate at present.
    CURR.MKT = CQ.ChqSubmit.getCcyMkt()
    CG.ChargeConfig.CalculateCharge(ACT.CUST, '', ACT.CURR, CURR.MKT, EXCH.RATE, '', ACT.CURR, CHG.DATA, '', '', '')
    CQ.ChqSubmit.setCcyMkt(CURR.MKT)

    CQ.ChqIssue.setCqChgData(CHG.DATA)
    CNT.CHRG = DCOUNT(CHG.DATA<2>,@VM)
    T.CNT = 1
    C.CNT = 1
    FOR CNT = 1 TO CNT.CHRG

        IF ACCT.CURR EQ EB.SystemTables.getLccy() THEN
            IF CHG.DATA<2,CNT> EQ 'TAX' THEN
                CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt,T.CNT> = CHG.DATA<4,CNT>
                CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode,T.CNT> = CHG.DATA<1,CNT>
                T.CNT += 1
            END ELSE
                CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount,C.CNT> = CHG.DATA<4,CNT>
                C.CNT += 1
            END
        END ELSE
            IF CHG.DATA<2,CNT> EQ 'TAX' THEN
                CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsTaxAmt,T.CNT> = CHG.DATA<5,CNT>
                CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsTaxCode,T.CNT> = CHG.DATA<1,CNT>
                T.CNT += 1
            END ELSE
                CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount,C.CNT> = CHG.DATA<5,CNT>
                C.CNT += 1
            END
        END

    NEXT CNT


RETURN
*-----------(Check.Chrg.Code)



*-----------------------------------------------------------------------------
PREPARE.ACCOUNTING.ENTRIES:
*--------------------------
    YR.MULTI.STMT = ''
    STMT.ENTRY.REC = ''
    LCY.AMT = ''
    ACCOUNT.IND = ''

*     Build Array for Additional Charges
    IF CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChgAmount> THEN
        GOSUB BUILD.ADDNL.CHARGE.ENTRIES
        ACCOUNT.IND = 1
    END

    EB.SystemTables.setDynArrayToRNew(CHQ.IS.REC)
    EB.SystemTables.setV(CQ.ChqIssue.ChequeIssue.ChequeIsAuditDateTime)

    IF ACCOUNT.IND THEN
        CRT 'Accounting : ' : CQ.ChqSubmit.getNewId() : '<----'
        AC.API.EbAccounting('CC', 'SAO', YR.MULTI.STMT, '')
    END

*     Update Cheque.Charge.Bal with charges collected
    R.REC = EB.SystemTables.getDynArrayFromRNew()
    MATPARSE R.NEW.REC FROM R.REC
    CQ.ChqIssue.setCqFunction('EOD')
    REC.ID = CQ.ChqSubmit.getNewId()
    CQ.ChqFees.ChequeChargeBalUpdate(REC.ID, MAT R.NEW.REC, CHRG.ACCT, ACCT.CURR)
    CQ.ChqSubmit.setNewId(REC.ID)
    MATBUILD R.REC FROM R.NEW.REC
    EB.SystemTables.setDynArrayToRNew(R.REC)
*     Delivery Messages

    CH.STS = EB.SystemTables.getRNew(CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus)

    ISSUE.REC = CQ.ChqIssue.ChequeIssue.CacheRead(CH.STS, REC.ERR)
    CQ.ChqSubmit.setChqStsRec(ISSUE.REC)
    CQ.ChqSubmit.setCsErr(REC.ERR)
    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsClassType, CQ.ChqSubmit.getChqStsRec()<CQ.ChqConfig.ChequeStatus.ChequeStsClassType>)
    EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsMessageClass, CQ.ChqSubmit.getChqStsRec()<CQ.ChqConfig.ChequeStatus.ChequeStsMessageClass>)

    BAL.CHG.CODE = '' ; BAL.CHG.AMT = '' ; BAL.TAX.AMT = '' ; CHG.DATE = ''
    EB.SystemTables.setIdNew(CQ.ChqSubmit.getNewId())
    CHG.ARRY = CQ.ChqSubmit.getChargeArray()
    CQ.ChqIssue.ChequeIssueDelivChgDets(CHG.ARRY,BAL.CHG.CODE,BAL.CHG.AMT,BAL.TAX.AMT,CHG.DATE)
    CQ.ChqSubmit.setChargeArray(CHG.ARRY)
    IF CQ.ChqSubmit.getChargeArray() THEN
        CHG.ARRY = CQ.ChqSubmit.getChargeArray()
        CQ.ChqIssue.ChequeIssueDelivery(CHG.ARRY)
    END ELSE
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsActivity, '')
        EB.SystemTables.setRNew(CQ.ChqIssue.ChequeIssue.ChequeIsDeliveryRef, '')
    END
    CHQ.IS.REC = EB.SystemTables.getDynArrayFromRNew()

RETURN
*-----------(Prepare.Accounting.Entries)



*----------------------------------------------------------------
BUILD.ADDNL.CHARGE.ENTRIES:
*--------------------------
    CNT.CHG.CODE = DCOUNT(CHQ.IS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChgCode>,@VM)
    BUILD.ENTRY=1
    ACCOUNT.REC =  CQ.ChqSubmit.getYrAccount()
    REC.ID = CQ.ChqSubmit.getNewId()
    MATPARSE CHQ.REC FROM CHQ.IS.REC
    CQ.ChqIssue.ChequeIssueAddnlCharges(CHRG.ACCT, ACCOUNT.REC, MAT CHQ.REC, EXCH.RATE, REC.ID, YR.MULTI.STMT)

RETURN
*-----------(Build.Addnl.Charge.Entries)

*-----------------------------------------------------------------------------
GET.EXCH.RATE:
*-------------
    EXCH.RATE = ''
    CQ.ChqSubmit.setCcyMkt(CQ.ChqSubmit.getChqChgRec()<CQ.ChqFees.ChequeCharge.ChequeChgCurrencyMarket>)
    IF CQ.ChqSubmit.getCcyMkt() EQ '' THEN CQ.ChqSubmit.setCcyMkt(1)
    CQ.ChqSubmit.setRateType(CQ.ChqSubmit.getChqChgRec()<CQ.ChqFees.ChequeCharge.ChequeChgRateType>)

* If Currency market and rate type is not mentioned in cheque.Charge,
* default exch.rate to mid.rate

    JFCY = CQ.ChqSubmit.getYrAccount()<AC.AccountOpening.Account.Currency> : CQ.ChqSubmit.getCcyMkt()
    BEGIN CASE
        CASE CQ.ChqSubmit.getRateType() = 'BUY'
            JRATE.TYPE = 'BUY.RATE'
        CASE CQ.ChqSubmit.getRateType() = 'SELL'
            JRATE.TYPE = 'SELL.RATE'
        CASE 1
            JRATE.TYPE = 'MID.REVAL.RATE'
    END CASE
    EB.SystemTables.setEtext('')
    ST.CurrencyConfig.UpdCcy(JFCY, JRATE.TYPE)

* BG_100000159 -s
*      EXCH.RATE<1> = JRATE.TYPE          ; * BG_100000159 - commented
*      EXCH.RATE<4> = 'Y'                 ; * BG_100000159 - commented

    tmp=CQ.ChqIssue.getCqExchRate(); tmp<1>=JRATE.TYPE; CQ.ChqIssue.setCqExchRate(tmp)
    tmp=CQ.ChqIssue.getCqExchRate(); tmp<4>='Y'; CQ.ChqIssue.setCqExchRate(tmp)
* BG_100000159 -e

GET.EXCH.RATE.EXIT:
RETURN
*------------(Get.Exch.Rate)


*-----------------------------------------------------------------------------
FATAL.ERROR:
*-----------
    EB.ErrorProcessing.FatalError('EOD.CHEQUE.REORDER')

RETURN
*-----------(Fatal.Error)
*-----------------------------------------------------------------------------
* EN_10003189 - S
WRITE.EXCEPTION.LOG:
*-------------------

    EXCEP.MESSAGE = "Exceeded max Sequence no - Cannot issue Reordering"
    ER.FILE.NAME = CQ.ChqSubmit.getFnCi()
    EB.ErrorProcessing.ExceptionLog("S","ST","EOD.CHEQUE.REORDER","CHEQUE.ISSUE","","",ER.FILE.NAME,CHQ.REG.ID,"",EXCEP.MESSAGE,"")

RETURN
* EN_10003189 - E
*-----------(Write in exception log file)

END
*-----(End of Eod.Cheque.Reorder)
