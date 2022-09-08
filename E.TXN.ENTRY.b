* @ValidationCode : MjoyOTc2Nzk3NTpjcDEyNTI6MTYwMzQ2MTE3MDE1ODpiY2Fwb29ydmE6Mjc6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MToxMjAzOjgxMA==
* @ValidationInfo : Timestamp         : 23 Oct 2020 19:22:50
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : bcapoorva
* @ValidationInfo : Nb tests success  : 27
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 810/1203 (67.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*---------------------------------------------------------------------------------
* <Rating>5894</Rating>
*--------------------------------------------------------------------------------
* Version 16 07/06/01  GLOBUS Release No. G12.0.00 29/06/01
*
*************************************************************************
*
$PACKAGE AC.ModelBank

SUBROUTINE E.TXN.ENTRY(STMT.LIST)
*
*************************************************************************
*
* This routine is called by TXN.ENTRY in order to return all the entry
* id's for the transaction whose id is passed in O.DATA
*
* 06/01/93 - GB9200492
*            Allow FID orders and placements to be enquired on
*
* 23/04/93 - GB9300684
*            Ignore history records where the statement number is "_".
*            This means no new entries have been raised.
*
* 01/11/95 - GB9501033
*            Cater for multi company and swaps
*
* 14/03/96 - GB9501021
*            Add PD.PAYEMNT.DUE
*
* 09/04/96 - GB9600411
*            Use RECORD.READ.HIST to get stmt nos.
*
* 11/04/96 - GB9600324
*            Use EB.SYSTEM.ID to find the stmt nos field
*
* 11/03/03 - GLOBUS_CI_10007309
*            Enquiry TXN.ENTRY does not work with DX. Since DX.TRADE does not
*            store the STMT.ENTRIES for the transaction; rather it stores it in a live file
*            DX.TRANSACTION.
*
* 17/06/03 - BG_100004400
*            To display the entries related to AZ contract
* 26/01/05 - BG_100007950
*            To ensure DC.ENTRY has the correct key as a result of
*            the restructure if the DATA.CAPTURE id for Non-Stop processing.
* 15/03/05 - BG_100008371
*            To allow the user to input the TXN.REF in the either of the
*            following format: DDDDBBB
*                              DDDDBBBIII
*                              DCNNNNNDDDDBBB
*                              DCNNNNNDDDBBBIII
*                              Where DDDD is the Dept
*                              BBB is the batch
*                              III is the item number
*                              DC is the actual application id for DATA.CAPTURE
*                              NNNNN is the julian date
*
* 29/03/05 - CI_100028388
*            Ensure that the correct initial compnay code is loaded and that
*            the correct mnemonic is opend when reading entries
*
* 27/08/05 - CI_10033946
*            TXN.ENTRY enquiry does not work for SL Module.
*
* 05/08/06 - CI_10043178
*            TXN.ENTRY enquiry does not work for MG.PAYMENT.
*
* 30/08/06 - CI_10043674
*          - Code included to display FT.TAPES entries in TXN.ENTRY
*
* 13/10/06 - BG_100012233
*            LC.ACCOUNT.BALANCES not handled by TXN.ENTRY enquiry
*
* 01/12/06 - BG_100012508
*            The program, E.TXN.ENTRY contains the following line of code :
*            IF FILE.NAME EQ 'FBNK.LETTER.OF.CREDIT' THEN which doesn't make
*            sense as not all installations should be assumed to be an "FBNK"
*
* 20/06/07 - EN_10003378
*            Get the entries from EB.CONTRACT.BALANCES for those contracts
*            which are moved to ECB.
*
* 09/10/07 - BG_100015371
*            Get the applications that are moved to ECB from RE.APPLICATIONS, instead
*            of adding the module to the common variable C$CRF.ONLINE.APPL in different routines.
*
* 23/01/08 - BG_100016663
*            Unable to see TXN.ENTRY in LC sight drawing liquidation.
*
* 19/08/08 - BG_100019579
*            For DX, use DX.TRADE instead of SELECT if possible
*
* 28/08/08 - BG_100019716
*            Enquiry TXN.ENTRY not getting the entries from ECB, instead getting the entries from
*            application itself for LETTER.OF.CREDIT and DRAWING applications.
*            Code which gets the entries from DR.DISC.AMENDMENTS and LC.ACCOUNT.BALANCES is removed
*            as it is not required after ECB sar (EN_10003378).
*
* 31/10/08 - BG_100020657
*            Fix enquiry to work with SY
*
* 12/11/08 - BG_100020805
*            For SWAP contract EB.CONTRACT.BALANCES has two records, TXN.REF.A and TXN.REF.L
*            For FOREX contract EB.CONTRACT.BALANCES has two records, TXN.REF.B and TXN.REF.S
*            Code changed to read with correct ID.
*
* 13/11/08 - CI_10058782
*            For nofile enquiry, the entries must be sorted according to date
*            and then displayed.
*
* 09/01/08 - BG_100021553
*            Removed I_F.LIQD.POSITION insert file and related codes as this is made OB
*
* 13/01/09 - CI_10060056
*            While executing the TXN.ENTRY enquiry, only the reversal P&L entries
*            are shown and the original P&L entries are missing
*
* 25/03/09 - CI_10061613
*            For FOREX contract EB.CONTRACT.BALANCES has three records,TXN.REF.B, TXN.REF.S and also TXN.REF
*            If UPDATE.ENTRIES field is set to null or 'NO' in ACCOUNT.PARAMETER table,
*            then it needs to form entries from contract's STMT.NOS field
*
* 16/07/09 - CI_10064699
*            Ref : HD0923311
*            For the AA transaction ID or AA account id, the stmt and Categ Entries details are picked from ECB file.
*
* 21/08/09 - EN_10004297
*            Enhanced to display performance fees entries in TX.ENTRY enquiry
*
* 14/10/09 - CI_10066814
*            OPF is done for AA files only if AA product is installed in the system
*
* 26 NOV 09 - BG_100025931
*             Enhanced to support TELLER.FINANCIAL.SERVICES
*
* 01/07/2010 - DEFECT 60387 / TASK 63624
*              For the AZ account id alone is passed,then trans reference should be formed as 'AZ-'<account>
*
* 02/08/2010 - RTC Work Item 72916
*              For Security contracts, the variable APP should hold value as 'SC'
*
* 03/02/11 - Task 81377
*            Validate and raise error if the restored arrangement is in unauth stage.
*
* 16/03/11 - Defect 172339 /Task 173313
*            Fatal Error arised while SC module not installed
*
* 07/04/11 - Defect 182541 /Task 187485
*            Variable BL and BR is never assigned
*
* 22/11/11 - Defect - 305561 / Task - 310407
*            The entry id's are picked from ECB for DX transaction.
*
* 02/02/2012 - DEFECT 335148 / TASK 349521
*              TXN.REF will have the STP id, which has numeric reference
*              so for SC.TRADING.POSITION application, decide the APP as SC.
*
*  02/03/12 - D 364086 / T 365300
*             Changes done to check whether the AZ product is installed in the company
*             before reading the AZ.ACCOUNT history record
*
* 13/03/12 - TASK : 334092
*            Allowing more than 99 drawings under a LETTER.OF.CREDIT
*            REF : 323657
*
* 31/07/12 - Defect 446632 / Task 452938
*            On running the enquiry TXN.ENTRY.MB with FX reference,
*            the output displays JUNK value
*
*31/07/12 - Defect 445865/ Task 454804
*             COMPANY.MNEMONIC is not displayed in the output of the enquiry TXN.ENTRY or TXN.ENTRY.MB
*             for DC transactions.
*
* 18/09/12 - Defect 479925 / Task 484620
*            Enquiry TXN.ENTRY.MB and TXN.ENTRY displayed only the latest accrual entries.
* 28/09/12 - Defect 486449 / Task 489916
*            Unable to view authorized CHEQUE.ISSUE records through the Enquiry TXN.ENTRY.MB
*
* 22/09/2012 - DEFECT 484426 / TASK 486587
*              Validation added to throw error when invalid transreference is entered.
*
* 22/01/12  - DEFECT:541182 TASK:568351
*             While using Security Portfolio Account and Security Master number in TXN.ENTRY.MB/TXN.ENTRY
*             the enquiry throws a fatal error.
*
* 12/03/13 - Defect 606104 / Task 609822
*            Spec entries are not getting displayed in ENQ TXN.ENTRY.MB for DX.TRADE
*
* 05/09/13 - Defect - 660760 / Task - 671100
*            Get the entry details for DX from ECB.
*            ECB ids are formed based on primary , secondary trans reference and trade ccy,
*            delivery ccy and respective account ccy combinations.
*
* 04/03/14 - DEFECT 856101 / TASK 693212
*            Remove the SPEC.ENTRY id count from the second sub value field of ENTRY ID's field
*            which will be appended to it, in case of AA related entries.
*
* 27/06/14 - Defect 984095 / Task 1041603
*            When the entry is generated for Accounting Company, company mnemonic of the parent
*            company will be appended with Entry ids. Hence check whether the company code in Entry
*            is Accounting Company. If so get the company mnemonic from R.COMPANY as the enquiry will
*            be executed from the Parent company.
*
* 08/07/14 - Defect 1051301 / Task 1051658
*            Compilation error due to wrong loop structure.
*
* 20/03/15 - Defect 1262806 / Task 1290958
*            Few reversal entries of DX.TRADE were missing in TXN.ENTRY output
*
* 08/08/15 - Defect 1425352 / CI_10078022
*            When there is no entries for the txn company then check for account company also. Because there may be cases
*            where both the accounts in a txns is from other company.
*
* 30/04/16 - Defect 1715821 / Task 1716624
*            Changes done to avoid TAFC compilation warnings.
*
* 23/11/16 - Defect 1780369  / Task 1930417
*            Fix the looping to swap entries to improve performance
*            for large number of entries.
*
* 23/01/17 - Defect 1962636 / Task 1995698
*            Code changes done to display statement and categ entries updated in
*            ND deal with ECB id as NDDEALID.B & NDDEALID.S
* 14/03/17 - Defect 2043064 / Task 2052048
*            Changes done to skip the read from history for SY application since
*            SY.TRANSACTION is a live table and does not have history records.
*
*12/1/17   - Task 1984155
*            TPS - Payments: Ability to drilldown to TPS from any Statement enquiry/statement.
*
*24/03/17  - Defect 2062659 / Task 2064652
*          - TXN.ENTRY is not displaying reversal entries.
*
* 01/04/17 - Defect 2072432 / Task 2074768
*            ND will have ECB updated in three ids. ND.DEAL (Online) & ND.DEAL.B , ND.DEAL.S (In COB).
*            When enquiry is run for ND.DEAL record where only ND.DEAL ECB exists i.e immediately after the transaction,
*            then system is not fetching the entries since logic introduced in Defect 1962636 is to read ND.DEAL.B record and
*            set ECB.EXISTS as 1. In this case ECB.EXISTS wont be set and further process to retrieve entries doesn't happen.
*            Changes done to first read ECB of ND.DEAL.B and if it doesnt exists then read ECB of ND.DEAL record and set ECB.EXISTS if ECB is present.
*
* 08/04/17 - Defect 2072432 / Task 2082845
*            Changes to handle uninitialized variable warnings.
*
* 10/04/17 - Defect 2001310 / Task 2080195
*            For OTC type DX Transaction, Trade and Delivery Currency values are
*            taken from DX.TRADE record since they will not be available
*            in DX.CONTRACT.MASTER.
*
* 12/10/17 - Defect 2296341 / Task 2303161
*            Modifications done to read the History record of Account if the record not
*            present in LIVE to display the entries properly while running TXN.ENTRY.MB enquiry.
*
* 14/10/17 - Defect 2300571 / Task 2306876
*            For SY records STMT.ENTRIES are not retrieved properly.
*            Changes done to get the entries properly
*
* 16/10/17 - Defect 2272339 / Task 2283157
*            Enquiry TXN.ENTRY results �No entries found for Deal�
*             when DX.CLOSEOUT is given as TRANS.REFERENCE.
*
* 12/12/17 - Defect 2367525 / Task 2376988
*            For MD created in FCY, charges taken in LCY and Event.processing is Online, the ECB ids will be MDID and MDID-LOCAL
*            so fetch the entries from both
*
* 03/01/18 - Defect 2395802 / Task 2401704
*            TXN.ENRTY enquiry should display entries related to DR.DISC.AMENDMENTS
*            when DR.DISC.AMENDMENTS id is inputted as Transaction Ref.
*
* 05/02/18 - Defect 2163263 / Task 2444644
*            Enquiry TXN.ENTRY.MB not display some of the STMT.ENTRYs raised for DX contract
*
* 13/06/18 - Defect 2629960 / Task 2632918
*            Enquiry TXN.ENTRY.MB & TXN.ENTRY not display if Update.Entries is null in ACCOUNT.PARAMETER
*
* 30/10/18 - Enhancement 2822520 / Task 2833705
*            Code changed done for componentisation and to avoid errors while compilation
*            using strict compile
*
* 16/11/18 - Defect 2847727 / Task 2856363
*            Enquiry TXN.ENTRY.MB & TXN.ENTRY does not display STMT.ENTRY.DETAIL entries for DC transactions.
*            Added code to read STMT.ENTRY.DETAIL table if Entry not available in STMT.ENTRY table.
*
* 30/05/19 - Defect 3152926 / Task 3157454
*            Enquiry TXN.ENTRY.MB & TXN.ENTRY does not display entries for TPS transaction
*
* 24/06/19 - Enhancement 3186772 / Task 3186773
*            Product Installation Check for CQ.
*
* 04/02/2020 - Defect 3561012 / Task 3572158
*              ** FATAL ERROR IN (OPF) ** NO FILE.CONTROL RECORD - POR.TRANSACTION
*              Check is done if PP module is installed in the company
*
* 10/03/2020 - Defect 3601210 / Task 3630798
*              Enquiry TXN.ENTRY does not display relevant STMT.ENTRY ids for MM and PD contracts
*              whose CURR NO is divisible by 10. Added code to display the entries of history records
*              whose CURR NO is divisible by 10.
*
* 20/07/20 - Enhancement 3847757 / Task 3847759
*            Changes to support AA Activity & Clearing Reference as TRANSACTION.REF
*            Changes to support sorting and filter based on Booking Date, Value Date and Transaction Reference
*
* 09/09/20 - Enhancement 3932648 / Task 3952625
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*
* 24/09/20 - Defect 3955960 / Task 3956514
*            Enquiry TXN.ENTRY.MB doesn't displays STMT.ENTRY accounting entries for SC.TRAIL.FEES.ARRANGEMENT
*            For the SC.TRAIL.FEES.ARRANGEMENT,trans reference should be formed as 'SC-'<SC.TRAIL.FEES.ARRANGEMENT ID>
*            Stmt entries will be fetched from ECB of the transaction reference with id as SC.TRAIL.FEES.ARRANGEMENT ID.
*
* 23/10/20 - Defect 4041399 / Task 4041413
*            File name passed seperately for Cache Read
*************************************************************************

    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING MG.Payment
    $USING SC.SctSecurityLending
    $USING SC.SccClassicCA
    $USING SC.ScfSafekeepingFees
    $USING SC.ScfAdvisoryFees
    $USING SC.ScvValuationUpdates
    $USING SC.SctDealerBookPosition
    $USING LC.Contract
    $USING SL.BuySell
    $USING SL.Loans
    $USING SL.Presyndication
    $USING SL.ODSettlement
    $USING SL.Facility
    $USING SL.Fees
    $USING BF.ConBalanceUpdates
    $USING AC.EntryCreation
    $USING AC.Config
    $USING AA.Framework
    $USING AC.AccountOpening
    $USING TT.TellerFinancialService
    $USING CQ.ChqIssue
    $USING DX.Trade
    $USING EB.DataAccess
    $USING RE.Config
    $USING EB.Utility
    $USING EB.API
    $USING AC.API
    $USING AC.ModelBank
    $USING AZ.Contract
    $USING DX.Configuration
    $USING SC.ScoPortfolioMaintenance
    $USING EB.Reports
    $USING DI.Contract
    $USING DP.Contract
    $USING XF.Contract
    $USING PT.Contract
    $USING FT.Clearing
    
    $USING PP.PaymentFrameworkService
    $INSERT I_PaymentFrameworkService_PORPmtFlowDetailsReq
    $INSERT I_PaymentFrameworkService_PORPmtFlowDetailsList
    $USING DX.Closeout
    $USING MD.Contract
    $USING SC.ScfTrailerFees

*
*************************************************************************
*
    
    GOSUB INITIALISE

    IF BOOKING.DATE OR VALUE.DATE THEN      ;*when Booking Date or Value date is entered validate the dates entered in selection
        GOSUB CHECK.DATES
    END
    
    GOSUB DECIDE.TXN.REF.FROM.ACCOUNT

    GOSUB VALIDATE.PARAMS
    
    GOSUB GET.APPLICATION
    
    IF EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParUpdateEntries> NE '' AND EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParUpdateEntries> NE 'NO' THEN
        IF APP MATCHES C$CRF.ONLINE.APPL THEN
* There are special cases where ECB will be updated with DEALID , DEALID.S & DEALID.B.
* Application such as FX,ND etc updates as above. Hence form ECB.ID with DEALID.B and check if ECB exists and proceed further.
* When the TXN.REF is from SC.TRAIL.FEES.ARRANGEMENT then the EXB is fetched based on TXN.REF begining with SC
            IF APP EQ 'SW' OR APP EQ 'FX' OR APP EQ 'ND' OR TXN.REF[1,3] EQ 'SC-' THEN
                GOSUB FORM.ECB.ID
            END ELSE
                GOSUB READ.ECB
                IF ECB.EXIST EQ '0' AND TXN.REF[1,3]='DXC' THEN
                    GOSUB READ.DXCO
                
                END
            END
        END
    END
    GOSUB SETUP.STMT.LIST

    STMT.CNT = DCOUNT(STMT.LIST,@FM)
    GOSUB DO.SWAP
    
    IF SaveIdCompany NE EB.SystemTables.getIdCompany() THEN
        ST.CompanyCreation.LoadCompany(SaveIdCompany)
    END
    
RETURN
*
*************************************************************************
*
INITIALISE:
*
    INTERNAL.CALL = STMT.LIST
    STMT.LIST = ''

    LOCATE 'TRANSACTION.REF' IN EB.Reports.getDFields()<1> SETTING ID.POS ELSE
        NULL
    END

    LOCATE 'DC.BATCH.DATE' IN EB.Reports.getDFields()<1> SETTING DC.POS ELSE
        NULL
    END

    LOCATE 'APPLICATION' IN EB.Reports.getDFields()<1> SETTING AP.POS ELSE
        NULL
    END

    TXN.REF = FIELD(EB.Reports.getDRangeAndValue()<ID.POS>,';',1)
    TXN.HIST = FIELD(EB.Reports.getDRangeAndValue()<ID.POS>,';',2)

    DC.DATE = EB.Reports.getDRangeAndValue()<DC.POS>
    APPL = EB.Reports.getDRangeAndValue()<AP.POS>

    EnqSelection = EB.Reports.getEnqSelection()
    
    EnqFields = EB.Reports.getEnqSelection()<2>
    LOCATE 'BOOKING.DATE' IN EnqFields<1,1> SETTING BD.POS THEN
        BD.OPERAND = EnqSelection<3,BD.POS>
        BOOKING.DATE = EnqSelection<4,BD.POS>
    END
    LOCATE 'VALUE.DATE' IN EnqFields<1,1> SETTING VD.POS THEN
        VD.OPERAND = EnqSelection<3,VD.POS>
        VALUE.DATE = EnqSelection<4,VD.POS>
    END
    
    EnquiryName = EnqSelection<1>
    SaveIdCompany = EB.SystemTables.getIdCompany()
    AC.ModelBank.setSpecEntryDetails('')

    REC = ''
    NO.HIST = '' ; FT.TAPES.ID = ''
*
    R.CONTRACT.BALANCES = ''

    R.EB.CONT.ENTRIES = ''

    OLD.CODE = ''
    ENT.LIST = ''

    ECB.EXIST = 0

    RE.Config.Applications('C$CRF.ONLINE.APPL',C$CRF.ONLINE.APPL)

    RET.STMT.ENTS = ''
    RET.CATEG.ENTS = ''

    POS = 0
    VAL.DATES = ''
    BOOK.DATE.TIMES = ''
    PROCESS.TFS.HIST = 0
    
    GOSUB CHECK.PRODUCT.INSTALLED
    
RETURN
*
***************************************************************************
*
CHECK.DATES:

* Only Booking Date or Value is allowed as Input Selection, set Date Option & Selection Operand accordingly
* Raise error incorrect dates are entered or both selection are entered

    BEGIN CASE
        CASE BOOKING.DATE NE ''
            DATE.OPTION = 'BOOK'
            DATE.OPERAND = BD.OPERAND
            DATE.VAL = BOOKING.DATE
            GOSUB VALIDATE.DATE
            START.DATE = FIRST.DATE
            END.DATE = SECOND.DATE
        CASE VALUE.DATE NE ''
            DATE.OPTION = 'VALUE'
            DATE.OPERAND = VD.OPERAND
            DATE.VAL = VALUE.DATE
            GOSUB VALIDATE.DATE
            START.DATE = FIRST.DATE
            END.DATE = SECOND.DATE
        CASE BOOKING.DATE NE '' AND VALUE.DATE NE ''
            EB.Reports.setEnqError("AC-MORE.THAN.ONE.DATE.SPECIFIED")
            GOSUB V$ERROR
    END CASE
    
RETURN
*
***************************************************************************
*
VALIDATE.DATE:
*** <desc>
**  Validations to handle Date input provided by the user.</desc>

    SAVE.COMI = EB.SystemTables.getComi()
    GIVEN.DATE = DATE.VAL
    IF DATE.OPERAND EQ 'RG' AND DCOUNT(GIVEN.DATE,@SM) EQ '2' THEN
        FIRST.DATE = GIVEN.DATE<1,1,1>
        EB.SystemTables.setComi(FIRST.DATE)
        GOSUB SET.ENQ.ERROR
        FIRST.DATE = EB.SystemTables.getComi()
        SECOND.DATE = GIVEN.DATE<1,1,2>
        IF SECOND.DATE THEN
            EB.SystemTables.setComi(SECOND.DATE)
            GOSUB SET.ENQ.ERROR
            SECOND.DATE = EB.SystemTables.getComi()
        END
    END ELSE
        EB.SystemTables.setComi(DATE.VAL)
        GOSUB SET.ENQ.ERROR
        FIRST.DATE = EB.SystemTables.getComi()
    END

    EB.SystemTables.setComi(SAVE.COMI)

RETURN
*
***************************************************************************
*
SET.ENQ.ERROR:
*** <desc>
**  Sets the error message if ETEXT returned from IN2D routine </desc>

    IF EB.SystemTables.getComi() NE "!TODAY" THEN
        EB.Utility.InTwod("11","D")
        IF EB.SystemTables.getEtext() THEN
            EB.Reports.setEnqError(EB.SystemTables.getEtext())
            GOSUB V$ERROR
        END
    END ELSE
        EB.SystemTables.setComi(EB.SystemTables.getToday())
    END

RETURN
*
***************************************************************************
*
DECIDE.TXN.REF.FROM.ACCOUNT:
********************
* For the AA account id , the Arrangement account id assigned in the Transaction Reference.
*
    IF NUM(TXN.REF) THEN

        R.ACCOUNT = ""
        ERR = ""
        R.ACCOUNT = AC.AccountOpening.Account.Read(TXN.REF, ERR)
* If the account record not present in LIVE check for the record in History as it might have closed
        IF NOT(R.ACCOUNT) THEN
            F.ACCOUNT.HIS=''
            HIS.ACCNO = TXN.REF
            EB.DataAccess.Opf("F.ACCOUNT$HIS",F.ACCOUNT.HIS)
            EB.DataAccess.ReadHistoryRec(F.ACCOUNT.HIS,HIS.ACCNO,R.ACCOUNT,HIS.ERR)
        END
    
*If the transaction reference is not account LIVE record and not in account HISTORY record then check if it is in SC.TRAIL.FEES.ARRANGEMENT or SC.TRAIL.FEES.ARRANGEMENT$HIS
        IF NOT(R.ACCOUNT) THEN
            R.ISSUER = ''
            ER = ''
            FN.SC.TRAIL.FEES.ARRANGEMENT = 'F.SC.TRAIL.FEES.ARRANGEMENT'
            F.SC.TRAIL.FEES.ARRANGEMENT = ''
            CUSTID =  TXN.REF
            EB.DataAccess.Opf(FN.SC.TRAIL.FEES.ARRANGEMENT,F.SC.TRAIL.FEES.ARRANGEMENT)
            EB.DataAccess.CacheRead(FN.SC.TRAIL.FEES.ARRANGEMENT,CUSTID,R.ISSUER,ER)
            IF NOT(R.ISSUER) THEN
                HIS.ERR = ''
                FN.SC.TRAIL.FEES.ARRANGEMENT.HIS = 'F.SC.TRAIL.FEES.ARRANGEMENT$HIS'
                F.SC.TRAIL.FEES.ARRANGEMENT.HIS = ''
                HIS.CUSTID = TXN.REF
                EB.DataAccess.Opf(FN.SC.TRAIL.FEES.ARRANGEMENT.HIS,F.SC.TRAIL.FEES.ARRANGEMENT.HIS)
                EB.DataAccess.CacheRead(FN.SC.TRAIL.FEES.ARRANGEMENT.HIS,HIS.CUSTID,R.ISSUER,HIS.ERR)
            END
        END

    

        BEGIN CASE
            CASE R.ACCOUNT<AC.AccountOpening.Account.ArrangementId>
* For the AA account id , the Arrangement account id assigned in the Transaction Reference.
                TXN.REF = R.ACCOUNT<AC.AccountOpening.Account.ArrangementId>

            CASE R.ACCOUNT<AC.AccountOpening.Account.AllInOneProduct>
* For the AZ account id alone is passed,then trans reference should be formed as 'AZ-'<account>
                TXN.REF = 'AZ-':TXN.REF
                
            CASE R.ISSUER
* For the SC.TRAIL.FEES.ARRANGEMENT,then trans reference should be formed as 'SC-'<customer>
                TXN.REF = 'SC-':TXN.REF


            CASE 1
* Check the AZ.ACCOUNT in history file, since after maturity of AZ , ALL.IN.ONE.PRODUCT field in ACCOUNT is nullified
                LOCATE 'AZ' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1>  SETTING AZ.POS THEN
                    AZ.HIS.ID = TXN.REF:';1'
                    R.AZ.ACCOUNT = ''
                    YERR = ''
                    R.AZ.ACCOUNT = AZ.Contract.Account.ReadHis(AZ.HIS.ID, YERR)
                    IF NOT(YERR) THEN
* For the AZ account id alone is passed,then trans reference should be formed as 'AZ-'<account>
                        TXN.REF = 'AZ-':TXN.REF
                    END
                END
        END CASE
    END

RETURN
***************************************************************************
*
VALIDATE.PARAMS:
*
* Ensure the only operand entered is 'EQ' and that a date is entered
* with a data capture contract only.
*
    EB.Reports.setEnqError('')

    IF NUM(TXN.REF) THEN
        IF NOT(DC.DATE) THEN
            EB.Reports.setEnqError('DC.BATCH.DATE MUST BE ENTERED FOR DATA CAPTURE DEALS')
            GOSUB V$ERROR
        END
        IF TXN.HIST THEN
            EB.Reports.setEnqError('NO HISTORY FOR DATA CAPTURE DEALS')
            GOSUB V$ERROR
        END
* BG_100008371 S
        IF LEN(TXN.REF) NE 7 AND LEN(TXN.REF) NE 10 THEN
            EB.Reports.setEnqError('INVALID TRANSACTION REFERENCE')
            GOSUB V$ERROR
        END
* BG_100008371 E
*
* Strip of the data.capture item number from the id if it has been entered
*
* BG_100008371 S
* If the TNX.REF is numeric then it should be either DDDDBBB or DDDDBBBIII
        IF LEN(TXN.REF) EQ 10 THEN
            TXN.REF = TXN.REF[1,LEN(TXN.REF)-3]   ;* BG_100007950
        END

* BG_100008371 E
    END ELSE
* BG_100008371 S
* If TXN.REF in not numeric then it should be either DCNNNNNDDDDBBB or DCNNNNNNDDDDBBBIII
        IF TXN.REF[1,2] NE 'DC' THEN
            IF DC.DATE THEN
                EB.Reports.setEnqError('DC.BATCH.DATE ONLY VALID FOR DATA CAPTURE TRANSACTIONS')
                GOSUB V$ERROR
            END
        END ELSE
            DC.DATE = ''
            IF LEN(TXN.REF) NE 14 AND LEN(TXN.REF) NE 17 OR NOT(NUM(TXN.REF[3,15])) THEN
* When DC REFERENCE has masking characters then throw error.
                EB.Reports.setEnqError('INVALID TRANSACTION REFERENCE')
                GOSUB V$ERROR
            END
            IF LEN(TXN.REF) EQ 17 THEN
                TXN.REF = TXN.REF[1,LEN(TXN.REF)-3]
            END
            DC.JULDATE = TXN.REF[3,5]
            EB.Utility.CheckDate(DC.JULDATE)

            EB.API.Juldate(DC.DATE,DC.JULDATE)

        END
    END
* BG_100008371 E
    
    CheckFields<1,1> = "TRANSACTION.REF"
    CheckFields<1,2> = "DC.BATCH.DATE"
    CheckFields<1,3> = "APPLICATION"
    TotalFields = DCOUNT(EB.Reports.getDFields(),@FM)
    FOR I = 1 TO TotalFields
        IF EB.Reports.getDFields()<I> MATCHES CheckFields AND EB.Reports.getDLogicalOperands()<I> AND EB.Reports.getDLogicalOperands()<I> NE '1' THEN
            EB.Reports.setEnqError('OPERANDS CAN ONLY BE EQUAL')
            GOSUB V$ERROR
        END
    NEXT I

    IF APPL THEN
        EB.SystemTables.setFFileControl('')
        ER = ''
        tmp.F.FILE.CONTROL = EB.SystemTables.getFFileControl()
        EB.DataAccess.Opf('F.FILE.CONTROL':@FM:"NO.FATAL.ERROR",tmp.F.FILE.CONTROL)
        EB.SystemTables.setFFileControl(tmp.F.FILE.CONTROL)
        IF EB.SystemTables.getEtext() THEN
            EB.Reports.setEnqError('NO FILE CONTROL FILE')
            GOSUB V$ERROR
        END
        R.REC = ''
        R.REC = EB.SystemTables.FileControl.Read(APPL, ER)
        IF ER THEN
            EB.Reports.setEnqError('NO FILE CONTROL RECORD FOR APPLICATION ':APPL)
            GOSUB V$ERROR
        END
    END


RETURN
*
***************************************************************************
*
GET.APPLICATION:
*
* Determine the application from the id and open the relevant file.
*
    APP = TXN.REF[1,2]
    SC.APP = TXN.REF[1,6]
    FD.APP = TXN.REF[1,3]
    AAA.REF = TXN.REF[1,5]
*Code Added to Support AM.PERFORMANCE.FEES entries
    AMPF.APP = FIELD(TXN.REF,'.',1)
    ! Support TELLER.FINANCIAL.SERVICES
    TFS.APP = TXN.REF[1,3]
    IF APP = 'BR' THEN
        APP = 'BL'
    END

    BEGIN CASE

        CASE TFS.APP EQ 'TFS'
            FILE.NAME = 'F.TELLER.FINANCIAL.SERVICES'
            FIELD.POS = TT.TellerFinancialService.TellerFinancialServices.TfsUlStmtNo
            
* Case for SY records
        CASE TXN.REF[1,5] EQ 'SYDCI'
            FILE.NAME = 'F.SY.DCI'
            FIELD.POS = DI.Contract.DCI.DciStmtNos
        CASE TXN.REF[1,6] EQ 'SYACDC'
            FILE.NAME = 'F.SY.ACCU.DECU'
            FIELD.POS = DP.Contract.AccuDecu.AdcStmtNos
        CASE TXN.REF[1,5] EQ 'SYIMF'
            FILE.NAME = 'F.SY.IMF'
            FIELD.POS = XF.Contract.IMF.ImfStmtNos
        CASE TXN.REF[1,6] EQ 'SYFXPT'
            FILE.NAME = 'F.SY.FX.FORWARDS'
            FIELD.POS = PT.Contract.FxForwards.FxfStmtNos

        CASE APP EQ 'TF'
            APP = 'LC'
            IF LEN(FIELD(TXN.REF,';',1)) GE 16 THEN ;* Check DR.DISC.AMENDMENTS id
                FILE.NAME = 'F.DR.DISC.AMENDMENTS'
                FIELD.POS = LC.Contract.DrDiscAmendments.DiscDrStmtEntryNo
            END ELSE
                IF LEN(FIELD(TXN.REF,';',1)) GE 14 THEN ;*ID of drawings will gets changed to 15 digits after 99 drawings.
                    FILE.NAME = 'F.DRAWINGS'
                    FIELD.POS = LC.Contract.Drawings.TfDrStmtEntryNo
                END ELSE
                    FILE.NAME = 'F.LETTER.OF.CREDIT'
                    FIELD.POS = LC.Contract.LetterOfCredit.TfLcStmtEntryNo
                END
            END
        CASE APP = 'SL'
            GOSUB GET.SL.FIELD.POS          ;* CI_10033946-S
            IF FILE.NAME = '' THEN          ;* If the user gives Invalid ID, do not fatal out.
                EB.Reports.setEnqError('INVALID ID')
                GOSUB V$ERROR
            END         ;* CI_10033946-E

        CASE APP EQ 'MG' AND FIELD(TXN.REF,'.',2)     ;* CI_10043178 S
            FILE.NAME = 'F.MG.PAYMENT'
            FIELD.POS = MG.Payment.Payment.PayStmtNo      ;* CI_10043178 E
        
        CASE AAA.REF EQ 'AAACT' AND EnquiryName EQ 'TXN.ENTRY.MB' AND NOT(INTERNAL.CALL)    ;*When AA Activity is enquired from TXN.ENTRY.MB
            GOSUB CHECK.AAA.ACT
        
        CASE AAA.REF EQ 'AAACT'                                                             ;*When AA Activity is enquired from TXN.ENTRY
            FILE.NAME = 'F.AA.ARRANGEMENT.ACTIVITY'
            FIELD.POS = AA.Framework.ArrangementActivity.ArrActStmtNos
            
        CASE APP = 'AA'
            FILE.NAME = 'F.EB.CONTRACT.BALANCES'
*AA account id is passed then restore that id further process.
            GOSUB AA.GET.TXN
            NO.HIST = 1
            
        CASE APPL EQ 'BOND.LENT.MASTER'
            FILE.NAME = 'F.BOND.LENT.MASTER'
            FIELD.POS = SC.SctSecurityLending.BondLentMaster.ScBlmStatementNos

        CASE APPL EQ 'DIV.COUP.CUS'
            FILE.NAME = 'F.DIV.COUP.CUS'
            FIELD.POS = SC.SccClassicCA.DivCoupCus.ScDpcStatementNos

        CASE APPL EQ 'REDEMPTION.CUS'
            FILE.NAME = 'F.REDEMPTION.CUS'
            FIELD.POS = SC.SccClassicCA.RedemptionCus.ScBalStatementNos

        CASE APPL EQ 'SAFEKEEP.HOLDING'
            FILE.NAME = 'F.SAFEKEEP.HOLDING'
            FIELD.POS = SC.ScfSafekeepingFees.SafekeepHolding.ShdStatementNos

        CASE APPL EQ 'SC.ADVISORY.CHG'
            FILE.NAME = 'F.SC.ADVISORY.CHG'
            FIELD.POS = SC.ScfAdvisoryFees.AdvisoryChg.AdcStatementNos

        CASE APPL EQ 'SC.POS.ADJUSTMENT'
            FILE.NAME = 'F.SC.POS.ADJUSTMENT'
            FIELD.POS = SC.ScvValuationUpdates.PosAdjustment.TraStatementNos
            NO.HIST = 1

        CASE APPL EQ 'SC.TRADING.POSITION'
            FILE.NAME = 'F.SC.TRADING.POSITION'
            FIELD.POS = SC.SctDealerBookPosition.TradingPosition.TrpStatementNo
            APP = 'SC' ;* TXN.REF will have the STP id, so decide the APP as SC.
            NO.HIST = 1

        CASE APPL EQ 'SC.STOCK.DIV.CUS'
            FILE.NAME = 'F.SC.STOCK.DIV.CUS'
            FIELD.POS = SC.SccClassicCA.StockDivCus.ScSddStatementNos
        
        CASE NUM(TXN.REF) OR APP EQ 'DC'    ;* BG_100007950
            FILE.NAME = 'F.DC.ENTRY'
            TXN.REF = DC.DATE:'-':TXN.REF
            
* Case for SC.TRAIL.FEES.ARRANGEMENT
        CASE TXN.REF[1,3] EQ 'SC-'
            FILE.NAME = 'F.SC.TRAIL.FEES.ARRANGEMENT'

        CASE 1
            GOSUB CHECK.EB.SYSTEM.ID
            IF FIELD.POS = "" THEN
                EB.Reports.setEnqError('INVALID TRANSACTION REFERENCE')
                GOSUB V$ERROR
            END

    END CASE

    FILE = ''
    EB.DataAccess.Opf(FILE.NAME,FILE)

    IF FIELD(FILE.NAME,".",2) = "DX" THEN
        F.DX.TRADE = ""
        EB.DataAccess.Opf("F.DX.TRADE", F.DX.TRADE)
    END

* for DX application DX.TRANSACTION holds the STMT.ENTRIES;
* for SY application SY.TRANSACTION holds the STMT.ENTRIES;
* since this
* is a LIVE file no HISTORY record is available.
    IF NOT(Clearing) AND NOT(DC.DATE) AND NOT(NO.HIST) AND NOT(FIELD(FILE.NAME,".",2) = "DX") AND NOT(FIELD(FILE.NAME,".",2) = "SY") AND NOT(FT.TAPES.ID) AND NOT(FIELD(FILE.NAME,".",2) EQ "POR") THEN
        FILE.NAME$HIS = FILE.NAME:'$HIS'
        FILE$HIS = ''
        EB.DataAccess.Opf(FILE.NAME$HIS,FILE$HIS)
    END

RETURN
*
*=====================================================================
GET.SL.FIELD.POS:
*=====================================================================

    SL.ID.LEN = LEN(TXN.REF)
    BEGIN CASE

        CASE SL.ID.LEN = 12
            FILE.NAME = 'F.PRE.SYNDICATION.FILE'
            FIELD.POS = SL.Presyndication.PreSyndicationFile.PreSyndStmtNo

        CASE SL.ID.LEN = 14
            IF APPL EQ 'SL.OD.SETTLE' THEN  ;* Display OD.SETTLE details only when APPL is stated exclusively.
                FILE.NAME = 'F.SL.OD.SETTLE'
                FIELD.POS = SL.ODSettlement.OdSettle.OdSetStmtNo
            END ELSE
                FILE.NAME = 'F.FACILITY'
                FIELD.POS = SL.Facility.Facility.FacStmtNo
            END

        CASE SL.ID.LEN = 18
            FILE.NAME = 'F.SL.BUY.SELL'
            FIELD.POS = SL.BuySell.BuySell.BsStmtNo

        CASE SL.ID.LEN EQ 19
            IF APPL EQ 'SL.OD.SETTLE' THEN
                FILE.NAME = 'F.SL.OD.SETTLE'
                FIELD.POS = SL.ODSettlement.OdSettle.OdSetStmtNo
            END ELSE
                FILE.NAME = 'F.SL.LOANS'
                FIELD.POS = SL.Loans.Loans.LnStmtNo
            END

        CASE SL.ID.LEN = 26
            FILE.NAME = 'F.SL.CHARGE'
            FIELD.POS = SL.Fees.Charge.SlcStmtNo

    END CASE

RETURN

***************************************************************************
*
CHECK.AAA.ACT:

* When Enquired from TXN.ENTRY.MB and AA Activity Id is used as Transaction Ref
* New AA Contract - With Enq Field set in AA Activity History
* Old AA Contract - Existing AA Contracts without the New Enq field in AA Activity History
*
* For New Contracts, when AAA is enquired, check the AAA record to get the STMT.NOS
* For Old Contracts, when AAA is enquired, get the Arrangement Reference & set Application as ECB
    
    ArrActErr = ''
    ArrActRec = AA.Framework.ArrangementActivity.Read(TXN.REF, ArrActErr)
    IF ArrActRec THEN
        ArrangementId = ArrActRec<AA.Framework.ArrangementActivity.ArrActArrangement>
        AAActHistory = AA.Framework.ActivityHistory.Read(ArrangementId, Error)
        IF AAActHistory<AA.Framework.ActivityHistory.AhContractEnq> EQ 'YES' THEN
            FILE.NAME = 'F.AA.ARRANGEMENT.ACTIVITY'
            FIELD.POS = AA.Framework.ArrangementActivity.ArrActStmtNos
        END ELSE
            FILE.NAME = 'F.EB.CONTRACT.BALANCES'
            TXN.REF = ArrangementId
            GOSUB AA.GET.TXN
            NO.HIST = 1
        END
    END ELSE
        GOSUB AA.GET.ERROR
    END
    
RETURN

***************************************************************************
*
AA.GET.TXN:
**********
* Account id is picked from AA.ARRANGEMENT.

    R.ARRANGEMENT = ""
    ERR = ""
    R.ARRANGEMENT = AA.Framework.Arrangement.Read(TXN.REF, ERR)
    
    IF R.ARRANGEMENT THEN
        IF  R.ARRANGEMENT<AA.Framework.ArrangementSim.ArrArrStatus> EQ "UNAUTH" OR R.ARRANGEMENT<AA.Framework.ArrangementSim.ArrArrStatus> EQ "RESTORE-UNAUTH" THEN
            GOSUB AA.GET.ERROR
        END
        LOCATE 'ACCOUNT' IN  R.ARRANGEMENT<AA.Framework.ArrangementSim.ArrLinkedAppl,1> SETTING ACCOUNT.POS THEN
            TXN.REF = R.ARRANGEMENT<AA.Framework.ArrangementSim.ArrLinkedApplId,ACCOUNT.POS>
        END ELSE
            GOSUB AA.GET.ERROR
        END
    END ELSE
        GOSUB AA.GET.ERROR
    END

RETURN
***************************************************************************
*
AA.GET.ERROR:
*************
* Common AA error Message.
    EB.Reports.setEnqError("ARRANGEMENT ID IS INCORRECT")
    GOSUB V$ERROR

RETURN
*******************************************************************************
CHECK.EB.SYSTEM.ID:
*==================
** Read the EB.SYSTEM.ID record
** Check first SC.APP
**             FD.APP
**             APP
*
*   TPS transaction ids begin with company mnemonic which might clash with ids of EB.SYSTEM.ID which might hold some other application. Thus first check for TPS
*   transactions else proceed to get application from EB.SYSTEM.ID.
*   New condition added to display TPS transactions based on TPS FT Reference Number. It is default Scenario and it checks for first 3 characters of ID in Transaction Reference.
*   If First 3 characters in the Transaction Reference is equal to ID in the MNEMONIC.COMPANY, then FILE.NAME will be assigned with POR.TRANSACTION.

*Mnemonic company read has to be done only if PP is installed
    IF ppInstalled THEN
        iPPCompRef = TXN.REF[1,3]
        oRecord = ""
        oError = ""
        oRecord = ST.CompanyCreation.MnemonicCompany.CacheRead(iPPCompRef, oError)
        IF oRecord NE "" THEN
            APPLVAL = APPL
            IF APPLVAL EQ 'POR.TRANSACTION' OR APPLVAL EQ '' THEN
                FILE.NAME = 'F.POR.TRANSACTION'
                FIELD.POS = PP.PaymentFrameworkService.PORPmtFlowDetailsList.entryIDs
            END
            RETURN
        END
    END
    Clearing = ''
    IF INDEX(TXN.REF,'-',1) THEN            ;* Check whether the passsed Transaction Ref is related to Clearing
        EntryParamId = FIELD(TXN.REF,'-',1)
        AEPError = ''
        FT.Clearing.AcEntryParam.CacheRead(EntryParamId, AEPError)
        IF NOT(AEPError) THEN
            Clearing = 1
            FILE.NAME = 'F.AC.INWARD.ENTRY'
            FIELD.POS = FT.Clearing.AcInwardEntry.AcieStmtNo
            RETURN
        END
    END
    
    SYS.ID.REC = "" ; YERR = "" ; CHEQUE.REC = ""
    SYS.ID.REC = EB.SystemTables.SystemId.Read(SC.APP, YERR)
    IF YERR THEN
        YERR = ""
        SYS.ID.REC = EB.SystemTables.SystemId.Read(FD.APP, YERR)

        IF YERR THEN
            YERR = ""
            SYS.ID.REC = EB.SystemTables.SystemId.Read(APP, YERR)

        END
        IF YERR THEN
            FT.TAPES.ID = FIELD(TXN.REF,'.',1) ; YERR = ''
            SYS.ID.REC = EB.SystemTables.SystemId.Read(FT.TAPES.ID, YERR)

        END
* For AM.PERFORMANCE.FEES entries as well as CHEQUE.ISSUE entries
        IF YERR THEN
            IF CQInstalled THEN
                CHEQUE.REC = CQ.ChqIssue.ChequeIssue.Read(TXN.REF, YERR)
            END
            IF CHEQUE.REC AND CQInstalled THEN
                FIELD.POS = CQ.ChqIssue.ChequeIssue.ChequeIsStmtNo
                FILE.NAME = 'F.CHEQUE.ISSUE'
            END ELSE
                LOCATE 'AM' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1>  SETTING SEL.POS THEN
                    GOSUB AMPF.CHECK        ;*Check if it is a Performance fees entry
                    SYS.ID.REC = EB.SystemTables.SystemId.Read(AMPF.APP, YERR)

                END ELSE
                    YERR = 'INVALID TRANSACTION REFERENCE'
                END
            END
        END
    END ELSE
        APP = "SC"
    END
*
    
    IF NOT(CHEQUE.REC) THEN
        FILE.NAME = SYS.ID.REC<EB.SystemTables.SystemId.SidStmtNoAppl>
        FIELD.POS = SYS.ID.REC<EB.SystemTables.SystemId.SidStmtNoLoc>
        IF FILE.NAME THEN         ;* Translate from name to number
            SS.REC = ""
            EB.API.GetStandardSelectionDets(FILE.NAME, SS.REC)
            LOCATE FIELD.POS IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN
                FIELD.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo, POS>
                FILE.NAME = "F.":FILE.NAME
            END ELSE
                FIELD.POS = ""
            END
        END
    END

RETURN
*
***************************************************************************
*
SETUP.STMT.LIST:
*
* Read in the contract and setup the entry.id's from the STMT.NO field
* unless the file read is the DC.ENTRY file in which case the record
* should be returned as the list.
*

    IF TXN.REF[1,2] EQ 'AZ' THEN        ;* BG_100004400 S
        TXN.REF = TXN.REF[4,999]
    END

    BEGIN CASE

        CASE FIELD(FILE.NAME,".",2) = "DX"
            R.DX.TRADE = ''
* Reading the DX.CLOSEOUT if TXN.ENTRY enq transid supplied as DXCO.
            IF R.DX.CLOSEOUT THEN
                DX.TRADEID = R.DX.CLOSEOUT<DX.Closeout.Closeout.CoTradeId>
            END ELSE
                DX.TRADEID = TXN.REF
            END
            DX.TRADEIDCOUNT = DCOUNT(DX.TRADEID, @VM)
            DX.TRADEIDCOUNTSTART=1
            LOOP
            WHILE DX.TRADEIDCOUNTSTART LE DX.TRADEIDCOUNT
                TXN.REF = DX.TRADEID<1,DX.TRADEIDCOUNTSTART>

                R.DX.TRADE = DX.Trade.Trade.Read(TXN.REF, ER)

                IF R.DX.TRADE NE '' THEN
* Use DX.TRADE to obtain STMT.ENTRY records
* -----------------------------------------

                    SS.REC = ""
                    DX.MASTER.REC = ''
                    EB.API.GetStandardSelectionDets("DX.TRADE", SS.REC)
                    EB.API.GetStandardSelectionDets("DX.CONTRACT.MASTER", DX.MASTER.REC)
                    LOCATE "CONTRACT.CODE" IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName, 1> SETTING CONTRACT.CODE.POS THEN
                        DX.MAS.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo, CONTRACT.CODE.POS>
                        R.DX.CONTRACT.MASTER = DX.Configuration.ContractMaster.Read(R.DX.TRADE<DX.MAS.POS>, ERR)
                    END
* Get trade currency
                    LOCATE "CURRENCY" IN DX.MASTER.REC<EB.SystemTables.StandardSelection.SslSysFieldName, 1> SETTING CCY.POS THEN
                        DM.CCY.POS =  DX.MASTER.REC<EB.SystemTables.StandardSelection.SslSysFieldNo , CCY.POS>
                        TRADE.CCY = R.DX.CONTRACT.MASTER<DM.CCY.POS>
                        IF NOT(TRADE.CCY) THEN ;* Trade currency is taken from DX.TRADE if not available in DX.CONTRACT.MASTER
                            TRADE.CCY = R.DX.TRADE<DX.Trade.Trade.TraTradeCcy>
                                
                        END
                    END

*Get delivery currency
                    LOCATE "DELIVERY.CURRENCY" IN DX.MASTER.REC<EB.SystemTables.StandardSelection.SslSysFieldName, 1> SETTING DEV.CCY.POS THEN
                        DM.CCY.POS = DX.MASTER.REC<EB.SystemTables.StandardSelection.SslSysFieldNo , DEV.CCY.POS>
                        DEV.CCY = R.DX.CONTRACT.MASTER<DM.CCY.POS>
                        IF NOT(DEV.CCY) THEN ;* Delivery currency is taken from DX.TRADE if not available in DX.CONTRACT.MASTER
                            DEV.CCY = R.DX.TRADE<DX.Trade.Trade.TraDlvCcy>
                        END
                    END

*Get primary account ccy position

                    LOCATE "PRI.ACC.CCY" IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName, 1> SETTING PRI.ACCT.CCY.FIELD.POS THEN
                        PRI.ACCT.CCY.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo, PRI.ACCT.CCY.FIELD.POS>
                    END

*Get secondary account ccy position
                    LOCATE "SEC.ACC.CCY" IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName, 1> SETTING SEC.ACCT.CCY.FIELD.POS THEN
                        SEC.ACCT.CCY.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo, SEC.ACCT.CCY.FIELD.POS>
                    END
* Get primary ref ccy position
                    LOCATE "PRI.REF.CCY" IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName, 1> SETTING PRI.REF.CCY.FIELD.POS THEN
                        PRI.REF.CCY.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo, PRI.REF.CCY.FIELD.POS>
                    END
* Get commission account ccy position
                    LOCATE "PRI.COMM.CCY" IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName, 1> SETTING PRI.COMM.ACCT.CCY.FIELD.POS THEN
                        PRI.COMM.ACCT.CCY.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo, PRI.COMM.ACCT.CCY.FIELD.POS>
                    END
* Get secondary account ccy position
                    LOCATE "SEC.COMM.CCY" IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName, 1> SETTING SEC.COMM.ACCT.CCY.FIELD.POS THEN
                        SEC.COMM.ACCT.CCY.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo, SEC.COMM.ACCT.CCY.FIELD.POS>
                    END
* Get secondary ref ccy position
                    LOCATE "SEC.REF.CCY" IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName, 1> SETTING SEC.REF.CCY.FIELD.POS THEN
                        SEC.REF.CCY.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo, SEC.REF.CCY.FIELD.POS>
                    END



* First process primary transactions

                    LOCATE "PRI.TRANS.KEY" IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName, 1> SETTING PRI.KEY.FIELD.POS THEN
                        PRI.KEY.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,PRI.KEY.FIELD.POS>
                        PRIMARY.CUSTOMER.LIST = R.DX.TRADE<PRI.KEY.POS> ;* Can have more than 1 customer
                        CUST.CNT = 1
                        LOOP
                            REMOVE PRI.CUST.ID FROM PRIMARY.CUSTOMER.LIST SETTING PRI.POS
                        WHILE PRI.CUST.ID:PRI.POS
                            DX.TRANS.KEY  = PRI.CUST.ID

* process the ECB for trade currency
                            CCY.VALUE = TRADE.CCY
                            GOSUB GET.DX.STATEMENTS.FOR.DX.TRADE

*process the ECB for delivery currency
                            IF DEV.CCY AND (DEV.CCY NE CCY.VALUE) THEN
                                CCY.VALUE = DEV.CCY
                                GOSUB GET.DX.STATEMENTS.FOR.DX.TRADE
                            END

*process the ECB for the primary account currency
* If primary account currency is different from delivery and trade currency then,
* entry ids are fetched from that ECB
                            PRI.ACCT.CCY = R.DX.TRADE<PRI.ACCT.CCY.POS,CUST.CNT>
                            IF PRI.ACCT.CCY NE TRADE.CCY AND PRI.ACCT.CCY NE DEV.CCY THEN
                                CCY.VALUE = PRI.ACCT.CCY
                                GOSUB GET.DX.STATEMENTS.FOR.DX.TRADE
                            END
* When reference currency differs from Trade currency

                            PRI.REF.CCY = R.DX.TRADE<PRI.REF.CCY.POS,CUST.CNT>
                            IF PRI.REF.CCY AND PRI.REF.CCY NE TRADE.CCY THEN
                                CCY.VALUE = PRI.REF.CCY
                                GOSUB GET.DX.STATEMENTS.FOR.DX.TRADE
                            END
* When the commission currency is different from deal currency.
* Loop through total commission currencies and get the ECB
                            COMM.ACCT.CCY.LIST = R.DX.TRADE<PRI.COMM.ACCT.CCY.POS> ;* Take the list of Commission currencies for primary.
                            GOSUB GET.COMM.CCY.ENTS

                            CUST.CNT += 1
                        REPEAT

                    END

* Now process secondary transactions
                    LOCATE "SEC.TRANS.KEY" IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName, 1> SETTING SEC.KEY.FIELD.POS THEN
                        SEC.KEY.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,SEC.KEY.FIELD.POS>
                        DX.TRANS.KEY  = R.DX.TRADE<SEC.KEY.POS>
* process the ECB for trade currency
                        CCY.VALUE = TRADE.CCY
                        GOSUB GET.DX.STATEMENTS.FOR.DX.TRADE

*process the ECB for delivery currency
                        IF DEV.CCY AND (DEV.CCY NE CCY.VALUE) THEN
                            CCY.VALUE = DEV.CCY
                            GOSUB GET.DX.STATEMENTS.FOR.DX.TRADE
                        END

*process the ECB for the secondary account currency
* If secondary account currency is different from delivery and trade currency then,
* entry ids are fetched from that ECB
                        SEC.ACCT.CCY = R.DX.TRADE<SEC.ACCT.CCY.POS>
                        IF SEC.ACCT.CCY NE  TRADE.CCY AND SEC.ACCT.CCY NE DEV.CCY THEN
                            CCY.VALUE = SEC.ACCT.CCY
                            GOSUB GET.DX.STATEMENTS.FOR.DX.TRADE
                        END
* If ref currency is diffrent from trade currecny.

                        SEC.REF.CCY = R.DX.TRADE<SEC.REF.CCY.POS>
                        IF SEC.REF.CCY AND SEC.REF.CCY NE TRADE.CCY THEN
                            CCY.VALUE = SEC.REF.CCY
                            GOSUB GET.DX.STATEMENTS.FOR.DX.TRADE
                        END
* When the commission currency is different from deal currency.
* Loop through total commission currencies and get the ECB
                        COMM.ACCT.CCY.LIST = ""
                        COMM.ACCT.CCY.LIST = R.DX.TRADE<SEC.COMM.ACCT.CCY.POS> ;* Take the list of Commission currencies for Secondary.
                        GOSUB GET.COMM.CCY.ENTS
                    END
                END ELSE
* Use previous selection routine
* ------------------------------

                    SEL.CMD = "SELECT ":FILE.NAME:" LIKE ":TXN.REF:"..."
                    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.SELS, ERR)
                    TXN.ID.LIST=SEL.LIST

                    LOOP
                        REMOVE TXN.ID FROM TXN.ID.LIST SETTING YPOS
                    WHILE TXN.ID:YPOS
                        EB.DataAccess.FRead(FILE.NAME,TXN.ID,REC,FILE,ER)
                        DX.TRANS.KEY  = TXN.ID

