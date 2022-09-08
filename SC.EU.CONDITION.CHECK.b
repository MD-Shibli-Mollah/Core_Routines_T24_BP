* @ValidationCode : Mjo2NjE5NjExMTU6Q3AxMjUyOjE2MDgzMDQ0NDA2NzQ6bmJhbGFjaGFuZHJhbjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTEuMjAyMDEwMjktMTc1NDotMTotMQ==
* @ValidationInfo : Timestamp         : 18 Dec 2020 20:44:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nbalachandran
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>1035</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SC.EU.CONDITION.CHECK(IN.DATA,OUT.DATA)
********************************************************
*
* This routine is attached in the TX.CONDITION to check if the
* customer, Security and the Tax are EU effective before writing
* in to the TAX Engine.
*
* INCOMING PARAMETER:
* IN.DATA - Which is the Portfolio number
*
* RETURN PARAMETER:
* OUT.DATA - Which holds either 1 or 0.
* If 1 is returned, then it is Tax liable else not taxable.

* 24/12/04 - EN_10002396
*            New Program
*
* 08/02/05 - GLOBUS_BG_100008046
*            Initial Data Build dev
*
* 17/02/05 - GLOBUS_BG_100008103
*            Bug fixes for EU Directives
*
* 01/03/05 - GLOBUS_BG_100008103
*            Included the RUNNING.UNDER.BATCH
*
* 04/03/05 - GLOBUS_BG_100008256
*            Bug fixes for EU Directives
*
* 15/03/05 - GLOBUS_BG_100008256
*            Bug fixes for EU directives
*
* 30/03/05 - GLOBUS_BG_100008413
*            EUSD Changes
*
* 22/04/05 - GLOBUS_BG_100008636
*            EUSD Bug fixes
*
* 04/05/05 - GLOBUS_CI_10029884
*            HD0505031 ; COB crashes for CASH ENT
*
* 10/05/05 - GLOBUS_BG_100008730
*            INFO.CUSTOMER List changed
*
* 14/05/05 - GLOBUS_CI_10030223
*            Problem with conversion events
*
* 20/05/05 - GLOBUS_CI_10030263
*            ACTUAL.LIABLE check to be done only for ONLINE trades
*
* 02/06/05 - GLOBUS_BG_100008796
*            For redemption, only one update should happen to EAD
*
* 06/06/05 - GLOBUS_CI_10030853
*            RNAU moved to CUR during batch - ETL and EAD not re-updated
*
* 09/06/05 - GLOBUS_CI_10030773
*            CASH Ent given in TXN.TAX.CODE should only be taxable
*
* 13/06/05 - GLOBUS_CI_10031074
*            REV or DEL of info customers must happen Online
*
* 16/06/05 - GLOBUS_CI_10031200
*            REV,DEL not updating the EU.TXN.BASE
*
* 24/06/05 - GLOBUS_CI_10031586
*            Rework should not happen On-line for Info customers
*
* 30/06/05 - GLOBUS_CI_10031802
*            Control INT.MOVEMENT.PARAM with SEC.TRADE
*
* 06/09/05 - GLOBUS_CI_10034309
*            Variable undefined error message
*
* 13/10/05 - GLOBUS_CI_10035585
*            POSITION.TRANSFER  not get updated in EU.TAX.LINK during INTIAL.DATA.BUILD
*
* 19/10/05 - GLOBUS_BG_100009569
*            Unable to authorise the reversal of a DIARY
*
* 15/11/05 - GLOBUS_CI_10036451
*            SC.EU.INFO.CUSTOMER.WORK deletion during DIARY REVERSAL
*
* 21/11/05 - GLOBUS_CI_10036613
*            GET.LOC.REF changed to SC.GET.LOC.REF
*
* 26/12/05 - GLOBUS_CI_10037643
*            ETL updated for TRADE in IHLD status for INFO customer after EOD
*
* 22/06/06 - GLOBUS_CI_10042115
*            After the WHILE.COB para, the error variable is not being checked
*
* 09/10/06 - GLOBUS_CI_10044687
*            Variable undefined error.
*
* 04/12/06 - GLOBUS_CI_10045871
*            Variable undefined error.
*
* 15/03/07 - BG_100013327
*            Securities Das Routines
*
* 30/12/08 - BG_100016871 cgraf@temenos.com
*            Replace CACHE.READ with F.READ
*
* 20/07/10 - 68871: Amend SC routines to use the Customer Service API's
*
* 04/07/13 - Defect_709889 Task_720309
*            Service based trades doesn�t update EU tax related files. As a result,
*            Stock split event couldn�t allocate nominals and results in fatal error
*
* 22/11/13 - Defect 842527 / Task 843282
*            EU Tax didn't calculated when primary customer is in exempted group,
*            where as joint customer is liable to tax.
*
* 14/07/15 - Enhancement:1237565 Task:1377024
*            ABN - Calculation of Tax for fixed income instruments
* 25-04-16 - 1708407
*            Incorporation of Components
*
* 20/06/19  - Defect-3182876 Task-3189588
*             System throws the warning message Invalid or uninitialised variable while inputting SEC.TRADE transaction.
*
* 25/02/20  - Defect-3602723 Task-3608695
*             System throws the warning message Invalid or uninitialised variable while inputting SECURITY.TRANSFER transaction.
*
* 03/02/2020 - Enhancement 3568228 / Task 3568038
*            Changing reference of routines that have been moved from ST to CG
*
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*
* 10/11/20 - SI-3858153 / ENH-4034105 / TASK-4034130
*            ENC2 Client BIL-Tax setup at SAT/AT level-Auth processing
*
* 20/06/19  - Defect-4116032 Task-4139227
*             Total nominal of EU.TAX.LINK is not correctly matched with Security Position record.
*
************************************************************
    $INSERT I_DAS.TAX.TYPE ; * BG_100013327 S
    $INSERT I_CustomerService_DataField


    $USING SC.SctTrading
    $USING SC.ScoSecurityPositionUpdate
    $USING SC.SctOffMarketTrades
    $USING SC.ScoSecurityMasterMaintenance
    $USING CG.ChargeConfig
    $USING SC.SctTaxes
    $USING ET.Contract
    $USING SC.SctPositionTransfer
    $USING EB.Utility
    $USING SC.SccEventCapture
    $USING SC.SccEntitlements
    $USING SC.SctServiceBasedOrders
    $USING SC.ScoPortfolioMaintenance
    $USING EB.DataAccess
    $USING SC.ScoFoundation
    $USING EB.SystemTables
    $USING EB.Delivery

