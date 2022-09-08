* @ValidationCode : MjoxNzc4MzI2NjUzOkNwMTI1MjoxNTgxMDc2OTA0MjI4OmJzYXVyYXZrdW1hcjozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAyLjIwMjAwMTE3LTIwMjY6NDk6MzU=
* @ValidationInfo : Timestamp         : 07 Feb 2020 17:31:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 35/49 (71.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 5 25/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>-28</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LI.ModelBank

SUBROUTINE E.LIM.TRADE.NEXT
*-------------------------------------------------
*
* This subroutine will be used to decide which
* enquiry to link to from the LIM.TRADE enquiry.
* All the parameters required are passed in
*  I_ENQUIRY.COMMON
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
*         O.DATA          Initially set to the ID of the line
*
*
* OUTOUT O.DATA           Name of the next enquiry to link to.
*-----------------------------------------------------------------------------
*
* 18/10/10 - Task - 84420
*            Replace the enterprise(customer service api)code into  Banking framework related
*            routines which reads CUSTOMER.
*
* 08/11/17 - EN 2322180 / Task 2322183
*            Support for new limit key and customer group id
*
* 07/02/20 - Enhancement 3498204 / Task 3498206
*            Support for new limits for FX
*-------------------------------------------------Insert statements
    $INSERT I_CustomerService_Parent

    $USING LI.Config
    $USING EB.Reports

*----------------------------------------------------Initialise variables
    CURR.ID = EB.Reports.getId()
    Y.LIAB.CUST = ""
    IF CURR.ID[1,2] NE "LI" THEN
        YLIAB.NO = FIELD(CURR.ID, ".",1,1)
*--Read Customer record for liability to see if there are linked customers
        Y.LIAB.CUST = "1"
        custId = YLIAB.NO
        custParent = ''
* calling the customer service api .getParent to get the liabilty of customer.
        CALL CustomerService.getParent(custId, custParent)
        IF custParent<Parent.customerLiability> EQ '' THEN
            Y.LIAB.CUST = ""
        END
    END

    IF Y.LIAB.CUST THEN
        YREF = FIELD(CURR.ID,".",2)
        IF YREF[1,3] NE "000" THEN
            YKEY = YREF[1,3]:"0000"
        END ELSE
            IF YREF[6,2] NE "00" THEN
                YKEY = YREF[1,5]:"00"
            END ELSE
                YKEY = YREF
            END
        END
        Y.WRK.KEY = FIELD(CURR.ID,".",1):".":YKEY:".":FIELD(CURR.ID,".",3)
        O.DATA.VALUE = "LIM.CUST\LINE.ID EQ ":Y.WRK.KEY:"\REF.NO EQ ":FIELD(CURR.ID, ".",2)
        EB.Reports.setOData(O.DATA.VALUE)
    END ELSE
        O.DATA.VALUE = ''
        IF EB.Reports.getRRecord()<LI.Config.Limit.FxOrTimeBand> = 'FX' THEN
            O.DATA.VALUE = "LIM.FX1\"
            Y.CUST.NEXT = ""
        END ELSE
            O.DATA.VALUE = "LIM.TXN\"
            Y.CUST.NEXT = "ALL"
        END
        IF CURR.ID[1,2] EQ "LI" THEN
            O.DATA.VALUE := "LIAB.NO EQ ":CURR.ID
        END ELSE
            O.DATA.VALUE := "LIAB.NO EQ ":FIELD(CURR.ID, ".",1)
            O.DATA.VALUE := "\REF.NO EQ ":FIELD(CURR.ID, ".",2)
            O.DATA.VALUE := "\SER.NO EQ ":FIELD(CURR.ID, ".",3)
            IF Y.CUST.NEXT THEN
                O.DATA.VALUE := "\CUST.NO EQ ":Y.CUST.NEXT
            END
        END
        EB.Reports.setOData(O.DATA.VALUE)
    END
PROG.EXIT:
RETURN
*-----------------------------------------------------------------------------
END
