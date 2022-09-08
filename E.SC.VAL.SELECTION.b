* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 23 22/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>61</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvReports
    SUBROUTINE E.SC.VAL.SELECTION
************************************************************
*
*    SUBROUTINE TO CONTSTRUCT ENQUIRY SELECTION PARAMETERS
*     FOR SECURITY, ACCOUNTS, DEPOSITS, FOREIGN EXCHANGE
*    FOR USE IN NEXT LEVEL ENQUIRY
*
*    LOCAL3 = SEC.ACC.NO
*    LOCAL2 = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamAccountNos>
*    LOCAL6 = LIQD.ASSET.NO
*    LOCAL7 = LIQD.POS.KEYS
*
* 30/09/02 - CI_10003897
*            Problems in drilldown in enquiries like
*            SC.VAL.MARKET or the CUS.VB because the
*            length of security master was hard coded.
*
* 25/06/03 - CI_10010271
*            Additional Validation to handle drill down to
*            DX.TRANSACTION records.
*
* 11/03/04 - CI_10018047
*            Problems in drilldown in enquiries.
*
* 23/12/04 - EN_10002382
*            SC Phase I non stop processing.
*
* 13/03/07 - GLOBUS_EN_10003200
*            Removal of POS.CON.SCAC
*
* 13/08/07 - GLOBUS_BG_100014892 dgearing@temenos.com
*            remove liqd applications as they are obsolete
*            get rid of "mid flow" returns as they are not needed
*            tidy up for ratings
*
* 22/12/08 - GLOBUS_CI_10059605 - dgearing@temenos.com
*            Unable to drilldown to MG contract.
*
* 13/02/09 - GLOBUS_BG_10022152 - dadkinson@temenos.com
*            Browser-compatibility fix for drilldown to
*            underlying contract.
*
* 04/08/09 - GLOBUS_BG_100024764 - dgearing@temenos.com
*            Asterix can no longer be used as a delimeter in
*            the output data as it can exist in the key for
*            security.trans for entitlements or for a service
*            based position.transfer. So change to tilda.
*            Remove quoting of data.rec as this is no longer
*            required it seems and it causes issues in concat.list.processor.
*
* 15/12/10 - DEFECT 92235 TASK 119119
*            While launching SC.VAL.MARGIN enquiry for a portfolio, System throws
*            an error “Enquiry Record Missing” when we drill down to view SY Transaction.
*
* 31/03/11 - DEFECT 56383 TASK 182892
*            Could not view the trade details after SC.VAL.COST for ND deal.
*
* 14/04/11 - DEFECT 104845 TASK 192188
*            The Contract  details  for AA  cannot be viewed , while
*            running the SC valuation enquiry.
*
* 18/04/11 - DEFECT 104845 TASK 194149
*            The Contract  details  for AA  cannot be viewed , while
*            running the SC valuation enquiry.
*
* 27/01/12 - DEFECT : 345825 TASK:346131
*            Unable to drill down account statement through enquiry
*
* 30/05/13 - Defect-685631 / Task-690142
*            "Invalid or uninitialised variable" message occurs while running the enquiry SC.VAL.COST
*
* 8/01/14 - Defect-876431 Task-883205
*           System doesnt show the DX.TRADE in the drop down Top Up Sell Out Margin Status Report under the menu Margin Call Reports.
*
* 20/04/15 - 1323085
*            Incorporation of components
*
* 17/07/15 - Enhancement_1322379 Task_1411404
*            TAFC Compilation errors
**********************************************************************************************

    $INSERT I_DAS.SECURITY.POSITION

    $USING SC.ScoPortfolioMaintenance
    $USING EB.DataAccess
    $USING ST.CompanyCreation
    $USING SC.ScoSecurityPositionUpdate
    $USING SC.ScoSecurityMasterMaintenance
    $USING SC.Config
    $USING SC.ScvValuationUpdates
    $USING EB.Reports
    $USING EB.SystemTables
    $USING ST.Valuation

    COMP.MNEM = ''
    SRC.ID = ''

    GOSUB GET.PORT.COMP.ID ; *Read the SAM record and get the PORT.COMP.ID

