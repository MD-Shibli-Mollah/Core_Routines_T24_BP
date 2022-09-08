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

*-----------------------------------------------------------------------------
* <Rating>69</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MI.AverageBalances
    SUBROUTINE CONV.BOOK.DATE.BALANCE.BUILD
****************************************************************************************
** 31/05/02 - GLOBUS_EN_10000771
** This routine is  called when BUILD.BD.BALANCES field on MI.PARAMETER is
** set to "Yes" and the record authorised. It picks up all the account
** ids from the ACCOUNT file which has a balance and writes OPENING AND CLOSING
** Balances to BOOK.DATED.BALANCE file
*
*01/08/08 - EN_10003635
*             Since updates to OPEN.CLEARED.BAL has been made optional in ACCOUNT.PARAMETER,
*           Access to OPEN.CLEARED.BAL has been removed and replaced with ONLINE.CLEARED.BAL.
*
*
****************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.MI.PARAMETER
    $INSERT I_F.ACCOUNT.PARAMETER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.BOOK.DATED.BALANCE
*
    GOSUB INITIALISE
    IF R.ACCOUNT.PARAMETER<AC.PAR.VALUE.DATED.ACCTNG> EQ 'NO' THEN
        IF R.NEW(MI.PARAM.BUILD.BD.BALANCES) EQ 'YES' THEN
            IF ENT.TODAY.UPDATE THEN
                COMMAND = 'SELECT ':FN.ACCOUNT : ' WITH OPEN.CLEARED.BAL NE "" '
            END ELSE
                COMMAND = 'SELECT ':FN.ACCOUNT : ' WITH ONLINE.CLEARED.BAL NE "" '
            END
            CALL EB.READLIST(COMMAND,ACCT.LIST,'',NO.OF.REC,RET.CODE)
            LOOP
                REMOVE ACCT.ID FROM ACCT.LIST SETTING POS
            WHILE ACCT.ID:POS
                BOOK.DATED.BAL.ID = ACCT.ID:'-':TODAY[1,6]
                CALL F.READ(FN.ACCOUNT,ACCT.ID,R.ACCOUNT,F.ACCOUNT,READ.ERR)
                IF ENT.TODAY.UPDATE THEN
                    OPEN.BALANCE = R.ACCOUNT<AC.OPEN.CLEARED.BAL>
                END ELSE
                    OPEN.BALANCE = R.ACCOUNT<AC.ONLINE.CLEARED.BAL>
                END
                BOOK.DATED.BAL.ARR<BDB.OPENING.BALANCE> = OPEN.BALANCE
                BOOK.DATED.BAL.ARR<BDB.CLOSING.BALANCE> = OPEN.BALANCE
                CALL F.WRITE(FN.BOOK.DATED.BALANCE,BOOK.DATED.BAL.ID,BOOK.DATED.BAL.ARR)
                CALL JOURNAL.UPDATE(BOOK.DATED.BAL.ID)
                CALL F.WRITE(FN.BOOK.BOOK.ACTIVITY,ACCT.ID,BOOK.DATED.BAL.ID)
                CALL JOURNAL.UPDATE(ACCT.ID)
            REPEAT
        END
    END
    RETURN

**
INITIALISE:

    READ.ERR = ""
    R.ACCOUNT = ""
    OPEN.BALANCE = ""
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
*
    FN.BOOK.DATED.BALANCE = 'F.BOOK.DATED.BALANCE'
    F.BOOK.DATED.BALANCE = ''
    CALL OPF(FN.BOOK.DATED.BALANCE,F.BOOK.DATED.BALANCE)
*
    FN.BOOK.BOOK.ACTIVITY  = 'F.BOOK.BOOK.ACTIVITY'
    F.BOOK.BOOK.ACTIVITY = ''
    CALL OPF(FN.BOOK.BOOK.ACTIVITY,F.BOOK.BOOK.ACTIVITY)
*
    ENT.TODAY.UPDATE = 0

    IF R.ACCOUNT.PARAMETER<AC.PAR.ENT.TODAY.UPDATE>[1,1] EQ "Y" THEN
        ENT.TODAY.UPDATE = 1
    END

    BOOK.DATED.BAL.ARR=''
    BOOK.DATED.BAL.ID=''
*
    RETURN
END
