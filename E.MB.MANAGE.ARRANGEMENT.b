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
* <Rating>-64</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AI.ModelBank

    SUBROUTINE E.MB.MANAGE.ARRANGEMENT(RESULT.ARR)
*-----------------------------------------------------------------------------
* Subroutine type : NOFILE
* Attached to     : STANDARD.SELECTION record NOFILE.MANAGE.ARRANGEMENT for the enquiry AI.MANAGE.INTERNET.ARRANGEMENT
*                   and AI.MANAGE.INTERNET.ARRANGEMENT.SEE
* Attached as     : NOFILE Enquiry routine
* Incoming        : Enquiry's selection and its value from common variables
* Outgoing        : RESULT.ARR - The list of Internet Arrangement details
*
*--------------------------------------------------------------------------------------------------------------
*                      M O D I F I C A T I O N S
*--------------------------------------------------------------------------------------------------------------
*
* 18/05/15 - Enhancement-1326996/Task-1399903
*			 Incorporation of AI components
*
* 08/01/16 - Defect 1593481 / Task 1594090
*			Warnings in TAFC
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AA.ARC
    $USING ST.Customer
    $USING AA.ProductFramework
    $USING EB.ARC
    $USING EB.Reports
    $INSERT I_DAS.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_DAS.EB.EXTERNAL.USER

    GOSUB INIT
    GOSUB OPENFILE
    GOSUB PROCESS
    GOSUB FIND.ALLOW.CUSTOMER.AND.PROXY

    CONVERT "_" TO @SM IN RESULT.ARR

    RETURN

**********
INIT:
**********

* To initialise the variables
    TABLE.SUFFIX = ''

    RETURN

************
OPENFILE:
************

    RETURN

************
PROCESS:
************

*To select the Internet Service Arrangement IDs based on the customer (or) select all the Internet Service Arrangement IDs for all customer

    LOCATE 'CUS.NO' IN EB.Reports.getEnqSelection()<2,1> SETTING ID.POS THEN

    CUS.NO = EB.Reports.getEnqSelection()<4,ID.POS>

    END
    IF CUS.NO EQ "" THEN

        SEL.LIST = DAS$MANAGE.ARRANGEMENT

        CALL DAS('AA.ARRANGEMENT.ACTIVITY',SEL.LIST,'',TABLE.SUFFIX)

    END ELSE

        THE.ARGS = CUS.NO

        SEL.LIST = DAS$CUSARRANGEMENT

        CALL DAS('AA.ARRANGEMENT.ACTIVITY',SEL.LIST,THE.ARGS,TABLE.SUFFIX)

    END

    RETURN

*********************************
FIND.ALLOW.CUSTOMER.AND.PROXY:
*********************************

* To find the External user id , proxy arrangement customer and proxy arrangement based on the arrangement id.

    LOOP

        REMOVE ARR.ID FROM SEL.LIST SETTING POS

    WHILE ARR.ID:POS

        REC.ARR = AA.Framework.ArrangementActivity.Read(ARR.ID,REC.ERROR)

        AA.ARR.ID=REC.ARR<AA.Framework.ArrangementActivity.ArrActArrangement>

        CUS.NO=REC.ARR<AA.Framework.ArrangementActivity.ArrActCustomer>

        GOSUB FIND.PROXY.ARRANGEMENT

        THE.LIST=DAS.EXT$ARRANGEMENT

        THE.ARGS = AA.ARR.ID

        CALL DAS('EB.EXTERNAL.USER',THE.LIST,THE.ARGS,TABLE.SUFFIX)

        EXT.USER.ID=THE.LIST

        CONVERT @VM TO "_" IN PRO.ARR.ACTIVITY.ID

        RESULT.ARR<-1>=EXT.USER.ID:"*":CUS.NO:"*":AA.ARR.ID:"*":"":"*":ARR.ID:"*":CUS.NAME:"*":PROXY.ARR.ID:"*":PRO.ARR.ACTIVITY.ID

    REPEAT

    RETURN

****************************
FIND.PROXY.ARRANGEMENT:
***************************

    ID.INFO = AA.ARR.ID

    PROPERTY = 'USERRIGHTS'


    AA.ProductFramework.GetPropertyRecord(TEMPLATE, ID.INFO, PROPERTY, PROPERTY.DATE, PROP.CLASS, BASE.ARR.REC,PROPERTY.RECORD, REC.ERR)


    CUS.NAME = ''

    ALLOW.CUST = PROPERTY.RECORD<AA.ARC.UserRights.UsrRgtAllowedCustomer>

    CUST.COUNT=DCOUNT(ALLOW.CUST,@VM)

    FOR I=1 TO CUST.COUNT

        ALLOW.CUST.ID=ALLOW.CUST<1,I>


        REC.CUS = ST.Customer.Customer.Read(ALLOW.CUST.ID,CUS.ERROR)


        CUS.NAME<1,-1>=REC.CUS<ST.Customer.Customer.EbCusShortName>

    NEXT I

    CONVERT @VM TO "_" IN CUS.NAME

    PROXY.ARR.ID=PROPERTY.RECORD<AA.ARC.UserRights.UsrRgtProxyArrangement>

    PRO.AR.ID=PROXY.ARR.ID

    CONVERT @VM TO "_" IN PROXY.ARR.ID

    PRO.ARR.ACTIVITY.ID = ''

    LOOP

        REMOVE PROXY.AR.ID FROM PRO.AR.ID SETTING PR.POS

    WHILE PROXY.AR.ID:PR.POS

        THE.LIST.PROXY=DAS$PROXYARRANGEMENT

        THE.ARGS=PROXY.AR.ID

        CALL DAS('AA.ARRANGEMENT.ACTIVITY',THE.LIST.PROXY,THE.ARGS,TABLE.SUFFIX)

        PRO.ARR.ACTIVITY.ID<1,-1>= THE.LIST.PROXY


    REPEAT

    RETURN

    END
