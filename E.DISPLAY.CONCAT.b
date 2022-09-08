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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.CashFlow
    SUBROUTINE E.DISPLAY.CONCAT
*
* Subroutine to convert concat record to multi.valued for
* display by enquiries.
*
*------------------------------------------------------------------------

    $USING EB.Reports
    $USING EB.SystemTables
*
*------------------------------------------------------------------------
*
    R.RECORD.VAL = EB.Reports.getRRecord()
    CONVERT @FM TO @VM IN R.RECORD.VAL     ; * Concat to multivalue
    EB.Reports.setRRecord(R.RECORD.VAL)
    EB.Reports.setVmCount(DCOUNT(R.RECORD.VAL,@VM)); * Number of multi values

*
    RETURN
*
*------------------------------------------------------------------------
    END