* Check if ET is installed
    ET.INSTALLED = ''
    EB.Delivery.ValProduct("ET","","",ET.INSTALLED,"")
    
* Do not process
* a) When it is triggered on authorisation of the contract,
*    as the database EU.TXN.BASE gets updated on unauth stage itself
* b) When ET module is not installed
    IF EB.SystemTables.getMessage() EQ 'AUT' OR NOT(ET.INSTALLED) THEN
        OUT.DATA = 0
        RETURN
    END
    
* if param file in tax.type is SC.LOCAL.TAX.PARAM, then
* do not need to check for liability. Set the variable OUT.DATA and return

    IF ET.Contract.getLocalTaxCode() THEN
        OUT.DATA = 1
        RETURN
    END

    GOSUB INITIALISE
    GOSUB PROCESS

    IF LIABLE = 1 THEN
        tmp.RUNNING.UNDER.BATCH = EB.SystemTables.getRunningUnderBatch()
        IF NOT(tmp.RUNNING.UNDER.BATCH) THEN          ;* CI_10030263 - S Should be checked only for online transcations
            GOSUB ACTUAL.LIABLE
        END         ;* CI_10030263 - E
        OUT.DATA = LIABLE
    END
* This code is added for diary application where its application name is Entitlement
    IF SAVE.APPLICATION NE EB.SystemTables.getApplication() THEN       ;* BG_100009569 S
        EB.SystemTables.setApplication(SAVE.APPLICATION)
    END   ;* BG_100009569 E

RETURN

***********
INITIALISE:
***********

    YID = '' ; YREC = '' ; APPL.ERR = ''
    SM.EFF.DATE = '' ; POSN = ''
    TRANS.TYPE.CODE = '' ; CU.TAX.CODE = '' ; TXN.TAX.TYPE = ''
    LIABLE = 0 ; APPL.POS = '' ; PORT.NO = '' ; LIST.ID = ''
    ENTL.REC = '' ; YRET = ''
    SAVE.APPLICATION = ''     ;* BG_100009569
    SAVE.APPLICATION = EB.SystemTables.getApplication()      ;* BG_100009569
    CU.EFF.DATE = '' ; SM.EFF.DATE = '' ; TXN.ID = '' ; DIM APPL.REC(500)
    REC.STATUS = ''


    TT.REC = '' ; TAX.EFFECTIVE.DATE = '' ; * BG_100013327 S
    SEL.ARR = dasTaxTypeLocalTaxParamLikeStarting
    THE.ARGS = "EU.TAX.PARAM"
    EB.DataAccess.Das('TAX.TYPE',SEL.ARR,THE.ARGS,'') ; * BG_100013327 E

    IF SEL.ARR<1> THEN
        TT.ERR = ''
        TT.REC = CG.ChargeConfig.TaxType.CacheRead(SEL.ARR<1>, TT.ERR)
* Before incorporation : CALL CACHE.READ('F.TAX.TYPE',SEL.ARR<1>,TT.REC,TT.ERR)
        IF NOT(TT.ERR) AND TT.REC<CG.ChargeConfig.TaxType.TaxTtyEffectiveDate> THEN
            TAX.EFFECTIVE.DATE = TT.REC<CG.ChargeConfig.TaxType.TaxTtyEffectiveDate>
        END
    END
RETURN

********
PROCESS:
********
    YREC = ''
    TRANS.ID = IN.DATA<2>
    TXN.ID = FIELD(TRANS.ID,'.',1)
    IF TRANS.ID[1,6] = "DIARSC" THEN ; * BG_100016871 S
        GOSUB READ.DIARY ; *Read DIARY record
    END ; * BG_100016871 E
    IF COUNT(TRANS.ID,".") EQ 1 THEN
        GOSUB PROCESS.FROM.SECURITY.TRANSFER
    END ELSE
        GOSUB PROCESS.FROM.ENTITLEMENT
    END
    IF LIABLE = 1 AND YRET = 'CREDIT' THEN
        GOSUB CHECK.CUSTOMER.LIAB
        tmp.RUNNING.UNDER.BATCH = EB.SystemTables.getRunningUnderBatch()
        IF NOT(tmp.RUNNING.UNDER.BATCH) AND LIABLE = 1 THEN     ;* Needs to be checked
            GOSUB ACTUAL.LIABLE
        END
        IF LIABLE = 1 THEN
            GOSUB DETERMINE.CUSTOMER.GROUP
        END
    END

    OUT.DATA = LIABLE
