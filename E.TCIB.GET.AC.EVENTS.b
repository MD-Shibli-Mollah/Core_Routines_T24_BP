* @ValidationCode : MjoxNDI0NTQyOTk1OkNwMTI1MjoxNTY4NzIxNTgwMDY1OmluZGh1bWF0aGlzOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOS4yMDE5MDgyMy0wMzA1Oi0xOi0x
* @ValidationInfo : Timestamp         : 17 Sep 2019 17:29:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : indhumathis
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201909.20190823-0305
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-------------------------------------------------------------------------------------------------------------
* <Rating>-108</Rating>
*---------------------------------------------------------------------------------------------------------------
* Subroutine type : NOFILE
* Attached to     : STANDARD.SELECTION record E.TCIB.GET.AC.EVENTS for the enquiry TCIB.AC.GET.ELIGIBLE.EVENTS
* Attached as     : NOFILE Enquiry routine
* Incoming        : Enquiry's selection and its value from common variables
* Outgoing        : FINAL.ARR - The List of TEC.ITEMS record eligible for the given account
* Version         : 1.0
*                 : Enhancement 590517
*---------------------------------------------------------------------------------------------------------------
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*
* 05/09/19 - Enhancement 3327829 / Task 3327843
*            AC.GET.ELIGIBLE.EVENTS has been moved from ST.ChargeConfig to AC.Config and Product Installation check for AC.
*---------------------------------------------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE E.TCIB.GET.AC.EVENTS(FINAL.ARR)


    $INSERT I_DAS.EB.ALERT.REQUEST
    $INSERT I_DAS.TEC.ITEMS

    $USING AC.AccountOpening
    $USING AA.Framework
    $USING AA.Alerts
    $USING EB.Logging
    $USING EB.Reports
    $USING EB.AlertProcessing
    $USING AC.Config
    $USING EB.API

    isACInstalled = ""
    EB.API.ProductIsInCompany('AC', isACInstalled)
    IF NOT(isACInstalled) THEN
        RETURN
    END
    
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB PROCESS

*The below condition is to remove the TEC.ITEMS which is already subscribed for this Account -- for ARC-IB
*Check the enquiry AI.AC.GET.ELIGIBLE.EVENTS

    IF FINAL.ARR AND TEC.ITEMS.LIST THEN

        GOSUB CHECK.DUPLICATE
    END

    IF FINAL.ARR AND ARRANGEMENT.ID THEN

        THE.LIST=DAS.EB.ALERT.REQUEST$CONTRACT.REF

        THE.ARGS=ARRANGEMENT.ID:@FM:'YES'

        GOSUB CHECK.DUPLICATE.ARR
    END

    GOSUB CHECK.INTERNAL.ALERTS

    FINAL.ARR = CHANGE(FINAL.ARR,@VM,@FM)

RETURN

***********
INITIALISE:
***********

*-----------------------------------------------------------------------------------------------------------------
*Do all the initialisations here, open files, get the Account number and the selection fields
*------------------------------------------------------------------------------------------------------------------

    ACCT.NO = ""

    LOCATE "ACCT.NUMBER" IN EB.Reports.getDFields()<1> SETTING FIELD.POS THEN

        ACCT.NO = EB.Reports.getDRangeAndValue()<FIELD.POS>

    END

    FINAL.ARR = ""

    VALUE.ARR=""

    R.ACCT.REC = ""

    ELIGIBLE.EVENTS.LIST = ""

    DATE.PART = ""

    PRODUCT.ID = ""

    ARRANGEMENT.ID = ""

    EFFECTIVE.DATE = ""

    CURRENCY = ""

    PROD.ALERTS.EVENTS = ""

    ARR.ALERTS.EVENTS  = ""

    PL.LEND="LENDING"

    PL.DEPOSIT="DEPOSITS"

    SKIP.TEC.ITEMS='ACCOUNT.AMEND.COND':@VM:'AA.ISSUE.BILL':@VM:'AA.AGE.OVERDUE':@VM:'AA.OVERDUE.ARRANGEMENT.GRACE':@VM:'AA.DISBURSE.ARRANGEMENT':@VM:'AA.ISSUE.CHASER':@VM:'AA.PAYOFF.ARRANGEMENT'

    SKIP.DEPOSIT.TEC.ITEMS='AA.ISSUE.BILL'

    isEventPublished = '1'

RETURN

**********
OPENFILES:
**********

RETURN


*********
PROCESS:
*********
*------------------------------------------------------------------------------------------------------------------
* Get the Account number and check if this an arrangement Id.
* If arrangement get the list of eligible TEC.ITEMS for this arrangement at the product level
* else get the list of eligible TEC.ITEMS at the account level using the core routine which reads
* the file ACCT.GROUP.EVENT
*-------------------------------------------------------------------------------------------------------------------
    IF ACCT.NO THEN

        R.ACCT.REC = AC.AccountOpening.Account.Read(ACCT.NO,R.ERR)

        IF NOT(R.ERR) THEN

            TEC.ITEMS.LIST = R.ACCT.REC<AC.AccountOpening.Account.Event>

            IF R.ACCT.REC<AC.AccountOpening.Account.ArrangementId> THEN

                GOSUB ARRANGEMENT.TEC.ITEMS

            END ELSE

                AC.Config.AcGetEligibleEvents(ACCT.NO, R.ACCT.REC, ELIGIBLE.EVENTS.LIST, DATE.PART, RESER3, RESER2, RESER1)

                FINAL.ARR = ELIGIBLE.EVENTS.LIST

            END

        END
    END

