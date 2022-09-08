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
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.ACTION.TYPE.DETAILS(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)


* Modification History :
*
*07/07/15 - Defect 1385774 / Task 1400761
*           Creation of routine to fetch the first multivalue
*           from ADDL.REP.INFO field.
*
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine
*-----------------------------------------------------------------------------
	$USING OC.Reporting

    RET.VAL= TXN.DATA<1,1> 

    RETURN