* process the ECB for trade currency
                        CCY.VALUE = REC<DX.Trade.Transaction.TxTradeCcy>
                        GOSUB GET.DX.STATEMENTS.FOR.DX.TRADE
                        DEV.CCY = REC<DX.Trade.Transaction.TxDeliveryCcy>

* process the ECB for delivery currency

                        IF DEV.CCY AND (DEV.CCY NE CCY.VALUE) THEN
                            CCY.VALUE = DEV.CCY
                            GOSUB GET.DX.STATEMENTS.FOR.DX.TRADE
                        END

* process the ECB for the primary account currency
*If primary account currency is different from delivery and trade currency then,
*entry ids are fetched from that ECB

                        ACCT.CCY =  REC<DX.Trade.Transaction.TxAccCcy>
                        IF ACCT.CCY NE TRADE.CCY AND ACCT.CCY NE DEV.CCY THEN
                            CCY.VALUE = ACCT.CCY
                            GOSUB GET.DX.STATEMENTS.FOR.DX.TRADE
                        END
                    REPEAT
                END
                DX.TRADEIDCOUNTSTART++
            REPEAT
*       New CASE added to display TPS transactions based on TPS FT Reference and display list of transactions generated for that FT reference.
        CASE FILE.NAME EQ "F.POR.TRANSACTION"
            companyID =  TXN.REF[1,3]
            iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.companyID> = companyID
            iPORPmtFlowDetailsReq<PP.PaymentFrameworkService.PORPmtFlowDetailsReq.ftNumber> = TXN.REF
                
