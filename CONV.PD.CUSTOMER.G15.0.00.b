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

*===============================================================
*-----------------------------------------------------------------------------
* <Rating>239</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PD.Config
    SUBROUTINE CONV.PD.CUSTOMER.G15.0.00(PD.ID, PD.REC, PD.FILE)
*===============================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE

*===============================================================
* Modifications

* 20/05/04 - EN_10002267
*            New conversion routine to populate PD.CUSTOMER
*
* 25/01/05 - BG_100007946
*            Converting this to RECORD.ROUTINE from FILE.ROUTINE.
*
* 23/09/05 - CI_10034974
*            Converting system.id record as company.id in
*            PD.PAYMENT.DUE during upgrade
*
* 25/10/07 - CI_10052160
*            Replacing F.WRITE with WRITE and F.READ with READ
*
* 27/12/07 - CI_10053130
*            PD.PARAM.ID is sent as NULL if 'SYSTEM' to get back the respective
*            company's parameter record thru EB.READ.PARAMETER.
*
* 15/12/08 - BG_100021299
*            Conversion fails while running RUN.CONVERSION.PGMS
*
*===============================================================


    IF FILE.TYPE NE '1' THEN RETURN
    GOSUB INITIALISE
    GOSUB PROCESS.PD.PAYMENT.DUE
    RETURN
*===============================================================
*==========
INITIALISE:
*==========
*
    EQU PD.CUSTOMER TO 2
    EQU PD.PARAMETER.RECORD TO 14
    FN.PD.CUSTOMER = 'F.PD.CUSTOMER'
    F.PD.CUSTOMER = ""
    CALL OPF(FN.PD.CUSTOMER,F.PD.CUSTOMER)
    FN.PD.PARAMETER = 'F.PD.PARAMETER'
    F.PD.PARAMETER = ""

    RETURN

*===============================================================
*=========================
PROCESS.PD.PAYMENT.DUE:
*=========================

    CUSTOMER.ID = PD.REC<PD.CUSTOMER>

    PD.PARAM.ID = PD.REC<PD.PARAMETER.RECORD>

    GOSUB GET.PARAM.ID

    IF CUSTOMER.ID THEN
        GOSUB UPDATE.PD.CUSTOMER
    END
    RETURN

*===============================================================
GET.PARAM.ID:

TRY.AGAIN:

    R$PD.PARAMETER = ""
    ETEXT = ""
    IF PD.PARAM.ID = 'SYSTEM' THEN
        PD.PARAM.ID = ''      ;* initialised to get back the respective company's parameter record
    END
    CALL EB.READ.PARAMETER(FN.PD.PARAMETER,'N','',R$PD.PARAMETER,PD.PARAM.ID,F.PD.PARAMETER,ETEXT)

    IF R$PD.PARAMETER = '' THEN
        PD.PARAM.ID = ""
        ETEXT = ""
        GOTO TRY.AGAIN
    END ELSE
        PD.REC<PD.PARAMETER.RECORD> = PD.PARAM.ID
    END

    RETURN

UPDATE.PD.CUSTOMER:
*==================

    R.PD.CUST = '' ; PD.CUST.ERR = ''

    READU R.PD.CUST FROM F.PD.CUSTOMER , CUSTOMER.ID
    ELSE R.PD.CUST = ''

    IF NOT(R.PD.CUST)  THEN
        R.PD.CUST = PD.ID
        GOSUB WRITE.RECORD
    END ELSE
        LOCATE PD.ID IN R.PD.CUST<1> BY "AR"  SETTING POS THEN
            RELEASE F.PD.CUSTOMER, CUSTOMER.ID
        END ELSE
            R.PD.CUST := FM: PD.ID
            GOSUB WRITE.RECORD
        END
    END
    RETURN
*===============================================================
WRITE.RECORD:
*==============
    WRITE R.PD.CUST ON F.PD.CUSTOMER , CUSTOMER.ID

    RETURN
*===============================================================
END