RETURN

*** <region name= PROCESS.FROM.SECURITY.TRANSFER>
PROCESS.FROM.SECURITY.TRANSFER:
*** <desc> </desc>

    YREC = SC.ScoSecurityPositionUpdate.SecurityTrans.Read(TRANS.ID, TRANS.ERR)
* Before incorporation : CALL F.READ(FN.SECURITY.TRANS,TRANS.ID,YREC,F.SECURITY.TRANS,TRANS.ERR)
    CUST.ID = FIELD(YREC<SC.ScoSecurityPositionUpdate.SecurityTrans.SctSecurityAccount>,'-',1)
    PORT.ID = YREC<SC.ScoSecurityPositionUpdate.SecurityTrans.SctSecurityAccount>
    GOSUB GET.SAM
    BEGIN CASE
        CASE TRANS.ID[1,6] = "SCTRSC"
            EB.SystemTables.setApplication('SEC.TRADE')
            GOSUB WHILE.COB
            IF NOT(APPL.ERR) THEN       ;* CI_10042115 - S
                LOCATE CUST.ID IN APPL.REC(SC.SctTrading.SecTrade.SbsCustomerNo)<1,1> SETTING APOS THEN
                    YREC<SC.ScoSecurityPositionUpdate.SecurityTrans.SctTransType>= APPL.REC(SC.SctTrading.SecTrade.SbsCustTransCode)<1,APOS>
                    SECURITY.CODE = APPL.REC(SC.SctTrading.SecTrade.SbsSecurityCode)
                    GOSUB READ.SECURITY.MASTER ; * BG_100016871
                    TAX.TYPE = APPL.REC(SC.SctTrading.SecTrade.SbsCuTaxType)<1,APOS>
                    TRANS.TYPE.CODE = APPL.REC(SC.SctTrading.SecTrade.SbsCustTransCode)<1,APOS>
                    CU.TAX.CODE.ARR = APPL.REC(SC.SctTrading.SecTrade.SbsCuTaxCode)<1,APOS>
* incase of different type of tax codes, extract the EU TAX from cu.tax codes
* and check for effective dates.
                    LOOP
                        REMOVE TAX.CODE FROM CU.TAX.CODE.ARR SETTING CODE.POS
                    WHILE TAX.CODE:CODE.POS DO
                        R.TXN.TAX.CODE = ''
                        R.TXN.TAX.CODE = SC.SctTaxes.TxnTaxCode.CacheRead(TAX.CODE, TAX.CODE.ERR)
* Before incorporation : CALL CACHE.READ('F.TXN.TAX.CODE',TAX.CODE,R.TXN.TAX.CODE,TAX.CODE.ERR)
                        IF R.TXN.TAX.CODE<SC.SctTaxes.TxnTaxCode.ScTxnTaxParamFile> EQ "EU.TAX.PARAM" THEN
                            CU.TAX.CODE = TAX.CODE
                        END
                    REPEAT
                    IF APPL.REC(SC.SctTrading.SecTrade.SbsRecordStatus) EQ 'IHLD' THEN
                        REC.STATUS = 1  ;* CI_10037643 S/E
                    END
                    GOSUB CHECK.SECURITY.LIAB
                END
            END     ;* CI_10042115 - E

        CASE TRANS.ID[1,6] = "SECTSC"
            EB.SystemTables.setApplication('SECURITY.TRANSFER')
            GOSUB WHILE.COB
            IF NOT(APPL.ERR) THEN       ;* CI_10042115 - S
                YREC<SC.ScoSecurityPositionUpdate.SecurityTrans.SctTransType>= APPL.REC(SC.SctOffMarketTrades.SecurityTransfer.ScStrTransactionType)
                SECURITY.CODE = APPL.REC(SC.SctOffMarketTrades.SecurityTransfer.ScStrSecurityNo)
                GOSUB READ.SECURITY.MASTER ; * BG_100016871
                TAX.TYPE = APPL.REC(SC.SctOffMarketTrades.SecurityTransfer.ScStrCuTaxType)
                TRANS.TYPE.CODE = APPL.REC(SC.SctOffMarketTrades.SecurityTransfer.ScStrTransactionType)
* Fixing reference of CU.TAX.CODE from SEC.TRADE to SECURIYT.TRNSFER.
                CU.TAX.CODE.ARR = APPL.REC(SC.SctOffMarketTrades.SecurityTransfer.ScStrCuTaxCode)
* incase of different type of tax codes, extract the EU TAX from cu.tax codes
* and check for effective dates.
                LOOP
                    REMOVE TAX.CODE FROM CU.TAX.CODE.ARR SETTING CODE.POS
                WHILE TAX.CODE:CODE.POS DO
                    R.TXN.TAX.CODE = ''
                    R.TXN.TAX.CODE = SC.SctTaxes.TxnTaxCode.CacheRead(TAX.CODE, TAX.CODE.ERR)
* Before incorporation : CALL CACHE.READ('F.TXN.TAX.CODE',TAX.CODE,R.TXN.TAX.CODE,TAX.CODE.ERR)
                    IF R.TXN.TAX.CODE<SC.SctTaxes.TxnTaxCode.ScTxnTaxParamFile> EQ "EU.TAX.PARAM" THEN
                        CU.TAX.CODE = TAX.CODE
                    END
                REPEAT
                IF APPL.REC(SC.SctOffMarketTrades.SecurityTransfer.ScStrRecordStatus) EQ 'IHLD' THEN
                    REC.STATUS = 1      ;* CI_10037643 S/E
                END
                GOSUB CHECK.SECURITY.LIAB
            END     ;* CI_10042115 - E

        CASE TRANS.ID[1,6] = "POSTSC"
            EB.SystemTables.setApplication('POSITION.TRANSFER')
            GOSUB WHILE.COB