*           Based on Transaction Reference Number and Company ID, Statement Entry Details will be fetched from Payment Flow Details.
            PP.PaymentFrameworkService.getPORPaymentFlowDetails(iPORPmtFlowDetailsReq, oPORPmtFlowDetailsList, oPORPmtFlowDetailsGetError)
            iStatementEntries = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.entryIDs>
            iStatementEntries<-1> = oPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.reversalEntryIDs>
            IF iStatementEntries THEN
                FMC = DCOUNT(iStatementEntries,@FM)
                FOR ZI = 1 TO FMC
                    STMT.FIELD = iStatementEntries<ZI>
                    FULL.STMT.FIELD = ""
                    LAST.STMT.FIELD = ""
                    VMC = DCOUNT(STMT.FIELD,@VM)
                    FOR YI = 1 TO VMC
                        IF STMT.FIELD<1,YI> = "_" THEN
                            STMT.FIELD<1,YI> = FULL.STMT.FIELD<1,YI>
                        END
                    NEXT YI
                    FULL.STMT.FIELD = STMT.FIELD
                    IF STMT.FIELD NE LAST.STMT.FIELD THEN
                        GOSUB PROCESS.STMT.LIST
                        LAST.STMT.FIELD = STMT.FIELD
                    END
                NEXT ZI
            END
        CASE FIELD(FILE.NAME,'.',2,99) EQ 'AC.INWARD.ENTRY'

