* @ValidationCode : Mjo4NjA1Mzk3NzU6Q3AxMjUyOjE1NjY0MDgwMjMzNDA6c21pdGhhYmhhdDoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA4LjIwMTkwNzIzLTAyNTE6MTAzOjk0
* @ValidationInfo : Timestamp         : 21 Aug 2019 22:50:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smithabhat
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 94/103 (91.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190723-0251
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CL.ModelReport
SUBROUTINE E.CL.COLL.ITEM.REP(ENQ.LIST)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*** <doc>
* Routine Type : NO-FILE routine
* Routine will select the Collection item's based on PD.DAYS.
* @author johnson@temenos.com
* @stereotype template
* @uses ENQUIRY>CL.DC.ENQ.COLL.ITEM.REP
* @uses
* @package retaillending.CL
*
*** </doc>
*** </region>

*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History :
*-----------------------
* 11/04/14 -  ENHANCEMENT - 908020 /Task - 988392
*          -  Loan Collection Process
*
* 10/07/19 -  ENHANCEMENT - 2886910/Task - 3221955
*          -  Changes made to get the Limit Id for Accounts Arrangement which is overdrawn
*** </region>

*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
* Input :
*
*
*
*
* Output
*
* ENQ.LIST = It return final result
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING CL.Contract
    $USING EB.Reports
    $USING EB.DataAccess
    $USING AA.Framework

*** </region>

*** <region name= Main Section>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*** </region>

*** <region name= INITIALISE>
*** <desc>Initialise local variables and file variables</desc>

INITIALISE:
***********

* Initialise all the variables

    FN.CL.COLLECTION.ITEM = 'F.CL.COLLECTION.ITEM'
    F.CL.COLLECTION.ITEM = ''
    EB.DataAccess.Opf(FN.CL.COLLECTION.ITEM,F.CL.COLLECTION.ITEM)

    FN.AA.OVERDUE.STATS = 'F.AA.OVERDUE.STATS'
    F.AA.OVERDUE.STATS = ''
    EB.DataAccess.Opf(FN.AA.OVERDUE.STATS,F.AA.OVERDUE.STATS)

    FN.LIMIT = 'F.LIMIT'
    F.LIMIT =''
    EB.DataAccess.Opf(FN.LIMIT,F.LIMIT)
    
    LOCATE 'DUE.START.FROM' IN EB.Reports.getEnqSelection()<2,1> SETTING YSEL.POS THEN
        FROM.DAYS = EB.Reports.getEnqSelection()<4,YSEL.POS>
        FROM.OPER = EB.Reports.getEnqSelection()<3,YSEL.POS>
    END

    LOCATE 'DUE.DAYS.UPTO' IN EB.Reports.getEnqSelection()<2,1> SETTING YSEL.TO.POS THEN
        TO.DAYS = EB.Reports.getEnqSelection()<4,YSEL.TO.POS>
        TO.OPER = EB.Reports.getEnqSelection()<3,YSEL.TO.POS>
        LOGIC.OPER = 'OR'
    END

    IF FROM.OPER EQ 'GE' AND TO.OPER EQ 'LE' THEN
        LOGIC.OPER = 'AND'
    END
    SEL.EXE.CMD = ''
    DEBT.REC.LIST = ''
    NO.OF.REC = ''
    ERR.REC = ''
    TOT.DC.RECS = ''
    COLL.ITEM.ID = ''
    NO.OF.PDS = ''
    COLL.ID = ''
    CI.ARRAY = ''
    ENQ.LIST = ''   ;* Final Return Array

RETURN

*** </region>

*** <region name= PROCESS>
*** <desc>Main process Selection</desc>

PROCESS:
********

* select the Collection Items duration Period.

    SEL.EXE.CMD = 'SELECT ':FN.CL.COLLECTION.ITEM:' WITH NO.OF.DAYS.PD ':FROM.OPER:' ':'"':FROM.DAYS:'"':' ':LOGIC.OPER:' ':TO.OPER:' ':'"':TO.DAYS:'"'
    EB.DataAccess.Readlist(SEL.EXE.CMD,DEBT.REC.LIST,'',NO.OF.REC,ERR.REC)

    TOT.DC.RECS = DCOUNT(DEBT.REC.LIST,@FM)

    FORM.ARRAY = ''
    FOR INIT.REC = 1 TO TOT.DC.RECS

        COLL.ITEM.ID = DEBT.REC.LIST<INIT.REC>

        R.CL.COLLECTION.ITEM = CL.Contract.CollectionItem.Read(COLL.ITEM.ID, ERR.REC)

        NO.OF.PDS = DCOUNT(R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitDueReference>,@VM)
        OVERDUE.ID.LIST = ''
        LimitIdList = ''
        FOR PD.CNT = 1 TO NO.OF.PDS
            CONTRACT.ID = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitUlContractRef,PD.CNT>

            IF CONTRACT.ID[1,2] EQ 'AA' THEN
                
                GOSUB GetArrangementDetails ;* Get the Arrangement Record of contract
                GOSUB FETCH.AA.OVERDUE.ID
                GOSUB GetLimitId ;* Get the Limit attached to Accounts Arrangement
                GOSUB GetOverdueAndLimitList ;* Get the Overdue and Limit Id List

            END ELSE
                OVERDUE.ID.LIST<-1> =  R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitDueReference,PD.CNT>
            END
        NEXT PD.CNT        

    
        CHANGE @FM TO @VM IN OVERDUE.ID.LIST
        CHANGE @FM TO @VM IN LimitIdList
        
        CI.ARRAY = ''
        DATE.TIME = 0         ;* For future user
        CI.ARRAY = COLL.ITEM.ID:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitTotOverdueAmt>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitTotOutstdingAmt>:"*"
        CI.ARRAY := R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitNoOfDaysPd>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitActionCode>:"*"
        CI.ARRAY := R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitActionDate>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitOutcomeCode>:"*"
        CI.ARRAY := R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitCollector>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitQueue>:"*":OVERDUE.ID.LIST:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitUlContractRef>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitOdCurrency,1>:"*":LimitIdList:"*":DATE.TIME : "*" : TO.DAYS ;* Append the Limit Id of arrangement to array

        FORM.ARRAY<-1> = CI.ARRAY

    NEXT INIT.REC
 
    ENQ.LIST<-1> = FORM.ARRAY

RETURN

*** </region>

*** <region name= GET OVERDUE IDS>
*** <desc>Main process Selection</desc>


FETCH.AA.OVERDUE.ID:
********************

    OVERDUE.LIST = ''
    IF RArrangement<AA.Framework.Arrangement.ArrProductLine> EQ 'LENDING' THEN ;* Arrangement should belong to Lending Product Line
        CONTRACTS.ID = SQUOTE(CONTRACT.ID):"..."

        SEL.CMD = "SELECT ":FN.AA.OVERDUE.STATS:" WITH @ID LIKE ":DQUOTE(CONTRACTS.ID)
        EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.OF.REC,ERR.REC)
        OVERDUE.LIST = SEL.LIST
        CHANGE @FM TO @VM IN OVERDUE.LIST
    END

