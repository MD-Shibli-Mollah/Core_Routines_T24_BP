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
* <Rating>257</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Contract
    SUBROUTINE CONV.DR.DISC.AMEND.G14.0(DR.AMEND.ID,DISC.AMEND.REC,DR.AMEND.FILE)

* 13/01/05 - CI_10026338
*            Limit should be updated from DR.DISC.AMENDMENTS during
*            unauthorised stage only.
* 19/12/06 - CI_10046199
*            Crash in LIMIT.UPDATE
*



    $INSERT I_EQUATE
    $INSERT I_COMMON


* Process only records in 'NA' Status only.
    EQU DISC.DR.RECORD.STATUS TO 59
    IF DISC.AMEND.REC<DISC.DR.RECORD.STATUS>[2,2] <> 'NA' THEN RETURN

    GOSUB OPEN.FILES

* Don't proceed for 'SP' drawings
    IF DR.RECORD<1> = 'SP' THEN RETURN

    GOSUB PROCESS.LIMITS.INITIALISE
    IF CUSTOMER.NUMBER THEN   ;* CI_10046199
        GOSUB PROCESS.LIMITS
    END   ;* CI_10046199

    V$FUNCTION= SAVE.V$FN
    ID.NEW = SAVE.ID.NEW
    RETURN          ;* Main return

*----------
OPEN.FILES:
*----------


    FN.DRAWINGS ='F.DRAWINGS' ; FV.DRAWINGS =''
    CALL OPF(FN.DRAWINGS, FV.DRAWINGS)

    DR.ID = DR.AMEND.ID[1,14]

    CALL F.READ(FN.DRAWINGS, DR.ID, DR.RECORD,  FV.DRAWINGS, DR.ERR )

    RETURN

*-------------------------
PROCESS.LIMITS.INITIALISE:
*-------------------------

    EQU TF.DR.CUSTOMER.LINK TO  100 ,  TF.DR.LIMIT.REFERENCE TO 68

    EQU DISC.DR.DRAW.CURRENCY TO 1 , DISC.DR.DOCUMENT.AMOUNT TO 2,
    DISC.DR.MATURITY.DATE TO  4,  DISC.DR.NEW.MATURITY.DATE TO 15

    EQU EB.CUS.CUSTOMER.LIABILITY   TO 25

    SAVE.V$FN = V$FUNCTION
    SAVE.ID.NEW = ID.NEW
    V$FUNCTION = 'I'
    LIMIT.KEY = DR.ID
    LIAB.NO = ''
    ID.NEW = DR.AMEND.ID
    RETURN.CODE = ''
    CUSTOMER.NUMBER = DR.RECORD<TF.DR.CUSTOMER.LINK>
    POS = INDEX(DR.RECORD<TF.DR.LIMIT.REFERENCE>,'.',1)
    REF.NO = DR.RECORD<TF.DR.LIMIT.REFERENCE>[1,POS-1]
    SERIAL.NO = DR.RECORD<TF.DR.LIMIT.REFERENCE>[POS+1,9]
    CALL DBR('CUSTOMER':FM:EB.CUS.CUSTOMER.LIABILITY,CUSTOMER.NUMBER,LIAB.NO)
    ONLINE.MAT = ''
    IF DISC.AMEND.REC<DISC.DR.NEW.MATURITY.DATE> LE TODAY THEN ONLINE.MAT = 1
    OPE = ''
    DRAW.CCY = DISC.AMEND.REC<DISC.DR.DRAW.CURRENCY>
    RETURN

*--------------
PROCESS.LIMITS:
*--------------

* Reverse Old limit ie limit hit by drawings .
    OPE = 'DEL'
    LIMIT.AMOUNT = DISC.AMEND.REC<DISC.DR.DOCUMENT.AMOUNT>
    PASS.DATE = DISC.AMEND.REC<DISC.DR.MATURITY.DATE>
    GOSUB LIMIT.CHECK

* Update limit for new maturity date
    IF NOT(ONLINE.MAT) THEN

        OPE = 'VAL'
        LIMIT.AMOUNT = DISC.AMEND.REC<DISC.DR.DOCUMENT.AMOUNT>
        PASS.DATE = DISC.AMEND.REC<DISC.DR.NEW.MATURITY.DATE>
        GOSUB LIMIT.CHECK
    END
    RETURN

*------------
LIMIT.CHECK:
*------------

    CALL LIMIT.CHECK(LIAB.NO,CUSTOMER.NUMBER,REF.NO,SERIAL.NO,
    LIMIT.KEY,PASS.DATE,DRAW.CCY,-LIMIT.AMOUNT,
    '','','','','','','','','U',OPE,RETURN.CODE)
    RETURN

END
