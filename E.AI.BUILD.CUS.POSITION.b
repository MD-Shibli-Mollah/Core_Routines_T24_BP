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
* <Rating>-16</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE E.AI.BUILD.CUS.POSITION(ENQ.DATA)
*-----------------------------------------------------------------------------

*08/03/12  - Task 368888
*            This build routine is attached in enquiry AI.CUSTOMER.POS.SUMMARY which
*            is linked to Corporate ARC IB page.This routine will build the data in CUSTOMER.POSTION
*            file for Corporate Customer.
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------

    $USING ST.Customer

    DEFFUN System.getVariable()

    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
PROCESS:

    LOCATE 'REBUILD.DATA' IN ENQ.DATA<2,1> SETTING RB.POS THEN
    REBUILD = ENQ.DATA<4,RB.POS>
    END ELSE
    REBUILD = 'Y'
    END

    Y.CUS.ID = "EXT.SMS.CUSTOMERS"
    Y.CUS.VALUE = System.getVariable(Y.CUS.ID)
    IF REBUILD[1,1] NE 'N' THEN
        LOCATE "CUSTOMER.NO" IN ENQ.DATA<2,1> SETTING CUST.POS THEN
        ENQ.DATA<4,CUST.POS> = Y.CUS.VALUE
    END ELSE
        ENQ.DATA<2,1> = "CUSTOMER.NO"
        ENQ.DATA<3,1> = "EQ"
        ENQ.DATA<4,1> = Y.CUS.VALUE
    END
    ST.Customer.setCCustPosUpdateXref(0)
    Y.CUS.VALUE := @FM:ENQ.DATA
    CUST.ID = Y.CUS.VALUE
    ST.Customer.CusBuildPositionData(CUST.ID)
    ST.Customer.setCCustPosUpdateXref(1)
    END

    RETURN
*-----------------------------------------------------------------------------
    END