RETURN

*** </region>
*--------------------------------------------------------------------------
*** <region name= GetArrangementDetails>
*** <desc>Get Arrangement Record of the contract</desc>
GetArrangementDetails:
    
    RArrangement = ''
    RetError = ''
    AA.Framework.GetArrangement(CONTRACT.ID, RArrangement, RetError) ;* Get the Arrangement Record
    
RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= GetLimitId>
*** <desc>Get Limit Id for Accounts Arrangement</desc>
GetLimitId:
    
    LimitId = ''
    IF RArrangement<AA.Framework.Arrangement.ArrProductLine> EQ 'ACCOUNTS' THEN ;* Arrangement should belong to Accounts Product Line
        AccountNumber = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitAccountNumber,PD.CNT> ;* Get the Account Number of Contract
        SelCmdLI = "SELECT ":FN.LIMIT:" WITH ACCOUNT LIKE ":AccountNumber
        SelList = ''
        NoOfRec = ''
        SelErr = ''
        EB.DataAccess.Readlist(SelCmdLI,SelList,'',NoOfRec,SelErr)
        LimitId = SelList ;* Get the Limit Id
    END

RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= GetOverdueAndLimtiList>
*** <desc>Get the Overdue and Limit list</desc>
GetOverdueAndLimitList:
    
    IF PD.CNT NE "1" THEN
        OVERDUE.ID.LIST:=@FM:OVERDUE.LIST
    END ELSE
        OVERDUE.ID.LIST = OVERDUE.LIST
    END
    
    IF PD.CNT NE "1" THEN
        LimitIdList:=@FM:LimitId
    END ELSE
        LimitIdList = LimitId
    END
    
RETURN
*** </region>
*--------------------------------------------------------------------------
END
