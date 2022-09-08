* @ValidationCode : MjotNzM3NTkxODYzOmNwMTI1MjoxNjA2MjM1MTYxMDg0OmprYXJ0aGlrYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA5LjIwMjAwODI4LTE2MTc6NTEwOjIwMw==
* @ValidationInfo : Timestamp         : 24 Nov 2020 21:56:01
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : jkarthika
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 203/510 (39.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>477</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LI.ModelBank
SUBROUTINE E.LIM.LIAB.SELECTION(Y.ID.LIST)
*
**** =============================================================== ****
**** Prepares a list of limit and account records to be processed    ****
**** for enquiry on customers. The ID list contains all limit Ids    ****
**** followed by any customer accounts for all the customers who     ****
**** have the same liability group.                                  ****
**** =============================================================== ****
*
*------------------------------------------------------------------------
*
*              M O D I F I C A T I O N S
*
* 05 SEP 94 - GB9400998
*             In the equal processing allow for customer number that is
*             part of a Liability structure but not the lead.
*
* 09/05/96 - GB9600597
*            Show Securities in LIOAB enquiry
*
*
* 10/05/96 - GB9600612
*            Add non Globus collateral
*
* 19/07/96 - GB9601003
*            Securities may not exist, set the flag in either case
*
* 22/07/97 - GB9700845
*            Incorrectly setting local variable CO.INSTALLED.  Enquiry
*            coming up with '....Improper data type.....' error message.
*
* 11/09/98 - GB9801141 / G99800168
*            a) Collateral was shown as three times its value in a multi
*            company environment with three companies.
*
*            b) Pass company mnemonic to E.LC.BUILD.BEN.LIST.
*
* 09/04/04 - GLOBUS_CI_10018889
*            Variable Y.I should be incremented when Selection Criteria
*            Operand is NE.
*
* 18/10/05 - CI_10035737
*            Select the accounts from lead compnay only.
*
* 13/03/07 - GLOBUS_EN_10003200
*            Removal of POS.CON.SCAC
*
* 24/04/07 - GLOBUS_BG_100013586
*            Securities Held gets doubled
*
* 24/04/07 - GLOBUS_BG_100013586
*            Securities Held gets doubled
*
* 19/07/07 - EN_10003427 / BG_100014749
*            Co Titular enhancement, added customer container expansion for
*            customers with related customers.
*            Ref: SAR-2006-12-01-0003
*
* 22/11/07 - BG_100016001
*            Use the Container marker from CUSTOMER.RELATIONS to ensure
*            only related customers from a Container are used.
*
* 19/11/08 - CI_10058972
*            check for company installed when processing the company
*
* 09/09/09 - CI_10065969
*            Updated display of enquiry output.
*
* 13/04/10 - RTC WORK ITEM 39955
*            Since the variable PROCESS.AC resets for each customer, variable is
*            holding the value that was set for the last processed customer only.
*
* 14/04/10 - Defect - 32883 / Task - 33765
*            EXECUTE is replaced with DAS
* 18/10/10 - Task - 84420
*            Replace the enterprise(customer service api)code into  Banking framework related
*            routines which reads CUSTOMER.
*
* 23/05/11 - Enhancement - 182581 / Task- 191536
*            Moving Balances to ECB from Account Balance Fields.
*
* 19/04/12 - Defect 389501 / Task 391603
*            Liquidated collaterals are filtered from the selection list,
*            not to display in enquiry output.
*
* 13/02/13 - Defect 585905 / Task 450894
*            Group Limit changes for Liab enquiry.
*
* 28/02/14 - Defect_927270 Task_927805
*            The enquiry LIAB fatal out when SEC.ACC.MASTER is shared.
*
* 21/04/14 - Defect 931841 / Task 977672
*            The enquiry LIAB displays the limit for restricted customers.
*            Changes have been done to check the allowed and restricted customer setup
*            defined in the limit.
*
* 08/05/13 - Defect 986559 / Task 992303
*            Changes has been done to display even the sub group limits while
*            running the LIAB enquiry for the master group
*
* 13/05/14 - Enhancement 836368 / Task 931206
*            Changes have been done to revalue the collateral and do reallocation
*            when there is online update and collateral revaluation setup.
*
* 20/04/15 - Defect 1309000 / Task 1321014
*            When LIAB enquiry is launched for a customer in two sessions in desktop, system
*            hangs due to lock in LI.CO.UPDATE.I routine. Changes have been done to pass the APPLICATION
*            as "LIMIT.TXNS" and release the lock in LI.CO.UPDATE.III routine for that application
*
* 31/07/15 - Defect 1424038 / Task 1425099
*            Code change done such that the alloc work list is populated only if REAL.TIME.ALLOC is set as
*            'Yes' in the Collateral Parameter.
*
* 12/08/15 - Task 1436233
*            Changing the selection of customer record using CHECK.LIAB
*            I-Desc field by handling that I-Desc condition in this selection
*            routine for TAFJ compatibility.
*
* 12/12/15 - Enhancement 1175200 / Task 1271125
*            If a collateral is marked for exclusion, then collateral will be updated with status "EXC".
*            When collateral is in that status, the value must not be considered. Changes have been done
*            to skip the collateral if the status is "LIQ" or "EXC"
*
* 21/08/17 - EN 2205157 / Task 2237727
*            use API instead of direct I/O for LIMIT related files
*            LIMIT.LIABILITY, LIMIT.LINES
*
* 08/11/17 - EN 2322180 / Task 2322183
*            Support for new limit key and customer group id
*
* 07/03/18 - Defect 2485201 / Task 2486303
*            PAT common is cleared before calling JOURNAL.UPDATE and set after returning back
*            to avoid JOURNAL.UPDATE triggering next PW activity
*
* 28/06/18 - Defect 2647798 / Task 2652960
*            List of customers formed by DAS to be updated in variable CUSTOMER.LIST when ALL is passed as
*            Liability Number in LIAB enquiry
*
* 25/04/20 - Enhancement 3622992 / Task 3622995
*            Ignore the Limit records with limit product that are marked for third party exposure as YES.
*            Include such limit records for display only when user explicitly
*            queries with SHOW.THIRD.PARTY.EXPOSURE as YES.
*
* 03/04/20 - Enhancement 3793141 / Task 3979294
*            L3 API- Flag introduced to skip collateral revaluation when its called from L3 Java.
*
* 04/11/2020 - Enhancement 4038365 / Task 4038373
*              Modified the code to display the Non-core asset linked to Collaterals through EXTERNAL Collateral Type
*
* 23/11/2020 - Enhancement 4051489 / Task 4096336
*              Modified the code to display the Property and Mortgage records linked to Collaterals through PROPERTY and MORTGAGE Collateral Type
*------------------------------------------------------------------------
    $INSERT I_CustomerService_Parent
    $INSERT I_DAS.SECURITY.POSITION
    $INSERT I_DAS.CUSTOMER

    $USING ST.CompanyCreation
    $USING CO.Contract
    $USING CO.Config
    $USING LC.Contract
    $USING LC.Config
    $USING AC.AccountOpening
    $USING LI.Config
    $USING EB.DataAccess
    $USING EB.Display
    $USING ST.Customer
    $USING AC.CashFlow
    $USING SC.ScoPortfolioMaintenance
    $USING LC.Foundation
    $USING LI.GroupLimit
    $USING EB.TransactionControl
    $USING SC.ScvValuationUpdates
    $USING EB.SystemTables
    $USING EB.Reports
    $USING PW.Foundation