* Clearing can have two types of STMT.NOS updated in the Record
* Updated with Short Entry Id & Counts with company details
* Updated with Direct Entry Id without any count or company details
            
            REC = FT.Clearing.AcInwardEntry.Read(TXN.REF, ER)
            IF REC THEN
                STMT.FIELD = REC<FIELD.POS>
                STMT.NOS = FIELD(STMT.FIELD<1,1>,'.',2)
                IF LEN(STMT.NOS) EQ 2 THEN
                    GOSUB PROCESS.STMT.LIST
                END ELSE
                    REC = AC.EntryCreation.StmtEntry.Read(STMT.FIELD, Error)
                    IF NOT(REC) THEN
                        REC = AC.EntryCreation.StmtEntryDetail.Read(STMT.FIELD, Error)
                    END
                    STMT.FIELD = REC<AC.EntryCreation.StmtEntry.SteStmtNo>
                    GOSUB PROCESS.STMT.LIST
                END
            END
            
        CASE 1
            IF TXN.REF[1,3] EQ 'SC-' THEN
                TXN.REF = TXN.REF[4,LEN(TXN.REF)]
            END
            
            EB.DataAccess.FRead(FILE.NAME,TXN.REF,REC,FILE,ER)
* BG_100008371 S
* If TXN.REF is input as in old format and if DC.ENTRY does not exist
* then convert it into new format and read again.
            IF ER AND DC.DATE THEN
                IF NUM(FIELD(TXN.REF,'-',2)) THEN
                    TXN.REF = FIELD(TXN.REF,'-',2)
                    DC.JULDATE = ''
                    EB.API.Juldate(DC.DATE,DC.JULDATE)
                    TXN.REF = DC.DATE:'-DC':DC.JULDATE[3,5]:TXN.REF
                    EB.DataAccess.FRead(FILE.NAME,TXN.REF,REC,FILE,ER)
                END
            END
