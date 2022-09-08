* @ValidationCode : MjoxODM5MTAyNDU5OkNwMTI1MjoxNTQ5NDU0NzIyNzkzOnJhdmluYXNoOjEwOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTAyLjIwMTgxMjMxLTA4NDI6MzY6MzY=
* @ValidationInfo : Timestamp         : 06 Feb 2019 17:35:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ravinash
* @ValidationInfo : Nb tests success  : 10
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/36 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201902.20181231-0842
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE EB.API
SUBROUTINE MNEMONIC.CALCULATION(FILE.CLASSIFICATION, Y.FILE.NAME, MNEMONIC, CLASS.OK)
*-----------------------------------------------------------------------------
*   Incoming : FILE.CLASSIFICATION , Y.FILE.NAME (File name as incoming)
*
*   Outgoing : MNEMONIC , CLASS.OK
*-----------------------------------------------------------------------------
* Modification History :
*
* 04/02/2019 - Enhancement 2822523 / Task 2976095
*            - Mnemonic Calculation based on file classification and File Name
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING ST.CompanyCreation
*-----------------------------------------------------------------------------
    MNEMONIC = "" ;* Initially Mnemonic is null
    CLASS.OK = 1 ;* Class.OK set to 1
    BEGIN CASE
        CASE FILE.CLASSIFICATION = "INT" ;* If file classification is INT type
            MNEMONIC = ""
        CASE FILE.CLASSIFICATION = "CUS" ;* If file classification is CUS type
            MNEMONIC = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerMnemonic)
        CASE FILE.CLASSIFICATION = "FIN" ;* If file classification is FIN type
            MNEMONIC = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialMne)
        CASE FILE.CLASSIFICATION = "FTF" ;* If file classification is FTF type
            MNEMONIC = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinanFinanMne)
        CASE FILE.CLASSIFICATION = "CCY" ;* If file classification is CCY type
            MNEMONIC = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCurrencyMnemonic)
        CASE FILE.CLASSIFICATION = "NOS" ;* If file classification is NOS type
            MNEMONIC = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComNostroMnemonic)
        CASE FILE.CLASSIFICATION = "CST" ;* If file classification is CST type
            MNEMONIC = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComDefaultCustMne)
            IF EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComSpclCustFile) THEN
                SUBFIELD = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComSpclCustFile)
                LOCATE Y.FILE.NAME IN SUBFIELD<1,1> SETTING POS THEN
                    MNEMONIC = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComSpclCustMne)<1,POS>
                END
            END
        CASE FILE.CLASSIFICATION = "FTD" ;* If file classification is FTD type
            MNEMONIC=EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComDefaultFinanMne)
            IF EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComSpclFinFile) THEN
                SUBFIELD = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComSpclFinFile)
                LOCATE Y.FILE.NAME IN SUBFIELD<1,1> SETTING POS THEN
                    MNEMONIC = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComSpclFinMne)<1,POS>
                END
            END
        CASE FILE.CLASSIFICATION = "FRP" ;* If file classification is FRP type
            MNEMONIC = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic)
        CASE 1
            CLASS.OK = 0 ;* Default case Class.OK set to 0
    END CASE

END
