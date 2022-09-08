* @ValidationCode : MjoxMjcyMzI5MDc0OkNwMTI1MjoxNDg1MjUwNzI1Mjg1OmpoYWxha3ZpajozOjA6LTMxOi0xOmZhbHNlOk4vQQ==
* @ValidationInfo : Timestamp         : 24 Jan 2017 15:08:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jhalakvij
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : -31
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-63</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.Framework
    SUBROUTINE AA.GET.INITIAL.BALANCE.AMOUNT(PROPERTY.ID, START.DATE, END.DATE, CURRENT.DATE, BALANCE.TYPE, ACTIVITY.IDS, CURRENT.VALUE, START.VALUE, END.VALUE)

*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
* This is a RULE.VAL.RTN designed and released to evaluate the newly created
* Periodic Attribute Classes
*
*-----------------------------------------------------------------------------
* @uses I_AA.APP.COMMON
* @package retaillending.AA
* @stereotype subroutine
* @author carolbabu@temenos.com
*-----------------------------------------------------------------------------
*** </region>
**
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* @param Property ID   - Property ID
* @param Start Date    - Rule Start Date
* @param End Date      - Rule End Date
* @param Current Date  - The current date at which the arrangement is running and for which the balance amount is sought
* @param Balance Type  - Balance Type for which the Balance Amount is required
* @param Activity ID   - Activity ID for which the Balance Amount is required
*
* Ouptut
* @return Current Value - The value for the attribute on the actual date.
* @return Start Value   - Balance Amounts of the Authorised Movements
* @return End Value     - Balance Amounts of all the Movements
*
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
* 24/11/10 - EN_72965
*            New routine to get the balance amounts
*            used in rule evaluation
*
* 11/07/14 - Task : 1033488
*            Defect : 1021864
*            Check if the activity has been already processed once, else get the balance amount of the particular period balance
*            instead of ECB.
*
* 03/10/16 - Task : 1880367
*            Defect : 1876929
*            Routine should support multiple activities
*
* 22/01/17 - Task : 1994583
*            Enhancement : 1963975
*            New API to get the activity base details like date\amount\count
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $USING AA.PaymentSchedule
    $USING AC.BalanceUpdates
    $USING AA.Framework

*** </region>

*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise para in the sub routine</desc>
INITIALISE:

    START.VALUE = ''
    END.VALUE = ''
    ARRANGEMENT.ID = AA.Framework.getArrId()
    ACT.POS = ''
    R.ACTIVITY.HISTORY = ''
    R.ARRANGEMENT.ACTIVITY = AA.Framework.getRArrangementActivity()

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
*** <desc>To check whether the activity is called for the first time sub routine</desc>
PROCESS:

    CNT.ACTIVITY.IDS = DCOUNT(ACTIVITY.IDS,@FM) ;* Count of activies
    RETURN.FLAG = '' ;* Flag to indicate whether the activity already processed once
    ACT.CNT = '1'

    IF ACTIVITY.IDS THEN ;* When activity ids are available then validate whether the activity already triggered
        LOOP
        UNTIL ACT.CNT GT CNT.ACTIVITY.IDS OR RETURN.FLAG ;* Loop until we found the activity processed already or loop all activities

        ACTIVITY.ID = ACTIVITY.IDS<1,ACT.CNT> ;* Get a activity id to locate it in activity history
        ACTIVITY.DATES = ""
        AA.Framework.GetContextHistoryDetails("COUNT", ARRANGEMENT.ID, "", ACTIVITY.ID, ACTIVITY.DATES, "", "", "")
        ** Get the count of the activity present under the activity history. If that activity is already triggered but its status is in
        ** either DELETE or AUTH-REV then COUNT would be reduced.

        IF ACTIVITY.DATES THEN
            ** Only during the first time processing of the particular activity, system must validate the amount against the rule value.
            END.VALUE = "NOCOMPARE"
            RETURN.FLAG = 1 ;* Flaf indicated the activity already processed once
        END ELSE
            ** Get the amount from arrangement activity, since during the transaction the txn amount wont be available under the activity history.
            END.VALUE = R.ARRANGEMENT.ACTIVITY<AA.Framework.ArrangementActivity.ArrActTxnAmount>
        END
        ACT.CNT += 1
        REPEAT
    END ELSE ;* When activity ids are not available then return the default end value
        END.VALUE = R.ARRANGEMENT.ACTIVITY<AA.Framework.ArrangementActivity.ArrActTxnAmount>
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------

    END
