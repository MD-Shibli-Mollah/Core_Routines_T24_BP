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
* <Rating>-60</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.Rules
    SUBROUTINE CONV.AA.PERIODIC.ATTRIBUTE.R13(REC.ID,R.PERIOD,YFILE)
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* Record Conversion routine to convert existing Periodic Attribute to update
* COMPARISON.TYPE, PR.ATTR.CLASS field and TYPE fields.
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
* 19/06/2012 - Ref - 355144
*              Task - 395758
*              Update the COMPARISON.TYPE field as per the corresponding AA.PERIODIC.ATTRIBUTE.CLASS record.
*              Update the PR.ATTR.CLASS field as per the newly introduced AA.PERIODIC.ATTRIBUTE.CLASS records.
*              Update the TYPE field as per the newly introduced AA.PERIODIC.ATTRIBUTE.CLASS records.
*
* 13/09/2012 - Ref - 481316
*              Task - 481389
*              Update the PR.ATTR.CLASS field as per the newly introduced AA.PERIODIC.ATTRIBUTE.CLASS 
*              records (REPAY.TOLERANCE.CURRENT & REPAY.TOLERANCE.TOTAL).
* 
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
** Input:
*
** REC.ID   - Record Id
** R.PERIOD - Periodic Attribute Record
** YFILE    - File Name
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.PERIODIC.ATTRIBUTE
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
INITIALISE:

