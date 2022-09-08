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
* <Rating>66</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.Config
    SUBROUTINE CONV.AZ.PROD.PARAM.G15.0(APP.ID,APP.REC,YFILE)
************************************************************************************
*21/04/04 - EN_10002226
*           New conversion routine to default the value in LAST.DAY.INCL field in APP
*           from LAST.DAY.INCLUSIVE field in ACCOUNT.ACCRUAL file.
*
* 24/08/04 - BG_100007101
*            Fields introduced later made the LAST.DAY.INCL field from 91 to 101.
*            Hence the conversion did not run properly. Fixed the same.
*
************************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT.ACCRUAL
    $INSERT I_F.AZ.PRODUCT.PARAMETER
*
    GOSUB OPEN.FILES
    GOSUB READ.FILES
    GOSUB PROCESS.PARA
    RETURN
*
*==========
OPEN.FILES:
*==========
*Open the files here...
    FN.ACCOUNT.ACCRUAL = 'F.ACCOUNT.ACCRUAL' ; FV.ACCOUNT.ACCRUAL = ''
    CALL OPF(FN.ACCOUNT.ACCRUAL,FV.ACCOUNT.ACCRUAL)
    FN.AZ.ACCOUNT = 'F.AZ.ACCOUNT' ; FV.AZ.ACCOUNT = ''
    CALL OPF(FN.AZ.ACCOUNT,FV.AZ.ACCOUNT)
    RETURN
*
*==========
READ.FILES:
*==========
*Read the ACCOUNT.ACCRUAL file
    AC.ACCR.PARAM.ID = ''; AC.ACCR.ERR = ''
    CALL EB.READ.PARAMETER(FN.ACCOUNT.ACCRUAL,'N','',ACCOUNT.ACCRUAL.REC,AC.ACCR.PARAM.ID,FV.ACCOUNT.ACCRUAL,AC.ACCR.ERR)
    IF AC.ACCR.ERR THEN ACCOUNT.ACCRUAL.REC = ""
    RETURN
*============
PROCESS.PARA:
*============
    IF NOT(AC.ACCR.ERR) THEN
* In this rtn earlier app.rec<91> was set 'y'. But later 10 more fields were added. 
*So, this 'Y' was sitting in the wrong place. So, introduced the above line and made 91 to 101 in the below line....
	APP.REC<91> = ''  
	IF ACCOUNT.ACCRUAL.REC<2>= 'Y' THEN
            APP.REC<101> = 'Y'
        END
    END
    RETURN
END
