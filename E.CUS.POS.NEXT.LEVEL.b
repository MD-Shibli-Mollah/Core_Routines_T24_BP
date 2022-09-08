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

* Version 5 18/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>690</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE E.CUS.POS.NEXT.LEVEL
*-----------------------------------------------------------------------------
*
* This subroutine will decide the next level enquiry
* for CUS.POSITION
* Both the summary and the detail enquires
** A number of days for STMT.ENT.BOOK can be specfied as a Type S item
*
*----------------------------------------------------------------------
* Program Changes
*
* 09/09/97 - GB9701037
*            When checking for LIMIT.REF to start with CURR and an or
*            CHECK for Application to be AC
*
* 29/09/99 - GB9901345
*          - Remove TXN.CO.MNE var from concatenation of NEXT.SEL
*            and NEXT.APP var
* 18/03/02 - BG_100000723
*            For cheque collateral, drill dowm to the enquiry CQ.COLL.DETAILS
*
* 26/03/02 - CI_10001399
*            ERROR IN CUSTOMER POSITION, CIF-586252
*            Reintroduced the field TXN.CO.MNE to rectify the problem.
*
* 12/01/05 - BG_100007893
*            ENQ of Detailed Customer Position throws error message
*            EB.RTN.INVALID.SELECTION.FLD
*            Drilldown to DX.TRADE and DX.TRANSACTION added
*
* 07/06/05 - EN_10002549
*            CACHE.READ file EB.SYSTEM.ID
*
* 14/07/06 - CI_10042622
*            CUSTOMER.POSITION.SUMMARY fatal out when the enquiry is run for the customer who
*            has MD deals in other company and MD not installed in company where enquiry is run.
*            Fix done such that MD deal positions are displayed when enquiry is run in the
*            company where MD not installed, but no drill down to MD deal details allowed.
*
* 14/09/06 - CI_10044106
*            When trying to drill down the other company's contract from the current company
*            in the customer.position enquiry output, we get the message 'Record Missing'.
*            Now we append the company mnemonic also with the transaction id & function,
*            so that we can now view other company contract.
*
* 11/05/07 - CI_10049012
*            Drill down not working for DX transactions.
*
* 30/06/09 - BG_100024318
*            Drill down not working for LC Mixed Payment transactions.
*
* 01/07/09 - BG_100024323
*            Enquiry LIAB is launched with invalid selection field.
*
* 07/07/09 - BG_100024384
*            Since ND no more a separate product, there is no need for checking it
*            in the COMPANY record.
* 28/04/10 - Defect 35151 / Task 44629
*            READV replaced with F.READV for reading LIMIT.REFERENCE application.
*
* 19/07/10 - Defect 43285 / Task 59002
*            Added case for external file.
*
* 04/01/12 - Defect 333721/Task 334211
*			 Pass ACCT.ID in the selection criteria when STMT.ENT.BOOK enquiry is to be
*			 executed.
*
* 18/08/14 - Defect 1080374 / Task 1088581
*			 When user tries to drill down account information in customer position
*			 enquiry "Sorry, you don't have permissions to access this data" is thrown
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 16/04/16 - Defect 1682901 / Task 1700517
*          - Drill down application should be correctly build for external files
*
*----------------------------------------------------------------------
*
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING SC.ScoPortfolioMaintenance
    $USING ST.ModelBank
    $USING ST.Customer
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING LI.Config
    $USING AC.Config
    $USING ST.CompanyCreation

*
    CUS.POS.ID = EB.Reports.getOData()       ;* Pass in CUSTOMER.POSITION.ID
    NEXT.APP = ""
    NEXT.SEL = ""
    NEXT.SEL2 = ""
    NEXT.SEL3 = ""
    LOCATE "AC.NO.DAYS" IN EB.Reports.getEnqSelection()<2,1> SETTING DAY.POS THEN
    NO.DAYS = EB.Reports.getEnqSelection()<4,DAY.POS>
    END ELSE
    NO.DAYS = "7W"
    END
*
    EXT.FLAG = CUS.POS.ID["*",10,1] ;* Set the flag for EXTERNAL file.
    TXN.REF = CUS.POS.ID["*",6,1]
    IF TXN.REF[1,2] EQ 'TF' AND LEN(TXN.REF) GT 14 THEN
        TXN.REF = TXN.REF[1,12]
    END
    TXN.CO.MNE = CUS.POS.ID["*",4,1]
    LIAB.NO = CUS.POS.ID["*",1,1]
    CUST.NO = CUS.POS.ID["*",2,1]
    LIM.REF.ID = CUS.POS.ID["*",5,1]
    FULL.LIM.REF = LIM.REF.ID ;* Store away as it is modified
    APP.ID = CUS.POS.ID["*",3,1]
    CATEGORY = EB.Reports.getRRecord()<ST.Customer.CustomerPosition.CupCategory>
