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
* <Rating>-64</Rating>
*-----------------------------------------------------------------------------
* Version 3 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
    $PACKAGE AC.BalanceUpdates
    SUBROUTINE CONV.AAA.R09(ID.ACCT.ACCT.ACTIVITY, R.ACCT.ACCT.ACTIVITY, FN.ACCT.ACCT.ACTIVITY)
*-----------------------------------------------------------------------------
* Program Description
*
* Move the contents of ACCT.ACCT.ACTIVITY records to EB.CONTRACT.BALANCES
* and delete the original record.
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 10/09/08 - EN_10003825
*            Removal of ACCT.ACCT.ACTIVITY.
*
* 07/11/08 - BG_100020751
*            Fatal error in CONV.AAA.R09.
*
* 10/11/08 - BG_100020754
*            Store balance type activity months on EB.CONTRACT.BALANCES.
*
* 28/06/11 - Task 235035
*            The ACCT.ACCT.ACCTIVTY record is not removed after write into the ECB. So
*            write a record in AC.CONV.ENTRY so that it can delete the ACCT.ACCT.ACTIVITY
*            record during COB.
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*-----------------------------------------------------------------------------

* Initialise
    GOSUB INITIALISE

* Read EB.CONTRACT.BALANCES record
    GOSUB READ.EB.CONTRACT.BALANCES.RECORD

* Update EB.CONTRACT.BALANCES record
    GOSUB UPDATE.EB.CONTRACT.BALANCES.RECORD

* Write EB.CONTRACT.BALANCES.RECORD
    GOSUB WRITE.EB.CONTRACT.BALANCES.RECORD

* Update AC.CONV.ENTRY file
    GOSUB UPDATE.AC.CONV.ENTRY

    RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise </desc>

    ID.EB.CONTRACT.BALANCES = FIELD(ID.ACCT.ACCT.ACTIVITY, ".", 1)
    BAL.TYPE = FIELD(ID.ACCT.ACCT.ACTIVITY, ".", 2, 2)

    FN.EB.CONTRACT.BALANCES = "F.EB.CONTRACT.BALANCES"
    F.EB.CONTRACT.BALANCES = ""
    CALL OPF(FN.EB.CONTRACT.BALANCES, F.EB.CONTRACT.BALANCES)

    FN.ACCT.ACCT.ACTIVITY = "F.ACCT.ACCT.ACTIVITY"
    F.ACCT.ACCT.ACTIVITY = ""
    CALL OPF(FN.ACCT.ACCT.ACTIVITY, F.ACCT.ACCT.ACTIVITY)

    FN.AC.CONV.ENTRY = 'F.AC.CONV.ENTRY'
    F.AC.CONV.ENTRY = ''

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= READ.EB.CONTRACT.BALANCES.RECORD>
READ.EB.CONTRACT.BALANCES.RECORD:
*** <desc>Read EB.CONTRACT.BALANCES record </desc>

    READU R.EB.CONTRACT.BALANCES FROM F.EB.CONTRACT.BALANCES, ID.EB.CONTRACT.BALANCES ELSE
    R.EB.CONTRACT.BALANCES = ""
    END

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= UPDATE.EB.CONTRACT.BALANCES.RECORD>
UPDATE.EB.CONTRACT.BALANCES.RECORD:
*** <desc>Update EB.CONTRACT.BALANCES record </desc>

    IF BAL.TYPE EQ "" THEN
        R.EB.CONTRACT.BALANCES<54> = LOWER(R.ACCT.ACCT.ACTIVITY)
    END ELSE
        LOCATE BAL.TYPE IN R.EB.CONTRACT.BALANCES<55, 1> BY "AL" SETTING BAL.TYPE.POS ELSE
            NULL
        END
        INS BAL.TYPE BEFORE R.EB.CONTRACT.BALANCES<55, BAL.TYPE.POS>
        INS LOWER(LOWER(R.ACCT.ACCT.ACTIVITY)) BEFORE R.EB.CONTRACT.BALANCES<56, BAL.TYPE.POS>
    END

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= WRITE.EB.CONTRACT.BALANCES.RECORD>
WRITE.EB.CONTRACT.BALANCES.RECORD:
*** <desc>Write EB.CONTRACT.BALANCES.RECORD </desc>

    WRITE R.EB.CONTRACT.BALANCES ON F.EB.CONTRACT.BALANCES, ID.EB.CONTRACT.BALANCES

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= UPDATE.AC.CONV.ENTRY>
UPDATE.AC.CONV.ENTRY:
*** <desc>Update the AC.CONV.ENTRY file </desc>
*
    R.AC.CONV.ENTRY = ''
    Y.ERROR = ''
*
    CALL F.READ(FN.AC.CONV.ENTRY, 'AAA.TO.ECB', R.AC.CONV.ENTRY, F.AC.CONV.ENTRY, Y.ERROR)
*
    IF Y.ERROR THEN
        CALL F.WRITE(FN.AC.CONV.ENTRY, 'AAA.TO.ECB', R.AC.CONV.ENTRY)
    END
*
    RETURN
*
*** </region>
*-----------------------------------------------------------------------------
    END
