* @ValidationCode : MjotMTk1NTA5ODg2OmNwMTI1MjoxNjAxMzExMjI3OTY4Om1hcmNoYW5hOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MToxNDE6MTA1
* @ValidationInfo : Timestamp         : 28 Sep 2020 22:10:27
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : marchana
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 105/141 (74.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>61</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.ARRANGEMENT.BALANCE.TYPES
*
** Enquiry routine to return a list of balance types for an
** arrangement for a given date
** needs to look at the properties of the arrangement and
** add the possible prefixes and suffixes to the property
** balance types and associated balance for the date will be
** added to the arrangement record
*
** Uses
**  R.RECORD - AA.ARRANGEMENT layout
**  O.DATA  - ARRANGEMENT ID
**  ENQ.SELECTION - to find effective date
** Updates
**  R.RECORD
*
** 22/08/07 - BG_100014998
**            Get the list of products by calling AA.GET.ARRANGEMENT.PRODUCT
**
** 10/11/07 - BG_100015419
*             Add balance for properties with no activity update and virtual
*
* 01/10/09 - BG_100025311
*            Replaced the call to AA.GET.ARRANGEMENT.PRODUCT with AA.GET.ARRANGEMENT.PROPERTIES
*            to get the list arrangement of properties.
*            Ref: HD0935492
*
* 23/10/09 - EN_10004405
*            Ref : SAR-2008-11-06-0009
*            Deposits Infrastructure - Review Activities and Actions
*
* 25/04/2016 - Defect : 1682818
*              Task   : 1706284
*              Loan report summary of Overdue is not displaying Principal overdue and Interest overdue
*
* 13/12/17 - Enhancement : 2142378
*            Task : 2336599
*            Get the Balance prefix of a property class for a product line using API AA.GET.BALANCE.PREFIX
*
* 22/04/20 - Task   : 3691608
*            Defect : 3691601
*            Performance Improvement in AA.REPORT
*
* 08/09/20 - Enhancement 3932648 / Task 3952625
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF

* 11/08/20 - Task : 3904772
*            Defect: 3897601
*            Return the values in an array instead of assign it in R.RECORD
****************************************************************
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AC.SoftAccounting
    $USING AC.API
    $USING BF.ConBalanceUpdates
    $USING RE.ConBalanceUpdates
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.DataAccess

*
*
    GOSUB INITIALISE
    GOSUB GET.BALANCE.TYPES
    GOSUB ADD.BALANCES
    CONVERT @VM TO "~" IN RET.ARRAY
    EB.Reports.setOData(RET.ARRAY)
    
    
*
RETURN
*
*-----------------------------------------------------------------------------
INITIALISE:

    ARR.NO = EB.Reports.getOData()
    ACCT.NO = EB.Reports.getRRecord()<AA.Framework.Arrangement.ArrLinkedApplId>
    BALANCE.TYPE.POS = 50     ;* Balance type field in record
    BALANCE.BK.AMT.POS = 51   ;* Booking dated balance for balance type
    BALANCE.VD.AMT.POS = 52   ;* Value Dated balance for balance type
*
    LOCATE "BALANCE.DATE" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
        EFF.DATE = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
        EFF.DATE = EB.SystemTables.getToday()
    END
*
    AC$BALANCES.LIST = ""
    GOSUB BUILD.AC.BALANCES.LIST

    FULL.BALANCE.LIST = AC$BALANCES.LIST<1>

    PRODUCT.LINE = EB.Reports.getRRecord()<AA.Framework.Arrangement.ArrProductLine>
*
RETURN
*
*-----------------------------------------------------------------------------
BUILD.AC.BALANCES.LIST:
*
** Get a list AC.BALANCE.TYPES and store a separate list of virtual balances
*
    F.AC.BALANCE.TYPE = ''
*
*** Just get all arrangement related balance from ECB
    R.EB.CONTRACT.BALANCE.RECORD = ""
    AC.API.EbReadContractBalances(ACCT.NO, R.EB.CONTRACT.BALANCE.RECORD, "", "")
    BALANCE.NAMES = RAISE(R.EB.CONTRACT.BALANCE.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbCurrAssetType>)
    BAL.IDX = ''
    LOOP
        REMOVE BALANCE.NAME FROM BALANCE.NAMES SETTING POS
    WHILE BALANCE.NAME : POS
        BALANCE.TYPE.REC = ''
        BALANCE.TYPE.REC = AC.SoftAccounting.BalanceType.CacheRead(BALANCE.NAME, "")
        BAL.IDX += 1
        AC$BALANCES.LIST<1,BAL.IDX> = BALANCE.NAME
        AC$BALANCES.LIST<2,BAL.IDX> = LOWER(BALANCE.TYPE.REC<AC.SoftAccounting.BalanceType.BtVirtualBal>)
        AC$BALANCES.LIST<3,BAL.IDX> = BALANCE.TYPE.REC<AC.SoftAccounting.BalanceType.BtActivityUpdate>
    REPEAT
*
    IF AC$BALANCES.LIST = '' THEN
        AC$BALANCES.LIST = "NONE"       ;* Stop repeated selection
    END
*
RETURN
*
*-----------------------------------------------------------------------------
GET.BALANCE.TYPES:
*
** Get the list of properties from the arrangement record
** then from the property class get the prefixes
** also get a list of all balance types so that we can look for virtual balances
** and any that are created by soft accounting
*

* Forcefully append null values into ARR.INFO, so that, values are not picked from common in AA.GET.ARRANGEMENT.PROPERTIES
* This is done to avoid common variables of some other arrangement getting assinged from cache, when multiple arrangment details are accessed within
* the same session
    ARR.INFO = ARR.NO:@FM:'':@FM:'':@FM:'':@FM:'':@FM:''
    tmp.R.RECORD = EB.Reports.getRRecord()
    AA.Framework.GetArrangementProperties(ARR.INFO, EFF.DATE, tmp.R.RECORD, PROPERTY.LIST)
    EB.Reports.setRRecord(tmp.R.RECORD)
*
** Balance List will contain:
** 1,x name
** 2,x whether ACTIVITY is updated or not
** 3,x,y for a virtual balance the component balances
*
    IDX = ''
    BALANCE.LIST = ''
    LOOP
        REMOVE PROPERTY FROM PROPERTY.LIST SETTING YD
    WHILE PROPERTY:YD
        PROPERTY.CLASS = ''
        AA.ProductFramework.GetPropertyClass(PROPERTY, PROPERTY.CLASS)
        GOSUB GET.PREFIXES
    REPEAT
*
** Now go through the balances that aren't related to the properties
** and are not virtual to see if we need to get any of them
** FULL.BALANCES.LIST contains a list of balances not linked to the
** product
*
    LOOP
        REMOVE BALANCE.NAME FROM FULL.BALANCE.LIST SETTING YD
    WHILE BALANCE.NAME:YD
        LOCATE BALANCE.NAME IN AC$BALANCES.LIST<1,1> SETTING BAL.POS THEN
            IF AC$BALANCES.LIST<2,BAL.POS> = "" THEN        ;* Not virtual
                IDX += 1
                BALANCE.LIST<IDX> = BALANCE.NAME
                LOCATE BALANCE.NAME IN FULL.BALANCE.LIST<1,1> SETTING BAL.POS THEN
                    DEL FULL.BALANCE.LIST<1,BAL.POS>
                END
            END
        END
    REPEAT
*
** Finally look for the virtual balances in the list
*
    FULL.BALANCE.LIST = FULL.BALANCE.LIST
    LOOP
        REMOVE BALANCE.NAME FROM FULL.BALANCE.LIST SETTING YD
    WHILE BALANCE.NAME:YD
        IDX += 1
        BALANCE.LIST<IDX> = BALANCE.NAME
    REPEAT
*
RETURN
*
*-----------------------------------------------------------------------------
GET.PREFIXES:
*
** Find the balance prefixes and add the balance types to a
** list of balance types for which we need to retrieve the
** balance
*
    RETURN.ERROR = ""       ;* return error if any
    BALANCE.PREFIX = ""     ;* Balance prefix for a product line
    AA.Framework.GetBalancePrefix(PRODUCT.LINE, PROPERTY.CLASS, "", BALANCE.PREFIX, RETURN.ERROR)  ;* Get balance prefixes of a property class for a product line
    
    PREFIX.IDX = ''
    LOOP
        PREFIX.IDX += 1
        
    WHILE BALANCE.PREFIX<PREFIX.IDX>
        BALANCE.NAME = BALANCE.PREFIX<PREFIX.IDX>:PROPERTY
        IF BALANCE.NAME THEN
            IDX += 1
            BALANCE.LIST<IDX> = BALANCE.NAME
            LOCATE BALANCE.NAME IN FULL.BALANCE.LIST<1,1> SETTING BAL.POS THEN
                DEL FULL.BALANCE.LIST<1,BAL.POS>
            END
        END
    REPEAT

*
RETURN
*
*-----------------------------------------------------------------------------
ADD.BALANCES:
*
** Now for each balance in the list call EB.GET.ACCT.BALANCE to retrieve
** the balance we want
*
    NEXT.BAL = 0
    IDX = 0
    LOOP
        IDX += 1
        BALANCE.TYPE = BALANCE.LIST<IDX>
    WHILE BALANCE.TYPE
        LOCATE BALANCE.TYPE IN AC$BALANCES.LIST<1,1> SETTING BAL.POS THEN
            ACTIVITY.BALANCE = AC$BALANCES.LIST<3,BAL.POS>  ;* Indicates we'll use ACCT.ACTIVITY
            VIRTUAL.BALANCES = AC$BALANCES.LIST<2,BAL.POS>
            ACCT.NO.BAL = ACCT.NO:".":BALANCE.TYPE
            BOOK.OR.VALUE = "BOOKING"
            GOSUB GET.BALANCE
            BD.BAL = BAL.AMT
            BOOK.OR.VALUE = 'VALUE'
            GOSUB GET.BALANCE
            VD.BAL = BAL.AMT
            IF VD.BAL OR BD.BAL THEN
                NEXT.BAL +=1
                RET.ARRAY<1,NEXT.BAL> = BALANCE.TYPE:"*":BD.BAL:"*":VD.BAL
                RET.BALANCE.TYPES<1,NEXT.BAL> = BALANCE.TYPE
                RET.BALANCE.BK.AMT<1,NEXT.BAL> = BD.BAL
                RET.BALANCE.VD.AMT<1,NEXT.BAL> = VD.BAL
            END
        END
    REPEAT
*
RETURN
*
*-----------------------------------------------------------------------------
GET.BALANCE:
*
    BAL.AMT = ''    ;* Returned balance
    CR.MVMT = ''    ;* Credit movement for date
    DR.MVMT = ''    ;* Debit movement for date
    BEGIN CASE
        CASE VIRTUAL.BALANCES     ;* Get the balance from the values we've already calculated
            GOSUB CALCULATE.VIRTUAL.BALANCE
        CASE ACTIVITY.BALANCE     ;* Get the dated balance
            AC.API.EbGetAcctBalance(ACCT.NO.BAL, "", BOOK.OR.VALUE, EFF.DATE, "", BAL.AMT, CR.MVMT, DR.MVMT, "")
        CASE EFF.DATE = EB.SystemTables.getToday()     ;* Go to EB.CONTRACT.BALANCES for the current balance
            BF.ConBalanceUpdates.AcGetEcbBalance(ACCT.NO, BALANCE.TYPE, "", "", BAL.AMT, "")
    END CASE
*
RETURN
*
*-----------------------------------------------------------------------------
CALCULATE.VIRTUAL.BALANCE:
*
** We'll calculate this from the balances that we will have already extracted
** We do this as although EB.GET.ACCT.BALANCE handles virtual balances it only
** does so if the balance is in ACCT.ACTIVITY which may not always be the case
** for some balances
*
    LOOP
        REMOVE BAL.NAME FROM VIRTUAL.BALANCES SETTING YD
    WHILE BAL.NAME:YD
        LOCATE BAL.NAME IN RET.BALANCE.TYPES<1, 1> SETTING BAL.POS THEN
            IF BOOK.OR.VALUE = "BOOKING" THEN
                BAL.AMT += RET.BALANCE.BK.AMT<1, BAL.POS>
            END ELSE
                BAL.AMT += RET.BALANCE.VD.AMT<1, BAL.POS>
            END
        END
    REPEAT
*
RETURN
*
*-----------------------------------------------------------------------------
*
END