*
    DETAIL = ""
    LOCATE "DETAIL.NEXT.LEVEL" IN EB.Reports.getEnqSelection()<2,1> SETTING DETAIL.POS THEN
    IF EB.Reports.getEnqSelection()<4,DETAIL.POS> NE "N" THEN
        DETAIL = 1
    END
    END ELSE
    LOCATE "DETAIL.NEXT.LEVEL" IN EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFieldName,1> SETTING DETAIL.POS THEN
    IF EB.Reports.getREnq()<EB.Reports.Enquiry.EnqOperation,DETAIL.POS>[1,2] NE '"N' THEN
        DETAIL = 1
    END
    END
    END
*
    IF DETAIL THEN
        *
        BEGIN CASE
            CASE APP.ID = "AC"    ;* Stmt Ent Last

                * If the user is logged from the branch company, TXN.CO.MNE will contain the value of lead company
                *  So, take the mnemonic from the account if logged from the branch company

                R.ACCOUNT = ''
                ACC.ERR = ''
                R.ACCOUNT = AC.AccountOpening.tableAccount(TXN.REF,ACC.ERR)
                IF (R.ACCOUNT<AC.AccountOpening.Account.CoCode> EQ EB.SystemTables.getIdCompany()) AND (EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic) NE TXN.CO.MNE) THEN
                    TXN.CO.MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic)
                END
                IF EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParValueDatedAcctng>[1,1] = "Y" THEN
                    NEXT.APP = "VAL.STMT.ENT.BOOK"
                    * GB9901345
                    NEXT.SEL = "ACCOUNT.NUM EQ ":TXN.REF:"\":TXN.CO.MNE
                    NEXT.SEL2 = "VALUE.DATE.SEL GE !TODAY-":NO.DAYS
                END ELSE
                    NEXT.APP = "STMT.ENT.BOOK"
                    * GB9901345
                    NEXT.SEL = "ACCT.ID EQ ":TXN.REF:"\":TXN.CO.MNE
                    NEXT.SEL2 = "BOOKING.DATE GE !TODAY-":NO.DAYS
                END
                *
            CASE APP.ID = "SC"    ;* SC.SEC.ACC.HOLD.SUM

                * If the user is logged from the branch company, TXN.CO.MNE will contain the value of lead company
                * So take the mnemonic from the security account master if logged from the branch company

                R.SEC.ACC.MASTER = ''
                F.SEC.ACC.MASTER = ''
                SAM.ERR = ''
                R.SEC.AC.MASTER = SC.ScoPortfolioMaintenance.tableSecAccMaster(TXN.REF, SAM.ERR)

                IF (R.SEC.AC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamCoCode> EQ EB.SystemTables.getIdCompany()) AND (EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic) NE TXN.CO.MNE) THEN
                    TXN.CO.MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic)
                END

                NEXT.APP = "SC.SEC.ACC.HOLD.SUM"
                * GB9901345
                NEXT.SEL = "SECURITY.ACCOUNT EQ ":TXN.REF:"\":TXN.CO.MNE
                *
            CASE APP.ID MATCHES "SCB":@VM:"SCS"
                NEXT.APP = "SC.POS.DET2"
                * GB9901345
                NEXT.SEL = "REF.NO EQ ":TXN.REF:"\":TXN.CO.MNE
                *
                *
                * BG_100000723 S
            CASE APP.ID = 'CQ'
                NEXT.APP ='CQ.COLL.DETAILS'
                NEXT.SEL = '@ID EQ ':TXN.REF
                * BG_100000723 E

                * BG_100007893 S

            CASE APP.ID = 'DXTRA'
                DXTRA.ID = FIELD(TXN.REF,'.',1)       ;* @id for DX.TRADE
                NEXT.APP = 'DX.TRADE S ' : DXTRA.ID   ;* CI_10049012
                NEXT.SEL = ''

            CASE APP.ID = 'DX'
                NEXT.APP = 'DX.TRANSACTION S ' : TXN.REF        ;* CI_10049012
                NEXT.SEL = ''

                * BG_100007893 E

            CASE EXT.FLAG EQ 'EXTERNAL'
                EXT.ID = CUST.NO:'-':APP.ID:'-':TXN.REF
                NEXT.APP = 'EXTERNAL.ARRANGEMENT.FILE S ' : EXT.ID
                NEXT.SEL = ''

            CASE 1
                *
                ** Order for processing:
                ** 1) Category * CP.TYPE
                ** 2) App * CP.TYPE
                ** 3) Category
                ** 4) App
                ** 5) EB.SYSTEM.ID
                *
                SEARCH.APP= APP.ID[1,2]
                IF SEARCH.APP EQ 'ND' THEN
                    SEARCH.APP = 'FX'
                END

                LOCATE SEARCH.APP IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING YNEXT.APP ELSE
                YNEXT.APP = ''
            END

            IF YNEXT.APP OR APP.ID[1,3] EQ 'EXT' THEN
                CP.REC = ""
                ST.ModelBank.CpGetRecord(CP.REC, CATEGORY, APP.ID)
                CONVERT ">" TO @FM IN CP.REC       ;* Returned converted already
                CONVERT "]" TO @VM IN CP.REC
                IF CP.REC<ST.Customer.CusPosEnqParam.CpeParApplication> THEN
                    NEXT.APP = CP.REC<ST.Customer.CusPosEnqParam.CpeParApplication>:" S ":TXN.REF:"\":TXN.CO.MNE   ;*CI_10001399
                    NEXT.SEL = ""
                END ELSE
                    YERR = '' ;* EN_10002549/S
                    EB.DataAccess.CacheRead('F.EB.SYSTEM.ID',APP.ID,R.EB.SYSTEM.ID,YERR)
                    IF NOT(YERR) THEN
                        SYS.REC = R.EB.SYSTEM.ID<EB.SystemTables.SystemId.SidApplication>     ;* EN_10002549/E

                        * GB9901345
                        NEXT.APP = SYS.REC:" S ":TXN.REF:"\":TXN.CO.MNE
                        NEXT.SEL = ""
                    END ELSE
                        NEXT.APP = "LIAB"
                        NEXT.SEL = "LIABILITY.NUMBER EQ ":CUST.NO
                    END
                END
            END
            *
    END CASE
