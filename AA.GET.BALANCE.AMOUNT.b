* @ValidationCode : MjotNzUyNjQ1ODcwOkNQMTI1MjoxNjA3OTMyODQ2NDAwOm1hbmlydWRoOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMjAyMDA5MTktMDQ1OTo4Mzo4Mg==
* @ValidationInfo : Timestamp         : 14 Dec 2020 13:30:46
* @ValidationInfo : Encoding          : CP1252
* @ValidationInfo : User Name         : manirudh
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 82/83 (98.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-131</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Framework
SUBROUTINE AA.GET.BALANCE.AMOUNT(PROPERTY.ID, START.DATE, END.DATE, CURRENT.DATE, BALANCE.TYPE, ACTIVITY.IDS, CURRENT.VALUE, START.VALUE, END.VALUE)

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
*                         Current Value will be  passed only when multi.arrangement is set for the periodic attribute and
*                         value will be in the following format
*                         Multi.arrangement->CRA    -  arrangement.id:@VM:account.id
*                         Multi.arrangement->BUNDLE -  arrangement.id:@VM:account.id:@VM:RecipientCcy
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
*            New routine to get the balance amount
*            used in rule evaluation
*
* 19/02/11 - EN_56307
*            Task: 136334
*            Locate statement added to locate the Balance amount in the end date
*
* 10/03/11 - 159892
*            Ref: 56308
*            Balance amount should not be absolute since for Accounts PL balance
*            can be negative or positive
*
* 05/04/11 - Task: 185974
*            Defect: 183878
*            Code changes to include the Current activity amount with the END.VALUE
*
* 13/04/11 - Task : 191239
*            Defect : 183803
*            Code changes to avail current balances without locating effective date.
*
* 25/06/11 - Task: 233604
*            Defect: 232907
*            If start date and end date is equal then set start value to zero. On same
*            date it is not required to know start value.
*
* 28/06/11 - Task : 235280
*            Defect : 232743
*            Dont blindly add the TXN amount for ACCOUNTs. DIRECT.ACCOUNTING changes have already updated
*            the balances correctly. So, dont add the amounts - it would double it.
*
* 31/10/13 - Task : 825041
*          - Defect : 799787
*          - If settlement instruction are given inside AA, negative amount is passed as END.VALUE
*
* 29/11/14 - 1184118
*            Ref: 1183050
*            Do not set DIRECT.ACCTNG for activities that doesn't raise direct accounting
*
* 04/12/14 - Task : 1188606
*            Defect : 1184404
*            Current balance goes below the specified value because of the current transaction amount included
*
* 29/11/14 - Defect:1183050
*            Ref: 1225357
*            We need too loop through all balances if the balance type is "VIRTUAL"

* 10/05/18 - Enhancement : 2775224
*            Task        : 2765051
*            Changes will be made in this routine to read the 7th parameter i.e CURRENT.VALUE and assign the same to ACCOUNT.ID if present.
*
* 14/12/18 - Defect : 2902549
*            Task   : 2903683
*            For Multi arrangement remove today's balance movement
*
* 18/12/18 - Defect : 2902549
*            Task   : 2907906
*            For end date only today's balance should be removed
*
* 12/11/20 - Enhancement : 3650102
*            Task        : 4126087
*   		 For EPP fetch the balances and actvities from the external system using B&A microservice
*
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $USING AC.BalanceUpdates
    $USING AC.SoftAccounting
    $USING AA.Framework
    $USING AA.Rules
    $USING EB.API
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB GET.REAL.BALANCE.TYPE   ;* Check virtual balance type.
    GOSUB PROCESS                 ;* Find balance amount for the dates

RETURN

*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise para in the sub routine</desc>
INITIALISE:

    CHECK.END.DATE = END.DATE        ;* Required end date
    CHECK.START.DATE = ''
    CHECK.START.DATE = START.DATE    ;* Required start date
    INITIAL.AVAIL.BAL = ''
    START.VALUE = 0
    END.VALUE = 0
    BALANCE.TYPE.LIST = '' ;* List of balance to evaluate.
    ARR.CCY        = AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrCurrency> ;* get arrangement currency
    CURR.CCY       = CURRENT.VALUE<1,3> ;* get processing arrangement currency from current value
    CURRENT.ACCOUNT= ''
 
RETURN

*-----------------------------------------------------------------------------

*** <region name= Get Real Balance Type>
*** <desc>If the given balance is a VIRTUAL balance then we need to load the real balance </desc>
GET.REAL.BALANCE.TYPE:

    BALANCE.TYPE.LIST = BALANCE.TYPE

    R.BALANCE.TYPE = ''
    R.BALANCE.TYPE = AC.SoftAccounting.BalanceType.CacheRead(BALANCE.TYPE.LIST, VAL.ERR)
    IF R.BALANCE.TYPE<AC.SoftAccounting.BalanceType.BtReportingType> = "VIRTUAL" THEN  ;* I am not a real balance
        BALANCE.TYPE.LIST = R.BALANCE.TYPE<AC.SoftAccounting.BalanceType.BtVirtualBal> ;* Load real balance
    END

RETURN

*** <region name= Process>
*** <desc>Process para in the subroutine</desc>
PROCESS:

    BALANCE.COUNT = 1             ;* Balance count
    BALANCE.TOT = DCOUNT(BALANCE.TYPE.LIST,@VM) ;* Total number of balances

    LOOP
    WHILE BALANCE.COUNT LE BALANCE.TOT

        BALANCE.NAME = BALANCE.TYPE.LIST<1,BALANCE.COUNT>   ;* Current balance type

        IF CURRENT.VALUE<1,1> EQ "EXT.BAL.REQUEST" THEN
            GOSUB GET.EPP.BALANCES
        END ELSE
            GOSUB GET.CORE.BALANCES
        END
    
        BALANCE.COUNT ++
    REPEAT
 
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get EPP Balances>
*** <desc> Get Balances from the external system </desc>
GET.EPP.BALANCES:
    
    BALANCE.AMOUNT = 0

	AA.Framework.GetEppPeriodBalances(CURRENT.VALUE<1,2>, BALANCE.TYPE, DATE.OPTIONS,CHECK.START.DATE,CHECK.END.DATE, "", TOTAL.BALANCE.DETAILS, ERR.MSG)

    AA.Framework.BuildEppBalanceDetails(CURRENT.VALUE<1,2>, BALANCE.TYPE, TOTAL.BALANCE.DETAILS, BAL.DETAILS)
   
    BALANCE.MOVEMENTS = BAL.DETAILS<1>
    CREDIT.MOVEMENTS = BAL.DETAILS<2>
    DEBIT.MOVEMENTS = BAL.DETAILS<3>
    CLOSING.BALANCES = BAL.DETAILS<4>

    NO.MOVEMENTS = DCOUNT(BALANCE.MOVEMENTS, @VM)
    
    START.VALUE = CLOSING.BALANCES<1,1>
    END.VALUE = CLOSING.BALANCES<1,NO.MOVEMENTS>
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get CORE Balances>
*** <desc> Get Balances from the core Transact system </desc>
GET.CORE.BALANCES:
    
*** Find start balance
    IF CHECK.START.DATE NE CHECK.END.DATE THEN  ;* No need to find start balance when start date and end date are same
        CHECK.DATE = CHECK.START.DATE
        GOSUB GET.BALANCE.AMOUNT                ;* Get the amount for this balance name & start date
        START.VALUE += BALANCE.AMOUNT           ;* Add the amounts
    END

*** Find end balance
    CHECK.DATE = CHECK.END.DATE
    IF CURRENT.VALUE AND CHECK.START.DATE NE CHECK.END.DATE  THEN ;* For Multi arrangement remove today's date movement and if start and end date are not same
        EB.API.Cdt("", CHECK.DATE, "-1C")
    END
    GOSUB GET.BALANCE.AMOUNT               ;* Get the amount for this balance name & end date
    
    END.VALUE += BALANCE.AMOUNT            ;* Add the amounts
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
    
*** <region name= Get Balance Amount>
*** <desc>Get balance amount for this balance name</desc>
GET.BALANCE.AMOUNT:

    ERR.MSG = ''
    BAL.DETAILS = ''          ;* The current balance figure
    DATE.OPTIONS = ""
    DATE.OPTIONS<2> = "ALL"   ;* Include all unauthorised movements
    
    IF NOT(ARR.CCY) AND CURRENT.VALUE<1,4> THEN ;*Applicable for bundle, amount converted to recipient currency
        
        ARR.CCY = CURRENT.VALUE<1,4>  ;* get master Currency if multiArrangement is bundle
        
    END
    
    CURRENT.ACCOUNT = CURRENT.VALUE<1,2> ;* current value from evaluate periodic rules is passed as Arrid:@VM:Accntid
    
    IF CURRENT.ACCOUNT THEN  ;* current value which is passed from the rule val routine  then assign it to account.id
        
        ACCOUNT.ID   = CURRENT.ACCOUNT
        
    END ELSE   ;* if not get account id from the common variable
    
        ACCOUNT.ID = AA.Framework.getLinkedAccount()
        
    END
    
    BALANCE.AMOUNT = 0
    
    AA.Framework.GetPeriodBalances(ACCOUNT.ID, BALANCE.NAME, DATE.OPTIONS, CHECK.DATE, "", "", BAL.DETAILS, ERR.MSG)
    
    IF BAL.DETAILS<AC.BalanceUpdates.AcctActivity.IcActBalance> THEN
        BALANCE.AMOUNT = BAL.DETAILS<AC.BalanceUpdates.AcctActivity.IcActBalance> ;* Add only having balance.
    END
    
    GOSUB GET.AMOUNT.IN.ARR.CCY
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= get amount in arr ccy>
*** <desc>To get the amount in the arrangement currency </desc>
GET.AMOUNT.IN.ARR.CCY:
    
    IF CURR.CCY AND ARR.CCY NE CURR.CCY THEN ;* if master currrency is passed in the current.value argument then currency movements is called
        
        AA.Rules.GetCcyMovements(CURRENT.VALUE<1,1>, '1', ARR.CCY, CURR.CCY, BAL.DETAILS, BALANCE.TYPE, CHECK.START.DATE, CHECK.END.DATE, PRIN.DATA)
        BALANCE.AMOUNT =PRIN.DATA<2>
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
