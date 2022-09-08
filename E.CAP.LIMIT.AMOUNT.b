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

* Version n dd/mm/yy  GLOBUS Release No. 200508 29/07/05
*-----------------------------------------------------------------------------
* <Rating>-15</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LI.ModelBank

    SUBROUTINE E.CAP.LIMIT.AMOUNT
*===========================================================================================================
* E.CAP.LIMIT.AMOUNT - This subroutine is called from both CUSTOMER.POSITION
*                      and CUSTOMER.POSITION.SUMMARY Enquiries. It returns the
*                      global limit amount, if it exists else returns the Maximum
*                      amount for the customer - O.DATA contains the CUSTOEMR.NO initially.
*
*===========================================================================================================
*
* 12/09/03 - CI_10012556
*            New Subroutime
*
* 15/03/05 - CI_10028246
*            Changes were done to include all the deal amounts of global limits
*            if more than one global limit exists.
* 07/06/05 - EN_10002549
*            GLOBAL.AMOUNT is built in CUS.BUILD.POSITION.DATA and stored in common.
*
*===========================================================================================================
*                      Insert Files
*===========================================================================================================
    $USING ST.Customer
    $USING EB.Reports

*===========================================================================================================
*                      Main Section
*===========================================================================================================

*--- If no global limit is defined, set the maximum amount.
    GLOBAL.AMT = ST.Customer.getCCustPosGlobalAmt()
    IF GLOBAL.AMT EQ 0 THEN           ; * EN_10002549
        EB.Reports.setOData(999999999999999); * Maximum amt
    END ELSE
        EB.Reports.setOData(GLOBAL.AMT); * EN_10002549
    END

    RETURN
*===========================================================================================================
    END
