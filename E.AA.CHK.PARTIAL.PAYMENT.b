* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-45</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.CHK.PARTIAL.PAYMENT
*********************************************************
* This is a conversion routine attached in the enquiry AA.DETAILS.ACCOUNT.DATES
* This routine is used to return the EXP balance for the given arrangement.
* This will work for both Live / Sim Overview.
* Incoming Argument
* O.DATA               - Account Number * Product Name * Simulation Reference
*
* Outgoing Argument
* O.DATA               - Remaining amount in EXP balance for the deposit arrangement
*
***********************************************************
* MODIFICATION HISTORY
*
* 20-06-2014 - Task : 1034611
*              Defect: 1029435
*              The call routine AA.GET.PROPERTY.NAME is replaced with the required logic. Issue with AA$PROPERTY.CLASS.LIST common variable.
***********************************************************
    $USING AA.ProductManagement
    $USING AA.ProductFramework
    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Reports

    GOSUB INIT
    GOSUB ASSIGN.VALUES
    GOSUB PROCESS
    RETURN

***************
INIT:
***************
    GET.ID = '' ; ACCOUNT.ID = '' ; PRODUCT.ID = '' ;   START.DATE = '' ; END.DATE = ''
    PROPERTY = '' ; recProduct = '' ; BALANCE.TO.CHECK = '' ; EXP.BALANCE = '' ; SIM.REF.ID = ''
    GET.ID = EB.Reports.getOData()
    RETURN

****************
ASSIGN.VALUES:
****************

    ACCOUNT.ID = FIELD(GET.ID,"*",1)
    PRODUCT.ID = FIELD(GET.ID,"*",2)
    SIM.REF.ID = FIELD(GET.ID,"*",3)

    START.DATE = EB.SystemTables.getToday()
    END.DATE   = EB.SystemTables.getToday()
    IF SIM.REF.ID THEN
        ACCOUNT.ID<2> = SIM.REF.ID      ;* Need to pass the simulation reference with Account number to get the balances for simulation records.
    END
    RETURN

******************
PROCESS:
******************

    AA.ProductFramework.GetProductPropertyRecord("PRODUCT", "", PRODUCT.ID, "", "", "", "", effectiveDate, recProduct, errMsg)

    PROPERTY.CLS = 'ACCOUNT'
    PROP.LIST = RAISE(recProduct<AA.ProductManagement.ProductDesigner.PrdProperty>)
    PROP.CLASS = ''
    PROP.LIST.IDX = ''
    PROP.FOUND = 0
    BAL.PROPERTY = ''
    LOOP
        READNEXT PROP FROM PROP.LIST SETTING PROP.LIST.IDX ELSE
            PROP.LIST.IDX = ''
        END
    UNTIL NOT(PROP)
        AA.ProductFramework.GetPropertyClass(PROP, PROP.CLASS)        ;* Find the class of this property
        IF PROP.CLASS EQ PROPERTY.CLS THEN        ;* If the required and current classes are the same, append to the list
            BAL.PROPERTY<-1> = PROP
        END
    REPEAT

    BALANCE.TO.CHECK = "EXP":BAL.PROPERTY
    AA.Framework.GetPeriodBalances(ACCOUNT.ID,BALANCE.TO.CHECK,REQUEST.TYPE,START.DATE,END.DATE,'',BAL.DETAILS,'')
* BAL.DETAILS will have 4 values separedte by FM Date , Credit Movement , Debit Movement & Dated Balance
    EB.Reports.setOData(BAL.DETAILS<4>)
    RETURN
    END