**** =============================================================== ****
MAIN.PARA:
*--------
*
    Y.ID.LIST = ''
    ALLOC.WORK.LIST = ''
    
    LOCATE "LIABILITY.NUMBER" IN EB.Reports.getDFields()<1> SETTING LIAB.POS ELSE
        LIAB.POS = ''
    END
    
    THIRD.PARTY.EXPOSURE = ''
    THIRD.PARTY.POS = ''
    LOCATE "SHOW.THIRD.PARTY.EXPOSURE" IN EB.Reports.getDFields()<1> SETTING THIRD.PARTY.POS THEN
        THIRD.PARTY.EXPOSURE = EB.Reports.getDRangeAndValue()<THIRD.PARTY.POS>
    END
    
    IF EB.Reports.getDLogicalOperands()<LIAB.POS> = '' OR EB.Reports.getDLogicalOperands()<LIAB.POS> = 6 OR EB.Reports.getDLogicalOperands()<LIAB.POS> = 7 THEN
        RETURN
    END

    GOSUB OPEN.ALL.FILES:

    GOSUB PROCESS.PARA:

RETURN

**** =============================================================== ****
OPEN.ALL.FILES:
*-------------

* Open all files required for processing.

    LOCATE "SC" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING SC.POS THEN
        SC.INSTALLED = 1
    END ELSE
        SC.INSTALLED = 0
    END

    LOCATE "CO" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING CO.POS THEN
        CO.INSTALLED = 1      ;* GB9700845
    END ELSE        ;* GB9700845
        CO.INSTALLED = 0      ;* GB9700845
    END

    LOCATE "LC" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING LC.POS THEN
        LC.INSTALLED = 1
    END ELSE
        LC.INSTALLED = 0
    END

RETURN
*
**** =============================================================== ****
PROCESS.PARA:
*-----------
*
* Establish a list of the possible companies that may contain CUSTOMER
* ACCOUNT records.
*
    YR.COMP.CHECK = ""
    YR.COMPANY.CHECK = ST.CompanyCreation.CompanyCheck.Read("CUSTOMER", CC.ERR)
*
* Take all companies sharing the limit files
*
    CURR.COMP = EB.SystemTables.getIdCompany()
    LOCATE CURR.COMP IN YR.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocCompanyCode,1> SETTING BMV ELSE
        COMPANY.LIST = YR.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocUsingCom>
        FIND CURR.COMP IN COMPANY.LIST SETTING BMF,BMV,BMS ELSE
            EB.SystemTables.setText("COMPANY MISSING FROM F.COMPANY.CHECK ID = CUSTOMER")
            EB.Display.Rem()
        END
    END

    YCUST.ACCT.MNEMONICS = YR.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocCompanyMne,BMV>
    YCUST.COMPANY = YR.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocCompanyMne,BMV>          ;* Customer Company Mnemonic
    IF YR.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocUsingMne,BMV> THEN
        YCUST.ACCT.MNEMONICS = YCUST.ACCT.MNEMONICS:@VM:YR.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocUsingMne,BMV>
    END
* Main processing.
* Form list of customers.
    GOSUB FORM.LIST.OF.CUST:
* Read the COLLATERAL.PARAMETER record if Collateral module is installed in the company
    IF CO.INSTALLED THEN
        CUS.COMP = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany)
        Y.COLL.PARAM = CO.Config.CollateralParameter.CacheRead(CUS.COMP, ER)
    END
* Process all the customers selected.

    GOSUB PROCESS.CUST.RECORDS:
