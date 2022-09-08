* @ValidationCode : MjoxNzE1MjAxMzc1OmNwMTI1MjoxNjA2MjA3MjkxMjU4OmprYXJ0aGlrYTo3OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA5LjIwMjAwODI4LTE2MTc6NjQ5OjI5NQ==
* @ValidationInfo : Timestamp         : 24 Nov 2020 14:11:31
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : jkarthika
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 295/649 (45.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>3785</Rating>
*-----------------------------------------------------------------------------
* Version 20 06/06/01  GLOBUS Release No. G12.0.00 29/06/01
* Version 9.1.0A released on 29/09/89
$PACKAGE LI.ModelBank
SUBROUTINE E.LIM.ENQ.REC.BUILD
*
**** =============================================================== ****
**** Formats R.RECORD for Limit enquiry. Record is either read from  ****
**** the LIMIT file or ACCOUNT file.                                 ****
**** Key to be used for reading the files is passed in O.DATA by the ****
**** Enquiry system. The key to account records has 'AC\Customer No  ****
**** Concatenated in front of the account number. More than one a/c  ****
**** nos may be sent in O.DATA. A/c Nos are separated by '.'.        ****
**** Consolidated balances of all a/c nos passed to be set up in     ****
**** R.RECORD.                                                       ****
**** The key to limit records are passed one at a time.              ****
**** =============================================================== ****
*
*************************************************************************
* Modification Log:
* =================
*
* 12/03/93 - GB9300367
*            Allow for deposit and fid limits to be any reference no
*
* 09/05/96 - GB9600597 & GB9600900
*            Show value of securities holdings for the customer
*
* 23/01/98 - GB9800042
*            Check field ALLOW.NETTING when calculating working balance.
*
*
* 01/09/98 - GB9801068
*            SC.CALC.CONSID has two more parameters added to it.
*
* 09/01/03 - EN_10001552
*          - Removed the changes done with regard to LIMIT.REVAL.OS,
*          - cause this is handled by the new routine LIMIT.RATE.REVAL
*          - Also included the LOWEST.LIM.REF as the last parameter
*          - of LIMIT.CURR.CONV.
*
* 28/02/03 - BG_100003410
*          - When UPD.RATE in LIMIT.PARAMETER is set to YES, then
*          - TOTAL.OS needs to display the converted amt. This change
*          - is pertaining to the enchancement done in - EN_10001552.
*
*18/11/03  - CI_10014930
*            For Nostro Account YLIM.REF was getting Non Nummerid Value
*            Assigned because of which LIMIT.CURR.CONV was called with
*            wrong value And resulting in giving the error Non Numeric Data
*
* 03/03/04 - GLOBUS_CI_10017872
*            Fix to avoid LIMIT Enquiry Fataling out due to SMS Restrictions
*
* 21/12/04 - EN_10002382
*            Securities Phase I non stop processing.
*
* 24/10/05 - CI_10036017
*            The selection routine E.LIM.LIAB.SELECTION returns the list of
*            accounts with its lead company mnemonic. So while storing the accounts
*            in the corresponding company list for drill down, check the key account
*            mnemonic with the current company's financial company mnemonic.
*
* 20/03/06 - EN_10002868
*            Bond Pricing Calculation - Fixed
*
* 22/06/07 - BG_100014293
*            While opneing limit account with compnay code, in case of branch
*            company do OPF with financial company mnemonic.
*
* 07/11/08 - CI_10058746
*            In the para PROCESS.LIMIT.ACCOUNTS,
*            When there are no accounts attached to the limit for a customer, then LOCAL7
*            variable will hold null value. While populating R.RECORD<9>, R.RECORD<10> a check
*            is done for the value in LOCAL7. Hence no value is stored in R.RECORD<9> and
*            R.RECORD<10> in this case. So while drilling down, displays the error message.
*
* 27/07/09 - GLOBUS_CI_10064862
*            To calculate the Available Amount based upon the Account Parameter setup
*
* 09/09/09 - CI_10065967
*            Updated display of enquiry output.
*
* 07/10/09 - CI_10066608
*            Updation of TIME.CODE field number in R.RECORD
*            Replaced the old field number 17 to 30 which is the field number of TIME.CODE in LIMIT
*
* 14/05/10 - DEFECT 12313 / TASK 49127
*            Decrement OFS$ENQ.KEYS whenever an account limit is removed or
*            deleted from ENQ.KEYS to display a correct record count in browser display.
*
* 06/09/10 - ENHANCEMENT - 34396 - SAR-2009-12-17-0001
*            Introducing New Price type - COL.YIELD
*
*
* 23/11/10 - T 110525 // D 91269
*            Changes done to call LIMIT.REVAL.OS when accounts are attached to limit
*            even though UPDATE.RATE field in the LIMIT.PARAMETER is set to 'YES'.
*
* 15/02/2011 - DEFECT 36446 / TASK 74363
*              Changes done to show WORKING.BALANCE for ACCOUNT instead of AVAILABLE.BAL
*
* 30/05/2011 - Task 218798
*              Changes done for showing the correct outstanding amount when ALLOW.NETTING is
*              set in ACCOUNT and LIMIT record
*
* 14/07/11 -   Task 238249 / Defect 237799
*              Reverting the changes done through DEFECT 36446 / TASK 74363.
*              Enquiry should display balances according to the CREDIT.CHECK field.
*
* 23/05/11 - Enhancement - 182581 / Task- 191536
*            Moving Balances to ECB from Account Balance Fields.
*
* 01/01/13 - Enhancement - 450817 / Task 486148
*            Changes done to get the account utilisation details from new work file
*            LI.LIMIT.GROUP.ALLOCATION for the account whose customer has group limit setup.
*
* 13/02/13 - Defect 585905 / Task 450894
*            Group Limit Changes, for Liab enquiry
*
* 02/04/13 - Defect 638332 / Task 638389
*            For group limits set the drill down enq as LIM.CUST and pass the LINE.ID as the
*            first three parts of group limit id.
*
* 06/02/2014 - Defect 902096 / Task 907708
*              The working balance of account is set in variable workingBal before checking the balance.
*
* 11/06/14 - Defect 986559 / Task 1024288
*            Changes has been done such that even for the sub group limits, the description is
*            displayed from the LIMIT.SHARING.GROUP
*
* 30/06/14 - Enhancement 930605 / Task 930608
*            Consider TDGL movements while fetching balance for all accounts based on
*            the parameter setup, that is fetched from API GET.CREDIT.CHECK.
*
* 16/07/14 - Defect 986559 / Task 1059394
*            Changes has been done such that the utilisation is shown correctly
*            even for the sub group limits
*
* 06/11/14 - Enhancement 608555 / Task 608562
*            AC.BALANCE.TYPE set to exclude credit check process will not utilise the limits
*            so in order to get the account balance attached to limit call the core API
*            GET.WORKING.AVAIL.BALANCE instead of directly taking working balance from account.
*            Also the LIMIT CR ACCOUNT balance is not displayed correctly.
*            Since the variable YACC.AMT is not added with Y.LIMIT.CREDIT enquiry
*            failed to display the credit amount correctly.
*
* 11/11/14 - Task 1165382
*            Removed the addition of TDGL balance. Since this is done in GET.WORKING.AVAIL.BAL
*            routine.
*
* 09/07/15 - Defect 1373841 / Task 1402445
*            New routine AC.GET.LOCKED.AMOUNT is called to get the locked amount for that account
*
* 30/06/17 - EN_2166984 / TASK_2166987
*            Changes done to support use of different currency market
*            for accounts exposure calculation under the limits.
*
* 07/07/17 - EN_2166984 / TASK_2187168
*            Pass limit currency to limit.reval.os for non-account based limits.
*
* 19/07/2017 - Defect 2202441 / Task 2202451
*              When adjust avail amt field in enquiry selection is set as YES, recompute
*              Available amount field adjusting the outstainding of short bands with long time band
*
* 21/08/17 - EN 2205157 / Task 2237727
*            use API instead of direct I/O for LIMIT related files
*            LIMIT.LINES
*
* 08/11/17 - EN 2322180 / Task 2322183
*            Support for new limit key and customer group id
*
* 04/12/17 - EN_2287989 / Task 2292817
*            Invoke new generic API LIMIT.CALC.INFO to calculate limit amounts.
*
* 19/12/17 - EN_2287989 / TASK_2385761
*            Removing unused variables to avoid compilation warnings.
*
** 16/01/2018 - Enhancement 2321403 / Task 2417547
*              Modified to get locked amount details from ECB
*              Modified to call wrapper routine, AC.CashFlow.GetLockedDetails to get locked information
*
* 13/06/18 - Defect 2597034 / Task 2628208
*            Merge balances for HVT accounts and write it in cache to fetch correct working balances if notional
*            merge has not happened at time enquiry is executed
*
*   07/08/18 - Enhancement 2675478 / Task 2675652
*            - Changes made to pass the 'Locked With Limit' value along with the
*              accountId as part of 'OFS Clearing support for NSF processing'
*
* 26/04/19 - Defect 3087388 / Task 3102572
*            Code changes done to set flag so that locked amount is not returned from AC.GET.LOCKED.DETAILS
*            as the same  is being returned from AC.GET.CREDIT.CHECK.BALANCE in case the
*            new credit check structure is followed.
*
* 14/05/19 - Defect 3124469 / Task 3128117
*            Changes done to pass SER.NO as part of selection criteria to the
*            drill down enquiry LIM.TXN such that only the details of choosen
*            limits are displayed
*
* 29/07/2019 - Enhancement 3253878 / Task 3253880
*              New API should replace the direct read call to retreive the Limit Parameter record.
*              However since limit parameter record wasn't used in this routine, removed the code snippet
*
* 11/09/19 - Enhancement 3297023 / Task 3297026
*            Formatting changes of limit products for numeric and non-numeric keys.
*
* 20/03/2020 - Defect 3615083 / Task 3650981
*              Modified the code to sort the collateral ids instead of arranging in AL order so
*              that LIAB enquiry should display all COLLATERAL records properly
*
* 23/11/2020 - Enhancement 4051489 / Task 4096336
*              Modified the code to display the Property and Mortgage records linked to Collaterals through PROPERTY and MORTGAGE Collateral Type
***********************************************************************************

*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $INSERT I_ENQUIRY.COMMON
*
    $INSERT I_F.LIMIT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.LIMIT.REFERENCE
    $INSERT I_F.COMPANY
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_F.SECURITY.POSITION
    $INSERT I_F.PRICE.TYPE
    $INSERT I_F.COLLATERAL
    $INSERT I_F.LETTER.OF.CREDIT
    $INSERT I_F.DRAWINGS
    $INSERT I_F.LIMIT.PARAMETER         ;* BG_100003410
    $INSERT I_AccountService_WorkingBalance
    $INSERT I_F.LIMIT.SHARING.GROUP
    $INSERT I_AccountService_TradeDatedGLBal

*
**** =============================================================== ****
MAIN.PARA:
*--------
*
**** Open all files..
*
    GOSUB OPEN.REQD.FILES:
*
*** Main process.
*
    DIM MACC.REC(AC.AUDIT.DATE.TIME)
    R.RECORD = ''
    VM.COUNT = 1
    GOSUB PROCESS.PARA:
*
*** Return to enquiry
*
RETURN
*
**** =============================================================== ****
OPEN.REQD.FILES:
*--------------
*
    F.LIMIT = ''
    CALL OPF('F.LIMIT',F.LIMIT)
*
    F.ACCOUNT = ""
    CALL OPF("F.ACCOUNT",F.ACCOUNT)
*
    LOCATE "SC" IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING SC.POS THEN
        F.SECURITY.MASTER = ""
        CALL OPF("F.SECURITY.MASTER", F.SECURITY.MASTER)
    END
*
    LOCATE "CO" IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING CO.POS THEN
        F.COLLATERAL = ""
        CALL OPF("F.COLLATERAL", F.COLLATERAL)
    END
*
    LOCATE "LC" IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING LC.POS THEN
        F.LETTER.OF.CREDIT = ""
        CALL OPF("F.LETTER.OF.CREDIT",F.LETTER.OF.CREDIT)
        F.LETTER.OF.CREDIT$NAU = ""
        CALL OPF("F.LETTER.OF.CREDIT$NAU",F.LETTER.OF.CREDIT)
        F.DRAWINGS = ""
        CALL OPF("F.DRAWINGS",F.DRAWINGS)
        F.DRAWINGS$NAU = ""
        CALL OPF("F.DRAWINGS$NAU",F.DRAWINGS)
    END
*
    ADJ.AVAIL.AMT = ''
    LOCATE "ADJUST.AVAIL.AMT" IN D.FIELDS<1> SETTING ADJ.POS THEN
        ADJ.AVAIL.AMT = D.RANGE.AND.VALUE<ADJ.POS>
    END
*
RETURN
*
**** =============================================================== ****
PROCESS.PARA:
*-----------
*
    YKEY = O.DATA
    BEGIN CASE
        CASE FIELD(YKEY,'\',1) = 'AC'
*
**** String of account numbers passed.
*
            GOSUB PROCESS.ACCOUNTS:
*
        CASE FIELD(YKEY,"\",1) = "SC"
            GOSUB PROCESS.SECURITIES
*
        CASE FIELD(YKEY,"\",1) = "CO"      ;* Check whether the first field of YKEY is 'CO'. If it is 'CO', then para PROCESS.COLLATERAL is processed for External assets
            GOSUB PROCESS.COLLATERAL
*
        CASE FIELD(YKEY,"\",1) = "PROP"    ;* Check whether the first field of YKEY is 'PROP'. If it is 'PROP', then para PROCESS.COLLATERAL is processed for Property assets
            GOSUB PROCESS.COLLATERAL
            
        CASE FIELD(YKEY,"\",1) = "MTG"     ;* Check whether the first field of YKEY is 'MTG'. If it is 'MTG', then para PROCESS.COLLATERAL is processed for Mortgage assets
            GOSUB PROCESS.COLLATERAL
            
        CASE FIELD(YKEY,'\',1) = 'LI'
            GOSUB PROCESS.LIMIT.ACCOUNTS:
*
        CASE FIELD(YKEY,'\',1) = 'LC'
            GOSUB PROCESS.LC
*
        CASE 1
*
**** Limit key identified.
*
            GOSUB PROCESS.LIMITS:
    END CASE
*
RETURN
*
**** =============================================================== ***
PROCESS.LC:
*----------
*
    R.RECORD = ''
    Y.LC.LIMIT = 0
    Y.LC.CUST = FIELD(YKEY,'\',2)
    Y.LC.LIST = FIELD(YKEY,'\',3)
    CONVERT "*" TO @FM IN Y.LC.LIST
    LOOP
        REMOVE LC.NO FROM Y.LC.LIST SETTING MORE
    WHILE MORE:LC.NO
        IF LEN(LC.NO) = 12 THEN         ;! It is a LC record
            LC.READ.ERR = ''
            LC.REC = ''
            CALL F.READ('F.LETTER.OF.CREDIT$NAU',LC.NO,LC.REC,F.LETTER.OF.CREDIT$NAU,LC.READ.ERR)
            IF LC.READ.ERR # '' THEN
                CALL F.READ('F.LETTER.OF.CREDIT',LC.NO,LC.REC,F.LETTER.OF.CREDIT,LC.READ.ERR)
            END
            IF LC.REC # '' THEN
                YCCY.AMNT = LC.REC<TF.LC.LIABILITY.AMT>
                YCONV.CURRENCY = LC.REC<TF.LC.LC.CURRENCY>
                YLIM.REF = LC.REC<TF.LC.LIMIT.REFERENCE>
                GOSUB CONV.AMOUNTS
            END
        END ELSE    ;! It is a DR record
            DR.READ.ERR = ''
            DR.REC = '' ; DR.NO = LC.NO
            CALL F.READ('F.DRAWINGS$NAU',DR.NO,DR.REC,F.DRAWINGS$NAU,DR.READ.ERR)
            IF DR.READ.ERR # '' THEN
                CALL F.READ('F.DRAWINGS',DR.NO,DR.REC,F.DRAWINGS,DR.READ.ERR)
            END
            IF DR.REC # '' THEN
                YCCY.AMNT = DR.REC<TF.DR.DOCUMENT.AMOUNT>
                YCONV.CURRENCY = DR.REC<TF.DR.DRAW.CURRENCY>
                YLIM.REF = DR.REC<TF.DR.LIMIT.REFERENCE>
                GOSUB CONV.AMOUNTS
            END
        END
        Y.LC.LIMIT = Y.LC.LIMIT + YCCY.AMNT
    REPEAT
    YTEXT = 'LC BENEFICIARY'
    CALL TXT(YTEXT)
    R.RECORD<1> = Y.LC.CUST
    R.RECORD<2> = YTEXT
    R.RECORD<4> = LCCY
    R.RECORD<6> = Y.LC.LIMIT/1000
    R.RECORD<9> = 'LC.EXPORT'
    R.RECORD<10> = 'LC.BENEFICIARY EQ ':Y.LC.CUST
RETURN

**** =============================================================== ****
PROCESS.ACCOUNTS:
*---------------
*
**** --------------------------------------------------------------- ****
**** Multi valued field. The first contains "AC" followed by a "\"   ****
**** Each subsequent multi value hold the company mnemonic followed  ****
**** by a "\" then the account numbers under that company separated  ****
**** by a ".".
**** eq. AC\1234vmECO\19.27vmCO2\35                                  ****
**** --------------------------------------------------------------- ****
*
    R.RECORD = ''
    Y.LIMIT.CREDIT = 0
    Y.NON.LIMIT.CREDIT = 0
    Y.NON.LIMIT.DEBIT = 0
    CONVERT "|" TO @VM IN YKEY
    REMOVE YKEY.VALUE FROM YKEY SETTING YKEY.DELIM          ;* Get rid of the liab no
    Y.LIAB.NO = FIELD(YKEY.VALUE,'\',2)
    Y.LIM.AC = '' ; Y.LIM.AC.THIS.CO = ""
    Y.NON.LIM.AC = '' ; Y.NON.LIM.AC.THIS.CO = ""
*
    LOOP
        REMOVE YKEY.VALUE FROM YKEY SETTING YKEY.DELIM
    UNTIL YKEY.VALUE = ""
        Y.ACCT.LIST = FIELD(YKEY.VALUE,"\",2)
*
        CONVERT '.' TO @FM IN Y.ACCT.LIST
        YACCT.MNE = FIELD(YKEY.VALUE,"\",1)
*
        LOOP
            REMOVE Y.ACC.NO FROM Y.ACCT.LIST SETTING YINDEX.1
        WHILE Y.ACC.NO
            ACC.READ.ERR = "" ; YR.ACCOUNT = ""
            CALL F.READ('F.ACCOUNT',Y.ACC.NO, YR.ACCOUNT, F.ACCOUNT, ACC.READ.ERR)
*
* Only add the balances if the LIMIT.REF is not numeric as these have
* already been taken into account
*
* CI_10014930 Commented this line instead YLIM.REF is assigned a value inside
* the IF/ELSE statment
*            YLIM.REF = YR.ACCOUNT<AC.LIMIT.REF>     ;* CI_10014930 S/E
            accountKey = Y.ACC.NO
            CACHE.LOADED = 0        ;* Flag to indicate if ECB is updated in cache
            HVT.PROCESS = ""
            CALL AC.CHECK.HVT(accountKey, YR.ACCOUNT, "", "", HVT.PROCESS, "", "", ERR)  ;* Read the account record to find if account is set as HVT, if not then continue as before
            IF HVT.PROCESS EQ "YES" THEN
                GOSUB CLEAR.CACHE         ;* Clear R.EB.CONTRACT.BALANCES on entry
                RESPONSE = ''
                CALL AC.HVT.MERGE.ECB(accountKey, RESPONSE)  ;* Load cache with amounts
                IF RESPONSE EQ 1 THEN
                    CACHE.LOADED = 1
                END
            END
            GOSUB GET.WORKING.BALANCE
            IF CACHE.LOADED THEN          ;* Only when ECB is put in cache clear it
                GOSUB CLEAR.CACHE         ;* Clear R.EB.CONTRACT.BALANCES on exit
            END
            IF YR.ACCOUNT<AC.LIMIT.REF> EQ 'NOSTRO' OR YR.ACCOUNT<AC.LIMIT.REF> EQ '' THEN
*
                YCCY.AMNT =  workingBal<Balance.workingBal>
                YCONV.CURRENCY = YR.ACCOUNT<AC.CURRENCY>
                YLIM.REF = '' ;* CI_10014930 S/E     Assigned '' b'cos AC.LIMIT.REF holds NOSTRO
                GOSUB CONV.AMOUNTS:

                IF workingBal<Balance.workingBal> GT 0 THEN
                    Y.NON.LIMIT.CREDIT = Y.NON.LIMIT.CREDIT + YCCY.AMNT
                END ELSE
                    Y.NON.LIMIT.DEBIT = Y.NON.LIMIT.DEBIT + YCCY.AMNT
                END
*
* Store accounts in this company separately so that they can be processed
* first by the next enquiry down, otherwise the user will never be able
* to see accounts in another company. This way he will be able tio see the
* accounts of the company he is signed on to.
*
                IF YACCT.MNE = R.COMPANY(EB.COM.FINANCIAL.MNE) THEN   ;* CI_10036017 - S/E
                    YSEARCH.ACC = Y.ACC.NO:"\":YACCT.MNE
                    LOCATE YSEARCH.ACC IN Y.NON.LIM.AC.THIS.CO<1,1,1> BY 'AL' SETTING Y.AC.POS ELSE
                        INS YSEARCH.ACC BEFORE Y.NON.LIM.AC.THIS.CO<1,1,Y.AC.POS>
                    END
                END ELSE
                    YSEARCH.ACC = Y.ACC.NO:"\":YACCT.MNE
                    LOCATE YSEARCH.ACC IN Y.NON.LIM.AC<1,1,1> BY 'AL' SETTING Y.AC.POS ELSE
                        INS YSEARCH.ACC BEFORE Y.NON.LIM.AC<1,1,Y.AC.POS>
                    END
                END
*
            END ELSE
                YLIM.REF = YR.ACCOUNT<AC.LIMIT.REF>         ;* CI_10014930 S/E  Assign AC.LIMIT.REF to YLIM.REF as it holds a valid limit reference id
                IF workingBal<Balance.workingBal> GT 0 THEN
                    YCCY.AMNT = workingBal<Balance.workingBal>
                    YCONV.CURRENCY = YR.ACCOUNT<AC.CURRENCY>
                    GOSUB CONV.AMOUNTS
                    Y.LIMIT.CREDIT = Y.LIMIT.CREDIT + YCCY.AMNT
*
* Store accounts in this company separately so that they can be processed
* first by the next enquiry down, otherwise the user will never be able
* to see accounts in another company. This way he will be able tio see the
* accounts of the company he is signed on to.
*
                    IF YACCT.MNE = R.COMPANY(EB.COM.FINANCIAL.MNE) THEN         ;* CI_10036017 - S/E
                        YSEARCH.ACC = Y.ACC.NO:"\":YACCT.MNE
                        LOCATE YSEARCH.ACC IN Y.LIM.AC.THIS.CO<1,1,1> BY 'AL' SETTING Y.AC.POS ELSE
                            INS YSEARCH.ACC BEFORE Y.LIM.AC.THIS.CO<1,1,Y.AC.POS>
                        END
                    END ELSE
                        YSEARCH.ACC = Y.ACC.NO:"\":YACCT.MNE
                        LOCATE YSEARCH.ACC IN Y.LIM.AC<1,1,1> BY 'AL' SETTING Y.AC.POS ELSE
                            INS YSEARCH.ACC BEFORE Y.LIM.AC<1,1,Y.AC.POS>
                        END
                    END
                END
            END
        REPEAT
*
    REPEAT
*
* If there are accounts for this company insert them before the other
* account list.
*
    IF Y.LIM.AC OR Y.LIM.AC.THIS.CO THEN
        Y.LIM.AC = Y.LIM.AC.THIS.CO:@SM:Y.LIM.AC
    END
    IF Y.NON.LIM.AC OR Y.NON.LIM.AC.THIS.CO THEN
        Y.NON.LIM.AC = Y.NON.LIM.AC.THIS.CO:@SM:Y.NON.LIM.AC
    END
*
    LOCAL7 = ''
    LOCAL7<1> = Y.LIMIT.CREDIT
    LOCAL7<2> = Y.LIM.AC

    CUST.ID = ''
    CUST.ID = FIELD(Y.LIAB.NO,@VM,1)

* Print accounts without limit  if they exist else print limit accounts and remove trigger to
* print accounts with limit  from ENQ.KEYS as they are printed currently.

    IF Y.NON.LIM.AC NE '' THEN
        R.RECORD<1> = Y.LIAB.NO
        YTEXT = 'CURRENT ACCOUNTS'
        CALL TXT(YTEXT)
        R.RECORD<2> = YTEXT
        R.RECORD<3> = ''
        R.RECORD<4> = LCCY
        R.RECORD<5> = ''
        R.RECORD<6> = Y.NON.LIMIT.DEBIT / 1000
        R.RECORD<7> = Y.NON.LIMIT.CREDIT / 1000
        R.RECORD<9> = 'ACCT.BAL.TODAY'
        CONVERT @SM TO ' ' IN Y.NON.LIM.AC
        R.RECORD<10> = 'ACCOUNT.NUMBER EQ ':TRIM(Y.NON.LIM.AC)
    END ELSE
        IF Y.LIM.AC <> '' THEN
            YKEY = "LI\":CUST.ID
            GOSUB PROCESS.LIMIT.ACCOUNTS
            GOSUB UPDATE.ENQ.KEYS
        END
    END
* Remove trigger to display accounts with limit if accounts with limit do not exist.
    IF Y.LIM.AC EQ '' THEN
        GOSUB UPDATE.ENQ.KEYS
    END

RETURN
*
*-------------------------------------------------------------------------------
GET.WORKING.BALANCE:
*-------------------
* Get the account balance as per the credit check setup

    WORKING.BALANCE = 0
    MAT MACC.REC = ''
    MATPARSE MACC.REC FROM YR.ACCOUNT

* AC.BALANCE.TYPE can be setup to exclude from credit checking process
* such balances will not utilise limits, So call core api to return the
* account balance which utilises limit

    AF.DATE = '' ;* Exclude credit check available
    CALL GET.WORKING.AVAIL.BAL(AF.DATE, accountKey, MAT MACC.REC, '', WORKING.BALANCE,'')

*  If locked amount is attached to that account, then that amount should be considered.
    IF MACC.REC(AC.LIMIT.REF) AND MACC.REC(AC.LIMIT.REF) NE 'NOSTRO' THEN

        LOCKED.WITH.LIMIT = ''
        LOCK.AMT = ''
        LOCKED.DETAILS = ''
        RESPONSE.DETAILS = ''
        accountKey<4> = '1' ;* Set if required to check LOCKED.WITH.LIMIT otherwise null.
        accountKey<5> = '1'  ;* Set if locked amount is not required in case of new component structure.
        CALL AC.GET.LOCKED.DETAILS(accountKey, LOCKED.DETAILS,RESPONSE.DETAILS)
        LOCKED.DATES = LOCKED.DETAILS<1>
        LOCKED.AMOUNT = LOCKED.DETAILS<2>
        IF AF.DATE EQ '' THEN
            AF.DATE = TODAY
        END
        LOCATE AF.DATE IN LOCKED.DATES<1,1> BY 'AR' SETTING LOCK.POS THEN   ;* Check if there is any locked amount on the transaction date
            LOCK.AMT = LOCKED.AMOUNT<1,LOCK.POS>
        END ELSE
            IF LOCK.POS > 1 THEN                               ;* If locked amount is not present on that date and if ladder is present
                LOCK.AMT = LOCKED.AMOUNT<1,LOCK.POS-1>        ;* get the locked amount of the previous date
            END
        END
        
        WORKING.BALANCE = WORKING.BALANCE - LOCK.AMT

    END

    workingBal = WORKING.BALANCE

RETURN
*--------------------------------------------------------------------------------
UPDATE.ENQ.KEYS:
*------------------------------------------
*Display of credit accounts is avoided if
*credit accounts do not exist or are already printed.
*
    KEY.ID = ''
    KEY.ID = "LI\":CUST.ID
    LOCATE KEY.ID IN ENQ.KEYS<1> SETTING KEY.POS THEN
        DEL ENQ.KEYS<KEY.POS>
        OFS$ENQ.KEYS -= 1     ;* Decrement a value for browser display of record count
    END

RETURN

*
**** =============================================================== ****
PROCESS.LIMIT.ACCOUNTS:
*---------------------
*
**** =============================================================== ****
**** Exctracts the cumulative balance for the accounts in credit and ****
**** having a link to limits. This amount is calculated in the prev. ****
**** call when the keys are passed with 'AC\' appended in front.     ****
**** The amounts calculated are stored in common variable LOCAL7.    ****
**** LOCAL7 field 1 contains the balance and field 2 contains the    ****
**** a/c nos matching this condition. The a/c nos are stored as sub  ****
**** values.                                                         ****
**** =============================================================== ****
*
    Y.LI.LIAB.NO = FIELD(YKEY,'.',1)
    Y.LIAB.NO = FIELD(Y.LI.LIAB.NO,'\',2)
    R.RECORD = ''
    Y.LIM.AC = LOCAL7<2>
    IF Y.LIM.AC NE '' THEN
        R.RECORD<1> = Y.LIAB.NO
        YTEXT = 'LIMIT CR ACCOUNTS'
        CALL TXT(YTEXT)
        R.RECORD<2> = YTEXT
        R.RECORD<3> = ''
        R.RECORD<4> = LCCY
        R.RECORD<5> = ""
        R.RECORD<6> = ""
        Y.LIMIT.CREDIT = LOCAL7<1>
        R.RECORD<7> = Y.LIMIT.CREDIT / 1000
        R.RECORD<9> = 'ACCT.BAL.TODAY'
        CONVERT @SM TO ' ' IN Y.LIM.AC
        R.RECORD<10> = 'ACCOUNT.NUMBER EQ ':TRIM(Y.LIM.AC)
    END
RETURN
*
*-------------------------------------------------------------------------
PROCESS.SECURITIES:
*==================
** Multi valued filed The first contains SC followed by "\"
** Each subsequent value holds the company menmonic separated by
** a "\" then the security position ids for that company separated by a "*"
** Amounts will be shown as the local equivalent
*
    CREDIT.SC.AMT = "" ; DEBIT.SC.AMT = ""
    CONVERT "|" TO @VM IN YKEY
    REMOVE YKEY.VALUE FROM YKEY SETTING YKEY.DELIM          ;* Get rid of liab no
    LIAB.NO = YKEY.VALUE["\",2,1]       ;* Extract liability
    SC.POSITION.IDS = ""      ;* Store list of security positions
*
    LOOP
        REMOVE YLIST FROM YKEY SETTING YKEY.DELIM
    UNTIL YLIST = ""          ;* List per company
        SC.POS.LIST = YLIST["\",2,1]    ;* Poisition ids
*
        CONVERT "*" TO @FM IN SC.POS.LIST
        YPORT.MNE = YLIST["\",1,1]      ;* Company code
        F.SECURITY.POSITION = ""
        CALL OPF("F.SECURITY.POSITION", F.SECURITY.POSITION)
*
        LOOP
            REMOVE SC.POS.ID FROM SC.POS.LIST SETTING SCD
        WHILE SC.POS.ID:SCD
*
            LOCATE SC.POS.ID IN SC.POSITION.IDS<1,1,1> BY "AL" SETTING YSC.ID.POS ELSE
                INS SC.POS.ID BEFORE SC.POSITION.IDS<1,1,YSC.ID.POS>
            END
***            READ YR.SC.POSITION FROM F.SECURITY.POSITION, SC.POS.ID THEN
            SP.ID = SC.POS.ID
            LOCK.RECORD = 0
            PROCESS.MAIN.SP = 0
            GOSUB READ.SEC.POSITION
            YR.SC.POSITION = SP.RECORD
            IF READ.ERROR EQ '' AND YR.SC.POSITION NE '' THEN
                IF YR.SC.POSITION<SC.SCP.CLOSING.BAL.NO.NOM> THEN     ;* Don't bother for zero position
                    SM.ID = YR.SC.POSITION<SC.SCP.SECURITY.NUMBER>    ;* Key to security master
*
** Work out the pricing technique from SECURITY.MASTER, and the latest
** price
*
                    PRICE = "" ; VALUE.DATE = TODAY ; SC.VALUE = ""
                    READ SM.REC FROM F.SECURITY.MASTER, SM.ID THEN
                        SC.CCY = SM.REC<SC.SCM.SECURITY.CURRENCY>     ;* Price returned in this
                        CALC.METHOD = ""
                        CALL DBR("PRICE.TYPE":@FM:SC.PRT.CALCULATION.METHOD, SM.REC<SC.SCM.PRICE.TYPE>, CALC.METHOD)
                        IF CALC.METHOD MATCHES "DISCOUNT":@VM:"YIELD":@VM:"TYIELD":@VM:"COL.YIELD" THEN
                            PRICE = SM.REC<SC.SCM.DISC.YLD.PERC>      ;* Discounted percentage
                        END ELSE
                            PRICE = SM.REC<SC.SCM.LAST.PRICE>
                        END
* GB9801068 (Starts)
                        CAP.RATE = "" ; CAP.AMT = ""
                        CALL SC.CALC.CONSID(SM.ID, YR.SC.POSITION<SC.SCP.CLOSING.BAL.NO.NOM>, PRICE, VALUE.DATE, SC.VALUE,CAP.RATE,CAP.AMT,FACTOR)
* GB9801068 (Ends)
                        YCCY.AMNT = SC.VALUE ; YCONV.CURRENCY = SC.CCY
                        YLIM.REF = SM.REC<SC.SCM.LIMIT.REF>
                        GOSUB CONV.AMOUNTS
                        IF SC.VALUE GT 0 THEN
                            CREDIT.SC.AMT += YCCY.AMNT
                        END ELSE
                            DEBIT.SC.AMT += YCCY.AMNT
                        END
                    END
                END
            END
*
        REPEAT
*
    REPEAT
*
** Return R.RECORD
*
    R.RECORD = ""
    R.RECORD<1> = LIAB.NO
    YTEXT = "SECURITIES HELD" ; CALL TXT(YTEXT)
    R.RECORD<2> = YTEXT
    R.RECORD<3> = ""
    R.RECORD<4> = LCCY
    R.RECORD<5> = ""
    R.RECORD<6> = (CREDIT.SC.AMT - DEBIT.SC.AMT) / 1000     ;* Net position
    R.RECORD<9> = "SC.PORT.HOLD.SUM"    ;* Next level enquiry
    CONVERT @SM TO "" IN SC.POSITION.IDS
    R.RECORD<10> = "CUSTOMER.NUMBER EQ ":LIAB.NO  ;* Selection for next enquiry
*
    LOCAL7 = ""     ;* No securities limits at present
*
RETURN
*
**** =============================================================== ****
PROCESS.COLLATERAL:
*==================
** Process collateral records and extract the nominal value, convert
** to local currency
*
    COLL.EXT.AMT = ""   ;*To get the External Asset Amount
    COLL.PROP.AMT = ""  ;*To get the Property Asset Amount
    COLL.MTG.AMT = ""   ;*To get the Mortgage Asset Amount
    CONVERT "|" TO @VM IN YKEY
    REMOVE YKEY.VALUE FROM YKEY SETTING YKEY.DELIM          ;* Get rid of liab no
    LIAB.NO = YKEY.VALUE["\",2,1]       ;* Extract liability
    COLLATERAL.IDS = ""
*
    LOOP
        REMOVE YLIST FROM YKEY SETTING YKEY.DELIM
    UNTIL YLIST = ""          ;* List per company
        CO.POS.LIST = YLIST["\",2,1]    ;* Poisition ids
*
        CONVERT "*" TO @FM IN CO.POS.LIST
        YCOLL.MNE = YLIST["\",1,1]      ;* Company code
*
        LOOP
            REMOVE CO.ID FROM CO.POS.LIST SETTING COD
        WHILE CO.ID:COD
*
            sortData = SORT(CO.POS.LIST)   ;* sorting the collateral ids
            LOCATE CO.ID[".",1,2] IN sortData<1,1,1> SETTING COL.POS ELSE
                INS CO.ID[".",1,2] BEFORE COLLATERAL.IDS<1,1,COL.POS>
            END
            READ YR.COLLAT FROM F.COLLATERAL, CO.ID THEN
                COLL.APP = YR.COLLAT<COLL.APPLICATION>  ;*To get the Collateral Application
                BEGIN CASE
                    CASE COLL.APP = "PROPERTY"
                        YCCY.AMNT = YR.COLLAT<COLL.NOMINAL.VALUE> ; YCONV.CURRENCY = YR.COLLAT<COLL.CURRENCY>
                        GOSUB CONV.AMOUNTS
                        COLL.PROP.AMT += YCCY.AMNT
           
                    CASE COLL.APP = "MORTGAGE"
                        YCCY.AMNT = YR.COLLAT<COLL.NOMINAL.VALUE> ; YCONV.CURRENCY = YR.COLLAT<COLL.CURRENCY>
                        GOSUB CONV.AMOUNTS
                        COLL.MTG.AMT += YCCY.AMNT
                
                    CASE 1
                        YCCY.AMNT = YR.COLLAT<COLL.NOMINAL.VALUE> ; YCONV.CURRENCY = YR.COLLAT<COLL.CURRENCY>
                        GOSUB CONV.AMOUNTS
                        COLL.EXT.AMT += YCCY.AMNT
                END CASE
            END
*
        REPEAT
*
    REPEAT
*
** Return R.RECORD

*If Collateral Property amount is present, COLL.AMT is appended with it and application is set as "PROPERTY"
    IF COLL.PROP.AMT THEN
        COLL.AMT<-1> = COLL.PROP.AMT
        APPLN<-1> = "PROPERTY"
    END
*
*If Collateral Mortgage amount is present, COLL.AMT is appended with it and application is set as "MORTGAGE"
    IF COLL.MTG.AMT THEN
        COLL.AMT<-1> = COLL.MTG.AMT
        APPLN<-1> = "MORTGAGE"
    END
*
*If Collateral External amount is present, COLL.AMT is appended with it and application is set as "EXTERNAL"
    IF COLL.EXT.AMT THEN
        COLL.AMT<-1> = COLL.EXT.AMT
        APPLN<-1> = "EXTERNAL"
    END
*
*
    CO.TOT.COUNT = DCOUNT(COLL.AMT,@FM)  ;*Count of amounts are taken
    R.RECORD = ''
    FOR CO.COUNT =1 TO CO.TOT.COUNT
        R.RECORD<1,CO.COUNT> = LIAB.NO
        YTEXT = APPLN<CO.COUNT> :' ':'COLLATERAL' ; CALL TXT(YTEXT)
        R.RECORD<2,CO.COUNT> = YTEXT
        R.RECORD<3,CO.COUNT> = ""
        R.RECORD<4,CO.COUNT> = LCCY
        R.RECORD<5,CO.COUNT> = ""
        R.RECORD<6,CO.COUNT> = COLL.AMT<CO.COUNT> / 1000       ;* Long position
        R.RECORD<9,CO.COUNT> = "CO.100"    ;* Next level enquiry
        CONVERT @SM TO " " IN COLLATERAL.IDS
        R.RECORD<10,CO.COUNT> = "COLLATERAL.RIGHT EQ ":COLLATERAL.IDS    ;* Selection for next enquiry
*
        LOCAL7 = ""     ;* No securities limits at present
    NEXT CO.COUNT
RETURN
*
**************************************************************************
PROCESS.LIMITS:
*-------------
*
**** Build R.RECORD from Limit files.
*
    FN.LIMIT.SHARING.GROUP = "F.LIMIT.SHARING.GROUP"
    F.LIMIT.SHARING.GROUP = ''
    R.RECORD = ''
    Y.LIMIT.ID = YKEY
    READ Y.LIMIT FROM F.LIMIT, Y.LIMIT.ID ELSE
        Y.LIMIT = ''
    END
*

    LOCATE "LIABILITY.NUMBER" IN D.FIELDS<1> SETTING LIAB.POS ELSE
        LIAB.POS = ''
    END

    LIMIT.TXN.REF = ''
    IF Y.LIMIT.ID[1,2] EQ 'LI' THEN
        LIMIT.TXN.REF = Y.LIMIT.ID
    END
    
    LIMIT.ID.COMPONENTS = ''
    LIMIT.ID.COMPOSED = ''
    CALL LI.LIMIT.ID.PROCESS(Y.LIMIT.ID, LIMIT.ID.COMPONENTS, LIMIT.ID.COMPOSED, '', '')
    IF Y.LIMIT.ID[1,2] EQ 'LI' THEN
        R.RECORD<1> = D.RANGE.AND.VALUE<LIAB.POS,1,1>
        Y.LIMIT.REF = LIMIT.ID.COMPONENTS<2>
    END ELSE
        R.RECORD<1> = FIELD(YKEY,'.',1)
*
**** LIMIT.FIND.REF
*
        Y.LIMIT.REF = FIELD(YKEY,'.',2)
    END
    IF NUM(Y.LIMIT.REF) THEN
        Y.LIMIT.REF = Y.LIMIT.REF * 1
        IF LEN(Y.LIMIT.REF) > 4 THEN
            YLEN = LEN(Y.LIMIT.REF)
            IF Y.LIMIT.REF[YLEN-3,4] NE "0000" THEN
                Y.LIMIT.REF = Y.LIMIT.REF[YLEN-3,4]
                Y.LIMIT.REF = Y.LIMIT.REF * 1
            END
        END
    END
* For group limits get the description from LIMIT.SHARNG.GROUP

    IF FIELD(YKEY,'.',1)[1,1] = 'M' OR FIELD(YKEY,'.',1)[1,1] = 'S'THEN ;* For the group limits get the description from Limit sharing group
        GROUP.ID = FIELD(YKEY,'.',1)
        R.LIMIT.SHARING.GROUP = ''
        CALL F.READ(FN.LIMIT.SHARING.GROUP, GROUP.ID, R.LIMIT.SHARING.GROUP, F.LIMIT.SHARING.GROUP, ERR)
        Y.REF.DESC = R.LIMIT.SHARING.GROUP<LI.SG.SHORT.DESC>
    END ELSE
        YCHK.FILE = ''
        YCHK.FILE<1> = 'LIMIT.REFERENCE'
        YCHK.FILE<2> = LI.REF.SHORT.NAME
        YCHK.FILE<3> = 'L'
        Y.REF.DESC = ''
        CALL DBR(YCHK.FILE,Y.LIMIT.REF,Y.REF.DESC)
    END

    R.RECORD<2> = Y.REF.DESC
    IF YKEY[1,2] EQ 'LI' THEN
        R.RECORD<3> = Y.LIMIT<LI.SERIAL.NUMBER>
    END ELSE
        R.RECORD<3> = FIELD(YKEY,'.',3,1)
    END
    R.RECORD<4> = Y.LIMIT<LI.LIMIT.CURRENCY>
*
    Y.CALC.LIMIT = ''
    YCOUNT.AMTS = ''
    ADDL.INFO<1> = ADJ.AVAIL.AMT
    CACHE.LOADED = ''        ;* Flag to indicate if ECB is updated in cache
    GOSUB CLEAR.CACHE        ;* Clear R.EB.CONTRACT.BALANCES on entry
    IF Y.LIMIT<LI.ACCOUNT> THEN
        GOSUB CHECK.HVT
    END
    LI.ModelBank.limitCalcInfo(Y.LIMIT.ID, Y.LIMIT, ADDL.INFO, YCOUNT.AMTS, Y.CALC.LIMIT, '', '', '')
    IF Y.LIMIT<LI.ACCOUNT> AND CACHE.LOADED THEN
        GOSUB CLEAR.CACHE    ;* Clear R.EB.CONTRACT.BALANCES on exit
    END
    
    FOR Y.VC = 1 TO YCOUNT.AMTS
        IF NUM(Y.CALC.LIMIT<1, Y.VC>) = 1 AND Y.CALC.LIMIT<1, Y.VC> <> "" THEN
            IF Y.CALC.LIMIT<1, Y.VC> >= 500 THEN
                Y.CALC.LIMIT<1, Y.VC> = Y.CALC.LIMIT<1, Y.VC>/1000
            END ELSE
                Y.CALC.LIMIT<1, Y.VC> = 0
            END
        END
        R.RECORD<5,Y.VC> = Y.CALC.LIMIT<1, Y.VC>
        R.RECORD<6,Y.VC> = Y.CALC.LIMIT<2, Y.VC> / 1000
        R.RECORD<7,Y.VC> = Y.CALC.LIMIT<3, Y.VC> / 1000
        R.RECORD<18,Y.VC> = Y.CALC.LIMIT<4, Y.VC> / 1000
        R.RECORD<19,Y.VC> = Y.CALC.LIMIT<5, Y.VC> / 1000
    NEXT Y.VC

**** Reformat the date.
*
    Y.EXP.DT = Y.LIMIT<LI.EXPIRY.DATE>
    R.RECORD<8> = Y.EXP.DT
    R.RECORD<30> = Y.LIMIT<LI.TIME.CODE>
    R.RECORD<31> = Y.LIMIT<LI.CUSTOMER.NUMBER>
    R.RECORD<32> = Y.LIMIT<LI.JOINT.LIABILITY>
****
**** Linking to Next enquiry.
****

    VM.COUNT = YCOUNT.AMTS
    CUST.CNT = DCOUNT(Y.LIMIT<LI.CUSTOMER.NUMBER>,@VM)
    IF CUST.CNT GT YCOUNT.AMTS THEN
        VM.COUNT = CUST.CNT
    END
    GOSUB SET.NEXT.ENQ:
RETURN
*
**** =============================================================== ****
SET.NEXT.ENQ:
*-----------
*
****  Decide which is to be the next enquiry depending on the limit
****  record id.
*

* For group limits Next drill down enquiry will be LIM.CUST
* Pass the line id as the first three parts of limit id for group limits
* LINE.ID is set as C type in SS and hence it needs to be the if of limit lines file

    CUSTOMER.ID = ''
    IF LIMIT.ID.COMPONENTS<1>[1,1] = 'M' THEN
        R.RECORD<9> = 'LIM.CUST'
        R.RECORD<10> = 'LINE.ID EQ ':FIELD(LIMIT.ID.COMPOSED,'.',1,3) ;* Pass Group limit id as in LIMIT.LINES
* When the enquiry is run for LIMIT SHARING GROUP ID Customer part will be null
* on that case we have to display all the limits of the customer hence set CUST.NO as ALL
        IF FIELD(Y.LIMIT.ID,'.',4,1) THEN ;*
            CUSTOMER.ID = LIMIT.ID.COMPONENTS<4>
        END ELSE
            CUSTOMER.ID = 'ALL'
        END

        R.RECORD<11> = "CUST.NO EQ ":CUSTOMER.ID

        RETURN
    END

    YLIM.REF = LIMIT.ID.COMPONENTS<2>
    LL.ERR = ''
    CALL LI.LIMIT.LINES.READ(Y.LIMIT.ID, Y.LIMIT.LINES, LL.ERR)
    IF Y.LIMIT.LINES THEN
        Y.FLAG.OVER = ''
        Y.CUST.PRESENT = ''
        LOOP
            REMOVE Y.LIM.FIELD FROM Y.LIMIT.LINES SETTING Y.LIM.LINE.INDEX
        UNTIL Y.LIM.FIELD = '' OR Y.FLAG.OVER = 1
            LIMIT.ID.COMPONENTS1 = ''
            LIMIT.ID.COMPOSED1 = ''
            CALL LI.LIMIT.ID.PROCESS(Y.LIM.FIELD, LIMIT.ID.COMPONENTS1, LIMIT.ID.COMPOSED1, '', '')
            IF LIMIT.ID.COMPONENTS1<2> <> YLIM.REF THEN
                Y.FLAG.OVER = 1
                Y.NEXT.ENQ = 'LIM.TRADE'
            END ELSE
                IF LIMIT.ID.COMPONENTS1<4> NE '' THEN
                    Y.CUST.PRESENT = 1
                END
            END
        REPEAT
        IF Y.FLAG.OVER THEN
            NULL
        END ELSE
            IF Y.CUST.PRESENT THEN
                Y.NEXT.ENQ = 'LIM.CUST'
            END ELSE
                IF Y.LIMIT<LI.FX.OR.TIME.BAND> = 'FX' THEN
                    Y.NEXT.ENQ = 'LIM.FX1'
                END ELSE
                    Y.NEXT.ENQ = 'LIM.TXN'
                END
            END
        END
        R.RECORD<9> = Y.NEXT.ENQ
        BEGIN CASE
            CASE Y.NEXT.ENQ = 'LIM.TRADE'
                R.RECORD<10> = 'LINE.ID EQ ':Y.LIMIT.ID
                IF LIMIT.TXN.REF EQ '' THEN
                    R.RECORD<11> = "CUST.NO EQ ''"
                END
                IF ADJ.AVAIL.AMT[1,1] = "Y" THEN
                    R.RECORD<12> = "ADJUST.AVAIL.AMT EQ ":ADJ.AVAIL.AMT
                END
            CASE Y.NEXT.ENQ = 'LIM.CUST'
                R.RECORD<10> = 'LINE.ID EQ ':Y.LIMIT.ID
                R.RECORD<11> = "CUST.NO EQ ALL"
                R.RECORD<12> = "ADJUST.AVAIL.AMT EQ ":ADJ.AVAIL.AMT
                
            CASE Y.NEXT.ENQ = 'LIM.TXN'
                GOSUB UPDATE.LIM.TXN.SELECTION ;* To form and update the selection criteria for LIM.TXN enquiry
                
            CASE OTHERWISE
                R.RECORD<10> = 'LIAB.NO EQ ':D.RANGE.AND.VALUE<LIAB.POS,1,1>
                R.RECORD<11> = 'REF.NO EQ ':LIMIT.ID.COMPONENTS<2>
                IF ADJ.AVAIL.AMT[1,1] = "Y" THEN
                    R.RECORD<12> = "ADJUST.AVAIL.AMT EQ ":ADJ.AVAIL.AMT
                END
        END CASE
    END



RETURN
**** =============================================================== ****
CONV.AMOUNTS:
*===========
*
    IF YCONV.CURRENCY NE LCCY THEN
        YLOCAL.CONV.AMT = ""
* EN_10001552s
* Forming the LOWEST.LIM.REF to pass as the last parameter for
* LIMIT.CURR.CONV.
        YLIM.REF = FIELD(YLIM.REF,'.',1)
        IF LEN(YLIM.REF) EQ 5 AND NUM(YLIM.REF) THEN
            LIM.REF = YLIM.REF[4]
        END ELSE
            LIM.REF = YLIM.REF
        END
*
* Use LIMIT.CURR.CONV to calculate the local equivalent
*
        CALL LIMIT.CURR.CONV(YCONV.CURRENCY,YCCY.AMNT,LCCY,YLOCAL.CONV.AMT,LIM.REF)       ;* EN_10001552e
        YCCY.AMNT = YLOCAL.CONV.AMT
        ETEXT = ""
    END
RETURN
*
**** =============================================================== ****
********************
READ.SEC.POSITION:
********************

    REV1 = ''
    REV2 = ''
    REV3 = ''
    REV4 = ''
    READ.ERROR = ''
    SP.RECORD = ''
    SP.RECORD.ORG = ''

    CALL SC.READ.POSITION(SP.ID,LOCK.RECORD,PROCESS.MAIN.SP,REV1,REV2,SP.RECORD,SP.RECORD.ORG,READ.ERROR,REV3,REV4)

RETURN

**** =============================================================== ****

FATAL.ERROR:
    YSOURCE.ROUTINE = "E.LIM.ENQ.REC.BUILD"
    CALL FATAL.ERROR(YSOURCE.ROUTINE)
RETURN

**** =============================================================== ****
CHECK.HVT:
*=========
*
    YNO.OF.ACCOUNTS = DCOUNT(Y.LIMIT<LI.ACCOUNT>,@VM)
    FOR YAV = 1 TO YNO.OF.ACCOUNTS
        YCOMP.MNE = Y.LIMIT<LI.ACC.COMPANY, YAV>
        YKEY = Y.LIMIT<LI.ACCOUNT, YAV>
        GOSUB GET.ACCOUNT.RECORD ;* Read the account record
        IF NOT(READ.ERR) THEN
            HVT.PROCESS = ""
            CALL AC.CHECK.HVT(YKEY, ACC.REC, "", "", HVT.PROCESS, "", "", ERR)  ;* Read the account record to find if account is set as HVT, if not then continue as before
            IF HVT.PROCESS EQ "YES" THEN
                RESPONSE = ''
                CALL AC.HVT.MERGE.ECB(YKEY, RESPONSE)  ;* load cache with amounts
                IF RESPONSE EQ 1 THEN
                    CACHE.LOADED = 1
                END
            END
        END
    NEXT YAV
*
RETURN

**** =============================================================== ****
GET.ACCOUNT.RECORD:
*=================
*
    ACC.REC = ""
    READ.ERR = ""
    CALL GET.ACCOUNT.COMPANY(YCOMP.MNE) ;* Get the lead company mnemonic of the account company to open the file
    YF.ACCOUNT = "F":YCOMP.MNE:".ACCOUNT" ;* Open the file when the company changes
    IF YF.ACCOUNT <> YPREV.FILE THEN
        YPREV.FILE = YF.ACCOUNT
        F.ACCOUNT = ""
        CALL OPF (YF.ACCOUNT, F.ACCOUNT)
    END

    CALL F.READ(YF.ACCOUNT, YKEY, ACC.REC, F.ACCOUNT, READ.ERR) ;* Read account record
*
RETURN

**** =============================================================== ****
CLEAR.CACHE:
*=========
*
    ACTION = "ClearCache"
    R.EB.CONTRACT.BALANCES = ''
    RESPONSE = ''   ;* Can be returned as RECORD NOT FOUND, INVALID ID, INVALID ACTION CODE, etc
    CALL EB.CACHE.CONTRACT.BALANCES('', ACTION, R.EB.CONTRACT.BALANCES, RESPONSE)
*
RETURN

*-----------------------------------------------------------------------------

*** <region name= UPDATE.LIM.TXN.SELECTION>
UPDATE.LIM.TXN.SELECTION:
*** <desc> To form and update the selection criteria for LIM.TXN enquiry </desc>

* in case of new limit
    IF Y.LIMIT.ID[1,2] = "LI" THEN
        R.RECORD<10> = 'LIAB.NO EQ ':Y.LIMIT.ID
        RETURN
    END
            
* for old limit structure
    R.RECORD<10> = 'LIAB.NO EQ ':D.RANGE.AND.VALUE<LIAB.POS,1,1>
    R.RECORD<11> = 'REF.NO EQ ':LIMIT.ID.COMPONENTS<2>
    R.RECORD<12> = 'SER.NO EQ ':LIMIT.ID.COMPONENTS<3>
    
RETURN
*** </region>

END
