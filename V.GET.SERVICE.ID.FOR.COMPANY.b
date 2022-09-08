* @ValidationCode : MjoxNjMyNjQxMzc0OkNwMTI1MjoxNTUzMTYxNDg1MDQ5OnBzdmlqaTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDMuMjAxOTAyMDEtMDgwMDotMTotMQ==
* @ValidationInfo : Timestamp         : 21 Mar 2019 15:14:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : psviji
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.20190201-0800
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE EB.Service
SUBROUTINE V.GET.SERVICE.ID.FOR.COMPANY
    
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    
    currentAppln = EB.SystemTables.getApplication()
    IF currentAppln NE 'TSA.SERVICE' THEN RETURN  ;* only for TSA.SERVICE application request via TRACE version
     
    tsaServiceId = EB.SystemTables.getComi()
    IF tsaServiceId EQ 'T24.TRACEABILITY.SERVICE' THEN         ;* only for this service
        compMne = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialMne)      ;* find current financial company mnemonic
        tsaServiceId = compMne:'/':tsaServiceId                 ;* prefix with TSA.SERVICE id
        EB.SystemTables.setComi(tsaServiceId)              ;* set COMI with changed ID
    END
    
RETURN