*
RETURN
*
**** =============================================================== ****
FORM.LIST.OF.CUST:
*----------------
*
**** Forms a list of customers to be processed depending on the common
**** variables passed. D.LOGICAL.OPERANDS & D.RANGE.AND.VALUE.
*
    Y.OPERAND = EB.Reports.getDLogicalOperands()<LIAB.POS>
    Y.CHK.VALUE = EB.Reports.getDRangeAndValue()<LIAB.POS>
*
    Y.CUST.ARRAY = ''

    IF Y.OPERAND = 1 AND Y.CHK.VALUE<1,1> NE 'ALL' THEN
**** Equal to one or more selected customers.
        GOSUB MATCH.EQUAL:
    END ELSE
        GOSUB MATCH.OTHERS:
    END
*
RETURN
*
**** =============================================================== ****
MATCH.EQUAL:
*----------
*
**** If operand is 'EQ', select on customer file can be avoided.
**** Customer record has to be read and checked whether the customer
**** is a part of a liability group or the head of a group or a stand
**** alone customer.

* Expand containers with the customers EB.CUS.REL.CUSTOMER list.
    IF Y.CHK.VALUE<1,1,2> = "" THEN
* If there is only one customer, check to see if is a container
        ST.Customer.CustomerRelations(Y.CHK.VALUE<1,1,1>, Y.REL.CUS, Y.ERR)
        IF Y.REL.CUS<3> THEN
* This is a Container customer so append the related customers.
            Y.I = 0
            LOOP
                Y.I += 1
                Y.CUST.ID = Y.REL.CUS<1,Y.I>
            WHILE Y.CUST.ID NE ''
                Y.CHK.VALUE<1,1,-1> = Y.CUST.ID
            REPEAT
        END
    END
*
    Y.I = 0
    LOOP
        Y.I += 1
        Y.CUST.ID = Y.CHK.VALUE<1,1,Y.I>
    WHILE Y.CUST.ID NE ''

        IF Y.CUST.ID[1,1] = 'M' THEN
            Y.CUST.ARRAY<-1> = Y.CUST.ID

* Adds the sub group limits of the master group

            GOSUB ADD.SUB.GRP.LIMIT

            CONTINUE
        END
        Error = ''
        customerId = Y.CUST.ID
        customerParent = ''
        IF NUM(Y.CUST.ID) THEN
            CALL CustomerService.getParent(customerId, customerParent) ;* Check if this is a valid customer id
            IF EB.SystemTables.getEtext() THEN ;* Not a customer id could be a customer group record, try it
                R.CUST.GROUP = ST.Customer.CustomerGroup.Read(Y.CUST.ID, Error)
            END
        END ELSE
            R.CUST.GROUP = ST.Customer.CustomerGroup.Read(Y.CUST.ID, Error) ;* Alpha id could a customer group record id
        END
        IF Error THEN ;* Neither customer nor customer group id, skip and continue to next id
            customerParent = ''
            CONTINUE
        END

        IF customerParent<Parent.customerLiability> EQ '' THEN ;* Append the customer /group id to process list
            Y.CUST.ARRAY<-1> = Y.CUST.ID
        END ELSE
            IF customerParent<Parent.customerLiability> EQ Y.CUST.ID THEN
                Y.CUST.ARRAY<-1> = Y.CUST.ID
            END ELSE
                Y.CUST.ARRAY<-1> = customerParent<Parent.customerLiability>
            END
        END
    REPEAT

RETURN
*
**** =============================================================== ****
MATCH.OTHERS:
*-----------
*
**** Select customer file depending on the operand...
**** Customer file will be checked based on the following condition.
**** If the customer is either at the head of a liability group or if the
**** customer is an individual and not part of any liability group.
**** For all customers who are a part of a liability group and not the
**** the head of the group then we dont select that customer.
*
    CUSTOMER.LIST = ''
    THE.LIST = DAS.CUSTOMER$SORTED
    EB.DataAccess.Das('CUSTOMER',THE.LIST,'','')
    
    LOOP
        REMOVE CUSTOMER.ID FROM THE.LIST SETTING CUS.POS
    WHILE CUSTOMER.ID:CUS.POS
        customerId = CUSTOMER.ID
        customerParent = ''
        CALL CustomerService.getParent(customerId, customerParent)
        CUST.LIAB.NO = customerParent<Parent.customerLiability>
        
        IF CUST.LIAB.NO NE '' AND CUST.LIAB.NO NE CUSTOMER.ID THEN
            CONTINUE
        END
        BEGIN CASE
    
            CASE Y.OPERAND = 1        ;* EQual to ALL.
                CUSTOMER.LIST<-1> = CUSTOMER.ID
            CASE Y.OPERAND = 2        ;* RanGe
                IF CUSTOMER.ID GE Y.CHK.VALUE<1,1,1> AND CUSTOMER.ID LE Y.CHK.VALUE<1,1,2> THEN
                    CUSTOMER.LIST<-1> = CUSTOMER.ID
                END
            CASE Y.OPERAND = 3        ;* Less Than
                IF CUSTOMER.ID LT Y.CHK.VALUE<1,1> THEN
                    CUSTOMER.LIST<-1> = CUSTOMER.ID
                END
            CASE Y.OPERAND = 4        ;* Greater Than
                IF CUSTOMER.ID GT Y.CHK.VALUE<1,1> THEN
                    CUSTOMER.LIST<-1> = CUSTOMER.ID
                END
            CASE Y.OPERAND = 5        ;* Not Equal to
                CHECK.VALUES = RAISE(Y.CHK.VALUE<1,1>)
                IF NOT(CUSTOMER.ID MATCHES CHECK.VALUES) THEN
                    CUSTOMER.LIST<-1> = CUSTOMER.ID
                END
            CASE Y.OPERAND = 6 OR Y.OPERAND = 7 ;* Like and unlike
                NULL
            CASE Y.OPERAND = 8        ;* Less than or Equal
                IF CUSTOMER.ID LE Y.CHK.VALUE<1,1> THEN
                    CUSTOMER.LIST<-1> = CUSTOMER.ID
                END
            CASE Y.OPERAND = 9        ;* Greater than or Equal
                IF CUSTOMER.ID GE Y.CHK.VALUE<1,1> THEN
                    CUSTOMER.LIST<-1> = CUSTOMER.ID
                END
            CASE Y.OPERAND = 10 ;* Not in range
                IF CUSTOMER.ID LT Y.CHK.VALUE<1,1,1> OR CUSTOMER.ID GT Y.CHK.VALUE<1,1,2> THEN
                    CUSTOMER.LIST<-1> = CUSTOMER.ID
                END
        END CASE
    REPEAT