* If there are mismatches occured in ETL and there are position transfer txns from one depo to another involved in it then
* During initial data build, position - out should not be reflected and position - in should be reflected in ETL
* For that case, the following code changes has been done.

            IF NOT(APPL.ERR) THEN       ;* CI_10042115 - S
                IF APPL.REC(SC.SctPositionTransfer.PositionTransfer.ScPstDepositoryFrom) AND APPL.REC(SC.SctPositionTransfer.PositionTransfer.ScPstDepositoryTo) AND APPL.REC(SC.SctPositionTransfer.PositionTransfer.ScPstDepositoryFrom) NE APPL.REC(SC.SctPositionTransfer.PositionTransfer.ScPstDepositoryTo) THEN
                    IF EB.SystemTables.getRunningUnderBatch()  THEN  ;* CI_10035585 S
                        GOSUB POSN.TRANSFER.LIABLE
                    END ELSE
                        LIABLE = 0
                    END
                END ELSE
                    GOSUB POSN.TRANSFER.LIABLE
                END ;* CI_10035585 E
            END     ;* CI_10042115 - E

        CASE TRANS.ID[1,6] = "DIARSC"
            SECURITY.CODE = YREC<SC.ScoSecurityPositionUpdate.SecurityTrans.SctSecurityNumber>
            GOSUB READ.SECURITY.MASTER ; * BG_100016871
* DIARY event should be passed instead of TRANS.TYPE from SECURITY.TRANS
            TRANS.TYPE.CODE = DIARY.REC<SC.SccEventCapture.Diary.DiaEventType>
* Getting tax details moved to new method, since multiple tax setup is introduced.
            TAX = 'SC.TAX.CODE'
            SC.ScoSecurityMasterMaintenance.SmGetTaxByName(R.EU.SM,TAX,'')
            TAX.CODES.ARR = TAX
            LOOP
                REMOVE TAX.CODE FROM TAX.CODES.ARR SETTING CODE.POS
            WHILE TAX.CODE:CODE.POS DO
                R.TXN.TAX.CODE = ''
                R.TXN.TAX.CODE = SC.SctTaxes.TxnTaxCode.CacheRead(TAX.CODE, TAX.CODE.ERR)
* Before incorporation : CALL CACHE.READ('F.TXN.TAX.CODE',TAX.CODE,R.TXN.TAX.CODE,TAX.CODE.ERR)
                IF R.TXN.TAX.CODE<SC.SctTaxes.TxnTaxCode.ScTxnTaxParamFile> EQ "EU.TAX.PARAM" THEN
                    CU.TAX.CODE = TAX.CODE
                END
            REPEAT
            GOSUB CHECK.SECURITY.LIAB

        CASE TRANS.ID[1,6] = "SCSTCD"
* Perform processing for service based trades as for normal trades
            EB.SystemTables.setApplication('SC.SEC.TRADE.CUST.DETAIL')
            GOSUB WHILE.COB
            IF NOT(APPL.ERR) THEN

                YREC<SC.ScoSecurityPositionUpdate.SecurityTrans.SctTransType>= APPL.REC(SC.SctServiceBasedOrders.SecTradeCustDetail.StdTransCode)
                SECURITY.CODE = APPL.REC(SC.SctServiceBasedOrders.SecTradeCustDetail.StdSecurityNo)
                GOSUB READ.SECURITY.MASTER
                TAX.TYPE = APPL.REC(SC.SctServiceBasedOrders.SecTradeCustDetail.StdCuTaxType)<1,1>
                TRANS.TYPE.CODE = APPL.REC(SC.SctServiceBasedOrders.SecTradeCustDetail.StdTransCode)
                CU.TAX.CODE.ARR = APPL.REC(SC.SctServiceBasedOrders.SecTradeCustDetail.StdCuTaxCode)<1,1>
* incase of different type of tax codes, extract the EU TAX from cu.tax codes
* and check for effective dates.
                LOOP
                    REMOVE TAX.CODE FROM CU.TAX.CODE.ARR SETTING CODE.POS
                WHILE TAX.CODE:CODE.POS DO
                    R.TXN.TAX.CODE = ''
                    R.TXN.TAX.CODE = SC.SctTaxes.TxnTaxCode.CacheRead(TAX.CODE, TAX.CODE.ERR)
* Before incorporation : CALL CACHE.READ('F.TXN.TAX.CODE',TAX.CODE,R.TXN.TAX.CODE,TAX.CODE.ERR)
                    IF R.TXN.TAX.CODE<SC.SctTaxes.TxnTaxCode.ScTxnTaxParamFile> EQ "EU.TAX.PARAM" THEN
                        CU.TAX.CODE = TAX.CODE
                    END
                REPEAT
                IF APPL.REC(SC.SctServiceBasedOrders.SecTradeCustDetail.StdRecordStatus) EQ 'IHLD' THEN
                    REC.STATUS = 1
                END
                GOSUB CHECK.SECURITY.LIAB

            END

        CASE 1

    END CASE

RETURN
*** </region>

