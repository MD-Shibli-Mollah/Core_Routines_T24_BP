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
* <Rating>-71</Rating>
*-----------------------------------------------------------------------------
* Version 3 15/05/01  GLOBUS Release No. 200508 30/06/05
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.AC.RATE.CODE(ACC.NO, AC.SIGN, CODE)
**********************************************************************************
* This routine will determine the PM rate code for a given account. This
* is the same code assigned by the PM.ACCOUNT.MOVEMENT routine and
* subsequently recorded on the PM.DLY.POSN.CLASS file. This code can be
* converted to a real rate by calling the routine E.PM.AC.RATES.
**********************************************************************************
* INPUT
* =====
* ACC.NO          ; ID of the account for the interest rate code is to
*                   be returned.
* AC.SIGN         : Indicates whether the credit or debit rate is required
*
* OUTPUT
* ======
* CODE            : Interest rate code.
*
**********************************************************************************
*
* 18/08/97 - GB9700954
*            ING0113 Up to 9999 Interest key types
*
* 26/06/06 - EN_10002987
*            File ACCOUNT.DATE is no more. Get the ADI/ACI/ADL dates from
*            ACCOUNT fields ACCT.DEBIT.INT/ACCT/CREDIT.INT/ACC.DEB.LIMIT fields
*
* 24/01/07 - CI_10046838
*            cater for multi valued banded interest rates related to amount
*
* 05/03/07 - CI_10047615
*            Multiply operand is not correctly processed
*
* 26/10/15 - EN_1226121 / Task 1511358
*	      	 Routine incorporated
*
**********************************************************************************
    $USING AC.AccountOpening
    $USING IC.Config
    $USING EB.DataAccess
    $USING IC.InterestAndCapitalisation
    $USING PM.Reports

**********************************************************************************

    GOSUB INITIALISE

    ACC.REC = AC.AccountOpening.Account.Read(ACC.NO, ERR)
    IF ERR THEN
        RETURN
    END

    IF AC.SIGN EQ 'CREDIT' THEN
        GOSUB GET.AC.CREDIT.RATE
    END ELSE
        GOSUB GET.AC.DEBIT.RATE
    END

    IF NOT(CODE) THEN
        * Get rate from group
        CODE = 'G':ACC.REC<AC.AccountOpening.Account.ConditionGroup>:'*':AC.SIGN  ;* GB9700954
    END

    RETURN
**********************************************************************************
INITIALISE:
**********************************************************************************

    AMT = ABS(ACC.NO<2>)
    ACC.NO = ACC.NO<1>
    CR.SUB = 1
    DR.SUB = 1
    CODE = ''

    RETURN
**********************************************************************************
GET.AC.CREDIT.RATE:
**********************************************************************************

    IF NOT(ACC.REC<AC.AccountOpening.Account.AcctCreditInt>) THEN
        RETURN
    END

    TEMP.DATE.LIST = RAISE(ACC.REC<AC.AccountOpening.Account.AcctCreditInt>)
    CURR.ACCT.CREDIT.INT = ''
    IC.InterestAndCapitalisation.AcGetCurrentIntDate(TEMP.DATE.LIST, CURR.ACCT.CREDIT.INT)

    IF CURR.ACCT.CREDIT.INT THEN
        ACC.CR.REC = ''
        ACC.CR.ID = ACC.NO:'-':CURR.ACCT.CREDIT.INT
        ACC.CR.REC = IC.Config.AccountCreditInt.Read(ACC.CR.ID, ER)
        IF ER THEN
            RETURN
        END

        GOSUB GET.CR.SUBSCRIPT          ;* For banded amounts

        BEGIN CASE
            CASE ACC.CR.REC<IC.Config.AccountCreditInt.AciInterestDayBasis> EQ 'GENERAL'
                ACC.CR.REC = ''   ;* Get the code from group.
            CASE ACC.CR.REC<IC.Config.AccountCreditInt.AciCrBasicRate,CR.SUB>
                CODE = 'B':ACC.CR.REC<IC.Config.AccountCreditInt.AciCrBasicRate,CR.SUB>
                OPER = ''
                IF ACC.CR.REC<IC.Config.AccountCreditInt.AciCrMarginOper,CR.SUB> EQ 'ADD' THEN
                    OPER = '+'
                END
                IF ACC.CR.REC<IC.Config.AccountCreditInt.AciCrMarginOper,CR.SUB> EQ 'SUBTRACT' THEN
                    OPER = '-'
                END
                IF ACC.CR.REC<IC.Config.AccountCreditInt.AciCrMarginOper,CR.SUB> EQ 'MULTIPLY' THEN
                    OPER = 'M'
                END
                IF OPER NE "" AND ACC.CR.REC<IC.Config.AccountCreditInt.AciCrMarginRate,CR.SUB> THEN
                    CODE := '*':OPER:ACC.CR.REC<IC.Config.AccountCreditInt.AciCrMarginRate,CR.SUB>
                END

            CASE 1
                CODE = ACC.CR.REC<IC.Config.AccountCreditInt.AciCrIntRate,CR.SUB>
                IF ACC.CR.REC<IC.Config.AccountCreditInt.AciCrMarginOper,CR.SUB> EQ 'ADD' THEN
                    CODE = CODE + ACC.CR.REC<IC.Config.AccountCreditInt.AciCrMarginRate,CR.SUB>
                END
                IF ACC.CR.REC<IC.Config.AccountCreditInt.AciCrMarginOper,CR.SUB> EQ 'SUBTRACT' THEN
                    CODE = CODE - ACC.CR.REC<IC.Config.AccountCreditInt.AciCrMarginRate,CR.SUB>
                END
                IF ACC.CR.REC<IC.Config.AccountCreditInt.AciCrMarginOper,CR.SUB> EQ 'MULTIPLY' THEN
                    CODE = CODE + ((CODE/100) * ACC.CR.REC<IC.Config.AccountCreditInt.AciCrMarginRate,CR.SUB>)
                END
                CODE = "F*":CODE

        END CASE
    END

    RETURN