*
    THE.LIST = CUSTOMER.LIST
    LOOP
        CUS.POS = ''
        REMOVE YID.CUST FROM THE.LIST SETTING CUS.POS
    WHILE YID.CUST NE ''
        Y.CUST.ARRAY<-1> = YID.CUST
* Adds the sub group limits for the master group
        IF YID.CUST[1,1] EQ 'M' THEN
            GOSUB ADD.SUB.GRP.LIMIT
        END
    REPEAT

RETURN
*
**** =============================================================== ****
PROCESS.CUST.RECORDS:
*-------------------
*
**** Processes each customer built in Y.CUST.ARRAY for builds the list
**** of limit and account record ids.
*
    LOOP
        REMOVE Y.CURR.CUST FROM Y.CUST.ARRAY SETTING YINDEX.1
    WHILE Y.CURR.CUST

        GOSUB PROCESS.SHARED.LIMITS ; *If the customer is a part of LIMIT.SHARING.GROUP recalculate the group utilisation
        GOSUB BUILD.LIAB.LIST
        LOCATE "SKIP.COLLATERAL.REVALUATION" IN EB.Reports.getDFields()<2> SETTING SKIP.POS ELSE
            GOSUB REVALUE.COLLATERAL   ;* When there is online update setup, revalue the collateral and do the reallocation
        END
        
        Y.ACCT.LIST = '' ; Y.SC.LIST = "" ;
        Y.LC.LIST = ""
        Y.EXT.LIST = ''    ;*Y.EXT.LIST- to get the External Collateral details
        Y.PROP.LIST = ''   ;*Y.PROP.LIST-to get the Property Collateral details
        Y.MTG.LIST = ''    ;*Y.MTG.LIST- to get the Mortgage Collateral details
        PROCESS.AC = 0

        LOOP
            REMOVE Y.AC.CUST FROM Y.CUST.LIAB SETTING YINDEX.2
        WHILE Y.AC.CUST NE ''
            GOSUB PROCESS.EACH.COMPANY
            GOSUB BUILD.COLLATERAL.LIST
        REPEAT
* If accounts exist and at least one account needs to be printed.
        IF Y.ACCT.LIST NE '' AND PROCESS.AC THEN
            Y.ID.LIST<-1> = Y.ACCT.LIST
            Y.ACCT.LIST = 'LI\':Y.CURR.CUST
**** =============================================================== ****
***** Account numbers have to be processed in two runs while         ****
****  building the record for displaying. During the first run, the  ****
****  amounts are calculated and stored in local variable for Credit ****
****  Limit accounts. When the routine is called the next time with  ****
****  LI\Liability number, the amount is retrieved from the common   ****
****  variable and returned to the enquiry system.                   ****
**** =============================================================== ****
            Y.ID.LIST<-1> = Y.ACCT.LIST
        END

        IF Y.SC.LIST THEN
            Y.ID.LIST<-1> = Y.SC.LIST
        END
    
        IF Y.EXT.LIST THEN
            Y.ID.LIST<-1> = Y.EXT.LIST  ;*If Y.EXT.LIST (which contains the External Collateral details) exists, then it is appended to Y.ID.LIST which will build the record for displaying
        END
        IF Y.PROP.LIST THEN
            Y.ID.LIST<-1> = Y.PROP.LIST ;*If Y.PROP.LIST(which contains the Property Collateral details) exists, then it is appended to Y.ID.LIST which will build the record for displaying
        END
        IF Y.MTG.LIST THEN
            Y.ID.LIST<-1> = Y.MTG.LIST  ;*If Y.MTG.LIST(which contains the Mortgage Collateral details) exists, then it is appended to Y.ID.LIST which will build the record for displaying
        END
    
        IF Y.LC.LIST THEN
            Y.ID.LIST<-1> = Y.LC.LIST
        END
    REPEAT

RETURN
***</region>
*-----------------------------------------------------------------------------

*---------------
BUILD.LIAB.LIST:
*---------------

