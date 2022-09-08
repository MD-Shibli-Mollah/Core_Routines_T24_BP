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

* Version 4 25/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>162</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Contract
    SUBROUTINE CONV.CHARGES.14.2.0
*
* Program to read through the Drawings file and read any oustanding
* charge in the LC.ACCOUNT.BALANCES . The program then updates
* the REIMBURSE.AMOUNT and the PAYMENT.AMOUNT fields in the DRAWINGS
* file.
* This program is only to be used between the special lc's release
* 14.1.5lcs to G5.LC'S
*
* 15/06/07 - BG_100014255
*            Incorrect no. of arguments and routine missing
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_LC.COMMON
    $INSERT I_F.DRAWINGS
    $INSERT I_F.LC.ACCOUNT.BALANCES


    YF.DRAWINGS = 'F.DRAWINGS'
    F.DRAWINGS = ''
    YF.LETTER.OF.CREDIT = 'F.LETTER.OF.CREDIT'
    F.LETTER.OF.CREDIT = ''
    YF.ACCOUNT.BALANCES = 'F.LC.ACCOUNT.BALANCES'
    F.ACCOUNT.BALANCES = ''
    REAL.ENT = ''
    MAT.ENT = ''

    CALL OPF (YF.DRAWINGS, F.DRAWINGS )
    CALL OPF (YF.LETTER.OF.CREDIT, F.LETTER.OF.CREDIT )
    CALL OPF (YF.ACCOUNT.BALANCES, F.ACCOUNT.BALANCES )

    CMD.SELECT = 'SELECT ':YF.DRAWINGS
    LC.LIST = ''
    NO.RECS = 0
    CALL EB.READLIST(CMD.SELECT, LC.LIST, 'LC.LIST', NO.RECS, '')

    IF LC.LIST THEN

        LOOP
            REMOVE DR.ID FROM LC.LIST SETTING CODE
        WHILE DR.ID

            DR.REC = '' ; IO.ERR = '' ; ID.NEW = DR.ID
            CALL F.MATREAD ('F.DRAWINGS', DR.ID, MAT R.NEW, TF.DR.AUDIT.DATE.TIME, F.DRAWINGS, IO.ERR)
            CALL F.MATREAD ('F.LC.ACCOUNT.BALANCES', DR.ID[1,12], MAT R$ACCOUNT.BALANCES, LCAC.AUDIT.DATE.TIME, F.ACCOUNT.BALANCES, IO.ERR)
            CALL F.MATREAD ('F.LETTER.OF.CREDIT', DR.ID[1,12], MAT LC.REC, TF.LC.AUDIT.DATE.TIME, F.LETTER.OF.CREDIT, IO.ERR)
            IF NOT(IO.ERR) THEN

                IF R.NEW(TF.DR.DRAWING.TYPE) NE 'SP' AND R.NEW(TF.DR.DRAWING.TYPE)[1,1] NE 'M' THEN
                    IF NOT(R.NEW(TF.DR.DISCOUNT.AMT)) THEN
                        IF R.NEW(TF.DR.MATURITY.REVIEW) GE TODAY THEN
                            REC.DIFF = 0
                            GOSUB PAYMENT.CHARGES
                            GOSUB REIMBURSE.CHARGES
                            IF REC.DIFF THEN
                                GOSUB WRITE.RECORD
                            END
                        END

                    END
                END
            END
        REPEAT
    END
    RETURN
**********************************************************************
PAYMENT.CHARGES:
*

    BOOK.CHARGES = ''
    STATUS.CHANGE = '11'      ;* Awaiting Payment
    TOTAL.CHARGES= ''
    PARTY.CHARGED = 'B'
* STATUS.CHECK = '' ; CORR.CHECK = ''
* CORR.STATUS = ''
*
    REV.CHG = ''

    CALL LC.PROCESS.CHARGES(BOOK.CHARGES, TOTAL.CHARGES, STATUS.CHANGE,
    REV.CHG, PARTY.CHARGED, ENTRIES.ARRAY, CONSOL.REC, FWD.ARRAY, WRITE.LCAC )  ;*BG_100014255 S/E

    IF TOTAL.CHARGES THEN
        REC.DIFF = 1
        TOTAL.DRAW.CHRG = TOTAL.CHARGES<1>
        TOTAL.CLAIM.CHRG = TOTAL.CHARGES<3>
        PAYMENT.AMOUNT = R.NEW(TF.DR.PAYMENT.AMOUNT)
        PAYMENT.AMOUNT -= TOTAL.DRAW.CHRG
        PAYMENT.AMOUNT += TOTAL.CLAIM.CHRG
        R.NEW(TF.DR.PAYMENT.AMOUNT) = PAYMENT.AMOUNT
    END ELSE
        REC.DIFF = ''
    END
**
*** Update payment amount ***
***
    RETURN
*
***********************************************************************
REIMBURSE.CHARGES:
*
    BOOK.CHARGES = ''
    STATUS.CHANGE = '12'      ;* awaiting reimbursement
    TOTAL.CHARGES= ''
*STATUS.CHECK = '' ; CORR.CHECK = ''
    PARTY.CHARGED = 'O'
* CORR.STATUS = 'Y'         ;* Update the corr.charges here
*
    REV.CHG = ''
    CALL LC.PROCESS.CHARGES(BOOK.CHARGES, TOTAL.CHARGES, STATUS.CHANGE,
    REV.CHG, PARTY.CHARGED, ENTRIES.ARRAY, CONSOL.REC, FWD.ARRAY, WRITE.LCAC )  ;*BG_100014255 S/E

    IF TOTAL.CHARGES THEN
        REC.DIFF = 1
        TOTAL.DRAW.CHRG = TOTAL.CHARGES<1>
        TOTAL.CLAIM.CHRG = TOTAL.CHARGES<3>
        REIMBURSE.AMOUNT = R.NEW(TF.DR.REIMBURSE.AMOUNT)
        REIMBURSE.AMOUNT += TOTAL.DRAW.CHRG
        REIMBURSE.AMOUNT -= TOTAL.CLAIM.CHRG
        R.NEW(TF.DR.REIMBURSE.AMOUNT) = REIMBURSE.AMOUNT
    END
    RETURN
**********************************************************************
WRITE.RECORD:

    REC.DIFF = '' ; IO.ERR = ''

    CALL F.MATWRITE('F.DRAWINGS', DR.ID, MAT R.NEW, TF.DR.AUDIT.DATE.TIME)
    CALL F.MATWRITE ('F.LC.ACCOUNT.BALANCES', DR.ID[1,12], MAT R$ACCOUNT.BALANCES,
    LCAC.AUDIT.DATE.TIME)

    CALL JOURNAL.UPDATE(ID.NEW)
    RETURN
**********************************************************************
END
