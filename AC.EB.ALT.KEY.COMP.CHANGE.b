* @ValidationCode : MjoxMDQ0MjYxMjI6Q3AxMjUyOjE1NjEzNzA0Mzg0MTk6c3JhdmlrdW1hcjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDYuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 24 Jun 2019 15:30:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201906.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-83</Rating>
*-----------------------------------------------------------------------------
$PACKAGE MC.CompanyCreation
SUBROUTINE AC.EB.ALT.KEY.COMP.CHANGE(ACCOUNT.ID, RTN.RELATED.IDS, RTN.RELATED.FILE)

* Routine flow
****   READ EB.ALTERNATE.KEY for "CARD.ISSUE"
****   IF 'NO' record for CARD.ISSUE", nothing to do, exit
****   Loop through each ALT.KEY.FIELD field value of EB.ALTERNATE.KEY record
****     Form the name of concat file as CARD.ISSUE.<ALT.KEY.FIELD>
****     CALL AC.GET.CARD.ISSUE to get the list of card issues for the account
****     Loop through each CARD.ISSUE.LIST
****        Read CARD.ISSUE with the CARD.ISSUE.ID obtianed from the list
****        Locate ALT.KEY.FIELD given in EB.ALTERNATE.KEY in SS<SYS.FIELD.NAME, 1>
****        Then get the value of the field from R.CARD.ISSUE
****        Read F.CARD.ISSUE<ALT.KEY.FIELD> file with the id as field value obtained in the above step
****        Modify the company.code to EB.CC.COMPANY.TO and write the record
* Routine flow
*---------------------------------------------------------------------------------------------------------------------------
* Modification history
*
* 27/05/13 - Defect: 681096 / Task: 687049
*            New routine to change the company code in EB.ALTERNATE.KEY concat file defined for CARD.ISSUE
*            This would be attached to the "ACCOUNT" record of STANDARD.MAPPING as a routine in the field SYS.SUB.TABLE
*
* 05/11/14 - Defect: 1140498 / Task: 1159448
*            On using EB.COMPANY.CHANGE to convert an account, the concat table related to
*            EB.ALTERNATE.KEY is not converted properly if the EB.ALTERNATIVE.KEY is based on LOCAL.REF.FIELD.
*
* 24/06/19 - Enhancement 3187081 / Task 3187082
*			 Code changes have been made to check product installation for CQ.
*
*---------------------------------------------------------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING MC.CompanyCreation
    $USING CQ.Cards
    $USING EB.DataAccess
    $USING EB.API
    $USING EB.LocalReferences
    $USING ST.CompanyCreation

    IS.CQ.INSTALLED = ''
    EB.API.ProductIsInCompany('CQ', IS.CQ.INSTALLED)
    
    IF NOT(IS.CQ.INSTALLED) THEN   ;* Check whether the product 'CQ' is installed
        RETURN   ;* Terminate from further process
    END
    
MAIN.PROCESS:

    GOSUB INITIALISE

    IF NOT(RET.ERROR) THEN
        GOSUB PROCESS.PARA
    END

RETURN

INITIALISE:

    RET.ERROR = ''
    ACCT.ID = ACCOUNT.ID      ;* take a copy of incomming argument
    RTN.RELATED.IDS=''
    RTN.RELATED.FILE=''

    APPLN.NAME = "CARD.ISSUE"
    READ.ERR1 = ""
    R.EB.ALTERNATE.KEY = ""
    R.EB.ALTERNATE.KEY = EB.SystemTables.AlternateKey.CacheRead(APPLN.NAME, RET.ERROR)

    IF NOT(RET.ERROR) THEN
        EB.COMPANY.CHANGE.ID = MC.CompanyCreation.getEbCompChgId()     ;* common which holds the currently processing EB.COMPANY.CHANGE id
        R.EB.COMPANY.CHANGE = ''
        READ.ERR4 = ''
        R.EB.COMPANY.CHANGE = MC.CompanyCreation.EbCompanyChange.CacheRead(EB.COMPANY.CHANGE.ID, READ.ERR4)

        CQ.Cards.AcGetCardIssue(CARD.ISSUE.LIST, ACCT.ID)    ;* get the list of cards issued for the incomming account id
    END