**** All Limit records for the customer liability group

    Y.LIMIT.LIAB = ''
    LL.ERR = ''
    LI.Config.LimitLiabilityRead(Y.CURR.CUST, Y.LIMIT.LIAB, LL.ERR)

    IF Y.LIMIT.LIAB THEN
        LOOP
            REMOVE Y.CHECK.ID FROM Y.LIMIT.LIAB SETTING YLIM.INDEX
        WHILE Y.CHECK.ID
            INCLUDE.CUST = 1    ;* Flag to indicate whether this limit should be included or not
            IF INDEX(Y.CHECK.ID,'.',3) THEN
                CONTINUE
            END
            Y.LIM.REC = ''
            Y.LIM.REC = LI.Config.Limit.Read(Y.CHECK.ID, LIM.ERR)
* Ignore the Limit records with limit product that are marked for third party exposure as YES.
* Include such limit records for display only when user explicitly queries with SHOW.THIRD.PARTY.EXPOSURE as YES.
            LIMIT.REF.ID = Y.LIM.REC<LI.Config.Limit.LimitProduct>
            IF LIMIT.REF.ID THEN
                LIMIT.REF.REC = ''
                LIMIT.REF.ERR = ''
                LIMIT.REF.REC = LI.Config.LimitReference.CacheRead(LIMIT.REF.ID,LIMIT.REC.ERR)
                LIMIT.REF.EXPOSURE = LIMIT.REF.REC<LI.Config.LimitReference.RefThirdPartyExposure>
                IF (LIMIT.REF.EXPOSURE EQ "YES" AND THIRD.PARTY.EXPOSURE NE "YES") THEN
                    CONTINUE
                END
            END
* Check whether allowed customer is setup in limit record
* If the passed customer is not in the allowed customer field then do not include this limit
            IF Y.LIM.REC<LI.Config.Limit.AllowedCust> THEN
                LOCATE Y.CHK.VALUE IN Y.LIM.REC<LI.Config.Limit.AllowedCust,1> SETTING CUST.POS ELSE
                    INCLUDE.CUST = ''
                END
            END
* Check for restricted customer setup in limit record
* If the passed customer is in the restricted customer field then do not include this limit
            IF Y.LIM.REC<LI.Config.Limit.RestrictedCust> THEN
                LOCATE Y.CHK.VALUE IN Y.LIM.REC<LI.Config.Limit.RestrictedCust,1> SETTING CUST.POS THEN
                    INCLUDE.CUST = ''
                END
            END

            LLI.ERR = ''
            Y.LIM.LINES = ''
            LI.Config.LimitLinesRead(Y.CHECK.ID, Y.LIM.LINES, LLI.ERR)
            IF Y.LIM.LINES NE '' AND Y.LIM.REC NE '' AND INCLUDE.CUST THEN
                Y.ID.LIST<-1> = Y.CHECK.ID
            END
* Store the LIMIT.COL.ALLOC.WORK ids when there is online update setup and when REALTIME.ALLOC set in COLLATERAL.PARAMETER
            IF Y.LIM.REC<LI.Config.Limit.OnlineUpdate>  EQ 'Y' AND Y.COLL.PARAM<CO.Config.CollateralParameter.CollParRealtimeAlloc> EQ 'YES' THEN
                ALLOC.WORK.LIST<-1> = Y.LIM.REC<LI.Config.Limit.AllocWorkId>
            END
        REPEAT
    END

    Y.CUST.LIAB = ''
    Y.CUST.LIAB = ST.Customer.CustomerLiability.Read(Y.CURR.CUST, CL.ERR)
    IF Y.CUST.LIAB = '' THEN
        Y.CUST.LIAB = Y.CURR.CUST ;* Customer is not part of any liability group.
    END

    IF MASTER.GROUP.KEY THEN
        GOSUB GET.CUST.SHARED.LIMITS ; *Get the list of shared limits available for the customer
    END

RETURN

*---------------------
PROCESS.EACH.COMPANY:
*---------------------

* Check each possible company for the CUSTOMER.ACCOUNT file

    YCUST.ACCT.MNEMONICS = YCUST.ACCT.MNEMONICS
    LOOP
        REMOVE YCUST.ACC.MNE FROM YCUST.ACCT.MNEMONICS SETTING YD
    UNTIL YCUST.ACC.MNE = ""
* Select the accounts from Lead copmany.
        CO.MNE = YCUST.ACC.MNE
        CO.LEAD = '' ;   CO.CODE = '' ;  CO.LEAD.MNE = ''
        ST.CompanyCreation.GetCompany(CO.MNE,CO.CODE,CO.LEAD,CO.LEAD.MNE)

        IF CO.MNE NE CO.LEAD.MNE THEN
            CONTINUE
        END
    
        R.COMP = ST.CompanyCreation.Company.CacheRead(CO.LEAD, ER)

        YF.CUSTOMER.ACCOUNT = "F":YCUST.ACC.MNE:".CUSTOMER.ACCOUNT"
        F.CUST.ACCT = ""
        EB.DataAccess.Opf(YF.CUSTOMER.ACCOUNT,F.CUST.ACCT)
        EB.DataAccess.FRead(YF.CUSTOMER.ACCOUNT, Y.AC.CUST, Y.CUST.ACCT, F.CUST.ACCT, CA.ERR)
        
        IF Y.CUST.ACCT THEN
            GOSUB CHECK.ACCOUNTS
        END ELSE
            Y.CUST.ACCT = ''
        END

        IF Y.CUST.ACCT THEN
            IF Y.ACCT.LIST = "" THEN
                Y.ACCT.LIST = "AC\":Y.CURR.CUST
            END
            CONVERT @FM TO '.' IN Y.CUST.ACCT
            Y.ACCT.LIST := "|":YCUST.ACC.MNE:"\":Y.CUST.ACCT
        END
        GOSUB BUILD.SEC.LIST
        GOSUB BUILD.LC.LIST
    REPEAT

