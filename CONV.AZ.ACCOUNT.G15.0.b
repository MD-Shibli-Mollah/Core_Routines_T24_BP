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
* <Rating>41</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.Contract
    SUBROUTINE CONV.AZ.ACCOUNT.G15.0(AZ.ID,AZ.REC,YFILE)
************************************************************************************
*21/04/04 - EN_10002226
*           New conversion routine to default the value in LAST.DAY.INCL field in AZ
*           from LAST.DAY.INCLUSIVE field in ACCOUNT.ACCRUAL file.
*           Also update the AZ.CUSTOMER file for AZ.ACCOUNT file only
*
* 19/05/04 - EN_10002256
*            Update AZ.REPAY.ACCOUNT concat file for AZ.ACCOUNT.
*
************************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT.ACCRUAL
    $INSERT I_F.AZ.ACCOUNT
*
    GOSUB OPEN.FILES
    GOSUB READ.FILES
    GOSUB PROCESS.PARA
    IF NOT(INDEX(YFILE,'$',1)) THEN
        GOSUB UPDATE.AZ.CUSTOMER
        GOSUB UPDATE.AZ.REPAY.ACCT
    END
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
        IF ACCOUNT.ACCRUAL.REC<2>= 'Y' THEN
            AZ.REC<96> = 'Y'
        END
    END
    RETURN

*==================
UPDATE.AZ.CUSTOMER:
*==================

    FN.AZ.CUSTOMER = 'F.AZ.CUSTOMER'    ;*
    FV.AZ.CUSTOMER = ''
    CALL OPF(FN.AZ.CUSTOMER, FV.AZ.CUSTOMER)
    CUS.ID = AZ.REC<1>        ;* Assign the customer number

    CALL F.READ(FN.AZ.CUSTOMER,CUS.ID,R.AZ.CUSTOMER,FV.AZ.CUSTOMER,CUS.ERR)     ;* Read az customer without lock
    IF R.AZ.CUSTOMER THEN
        LOCATE AZ.ID IN R.AZ.CUSTOMER SETTING POS ELSE      ;* check AZ number already insert or not
            CALL F.READU(FN.AZ.CUSTOMER,CUS.ID,R.AZ.CUSTOMER,FV.AZ.CUSTOMER,CUS.ERR,'')   ;* Read az customer with lock
            R.AZ.CUSTOMER := FM:AZ.ID
            CALL F.WRITE(FN.AZ.CUSTOMER,CUS.ID,R.AZ.CUSTOMER)         ;* write a new record
        END
    END ELSE        ;* first time
        R.AZ.CUSTOMER = AZ.ID
        CALL F.WRITE(FN.AZ.CUSTOMER,CUS.ID,R.AZ.CUSTOMER)   ;* write a new record
    END

    RETURN

*===================
UPDATE.AZ.REPAY.ACCT:
*===================

    ACCT.ID = AZ.REC<AZ.REPAY.ACCOUNT>
    IF ACCT.ID THEN
        FN.AZ.REPAY.ACCOUNT = 'F.AZ.REPAY.ACCOUNT'
        FV.AZ.REPAY.ACCOUNT = ''
        CALL OPF(FN.AZ.REPAY.ACCOUNT,FV.AZ.REPAY.ACCOUNT)

        CALL F.READ(FN.AZ.REPAY.ACCOUNT,ACCT.ID,R.AZ.REPAY.ACCT,FV.AZ.REPAY.ACCOUNT,ACCT.ERR)

        IF R.AZ.REPAY.ACCT THEN
            LOCATE AZ.ID IN R.AZ.REPAY.ACCT SETTING RA.POS ELSE
                CALL F.READU(FN.AZ.REPAY.ACCOUNT,ACCT.ID,R.AZ.REPAY.ACCT,FV.AZ.REPAY.ACCOUNT,ACCT.ERR,'')
                R.AZ.REPAY.ACCT := FM:AZ.ID
                CALL F.WRITE(FN.AZ.REPAY.ACCOUNT,ACCT.ID,R.AZ.REPAY.ACCT)
            END
        END ELSE
            R.AZ.REPAY.ACCT = AZ.ID
            CALL F.WRITE(FN.AZ.REPAY.ACCOUNT,ACCT.ID,R.AZ.REPAY.ACCT)
        END
    END
    RETURN

END