RETURN

PROCESS.PARA:

    ALT.KEY.FLD.CNT = DCOUNT(R.EB.ALTERNATE.KEY<EB.SystemTables.AlternateKey.AltKeyAltKeyField>, @VM) ;* Loop through each alternate key field name defined in EB.ALTERNATE.KEY record
    FOR FLD.CNT = 1 TO ALT.KEY.FLD.CNT

        IF R.EB.ALTERNATE.KEY<EB.SystemTables.AlternateKey.AltKeyConcatType, FLD.CNT> <> 'SYSTEM' THEN ;* If concat records are not maintained by system, do nothing
            CONTINUE          ;* go to next alternate field
        END
        ALT.KEY.FLD.NAME = R.EB.ALTERNATE.KEY<EB.SystemTables.AlternateKey.AltKeyAltKeyField, FLD.CNT>
        FN.CONCAT.FILE.NAME = 'F.':APPLN.NAME:'.':ALT.KEY.FLD.NAME
        F.CONCAT.FILE.NAME = ''

        GOSUB PROCESS.CARD.ISSUE.LIST
    NEXT FLD.CNT

RETURN

PROCESS.CARD.ISSUE.LIST:

    CARD.ISSUE.CNT = DCOUNT(CARD.ISSUE.LIST, @FM)
    FOR CARD.CNT = 1 TO CARD.ISSUE.CNT

        CARD.ISSUE.ID = CARD.ISSUE.LIST<CARD.CNT>
        R.CARD.ISSUE = ""
        READ.ERR2 = ""
        R.CARD.ISSUE = CQ.Cards.CardIssue.CacheRead(CARD.ISSUE.ID, READ.ERR2)

        IF NOT(READ.ERR2) THEN
            GOSUB PROCESS.COMPANY.CHANGE
        END
    NEXT CARD.CNT

RETURN

PROCESS.COMPANY.CHANGE:

    SS.ID = "CARD.ISSUE"
    R.STANDARD.SELECTION = ""
    EB.API.GetStandardSelectionDets(SS.ID, R.STANDARD.SELECTION)
    EB.API.FieldNamesToNumbers(ALT.KEY.FLD.NAME, R.STANDARD.SELECTION, FLD.NO, YAF, YAV, YAS, DATA.TYPE, ERR.MSG)

    IF ERR.MSG THEN
        EB.LocalReferences.GetLocRef(SS.ID,ALT.KEY.FLD.NAME,FLD.NO)     ;* Get Local ref field position
        FLD.VALUE = R.CARD.ISSUE<CQ.Cards.CardIssue.CardIsLocalRef,FLD.NO>  ;* Get local ref field value
    END ELSE
        FLD.VALUE = R.CARD.ISSUE<FLD.NO, 1, 1>    ;* Always take the 1st MV field value
    END
    FLD.VALUE = FLD.VALUE[" ",1,1]      ;* ignore anything after first space

    IF FLD.VALUE THEN
        R.CONCAT.REC = ""
        READ.ERR3 = ""
        CONCAT.WRITE = ""
        EB.DataAccess.FReadu(FN.CONCAT.FILE.NAME, FLD.VALUE, R.CONCAT.REC, F.CONCAT.FILE.NAME, READ.ERR3, '')         ;* read the conact record with lock

        IF NOT(READ.ERR3) THEN

            IF R.EB.COMPANY.CHANGE<MC.CompanyCreation.EbCompanyChange.EbCcApplication> = "ACCOUNT" THEN
                R.CONCAT.REC = R.EB.COMPANY.CHANGE<MC.CompanyCreation.EbCompanyChange.EbCcCompanyTo>:'*':FIELD(R.CONCAT.REC,"*",2,99)         ;* replace company code with the new comp code
                CONCAT.WRITE = '1'
                EB.DataAccess.FWrite(FN.CONCAT.FILE.NAME, FLD.VALUE, R.CONCAT.REC)      ;* write out the modified record
            END
        END

        IF NOT(CONCAT.WRITE) THEN
            EB.DataAccess.FRelease(FN.CONCAT.FILE.NAME, FLD.VALUE, F.CONCAT.FILE.NAME)
        END
    END

RETURN

END
