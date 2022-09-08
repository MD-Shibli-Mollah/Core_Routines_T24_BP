* @ValidationCode : MjotODE1NTMxNTM6Q3AxMjUyOjE1NjE3MDAwMzcwMzA6anByaXlhZGhhcnNoaW5pOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDUzMS0wMzE0Oi0xOi0x
* @ValidationInfo : Timestamp         : 28 Jun 2019 11:03:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jpriyadharshini
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank
  
SUBROUTINE E.MB.CHEQUE.STATUS(RET.DATA)
*-----------------------------------------------------------------------------
* This is a nofile routine that is attached to an arc query to return all the
* details of all the cheques pertaining to the account
*-----------------------------------------------------------------------------
* MODIFICATIONS
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 24/06/19 - Enhancement 3186772 / Task 3186773
*            Product Installation Check for CQ.
*-----------------------------------------------------------------------------

    $INSERT I_DAS.CHEQUES.STOPPED
    $INSERT I_DAS.CHEQUES.PRESENTED
    $INSERT I_DAS.CHEQUE.REGISTER

    $USING CQ.ChqSubmit
    $USING EB.Reports
    $USING CQ.ChqPaymentStop
    $USING EB.DataAccess
    $USING EB.API

    GOSUB CHECK.CQ.INSTALLED
    
    IF NOT(CQInstalled) THEN
        RETURN
    END
    
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB GET.ACCT.NO
    GOSUB PROCESS.CHQ.PRESENTED
    GOSUB PROCESS.CHQ.RETURNED
    GOSUB PROCESS.CHQ.STOPPED

RETURN

*-----------------------------------------------------------------------------
INITIALISE:
*-----------------------------------------------------------------------------
*Initialise all the variables

    NO.OF.RECS = ''
    ERR = ''
    ACCOUNT.NO = ''
    CHQ.PRNT.LIST = ''
    CHQ.NO = '';CHQ.TYPE = ''

    CHQ.PRNT.STATUS = "1"
    CHQ.RET.STATUS = "2"
    CHQ.STOP.STATUS = "3"
    THE.REG.ARGS = ''
    THE.PRE.ARGS = ''
    PRNT.ID = ''
RETURN

*-----------------------------------------------------------------------------
OPEN.FILES:
*-----------------------------------------------------------------------------
*Open all the required files


RETURN

*-----------------------------------------------------------------------------
GET.ACCT.NO:
*-----------------------------------------------------------------------------
* fetch the account number
    LOCATE 'ACCOUNT.NO' IN EB.Reports.getDFields()<1> SETTING ACCT.POS ELSE NULL
    ACCOUNT.NO = EB.Reports.getDRangeAndValue()<ACCT.POS>
RETURN

*-----------------------------------------------------------------------------
PROCESS.CHQ.PRESENTED:

*-----------------------------------------------------------------------------
*determine all the presented  cheques and if found append them to the returning array

    THE.PRE.ARGS = ACCOUNT.NO
    THE.PRE.LIST = DAS.CHEQUES.PRESENTED$ACCT
    EB.DataAccess.Das("CHEQUES.PRESENTED",THE.PRE.LIST,THE.PRE.ARGS,'')
    PRESENTED.LIST = THE.PRE.LIST

    LOOP
        REMOVE PRNT.ID FROM PRESENTED.LIST SETTING PRNT.POS
    WHILE PRNT.ID : PRNT.POS
        R.CP.PRNT = CQ.ChqSubmit.tableChequesPresented(PRNT.ID,ERR.CP)
        GOSUB APPEND.CHQ.PRESENTED
    REPEAT
RETURN

*-----------------------------------------------------------------------------
APPEND.CHQ.PRESENTED:
*-----------------------------------------------------------------------------

*Append the cheques presnted details to returning array

    IF ERR.CP EQ '' THEN
        CHQ.TYPE = FIELD(PRNT.ID, ".", 1)
        CHQ.NO = FIELD(PRNT.ID, "-", 2)
        RET.DATA<-1> = CHQ.TYPE:"*":CHQ.NO:"*":CHQ.PRNT.STATUS:"*":ACCOUNT.NO
    END
RETURN


*-----------------------------------------------------------------------------
PROCESS.CHQ.RETURNED:
*-----------------------------------------------------------------------------
* Determine all the returned cheques and if found append them to the returning array

    THE.REG.ARGS = ACCOUNT.NO
    THE.REG.LIST = DAS.CHEQUE.REGISTER$ACCOUNT
    EB.DataAccess.Das("CHEQUE.REGISTER",THE.REG.LIST,THE.REG.ARGS,'')
    RETURNED.LIST = THE.REG.LIST

    LOOP
        REMOVE RET.CHQ FROM RETURNED.LIST SETTING RET.POS
    WHILE RET.CHQ : RET.POS
        R.CHQ.RET = CQ.ChqSubmit.tableChequeRegister(RET.CHQ, ERR.CS)
        IF ERR.CS EQ '' THEN
            CHQ.RET.TYPE = FIELD(RET.CHQ, ".", 1)
            CHQ.RET.NO = R.CHQ.RET<CQ.ChqSubmit.ChequeRegister.ChequeRegReturnedChqs>
            GOSUB CHECK.CHQ.RET
        END

    REPEAT
RETURN

*-----------------------------------------------------------------------------
CHECK.CHQ.RET:

*-----------------------------------------------------------------------------
*Check for the field "Cheque returned"
    IF CHQ.RET.NO NE '' THEN
        NO.OF.RET.CHQS = DCOUNT(CHQ.RET.NO,@VM)
        IF NO.OF.RET.CHQS GT '1' THEN
            CONVERT @VM TO "," IN CHQ.RET.NO
        END
        RET.DATA <-1> = CHQ.RET.TYPE:"*":CHQ.RET.NO:"*":CHQ.RET.STATUS:"*":ACCOUNT.NO
    END
RETURN

*-----------------------------------------------------------------------------
APPEND.CHQ.STOP:
*-----------------------------------------------------------------------------
*Append the cheques stopped to the returning array

    IF ERR.STP = '' THEN
        CHQ.STP.TYPE = R.CHQ.STP<CQ.ChqPaymentStop.ChequesStopped.ChqStpChqTyp>
        CHQ.STP.NO = FIELD(STP.CHQ,"*",2)
        RET.DATA<-1> = CHQ.STP.TYPE:"*":CHQ.STP.NO:"*":CHQ.STOP.STATUS:"*":ACCOUNT.NO
    END
RETURN


*-----------------------------------------------------------------------------
PROCESS.CHQ.STOPPED:
*-----------------------------------------------------------------------------
*determine all the stopped cheques and if found append them to the returning array

    THE.ARGS = ACCOUNT.NO
    THE.LIST = DAS.CHEQUES.STOPPED$ACCOUNT
    EB.DataAccess.Das("CHEQUES.STOPPED",THE.LIST,THE.ARGS,'')
    STOPPED.LIST = THE.LIST

    LOOP
        REMOVE STP.CHQ FROM STOPPED.LIST SETTING STP.POS
    WHILE STP.CHQ : STP.POS
        R.CHQ.STP = CQ.ChqPaymentStop.tableChequesStopped(STP.CHQ,ERR.STP)
        GOSUB APPEND.CHQ.STOP
    REPEAT

RETURN
*-----------------------------------------------------------------------------
CHECK.CQ.INSTALLED:
*-----------------------------------------------------------------------------
    
    productId = 'CQ'
    CQInstalled = ''
    EB.API.ProductIsInCompany(productId, CQInstalled)
RETURN
*-----------------------------------------------------------------------------
END
