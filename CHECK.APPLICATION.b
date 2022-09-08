* @ValidationCode : MjotMzIzNTA3MjkwOkNwMTI1MjoxNTQyNzE2ODI3MDc1OnJhdmluYXNoOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTEuMjAxODEwMjItMTQwNjotMTotMQ==
* @ValidationInfo : Timestamp         : 20 Nov 2018 17:57:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ravinash
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 34 22/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>16</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.TransactionControl
SUBROUTINE CHECK.APPLICATION
*-----------------------------------------------------------------------------
* Incoming  : COMI
*             N.B. If 'COMI' = 'ENRICH' then routine will assign
*             enrichments to 'T.ENRI'.
*
* Outgoing  : COMI.ENRI = Application description
*             E         = Any error messages
*
*-----------------------------------------------------------------------------
* PIF GB9300151; New module of 'MD' added (pete 25.01.93).
*
* 25/02/93 - GB9201157
*            Addition of new module 'DG' for DISAGIO.
*
* 22/11/94 - GB9401245
*            Add new module SL - Syndicated Loans
*
* 19/09/94 - GB9401273
*            Amend to allow enrichment to be passed back for any
*            application (previously hard-coded just for COMPANY)
*
* 11/09/95 - GB9501021
*            Overdue Processing Module
*            Add a new product PD for Payment Due module
*
* 26/09/95 - GB9501087
*                  Management Information Module
*                  Add a new product MI for Management Information module
* 25/04/96 - GB9600519
*            Image Processing Module Added.
*
* 24/09/97 - GB9701088
*            TK - Development Tool Kit added
*
* 04/02/98 - GB9800026
*            Add product of NR for Nostro Reconciliation
*
* 12/02/98 - GB9800126 & GB9800138
*            Add EU as a new product for the EURO
*            and AT for ATM
* 21.04.98 - GB9800002
*            Add BA (Branch Automation- GBS) AS A valid product
*
* 30/04/98 - GB9800429
*            Add Repos as a valid product - RP
*
* 21/08/98 - GB9801071
*            Add GAC as a valid product - GA
*
* 02/10/98 - GB9801223
*            Add HB and OF products
*
* 08/02/00 - GB0000139
*            Replace HB with IB add PC
*
* 14/04/00 - GB0001070
*            Add a new product OO OFS ONLINE
*
* 11/05/00 - GB0001210
*            Add a new product CM Conformation matching
*
* 08/06/00 - GB0001411
*            Correct conformation to confirmation
*
* 17/08/00 - GB0002081
*            Add new product DX for Derivatives
*
* 06/12/00 - GB0003163
*            Multi Book accounting
*
* 23/01/01 - GB0100149
*            Add new product 'BL' for Bills.
*
* 05/04/01 - GB0100964
*            Add new product 'AM' for Asset Management.
*
* 17/05/01 - GB0101173
*            Add new product 'AZ' for All in one account
*
*24/09/01 - GLOBUS_EN_10000164
*           Add new product 'DM' for Document Management
*25/09/01 - GLOBUS_EN_10000178
*           Add new product 'EM' for eMerge
* 25/07/01 - GLOBUS_EN_10000174
*            Add a new product CI Commissions for intermediaries
* 13/02/02 - EN_10000383
*            Add new product 'CQ' for Collateralization of Cheques.
*19/02/02 - GLOBUS_EN_10000478
*           Added product code SP for straight through processing
*20/02/02 - GLOBUS_EN_10000416
*           Added product code TX for TAX ENGINE
*07/05/02 - GLOBUS_EN_10000601
*           Added a new product MF
*
* 02/09/02 - GLOBUS_EN_10000971
*          Conversion Of all Error Messages to Error Codes
*
*09/09/02 - GLOBUS_EN_10001207
*           Added a new product TR
*
*24/12/02 - GLOBUS_EN_10001546
*           Added a new product CF
*
* 14/02/03 - EN_10001606
*           Add application description for NDF
*
* 31/03/03 - GLOBUS_EN_10001502
*            Add Global Processing as a new product
*
* 30/05/03 - GLOBUS_EN_10001720
*            Added new product LA.
*
* 13/06/03 - EN_10001867
*            Added New Product IA - International Accounting Standards.
*
* 25/09/03 - EN_10002016
*            Added new product Direct Debits (DD)
*
* 31/10/03 - BG_100005563
*            Added new product PROCESS WORKFLOW(PW)
*
* 02/11/03 - BG_10005573
*            Add new product NS - Non-Stop Processing
*
* 09/12/03 - GLOBUS_BG_10005775
*            Must now work with single valued PRODUCT field (FILE.CONTROL)
*
* 19/01/04 - EN_100002136
*            Added new product SA - Sales Administration
*
* 22/11/04 - BG_100007650
*            Add new product - Multiple Application Server
*
* 10/01/05 - EN_10002391
*            New Product ET - EUROPEAN Savings Directive.
*
*
* 03/05/06 - GLOBUS_EN_10002884
*            Added new product BR Branch resilience
*
* 22/05/06 - EN_10002860/BG_100011302
*            New Product - AA - Account Arrangement
*
* 07/07/06 - CI_10042463
*            Included SEAT product in Check Application.
*
* 28/07/06 - EN_10002851 - CRM Phase 1
*            Changing 'CR' to hold the enrichment for CRM.
*            Ref:SAR-2005-12-06-0005
*
* 22/08/06 - EN_10003051 - EN10003177
*            Removal of MB product code.
*            The MB product is to be made redundant and the functionality incorporated
*            in to MC (multi company). Remove the MB product code and its description.
*
* 15/09/06 - BG_100012044
*            Product 'FF' removed.
*
* 25/09/06 - BG_100012110
*            The product 'CR' duplicated in the Y.APP.LIST causing syncronishing
*            problems with Y.APP.DESC.
*
* 06/12/06 - EN_10003145
*            New product DW
*            Ref: SAR-2006-09-19-0007
*
* 09/04/07 - BG_100013562
*            Include new AA product codes
*
* 12/10/07 - BG_100015422
*            New product code AP for AA Proxy Services introduced
*
* 15/10/07 - EN_10003540
*            New product T-VERIFY
*
* 12/11/07 - CI_10052419  TTS0754801
*            Chaning the error code to give meaningful error msg.
*
* 28/12/07 - BG_100016475
*            Add JF as a valid product for internal use
* 19/05/08 - BG_100018486
*            New Product "SY" Structured Products
*
* 16/10/08 - EN_10003888
*            Removal of non standard APIs.
*            'TR' is made OB.
*
* 26/01/09 - BG_100021770 - aleggett@temenos.com
*            Product 'SB' added - Structured Products Builder.  Ref: TTS0805017
*
* 06/09/09 - EN_10004326
*            Added a new product AS - AA Savings
*
* 15/10/09 - EN_10004399
*            Added a new product WR - Wealth Management Reporting
*
* 04/01/10 - BG_100026455
*            Added a new product BE- Business Events
*
* 08/02/10 - RTC 17099(SI)
*            Rebrand AM as Wealth Management
*
* 09/07/10 - Enhancement:18647, Task:65935
*            Online Valuation Processing
*
* 28/07/10 - Task 71786
*            new WS product
*
*
* 03/08/10 - Task:68638 // Enhancement:63652
*            Accounts product line is enhanced to allow creation of savings/current
*            account and to do some basic activities on it.
*            Add a new product AR-Retail arrangement account.
*
* 25/10/10 - Enhancement:41587 / Task:82577
*            Added  a new product MO - MOBILE SERVICES
*
* 07/01/11 - Enhancement:84264 / Task:122412
*            New Products Added:'OP'-ARC Origination & 'SG'-Service Level Agreement.
* 28/12/10- Enhancement:56310
*          - Task # 120636
*             Product Bundling Product line is enhanced to allow creation of Bundling with
*             other product
*
* 21/01/11 - Task: 132934
*            Dev coding for Unable to add BM product to SPF
*
* 08/02/11 - Task: 149352
*            Merge JF product into EB. JF_Foundation component becomes
*            EB_AgentFramework.
*
* 14/02/11 - Task 152834
*            Add new PV Provisioning Module
*
* 02/03/11 - Task 152788
*             Change the description of "AR" product.
*
* 21/06/11 - Task 202676
*            Add the new module RS -Retail sweeping.
*
* 06/07/11 - Enhancement - 195992 / Task - 199622
*            Add the new Module PO - Cash pooling
*
* 14/10/11 - Task 287131
*            Adding new Module NE - NEO
*
* 06/08/11 - Task 234844
*            Added a new module VR.
*
* 25/11/11 - Task 314933/ Defect 314448
*            Prototype Development
*            Added OR - Origination Product
*
* 30/03/12 - Task 369300
*            Adding the new product SF = SWIFT LICENSING.
*
* 31/05/12 - Task 414340
*            Removal of VR and Inclusion VS.
*
* 13/06/12 - Task 387669
*            Inclusion of the new product VP.
*
* 12/04/12 - Enhancement 334398 / Task 369373
*            Added a new module FA - FATCA (Foreign Account Tax Compliance Act)
*
* 21/06/12 - Task 374214
*            Adding VL.
*
* 13/07/12 - Task:443021 / Defect:428817
*            Concept of adding the products and descriptions in variables like Y.APP.LIST & Y.APP.DESC is not necessary.
*            Releasing EB.PRODUCT and having valid license code of the product is sufficient.
*            This routine will check if a product is installed (in SPF) and provides product description from EB.PRODUCT as its enrichment.
*
* 16/04/13 - Task - 651187 / Defect - 622681
*            The Variable E should not to be set incase of enrichment request.
*
* 10/03/16 - Task - 1659318 / Defect - 1357356
*            Added EB.PRODUCT check for the products added newly to SPF
*
* 24/10/18 - Enhancement 2822523 / Task 2826350
*          - Incorporation of EB_TransactionControl component
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SPF
    $INSERT I_F.EB.PRODUCT
