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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DC.ModelBank
    SUBROUTINE E.C.GET.CR.DR.IND

    $USING DC.ModelBank
    $USING EB.Reports

    DC.AMOUNT = EB.Reports.getOData()

    IF DC.AMOUNT EQ '' THEN
        EB.Reports.setOData('')
        RETURN
    END
	
    BEGIN CASE
        CASE DC.AMOUNT GT 0
            EB.Reports.setOData('CR')
        CASE DC.AMOUNT LT 0
            EB.Reports.setOData('DR')
        CASE 1
            EB.Reports.setOData('')
    END CASE
    RETURN