* BG_100008371 E

            IF ER AND NOT(ECB.EXIST) THEN

* Skip the read from history for SY application since SY.TRANSACTION is a live table and does not have history records.
                IF NOT(DC.DATE) AND NOT(TXN.HIST) AND NOT(NO.HIST) AND NOT(FIELD(FILE.NAME,".",2) = "SY") THEN
                    TXN.HIST = 1
                END
            END ELSE
                IF DC.DATE THEN
                    ENT.LIST = REC
                    Y.DC.COUNT = DCOUNT(REC,@FM)
                    FOR I = 1 TO Y.DC.COUNT
                        Y.FILE = ENT.LIST<I>[1,1]
                        ENT.ID = ENT.LIST<I>[2,99]
                        Y.READ.ERR = ""
                        BEGIN CASE
                            CASE Y.FILE EQ "S"
                                Y.READ.ERR = ""
                                ENT.REC = AC.EntryCreation.StmtEntry.Read(ENT.ID, Y.READ.ERR)
                                IF Y.READ.ERR THEN ;* If Entry is not present , then check in DETAIL table.
                                    Y.READ.ERR = ""
                                    ENT.REC = AC.EntryCreation.StmtEntryDetail.Read(ENT.ID, Y.READ.ERR)
                                END
                                
                            CASE Y.FILE EQ "C"
                                Y.READ.ERR = ""
                                ENT.REC = AC.EntryCreation.CategEntry.Read(ENT.ID, Y.READ.ERR)
                                IF Y.READ.ERR THEN ;* If Entry is not present , then check in DETAIL table.
                                    Y.READ.ERR = ""
                                    ENT.REC = AC.EntryCreation.CategEntryDetail.Read(ENT.ID, Y.READ.ERR)
                                END
                        END CASE
                        CO.CODE = ENT.REC<AC.EntryCreation.StmtEntry.SteCompanyCode>
                        IF I = 1 OR CO.CODE NE OLD.CODE THEN
                            OLD.CODE = CO.CODE
                            COMP.REC =''
                            COMP.REC = ST.CompanyCreation.Company.CacheRead(CO.CODE, "")
                        END
                        CO.MNEMONIC = COMP.REC<ST.CompanyCreation.Company.EbComMnemonic>
                        STMT.LIST<-1> = ENT.LIST<I>:"*":CO.MNEMONIC
                    NEXT I
                    RETURN
                END
                
                IF APP MATCHES C$CRF.ONLINE.APPL AND ECB.EXIST EQ '1' THEN
                    GOSUB GET.ENT.FROM.ECB
                END ELSE
                    STMT.FIELD = REC<FIELD.POS>
                    IF TXN.REF[1,3] EQ 'TFS' OR APPL EQ 'TELLER.FINANCIAL.SERVICES' THEN
                        PROCESS.TFS.HIST = 0
                        GOSUB PROCESS.TFS.STMT.LIST
                    END ELSE
                        GOSUB PROCESS.STMT.LIST
                    END
                END
            END         ;* CI_10007309 s/e

            IF TXN.HIST THEN
