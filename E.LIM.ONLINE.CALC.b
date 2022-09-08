* @ValidationCode : MjotODQxMjk0MTE5OkNwMTI1MjoxNTgxMDc2OTAyMzQ5OmJzYXVyYXZrdW1hcjo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAyLjIwMjAwMTE3LTIwMjY6MTU1OjEyMg==
* @ValidationInfo : Timestamp         : 07 Feb 2020 17:31:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 122/155 (78.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 10 25/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>455</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LI.ModelBank

SUBROUTINE E.LIM.ONLINE.CALC
*-------------------------------------------------
*
* This subroutine will be used to calculate the
* net committed amount, i.e. including sub allocations.
* It is used in the standard enquiry system
* when it is necessary to read the limit record
* as the limit record is not held in I_ENQUIRY.COMMON
*
* The fields used are as follows:-
*
* INPUT   ID              Id of the LIMIT record
*                         being processed.
*
*         R.RECORD        LIMIT record.
*
*         VC              Pointer to the current
*                         multi-value set being
*                         processed.
*
*         S               Pointer to the current
*                         sub-value set being
*                         processed.
*
*         O.DATA          Committed amount.
*
*
* OUTPUT  O.DATA          Net committed amount
*
* Modification History
*
* 07/02/20 - Enhancement 3498204 / Task 3498206
*            Support for new limits for FX
*---------------------------------------------------------
    $USING LI.Config
    $USING LI.LimitTransaction
    $USING EB.Reports

*----------------------------------------------------Initialise variables
    YLREPKEY = ""
    YLKEY = EB.Reports.getOData()
    IF YLKEY[1,2] = "LI" THEN   ;* Enquiry will try to form id as old limit only so take 1st part for new limits
        YLKEY = FIELD(YLKEY, ".", 1)
    END
    
    LIMIT.ID.COMPONENTS = ""
    LIMIT.ID.COMPOSED = ""
    RET.ERR = ""
    LI.Config.LimitIdProcess(YLKEY, LIMIT.ID.COMPONENTS, LIMIT.ID.COMPOSED, "", RET.ERR)
    YLLIAB = LIMIT.ID.COMPONENTS<1>
    YLREF = LIMIT.ID.COMPONENTS<2>
    YLSER = LIMIT.ID.COMPONENTS<3>
    YLCUST = LIMIT.ID.COMPONENTS<4>
    LIMIT.TYPE = LIMIT.ID.COMPONENTS<8>
    R.LIMIT.RECORD = RAISE(LIMIT.ID.COMPONENTS<10>)
    IF NOT(R.LIMIT.RECORD) THEN
        GOSUB READ.LIMIT.RECORD
    END
    GOSUB GET.AMOUNT
    IF YLAMT NE "" THEN
        IF YLAMT NE 0 THEN GOTO STORE.ODATA
    END
    YLCCY.TO = R.LIMIT.RECORD<LI.Config.Limit.LimitCurrency>
    YLHDAMT = YLAMT
    YLHDRSK = YLCL.RSK
    YLNEXTKEY = ""
    YLNEXTAMT = ""
    YLNEXTRSK = ""
    CREDIT.LINE = ""
    GLOBAL.REQD = 1
    NEXT.KEY = 0
    SUB.PRODUCT.LIMIT = 0
    GOSUB GET.NEXT.KEY
*
    YLNUM = 0
    IF YLNEXTKEY = "" THEN
        GOTO SET.WITH.FIRST
    END ELSE
        YLCOUNT = COUNT(YLNEXTKEY,@FM) + 1
    END
    LOOP WHILE YLNUM < YLCOUNT
        YLNUM += 1
        YLKEY = YLNEXTKEY<YLNUM>
        GOSUB READ.LIMIT.RECORD
        GOSUB GET.AMOUNT
        YLCCY.FROM = R.LIMIT.RECORD<LI.Config.Limit.LimitCurrency>
        IF YLCCY.TO <> YLCCY.FROM THEN
            YLAMTEQ = ""
            YLCL.RSKEQ = ""
            LI.LimitTransaction.LimitCurrConv(YLCCY.FROM,YLAMT,YLCCY.TO,YLAMTEQ,"")
            YLAMT = YLAMTEQ
            LI.LimitTransaction.LimitCurrConv(YLCCY.FROM,YLCL.RSK,YLCCY.TO,YLCL.RSKEQ,"")
            YLCL.RSK = YLCL.RSKEQ
        END
        YLNEXTAMT<YLNUM> = YLAMT
        YLNEXTRSK<YLNUM> = YLCL.RSK
    REPEAT
*
    LOOP UNTIL YLCOUNT = 1
        IF YLNEXTAMT<1> NE "0" AND YLNEXTAMT<1> < YLNEXTAMT<2> THEN
            DEL YLNEXTAMT<2>
            DEL YLNEXTKEY<2>
            DEL YLNEXTRSK<2>
        END ELSE
            DEL YLNEXTAMT<1>
            DEL YLNEXTKEY<1>
            DEL YLNEXTRSK<1>
        END
        YLCOUNT -= 1
    REPEAT
*
    IF YLNEXTAMT = "" OR YLNEXTAMT = "0" THEN
        GOTO SET.WITH.FIRST
    END ELSE
        YLAMT = YLNEXTAMT<1>
        YLCL.RSK = YLNEXTRSK<1>
        YLREPKEY = YLNEXTKEY<1>
        GOTO STORE.ODATA
    END
*
READ.LIMIT.RECORD:
    R.LIMIT.RECORD = ""
    R.LIMIT.RECORD = LI.Config.Limit.Read(YLKEY, "")
  
RETURN
*
GET.AMOUNT:
    
    YLAMT = R.LIMIT.RECORD<LI.Config.Limit.OnlineLimit,1> + R.LIMIT.RECORD<LI.Config.Limit.SubAllocTaken,1>
    YLAMT += R.LIMIT.RECORD<LI.Config.Limit.SubAllocGiven,1> + R.LIMIT.RECORD<LI.Config.Limit.CommtAmtAvail,1>
    YLCL.RSK = R.LIMIT.RECORD<LI.Config.Limit.CleanRisk>
    
RETURN
*
GET.NEXT.KEY:
    
    IF LIMIT.TYPE THEN  ;* Need not proceed for validation/ utilisation limits
        RETURN
    END
    
    IF YLCUST NE "" THEN
        YLNEXTKEY<-1> = YLLIAB:".":YLREF:".":YLSER
    END
    IF YLREF[6,2] NE "00" AND NUM(YLREF) THEN  ;* If subproduct limit like 0001010
        YLREF = YLREF[1,5]:"00" ;* Form corresponding product limit like 0001000
        YLNEXTKEY<-1> = YLLIAB:".":YLREF:".":YLSER  ;* Form product limit id
        IF YLCUST NE "" THEN    ;* If liability customer is there append it
            YLNEXTKEY<-1> = YLLIAB:".":YLREF:".":YLSER:".":YLCUST
        END
        SUB.PRODUCT.LIMIT = 1
    END
    IF YLREF[1,3] NE "000" AND NUM(YLREF) THEN ;* If global limit like 0011010
        YLREF = YLREF[1,3]:"0000"   ;* Form corresponding global limit like 0010000
        YLNEXTKEY<-1> = YLLIAB:".":YLREF:".":YLSER  ;* Form global limit id
        IF YLCUST NE "" THEN    ;* If liability customer is there append it
            YLNEXTKEY<-1> = YLLIAB:".":YLREF:".":YLSER:".":YLCUST
        END
        CREDIT.LINE = R.LIMIT.RECORD<LI.Config.Limit.CreditLine>    ;* Get credit line. Will be useful for new limits
    END
    
    IF YLKEY[1,2] EQ "LI" AND NOT(SUB.PRODUCT.LIMIT) AND CREDIT.LINE AND NUM(YLREF) THEN  ;* If product limit under global structure then directly take credit lines
        YLNEXTKEY = CREDIT.LINE
        NEXT.KEY = 1
    END
    
    IF YLKEY[1,2] EQ "LI" AND NOT(NUM(YLREF)) THEN  ;* For alphanumeric products take credit line and return
        YLNEXTKEY = R.LIMIT.RECORD<LI.Config.Limit.CreditLine>
        NEXT.KEY = 1
    END
    
    IF YLKEY[1,2] NE "LI" OR NEXT.KEY THEN  ;* Need not proceed for older limits or for new product limit under global hierarchy
        RETURN
    END
    
    YLNEXTKEY = ""
    IF NOT(CREDIT.LINE) THEN    ;* We did not have global limit in the structure
        CREDIT.LINE = R.LIMIT.RECORD<LI.Config.Limit.CreditLine>    ;* Get credit line
        GLOBAL.REQD = 0 ;* Set flag to 0 to indicate we dont have global limit
    END

* Util Limit Parent is updated in order like 1st is top most credit line then product and from 3rd position its all subproduct in case we have a global limit also.
* So we can rely on 2nd limit available at 2nd position in list of parents obtained for current limit in that case. However if product limit is top most limit, then
* product limit can be found at 1st position itself. Also in case of global limit structure, if we come for product limit, then it will be at 0th position. So in
* that case global limit will be found at 1st position. By default set extract position as 1 only. Only in case of global strcuture and level is not 0, we need
* extarction from 2nd position.
    
    EXTRACT.POS = 1
    R.LIMIT.HIERARCHY = "" ; E.LIMIT.HIERARCHY = ""
    R.LIMIT.HIERARCHY = LI.Config.LimitHierarchy.Read(CREDIT.LINE, E.LIMIT.HIERARCHY)   ;* Get full hierarchy from LIMIT.HIERARCHY table
    UTIL.LIMIT.ID = R.LIMIT.HIERARCHY<LI.Config.LimitHierarchy.LiLhUtilLimitId>         ;* List of product/ subproduct limits
    LOCATE YLKEY IN UTIL.LIMIT.ID<1,1> SETTING UTIL.POS THEN    ;* Where is current limit?
        PARENT.ARRAY = R.LIMIT.HIERARCHY<LI.Config.LimitHierarchy.LiLhUtilLimitParent,UTIL.POS> ;* Get the parent list
        LEVEL = R.LIMIT.HIERARCHY<LI.Config.LimitHierarchy.LiLhUtilLimitLevel,UTIL.POS>
        IF LEVEL NE 0 AND GLOBAL.REQD THEN
            EXTRACT.POS = 2
        END
        YLNEXTKEY<-1> = FIELD(PARENT.ARRAY, "#", EXTRACT.POS)
    END
    
    IF GLOBAL.REQD AND LEVEL NE 0 THEN  ;* If limit is at 0th level then parent is alredy updated so dont update again
        YLNEXTKEY<-1> = CREDIT.LINE
    END
        
RETURN
*
SET.WITH.FIRST:
    YLAMT = YLHDAMT
    YLCL.RSK = YLHDRSK
*
STORE.ODATA:
    IF NUM(YLAMT) = 1 AND YLAMT <> "" THEN
        YLAMT = YLAMT /1000
    END ELSE
        YLAMT = 0
    END
    IF NUM(YLCL.RSK) = 1 AND YLCL.RSK <> "" THEN
        YLCL.RSK = YLCL.RSK /1000
    END ELSE
        YLCL.RSK = 0
    END
    O.DATA.VALUE = YLAMT:"\":YLCL.RSK
    IF YLREPKEY NE "" THEN
        O.DATA.VALUE := "\":YLREPKEY
    END
    EB.Reports.setOData(O.DATA.VALUE)

RETURN
*-----------------------------------------------------------------------------
END