*** <region name= Main program flow>
*** <desc>Main program flow </desc>
    BEGIN CASE
        CASE EB.Reports.getOData()[1,2] = 'MM'
            * set drill down for money market application
            EB.Reports.setOData('MM.MONEY.MARKET S ':EB.Reports.getOData())
        CASE EB.Reports.getOData()[1,2] = 'LD'
            * set drill down for loans and deposits application
            EB.Reports.setOData('LD.LOANS.AND.DEPOSITS S ':EB.Reports.getOData())
        CASE EB.Reports.getOData()[1,2] = 'FX'
            * set drill down for foreign exchange application
            EB.Reports.setOData('FOREX S ':EB.Reports.getOData())
        CASE EB.Reports.getOData()[1,2] = 'ND'
            * set drill down for ND.DEAL application
            EB.Reports.setOData('ND.DEAL S ':EB.Reports.getOData())
        CASE EB.Reports.getOData()[1,2] = 'FR'
            * set drill down forward rate agreement application
            EB.Reports.setOData('FRA.DEAL S ':EB.Reports.getOData())
        CASE EB.Reports.getOData()[1,2] = 'FD'
            * set drill down for fiducuries application
            EB.Reports.setOData('FD.FID.ORDER S ':EB.Reports.getOData())
        CASE EB.Reports.getOData()[1,2] = 'MD'
            * set drill down for miscellaneous deals application
            EB.Reports.setOData('MD.DEAL S ':EB.Reports.getOData())
        CASE EB.Reports.getOData()[1,2] = 'MG'
            * set drill down for mortgage application
            EB.Reports.setOData('MG.MORTGAGE S ':EB.Reports.getOData())
            tmp.O.DATA = EB.Reports.getOData()
        CASE EB.Reports.getOData()[1,2] = 'TF' AND LEN(tmp.O.DATA) = 12

            * set drill down for letter of credit application
            EB.Reports.setOData('LETTER.OF.CREDIT S ':EB.Reports.getOData())
            tmp.O.DATA = EB.Reports.getOData()
        CASE EB.Reports.getOData()[1,2] = 'TF' AND LEN(tmp.O.DATA) > 12

            * set drill down for drawings application
            EB.Reports.setOData('DRAWINGS S ':EB.Reports.getOData())
        CASE EB.Reports.getOData()[4] MATCHES 'REPO':@VM:'RESO'
            * set drill down repo details
            EB.Reports.setOData('CUST.REPO~CUSTOMER.CCY.TYPE EQ ':EB.Reports.getOData())
        CASE EB.Reports.getOData()[1,2] = 'SY'
            * set drill down for miscellaneous deals application
            EB.Reports.setOData('SY.TRANSACTION S ':EB.Reports.getOData())
        CASE 1
            GOSUB CHECK.ACC.NO

            IF ACCT.POS = 1 THEN

                * set drill down for account statement enquiry
                tmp.TODAY = EB.SystemTables.getToday()
                EB.Reports.setOData('STMT.ENT.BOOK~ACCT.ID EQ ':EB.Reports.getOData():'+':'BOOKING.DATE LE ':tmp.TODAY)

                RETURN
            END
            IF ACCT.POS = 2 THEN
                EB.Reports.setOData('AA.ARRANGEMENT.TAB~ARRANGEMENT.ID EQ ':EB.Reports.getOData())
                RETURN
            END
            IF ACCT.POS = 3 THEN
                EB.Reports.setOData('AA.AD.ARRANGEMENT.TAB~ARRANGEMENT.ID EQ ':EB.Reports.getOData())
                RETURN
            END

            LOCATE EB.Reports.getOData() IN EB.Reports.getRRecord()<SC.ScvValuationUpdates.PosAsset.PasSecurityNo,1> SETTING DATA.POS THEN
            YAPPL = EB.Reports.getRRecord()<SC.ScvValuationUpdates.PosAsset.PasApplication,DATA.POS>
            BEGIN CASE
                CASE YAPPL EQ 'SC'
                    * set drill down for security transaction details
                    GOSUB VAL.POS.DET
                    EB.Reports.setOData('SC.POS.DET~':'REFERENCE.NUMBER EQ ':DATA.REC)
                CASE YAPPL EQ 'DX'
                    * set drill down for dx transaction details
                    * This bit of Code is added to Pick the Derivatives Transaction
                    * Previously it was Picking up the DX.CONTRACT.MASTER
                    * This could not drill down to Pick up the Next Level Enquiry
                    SOURCE.ID = EB.Reports.getRRecord()<SC.ScvValuationUpdates.PosAsset.PasSourceId,DATA.POS>

                    GOSUB CHECK.PORT.COMP.ID ; *Appends the SECURITY.TRANS id with company mnemonic if PORT.COMP.ID is not the same as ID.COMPANY.

                    CONVERT @SM TO ' ' IN SOURCE.ID
                    EB.Reports.setOData('%DX.TRANSACTION~@ID EQ ':SOURCE.ID)
            END CASE
        END
    END CASE

    RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= CHECK.ACC.NO>