*
** Get the last full record
*
                
                GOSUB CALCULATE.FULL.HIST.NO ; * calculate FULL.HIST.NO
                
                FULL.HIST.ID = TXN.REF:";":FULL.HIST.NO ; FULL.REC = ""
                EB.DataAccess.FRead(FILE.NAME$HIS, FULL.HIST.ID, FULL.REC, FILE$HIS, "")
                FULL.STMT.FIELD = FULL.REC<FIELD.POS>
*
                INC = 0
                TXN.START = FULL.HIST.NO    ;* Use for counter
                LAST.STMT.FIELD = ""        ;* Store to compare changes
                LOOP
                    HIST.ID = TXN.REF:';':TXN.START+INC
                    REC = ''
                    ER = ''
                    EB.DataAccess.FRead(FILE.NAME$HIS,HIST.ID,REC,FILE$HIS,ER)
                UNTIL ER
                    STMT.FIELD = REC<FIELD.POS>
                    IF STMT.FIELD THEN
*
** Go thriugh the whole entry field and fill in the "_"
** from the last full record. Only process if the history
** numbers have changed
*
                        VMC = DCOUNT(STMT.FIELD,@VM)
                        FOR YI = 1 TO VMC
                            IF STMT.FIELD<1,YI> = "_" THEN
                                STMT.FIELD<1,YI> = FULL.STMT.FIELD<1,YI>
                            END
                        NEXT YI
                        FULL.STMT.FIELD = STMT.FIELD
                        IF STMT.FIELD NE LAST.STMT.FIELD THEN
                            IF TXN.START + INC GE TXN.HIST THEN ;* Only once we reach the start
                                GOSUB PROCESS.STMT.LIST
                            END
                            LAST.STMT.FIELD = STMT.FIELD
                        END
                    END
                    IF TXN.REF[1,3] EQ 'TFS' OR APPL EQ 'TELLER.FINANCIAL.SERVICES' THEN
                        PROCESS.TFS.HIST = 1
                        GOSUB PROCESS.TFS.STMT.LIST
                    END ELSE
                        GOSUB PROCESS.STMT.LIST.HIST
                    END

                    INC += 1
                REPEAT
            END

    END CASE

    IF NOT(STMT.LIST) THEN
        EB.Reports.setEnqError('NO ENTRIES FOUND FOR TRANSACTION ':TXN.REF)
        GOSUB V$ERROR
    END

RETURN

*
**************************************************************************
PROCESS.TFS.STMT.LIST:
    ! Loop through each TFS Leg and get the respective Stmt Nos and for each of
    ! them, do PROCESS.STMT.LIST.
    GOSUB LOOP.THROUGH.TFS.STMT.NOS
    IF REC<TT.TellerFinancialService.TellerFinancialServices.TfsRUlStmtNo> THEN
        STMT.FIELD = REC<TT.TellerFinancialService.TellerFinancialServices.TfsRUlStmtNo>
        GOSUB LOOP.THROUGH.TFS.STMT.NOS
    END

RETURN
****************************************************************************
LOOP.THROUGH.TFS.STMT.NOS:

    SAVE.STMT.FIELD = STMT.FIELD
    NO.OF.TFS.LEGS = DCOUNT(REC<TT.TellerFinancialService.TellerFinancialServices.TfsTransaction>,@VM)
    TFS.LEG.COUNT = 1
    LOOP
    WHILE TFS.LEG.COUNT LE NO.OF.TFS.LEGS DO

        STMT.FIELD = RAISE(SAVE.STMT.FIELD<1,TFS.LEG.COUNT>)          ;* Raise from SM to VM
        IF PROCESS.TFS.HIST THEN
            GOSUB PROCESS.STMT.LIST.HIST
        END ELSE
            GOSUB PROCESS.STMT.LIST
        END

        TFS.LEG.COUNT += 1

    REPEAT

RETURN

***************************************************************************
PROCESS.STMT.LIST.HIST:

    IF STMT.FIELD THEN
*
** Go thriugh the whole entry field and fill in the "_"
** from the last full record. Only process if the history
** numbers have changed
*
        VMC = DCOUNT(STMT.FIELD,@VM)
        FOR YI = 1 TO VMC
            IF STMT.FIELD<1,YI> = "_" THEN
                STMT.FIELD<1,YI> = FULL.STMT.FIELD<1,YI>
            END
        NEXT YI
        FULL.STMT.FIELD = STMT.FIELD
        IF STMT.FIELD NE LAST.STMT.FIELD THEN
            IF TXN.START + INC GE TXN.HIST THEN   ;* Only once we reach the start
                GOSUB PROCESS.STMT.LIST
            END
            LAST.STMT.FIELD = STMT.FIELD
        END
    END
RETURN
***************************************************************************
*
PROCESS.STMT.LIST:
*
    
* Determine & store the entry ids.
*
    IF STMT.FIELD<1,1> = "_" THEN       ;* No new entries
        RETURN      ;* Go on to next history record
    END
*
    GOSUB GET.ENTRY.POS
    GOSUB GET.TXN.COMPANY.MNEMONIC
*
    DATE.FILTER = 1
    CURR.MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic)
    LOOP
    WHILE STMT.FIELD<1,ENTRY.POS+1> ;* Whilst there are figures
        GOSUB GET.STMT.ENTRIES
        GOSUB GET.CATEG.ENTRIES
        ENTRY.POS += 3        ;* Try to get the next company
        GOSUB GET.ACC.COMPANY.MNEMONIC
    REPEAT

RETURN
***************************************************************
GET.ENTRY.POS:
*************

    ENTRY.POS = 0   ;* Position of entries
    IF NOT(STMT.FIELD<1,1>) THEN ; * When there is no entry for txn company then check for account company.
