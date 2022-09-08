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

* Version 4 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE E.BUILD.CUS.POSITION(ENQUIRY.DATA)
*-----------------------------------------------------------------------------

*
** 19/12/97 - GB9701470
**            Build the data dependent on the rebuild flag being set
*
*  08/06/05 - EN_10002549
*             Set C$CUS.POS.UPDATE.XREF to 0, so that cache is used
*             instead on CUSTOMER.POSITION.XREF.
*
* 16/10/09 - EN_10004397
*            The enquiry CUSTOMER.POSITION and CUSTOMER.POSITION.SUMMARY should include those
*            exposures also for which the queried customer is a joint holder. To build customer
*            position based on the input to enquiry, ENQUIRY.DATA is passed.
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 30/05/16 - Defect 1643551 / Task 1747487
* 			 Introduced new common variable C$ENQUIRY.NAME to store the enquiry name correctly.
*
*-----------------------------------------------------------------------------

    $USING EB.Reports
    $USING ST.Customer

    LOCATE 'REBUILD.DATA' IN ENQUIRY.DATA<2,1> SETTING RB.POS THEN
        REBUILD = ENQUIRY.DATA<4,RB.POS>
    END ELSE
        REBUILD = 'Y'
    END
    IF REBUILD[1,1] NE 'N' THEN             ; * Do not execute on level dwon
        LOCATE "CUSTOMER.NO" IN ENQUIRY.DATA<2,1> SETTING CUS.POS THEN
            CUST.ID = ENQUIRY.DATA<4,CUS.POS>
            CONVERT " " TO @VM IN CUST.ID
            IF DCOUNT(CUST.ID,@VM) GT 1 OR CUST.ID = "ALL" THEN
                EB.Reports.setEnqError("ONLY ONE CUSTOMER ALLOWED")
            END ELSE
                ST.Customer.setCCustPosUpdateXref(0)	;* EN_10002549
                ENQ.NAME = ENQUIRY.DATA<1>
                ST.Customer.setCEnquiryName(ENQ.NAME)        
                CUST.ID := @FM:ENQUIRY.DATA
                ST.Customer.CusBuildPositionData(CUST.ID)
                ST.Customer.setCCustPosUpdateXref(1)        ;* EN_10002549(1)       ;* EN_10002549 Reset to 1
            END
        END
    END
*
    RETURN
*
*-----------------------------------------------------------------------------
    END