*** <desc>See if line corresponds to an account </desc>
CHECK.ACC.NO:
*------------

    DATA.REC = ''

    ACCOUNT.NO = EB.Reports.getOData()
    tmp.ID = EB.Reports.getId()
    K.SEC.ACC = FIELD(tmp.ID,'.',1,1)
    EB.Reports.setId(tmp.ID)
    tmp.ID = EB.Reports.getId()
    K.ASSET.TYPE = FIELD(tmp.ID,'.',3,1)
    EB.Reports.setId(tmp.ID)
    R.ASSET.TYPE = ''
    R.ASSET.TYPE = ST.Valuation.AssetType.CacheRead(K.ASSET.TYPE, ER)
* Before incorporation : CALL CACHE.READ('F.ASSET.TYPE', K.ASSET.TYPE, R.ASSET.TYPE, ER)
    INTERFACE.LOCAL = R.ASSET.TYPE<ST.Valuation.AssetType.AssInterfaceTo>
    ACCT.POS = ''
    IF INTERFACE.LOCAL = 'AC' THEN
        ACCT.POS = 1
    END
    IF INTERFACE.LOCAL = 'AL' THEN
        ACCT.POS = 2
    END
    IF INTERFACE.LOCAL = 'AD' THEN
        ACCT.POS = 3
    END

    RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= VAL.POS.DET>
*** <desc>Extract security.trans details for drilldown </desc>
VAL.POS.DET:
*-----------

************************************************************
*
*    SUBROUTINE TO EXTRACT SECURITY POSITION KEYS
*    AND PERFORMING MATCH ON SECURITY.NUMBER
*
*    LOCAL5 = SEC.ACC.NO
*    LOCAL4 = R.POS.CON.SCAC
*    SECURITY POSITION IS SELECTED ON CHANGE OF SEC.ACC.NO
*
****************************************
*
    DATA.REC = ''

    SECURITY.NO = EB.Reports.getOData()
    tmp.ID = EB.Reports.getId()
    K.SEC.ACC = FIELD(tmp.ID,'.',1,1)
    EB.Reports.setId(tmp.ID)

    GOSUB GET.SECURITY.MASTER.DETAILS ; *Get security.master record and set variables

    GOSUB GET.SECURITY.POSITION.LIST ; *get security.position list
*
    GOSUB PROCESS.SECURITY.POSITION.LIST ; *Go through security.position list and build data.rec

    GOSUB BUILD.TRANS.KEY.LIST ; *Build security.trans list from security.position list

    CONVERT @FM TO ' ' IN DATA.REC

    RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= GET.SECURITY.MASTER.DETAILS>