*
*Lengthy product lists and descriptions in variables Y.APP.LIST & Y.APP.DESC is removed

    GOSUB INITIALISE
    GOSUB PROCESS
RETURN
*----------------------------------------------------------------------------------------------------------------
INITIALISE:
    COMI.ENRI = ''  ;*variable to hold the enrichments
    Y.APPL.LIST = '' ;*variable to hold the product list
    Y.APPL.LIST = R.SPF.SYSTEM<SPF.PRODUCTS>      ;*Get the product list from the common R.SPF.SYSTEM

RETURN
*-------------------------------------------------------------------------------------------------------------
PROCESS:
    IF COMI <> "ENRICH" THEN  ;* Looking out for just enrichments or to check product installed or not?
        Y.APPLICATION = COMI  ;* Get product code
        GOSUB CHECK.PRODUCT.INSTALLED   ;* check if product is installed
        COMI.ENRI = Y.ENRICH  ;* set enrichment
    END ELSE        ;* To fetch only enrichments
        YAV = DCOUNT(R.NEW(AF), @VM)     ;* Product codes count
        FOR YI = 1 TO YAV
            Y.APPLICATION = R.NEW(AF) < 1, YI >   ;* Get each product code
            GOSUB CHECK.PRODUCT.INSTALLED         ;* check if product is installed
            E = '' ;* No need to set E for the request to get ENRICHMENT
            IF Y.ENRICH THEN
                LOCATE AF : "." : YI IN T.FIELDNO < 1 > SETTING YX ELSE
                    LOCATE AF IN T.FIELDNO<1> SETTING YX ELSE YX = 0
                END
                IF YX <> 0 THEN
                    T.ENRI < YX > = Y.ENRICH    ;*set enrichments for the valid products
                END
            END
        NEXT YI
    END
RETURN
*------------------------------------------------------------------------------------------
CHECK.PRODUCT.INSTALLED:
    E = ''
    Y.ENRICH = ''
    LOCATE Y.APPLICATION IN Y.APPL.LIST < 1, 1 > SETTING YX THEN ;* Is product installed in SPF?
        CALL CACHE.DBR("F.EB.PRODUCT",EB.PRD.DESCRIPTION,Y.APPLICATION,Y.ENRICH) ;*Get Description from EB.PRODUCT
    END ELSE
        IF APPLICATION EQ 'SPF' AND COMI NE 'ENRICH' THEN    ;* for the new product entered in SPF>PRODUCT field
            CALL CACHE.DBR("F.EB.PRODUCT",EB.PRD.DESCRIPTION,Y.APPLICATION,Y.ENRICH) ;* check for valid EB.PRODUCT entry and get enrichment
        END
    END
    IF NOT(Y.ENRICH) THEN
        E ="EB.RTN.INVALID.APP.CODE.ENT" ;* if not a valid product
    END

RETURN
*-------------------------------------------------------------------------------------------
END