*
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main process>
*** <desc>Description for the main process</desc>
PROCESS:

    GOSUB UPDATE.COMPARISON.TYPE
    GOSUB UPDATE.TYPE
    GOSUB UPDATE.PERIODIC.ATTRIBUTE.CLASS
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Update Comparison Type>
*** <desc>Update the COMPARISON.TYPE field as per the corresponding AA.PERIODIC.ATTRIBUTE.CLASS record.</desc>
UPDATE.COMPARISON.TYPE:

    BEGIN CASE

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'MAXIMUM.BALANCE.INCREASE':VM:'AMOUNT.INCREASE'
            R.PERIOD<AA.PA.COMPARISON.TYPE> = 'DIFFERENCE'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'PAYOFF.NEG.DIFFERENCE':VM:'AMOUNT.DECREASE'
            R.PERIOD<AA.PA.COMPARISON.TYPE> = '-DIFFERENCE'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'PAYOFF.POS.DIFFERENCE':VM:'TRANSACTION.AMOUNT.TOTAL':VM:'TRANSACTION.COUNT.TOTAL'
            R.PERIOD<AA.PA.COMPARISON.TYPE> = '+DIFFERENCE'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> EQ 'RATE.INCREASE'
            R.PERIOD<AA.PA.COMPARISON.TYPE> = '+BASISPOINT'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> EQ 'RATE.DECREASE'
            R.PERIOD<AA.PA.COMPARISON.TYPE> = '-BASISPOINT'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'RATE.INCREASE.TOLERANCE':VM:'AMOUNT.INCREASE.TOLERANCE'
            R.PERIOD<AA.PA.COMPARISON.TYPE> = '+TOLERANCE'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'RATE.DECREASE.TOLERANCE':VM:'AMOUNT.DECREASE.TOLERANCE'
            R.PERIOD<AA.PA.COMPARISON.TYPE> = '-TOLERANCE'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'MAXIMUM.BALANCE':VM:'MAXIMUM.CHARGE':VM:'MAXIMUM.RATE':VM:'TRANSACTION.AMOUNT.MAXIMUM':VM:'MAXIMUM.DELINQUENT.AMOUNT':VM:'MAXIMUM.DELINQUENT.DAYS'
            R.PERIOD<AA.PA.COMPARISON.TYPE> = 'MAXIMUM'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'MINIMUM.BALANCE':VM:'MINIMUM.CHARGE':VM:'MINIMUM.RATE':VM:'TRANSACTION.AMOUNT.MINIMUM':VM:'MINIMUM.INITIAL.BALANCE'
            R.PERIOD<AA.PA.COMPARISON.TYPE> = 'MINIMUM'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> EQ 'MINIMUM.BALANCE.INCREASE'
            R.PERIOD<AA.PA.COMPARISON.TYPE> = 'MINDIFFERENCE'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> EQ 'TRANSACTION.AMOUNT.MULTIPLE'
            R.PERIOD<AA.PA.COMPARISON.TYPE> = 'MULTIPLE'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'CURR.LOAN.REPAY.TOLERANCE':VM:'TOTAL.LOAN.REPAY.TOLERANCE'
            R.PERIOD<AA.PA.COMPARISON.TYPE> = 'TOLERANCE'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'FULL.DEPOSIT':VM:'FULL.DISBURSE':VM:'FULL.REDEEM'
            R.PERIOD<AA.PA.COMPARISON.TYPE> = 'EQUAL'

    END CASE
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Update Type>
*** <desc>Update the TYPE field as per the corresponding AA.PERIODIC.ATTRIBUTE.CLASS record.</desc>
UPDATE.TYPE:

    BEGIN CASE

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'MAXIMUM.BALANCE':VM:'MAXIMUM.BALANCE.INCREASE':VM:'MINIMUM.BALANCE':VM:'MINIMUM.BALANCE.INCREASE':VM:'MINIMUM.INITIAL.BALANCE'
            R.PERIOD<AA.PA.TYPE> = 'BALANCE.TYPE'
        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'MAXIMUM.CHARGE':VM:'MAXIMUM.RATE':VM:'RATE.INCREASE':VM:'RATE.INCREASE.TOLERANCE'
            R.PERIOD<AA.PA.TYPE> = 'CAP'
        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'MINIMUM.CHARGE':VM:'MINIMUM.RATE':VM:'RATE.DECREASE':VM:'RATE.DECREASE.TOLERANCE'
            R.PERIOD<AA.PA.TYPE> = 'FLOOR'

    END CASE
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Update Comparison Type>
*** <desc>Update the COMPARISON.TYPE field as per the corresponding AA.PERIODIC.ATTRIBUTE.CLASS record.</desc>
UPDATE.PERIODIC.ATTRIBUTE.CLASS:

    BEGIN CASE

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'MAXIMUM.BALANCE.INCREASE':VM:'MINIMUM.BALANCE':VM:'MINIMUM.BALANCE.INCREASE':VM:'MAXIMUM.BALANCE'
            R.PERIOD<AA.PA.PR.ATTR.CLASS> = 'BALANCE'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> EQ 'MAXIMUM.DELINQUENT.AMOUNT'
            R.PERIOD<AA.PA.PR.ATTR.CLASS> = 'DELINQUENT.AMOUNT'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> EQ 'MAXIMUM.DELINQUENT.DAYS'
            R.PERIOD<AA.PA.PR.ATTR.CLASS> = 'DELINQUENT.DAYS'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> EQ 'MINIMUM.INITIAL.BALANCE'
            R.PERIOD<AA.PA.PR.ATTR.CLASS> = 'INITIAL.BALANCE'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'MAXIMUM.CHARGE':VM:'MINIMUM.CHARGE'
            R.PERIOD<AA.PA.PR.ATTR.CLASS> = 'CHARGE.AMOUNT'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'PAYOFF.POS.DIFFERENCE':VM:'PAYOFF.NEG.DIFFERENCE'
            R.PERIOD<AA.PA.PR.ATTR.CLASS> = 'PAYOFF.AMOUNT'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'MAXIMUM.RATE':VM:'MINIMUM.RATE':VM:'RATE.DECREASE':VM:'RATE.DECREASE.TOLERANCE':VM:'RATE.INCREASE.TOLERANCE':VM:'RATE.INCREASE'
            R.PERIOD<AA.PA.PR.ATTR.CLASS> = 'INTEREST.RATE'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'AMOUNT.DECREASE.TOLERANCE':VM:'AMOUNT.DECREASE':VM:'AMOUNT.INCREASE.TOLERANCE':VM:'AMOUNT.INCREASE'
            R.PERIOD<AA.PA.PR.ATTR.CLASS> = 'TERM.AMOUNT'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> MATCHES 'TRANSACTION.AMOUNT.MINIMUM':VM:'TRANSACTION.AMOUNT.MAXIMUM':VM:'TRANSACTION.AMOUNT.MULTIPLE'
            R.PERIOD<AA.PA.PR.ATTR.CLASS> = 'TRANSACTION.AMOUNT'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> EQ 'FULL.DISBURSE'
            R.PERIOD<AA.PA.PR.ATTR.CLASS> = 'FULL.DISBURSEMENT'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> EQ 'FULL.REDEEM'
            R.PERIOD<AA.PA.PR.ATTR.CLASS> = 'FULL.REDEMPTION'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> EQ 'CURR.LOAN.REPAY.TOLERANCE'
            R.PERIOD<AA.PA.PR.ATTR.CLASS> = 'REPAY.TOLERANCE.CURRENT'

        CASE R.PERIOD<AA.PA.PR.ATTR.CLASS> EQ 'TOTAL.LOAN.REPAY.TOLERANCE'
            R.PERIOD<AA.PA.PR.ATTR.CLASS> = 'REPAY.TOLERANCE.TOTAL'

    END CASE
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
