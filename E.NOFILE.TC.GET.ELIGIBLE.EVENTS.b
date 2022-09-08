* @ValidationCode : Mjo0ODgzMDY5MjE6Q3AxMjUyOjE1ODM5OTgyMTY2OTE6cnZhcmFkaGFyYWphbjo2OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAzLjA6MTUxOjE0MQ==
* @ValidationInfo : Timestamp         : 12 Mar 2020 13:00:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 141/151 (93.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE EB.Channels
SUBROUTINE E.NOFILE.TC.GET.ELIGIBLE.EVENTS(FINAL.ARR)
*----------------------------------------------------------------------------------------------------------------
* Description:
* This subroutine is used to provide the list of eligible events for the particular account
*----------------------------------------------------------------------------------------------------------------
* Subroutine type : NOFILE
* Attached to     : STANDARD.SELECTION record NOFILE.TC.GET.ELIGIBLE.EVENTS for the enquiry TC.NOF.GET.ELIGIBLE.EVENTS
* Attached as     : NOFILE Enquiry routine
* Incoming        : Enquiry's selection and its value from common variables
* Outgoing        : FINAL.ARR - The List of TEC.ITEMS record eligible for the given account
*---------------------------------------------------------------------------------------------------------------
* Modification History :
* 25/05/16 - Enhancement 1694536 / Task 1745225
*            TCIB Componentization- Retail Functional Components
*
* 23/10/06 - EN_1957809 / Task 1957811
*            Alerts for TCIB16
*
* 24/05/17 - Task - 2126538 /Enhancement - 2117822
*            AC and DE product availability check has been done on the Company.
*            If AC is not installed NULL value is returned in the enquiry.
*            If DE is not installed the call to DAS on DE.MESSAGE.GROUP is suppressed.
*
* 05/09/19 - Enhancement 3327829 / Task 3327846
*            AC.GET.ELIGIBLE.EVENTS moved from ST to AC.
*
* 06/02/20 - Enhancement 3568228 / Task 3574705
*            Removing reference that have been moved from ST to CG
*
*---------------------------------------------------------------------------------------------------------------
    
    $USING AC.AccountOpening
    $USING AA.Framework
    $USING AA.Alerts
    $USING EB.Logging
    $USING EB.Reports
    $USING EB.AlertProcessing
    $USING EB.SystemTables
    $USING EB.Delivery
    $USING EB.DataAccess
    $USING EB.Template
    $USING EB.API
    $USING AC.Config
    $INSERT I_DAS.DE.MESSAGE.GROUP
    $INSERT I_DAS.EB.ALERT.REQUEST
*
    EB.API.ProductIsInCompany("AC", AC.isInstalled)
    IF NOT(AC.isInstalled) THEN
        FINAL.ARR =''
        RETURN
    END
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB PROCESS
*
    IF FINAL.ARR AND TEC.ITEMS.LIST THEN
        GOSUB AC.CHECK.DUPLICATE ;* Remove duplicate events form AC events array
    END
    IF FINAL.ARR AND ARRANGEMENT.ID THEN
        THE.LIST=DAS.EB.ALERT.REQUEST$CONTRACT.REF
        THE.ARGS=ARRANGEMENT.ID:@FM:'YES'
        GOSUB AA.CHECK.DUPLICATE ;* Remove duplicate events form AA events array
    END
    GOSUB CHECK.INTERNAL.ALERTS ;* Filter for Internal events.
*
    FINAL.ARR = CHANGE(FINAL.ARR,@VM,@FM) ;* Eligible Events Array
*
RETURN
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= Initialise>
INITIALISE:
*Do all the initialisations here, open files, get the Account number and the selection fields
    ACCT.NO = "" ;* Initialise the account number
    LOCATE "ACCOUNT.NO" IN EB.Reports.getDFields()<1> SETTING FIELD.POS THEN
        ACCT.NO = EB.Reports.getDRangeAndValue()<FIELD.POS>
    END
    FINAL.ARR = "" ;* Initialise the result array
    VALUE.ARR="" ;* Initialise deposit event array
    R.ACCT.REC = "" ;* Initialise account record
    ELIGIBLE.EVENTS.LIST = "" ;* Initialise eligible events list
    DATE.PART = "" ;* Initialise the date
    PRODUCT.ID = "" ;* Initialise the product Id
    ARRANGEMENT.ID = "" ;* Initialise the arrangement Id
    EFFECTIVE.DATE = "" ;* Initialise the effective date of arrangement
    CURRENCY = "" ;* Initialise the accout currency
    PROD.ALERTS.EVENTS = "" ;* Initialise the product events
    ARR.ALERTS.EVENTS  = "";* Initialise the arrangement events
    PL.LEND="LENDING" ;* Assign Lending product line
    PL.DEPOSIT="DEPOSITS" ;* Assign Deposit product line
    SKIP.TEC.ITEMS='ACCOUNT.AMEND.COND':@VM:'AA.ISSUE.BILL':@VM:'AA.AGE.OVERDUE':@VM:'AA.OVERDUE.ARRANGEMENT.GRACE':@VM:'AA.DISBURSE.ARRANGEMENT':@VM:'AA.ISSUE.CHASER':@VM:'AA.PAYOFF.ARRANGEMENT' ;* List of items to be skiped from result array
    SKIP.DEPOSIT.TEC.ITEMS='AA.ISSUE.BILL'
    isEventPublished = '1' ;* Initialise published event flag
    
    EB.API.ProductIsInCompany("DE", DE.isInstalled)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= Open Files>
OPENFILES:
* Open required files
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= Process>
PROCESS:
* Get the Account number and check if this an arrangement Id.
* If arrangement get the list of eligible TEC.ITEMS for this arrangement at the product level
* else get the list of eligible TEC.ITEMS at the account level using the core routine which reads
* the file ACCT.GROUP.EVENT
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
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= Arrangement Tec Items>
ARRANGEMENT.TEC.ITEMS:
* To get the arrangement related Events
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
        GOSUB TEC.ITEMS.ARR.ACCOUNT       ;* This will give the Available alert for selected product alone
    END
    IF PR.LINE EQ PL.DEPOSIT THEN
        GOSUB TEC.ITEMS.DEPOSIT
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= Tec Items for Arrangement Account >
TEC.ITEMS.ARR.ACCOUNT:
* Remove the unwanted events from the arrangement related events.
    THE.LIST = FINAL.ARR
    LOOP
        REMOVE TEC.ITEM.ID FROM THE.LIST SETTING TEC.POS
    WHILE TEC.ITEM.ID:TEC.POS
        IF NOT(TEC.ITEM.ID  MATCHES SKIP.TEC.ITEMS) THEN
            FINAL.ARR.EVENT<1,-1> = TEC.ITEM.ID ;* Events for Arrangement Account
        END
    REPEAT
*
    FINAL.ARR = FINAL.ARR.EVENT
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= Tec Items for Deposit >
TEC.ITEMS.DEPOSIT:
* Events for Deposit account
    LOOP
        REMOVE TEC.ITEM.ID FROM FINAL.ARR SETTING TEC.POS
    WHILE TEC.ITEM.ID:TEC.POS
        IF NOT(TEC.ITEM.ID  MATCHES SKIP.DEPOSIT.TEC.ITEMS) THEN
            R.TECITEM = EB.Logging.TecItems.Read(TEC.ITEM.ID,Y.ERR)
            TEC.VALUE = R.TECITEM<EB.Logging.TecItems.TecItValue>
            TEC.ID=TEC.VALUE[1,7]
            IF TEC.ID NE PL.LEND THEN
                VALUE.ARR<1,-1>=TEC.ITEM.ID ;* Events for Deposit
            END
        END
    REPEAT
*
    FINAL.ARR = VALUE.ARR
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= Check Duplicate >
AC.CHECK.DUPLICATE:
* Remove Duplicate from AC Events
* Read the account record and get the list of Alerts/TEC.ITEMS which are already subscribed
* and remove them from the final list FINAL.ARR
    LOOP
        REMOVE TEC.ITEM.ID FROM TEC.ITEMS.LIST SETTING TEC.POS
    WHILE TEC.ITEM.ID:TEC.POS
        LOCATE TEC.ITEM.ID IN FINAL.ARR<1,1> SETTING FOUND.POS THEN
            DEL FINAL.ARR<1,FOUND.POS> ;* Delete duplicate events from result array
        END
    REPEAT
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= Check Duplicate for Arrangement>
AA.CHECK.DUPLICATE:
* Remove Duplicate for AA Events
*CALL DAS('EB.ALERT.REQUEST',THE.LIST,THE.ARGS,'')
    EB.DataAccess.Das('EB.ALERT.REQUEST', THE.LIST, THE.ARGS, '')
    LOOP
        REMOVE EB.ALERT.ID FROM THE.LIST SETTING EB.ALERT.POS
    WHILE EB.ALERT.ID:EB.ALERT.POS
        R.EB.ALERT = EB.AlertProcessing.AlertRequest.Read(EB.ALERT.ID,Y.ERROR) ;* Read Eb Alert Request application
        EVENT.ID=R.EB.ALERT<EB.AlertProcessing.AlertRequest.ArEvent>
        LOCATE EVENT.ID IN FINAL.ARR<1,1> SETTING FOUND.POS THEN
            DEL FINAL.ARR<1,FOUND.POS> ;* Delete duplicate events from result array
        END
    REPEAT
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= Check Internal Alerts >
CHECK.INTERNAL.ALERTS:
*Removing the Internal subscription level TEC Items
    LIST.TEC.IDS = FINAL.ARR

    LOOP
        REMOVE TEC.ID.SEL  FROM LIST.TEC.IDS SETTING TEC.ID.SEL.POS
    WHILE TEC.ID.SEL:TEC.ID.SEL.POS
        R.TECITEM.CHK = EB.Logging.TecItems.Read(TEC.ID.SEL,Y.ERR)
        IF R.TECITEM.CHK THEN
            SEL.SUB.LEVEL =  R.TECITEM.CHK<EB.Logging.TecItems.TecItSubscriptionLevel>
            IF SEL.SUB.LEVEL NE 'INTERNAL' THEN ;* Filter the Internal events from result array
                EVENT.TYPE.ID=R.TECITEM.CHK<EB.Logging.TecItems.TecItEventType>
                EVENT.DESCRIPTION=R.TECITEM.CHK<EB.Logging.TecItems.TecItDescription,1>
                EVENT.INHERIT=R.TECITEM.CHK<EB.Logging.TecItems.TecItInherit,1>
                EVENT.FIELD.DESC=R.TECITEM.CHK<EB.Logging.TecItems.TecItFieldDesc,1>
                EVENT.FIELD.OPERAND=R.TECITEM.CHK<EB.Logging.TecItems.TecItOperand,1>
                EVENT.FIELD.VALUE=R.TECITEM.CHK<EB.Logging.TecItems.TecItValue,1>
                SUBSCRIPTION.LEVEL=R.TECITEM.CHK<EB.Logging.TecItems.TecItSubscriptionLevel>
                R.EVENT.TYPE=EB.SystemTables.EventType.Read(EVENT.TYPE.ID, EVENT.TYPE.ERR) ;* Get Event type
                EB.ACTIVITY.ID=R.EVENT.TYPE<EB.SystemTables.EventType.EvnTypEbActivity>
                R.EB.ADVICES=EB.Delivery.Advices.Read(EB.ACTIVITY.ID, EB.ADVICES.ERR) ;* Read Advices Record
                GOSUB GET.GROUP.ID
                AC.FINAL.ARRAY<1,-1> = TEC.ID.SEL:"*":GROUP.ID:"*":EVENT.DESCRIPTION:"*":EVENT.INHERIT:"*":EVENT.FIELD.DESC:"*":EVENT.FIELD.OPERAND:"*":EVENT.FIELD.VALUE:"*":SUBSCRIPTION.LEVEL
            END
        END
    REPEAT
*
    FINAL.ARR = AC.FINAL.ARRAY
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= Get Group Id >
GET.GROUP.ID:
*Get Message Group Id
    GROUP.ID=''
    IF EB.ADVICES.ERR ELSE
        MESSAGE.APP.ID=R.EB.ADVICES<EB.Delivery.Advices.AdvMessageType>
        THE.LIST=dasMessageApp
        THE.ARGS=MESSAGE.APP.ID:"..."
        IF DE.isInstalled THEN
            EB.DataAccess.Das("DE.MESSAGE.GROUP", THE.LIST, THE.ARGS, "") ;* Get the message group Id based on Messsage App
            GROUP.ID=THE.LIST<1>
        END
    END
RETURN
*-----------------------------------------------------------------------------------------------------------------------
END