*** <region name= PROCESS.FROM.ENTITLEMENT>
PROCESS.FROM.ENTITLEMENT:
*** <desc> </desc>

    BEGIN CASE
        CASE TRANS.ID[1,6] = "DIARSC"
            EB.SystemTables.setApplication("ENTITLEMENT")
            ENTL.REC = '' ; * BG_100016871 S
            YERR1 = ''
            ENTL.REC = SC.SccEntitlements.Entitlement.ReadNau(TRANS.ID, YERR1) ; * BG_100016871 E
* Before incorporation : CALL F.READ('F.ENTITLEMENT$NAU',TRANS.ID,ENTL.REC,'',YERR1) ; * BG_100016871 E
            IF YERR1 THEN
                ENTL.REC = '' ; * BG_100016871 S
                YERR1 = ''
                ENTL.REC = SC.SccEntitlements.Entitlement.Read(TRANS.ID, YERR1) ; * BG_100016871 E
* Before incorporation : CALL F.READ(FN.ENTITLEMENT,TRANS.ID,ENTL.REC,F.ENTITLEMENT,YERR1) ; * BG_100016871 E
            END
            IF NOT(YERR1) AND NOT(YERR2) THEN
                CUST.ID = FIELD(ENTL.REC<SC.SccEntitlements.Entitlement.EntPortfolioNo>,"-",1)
                PORT.ID = ENTL.REC<SC.SccEntitlements.Entitlement.EntPortfolioNo>
                GOSUB GET.SAM
                SECURITY.CODE = ENTL.REC<SC.SccEntitlements.Entitlement.EntSecurityNo>
                GOSUB READ.SECURITY.MASTER ; * BG_100016871
                TRANS.TYPE.CODE = DIARY.REC<SC.SccEventCapture.Diary.DiaEventType>
                TAX.CODES.ARR = DIARY.REC<SC.SccEventCapture.Diary.DiaScTaxCode>
                LOOP
                    REMOVE TAX.CODE FROM TAX.CODES.ARR SETTING CODE.POS
                WHILE TAX.CODE:CODE.POS DO
                    R.TXN.TAX.CODE = ''
                    R.TXN.TAX.CODE = SC.SctTaxes.TxnTaxCode.CacheRead(TAX.CODE, TAX.CODE.ERR)
* Before incorporation : CALL CACHE.READ('F.TXN.TAX.CODE',TAX.CODE,R.TXN.TAX.CODE,TAX.CODE.ERR)
                    IF R.TXN.TAX.CODE<SC.SctTaxes.TxnTaxCode.ScTxnTaxParamFile> EQ "EU.TAX.PARAM" THEN
                        CU.TAX.CODE = TAX.CODE
                    END
                REPEAT
                GOSUB CHECK.SECURITY.LIAB
            END
            YERR1 = ''
            R.DIARY.TYPE = SC.SccEventCapture.DiaryType.CacheRead(TRANS.TYPE.CODE, YERR1)
* Before incorporation : CALL CACHE.READ('F.DIARY.TYPE',TRANS.TYPE.CODE,R.DIARY.TYPE,YERR1)
* For redemption, we are not going to update the entitlement cash events
            IF R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryCash>[1,1] = 'Y' AND R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DrySecurityUpdate>[1,1] = 'Y' AND R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryNewSecurities> = 'NO' AND R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryOptions> = 'NO' AND R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryReinvest> = 'NO' AND R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryRights> = 'NO' AND R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryFreeSecurities> = 'NO' AND R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryRetainOriginal> = 'NO' THEN
                LIABLE = 0
            END

        CASE 1

    END CASE

RETURN
*** </region>


********************
CHECK.SECURITY.LIAB:
********************

* This para does the initial checking on the SM for CREDIT type transactions. For'DEBIT' type transactions SC.EU.SCOPE.CHECK is called to
* perform the liablity check on SM, CUSTOMER, TAX effective dates.

    R.EU.TAX.PARAM = '' ; YERR1 = '' ; YERR2 = '' ; YRET = ''         ;* CI_10034309 S/E
    tmp.ID.COMPANY = EB.SystemTables.getIdCompany()
    R.EU.TAX.PARAM = ET.Contract.EuTaxParam.CacheRead(tmp.ID.COMPANY, YERR1)
* Before incorporation : CALL CACHE.READ('F.EU.TAX.PARAM',tmp.ID.COMPANY,R.EU.TAX.PARAM,YERR1)
    IF YERR1 THEN
        R.EU.TAX.PARAM = ET.Contract.EuTaxParam.CacheRead('SYSTEM', YERR2)
