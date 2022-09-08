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

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Reports
    SUBROUTINE E.SW.STORE.DISCOUNT.RATE(ENQUIRY.DATA)
*-----------------------------------------------------------------------------
*
* 30/12/15 - Enhancement 1226121
*		   - Task 1569212
*		   - Routine incorporated
*
    $USING EB.Reports


* store discount rate in DUM(1)
* remove DISCOUNT.RATE from selection
*
    DISCOUNT.RATE = ''
    LOCATE 'DISCOUNT.RATE' IN ENQUIRY.DATA<2,1> SETTING DPOS THEN
    DISCOUNT.RATE = ENQUIRY.DATA<4,DPOS>
    DEL ENQUIRY.DATA<2,DPOS>
    DEL ENQUIRY.DATA<4,DPOS>
    END
*
    EB.Reports.setDum(1, DISCOUNT.RATE)
*
    RETURN
*
    END
