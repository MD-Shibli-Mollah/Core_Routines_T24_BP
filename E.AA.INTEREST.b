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
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.INTEREST

    $USING EB.Reports

*
    COMMON /AAINTENQ/ARR.ID
*
    EB.Reports.setRRecord(EB.Reports.getOData())
  	tmp = EB.Reports.getRRecord()
	CONVERT "*" TO @FM IN tmp
	
 	tmp<20>=ARR.ID; EB.Reports.setRRecord(tmp)
 	    RETURN
    END