RETURN
*
*----------------------------------------------
CHECK.ACCOUNTS:
*--------------------------------

    READ.ERR = ""
    FN.ACCOUNT = "F":YCUST.ACC.MNE:".ACCOUNT"
    F.ACCOUNT = ""
    EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)
    
    LOOP
        REMOVE ACCT.ID FROM Y.CUST.ACCT SETTING CUST.POS
    WHILE ACCT.ID:CUST.POS
        R.ACCT = ""
        EB.DataAccess.FRead(FN.ACCOUNT,ACCT.ID,R.ACCT,F.ACCOUNT,READ.ERR)
* Check if atleast one account needs to be printed in the enquiry
* Condition : Account balance greater than 0 or account does not have limit attached.
*get balance using service routine.
        accountKey = ACCT.ID
        response.Details = ''
        workingBal = ''
        AC.CashFlow.AccountserviceGetworkingbalance(accountKey, workingBal, response.Details)
*
        IF (R.ACCT<AC.AccountOpening.Account.LimitRef> EQ "NOSTRO") OR (R.ACCT<AC.AccountOpening.Account.LimitRef> EQ "") OR workingBal<AC.CashFlow.BalanceWorkingbal> GT 0 THEN
            PROCESS.AC = 1
        END
    REPEAT

RETURN
*-----------------------------------------------------------------------------
BUILD.SEC.LIST:
*----------------
*
** Build a list of all securities held by the customer
*
    SC.INSTALLED = ""
    LOCATE "SC" IN R.COMP<ST.CompanyCreation.Company.EbComApplications,1> SETTING SC.POS THEN
        SC.INSTALLED = 1
        SAM.FILE.CLASS = ''
        SC.ScoPortfolioMaintenance.ScGetFileClassification('SEC.ACC.MASTER',SAM.FILE.CLASS)        ;* Get file classification of SEC.ACC.MASTER
    END
    tmp.ETEXT = EB.SystemTables.getEtext()
    IF SC.INSTALLED AND NOT(tmp.ETEXT) ELSE
        RETURN
    END

* If file class of SEC.ACC.MASTER is CUS then process only in CUSTOMER company
    IF (SAM.FILE.CLASS = 'CUS' OR SAM.FILE.CLASS = 'INT') AND YCUST.ACC.MNE NE YCUST.COMPANY THEN
        RETURN
    END

    YR.SEC.ACC.CUST = SC.ScvValuationUpdates.SecAccCust.Read(Y.AC.CUST, ER)
    IF ER THEN
        RETURN
    END

    F.SEC.ACC.MASTER = ""     ;* This is held at FIN level
    YF.SEC.ACC.MASTER = "F":YCUST.ACC.MNE:".SEC.ACC.MASTER"
    EB.DataAccess.Opf(YF.SEC.ACC.MASTER, F.SEC.ACC.MASTER)
    R.SEC.ACC.MASTER = ""

    LOOP
        REMOVE PORT.ID FROM YR.SEC.ACC.CUST SETTING YD      ;* Gives list of portfolios
    WHILE PORT.ID:YD

        SAM.ERR = ''
        EB.DataAccess.FRead(YF.SEC.ACC.MASTER,PORT.ID,R.SEC.ACC.MASTER,F.SEC.ACC.MASTER, SAM.ERR)
        IF SAM.ERR THEN
            CONTINUE
        END
        SC.PORT.LIST = dasSecurityPositionSecurityAccount
        THE.ARGS = PORT.ID
        TABLE.SUFFIX = ''
        EB.DataAccess.Das('SECURITY.POSITION', SC.PORT.LIST, THE.ARGS, TABLE.SUFFIX)

        IF NOT(SC.PORT.LIST) THEN
            CONTINUE
        END

        IF Y.SC.LIST = "" THEN
            Y.SC.LIST = "SC\":Y.CURR.CUST         ;* There are some securities
        END
        CONVERT @FM TO "*" IN SC.PORT.LIST
        Y.SC.LIST := "|":YCUST.ACC.MNE:"\":SC.PORT.LIST
    REPEAT

RETURN

*--------------
BUILD.LC.LIST:
*--------------

    LC.INSTALLED = ""
    LOCATE "LC" IN R.COMP<ST.CompanyCreation.Company.EbComApplications,1> SETTING LC.POS THEN
        LC.INSTALLED = 1
    END
    
    IF NOT(LC.INSTALLED) THEN
        RETURN
    END
    
    LOCATE "LC.BENEFICIARY" IN EB.Reports.getDFields()<1> SETTING LC.BEN.POS THEN
        Y.LC.CHK = EB.Reports.getDRangeAndValue()<LC.BEN.POS>
        Y.BEN.LIST = Y.CURR.CUST
        LC.Foundation.ELcBuildBenList(Y.BEN.LIST, YCUST.ACC.MNE)
        IF Y.BEN.LIST # '' THEN
            CONVERT @FM TO '*' IN Y.BEN.LIST
            Y.LC.LIST = "LC\":Y.CURR.CUST:"\":Y.BEN.LIST
        END
    END

RETURN

*---------------------
BUILD.COLLATERAL.LIST:
*---------------------

    IF NOT(CO.INSTALLED) THEN
        RETURN
    END

    NON.SYS.CO = "" ;* To maintain the list of External Collateral ids and Collateral ids that are externally available
    PROP.LIST = ""  ;* To maintain the list of Property assets Collateral ids
    MTG.LIST = ""   ;* To maintain the list of Mortgage records Collateral ids
    CC.ERR = ''
    CO.RIGHT.LIST = CO.Contract.CustomerCollateral.Read(Y.AC.CUST, CC.ERR)
    IF CC.ERR THEN
        RETURN
    END
