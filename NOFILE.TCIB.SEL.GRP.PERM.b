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
* <Rating>-47</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE NOFILE.TCIB.SEL.GRP.PERM(OUT_ARRAY)
*-----------------------------------------------------------------------
* SUBROUTINE TYPE       : NOFILE ENQUIRY
* Attached to           : STANDARD.SELECTION record NOFILE.TCIB.SEL.GRP.PERM
* Incoming              : N/A
* Outgoing              : Customer and Group Id Details
*---------------------------------------------------------------------------------------------
* Description:
* Group Id and Customer Details
*-----------------------------------------------------------------------------
* Modification History
* * 01/07/14 - Enhancement 1001222/Task 1001223
*              TCIB : User management enhancements and externalisation
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*-----------------------------------------------------------------------
    $USING EB.Reports
    $USING ST.Customer

*-----------------------------------------------------------------------
    GOSUB INITIALIZE
    GOSUB OPEN.FILES
    GOSUB MAIN.PROCESS
*
    RETURN
*-------------------------------------------------------------------------------------------------------------------------
INITIALIZE:
*Initialsie Required variables
    FLAG = "*"
*
    RETURN
*-------------------------------------------------------------------------------------------------------------------------
OPEN.FILES:
*Open Required Files

    RETURN
*-------------------------------------------------------------------------------------------------------------------------
MAIN.PROCESS:
* Form group Id
    LOCATE "GROUP.INPUT" IN EB.Reports.getDFields()<1> SETTING ENQ.POS THEN
    GROUP.NAME=UPCASE(EB.Reports.getDRangeAndValue()<ENQ.POS>)       ;* To get group name
    END
    LOCATE "CUSTOMER" IN EB.Reports.getDFields()<1> SETTING ENQ.POS THEN
    CUSTOMER.ID = EB.Reports.getDRangeAndValue()<ENQ.POS>  ;* To get Custome Id
    R.CUST = ST.Customer.Customer.Read(CUSTOMER.ID, CUS.ERR)      ;* To read customer record
    IF (R.CUST = "" OR CUS.ERR NE "") THEN
        EB.Reports.setEnqError("EB-WRONG.ID.FORMAT")
        RETURN
    END
    END
    GROUP.ID= CUSTOMER.ID : "-" : GROUP.NAME      ;* Form group id with customer Id and Group name
    OUT_ARRAY= GROUP.ID : FLAG : "accepted"
*
    RETURN
* -------------------------------------------------------------------------------------------------------------
    END
