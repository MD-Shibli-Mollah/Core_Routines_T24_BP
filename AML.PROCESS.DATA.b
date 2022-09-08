* @ValidationCode : MjotNzI1NzA0MTMxOkNwMTI1MjoxNjE2Njc3NjU4MzgwOnZlbG11cnVnYW46MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4yMDIxMDMwMS0wNTU2OjI0MDoxNzg=
* @ValidationInfo : Timestamp         : 25 Mar 2021 18:37:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : velmurugan
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 178/240 (74.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



$PACKAGE VP.Config
SUBROUTINE AML.PROCESS.DATA(BI.FILE.NAME, rDwExport, T.BI.ID, T.ROW)
*
*-----------------------------------------------------------------------------
* Routine to fetch the data from STMT.ENTRY and the respective application set
* in AML.TXN.ENTRY. And will write this in .csv format.
*
*  Modification History:
*
* 14\11\11 - Task 234981
*            AML Service.
*
* 16/01/15 - Defect 1225127 / Task 1226344
*          - Amount will be passed as absolute value and new header DebitCreditInd added
*          - to indicate if the amount is debit or credit
*
* 23/01/15 - Defect 1231133 / Task 1232301
*          - When posting bulk transactions, entries corresponding to all customer accounts
*          - will be present.
*
* 04/03/15 - Defect 1271081/ Task 1272196
*          - The array IN.REC.ARR has to be made null after processing each string so that the
*          - next condition is not satisfied for same entry count
*
*
* 07/07/15 -  Enhancement 1265068
*            Routine incorporated
*
* 16/04/16 - Defect 1699922/ Task 1700213
*          - Assign variables correctly
*
*-----------------------------------------------------------------------------
*
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING DW.BiExport
    $USING DW.BiExportFramework
    $USING AC.EntryCreation
    $USING EB.API
    $USING EB.LocalReferences
    $USING EB.DataAccess
    $USING VP.Config


    GOSUB INITIALISE
    GOSUB PROCESS
*
RETURN
*
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Declared variables</desc>
*
INITIALISE:
***********
*
*

*Included the default header columns of FUNDS.TRANSFER and POR.TRANSACTION
    FM.SEP = ''
    IF T.ROW EQ 'HEADING' THEN
        T.ROW = 'branch':DW.BiExportFramework.getFldSep():'transactionID':DW.BiExportFramework.getFldSep():'applicationID':DW.BiExportFramework.getFldSep():'branchName'
        T.ROW := DW.BiExportFramework.getFldSep():'companyCode':DW.BiExportFramework.getFldSep():'backOfficeCode':DW.BiExportFramework.getFldSep():'backOfficeName'
        T.ROW := DW.BiExportFramework.getFldSep():'operationCode':DW.BiExportFramework.getFldSep():'operationDate':DW.BiExportFramework.getFldSep():'currency'
        T.ROW := DW.BiExportFramework.getFldSep():'amountCurrency':DW.BiExportFramework.getFldSep():'amountRefCurrency':DW.BiExportFramework.getFldSep():'accountID'
        T.ROW := DW.BiExportFramework.getFldSep():'limitRef':DW.BiExportFramework.getFldSep():'accountName':DW.BiExportFramework.getFldSep():'accountCustomerID'
        T.ROW := DW.BiExportFramework.getFldSep():'accountCustomerShortName':DW.BiExportFramework.getFldSep():'segmentSector'
        T.ROW := DW.BiExportFramework.getFldSep():'debitCreditInd':DW.BiExportFramework.getFldSep():'customerName':DW.BiExportFramework.getFldSep():'customerAddress'
        T.ROW := DW.BiExportFramework.getFldSep():'postalCode':DW.BiExportFramework.getFldSep():'residence':DW.BiExportFramework.getFldSep():'countryCode'
        T.ROW := DW.BiExportFramework.getFldSep():'valueDate':DW.BiExportFramework.getFldSep():'txnApproveDateTime':DW.BiExportFramework.getFldSep():'thirdPartyID'
        T.ROW := DW.BiExportFramework.getFldSep():'thirdPartyShortName'
        FM.SEP = '~'
    END
*
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Main Process</desc>
*
PROCESS:
********
*

    F.AML.EXT = ''
    TXN.ENTRY = ''
*
    R.BI.RECORD = ''
    R.BI.RECORD = VP.Config.AmlTxnEntry.Read(T.BI.ID , T.ER)
*
    APP.TO.READ = FIELD(T.BI.ID,'-',1)
    
    TXN.REF = FIELD(T.BI.ID,'-',2)

    TRN.BRA.MNE = FIELD(T.BI.ID,'-',3)
*
    VP.Config.setAmlRecCount(DCOUNT(R.BI.RECORD,@FM))
*
    IN.REC.ARR_FT = RAISE(R.BI.RECORD<1>)

    VP.Config.AmlExtractMapping.Read(APP.TO.READ , ER)
*
    APP.TO.READ.C = APP.TO.READ:'-':'CREDIT'
    R.AML.EXT.CREDIT = VP.Config.AmlExtractMapping.Read(APP.TO.READ.C  , ER)
*
    APP.TO.READ.D = APP.TO.READ:'-':'DEBIT'
    R.AML.EXT.DEBIT = VP.Config.AmlExtractMapping.Read(APP.TO.READ.D , ER)
*
    APP.TO.READ = "STMT.ENTRY"
    R.STMT.ENTRY = VP.Config.AmlExtractMapping.Read(APP.TO.READ , ER)
*
    FOR AML.CNT = 2 TO VP.Config.getAmlRecCount()
        IN.REC.ARR = RAISE(R.BI.RECORD<AML.CNT>)
        IN.REC.PROCESS = IN.REC.ARR
        IF IN.REC.ARR<AC.EntryCreation.StmtEntry.SteAmountLcy> LE 0 AND (R.AML.EXT.DEBIT OR R.STMT.ENTRY) THEN
            IN.REC.ARR<AC.EntryCreation.StmtEntry.SteAmountLcy> = ABS(IN.REC.ARR<AC.EntryCreation.StmtEntry.SteAmountLcy>)
            IN.REC.ARR<AC.EntryCreation.StmtEntry.SteAmountFcy> = ABS(IN.REC.ARR<AC.EntryCreation.StmtEntry.SteAmountFcy>)
            T.ROW := FM.SEP
            TXN.ENTRY = "DEBIT"     ;*Indicates the entry Type is Debit
            APP.TO.READ = "STMT.ENTRY"
            GOSUB PROCESS.STMT.DATA
            T.ROW := 'Debit':DW.BiExportFramework.getFldSep()    ;*indicates the entry amount is debit
            R.AML.EXT = R.AML.EXT.DEBIT
            IN.REC.ARR = IN.REC.ARR_FT
            APP.TO.READ = FIELD(T.BI.ID,'-',1)
            GOSUB PROCESS.DATA
            IN.REC.ARR = ''   ;*made the array null to exit loop
        END
        IF IN.REC.ARR<AC.EntryCreation.StmtEntry.SteAmountLcy> GT 0 AND (R.AML.EXT.CREDIT OR R.STMT.ENTRY) THEN
            IN.REC.ARR<AC.EntryCreation.StmtEntry.SteAmountLcy> = ABS(IN.REC.ARR<AC.EntryCreation.StmtEntry.SteAmountLcy>)
            IN.REC.ARR<AC.EntryCreation.StmtEntry.SteAmountFcy> = ABS(IN.REC.ARR<AC.EntryCreation.StmtEntry.SteAmountFcy>)
            T.ROW := FM.SEP
            TXN.ENTRY = "CREDIT"    ;*Indicates the entry Type is Credit
            APP.TO.READ = "STMT.ENTRY"
            GOSUB PROCESS.STMT.DATA
            T.ROW := 'Credit':DW.BiExportFramework.getFldSep()   ;*indicates the entry amount is credit
            R.AML.EXT = R.AML.EXT.CREDIT
            IN.REC.ARR = IN.REC.ARR_FT
            APP.TO.READ = FIELD(T.BI.ID,'-',1)
            GOSUB PROCESS.DATA
            IN.REC.ARR = ''   ;*made the array null to exit loop
        END
        FM.SEP = '~'
    NEXT AML.CNT
*
    VP.Config.VpAmlTxnEntryDelete(T.BI.ID)
*
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.STMT.DATA>
*** <desc>Drills STMT.ENTRY data based on the setup of AML.EXTRACT.MAPPING</desc>
*
PROCESS.STMT.DATA:
******************
*
    R.AML.EXT = R.STMT.ENTRY
*
    GOSUB PROCESS.DATA
*
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.DATA>
*** <desc>Drills APPLICATION data based on the setup of AML.EXTRACT.MAPPING</desc>
*
PROCESS.DATA:
*************
*
    FLD.LIST = ''
    FLD.LIST = R.AML.EXT<VP.Config.AmlExtractMapping.AmlExtFieldType>
    FLD.NAME = R.AML.EXT<VP.Config.AmlExtractMapping.AmlExtSysFieldName>
    FLD.LENGTH = R.AML.EXT<VP.Config.AmlExtractMapping.AmlExtFieldLength>
    NO.OF.FLDS = DCOUNT(FLD.LIST,@VM)
    PROC.APPL.NAME = APP.TO.READ
    FOR FLD.CNT = 1 TO NO.OF.FLDS
        FLD.TYPE = FLD.LIST<1,FLD.CNT>
        FIELD.NAME = FLD.NAME<1,FLD.CNT>
        GOSUB AML.GET.DATA
        FLD.LEN = FLD.LENGTH<1,FLD.CNT>
        TOTAL.SPLIT.VALUES = ''
        TOTAL.SPLIT.VALUES = DCOUNT(FIELD.INFO, @VM) ;* When RTN(AML.GET.THIRDPARTY.VALUES) that fetches ThirdPartyId and ThirdPartyName is attached, FIELD.INFO return two values
        
        IF TOTAL.SPLIT.VALUES GT 1 THEN
            FIRST.SPLIT=FIELD(FIELD.INFO,@VM,1)
            IF FLD.LEN THEN
                FIRST.SPLIT = FIRST.SPLIT[1,FLD.LEN]
            END
            SECOND.SPLIT = FIELD(FIELD.INFO,@VM,2)
            IF FLD.LEN THEN
                SECOND.SPLIT = SECOND.SPLIT[1,FLD.LEN]
            END
            T.ROW :=FIRST.SPLIT:DW.BiExportFramework.getFldSep():SECOND.SPLIT:DW.BiExportFramework.getFldSep()

        END ELSE
            IF FLD.LEN THEN
                FIELD.INFO = FIELD.INFO[1,FLD.LEN]
            END
            T.ROW :=FIELD.INFO:DW.BiExportFramework.getFldSep()

        END
    NEXT FLD.CNT
*
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= AML.GET.DATA>
*** <desc>Get field values for the field numbers defined in AML.EXTRACT.MAPPING</desc>
*
AML.GET.DATA:
*************
*
    R.STANDARD.SELECTION =""
    BEGIN CASE
        CASE FLD.TYPE = "FIELD"
            EB.API.GetStandardSelectionDets(PROC.APPL.NAME, R.STANDARD.SELECTION)
            GOSUB CHECK.LOCAL.FIELDS

        CASE FLD.TYPE="LINK.FIELD"
            GOSUB GET.LINK.DETS

        CASE FLD.TYPE = "CONST"
            FIELD.INFO = FIELD.NAME

        CASE FLD.TYPE = "RTN"
            CALL @FIELD.NAME(T.BI.ID,FIELD.INFO)

    END CASE
*
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.LOCAL.FIELDS>
*** <desc>Get local field values for the field numbers defined if any</desc>
*
CHECK.LOCAL.FIELDS:
*******************
*
    LOC.POSN.AV = ""
    LOC.POSN.AS = ""
    IF FIELD.NAME[1,9] = "LOCAL.REF" THEN
        LOC.POSN.AV = FIELD(FIELD(FIELD.NAME,'-',2),'.',1)
        LOC.POSN.AS = FIELD(FIELD(FIELD.NAME,'-',2),'.',2)
        EB.API.FieldNamesToNumbers("LOCAL.REF",R.STANDARD.SELECTION,FIELD.NO,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
        FIELD.INFO = IN.REC.ARR<FIELD.NO,LOC.POSN.AV,LOC.POSN.AS>
    END ELSE
        LINK.APPLN.NAME = PROC.APPL.NAME
        LINK.RECS = IN.REC.ARR
        LINK.FIELD.NAME = FIELD.NAME
        GOSUB GET.FIELD.DETS
    END
*
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.LINK.DETS>
*** <desc>Get Link field values for the field numbers defined if any</desc>
*
GET.LINK.DETS:
**************

    K = 1
    J = 2
    NO.OF.LINK.FLDS = DCOUNT(FIELD.NAME,">")
    LINK.APPLN.NAME = PROC.APPL.NAME

    LINK.RECS = IN.REC.ARR

*
    LOOP
    WHILE K LE NO.OF.LINK.FLDS

        LINK.FIELD.NAME = FIELD.NAME[">",K,1]
        GOSUB GET.FIELD.DETS
        LINK.FIELD.NAME = FIELD.INFO
        LINK.APPLN.NAME = FIELD.NAME[">",J,1]
        IF LINK.APPLN.NAME THEN
            COMPANY.MNEMONIC = ''
            Y.APPL = ''
            
            IF LINK.APPLN.NAME = 'ACCOUNT' OR LINK.APPLN.NAME = 'CUSTOMER' THEN
                
                COMPANY.ID = IN.REC.PROCESS<AC.EntryCreation.StmtEntry.SteCompanyCode>

                ERR = ''
                COMP.REC = ST.CompanyCreation.Company.CacheRead(COMPANY.ID, ERR)

                Y.APPL = LINK.APPLN.NAME
                GOSUB GET.COMPANY.MNEMONIC

                
            END
            
            FN.LINK.APPLN.NAME = "F":COMPANY.MNEMONIC:".":LINK.APPLN.NAME
            FV.LINK.APPLN.NAME = ''
            SAVE.COMPANY = ''
            
            IF EB.SystemTables.getIdCompany() NE COMPANY.ID THEN
               
                SAVE.COMPANY = COMPANY.ID
                ST.CompanyCreation.LoadCompany(COMPANY.ID)

            END
            EB.DataAccess.Opf(FN.LINK.APPLN.NAME,FV.LINK.APPLN.NAME)
            LINK.RECS =''
            EB.DataAccess.FRead(FN.LINK.APPLN.NAME,LINK.FIELD.NAME,LINK.RECS,FV.LINK.APPLN.NAME,LINK.ERR)
            IF SAVE.COMPANY THEN
                ST.CompanyCreation.LoadCompany(SAVE.COMPANY)
            END

        END
        K = K+2
        J = J+2
    REPEAT
*
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.FIELD.DETS>
*** <desc>Get the field numbers defined in AML.EXTRACT.MAPPING</desc>
*
GET.FIELD.DETS:
***************
*
    LRF.POSN = ""
    R.STANDARD.SELECTION = ""
    FIELD.NO = ""
    YAS = ""
    POS = ""
*
    EB.API.GetStandardSelectionDets(LINK.APPLN.NAME,R.STANDARD.SELECTION)
    EB.LocalReferences.GetLocRef(LINK.APPLN.NAME,LINK.FIELD.NAME,LRF.POSN)
*
    IF LRF.POSN THEN
        EB.API.FieldNamesToNumbers("LOCAL.REF",R.STANDARD.SELECTION,FIELD.NO,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
        FIELD.INFO = LINK.RECS<FIELD.NO,LRF.POSN,YAS>
    END ELSE
        EB.API.FieldNamesToNumbers(LINK.FIELD.NAME,R.STANDARD.SELECTION,FIELD.NO,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)

* If the link application name is POR.SUPPLEMENTARY.INFO based on the transaction entry type identify the credit/debit fields
* from POR.SUPPLEMENTARY.INFO and fill the field informtaions.
        IF LINK.APPLN.NAME = "POR.SUPPLEMENTARY.INFO" THEN
            IF TXN.ENTRY = "DEBIT" THEN
                LOCATE "D" IN LINK.RECS<1,1> SETTING POS THEN
                    FIELD.INFO = LINK.RECS<FIELD.NO,POS,1>
                END
            END
            IF TXN.ENTRY = "CREDIT" THEN
                LOCATE "C" IN LINK.RECS<1,1> SETTING POS THEN
                    FIELD.INFO = LINK.RECS<FIELD.NO,POS,1>
                END
            END
        END ELSE
            FIELD.INFO = LINK.RECS<FIELD.NO,1,1>
        END
    END
*
RETURN
*
*
*** </region>
*-----------------------------------------------------------------------------
*
GET.COMPANY.MNEMONIC:
*--------------------
*get the correct mnemonic based of application. To support for all classification of files
*
    R.FILE.CONTROL = EB.SystemTables.FileControl.Read(Y.APPL,FERR)
    FILE.CLASSIFICATION = R.FILE.CONTROL<EB.SystemTables.FileControl.FileControlClass>
    Y.FILE.NAME = Y.APPL
    GOSUB MNEMONIC.CALCULATION
    COMPANY.MNEMONIC = MNEMONIC


RETURN

MNEMONIC.CALCULATION:
    MNEMONIC = ""
    CLASS.OK = 1
    BEGIN CASE
        CASE FILE.CLASSIFICATION = "INT"
            MNEMONIC = ""
        CASE FILE.CLASSIFICATION = "CUS"
            MNEMONIC = COMP.REC<ST.CompanyCreation.Company.EbComMnemonic>
        CASE FILE.CLASSIFICATION = "FIN"
            MNEMONIC = COMP.REC<ST.CompanyCreation.Company.EbComFinancialMne>
        CASE FILE.CLASSIFICATION = "FTF"
            MNEMONIC = COMP.REC<ST.CompanyCreation.Company.EbComFinanFinanMne>
        CASE FILE.CLASSIFICATION = "CCY"
            MNEMONIC = COMP.REC<ST.CompanyCreation.Company.EbComCurrencyMnemonic>
        CASE FILE.CLASSIFICATION = "NOS"
            MNEMONIC = COMP.REC<ST.CompanyCreation.Company.EbComNostroMnemonic>
        CASE FILE.CLASSIFICATION = "CST"
            MNEMONIC = COMP.REC<ST.CompanyCreation.Company.EbComDefaultCustMne>
            IF COMP.REC<ST.CompanyCreation.Company.EbComSpclCustFile> THEN
                SUBFIELD = COMP.REC<ST.CompanyCreation.Company.EbComSpclCustFile>
                LOCATE Y.FILE.NAME IN SUBFIELD<1,1> SETTING POS THEN
                    MNEMONIC = COMP.REC<ST.CompanyCreation.Company.EbComSpclCustMne><1,POS>
                END
            END
        CASE FILE.CLASSIFICATION = "FTD"
            MNEMONIC=COMP.REC<ST.CompanyCreation.Company.EbComDefaultFinanMne>
            IF COMP.REC<ST.CompanyCreation.Company.EbComSpclFinFile> THEN
                SUBFIELD = COMP.REC<ST.CompanyCreation.Company.EbComSpclFinFile>
                LOCATE Y.FILE.NAME IN SUBFIELD<1,1> SETTING POS THEN
                    MNEMONIC = COMP.REC<ST.CompanyCreation.Company.EbComSpclFinMne><1,POS>
                END
            END
        CASE FILE.CLASSIFICATION = "FRP"
            MNEMONIC=COMP.REC<ST.CompanyCreation.Company.EbComMnemonic>
        CASE 1
            CLASS.OK = 0
    END CASE
RETURN
END