GET.SECURITY.MASTER.DETAILS:
*** <desc>Get security.master record and set variables </desc>

    tmp.ETEXT = EB.SystemTables.getEtext()
    R.SECURITY.MASTER = SC.ScoSecurityMasterMaintenance.tableSecurityMaster(SECURITY.NO,tmp.ETEXT)
    EB.SystemTables.setEtext(tmp.ETEXT)

    BOND.OR.SHARE = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare>
    ASSET.SUB.TYPE = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmSubAssetType>
    INTEREST.RATE = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmInterestRate>
    ACCRUAL.START.DATE = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmAccrualStartDate>
    KO.FLAG = ''
    VIB.FLAG = ''
    R.ASSET.SUB.TYPE = ''
    R.ASSET.SUB.TYPE = ST.Valuation.SubAssetType.CacheRead(ASSET.SUB.TYPE, ER)
* Before incorporation : CALL CACHE.READ('F.SUB.ASSET.TYPE', ASSET.SUB.TYPE, R.ASSET.SUB.TYPE, ER)

    KO.FLAG = R.ASSET.SUB.TYPE<ST.Valuation.SubAssetType.CsgKassenobligationen>
    VIB.FLAG = R.ASSET.SUB.TYPE<ST.Valuation.SubAssetType.CsgVarInterestBonds>

    IF KO.FLAG = 'YES' & ACCRUAL.START.DATE EQ '' THEN
        KO.PROCESSING = @TRUE  ;* Kassenobligationen
    END ELSE
        KO.PROCESSING = @FALSE ;* All other processing.
    END

    IF VIB.FLAG = 'YES' & NOT(INTEREST.RATE) THEN
        VIB.PROCESSING = @TRUE ;* Variable Interest Bonds.
    END ELSE
        VIB.PROCESSING = @FALSE          ;* Not Variable Interest Bonds.
    END

    RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= GET.SECURITY.POSITION.LIST>
GET.SECURITY.POSITION.LIST:
*** <desc>get security.position list </desc>

    IF EB.SystemTables.getLocalFiv() NE K.SEC.ACC THEN
        R.POS.CON.SCAC = dasSecurityPositionSecurityAccount
        THE.ARGS = K.SEC.ACC
        TABLE.SUFFIX = ''
        EB.DataAccess.Das('SECURITY.POSITION', R.POS.CON.SCAC, THE.ARGS, TABLE.SUFFIX)
        EB.SystemTables.setLocalFiv(K.SEC.ACC)
        EB.SystemTables.setLocalFou(R.POS.CON.SCAC)
    END ELSE
        R.POS.CON.SCAC = EB.SystemTables.getLocalFou()
    END

    RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= PROCESS.SECURITY.POSITION.LIST>
PROCESS.SECURITY.POSITION.LIST:
*** <desc>Go through security.position list and build data.rec </desc>

    ARRAY = R.POS.CON.SCAC
    LOOP
        REMOVE K.POS FROM ARRAY SETTING MORE
    WHILE K.POS:MORE ; * BG_100014892
        IF FIELD(K.POS,'.',2,1) = SECURITY.NO THEN
            tmp.VC = EB.Reports.getVc()
            ST.POS = LEN(EB.Reports.getRRecord()<SC.ScvValuationUpdates.PosAsset.PasSecurityNo,tmp.VC>) + 1

            MATURITY.DATE = EB.Reports.getRRecord()<SC.ScvValuationUpdates.PosAsset.PasHeldSince,EB.Reports.getVc()>[ST.POS,8]
            ST.POS += 8
            INTEREST.RATE = EB.Reports.getRRecord()<SC.ScvValuationUpdates.PosAsset.PasHeldSince,EB.Reports.getVc()>[ST.POS,99]
            IF FIELD(K.POS,'.',5) = MATURITY.DATE AND FIELD(K.POS,'.',6) = INTEREST.RATE THEN
                INS K.POS BEFORE DATA.REC<-1>
            END
        END
    REPEAT

    RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= BUILD.TRANS.KEY.LIST>