********************************************************************************
GET.CR.SUBSCRIPT:
**************

    IF ACC.CR.REC AND ACC.CR.REC<IC.Config.AccountCreditInt.AciInterestDayBasis> NE 'GENERAL' THEN
        NO.VM = DCOUNT(ACC.CR.REC<IC.Config.AccountCreditInt.AciCrBasicRate>,@VM)
        FOR CR.SUB = 1 TO NO.VM
            IF AMT LT ACC.CR.REC<IC.Config.AccountCreditInt.AciCrLimitAmt,CR.SUB> THEN
                EXIT
            END
        NEXT CR.SUB
    END

    RETURN

**********************************************************************************
GET.AC.DEBIT.RATE:
**********************************************************************************
    IF NOT(ACC.REC<AC.AccountOpening.Account.AcctDebitInt>) THEN
        RETURN
    END
* Get the current interest date from the list of debit int date

    TEMP.DATE.LIST = RAISE(ACC.REC<AC.AccountOpening.Account.AcctDebitInt>)
    IC.InterestAndCapitalisation.AcGetCurrentIntDate(TEMP.DATE.LIST,CURR.ACCT.DEBIT.INT)

    IF CURR.ACCT.DEBIT.INT THEN
        ACC.DR.REC = ''
        ACC.DR.ID = ACC.NO:'-':CURR.ACCT.DEBIT.INT

        ACC.DR.REC = IC.Config.AccountDebitInt.Read(ACC.DR.ID, ER)
        IF ER THEN
            RETURN
        END

        GOSUB GET.DR.SUBSCRIPT          ;* for banded amounts

        BEGIN CASE
            CASE ACC.DR.REC<IC.Config.AccountDebitInt.AdiInterestDayBasis> EQ 'GENERAL'
                ACC.DR.REC = ''
            CASE ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrBasicRate,DR.SUB>
                CODE = 'B':ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrBasicRate,DR.SUB>
                OPER = ''

                IF ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrMarginOper,DR.SUB> EQ 'ADD' THEN
                    OPER = '+'
                END
                IF ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrMarginOper,DR.SUB> EQ 'SUBTRACT' THEN
                    OPER = '-'
                END
                IF ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrMarginOper,DR.SUB> EQ 'MULTIPLY' THEN
                    OPER = 'M'
                END
                IF OPER NE "" AND ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrMarginRate,DR.SUB> THEN
                    CODE := '*':OPER:ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrMarginRate,DR.SUB>
                END

            CASE 1

                CODE = ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrIntRate,DR.SUB>
                IF ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrMarginOper,DR.SUB> EQ 'ADD' THEN
                    CODE = CODE + ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrMarginRate,DR.SUB>
                END
                IF ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrMarginOper,DR.SUB> EQ 'SUBTRACT' THEN
                    CODE = CODE - ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrMarginRate,DR.SUB>
                END
                IF ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrMarginOper,DR.SUB> EQ 'MULTIPLY' THEN
                    CODE = CODE + ((CODE /  100) * ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrMarginRate,DR.SUB>)
                END
                CODE = "F*":CODE

        END CASE
    END

    RETURN

********************************************************************************
GET.DR.SUBSCRIPT:
**************

    IF ACC.DR.REC AND ACC.DR.REC<IC.Config.AccountDebitInt.AdiInterestDayBasis> NE 'GENERAL' THEN
        NO.VM = DCOUNT(ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrBasicRate>,@VM)
        FOR DR.SUB = 1 TO NO.VM
            IF AMT LT ACC.DR.REC<IC.Config.AccountDebitInt.AdiDrLimitAmt,DR.SUB> THEN
                EXIT
            END
        NEXT DR.SUB
    END

    RETURN
**********************************************************************************
    END
**********************************************************************************