*
** Look at RIGHT.COLLATERAL to get the COLLATERAL records
** Then look at Collateral type via collateral to see if
** type is external
*
    LOOP
        REMOVE CO.RIGHT.ID FROM CO.RIGHT.LIST SETTING COD
    WHILE CO.RIGHT.ID:COD
        CO.LIST = ''
        CO.LIST = CO.Contract.RightCollateral.Read(CO.RIGHT.ID, COL.ERR)
        LOOP
            REMOVE CO.ID FROM CO.LIST SETTING COID
        WHILE CO.ID:COID      ;* Check each id for type
            YR.COLLAT = ''
            YR.COLLAT = CO.Contract.Collateral.Read(CO.ID, COL.ERR)
* If the collateral is expired or excluded, dont process
            EXCLUDE.COLLATERAL = ''   ;* Flag to indicate that collateral is to be excluded
            COLL.ERR = ''             ;* Error while determinin the exclusion
            CO.Contract.ExcludeCheck(CO.ID,YR.COLLAT,'',EXCLUDE.COLLATERAL,COLL.ERR,'')
            IF COL.ERR OR EXCLUDE.COLLATERAL THEN  ;* Filter the liquidated and excluded collateral records
                CONTINUE
            END
            COLT.ID = YR.COLLAT<CO.Contract.Collateral.CollCollateralType>
            YR.COLL.TYPE = ''
            YR.COLL.TYPE = CO.Config.CollateralType.Read(COLT.ID, COLT.ERR)
            IF NOT(YR.COLL.TYPE) THEN
                CONTINUE
            END
            BEGIN CASE
                CASE YR.COLLAT<CO.Contract.Collateral.CollApplication> = "EXTERNAL"   ;* If the APPLICATION field in COLLATERAL is 'EXTERNAL' then the COLLATERAL ID is appended to the list
                    NON.SYS.CO<-1> = CO.ID
                CASE YR.COLLAT<CO.Contract.Collateral.CollApplication> = "PROPERTY"   ;* If the APPLICATION field in COLLATERAL is 'PROPERTY' then the COLLATERAL ID is appended to the PROPERTY list
                    PROP.LIST<-1> = CO.ID
                CASE YR.COLLAT<CO.Contract.Collateral.CollApplication> = "MORTGAGE"   ;* If the APPLICATION field in COLLATERAL is 'MORTGAGE' then the COLLATERAL ID is appended to the MORTGAGE list
                    MTG.LIST<-1> = CO.ID
                CASE YR.COLL.TYPE<CO.Config.CollateralType.CollTypeApplicationInput> = "N"
                    NON.SYS.CO<-1> = CO.ID
                CASE YR.COLL.TYPE<CO.Config.CollateralType.CollTypeApplicationInput> = "O" AND YR.COLLAT<CO.Contract.Collateral.CollApplication> = ""
                    NON.SYS.CO<-1> = CO.ID
            END CASE
        REPEAT
    REPEAT

* EXTERNAL collateral ids with customer id is maintained in a separate list Y.EXT.LIST to display the collateral details in a separate line
    IF NON.SYS.CO THEN
        IF Y.EXT.LIST = "" THEN
            Y.EXT.LIST = "CO\":Y.CURR.CUST      ;*'CO' is added to identify the customer as the External collateral CUSTOMER
        END
        CONVERT @FM TO "*" IN NON.SYS.CO
        Y.EXT.LIST := "|":YCUST.ACC.MNE:"\":NON.SYS.CO    ;*Customer id and the collateral ids are added to Y.EXT.LIST
    END
*
* PROPERTY collateral ids with customer id is maintained in a separate list PROP.LIST to display the collateral details in a separate line
    IF PROP.LIST THEN
        IF Y.PROP.LIST = "" THEN
            Y.PROP.LIST = "PROP\":Y.CURR.CUST   ;*'PROP' is added to identify the customer as the PROPERTY collateral CUSTOMER
        END
        CONVERT @FM TO "*" IN PROP.LIST
        Y.PROP.LIST := "|":YCUST.ACC.MNE:"\":PROP.LIST    ;*Customer id and the collateral ids are added to Y.PROP.LIST
    END
*
* MORTGAGE collateral ids with customer id is maintained in a separate list Y.MTG.LIST to display the collateral details in a separate line
    IF MTG.LIST THEN
        IF Y.MTG.LIST = "" THEN
            Y.MTG.LIST = "MTG\":Y.CURR.CUST     ;*'MTG' is added to identify the customer as the MORTGAGE collateral CUSTOMER
        END
        CONVERT @FM TO "*" IN MTG.LIST
        Y.MTG.LIST := "|":YCUST.ACC.MNE:"\":MTG.LIST     ;*Customer id and the collateral ids are added to Y.MTG.LIST
    END
*
RETURN


*-----------------------------------------------------------------------------

*** <region name= PROCESS.SHARED.LIMITS>
PROCESS.SHARED.LIMITS:
*** <desc>If the customer is a part of LIMIT.SHARING.GROUP rebuild the group </desc>

    ONLINE.UPDATE = 0
    LI.GroupLimit.GetAllocateOnline(ONLINE.UPDATE, '', ERR) ;* Check whether online update is set in    Limit parameter