* Before incorporation : CALL CACHE.READ('F.EU.TAX.PARAM','SYSTEM',R.EU.TAX.PARAM,YERR2)
    END
    IF YERR2 THEN
        RETURN
    END
    SC.ScoFoundation.GetLocRef('SECURITY.MASTER',R.EU.TAX.PARAM<ET.Contract.EuTaxParam.EuTaxSmEffDateFld>,POSN)
    IF POSN > 0 THEN
        SM.EFF.DATE = R.EU.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmLocalRef><1,POSN>
    END
    IF NOT(YREC) THEN
        YREC = ENTL.REC
    END
    IF YREC THEN    ;* CI_10034309 S/E
        ET.Contract.ScEuDrCr(TRANS.ID,YREC,YDATA,YRET)
    END   ;* CI_10034309 S/E
    IF SM.EFF.DATE THEN
        ADD.INFO = ''
        ADD.INFO<37> = PORT.ID:'#':TRANS.TYPE.CODE:'#':'':'#':CU.TAX.CODE:'#':SECURITY.CODE:'#':'':'#':'':'#':'':'#':'YES'
        ADD.INFO<39> = EB.SystemTables.getApplication()
        ET.Contract.ScEuScopeCheck(CUST.ID,TAX.TYPE,LIABLE,ADD.INFO)
        GROUP.INFO = FIELD(ADD.INFO<38>,'#',1)
        IF YRET = 'CREDIT' THEN
            LIABLE = 1
            IF GROUP.INFO = 'CU.IN.EXE' THEN
                LIABLE = 0
            END
        END ELSE
            tmp.RUNNING.UNDER.BATCH = EB.SystemTables.getRunningUnderBatch()
            IF NOT(tmp.RUNNING.UNDER.BATCH) THEN
                IF GROUP.INFO EQ 'CU.IN.INFO' THEN
                    GOSUB INFO.LIST.FILE.UPD
                END
            END ELSE
                IF GROUP.INFO EQ 'CU.IN.INFO' THEN
                    LIABLE = 1
                END
            END
        END
    END
RETURN

*************************
DETERMINE.CUSTOMER.GROUP:
*************************
* This para determines if the CUSTOMER come under the TAX group or INFO group
* Getting tax details moved to new method, since multiple tax setup is introduced.
    TAX = 'SC.TAX.CODE'
    SC.ScoSecurityMasterMaintenance.SmGetTaxByName(R.EU.SM,TAX,'')
    TAX.CODES.ARR = TAX
    LOOP
        REMOVE TAX.CODE FROM TAX.CODES.ARR SETTING CODE.POS
    WHILE TAX.CODE:CODE.POS DO
        R.TXN.TAX.CODE = '' ; APPL.POS = 1
        R.TXN.TAX.CODE = SC.SctTaxes.TxnTaxCode.CacheRead(TAX.CODE, TAX.CODE.ERR)
* Before incorporation : CALL CACHE.READ('F.TXN.TAX.CODE',TAX.CODE,R.TXN.TAX.CODE,TAX.CODE.ERR)
        IF R.TXN.TAX.CODE<SC.SctTaxes.TxnTaxCode.ScTxnTaxParamFile> EQ "EU.TAX.PARAM" THEN
            IF EB.SystemTables.getApplication() NE 'POSITION.TRANSFER' THEN
                IF TRANS.ID[1,6] NE "DIARSC" THEN
                    LOCATE EB.SystemTables.getApplication() IN R.TXN.TAX.CODE<SC.SctTaxes.TxnTaxCode.ScTxnTxnApplic,1> SETTING APPL.POS ELSE
                        APPL.POS = 1
                    END
*                END ELSE
*                    LOCATE TRANS.TYPE.CODE IN R.TXN.TAX.CODE<SC.TXN.TXN.APPLIC,1> SETTING APPL.POS ELSE APPL.POS = 0
* The above code is commented because all the STOCK events must be written in to the base irrespective of whether
* the EVENT.TYPE is given in the TXN.TAX.CODE.
                END
            END
            IF R.EU.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare> EQ "B" THEN
                TXN.TAX.TYPE = R.TXN.TAX.CODE<SC.SctTaxes.TxnTaxCode.ScTxnBondsTax,APPL.POS,1>
            END ELSE
                TXN.TAX.TYPE = R.TXN.TAX.CODE<SC.SctTaxes.TxnTaxCode.ScTxnShareTax,APPL.POS,1>
            END
            IF TXN.TAX.TYPE[1,1] = '*' THEN
                TXN.TAX.TYPE = TXN.TAX.TYPE[2,99]
            END
        END
    UNTIL TXN.TAX.TYPE DO
    REPEAT
    R.CUSTOMER.CHARGE = '' ; CUSTOMER.ERR = ''
    R.CUSTOMER.CHARGE = CG.ChargeConfig.CustomerCharge.CacheRead(CUST.ID, CUSTOMER.ERR)
* Before incorporation : CALL CACHE.READ('F.CUSTOMER.CHARGE',CUST.ID,R.CUSTOMER.CHARGE,CUSTOMER.ERR)
    LOCATE TXN.TAX.TYPE IN R.CUSTOMER.CHARGE<CG.ChargeConfig.CustomerCharge.EbCchTaxType,1> SETTING TXN.POSN ELSE
        LIABLE = 0
        RETURN
    END
    EU.TAX.GROUP = R.CUSTOMER.CHARGE<CG.ChargeConfig.CustomerCharge.EbCchTaxActGroup><1,TXN.POSN>
    EU.TAX.POS = 0
    LOCATE EU.TAX.GROUP IN R.EU.TAX.PARAM<ET.Contract.EuTaxParam.EuTaxCuTaxGrp,1> SETTING EU.TAX.POS THEN
        LIABLE = 1
        IF EB.SystemTables.getRunningUnderBatch() THEN
            IF EB.SystemTables.getRDates(EB.Utility.Dates.DatCoBatchStatus) EQ "B" THEN  ;*BG_100008046 -S
                LIABLE = 0
            END     ;*BG_100008046 -S
        END
    END ELSE
        LOCATE EU.TAX.GROUP IN R.EU.TAX.PARAM<ET.Contract.EuTaxParam.EuTaxCuInfoGrp,1> SETTING EU.TAX.POS THEN
            tmp.RUNNING.UNDER.BATCH = EB.SystemTables.getRunningUnderBatch()
            IF NOT(tmp.RUNNING.UNDER.BATCH) THEN
                GOSUB INFO.LIST.FILE.UPD
            END ELSE
                IF REC.STATUS THEN      ;* CI_10037643 S
                    GOSUB INFO.LIST.FILE.UPD
                END ;* CI_10037643 E
                LIABLE = 1
            END
        END ELSE
            IF CUST.REL.ID THEN ; * If the group is neither in CU.TAX.GRP or CU.INFO.GRP and if customer relationship is set. Then set LIABLE to 1
                LIABLE = 1 ; * This is because the same would be processed in SC.CU.SCOPE.CHECK during Dr transactions.
            END

            IF EB.SystemTables.getRDates(EB.Utility.Dates.DatCoBatchStatus) EQ "B" THEN  ;*BG_100008046 -S
                LIABLE = 0
            END     ;*BG_100008046 -E
        END
    END