*Because there may be cases where both the accounts in a txns is from other company. In that case STMT.NOS field
* in the txn will the in format of
* Eg: txn done from BR1 for contingent accts in BNK.
*
*153 AUTH.DATE......... 30 NOV 2000
*163. 3 STMT.NOS....... US0010001
*163. 4 STMT.NOS....... 173830000557846.01
*163. 5 STMT.NOS....... 1-2
*164. 1 OVERRIDE....... EXREMFORM/FT*501 FROM 1001 RECEIVED

        ENTRY.POS = 3
    END

RETURN
***************************************************************
GET.TXN.COMPANY.MNEMONIC:
*************************
    IF REC<FIELD.POS+7> MATCHES "2A7N" THEN       ;* Load the correct initial company
        CO.CODE = REC<FIELD.POS+7> ; COMP.REC = ''
        COMP.REC = ST.CompanyCreation.Company.CacheRead(CO.CODE, "")
        CO.MNEMONIC = COMP.REC<ST.CompanyCreation.Company.EbComMnemonic>
    END ELSE
        CO.MNEMONIC = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic)  ;* Multi company mnemonic
    END

RETURN
***************************************************************
GET.ACC.COMPANY.MNEMONIC:
*************************

    LOOP
        IF STMT.FIELD<1,ENTRY.POS> MATCHES "2A7N" THEN  ;* Company code
            COMP.ID = STMT.FIELD<1,ENTRY.POS>   ;* get the company code from Entry
            IF COMP.ID MATCHES EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComAccountingCompany) THEN   ;* If company code in entry is Accounting Company and if enquiry is executed from Parent company
                CO.MNEMONIC = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic)          ;* set it to parent company
            END ELSE
                R.COMP = ST.CompanyCreation.Company.CacheRead(COMP.ID, ER)
                CO.MNEMONIC = R.COMP<ST.CompanyCreation.Company.EbComMnemonic>
            END
        END
    UNTIL STMT.FIELD<1,ENTRY.POS> MATCHES "2A7N":@VM:""
        ENTRY.POS += 1    ;* depends on number of Stmt and Categ entries
    REPEAT

RETURN
****************************************************************
GET.STMT.ENTRIES:
*****************
    
    NO.OF.ST.ENTS = STMT.FIELD<1,ENTRY.POS+2>
    NO.OF.SP.ENTS = FIELD(NO.OF.ST.ENTS,"*",2)
    NO.OF.ST.ENTS = FIELD(NO.OF.ST.ENTS,"*",1)            ;* Separate the SPEC.ENTRY counts, which will be updated incase of AA transactions.
    IF FIELD(NO.OF.ST.ENTS,'-',2) THEN
        NO.OF.ST.ENTS = FIELD(NO.OF.ST.ENTS,'-',2)
    END

*For New AA Contracts with Only Spec Entries, update the Common with Spec Entry details which can be used in TXN.ENTRY.MB
    IF NOT(NO.OF.ST.ENTS) AND NO.OF.SP.ENTS THEN
        SPEC.ENTRY.DETAILS = STMT.FIELD
        SPEC.ENTRY.DETAILS<-1> = CO.MNEMONIC
        AC.ModelBank.setSpecEntryDetails(SPEC.ENTRY.DETAILS)
    END
        
    FOR I = 1 TO NO.OF.ST.ENTS
        ST.ID = '(S':STMT.FIELD<1,ENTRY.POS+1>:FMT(I,'4"0"R'):"*":CO.MNEMONIC
        LOCATE ST.ID IN STMT.LIST<1> SETTING POS ELSE
            GOSUB SORT.STMT.LIST
        END
    NEXT I

RETURN
***************************************************************
GET.CATEG.ENTRIES:
******************

    NO.OF.CT.ENTS = STMT.FIELD<1,ENTRY.POS+3>
    IF FIELD(NO.OF.CT.ENTS,'-',2) THEN
        NO.OF.CT.ENTS = FIELD(NO.OF.CT.ENTS,'-',2)
    END ELSE
        IF NOT(NUM(NO.OF.CT.ENTS)) THEN
            NO.OF.CT.ENTS = ""      ;* Could be a company code
        END
    END

    FOR I = 1 TO NO.OF.CT.ENTS
        ST.ID = ')C':STMT.FIELD<1,ENTRY.POS+1>:FMT(I,'4"0"R'):"*":CO.MNEMONIC
        LOCATE ST.ID IN STMT.LIST<1> SETTING POS ELSE
            GOSUB SORT.STMT.LIST
        END
    NEXT I

RETURN
*************************************************************
READ.DXCO:
**********
*Reading DX.CLOSEOUT table

    TXN.REF.CLC =''
    R.DX.CLOSEOUT = ''
    R.DX.CLOSEOUT = DX.Closeout.Closeout.Read(TXN.REF, ERR)
    IF ERR THEN
        FN.DX.CLOSEOUT.HIS = 'F.DX.CLOSEOUT$HIS'
        F.DX.CLOSEOUT.HIS = ''
        EB.DataAccess.Opf(FN.DX.CLOSEOUT.HIS, F.DX.CLOSEOUT.HIS)
        R.DX.CLOSEOUT = DX.Closeout.Closeout.Read(TXN.REF, HIS.ERR) ; * Need not to be latest curr id as we just need trade id involved in closeout.
    END
    IF R.DX.CLOSEOUT THEN
        TXN.REF.CLC = TXN.REF

    END
RETURN
***************************************************************
READ.ECB:
************************
    
* To get the entries from ecb for the contract in ecb

    R.CONTRACT.BALANCES = BF.ConBalanceUpdates.EbContractBalances.Read(TXN.REF, ERR)

    IF R.CONTRACT.BALANCES THEN
        ECB.EXIST = 1
    END


RETURN

FORM.ECB.ID:
************
    CONTRACT.ID = TXN.REF
    IF APP EQ 'SW' THEN
        TXN.REF = CONTRACT.ID:'.':'A'
        GOSUB READ.ECB

        IF NOT(ECB.EXIST) THEN
            TXN.REF = CONTRACT.ID:'.':'L'
            GOSUB READ.ECB
        END
    END
    IF APP EQ 'FX' THEN
        TXN.REF = CONTRACT.ID:'.':'B'
        GOSUB READ.ECB
    END

* Check if ND.B exists and set the ECB.EXISTS flag accordingly.
    IF APP EQ 'ND' THEN
        TXN.REF = CONTRACT.ID:'.':'B'
        GOSUB READ.ECB
* ND.DEAL.B & ND.DEAL.S will be generated only in COB, so when these records doesn't exists that is transaction has created only the ND.DEAL ECB
* then in that case read the ND.DEAL ECB and set ECB.EXISTS flag accordingly.
        IF NOT(ECB.EXIST) THEN
            TXN.REF = CONTRACT.ID
            GOSUB READ.ECB
        END
    END

    IF TXN.REF[1,3] EQ 'SC-' THEN
        TXN.REF = CONTRACT.ID[4,LEN(TXN.REF)]
        GOSUB READ.ECB
    END

    TXN.REF = CONTRACT.ID
RETURN

*-------------------------
GET.ENT.FROM.ECB:
*---------------------------

    CONTRACT.ID = ''
    ENTRY.TYPE = 'S'

    RET.STMT.ENTS = ''
    DATE.FILTER = 0

    BEGIN CASE
        CASE APP EQ 'ND'
            GOSUB GET.ND
            RET.STMT.ENTS = RET.ENTRIES
        CASE APP EQ 'SW' OR APP EQ 'FX'
            GOSUB GET.SW.FX.ENT
            RET.STMT.ENTS = RET.ENTRIES
        CASE FIELD(FILE.NAME,".",2) = "DX"
            CONTRACT.ID = TXN.PREFIX : '.' :CCY.VALUE
            GOSUB CALL.EB.GET.CONT.ENTS
            RET.STMT.ENTS = ENTRY.LIST
        CASE APP EQ 'MD'
            GOSUB GET.MD
            RET.STMT.ENTS = RET.ENTRIES
        CASE TXN.REF[1,3] EQ 'SC-'
            CONTRACT.ID = TXN.REF[4,LEN(TXN.REF)]
            GOSUB CALL.EB.GET.CONT.ENTS
            RET.STMT.ENTS = ENTRY.LIST
        CASE 1
            CONTRACT.ID = TXN.REF
            GOSUB CALL.EB.GET.CONT.ENTS
            RET.STMT.ENTS = ENTRY.LIST
    END CASE

    GOSUB RETURN.ENTRIES


    ENTRY.TYPE = 'C'

    BEGIN CASE
        CASE APP EQ 'ND'
            GOSUB GET.ND
            RET.CATEG.ENTS = RET.ENTRIES
        CASE APP EQ 'SW' OR APP EQ 'FX'
            GOSUB GET.SW.FX.ENT
            RET.CATEG.ENTS = RET.ENTRIES
        CASE FIELD(FILE.NAME,".",2) = "DX"
            CONTRACT.ID = TXN.PREFIX : '.' :CCY.VALUE
            GOSUB CALL.EB.GET.CONT.ENTS
            RET.CATEG.ENTS = ENTRY.LIST
        CASE APP EQ 'MD'
            GOSUB GET.MD
            RET.CATEG.ENTS = RET.ENTRIES
        CASE 1
            CONTRACT.ID = TXN.REF
            GOSUB CALL.EB.GET.CONT.ENTS
            RET.CATEG.ENTS = ENTRY.LIST

    END CASE

    GOSUB RETURN.ENTRIES

RETURN

GET.SW.FX.ENT:
**************
    IF APP EQ 'SW' THEN
        CONTRACT.ID = TXN.REF:'.':'A'
    END ELSE
        CONTRACT.ID = TXN.REF:'.':'B'
    END

    GOSUB CALL.EB.GET.CONT.ENTS
    RET.ENTRIES = ENTRY.LIST

    IF APP EQ 'SW' THEN
        CONTRACT.ID = TXN.REF:'.':'L'
    END ELSE
        CONTRACT.ID = TXN.REF:'.':'S'
    END

    GOSUB CALL.EB.GET.CONT.ENTS
    RET.ENTRIES<-1> = ENTRY.LIST

RETURN

*-------------------------
CALL.EB.GET.CONT.ENTS:
*----------------------
    
    ENTRY.LIST = ''
    
    IF DATE.OPTION THEN     ;* Pass Date Option - BOOK or VALUE along with Selection Operand for filter purpose
        CONTRACT.ID<2,1> = DATE.OPTION
        CONTRACT.ID<2,2> = DATE.OPERAND
    END
    
    IF INTERNAL.CALL AND NUM(INTERNAL.CALL) THEN
        CONTRACT.ID<3> = INTERNAL.CALL
    END

    AC.API.EbGetContractEntries(CONTRACT.ID,ENTRY.TYPE,START.DATE,END.DATE,ENTRY.LIST)
    
RETURN
*************************************************
RETURN.ENTRIES:
********************
    CURR.MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic)
    
    LOOP
        REMOVE S.ENTRY.ID FROM RET.STMT.ENTS SETTING STMT.POS
    WHILE S.ENTRY.ID:STMT.POS
        S.COM.MNE = FIELD(S.ENTRY.ID,'/',2)
        S.ENT.ID = FIELD(S.ENTRY.ID,'/',1)
        ST.ID = '(S':S.ENT.ID:'*':S.COM.MNE
        LOCATE ST.ID IN STMT.LIST<1> SETTING POS ELSE
            GOSUB SORT.STMT.LIST
        END
    REPEAT

    LOOP
        REMOVE  C.ENTRY.ID FROM RET.CATEG.ENTS SETTING CATEG.POS
    WHILE C.ENTRY.ID:CATEG.POS
        C.COM.MNE = FIELD(C.ENTRY.ID,'/',2)
        C.ENT.ID = FIELD(C.ENTRY.ID,'/',1)
        ST.ID = ')C':C.ENT.ID :'*':C.COM.MNE
        LOCATE ST.ID IN STMT.LIST<1> SETTING POS ELSE
            GOSUB SORT.STMT.LIST
        END
    REPEAT

