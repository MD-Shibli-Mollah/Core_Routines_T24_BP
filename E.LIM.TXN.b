* @ValidationCode : MjoxNjA0NzEyMzM0OmNwMTI1MjoxNTcxMzk4MzA4Mjk0OmNtYW5pdmFubmFuOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTAuMjAxOTA5MjAtMDcwNzoyMDM6MjAz
* @ValidationInfo : Timestamp         : 18 Oct 2019 17:01:48
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : cmanivannan
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 203/203 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-183</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LI.ModelBank
SUBROUTINE E.LIM.TXN
*-------------------------------------------------
*
* This subroutine will be used to convert the
* the field markers to value markers in the Limit
* Txns record
* passed in I_ENQUIRY.COMMON
*
* The fields used are as follows:-
*
* INPUT   ID              Id of the LIMIT record
*                         being processed.
*
*         R.RECORD        LIMIT.TXNS record.
*
*         VC              Pointer to the current
*                         multi-value set being
*                         processed.
*M
*         S               Pointer to the current
*                         sub-value set being
*                         processed.
*
*         O.DATA          .
*
*
* OUTPUT  O.DATA
*
*
** 22/11/95 - GB9401247
**            Add Syndicated loans and commitments to record
*
** 25/07/96 - GB9600430
**            The full amount is now shown in the sixth element
*
** 05/08/97 - GB9700899
*             Include liablilty commitments
*
* 14/03/06 - BG_100010640
*            Select the contract only for the LEAD companies.
*
*
* 14/03/06 - CI_10039694/CI_10039694
*            In the LIAB drill down enquiry LIMIT.TXN system is not displaying the
*            SL Facility transactions.
*
* 23/07/07 - CI_10050470 / REF: HD0711933
*            LIAB drill down enquiry Fatals in OPF
*
* 11/8/08  -CI_10057270
*           Wrong company mnemonic  being referred in LIM.TXN enquiry
*
* 03/11/08 - BG_100020692
*            On running LIAB enquiry through browser for a customer who has no transactions entered,
*            displays 'NO TRANSACTIONS'. In the page displaying 'NO TRANSACTIONS' a link to next level drill down
*            'NDR.ENQ.W.SEE.WDR.REF' is displayed. While clicking on this it leads to the page
*            'APPLICATION MISSING' and also no other link is displayed to get into the previous page.
*            Hence stopped populating R.RECORD with 'NO TRANSACTIONS' only when enquiry is run through browser
*            or desktop.
*
* 30/06/09 - CI_10064142
*            LIAB enquiry display based on the updates on LIMIT.TXNS record
*            changed to display the appropriate mnemonics for book company contracts
*
* 29/10/09 - CI_10067061
*            System fatal out while drilling down LIAB enquiry for a multibook setup.
*
* 02/05/11 - Task 201829
*    Commitment details are not showing for branch company
*
* 14/07/11 - Task 238249 / Defect 237799
*            Enquiry should display balances according to the CREDIT.CHECK field in ACCOUNT.PARAMETER.
*
* 13/08/12 - Task 462596 / Defect 457610
*            On running LIAB enquiry through browser for a customer who has no transactions entered,its not
*            displaying 'NO TRANSACTIONS'.Hence populating R.RECORD with 'NO TRANSACTIONS'
*
* 13/02/13 - Defect 585905 / Task 450894
*            Group Limit bug fixes, Get the Account utilisation from the new file LI.GROUP.ALLOCATION
*            For the customer  having group limits.
*
* 07/08/13 - Defect 745236 / Task 751111
*            On running LIAB enquiry for AA accounts, system displays Maturity date as today date instead of
*            actual Maturity Date from the arrangement
*
* 03/01/14 - Task 753806
*            Variable initialized.
*
* 06/06/14 - Defect 1010829 / Task 1020389
*            On running LIAB enquiry from different company, system displayes the Maturity date as today
*            instead of actual Maturity date from the arrangement. This is because the account company is
*            different from the loaded company. So the account company is loaded and after processing it
*            has been reloaded.
*
* 06/11/14 - Enhancement 608555 / Task 608562
*            AC.BALANCE.TYPE set to exclude credit check process will not utilise the limits
*            so in order to get the account balance attached to limit call the core API
*            GET.WORKING.AVAIL.BALANCE instead of directly taking working balance from account.
*            Also the LIMIT CR ACCOUNT balance is not displayed correctly.
*            Since the variable YACC.AMT is not added with Y.LIMIT.CREDIT enquiry
*            failed to display the credit amount correctly.
*
* 19/03/15 - Defect 1276476 / Task 1287503
*            Enquiry LIM.TXN  fails to show the company mnemonic of commitment drawdown transaction which
*            is in INAU. So, the changes has been done such that if the transaction is not in live, then
*            read the txn record in INAU and process it.
*
* 02/04/15 - Defect 1293160 / Task 1301918
*            DBR is replaced by EB.READ.PARAMETER API to read the SL parameter record
*
* 07/04/15 - Defect 1307845 / Task 1308320
*            Enquiry displays time out error message since OPF done to file variable which is unassigned.
*            Assigned file variable with ACCOUNT file.
*
* 09/07/15 - Defect 1373841 / Task 1402445
*            New routine AC.GET.LOCKED.AMOUNT is called to get the locked amount for that account
*
* 18/08/17 - Defect 2238023 / Task 2239766
*            @SM Marker count set in order to display the contents of first row
*            on the enquiry passed in sub-value position
*
* 21/08/17 - EN 2205157 / Task 2237727
*            use API instead of direct I/O for LIMIT related files
*            LIMIT.TXNS
*
* 16/01/2018 - Enhancement 2321403 / Task 2417547
*              Modified to get locked amount details from ECB
*              Modified to call wrapper routine, AC.CashFlow.GetLockedDetails to get locked information
*
* 13/06/18 - Defect 2597034 / Task 2628208
*            Merge balances for HVT accounts and write it in cache to fetch correct working balances if notional
*            merge has not happened at time enquiry is executed
*
* 07/08/18 - Enhancement 2675478 / Task 2675652
*          - Changes made to pass the 'Locked With Limit' value along with the
*            accountId as part of 'OFS Clearing support for NSF processing'
*
* 26/04/19 - Defect 3087388 / Task 3102572
*            Code changes done to set flag so that locked amount is not returned from AC.GET.LOCKED.DETAILS
*            as the same  is being returned from AC.GET.CREDIT.CHECK.BALANCE in case the
*            new credit check structure is followed.
*
* 27/09/18 - Enhancement- 3326519 / Task- 3326500
*            Use New API to get the commitment amount for the legacy
*            and arrangement accounts, LD, SL contracts.
*--------------------------------------------------------------------------------------

    $USING LI.Config
    $USING AC.AccountOpening
    $USING MM.Contract
    $USING LD.Contract
    $USING ST.CompanyCreation
    $USING SL.Facility
    $USING SL.Config
    $USING EB.SystemTables
    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING AA.Framework
    $USING AA.TermAmount
    $USING AC.BalanceUpdates
    $USING EB.DataAccess
    $USING EB.Display
    $USING LI.GroupLimit
    $USING AC.CashFlow
    $USING TX.Contract
    $USING EB.API
    $USING LI.LimitTransaction
    $USING EB.Reports
    $USING AC.API
    $USING AC.HighVolume

    GOSUB INITIALISE          ;*Initialise the variables.
    GOSUB PROCESS   ;*To do the further process.

RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables. </desc>

* Read CUSTOMER COMPANY.CHECK record.

    APPLN = ""
    R.SS.REC = ""
    R.REC = ""
    LIM.TXN.DETS = ''         ;* The array that contains flag to indicate the calculate commitment for LIM.TXN enquiry,Company mnemonics,Utilamount for the account.
    CO.FIELD.NO = ""
    DIM MACC.REC(AC.AccountOpening.Account.AuditDateTime)
    MAT MACC.REC = ''
    YCOM.MNE = ''
    ERR = ''
    YR.COMPANY.CHECK = ''

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc>To do the further process. </desc>

    YR.COMPANY.CHECK = ST.CompanyCreation.CompanyCheck.Read("CUSTOMER", ERR)

    IF ERR THEN
        YR.COMPANY.CHECK = ""
    END

* Take all companies sharing the limit files
    LOCATE EB.SystemTables.getIdCompany() IN YR.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocCompanyCode,1> SETTING BMV ELSE
        COMPANY.LIST = YR.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocUsingCom>
        FIND EB.SystemTables.getIdCompany() IN COMPANY.LIST SETTING BMF,BMV,BMS ELSE
            EB.SystemTables.setText("COMPANY MISSING FROM F.COMPANY.CHECK ID = CUSTOMER")
            EB.Display.Rem()
        END
    END

    YCOMP.MNEMONICS = YR.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocCompanyMne,BMV>

    IF YR.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocUsingMne,BMV> THEN
        YCOMP.MNEMONICS = YCOMP.MNEMONICS:@VM:YR.COMPANY.CHECK<ST.CompanyCreation.CompanyCheck.EbCocUsingMne,BMV>
    END