RETURN

********************
INFO.LIST.FILE.UPD:
********************

* This para updates the file SC.EU.INFO.CUSTOMER.WORK if the input is for INFO customer
    INF.POS = ''
    IF R.EU.TAX.PARAM<ET.Contract.EuTaxParam.EuTaxInfoUpdMode> EQ 'BATCH' THEN
        IF COUNT(TRANS.ID,".") EQ 1 THEN
            LIST.ID = YREC<SC.ScoSecurityPositionUpdate.SecurityTrans.SctSecurityAccount>:'.':YREC<SC.ScoSecurityPositionUpdate.SecurityTrans.SctSecurityNumber>
        END ELSE
            LIST.ID = YREC<SC.SccEntitlements.Entitlement.EntPortfolioNo>:'.':YREC<SC.SccEntitlements.Entitlement.EntSecurityNo>
        END
        R.SC.EU.INFO.CUSTOMER = ET.Contract.ScEuInfoCustomerWork.Read(LIST.ID, CUS.ERR)
* Before incorporation : CALL F.READ('F.SC.EU.INFO.CUSTOMER.WORK',LIST.ID,R.SC.EU.INFO.CUSTOMER,F.SC.EU.INFO.CUSTOMER.WORK,CUS.ERR)
        LOCATE TRANS.ID IN R.SC.EU.INFO.CUSTOMER<1> SETTING INF.POS ELSE
            INF.POS = ''
        END
* The deletion or reversal of Info customer's tranasaction has to happen Online.
* So it should not be written to Info customer workfile.
        IF INF.POS = '' AND EB.SystemTables.getVFunction() NE "D" AND EB.SystemTables.getVFunction() NE "R" THEN
            IF R.SC.EU.INFO.CUSTOMER EQ '' THEN
                R.SC.EU.INFO.CUSTOMER = TRANS.ID
            END ELSE
                R.SC.EU.INFO.CUSTOMER := @FM:TRANS.ID
            END
            ET.Contract.EuInfoCustomerWorkUpdate(LIST.ID,'WRITE',R.SC.EU.INFO.CUSTOMER,'')
* Before incorporation : CALL F.WRITE('F.SC.EU.INFO.CUSTOMER.WORK',LIST.ID,R.SC.EU.INFO.CUSTOMER)
            LIABLE = 0
        END ELSE
* In case of reversal of DIARY or POSITION.TRANSFER without using comma version , during authorisation of RNAU
* record V$function is equal to "A". So additional check condition is added to allow deletion of reversed record
* from SC.EU.INFO.CUSTOMER.WORK
            IF EB.SystemTables.getVFunction() EQ "D" OR EB.SystemTables.getVFunction() EQ "R" OR (EB.SystemTables.getVFunction() EQ "A" AND (TRANS.ID[1,6] EQ "DIARSC" OR TRANS.ID[1,6] EQ "POSTSC")) OR REC.STATUS THEN    ;* CI_10036451 S/E ; * CI_10037643 S/E
                LOC.POS = ''
                LOCATE TRANS.ID IN R.SC.EU.INFO.CUSTOMER<1> SETTING LOC.POS THEN
                    DEL R.SC.EU.INFO.CUSTOMER<LOC.POS>
                END
                IF R.SC.EU.INFO.CUSTOMER EQ '' THEN
                    ET.Contract.EuInfoCustomerWorkUpdate(LIST.ID,'DELETE','','')
* Before incorporation : CALL F.DELETE('F.SC.EU.INFO.CUSTOMER.WORK',LIST.ID)
                END ELSE
                    ET.Contract.EuInfoCustomerWorkUpdate(LIST.ID,'WRITE',R.SC.EU.INFO.CUSTOMER,'')
* Before incorporation : CALL F.WRITE('F.SC.EU.INFO.CUSTOMER.WORK',LIST.ID,R.SC.EU.INFO.CUSTOMER)
                END
            END ELSE
                LIABLE = 0
            END
        END
    END
RETURN
********************
CHECK.CUSTOMER.LIAB:
********************
* This para is called only for "CREDIT" transactions

    CU.LOC = R.EU.TAX.PARAM<ET.Contract.EuTaxParam.EuTaxCuEffDateFld>
    CU.EFF.DATE = ''
    IF CU.LOC THEN
        customerKey = CUST.ID
        fieldName = CU.LOC
        fieldNumber = ''
        fieldOption = ''
        dataField = ''
        CALL CustomerService.getProperty(customerKey,fieldName,fieldNumber,fieldOption,dataField)
        IF EB.SystemTables.getEtext() = '' THEN
            CU.EFF.DATE = dataField<DataField.enrichment>
        END ELSE ;* error handling
            EB.SystemTables.setEtext('')
        END
    END

    IF NOT(CU.EFF.DATE) THEN
        LIABLE = 0
    END