*
    END ELSE
*
** Assume LIMIT.REFERENCE is passed
*
    IF LIM.REF.ID MATCHES "1N0N" THEN
        IF LIM.REF.ID[4] NE "0000" THEN
            LIM.REF.ID = LIM.REF.ID[4]
        END
        LIM.REF.ID += 0
    END
*
    R.LIMIT.REFERENCE = ''
    LIM.REF.TYPE = ""
    LIM.ERR = ''
    IF LIM.REF.ID THEN ;* Do read only when we have an id
        R.LIMIT.REFERENCE = LI.Config.tableLimitReference(LIM.REF.ID,LIM.ERR) ;* Readv is same as Read, so changed to table read
        IF NOT(LIM.ERR) THEN
            LIM.REF.TYPE = R.LIMIT.REFERENCE<LI.Config.LimitReference.RefFxOrTimeBand>
        END
    END
*
    BEGIN CASE
            *
        CASE LIM.REF.ID = "SCPORT"
            NEXT.APP = "SC.PORT.HOLD.SUM"
            NEXT.SEL = "CUSTOMER.NUMBER EQ ":CUST.NO
            *
        CASE LIM.REF.ID MATCHES "SCBOND":@VM:"SCSHARE"
            NEXT.APP = "SC.POS.DET2"
            * GB9901345
            NEXT.SEL = "REF.NO EQ ":TXN.REF:"\":TXN.CO.MNE
            *
            * GB9701037 and Or check
        CASE LIM.REF.ID[1,4] = "CURR" OR APP.ID = "AC"
            NEXT.APP = "ACCT.BAL.LAST"
            NEXT.SEL = "CUSTOMER EQ ":CUST.NO
            *
        CASE LIM.REF.ID[1,4] = "COLL"
            NEXT.APP = "CO.001"
            NEXT.SEL = "CUSTOMER.CODE EQ ":CUST.NO
            *
        CASE LIM.REF.ID = "COMMIT"
            NEXT.APP = "LD.COMMITMENTS"
            NEXT.SEL = "CUSTOMER.ID EQ ":CUST.NO
            *
        CASE LIM.REF.TYPE = "FX"
            NEXT.APP = "FX.ENQ.SUMMARY"
            NEXT.SEL = "COUNTERPARTY EQ ":CUST.NO
            *
        CASE LIM.REF.ID[4] = "0000"
            NEXT.APP = "LIAB"
            NEXT.SEL = "LIABLILTY.NUMBER EQ ":CUST.NO
            *
        CASE 1
            NEXT.APP = "LIM.TXN"
            NEXT.SEL = "LIAB.NO EQ ":LIAB.NO
            NEXT.SEL3 = "CUST.NO EQ ":CUST.NO
            NEXT.SEL2 = "REF.NO EQ ":FULL.LIM.REF
            *
    END CASE
*
    END
*
    EB.Reports.setOData(NEXT.APP:">":NEXT.SEL:">":NEXT.SEL2:">":NEXT.SEL3)
*
    RETURN
*-----------------------------------------------------------------------------
    END
