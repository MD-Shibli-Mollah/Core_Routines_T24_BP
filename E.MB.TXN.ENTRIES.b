* @ValidationCode : MjoyMTQ0MTc3NzkzOmNwMTI1MjoxNTk5Njc3MzA4NTM3OnNhaWt1bWFyLm1ha2tlbmE6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6LTE6LTE=
* @ValidationInfo : Timestamp         : 10 Sep 2020 00:18:28
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-80</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.MB.TXN.ENTRIES(ID.LIST)
*-----------------------------------------------------------------------------
*
* Subroutine type : Subroutine
* Attached to     : STANDARD.SELECTION record NOFILE.TXN.ENTRIES
* Purpose         : Returns STMT.ENTRY, CATEG.ENTRY, SPEC.ENTRY id's using the API EB.GET.CONTRACT.ENTRIES
* @author         : madhusudananp@temenos.com
*
*-----------------------------------------------------------------------------
*                M O D I F I C A T I O N   H I S T O R Y
*-----------------------------------------------------------------------------
*
* 12/02/2013 - Defect - 584034 / Task - 586558
*              Enquiry doesn't display the entries properly when some of the
*              entries are archived.
*
* 27/06/14 - Defect 984095 / Task 1041603
*            When the entry is generated for Accounting Company, company mnemonic of the parent
*            company will be appended with Entry ids. Hence check whether the company code in Entry
*            is Accounting Company. If so get the company mnemonic from R.COMPANY as the enquiry will
*            be executed from the Parent company.
*
* 08/07/14 - Defect 1051313 / Task 1051777
*            The insert file for COMPANY record has been included to avoid warnings during compilation
*
* 09/07/14 - Defect 1051313 / Task 1052476
*            In PROCESS.SPEC.ENTRIES paragraph the company mnemonic has been wrongly fetched from the
*            categ entry instead of the spec entry. Changes done to get the company mnemonic from the
*            spec entry.
*
* 11/03/15 - Defect 1247350 Task 1278471
*            Do not do direct read to ECB use the API so that the entries from EB.CONTRACT.ENTRIES
*            will also be included.
*
* 04/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 09/09/20 - Enhancement 3932648 / Task 3952625
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*-----------------------------------------------------------------------------
*
    $USING EB.SystemTables
    $USING EB.Reports
    $USING BF.ConBalanceUpdates
    $USING ST.CompanyCreation
    $USING AC.API
*
*---------------------------------------------
*
    GOSUB INITIALISE
    GOSUB GET.ENTRIES

RETURN
*
*---------------------------------------------
INITIALISE:
***********
* Initalise variables.

    LOCATE 'TRANSACTION.REF' IN EB.Reports.getDFields()<1> SETTING ID.POS ELSE
        NULL
    END
    TXN.REF = EB.Reports.getDRangeAndValue()<ID.POS>
    R.EB.CONT.BAL = BF.ConBalanceUpdates.tableEbContractBalances(TXN.REF,R.CONT.BAL.ERR)

    ID.LIST = ""
    ENTRY.TYPE.LIST = "S":@FM:"R":@FM:"C" ;* Form the entry type list.

RETURN
*-----------------------------------------------------------
GET.ENTRIES:
************
* Loop through all the entry types.
*
    LOOP
        REMOVE ENTRY.TYPE FROM ENTRY.TYPE.LIST SETTING POS
    WHILE ENTRY.TYPE:POS
        ENTRY.LIST = ''
        AC.API.EbGetContractEntries(TXN.REF , ENTRY.TYPE , "" , "" , ENTRY.LIST) ;* Use the API.
        IF ENTRY.LIST THEN
            NO.OF.ENTRIES  = DCOUNT(ENTRY.LIST,@FM)
            FOR ENT.CNT = 1 TO NO.OF.ENTRIES
                ENTRY.ID = FIELD(ENTRY.LIST<ENT.CNT>,'/',1)
                CO.MNE   = FIELD(ENTRY.LIST<ENT.CNT>,'/',2)
                GOSUB CHECK.MNEMONIC
                ID.LIST<-1> = ENTRY.TYPE:ENTRY.ID:'*':CO.MNE
            NEXT ENT.CNT
        END
    REPEAT

RETURN
*-----------------------------------------------------------
CHECK.MNEMONIC:
*
* Check the company mnemonic. If the mnemonic of company not the currently logged in company then
* check entry company code is Accounting Company. If so get the parent company mnemonic.
*
    IF CO.MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic) AND EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComParentCompany) = "" THEN
        RETURN   ;* mnemonic is for the currently logged in business company
    END

    IF NUM(CO.MNE) THEN       ;* some category entries seem to have a session number as suffix
        CO.ID = R.EB.CONT.BAL<BF.ConBalanceUpdates.EbContractBalances.EcbCoCode>        ;* set it to the company of the contract
        IF CO.ID = EB.SystemTables.getIdCompany() THEN
            CO.MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic)
        END ELSE
            GOSUB GET.MNE
        END
    END ELSE        ;* check to see if mnemonic is for an accounting company
        CO.ID = ST.CompanyCreation.MnemonicCompany.CacheRead(CO.MNE, ER)
* Before incorporation : CALL CACHE.READ("F.MNEMONIC.COMPANY",CO.MNE,CO.ID,ER)
        GOSUB GET.MNE
    END

RETURN

*---------------------------------------------------------------
*
GET.MNE:
*
* If the entry company code is Accounting Company, then get the Parent company to fetch the mnemonic.
*
    R.COMP = ST.CompanyCreation.Company.CacheRead(CO.ID, ER)
* Before incorporation : CALL CACHE.READ("F.COMPANY",CO.ID,R.COMP,ER)
    IF R.COMP<ST.CompanyCreation.Company.EbComParentCompany> THEN  ;* Will be updated only for Accounting Company
        CO.ID = R.COMP<ST.CompanyCreation.Company.EbComParentCompany>
        R.COMP = ST.CompanyCreation.Company.CacheRead(CO.ID, ER)
* Before incorporation : CALL CACHE.READ("F.COMPANY",CO.ID,R.COMP,ER)
    END
    CO.MNE = R.COMP<ST.CompanyCreation.Company.EbComMnemonic>

RETURN

*------------------------------------------------------------------
END
