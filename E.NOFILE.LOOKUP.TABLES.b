* @ValidationCode : MjotMTYyNDkwMDM3MDpDcDEyNTI6MTU4MjcyNjM2MzY1OTpwYWRtYXNyaXM6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2OjE5ODo5OA==
* @ValidationInfo : Timestamp         : 26 Feb 2020 19:42:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : padmasris
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 98/198 (49.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE E.NOFILE.LOOKUP.TABLES(YR.DETAILS)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 17/01/2019 - Nofile implementation for returning description
*
* 12/02/2019 - Enhancement 2875458 / Task 3025793 - Migration to IRIS R18
*
* 09/04/2019 - Defect - 3051760 / Task 3077077 -  Warning in T2_ModelBank in 201904 TAFC Primary Compilation
*
* 09/02/2020 - Enhancement 3504695 / Task 3578976 - Limit Authorisation Changes
*
* 26/02/2020 - Defect 3603524 / Task 3609484 - While creating indirect User for PERSONAL customer/arrangement, Relationship is not correct with respect to personal customer.
*-----------------------------------------------------------------------------

    $USING AA.ProductManagement
    $USING AA.Framework
    $USING AC.AccountOpening
    $USING EB.Reports
    $USING EB.Security
    $USING EB.SystemTables
    $USING EB.API
    $USING EB.DataAccess
    $USING EB.Template
    $USING LI.Config
    $USING ST.CompanyCreation
    $USING EB.ARC
 
    GOSUB INITIALISE
    GOSUB PROCESS
*
RETURN

*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables</desc>
INITIALISE:
*----------
* Read the passed applications , selection criteria , prefix id and custom id
    
    FN.EB.LOOKUP = 'F.EB.LOOKUP';FN.STANDARD.SELECTION = 'F.STANDARD.SELECTION';FN.LIMIT.REFERENCE = 'F.LIMIT.REFERENCE';FN.COMPANY = 'F.COMPANY';FN.ACCOUNT = 'F.ACCOUNT';
    
*Predefined description field names and applications
    
    FIELD.NAME = 'SHORT.DESC':@FM:'DESCRIPTION':@FM:'RATING.DESC':@FM:'COMPANY.NAME':@FM:'COUNTRY.NAME':@FM:'CCY.NAME':@FM:'SHORT.NAME':@FM:'USER.NAME':@FM:'RELATIONSHIP.NAME':@FM:'NICKNAME':@FM:'INSTITUTION':@FM:'SHORT.TITLE':@FM:'NAME':@FM:'DESCRIPT':@FM:'DESCR':@FM:'DESC':@FM:'CRD.STS.DES':@FM:'MNEMONIC'
    APPLICATION.LIST = 'CATEGORY':@FM:'EB.LOOKUP':@FM:'TARGET':@FM:'CURRENCY':@FM:'SECTOR':@FM:'RELATION':@FM:'LANGUAGE':@FM:'INDUSTRY':@FM:'COUNTRY':@FM:'CHEQUE.TYPE':@FM:'EB.CHANNEL':@FM:'RELATION':@FM:'TITLE':@FM:'CUSTOMER.STATUS':@FM:'CUS.LEGAL.DOC.NAME':@FM:'LOGIN.METHOD':@FM:'TXN.SIGN':@FM:'USAGE.UPDATE.TYPE'
    
    YR.DETAILS = ''
    APPLICATIONS = ''

    LOCATE "APPLICATION" IN EB.Reports.getDFields() SETTING ARRPOS THEN
        APPLICATIONS = EB.Reports.getDRangeAndValue()<ARRPOS>       ;*Read the application passed from dynamic selection
    END

    LOCATE "SELECTION" IN EB.Reports.getDFields() SETTING BALPOS THEN
        SELECTIONS = EB.Reports.getDRangeAndValue()<BALPOS>         ;*Read the selection passed from dynamic selection
        CHANGE @SM TO ' ' IN SELECTIONS
    END
    LOCATE "PREFIXID" IN EB.Reports.getDFields() SETTING ARRPOS THEN
        PREFIXIDS = EB.Reports.getDRangeAndValue()<ARRPOS>           ;*Read the prefix id passed from dynamic selection
    END

    LOCATE "CUSTOMID" IN EB.Reports.getDFields() SETTING BALPOS THEN
        CUSTOMIDS = EB.Reports.getDRangeAndValue()<BALPOS>          ;*Read the custom id passed from dynamic selection
    END

    LANGUAGE.ID = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>   ;*Read the language used by the user
    IF NOT(LANGUAGE.ID) THEN
        LANGUAGE.ID = 1
    END                                                                 ;*Read the language used by the user

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>the main process</desc>
PROCESS:
*-------
* Read the passed application , selection criteria , prefix id and custom id separated by  '|' symbol
 
    APPLICATIONS.DCOUNT = DCOUNT(APPLICATIONS,'|')
    FOR APPLICATION.COUNT = 1 TO APPLICATIONS.DCOUNT
        APPLICATION = FIELD(APPLICATIONS,'|',APPLICATION.COUNT)
        SELECTION = FIELD(SELECTIONS,'|',APPLICATION.COUNT)
        IF SELECTION NE '' THEN
            SELECTION = "WITH " : SELECTION
        END
        PREFIXID = FIELD(PREFIXIDS,'|',APPLICATION.COUNT)
        CUSTOMID = FIELD(CUSTOMIDS,'|',APPLICATION.COUNT)
        LOCATE APPLICATION IN APPLICATION.LIST<1> SETTING APP.POS THEN
            IF APPLICATION NE '' THEN
                EB.DataAccess.FRead(FN.STANDARD.SELECTION,APPLICATION,R.STANDARD.SELECTION,FV.STANDARD.SELECTION,STANDARD.SELECTION.ERR) ;*Read the standard selection record
                IF NOT(STANDARD.SELECTION.ERR) THEN
                    GOSUB PROCESS.SS.APPLICATION
                END ELSE
                    GOSUB PROCESS.NON.SS.APPLICATION
                END
            END
        END ELSE
            EB.Reports.setEnqError("EB-APPLICATION.NOT.FOUND")
            GOSUB EXIT.SUB
        END
    NEXT APPLICATION.COUNT
    
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.SS.APPLICATION>
*** <desc>process the applications with standard selection</desc>
PROCESS.SS.APPLICATION:
*-------------
 
* Read the description field name and number of the application from standard selection record
  
    STANDARD.SELECTION.SYS.FIELD.NAME = R.STANDARD.SELECTION<EB.SystemTables.StandardSelection.SslSysFieldName>
    STANDARD.SELECTION.SYS.FIELD.NO = R.STANDARD.SELECTION<EB.SystemTables.StandardSelection.SslSysFieldNo>
    
    DESCRIPTION.NO = ''
    FIELD.NAME.DCOUNT = DCOUNT(FIELD.NAME,@FM)
    FOR FIELD.NAME.COUNT = 1 TO FIELD.NAME.DCOUNT
        FIELD.NAME.VALUE = FIELD.NAME<FIELD.NAME.COUNT>
        LOCATE FIELD.NAME.VALUE IN STANDARD.SELECTION.SYS.FIELD.NAME<1,1> SETTING SS.POS THEN    ;* locate the description field name
            DESCRIPTION.NO = STANDARD.SELECTION.SYS.FIELD.NO<1,SS.POS>      ;*get the description field position number
            FIELD.NAME.COUNT = FIELD.NAME.DCOUNT
        END
    NEXT FIELD.NAME.COUNT

    FN.APPLICATION = 'F.':APPLICATION
    FV.APPLICATION = ''
    EB.DataAccess.Opf(FN.APPLICATION ,FV.APPLICATION)

    IF APPLICATION EQ 'SECTOR' THEN
        IF SELECTION EQ '' THEN
	        channelParameterRec = EB.ARC.ChannelParameter.Read('SYSTEM', channelParameterErr )
	        paramSectorCodeList = CHANGE (channelParameterRec<EB.ARC.ChannelParameter.CprExtUserSector>, @VM, ' ')
	        SELECTION = 'WITH @ID EQ ': paramSectorCodeList
        END
    END
    IF APPLICATION EQ 'RELATION' THEN
        IF SELECTION EQ '' THEN
            channelParameterRec = EB.ARC.ChannelParameter.Read('SYSTEM', channelParameterErr )
            BEGIN CASE
                CASE CUSTOMID EQ 'CUSTOMER'  ;*get the Retail relation values
                    LOCATE 'CUSTOMER' IN channelParameterRec<EB.ARC.ChannelParameter.CprRelationType,1> SETTING paramRelCodePos THEN
                        paramRelCodeList = CHANGE (channelParameterRec<EB.ARC.ChannelParameter.CprRelationCode, paramRelCodePos>, @SM, ' ')
                    END
                CASE CUSTOMID EQ 'CORPORATE.USER'  ;*get the Corporate relation values
                    LOCATE 'CORPORATE.USER' IN channelParameterRec<EB.ARC.ChannelParameter.CprRelationType,1> SETTING paramRelCodePos THEN
                        paramRelCodeList = CHANGE (channelParameterRec<EB.ARC.ChannelParameter.CprRelationCode, paramRelCodePos>, @SM, ' ')
                    END
            END CASE
            SELECTION = 'WITH @ID EQ ': paramRelCodeList
        END
    END
    IF APPLICATION EQ 'EB.CHANNEL' THEN
        IF SELECTION EQ '' THEN
            SELECTION = 'WITH CHANNEL.TYPE EQ INTERNET'
        END
    END
    SELECT.CMD = 'SSELECT ':FN.APPLICATION:' BY @ID ':SELECTION     ;*Fetch the records with matched selection criteria
    SELECT.ID = ''
    SELECT.NO = ''
    EB.DataAccess.Readlist(SELECT.CMD,SELECT.ID,'',SELECT.NO,SELECT.ERR)
    FOR SELECT.CNT = 1 TO SELECT.NO
        APPLICATION.ID = SELECT.ID<SELECT.CNT>
        GOSUB SET.OUTPUT.SS.APPLICATION
    NEXT SELECT.CNT

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.NON.SS.APPLICATION>
*** <desc>process the applications without standard selection</desc>
PROCESS.NON.SS.APPLICATION:
*-------------
* Fetch the eb lookup list with the selection passed

    SELECT.CMD = 'SSELECT ':FN.EB.LOOKUP:' BY @ID WITH VIRTUAL.TABLE EQ ':APPLICATION:' ':SELECTION
    SELECT.ID = ''
    SELECT.NO = ''
    EB.DataAccess.Readlist(SELECT.CMD,SELECT.ID,'',SELECT.NO,SELECT.ERR)
    
    FOR SELECT.CNT = 1 TO SELECT.NO
        EB.LOOKUP.ID = SELECT.ID<SELECT.CNT>
        GOSUB SET.OUTPUT.NON.SS.APPLICATION
    NEXT SELECT.CNT

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SET.OUTPUT.SS.APPLICATION>
*** <desc>generate the output for the nofile routine for applications with SS</desc>
SET.OUTPUT.SS.APPLICATION:
*-------------
* Read the application record and fetch the description details

    EB.DataAccess.FRead(FN.APPLICATION,APPLICATION.ID,R.APPLICATION,FV.APPLICATION,APP.ERR)
    IF NOT(APP.ERR) THEN
        BEGIN CASE
            CASE APPLICATION = 'AA.ARRANGEMENT'
                GOSUB PROCESS.AA.ARRANGEMENT
            CASE APPLICATION = 'MNEMONIC.COMPANY'
                GOSUB PROCESS.MNEMONIC.COMPANY
            CASE APPLICATION = 'LIMIT'
                GOSUB PROCESS.LIMIT
            CASE APPLICATION = 'TRANSACTION'
                GOSUB PROCESS.TRANSACTION
            CASE 1
                APPLICATION.DESCRIPTION = R.APPLICATION<DESCRIPTION.NO,LANGUAGE.ID>
        END CASE
        IF NOT(APPLICATION.DESCRIPTION) THEN
            APPLICATION.DESCRIPTION = R.APPLICATION<DESCRIPTION.NO,1>
        END

        BEGIN CASE
            CASE APPLICATION EQ 'LIMIT' AND CUSTOMID EQ 'REFERENCE'
                APPLICATION.ID = INT(FIELD(APPLICATION.ID,'.',2)):'.':FIELD(APPLICATION.ID,'.',3)       ;*Fetches the reference value of respective limit
            CASE APPLICATION EQ 'GENERAL.CHARGE' AND CUSTOMID EQ 'GEN.CHARGE'
                APPLICATION.ID = FIELD(APPLICATION.ID,'.',1)        ;*Fetches the charge id
            CASE APPLICATION EQ 'TAX' AND CUSTOMID EQ 'SEQUENCE'
                APPLICATION.ID = FIELD(APPLICATION.ID,'.',1)        ;*Fetches the tax id
        END CASE

        IF PREFIXID = 'Y' THEN
            BEGIN CASE

                CASE 1
                    APPLICATION.DESCRIPTION = APPLICATION.ID:' - ':APPLICATION.DESCRIPTION          ;*Prefix the description with account number
            END CASE
        END
        IF SELECT.CNT = 1 THEN
            YR.DETAILS<-1> = APPLICATION:'|':APPLICATION.ID:'|':APPLICATION.DESCRIPTION     ;*Amend the application ,application id and description
        END ELSE
            YR.DETAILS<-1> = '|':APPLICATION.ID:'|':APPLICATION.DESCRIPTION
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SET.OUTPUT.SS.APPLICATION>
*** <desc>generate the output for the nofile routine for applications without SS</desc>
SET.OUTPUT.NON.SS.APPLICATION:
* Read the eb lookup record with the id passed

    EB.DataAccess.FRead(FN.EB.LOOKUP,EB.LOOKUP.ID,R.EB.LOOKUP,FV.EB.LOOKUP,EB.LOOKUP.ERR)
    O.DATA.SAVE = EB.Reports.getOData()
    R.EB.LOOKUP = EB.Template.Lookup.Read(EB.LOOKUP.ID, R.EB.LOOKUP.ERR)
    IF NOT(R.EB.LOOKUP.ERR) THEN
        EB.LOOKUP.DESCRIPTION = R.EB.LOOKUP<EB.Template.Lookup.LuDescription,LANGUAGE.ID>       ;*Read the description value of the lookup table specific to language
        EB.LOOKUP.LOOKUP.ID = R.EB.LOOKUP<EB.Template.Lookup.LuLookupId>
        IF NOT(EB.LOOKUP.DESCRIPTION) THEN
            EB.LOOKUP.DESCRIPTION = R.EB.LOOKUP<DESCRIPTION.NO,1>       ;*Read the first description value of the lookup table
        END
        
        IF PREFIXID = 'Y' THEN
            EB.LOOKUP.DESCRIPTION = EB.LOOKUP.LOOKUP.ID:' - ':EB.LOOKUP.DESCRIPTION     ;*Prefix the description with lookup id
        END
        IF SELECT.CNT = 1 THEN
            YR.DETAILS<-1> = APPLICATION:'|':EB.LOOKUP.LOOKUP.ID:'|':EB.LOOKUP.DESCRIPTION      ;*Amend the application ,application id and description
        END ELSE
            YR.DETAILS<-1> = '|':EB.LOOKUP.LOOKUP.ID:'|':EB.LOOKUP.DESCRIPTION
        END

    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.AA.ARRANGEMENT>
*** <desc>process the records for AA.ARRANGEMENT application</desc>
PROCESS.AA.ARRANGEMENT:

    AA.PRODUCT.ID = R.APPLICATION<AA.Framework.ArrangementSim.ArrProduct>
    EB.DataAccess.FRead(FN.AA.PRODUCT,AA.PRODUCT.ID,R.AA.PRODUCT,FV.AA.PRODUCT,AA.PRODUCT.ERR)
    IF NOT(AA.PRODUCT.ERR) THEN
        APPLICATION.DESCRIPTION = R.AA.PRODUCT<AA.ProductManagement.Product.PdtDescription,LANGUAGE.ID>      ;*Read the description value of the product table specific to language
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.MNEMONIC.COMPANY>
*** <desc>process the records for MNEMONIC Company</desc>
PROCESS.MNEMONIC.COMPANY:
*-------------

* Fetch the company list based on mnemonic

    SELECT.CMD = 'SSELECT ':FN.COMPANY:' BY @ID WITH MNEMONIC EQ ':APPLICATION.ID
    SELECT.ID = ''
    SELECT.NO = ''
    EB.DataAccess.Readlist(SELECT.CMD,SELECT.ID,'',SELECT.NO,SELECT.ERR)

    COMPANY.ID = SELECT.ID
    EB.DataAccess.FRead(FN.COMPANY,COMPANY.ID,R.COMPANY,FV.COMPANY,COMPANY.ERR)
    IF NOT(COMPANY.ERR) THEN
        APPLICATION.DESCRIPTION = R.COMPANY<ST.CompanyCreation.Company.EbComCompanyName,LANGUAGE.ID>
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.LIMIT>
*** <desc>process the records for LIMIT application</desc>
PROCESS.LIMIT:
*-------------

    LIMIT.REFERENCE.ID = INT(FIELD(APPLICATION.ID,'.',2))
    EB.DataAccess.FRead(FN.LIMIT.REFERENCE,LIMIT.REFERENCE.ID,R.LIMIT.REFERENCE,FV.LIMIT.REFERENCE,LIMIT.ERR)
    IF NOT(LIMIT.ERR) THEN
        LIMIT.REFERENCE.DESCRIPTION = R.LIMIT.REFERENCE<LI.Config.LimitReference.RefDescription,LANGUAGE.ID>          ;*Read the description value of the limit reference specific to language
        APPLICATION.DESCRIPTION = LIMIT.REFERENCE.DESCRIPTION
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.TRANSACTION>
*** <desc>process the records for TRANSACTION application</desc>
PROCESS.TRANSACTION:
*-------------

* Locate the narrative field number in standard selection

    FIELD.NAME.VALUE = 'NARRATIVE'
    LOCATE FIELD.NAME.VALUE IN STANDARD.SELECTION.SYS.FIELD.NAME<1,1> SETTING SS.POS THEN
        DESCRIPTION.NO = STANDARD.SELECTION.SYS.FIELD.NO<1,SS.POS>
    END

    APPLICATION.DESCRIPTION = R.APPLICATION<DESCRIPTION.NO,LANGUAGE.ID>

RETURN
*** </region>
*** <region name= EXIT.SUB>
*** <desc>exit from the routine</desc>
*-----------------------------------------------------------------------------
EXIT.SUB:

RETURN TO EXIT.SUB
RETURN
*** </region>
*-----------------------------------------------------------------------------
END