* Read the Limit transaction file record into r.record
    LIM.TXN.KEY = EB.Reports.getId()
    ERR = ''
    R.RECORD.VAL = ''
    LI.LimitTransaction.LimitTxnsRead(LIM.TXN.KEY, R.RECORD.VAL, ERR)

    IF R.RECORD.VAL THEN
        EB.Reports.setRRecord(R.RECORD.VAL)
    END ELSE
        EB.Reports.setRRecord("")
    END

    GOSUB MAIN.PROCESS        ;*After all the successful validations, get the amounts.(Utilisation/Commitment)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN.PROCESS>
MAIN.PROCESS:
*** <desc>After all the successful validations, get the amounts.(Utilisation/Commitment) </desc>

    R.RECORD.VAL = EB.Reports.getRRecord()

* Convert fielrecords into multivalue fields within one record.
    CONVERT @FM TO @VM IN R.RECORD.VAL

    EB.Reports.setRRecord(R.RECORD.VAL)
    EB.Reports.setVmCount(COUNT(R.RECORD.VAL,@VM) + 1)

* Though LIMIT.TXNS file is a concat file the Field markers are turned into
* value markers for enquiries therefore this program treats them as VMs
    IF EB.Reports.getRRecord() NE "" THEN

        FOR YREF.POINT = 1 TO EB.Reports.getVmCount()
            LIM.TXN.DETS = @TRUE        ;* The flag to indicate that get the commitment amount for LIM.TXN enquiry.
            YACC.REF = FIELD(EB.Reports.getRRecord()<1,YREF.POINT>, "\",1,1)
            YACC.COM = FIELD(EB.Reports.getRRecord()<1,YREF.POINT>, "\",2,1)
            Y.ORG.COMP = YACC.COM
            YTYPE = YACC.REF[1,2]
* Check to handle multi book processing
            IF EB.SystemTables.getCMultiBook() AND YTYPE NE 'AC' THEN
                GOSUB MULTIBOOK.CHECK
            END

            IF YTYPE = "AC" THEN
                YACC.NO = YACC.REF[3,99]
                AC.AccountOpening.GetAccountCompany(YACC.COM)
                GOSUB LOAD.COMPANY
                YREC = ""
                YERR = ""
                YREC = AC.AccountOpening.Account.Read(YACC.NO, YERR)

                GOSUB CHECK.HVT.PROCESS ;*Check the account is HVT and then proceed.
                GOSUB GET.WORKING.BALANCE
                GOSUB GET.UTILISATION.AMOUNT      ;*Get the Utilisation for the account.
                GOSUB GET.COMMITMENT.AMOUNT       ;*Get the commitment amount for the account.

                IF CACHE.LOADED THEN    ;* Only when ECB is put in cache clear it
                    GOSUB CLEAR.CACHE   ;* Clear R.EB.CONTRACT.BALANCES on exit
                END
* After getting all the account details, the original company is restored.
                IF SAVE.COMPANY NE EB.SystemTables.getIdCompany() THEN
                    ST.CompanyCreation.LoadCompany(SAVE.COMPANY)
                END
            END

            IF YTYPE EQ 'MM' OR YTYPE EQ "AA" THEN
                LIM.TXN.DETS<2> = YREF.POINT
                LI.LimitTransaction.LimitCalcCommitmentInfo(LIM.TXN.KEY, LIM.TXN.DETS, '', '', '', '', '')
            END
        NEXT YREF.POINT

        R.RECORD.VAL = EB.Reports.getRRecord()
        EB.Reports.setVmCount(COUNT(R.RECORD.VAL,@VM) + (R.RECORD.VAL NE ''))
        EB.Reports.setSmCount(COUNT(R.RECORD.VAL<1,1>,@SM) + (R.RECORD.VAL<1,1> NE ''))
    END ELSE
        EB.Reports.setVmCount(0)
    END

* Now check for committments and if any present add to stored array
    LIM.TXN.DETS = @TRUE      ;* Flag to indicate the calculate commitment for LIM.TXN enquiry.
    LIM.TXN.DETS<5> = YCOMP.MNEMONICS   ;* Flag to indicate the calculate commitment for LIM.TXN enquiry.

    LI.LimitTransaction.LimitCalcCommitmentInfo(LIM.TXN.KEY, LIM.TXN.DETS, '', '', '', '', '')

    IF EB.Reports.getRRecord() EQ "" THEN
        tmp=EB.Reports.getRRecord()
        tmp<1,1>='NO TRANSACTIONS'
        EB.Reports.setRRecord(tmp)
        EB.Reports.setVmCount(1)
    END

RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name= GET.WORKING.BALANCE>
GET.WORKING.BALANCE:
*** <desc>Get working avail balances </desc>

* Get the account balance using the core API routine
* Get working avail balance will return the account balance as per the credit check
* setup excluding the balance of AC.BALANCE.TYPE setup to exclude credit check processing
    MAT MACC.REC = ''
* Account record to be passed
    MATPARSE MACC.REC FROM YREC
    ACCOUNT.ID = YACC.NO
    YACC.AMT = 0
    AF.DATE = ''    ;* Get todays balance
    AC.CashFlow.GetWorkingAvailBal(AF.DATE, ACCOUNT.ID, MAT MACC.REC, '', YACC.AMT,'')    ;* Get the account balance

*  If locked amount is attached to that account, then that amount should be considered.
    IF MACC.REC(AC.AccountOpening.Account.LimitRef) AND MACC.REC(AC.AccountOpening.Account.LimitRef) NE 'NOSTRO' THEN
        LOCKED.WITH.LIMIT = ''
        LOCK.AMT = ''
        LOCKED.DETAILS = ''
        RESPONSE.DETAILS = ''
        ACCOUNT.ID<4> = '1'   ;* Set if required to check LOCKED.WITH.LIMIT otherwise null.
        ACCOUNT.ID<5> = '1'   ;* Set if locked amount is not required in case of new component structure.
        AC.CashFlow.GetLockedDetails(ACCOUNT.ID, LOCKED.DETAILS,RESPONSE.DETAILS)
        LOCKED.DATES = LOCKED.DETAILS<1>
        LOCKED.AMOUNT = LOCKED.DETAILS<2>

        IF AF.DATE EQ '' THEN
            AF.DATE = EB.SystemTables.getToday()
        END

        LOCATE AF.DATE IN LOCKED.DATES<1,1> BY 'AR' SETTING LOCK.POS THEN       ;* Check if there is any locked amount on the transaction date
            LOCK.AMT = LOCKED.AMOUNT<1,LOCK.POS>
        END ELSE
            IF LOCK.POS > 1 THEN        ;* If locked amount is not present on that date and if ladder is present
                LOCK.AMT = LOCKED.AMOUNT<1,LOCK.POS-1>      ;* get the locked amount of the previous date
            END
        END
        YACC.AMT = YACC.AMT - LOCK.AMT
    END

RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name= MULTIBOOK.CHECK>
MULTIBOOK.CHECK:
*** <desc>MULTIBOOK.CHECK</desc>

    TX.Contract.GetApplication(YACC.REF,APPLN)
    IF APPLN NE "" THEN
        YCONT.MNE = FIELD(EB.Reports.getRRecord()<1,YREF.POINT>, "\",5,1)
        FN.FILE = "F":YCONT.MNE:".":APPLN
        tmp.F.FILE = ''
        EB.DataAccess.Opf(FN.FILE,tmp.F.FILE)
        EB.SystemTables.setFFile(tmp.F.FILE)
        EB.DataAccess.FRead(FN.FILE,YACC.REF,TXN.REC,tmp.F.FILE,ERR)

* If the record is not found in live, then try to get the INAU if available.
        IF ERR EQ 'RECORD NOT FOUND' THEN
            FN.FILE.NAU = FN.FILE:"$NAU"
            F.FILE.NAU = ''
            EB.DataAccess.Opf(FN.FILE.NAU, F.FILE.NAU)
            EB.DataAccess.FRead(FN.FILE.NAU, YACC.REF, TXN.REC, F.FILE.NAU, ERR)
        END

* If the record exists, then get the company mnemonic from the record.
        IF TXN.REC THEN
            GOSUB MB.PROCESS
        END

        R.REC = EB.Reports.getRRecord()<1,YREF.POINT>
        CONVERT "\" TO @VM IN R.REC
        R.REC<1,5> = YCOM.MNE
        CONVERT @VM TO "\" IN R.REC
        tmp=EB.Reports.getRRecord(); tmp<1,YREF.POINT>=R.REC; EB.Reports.setRRecord(tmp)
    END

RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name= MB.PROCESS>
MB.PROCESS:
*** <desc>MB.PROCESS</desc>

    EB.API.GetStandardSelectionDets(APPLN,R.SS.REC)
    FIELD.NAME = "CO.CODE"

    LOCATE FIELD.NAME IN R.SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN
        CO.FIELD.NO = R.SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,POS>
        COMP.CODE = TXN.REC<CO.FIELD.NO>
        R.COM = ST.CompanyCreation.Company.CacheRead(COMP.CODE, ER)
        IF NOT(ER) THEN
            YCOM.MNE = R.COM<ST.CompanyCreation.Company.EbComMnemonic>
        END
    END

RETURN
***<region>
*-----------------------------------------------------------------------------
*** <region name= LOAD.COMPANY>
LOAD.COMPANY:
*** <desc>LOAD.COMPANY</desc>

* If the account belongs to other company, then that particular company should be loaded to get the
* account details. Therefore if the LIAB enquiry is launched from other company, all the details are
* displayed correctly.

    SAVE.COMPANY = EB.SystemTables.getIdCompany()

    IF EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic) NE YACC.COM THEN
        R.MNE.COMP = ST.CompanyCreation.MnemonicCompany.Read(YACC.COM, YMNE.ERR)
* Get the company code and load the company only if the company code exists
        IF R.MNE.COMP<1> AND (R.MNE.COMP<1> NE EB.SystemTables.getIdCompany()) THEN
            ST.CompanyCreation.LoadCompany(R.MNE.COMP<1>)
        END
    END

RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name= CLEAR.CACHE>
CLEAR.CACHE:
*** <desc>CLEAR.CACHE</desc>

* Cache needs to be cleared on entry and exit of routine for HVT accounts

    ACTION = "ClearCache"
    R.EB.CONTRACT.BALANCES = ''
    RESPONSE = ''   ;* Can be returned as RECORD NOT FOUND, INVALID ID, INVALID ACTION CODE, etc
    AC.API.EbCacheContractBalances('', ACTION, R.EB.CONTRACT.BALANCES, RESPONSE)

RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.HVT.PROCESS>
CHECK.HVT.PROCESS:
*** <desc>Check the account is HVT and then proceed. </desc>

* Get the account balance using core routine
    HVT.PROCESS = ""
    CACHE.LOADED = 0          ;* Flag to indicate if ECB is updated in cache
    AC.HighVolume.CheckHvt(YACC.NO, YREC, "", "", HVT.PROCESS, "", "", ERR)     ;* Read the account record to find if account is set as HVT, if not then continue as before

    IF HVT.PROCESS EQ "YES" THEN
        GOSUB CLEAR.CACHE     ;* Clear R.EB.CONTRACT.BALANCES on entry
        RESPONSE = ''
        AC.HighVolume.HvtMergeECB(YACC.NO, RESPONSE)        ;* Load cache with amounts
        IF RESPONSE EQ 1 THEN
            CACHE.LOADED = 1
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.UTILISATION.AMOUNT>
GET.UTILISATION.AMOUNT:
*** <desc>Get the Utilisation for the account. </desc>

* For the account with debit balances get the actual utilisation from the new file Group allocation.
    IF YACC.AMT < 0 THEN
* For the customers with group setup account balance is shared between many group limits
* so get the exact amount allocated to the passed limit instead of using the whole account balance
        R.ACCOUNT.REC = ''
        GROUP.CUST = ''       ;* Set this flag to return the utilisation of the passed account
        LIMIT.UTILISED = 0
        R.ACCOUNT.REC = YREC
        ACCOUNT.ID = YACC.NO
        ID.VAL = EB.Reports.getId()
        LIMIT.ID = FIELD(ID.VAL,'.',1,3)
* Get the limit allocated amount for the account
        LI.GroupLimit.GetAccountUtilisation(ACCOUNT.ID, R.ACCOUNT.REC, LIMIT.ID, R.LIMIT.REC, GROUP.CUST, LIMIT.UTILISED, '', ERR)
* In case the account does not use the passed limit and the balance is allocated by some other limits
* balance returned value will be 0 so checking the return flag insted of checking return balance
        IF GROUP.CUST = 'YES' THEN      ;* This flag indicates the passed account customer is in sharing group so use the returned value
            YACC.AMT = LIMIT.UTILISED   ;* Take the returned balance
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.COMMITMENT.AMOUNT>
GET.COMMITMENT.AMOUNT:
*** <desc>Get the commitment amount for the account. </desc>

    IF YERR EQ '' THEN
        LIM.TXN.DETS<2> = YREF.POINT
        LIM.TXN.DETS<3> = LOWER(YREC)
        LIM.TXN.DETS<4> = YACC.AMT
        LI.LimitTransaction.LimitCalcCommitmentInfo(LIM.TXN.KEY, LIM.TXN.DETS, '', '', '', '', '')
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

END