BUILD.TRANS.KEY.LIST:
*** <desc>Build security.trans list from security.position list </desc>
*    SUBROUTINE TO EXTRACT SECURITY TRANS KEYS
*    FROM TRN CON DATE  TO BE USED IN ENQUIRY
*    SC.POS.DET
*
************************************************************
*
    SAVE.ID.COMPANY = ''
    IF PORT.COMP.ID AND PORT.COMP.ID NE EB.SystemTables.getIdCompany() THEN
        R.COMP = ST.CompanyCreation.tableCompany(PORT.COMP.ID,READ.ERR)
        COMP.MNEM = R.COMP<ST.CompanyCreation.Company.EbComMnemonic>
        SAVE.ID.COMPANY = EB.SystemTables.getIdCompany()
        EB.SystemTables.setIdCompany(PORT.COMP.ID)
        tmp.ID.COMPANY = EB.SystemTables.getIdCompany()
        ST.CompanyCreation.LoadCompany(tmp.ID.COMPANY)

    END
    POS.ARRAY = DATA.REC
    DATA.REC = ''
    LOOP
        REMOVE K.POS FROM POS.ARRAY SETTING MORE.POS
    WHILE K.POS:MORE.POS      ;* CI_10018047 S/E

        R.TRN.CON.DATE = '' ; EB.SystemTables.setEtext('')
        tmp.ETEXT = EB.SystemTables.getEtext()
        SC.ScoSecurityPositionUpdate.ReadTrnConDate(K.POS,R.TRN.CON.DATE,tmp.ETEXT)
        EB.SystemTables.setEtext(tmp.ETEXT)
        IF EB.SystemTables.getEtext() OR R.TRN.CON.DATE = '' THEN
            EB.Reports.setOData('')
            CONTINUE          ;* CI_10018047 S/E
        END

        ARRAY = R.TRN.CON.DATE
        LOOP
            REMOVE RECORD FROM ARRAY SETTING MORE
        WHILE RECORD:MORE   ; * BG_100014892
            DOT.POS = COUNT(RECORD,'.')
            K.TRANS = FIELD(RECORD,'.',DOT.POS,2)
            IF COMP.MNEM THEN
                K.TRANS = K.TRANS:'\':COMP.MNEM
            END
            INS K.TRANS BEFORE DATA.REC<-1>
        REPEAT

        IF SAVE.ID.COMPANY THEN
            EB.SystemTables.setIdCompany(SAVE.ID.COMPANY)
            tmp.ID.COMPANY = EB.SystemTables.getIdCompany()
            ST.CompanyCreation.LoadCompany(tmp.ID.COMPANY)

        END

    REPEAT

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.PORT.COMP.ID>
GET.PORT.COMP.ID:
*** <desc>Read the SAM record and get the PORT.COMP.ID </desc>
    tmp.ID = EB.Reports.getId()
    K.SEC.ACC = FIELD(tmp.ID,'.',1,1) ;*Get the SAM id
    EB.Reports.setId(tmp.ID)
    READ.ERR = ''
    R.SEC.ACC.MASTER = ''
    R.SEC.ACC.MASTER = SC.ScoPortfolioMaintenance.tableSecAccMaster(K.SEC.ACC,READ.ERR)

    PORT.COMP.ID = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamPortCompId> ;*Get the PORT.COMP.ID from SAM record.

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CHECK.PORT.COMP.ID>
CHECK.PORT.COMP.ID:
*** <desc>Appends the SECURITY.TRANS id with company mnemonic if PORT.COMP.ID is not the same as ID.COMPANY. </desc>
    IF PORT.COMP.ID AND PORT.COMP.ID NE EB.SystemTables.getIdCompany() THEN ;*If PORT.COMP.ID is not the same as ID.COMPANY append the security trans ID with the company mnemonic.
        R.COMP = ST.CompanyCreation.tableCompany(PORT.COMP.ID,READ.ERR)
        COMP.MNEM = R.COMP<ST.CompanyCreation.Company.EbComMnemonic>
        SRC.ID.CNT = DCOUNT(SOURCE.ID,@SM)
        FOR I = 1 TO SRC.ID.CNT
            IF SRC.ID THEN
                SRC.ID = SRC.ID:@SM:SOURCE.ID<1,1,I>:'\':COMP.MNEM
            END ELSE
                SRC.ID = SOURCE.ID<1,1,I>:'\':COMP.MNEM
            END
        NEXT I
        SOURCE.ID = SRC.ID
    END

    RETURN
*** </region>

    END