RETURN

**************
ACTUAL.LIABLE:
**************
* This para is called to check if the date of input greater or equal to the latest of the three dates.

    IF (SM.EFF.DATE GT CU.EFF.DATE) AND (SM.EFF.DATE GT TAX.EFFECTIVE.DATE) THEN
        LATEST.DATE = SM.EFF.DATE
    END ELSE
        IF CU.EFF.DATE GT TAX.EFFECTIVE.DATE THEN
            LATEST.DATE = CU.EFF.DATE
        END ELSE
            LATEST.DATE = TAX.EFFECTIVE.DATE
        END
    END
    IF EB.SystemTables.getToday() GE LATEST.DATE THEN
        LIABLE = 1
    END ELSE
        LIABLE = 0
    END
RETURN
**********
WHILE.COB:
**********
    IF EB.SystemTables.getRDates(EB.Utility.Dates.DatCoBatchStatus) EQ 'B' THEN
        F.APPL = 'F.':EB.SystemTables.getApplication()
        FV.APPL = ''
        EB.DataAccess.Opf(F.APPL, FV.APPL)

        F.APPL$NAU = 'F.':EB.SystemTables.getApplication():'$NAU'
        FV.APPL$NAU = ''
        EB.DataAccess.Opf(F.APPL$NAU, FV.APPL$NAU)

        R.APPL = ''
        EB.DataAccess.FRead(F.APPL$NAU,TXN.ID,R.APPL,FV.APPL$NAU,APPL.ERR)
        IF APPL.ERR THEN
            APPL.ERR = ''
            EB.DataAccess.FRead(F.APPL,TXN.ID,R.APPL,FV.APPL,APPL.ERR)
        END
        IF NOT(APPL.ERR) THEN
            MATPARSE APPL.REC FROM R.APPL
        END
    END ELSE
        R.NEW.DYN = EB.SystemTables.getDynArrayFromRNew()
        MATPARSE APPL.REC FROM R.NEW.DYN
    END
RETURN

******************************
POSN.TRANSFER.LIABLE:
*******************************
    SECURITY.CODE = YREC<SC.ScoSecurityPositionUpdate.SecurityTrans.SctSecurityNumber>
    GOSUB READ.SECURITY.MASTER ; * BG_100016871
    TRANS.TYPE.CODE = YREC<SC.ScoSecurityPositionUpdate.SecurityTrans.SctTransType>
* Getting tax details moved to new method, since multiple tax setup is introduced.
    TAX = 'SC.TAX.CODE'
    SC.ScoSecurityMasterMaintenance.SmGetTaxByName(R.EU.SM,TAX,'')
    TAX.CODES.ARR = TAX
    LOOP
        REMOVE TAX.CODE FROM TAX.CODES.ARR SETTING CODE.POS
    WHILE TAX.CODE:CODE.POS DO
        R.TXN.TAX.CODE = ''
        R.TXN.TAX.CODE = SC.SctTaxes.TxnTaxCode.CacheRead(TAX.CODE, TAX.CODE.ERR)
* Before incorporation : CALL CACHE.READ('F.TXN.TAX.CODE',TAX.CODE,R.TXN.TAX.CODE,TAX.CODE.ERR)
        IF R.TXN.TAX.CODE<SC.SctTaxes.TxnTaxCode.ScTxnTaxParamFile> EQ "EU.TAX.PARAM" THEN
            CU.TAX.CODE = TAX.CODE
        END
    REPEAT
    GOSUB CHECK.SECURITY.LIAB
RETURN          ;* CI_10035585 E

*-----------------------------------------------------------------------------
*** <region name= READ.SECURITY.MASTER>
READ.SECURITY.MASTER:
*** <desc>Read the SECURITY.MASTER record </desc>

    R.EU.SM = ''
    YERR = ''
    R.EU.SM = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SECURITY.CODE, YERR)
* Before incorporation : CALL F.READ(FN.SECURITY.MASTER,SECURITY.CODE,R.EU.SM,F.SECURITY.MASTER,YERR)

RETURN

*** </region>

*-----------------------------------------------------------------------------
*** <region name= READ.DIARY>
READ.DIARY:
*** <desc>Read DIARY record </desc>
    DIARY.REC = ''
    YERR2 = ''
    DIARY.REC = SC.SccEventCapture.Diary.Read(TRANS.ID[1,16], YERR2)
* Before incorporation : CALL F.READ(FN.DIARY,TRANS.ID[1,16],DIARY.REC,F.DIARY,YERR2)
RETURN
*** </region>
*-----------------------------------------------------------------------------
** <region name= GET.SAM>
GET.SAM:
*** <desc>Read SEC.ACC.MASTER </desc>

    CUST.REL.ID = ''
    R.SAM = ''
    SAM.ERR = ''
    R.SAM = SC.ScoPortfolioMaintenance.SecAccMaster.Read(PORT.ID, SAM.ERR)
* Before incorporation : CALL F.READ(FN.SEC.ACC.MASTER,PORT.ID,R.SAM,F.SEC.ACC.MASTER,SAM.ERR)
    CUST.REL.ID = R.SAM<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamCusRelationship>

RETURN
*** </region>

END
