* @ValidationCode : MjotMTQwODQzOTY3NjpDcDEyNTI6MTU3NzcwMDcxNjMyNjpydXNoYTo2OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEyLjIwMTkxMTA4LTA0NDY6MTQ2OjEyNQ==
* @ValidationInfo : Timestamp         : 30 Dec 2019 15:41:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rusha
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 125/146 (85.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201912.20191108-0446
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*---------------------------------------------------------------------------
* <Rating>192</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AB.ModelBank
SUBROUTINE E.AA.BUNDLE.STMT.ENT.LIST(BALANCE.ARRAY)

*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
* This routine returns the statement entry id's
*
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Arguments>
*** <desc> </desc>
*
* Parameters:
*
* Input
*
*** </region >
*-----------------------------------------------------------------------------
*
*** <region name= Modification history>
***
* 29/Sep/2015 - Defect 1473293
*               Task 1483007
*               Hot coded propert class is replaced with the property used in the arrangement.
*
* 25/05/2016  - Task : 1742520
*               Defect : 1732488
*               When bundle is closed then enquiry shouldn't display the transaction which is inputted after the close date
*
*
* 13/06/17 - Enhancement : 2148615
*            Task : 2231452
*            Value markers in BunArrangements in PRODUCT.BUNDLE is changed to SM
*
* 03/08/18 - Enhancement : 2688557
*            Task : 2688560
*            Enhanced to support each account and get statement entry list for TR/SA/CS accounts
*
*  17/08/18 -        Task : 2772062
*             Enhancement : 2688557
*             To fetch the statement entry ids for accounts in other company
*
* 21/12/19 - Task : 3502204
*            Defect : 3499254
*            For the Bundle Arrangement of Product MASTER.ACCOUNT, Arrangement id picked from the selection
*            Which is having XX along with the Bundle Arrangement
*
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Inserts used by the routine>
***

    $USING AA.Framework
    $USING AA.ProductBundle
    $USING EB.API
    $USING AA.ProductFramework
    $USING AC.ModelBank
    $USING EB.SystemTables
    $USING EB.Reports
    $USING ST.CompanyCreation

*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Main Process>
***

    GOSUB INITIALISE
    GOSUB GET.ARRANGEMENT.DETAILS
    GOSUB PROCESS
    IF BALANCE.ARRAY EQ "" THEN
        BALANCE.ARRAY = "NULL"
    END
    
    
RETURN

*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Initialise local variables>
***
INITIALISE:

    BALANCE.ARRAY = ''
    TEMP.ACC.ID = ''

    F.STMT.ENTRY.LOC = ''

    ARR.STATUS = ''
    LINK.DATES = ''
    CLOSE.DATE = ''

RETURN

*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Get bundle arrangement id and dates>
***
GET.ARRANGEMENT.DETAILS:

    LOCATE 'BUNDLE.ARRANGEMENT' IN EB.Reports.getDFields()<1> SETTING ARRPOS THEN
        BUNDLE.ARR.ID = EB.Reports.getDRangeAndValue()<ARRPOS>
        AccountId = FIELD(BUNDLE.ARR.ID,'-',2)
        BUNDLE.ARR.ID = FIELD(BUNDLE.ARR.ID,'-',1)
        IF BUNDLE.ARR.ID[1,2] EQ 'XX' THEN
            BUNDLE.ARR.ID = BUNDLE.ARR.ID[3,LEN(BUNDLE.ARR.ID)]
        END
        CompanyMnemonic = FIELD(BUNDLE.ARR.ID,"/",2)
    END
    
    IF CompanyMnemonic THEN
        GOSUB SaveCompany
    END
    
    AA.Framework.GetArrangement(BUNDLE.ARR.ID, R.ARRANGEMENT, ARR.ERROR)  ;* Arrangement record to pick the Property list
    CHECK.DATE = R.ARRANGEMENT<AA.Framework.Arrangement.ArrStartDate> ;* For enquiry, always start from start date of the contract

    ARR.STATUS = R.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus> ;* Get the bundle arrangement status
    IF ARR.STATUS EQ "CLOSE" THEN       ;* Get the bundle close date only when arrangement status is "CLOSE"
        LINK.DATES = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkDate>        ;* Get all link dates to find the close date
        CLOSE.DATE = LINK.DATES<1,DCOUNT(LINK.DATES,@VM)>    ;* Get the last multivalue link date, since this date is bundle close date
    END
    
    DATE.RECORD = AA.Framework.ArrangementDatedXref.Read(FIELD(BUNDLE.ARR.ID,"/",1), RET.ERR)
        
    GOSUB GET.FROM.TO.DATE   ;* to get FromDate and ToDate from BOOKING.DATE field based on the logical operand field
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Main Process>
***
PROCESS:
    
    BEGIN CASE
    
        CASE AccountId   ;* if Account Number is given
            AB.ModelBank.GetAcStmtEntList(AccountId, BUNDLE.ARR.ID, DATE.FROM, DATE.TO, BALANCE.ARRAY)    ;* to get statement entry list for TR/SA/CS accounts
        
        CASE 1
            IF CLOSE.DATE AND CLOSE.DATE LT DATE.TO THEN  ;* When bundle close date is available and the date is less than the booking date entered then the DATE.TO changed as bundle close date
                DATE.TO = CLOSE.DATE
            END

            ARR.INFO = BUNDLE.ARR.ID:@FM:'':@FM:'':@FM:'':@FM:'':@FM:''
            AA.Framework.GetArrangementProperties(ARR.INFO, CHECK.DATE, R.ARRANGEMENT, PROP.LIST)

            CLASS.LIST = ''
            AA.ProductFramework.GetPropertyClass(PROP.LIST, CLASS.LIST)       ;* Find their Property classes

            LOCATE 'PRODUCT.BUNDLE' IN CLASS.LIST<1,1> SETTING PROD.POS THEN
                PB.PROPERTY = PROP.LIST<1,PROD.POS>
            END

            LOCATE PB.PROPERTY IN DATE.RECORD<1,1> SETTING DAT.POS THEN
                PROPERTY.DATES = DATE.FROM:@VM:DATE.RECORD<2,DAT.POS>:@VM:DATE.TO
                PROPERTY.DATES = SORT(PROPERTY.DATES)
            END

            FOR PROP.DATE = 1 TO DCOUNT(PROPERTY.DATES,@FM)
                CURRENT.DATE = FIELD(PROPERTY.DATES<PROP.DATE>,'.',1)
                NEXT.DATE = FIELD(PROPERTY.DATES<PROP.DATE+1>,'.',1)
                IF NEXT.DATE EQ '' THEN
                    IF CompanyMnemonic THEN
                        GOSUB RestoreCompany
                    END
                    IF BALANCE.ARRAY EQ "" THEN
                        BALANCE.ARRAY = "NULL"
                    END
                
                    RETURN
                END
                GOSUB FIND.STATEMENT.IDS
            NEXT PROP.DATE
    END CASE
    
    IF CompanyMnemonic THEN
        GOSUB RestoreCompany
    END
    
RETURN
 
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Main Process>
***
FIND.STATEMENT.IDS:

    IF CURRENT.DATE GE DATE.FROM AND CURRENT.DATE LE DATE.TO THEN
        AA.ProductFramework.GetPropertyRecord('', FIELD(BUNDLE.ARR.ID,"/",1), PB.PROPERTY, CURRENT.DATE, 'PRODUCT.BUNDLE', '', R.PRODUCT.BUNDLE , REC.ERR)
       
        PRD.BUNDLE.PRODUCT.GRP = R.PRODUCT.BUNDLE<AA.ProductBundle.ProductBundle.BunProductGroup>   ;* Shared accounts product group
        TOT.PRODUCT.GRP.CNT = DCOUNT(PRD.BUNDLE.PRODUCT.GRP, @VM);*to fetch the total no of Product Groups
        FOR CNT.PRODUCT.GRP = 1 TO  TOT.PRODUCT.GRP.CNT
*In each Product Group -Product section, arrangements are now seperated by SM
            GOSUB FIND.ARRANGEMENT.IDS
        NEXT CNT.PRODUCT.GRP
    END
RETURN
*** </region>


*-----------------------------------------------------------------------------
*
*** <region name= Main Process>
***
FIND.ARRANGEMENT.IDS:
    ARRANGEMENT.IDS = R.PRODUCT.BUNDLE<AA.ProductBundle.ProductBundle.BunArrangement,CNT.PRODUCT.GRP>;*to fetch all arrangements in Product Groups
    FOR ARR.I = 1 TO DCOUNT(ARRANGEMENT.IDS,@SM)
        ARR.ID = ARRANGEMENT.IDS<1,1,ARR.I>
        IF ARR.ID THEN
            AA.Framework.GetArrangement(ARR.ID, R.ARRANGEMENT, ARR.ERROR)       ;* Arrangement record to pick the Property list
            ACCOUNT.ID = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId,1>
            IF CURRENT.DATE NE NEXT.DATE THEN
                IF NEXT.DATE EQ DATE.TO ELSE
                    EB.API.Cdt('',NEXT.DATE,'-1C')
                END
            END
            EB.Reports.setDFields("ACCT.ID":@FM:"BOOKING.DATE":@FM:"CO.CODE")
            EB.Reports.setDLogicalOperands(1:@FM:2:@FM:1)
            EB.Reports.setDRangeAndValue(ACCOUNT.ID:@FM:CURRENT.DATE:@SM:NEXT.DATE:@FM:EB.SystemTables.getIdCompany())
            Y.ID.LIST = ''
            AC.ModelBank.EStmtEntList(Y.ID.LIST)
            FOR ENT.I = 1 TO DCOUNT(Y.ID.LIST,@FM)
                ENTRY.ID = Y.ID.LIST<ENT.I>
                IF ENTRY.ID[1,5] NE "DUMMY" THEN
                    LOCATE ENTRY.ID IN TEMP.TRANS.REF<1> SETTING TRANS.POS ELSE
                        BALANCE.ARRAY<-1> = ENTRY.ID
                        TEMP.TRANS.REF<-1> = ENTRY.ID
                    END
                END
            NEXT ENT.I
        END
    NEXT ARR.I
   

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get From To Dates>
***
GET.FROM.TO.DATE:
    
    LOCATE "BOOKING.DATE" IN EB.Reports.getDFields()<1> SETTING YBOOK.POS THEN
        BOOK.DATE = EB.Reports.getDRangeAndValue()<YBOOK.POS>
        LOGICAL.OPERAND = EB.Reports.getDLogicalOperands()<YBOOK.POS>
        BEGIN CASE
            CASE LOGICAL.OPERAND EQ '4'
                EB.API.Cdt('',BOOK.DATE,'+1C')
                DATE.FROM = BOOK.DATE
                DATE.TO = EB.SystemTables.getToday()
            CASE LOGICAL.OPERAND EQ '9'
                DATE.FROM = BOOK.DATE
                DATE.TO = EB.SystemTables.getToday()
            CASE LOGICAL.OPERAND EQ '3'
                EB.API.Cdt('',BOOK.DATE,'-1C')
                DATE.TO = BOOK.DATE
                DATE.FROM = CHECK.DATE
            CASE LOGICAL.OPERAND EQ '8'
                DATE.TO = BOOK.DATE
                DATE.FROM = CHECK.DATE
            CASE LOGICAL.OPERAND EQ  '2'
                DATE.FROM = FIELD(BOOK.DATE,@SM,1)
                DATE.TO = FIELD(BOOK.DATE,@SM,2)
            CASE LOGICAL.OPERAND EQ '1'
                DATE.FROM = BOOK.DATE
                DATE.TO = BOOK.DATE
        END CASE
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SaveCompany>
SaveCompany:
*** <desc>To Save the Company if Called CompanyMnemonic not equal Current CompanyMnemonic</desc>

    SaveCompanyMnemonic = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic)
    IF SaveCompanyMnemonic NE CompanyMnemonic AND CompanyMnemonic THEN
        ST.CompanyCreation.LoadCompany(CompanyMnemonic)
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= RestoreCompany>
RestoreCompany:
*** <desc>To restore the company </desc>

    IF SaveCompanyMnemonic NE EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic) AND SaveCompanyMnemonic THEN
        ST.CompanyCreation.LoadCompany(SaveCompanyMnemonic)
    END
RETURN
*** </region>
END