* Master key will be returned only if the customer has group setup
    MASTER.GROUP.KEY = ''
    ERR = ''
    CUSTOMER.ID = Y.CURR.CUST
    LI.GroupLimit.GetMasterGroupKey(CUSTOMER.ID,'','',MASTER.GROUP.KEY,'',ERR)

    IF ONLINE.UPDATE AND MASTER.GROUP.KEY THEN
* While calling from enquiry no need to update limits after recalculating group utilisation
* GROUP ALLOCATION file will be loaded in cache so that latest info is available
        MODE = 'INFO' ;* Pass flag to say call is from enquiry
        LI.GroupLimit.RecalcGroupAllocation(MASTER.GROUP.KEY, '', MODE, '', '', ERR)
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.CUST.SHARED.LIMITS>
GET.CUST.SHARED.LIMITS:
*** <desc>Get the list of shared limits available for the customer </desc>

    LI.GroupLimit.GetCustomerGroup(Y.CURR.CUST,'',GROUP.KEYS,GROUP.ERROR)

    LOOP
        REMOVE GROUP.ID FROM GROUP.KEYS SETTING GRP.POS
    WHILE GROUP.ID : GRP.POS

* Do not consider sub group limits
        IF GROUP.ID[1,1] = 'S' THEN
            CONTINUE
        END

        ERR = ''
        R.LIAB = ''
        LI.Config.LimitLiabilityRead(GROUP.ID, R.LIAB, ERR)

        GOSUB GET.GROUP.CUST.LIMIT ; *
    REPEAT

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.GROUP.CUST.LIMIT>
GET.GROUP.CUST.LIMIT:
*** <desc> </desc>
* Take only the top line limits for the current customer
* In the first page of Liab enquiry display only the top level of group limits for the current
* customer alone, ignore all other limits.

    LOOP
        REMOVE LIM.ID FROM R.LIAB SETTING LIM.POS
    WHILE LIM.ID : LIM.POS
        GRP.LIMIT.REF = FIELD(LIM.ID, '.', 2,1) ;* Get the reference part

        BEGIN CASE
            CASE FIELD(LIM.ID, '.', 4) = '' ;* Ignore group limits without customer id
                CONTINUE
            CASE FIELD(LIM.ID, '.', 4) NE Y.CURR.CUST ;* Ignore group limits of other customer id
                CONTINUE
            CASE GRP.LIMIT.REF[1,3] AND GRP.LIMIT.REF[4,4] ;* Ignore Global product limit, Take the global line instead
                CONTINUE
            CASE GRP.LIMIT.REF[4,2] AND GRP.LIMIT.REF[6,2] ;* Ignore Group limit with sub product, Take the product level limit
                CONTINUE
        END CASE

* Include all other top level limits.
        Y.ID.LIST<-1> = LIM.ID

    REPEAT

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = ADD.SUB.GRP.LIMIT>
ADD.SUB.GRP.LIMIT:
*----------------

* The sub group of the master group are selected here
* Get the sub groups of the master group on reading the LI.SUB.GROUP application
    Y.LIM.SUB = ''
    Y.LIM.SUB = LI.GroupLimit.SubGroup.Read(Y.CHK.VALUE, SUB.ERR)
* If the sub groups are available, then they are added in the customer array for processing

    IF Y.LIM.SUB THEN
        Y.CUST.ARRAY<-1> = Y.LIM.SUB
    END

RETURN
*
**** =============================================================== ****
*** <region name= REVALUE.COLLATERAL>
REVALUE.COLLATERAL:
*** <desc>Revalue the collateral with the latest amount and do reallocation based on the new amount </desc>
*
    IF ALLOC.WORK.LIST THEN
        ALLOC.CNT = DCOUNT(ALLOC.WORK.LIST,@FM)
        FOR ALLOC.POS=1 TO ALLOC.CNT
            ALLOC.ID = ALLOC.WORK.LIST<ALLOC.POS>
* The routine COLLATERAL.ONLINE.REVALUATION will call LI.CO.UPDATE routine for reallocation with the latest value
* In LI.CO.UPDATE.II routine, there is a code to skip the updation of values if the APPLICATION is ENQUIRY.SELECT.
* So assignging the common variable APPLICATION as "LIMIT.TXNS" while calling LI.CO.UPDATE routine
* Also when the enquiry is launched for the same customer in two sessions in desktop, system hangs due to lock in
* LI.CO.UPDATE.I routine. So changes have been done to release the lock in LI.CO.UPDATE.III routine when application
* is LIMIT.TXNS
            SAVE.APPLICATION = EB.SystemTables.getApplication()
            EB.SystemTables.setApplication("LIMIT.TXNS")
            CO.Contract.CollateralOnlineRevaluationLoad()  ;* Load the variables requried for the job COLLATERAL.ONLINE.REVALUATION
            CO.Contract.CollateralOnlineRevaluation(ALLOC.ID)
            EB.SystemTables.setApplication(SAVE.APPLICATION);* Reassign the common variable
        NEXT ALLOC.POS
    END
    
    SAVE.PAT.ID=PW.Foundation.getActivityTxnId()          ;* Save the PAT common before clearing
    PW.Foundation.setActivityTxnId("")                    ;* Clear the PAT common to avoiding triggering next PW activity in JOURNAL.UPDATE
    EB.TransactionControl.JournalUpdate("")               ;* Update the latest collateral value
    PW.Foundation.setActivityTxnId(SAVE.PAT.ID)           ;* Set the PAT common to facilitate the usual PW flow.

RETURN
*** </region>
*
*-----------------------------------------------------------------------------

END
