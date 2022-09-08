* @ValidationCode : MjotMjE0NjAxMzYxMTpDcDEyNTI6MTU2NDU3MDg5Mjc5NDpzcmF2aWt1bWFyOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:31:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CQ.ChqEnquiry
    SUBROUTINE E.EOD.REORDER(YID.LIST)
*
*****************************************************************
* 23/10/01 - GLOBUS_BG_100000159
*            Inclusion of Stopped.cheque in YID.LIST
*
* 06/03/07 - EN_10003213
*            No of stopped cheques and Unused cheques should be displayed
*            correctly based on auto reorder type in CHEQUE.TYPE
*
* 06/03/07 - EN_10003187
*            Data Access Service - Application changes
*
* 05/01/12 - Task 334563
*            While running the enquiry, it is getting time out. So, changing
*            the F.READ to CACHE.READ to improve the performance.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Enquiry as ST_ChqEnquiry and include $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
****************************************************************************
*
    $USING CQ.ChqIssue
    $USING CQ.ChqConfig 
    $USING CQ.ChqFees
    $USING CQ.ChqSubmit
    $USING AC.AccountOpening
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.DataAccess
    $INSERT I_DAS.CHEQUE.ISSUE          ;* EN_10003187 S/E


    LOCATE 'ST.DATE' IN EB.Reports.getDFields()<1> SETTING POS ELSE
    POS = ''
    END
    LOCATE 'END.DATE' IN EB.Reports.getDFields()<1> SETTING POS1 ELSE
    POS1= ''
    END
    DATE1 = EB.Reports.getDRangeAndValue()<POS>
    DATE2 = EB.Reports.getDRangeAndValue()<POS1>
    IF DATE1 = '' THEN
        DATE1= EB.SystemTables.getToday()
    END
    IF DATE2 = '' THEN
        DATE2 = EB.SystemTables.getToday()
    END

* EN_10003187 S
    THE.LIST = DAS.CHEQUE.ISSUE$STATUS
    EB.DataAccess.Das("CHEQUE.ISSUE",THE.LIST,'','')

    SEL.LIST = THE.LIST
* EN_10003187 E

    LOOP
        REMOVE CHQ.ID FROM SEL.LIST SETTING MORE
    WHILE CHQ.ID : MORE
        CHQ.REC = CQ.ChqIssue.ChequeIssue.Read(CHQ.ID, ERR2)
        CHQ.CHR.REC = CQ.ChqFees.ChequeChargeBal.Read(CHQ.ID, ERR3)
        CHEQ.TYP.ID = FIELD(CHQ.ID,".",1)
        CHEQ.TYP.REC = CQ.ChqConfig.ChequeType.CacheRead(CHEQ.TYP.ID, ERR4)
        CNT = DCOUNT(CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalStatusDate>,@VM)
        FOR I = 1 TO CNT
            IF CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalStatusDate,I> GE DATE1 AND DATE2 = '' THEN
                RETURN
            END
            IF (CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalStatusDate,I> GE DATE1)  AND (CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalStatusDate,I> LE DATE2 ) THEN
                IF (CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalChequeStatus,I> EQ CHQ.REC<CQ.ChqIssue.ChequeIssue.ChequeIsChequeStatus>) AND (CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalChequeStatus, I> EQ CHEQ.TYP.REC<CQ.ChqConfig.ChequeType.ChequeTypeRequestStatus>) THEN
                    GOSUB FORM.YID.LIST
                END
            END
        NEXT I
    REPEAT
    RETURN

FORM.YID.LIST:

    ACCT.NO = FIELD(CHQ.ID,".",2)
    R.ACCOUNT = AC.AccountOpening.Account.Read(ACCT.NO,ER)
    ACCT.NAME = R.ACCOUNT<AC.AccountOpening.Account.AccountTitleOne>
    CUST.NO = R.ACCOUNT<AC.AccountOpening.Account.Customer>
    CHQ.TYP.ACCT = FIELD(CHQ.ID,".",1,2)
    CHEQ.REG.REC = CQ.ChqSubmit.ChequeRegister.Read(CHQ.TYP.ACCT, ERR5)
    ISS.CHQ = CHEQ.REG.REC<CQ.ChqSubmit.ChequeRegister.ChequeRegIssuedToDate>
    USED.CHQ = CHEQ.REG.REC<CQ.ChqSubmit.ChequeRegister.ChequeRegUsedToDate>
    RET.CHQ = CHEQ.REG.REC<CQ.ChqSubmit.ChequeRegister.ChequeRegReturnedChqs>
* EN_10003213 S
    STOP.RET= ''
* Stopped and returned cheques should be considered when
* Auto reorder type is ""
    IF CHEQ.TYP.REC<CQ.ChqConfig.ChequeType.ChequeTypeAutoReorderType> = '' THEN
        STOP.RET = CHEQ.REG.REC<CQ.ChqSubmit.ChequeRegister.ChequeRegStoppedChqs> + DCOUNT(RET.CHQ,@VM)

    END
    UNUSED.CHQS = ISS.CHQ - USED.CHQ - STOP.RET

    STOP.CHQ =  CHEQ.REG.REC<CQ.ChqSubmit.ChequeRegister.ChequeRegStoppedChqs>
    YID.LIST<-1> = CUST.NO:'*':ACCT.NO:'*':ACCT.NAME:'*':CHEQ.TYP.ID:'*':UNUSED.CHQS:'*':STOP.RET
    RETURN
    END