RETURN

***************************************************************************
GET.DX.STATEMENTS.FOR.DX.TRADE:

    TXN.LIST = DX.TRANS.KEY
* Looping has been corrected such that system run the the loop for all available transaction id available in TXN.LIST
    LOOP
        REMOVE TXN.ID FROM TXN.LIST SETTING POSN
    WHILE TXN.ID:POSN
        TXN.PREFIX = FIELD(TXN.ID, '.', 1, 2)
        TXN.SEQUENCE = FIELD(TXN.ID, '.', 3)
        IF EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParUpdateEntries> NE '' AND EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParUpdateEntries> NE 'NO' AND TXN.REF.CLC[1,3] NE 'DXC' THEN
            GOSUB GET.ENT.FROM.ECB
        END ELSE
            FOR THIS.SEQUENCE = 1 TO TXN.SEQUENCE
                IF TXN.REF.CLC[1,3] EQ 'DXC' THEN ;* checking for the DXCO record
                    TXN.VAL = FIELD(TXN.ID, '.', 2, 1)
                    TXN.PREFIX =  TXN.REF.CLC:'.':TXN.VAL
                END
                TXN.ID = TXN.PREFIX: '.': THIS.SEQUENCE
                EB.DataAccess.FRead(FILE.NAME, TXN.ID, REC, FILE, ER)
                STMT.FIELD = REC<FIELD.POS>
                GOSUB PROCESS.STMT.LIST ;* Process each STMT.ENTRY
            NEXT THIS.SEQUENCE
        END
    REPEAT


RETURN
*------------------------------------------------------------------------------------------
CHECK.COMPANY:
    
    ST.CompanyCreation.GetCompany(ENTRY.MNE,'',LEAD.COMPANY.CODE,'')
    IF EB.SystemTables.getIdCompany() NE LEAD.COMPANY.CODE THEN
        ST.CompanyCreation.LoadCompany(LEAD.COMPANY.CODE)
    END
    CURR.MNE = ENTRY.MNE
    
RETURN
*------------------------------------------------------------------------------------------
***************************************************************************
SORT.STMT.LIST:
***************

    STMT.ID = FIELD(ST.ID,"*",1)
    STMT.CAT.IND = ST.ID[2,1] ;* First char is prefix. Check second char for id type
    STMT.ID = STMT.ID[3,99] ;* Take remaining values as entry id
    
    ENTRY.MNE = FIELD(ST.ID,"*",2)
    IF ENTRY.MNE NE CURR.MNE THEN       ;*check and load Entry company to avoid read failure
        GOSUB CHECK.COMPANY
    END
      
    ENTRY.REQUIRED = 1
    IF STMT.CAT.IND EQ 'S' THEN
        STMT.ENT.REC = AC.EntryCreation.StmtEntry.Read(STMT.ID, S.ERR)
        IF S.ERR THEN
            STMT.ENT.REC = AC.EntryCreation.StmtEntryDetail.Read(STMT.ID, SED.ERR)
            IF SED.ERR THEN
                STMT.ENT.REC = ''
            END
        END
    END ELSE
        STMT.ENT.REC = AC.EntryCreation.CategEntry.Read(STMT.ID, C.ERR)
        IF C.ERR THEN
            STMT.ENT.REC = AC.EntryCreation.CategEntryDetail.Read(STMT.ID, CED.ERR)
            IF CED.ERR THEN
                STMT.ENT.REC = ''
            END
        END
    END
    
    IF DATE.OPTION AND DATE.FILTER THEN   ;* Date filter for Non Ecb Transaction Ref
        GOSUB FILTER.DATES
    END
    
    IF NOT(ENTRY.REQUIRED) THEN
        RETURN  ;* dont insert the entry in to the list if not required as result of Date filter
    END
    
    GOSUB APPEND.VAL.DATES
        
    IF STMT.LIST THEN
        STMT.LIST := @FM:ST.ID
    END ELSE
        STMT.LIST = ST.ID
    END

RETURN
***************************************************************************
FILTER.DATES:
*****************
    
    IF DATE.OPTION EQ 'VALUE' THEN
        FILTER.DATE =  STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteValueDate>
    END ELSE
        FILTER.DATE = STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteBookingDate>
    END
    
    BEGIN CASE
        
        CASE DATE.OPERAND EQ 'EQ' AND START.DATE AND FILTER.DATE EQ START.DATE
            ENTRY.REQUIRED = 1
        
        CASE DATE.OPERAND EQ 'LT' AND START.DATE AND FILTER.DATE LT START.DATE
            ENTRY.REQUIRED = 1
        
        CASE DATE.OPERAND EQ 'LE' AND START.DATE AND FILTER.DATE LE START.DATE
            ENTRY.REQUIRED = 1
        
        CASE DATE.OPERAND EQ 'GT' AND START.DATE AND FILTER.DATE GT START.DATE
            ENTRY.REQUIRED = 1
        
        CASE DATE.OPERAND EQ 'GE' AND START.DATE AND FILTER.DATE GE START.DATE
            ENTRY.REQUIRED = 1
        
        CASE DATE.OPERAND EQ 'RG' AND START.DATE AND END.DATE AND (FILTER.DATE GE START.DATE AND FILTER.DATE LE END.DATE)
            ENTRY.REQUIRED = 1
        
        CASE DATE.OPERAND AND (START.DATE OR END.DATE)
            ENTRY.REQUIRED = 0
            
    END CASE
    
RETURN
***************************************************************************
APPEND.VAL.DATES:
*****************

    IF STMT.ENT.REC THEN
        IF VAL.DATES THEN
            VAL.DATES<-1> = STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteValueDate>
            BOOK.DATE.TIMES<-1> = STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteDateTime>
        END ELSE
            VAL.DATES = STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteValueDate>
            BOOK.DATE.TIMES = STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteDateTime>
        END
    END

RETURN

***************************************************************************
DO.SWAP:
********

    IF STMT.CNT LE 200 THEN ;* When less number of entries, use the original sort with loop
        GOSUB DO.SWAP.LOOP ;* since this does not have much impact at that time
    END ELSE ;* If more than 200 entries, sort with function from runtime.
        STMT.ENTRY.IDS= SPLICE(BOOK.DATE.TIMES,'$',STMT.LIST) ;* Concat book date time to entry ids first
        STMT.ENTRY.IDS= SPLICE(VAL.DATES,'#',STMT.ENTRY.IDS) ;* Concat value date next.
        STMT.ENTRY.IDS= SORT(STMT.ENTRY.IDS) ;* Sorts in left justified ascending order. On same value date, sort is based on book date time
        STMT.LIST= FIELDS(STMT.ENTRY.IDS,'#',2) ;* Split by both delim to get the entry ids only
        STMT.LIST = FIELDS(STMT.ENTRY.IDS,'$',2)
    END
    STMT.LIST = EREPLACE( EREPLACE(STMT.LIST, "(", ""), ")", "") ;* Remove the prefix used for order before returning list

RETURN

***************************************************************************
DO.SWAP.LOOP:
********

    FOR I = 1 TO STMT.CNT-1
        FOR J = I+1 TO STMT.CNT
            IF VAL.DATES<I> GT VAL.DATES<J> THEN
                TEMP.DATE = VAL.DATES<J>
                VAL.DATES<J> = VAL.DATES<I>
                VAL.DATES<I> = TEMP.DATE

                TEMP.LIST = STMT.LIST<J>
                STMT.LIST<J> = STMT.LIST<I>
                STMT.LIST<I> = TEMP.LIST
            END
        NEXT J
    NEXT I

RETURN
***************************************************************************
AMPF.CHECK:
**********

    R.SAM = ''
    YERR = ''
    R.SEC.ACC.MASTER = SC.ScoPortfolioMaintenance.SecAccMaster.Read(AMPF.APP, YERR)

    IF NOT(YERR) THEN
        AMPF.APP = 'AMPF'
        FILE.NAME$HIS = 'F.AM.PERFORMANCE.FEES$HIS'
        FILE$HIS = ''
        EB.DataAccess.Opf(FILE.NAME$HIS,FILE$HIS)
    END

RETURN
*
V$ERROR:
*
RETURN TO V$ERROR

RETURN
*
***************************************************************************
GET.ND:
********
* For a ND deal, the ECB id's will be DEALID , DEALID.S & DEALID.B
* Hence logic is handling all the entries updated in corresponding ECB's of ND.DEAL
* to be displayed. Where as for FX it will be only DEALID.S & DEALID.B

    CONTRACT.ID = TXN.REF
    GOSUB CALL.EB.GET.CONT.ENTS
    RET.ENTRIES = ENTRY.LIST

    CONTRACT.ID = TXN.REF:'.':'B'
    GOSUB CALL.EB.GET.CONT.ENTS

    IF ENTRY.LIST THEN ;* Append only when value exists to avoid null marker
        RET.ENTRIES<-1> = ENTRY.LIST
    END

    CONTRACT.ID = TXN.REF:'.':'S'
    GOSUB CALL.EB.GET.CONT.ENTS

    IF ENTRY.LIST THEN ;* Append only when value exists to avoid null marker
        RET.ENTRIES<-1> = ENTRY.LIST
    END

RETURN
***************************************************************************
GET.MD:
******
*For MD created in FCY and charges taken in LCY, the ECB ids will be MDID and MDID-LOCAL so fetch the entries from both
    CONTRACT.ID = TXN.REF
    GOSUB CALL.EB.GET.CONT.ENTS
    RET.ENTRIES = ENTRY.LIST
        
    IF REC<MD.Contract.Deal.DeaCurrency> NE REC<MD.Contract.Deal.DeaChargeCurr> THEN;* only if Deal currency is different from Charge Currency ECB with MDID-LOCAL exist so why to fetch for all deals..!
            
        CONTRACT.ID = TXN.REF:'-':'LOCAL';* for Deals for which Contract currency and Charge Currency is different
        GOSUB CALL.EB.GET.CONT.ENTS
        IF ENTRY.LIST THEN ;* Append only when value exists to avoid null marker
            RET.ENTRIES<-1> = ENTRY.LIST
        END
    
    END

RETURN
***************************************************************************
GET.COMM.CCY.ENTS:
*********************
* Commission currencys are subvalued, and can have any number of currencies.
* if currency is of FCY then seperate ECB will be created hence
* loop through and get the list.
        
    LOOP
        REMOVE COMM.ACCT.CCY FROM COMM.ACCT.CCY.LIST SETTING COMM.CCY.POS
    WHILE COMM.ACCT.CCY:COMM.CCY.POS
        IF COMM.ACCT.CCY AND COMM.ACCT.CCY NE TRADE.CCY THEN
            CCY.VALUE = COMM.ACCT.CCY
            GOSUB GET.DX.STATEMENTS.FOR.DX.TRADE
        END
    REPEAT

RETURN
***************************************************************************
CHECK.PRODUCT.INSTALLED:
*********************

    CQInstalled = ''
    ppInstalled = ''
    EB.API.ProductIsInCompany('CQ', CQInstalled)
    EB.API.ProductIsInCompany('PP', ppInstalled)

RETURN
*-----------------------------------------------------------------------------

*** <region name= CALCULATE FULL.HIST.NO>
CALCULATE.FULL.HIST.NO:
*** <desc> </desc>

    IF TXN.HIST GT 10 THEN
        FULL.HIST.NO = TXN.HIST - (INT(TXN.HIST/10) * 10)
    END ELSE
        FULL.HIST.NO = 1
    END

* When TXN.HIST is a number divisible by 10, the FULL.HIST.NO would have been 0. Hence assign it to 1 to display the entry records.
    IF FULL.HIST.NO EQ 0 THEN
        FULL.HIST.NO = 1
    END
RETURN
END
    
    