RETURN

**********************
ARRANGEMENT.TEC.ITEMS:
**********************

    ARRANGEMENT.ID = R.ACCT.REC<AC.AccountOpening.Account.ArrangementId>

    IF NOT(PRODUCT.ID) OR NOT(CURRENCY)  THEN     ;* Get product/currency  from arrangement

        AA.Framework.GetArrangementProduct(ARRANGEMENT.ID, EFFECTIVE.DATE, ARR.RECORD, PRODUCT.ID, PROPERTY.LIST)

    END

    AA.Alerts.GetAlertsEvents(PRODUCT.ID,ARRANGEMENT.ID,EFFECTIVE.DATE,CURRENCY,PROD.ALERTS.EVENTS,ARR.ALERTS.EVENTS ,PROD.PROPERTY.RECORD,ARR.PROPERTY.RECORD,ALERTS.PROPERTY.NAME,RET.ERR,RES1,RES2,RES3,RES4)

    FINAL.ARR = PROD.ALERTS.EVENTS

*Select the events based on the product line(LENDING  or DEPOSITS)

    R.ARR = AA.Framework.Arrangement.Read(ARRANGEMENT.ID,R.ERROR)

    PR.LINE=R.ARR<AA.Framework.Arrangement.ArrProductLine>

    IF PR.LINE EQ 'ACCOUNTS' THEN

        GOSUB TEC.ITEMS.ARR.ACCOUNT.TCIB          ;* This will give the Available alert for selected product alone

    END


    IF PR.LINE EQ PL.DEPOSIT THEN

        GOSUB TEC.ITEMS.DEPOSIT

    END

RETURN


***************************
TEC.ITEMS.ARR.ACCOUNT.TCIB:
***************************

    THE.LIST = FINAL.ARR

    LOOP

        REMOVE TEC.ITEM.ID FROM THE.LIST SETTING TEC.POS

    WHILE TEC.ITEM.ID:TEC.POS

        IF NOT(TEC.ITEM.ID  MATCHES SKIP.TEC.ITEMS) THEN

            FINAL.ARR1<1,-1> = TEC.ITEM.ID

        END

    REPEAT

    FINAL.ARR = FINAL.ARR1

RETURN

******************
TEC.ITEMS.DEPOSIT:
******************

    LOOP
        REMOVE TEC.ITEM.ID FROM FINAL.ARR SETTING TEC.POS

    WHILE TEC.ITEM.ID:TEC.POS

        IF NOT(TEC.ITEM.ID  MATCHES SKIP.DEPOSIT.TEC.ITEMS) THEN

            R.TECITEM = EB.Logging.TecItems.Read(TEC.ITEM.ID,Y.ERR)

            TEC.VALUE = R.TECITEM<EB.Logging.TecItems.TecItValue>

            TEC.ID=TEC.VALUE[1,7]

            IF TEC.ID NE PL.LEND THEN

                VALUE.ARR<1,-1>=TEC.ITEM.ID

            END
        END

    REPEAT

    FINAL.ARR = VALUE.ARR

RETURN


****************
CHECK.DUPLICATE:
****************

*------------------------------------------------------------------------------------------------------------------------------
* Read the account record and get the list of Alerts/TEC.ITEMS which are already subscribed
* and remove them from the final list FINAL.ARR
*-------------------------------------------------------------------------------------------------------------------------------

    LOOP

        REMOVE TEC.ITEM.ID FROM TEC.ITEMS.LIST SETTING TEC.POS

    WHILE TEC.ITEM.ID:TEC.POS

        LOCATE TEC.ITEM.ID IN FINAL.ARR<1,1> SETTING FOUND.POS THEN

            DEL FINAL.ARR<1,FOUND.POS>
        END

    REPEAT

RETURN

********************
CHECK.DUPLICATE.ARR:
********************

    CALL DAS('EB.ALERT.REQUEST',THE.LIST,THE.ARGS,'')

    LOOP

        REMOVE EB.ALERT.ID FROM THE.LIST SETTING EB.ALERT.POS

    WHILE EB.ALERT.ID:EB.ALERT.POS

        R.EB.ALERT = EB.AlertProcessing.AlertRequest.Read(EB.ALERT.ID,Y.ERROR)

        EVENT.ID=R.EB.ALERT<EB.AlertProcessing.AlertRequest.ArEvent>


        LOCATE EVENT.ID IN FINAL.ARR<1,1> SETTING FOUND.POS THEN

            DEL FINAL.ARR<1,FOUND.POS>

        END

    REPEAT

RETURN

**********************
CHECK.INTERNAL.ALERTS:
**********************
*Removing the Internal subscription level tEC Items
*

    LIST.TEC.IDS = FINAL.ARR

    LOOP

        REMOVE TEC.ID.SEL  FROM LIST.TEC.IDS SETTING TEC.ID.SEL.POS

    WHILE TEC.ID.SEL:TEC.ID.SEL.POS

        R.TECITEM.CHK = EB.Logging.TecItems.Read(TEC.ID.SEL,Y.ERR)

        IF R.TECITEM.CHK THEN

            SEL.SUB.LEVEL =  R.TECITEM.CHK<EB.Logging.TecItems.TecItSubscriptionLevel>
            IF SEL.SUB.LEVEL NE 'INTERNAL' THEN
                FINAL.ARR2<1,-1> = TEC.ID.SEL
            END

        END

    REPEAT
    FINAL.ARR = FINAL.ARR2

RETURN
END
