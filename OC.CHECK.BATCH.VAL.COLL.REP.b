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
* <Rating>-11</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.CHECK.BATCH.VAL.COLL.REP(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 18/09/15 - Enhancement 1461371 / Task 1461382
*            OTC Collateral and Valuation Reporting.
*
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine
*
* 14/07/16 - Defect 1523549 / Task 1562086
*			 MTM value 1 & MTM value 2 updation in OC.VAL.COLL.DATA enquiry.
*-----------------------------------------------------------------------------
    
    
    $USING EB.Service 


*-----------------------------------------------------------------------------

    RET.VAL = 0;*to block online update of OC.VAL.COLL.DATA and during other txn processing.
    BATCH.VAL = EB.Service.getBatchInfo()<1>
 
   IF INDEX(BATCH.VAL,'OC.UPD.VAL.COLL.REPORT',1) THEN

        RET.VAL = 1 ;*update OC.VAL.COLL.DATA only during the batch OC.UPD.VAL.COLL.REPORT.

    END


    RETURN
