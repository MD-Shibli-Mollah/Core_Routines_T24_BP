* @ValidationCode : Mjo4NzEwOTQ3ODM6Q3AxMjUyOjE1MzgwNDY5NjU3NTU6c3RhbnVzaHJlZTotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxODA4LjIwMTgwNzIxLTEwMjY6LTE6LTE=
* @ValidationInfo : Timestamp         : 27 Sep 2018 16:46:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201808.20180721-1026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE ER.Config
SUBROUTINE CONV.ER.PARAMETER.G14.1(ID,REC,FILE)
*******************************************************
* 14/08/03 - EN_10001951
*            Conversion routine for populating values to the newly
*            added fields
*
* 09/10/08 - CI_10058109
*            CONVERSION.DETAIL correctly update the ER.PARAMETER record with id as COVER.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
* 08/08/18 - Enhancement-2702846
*			 Task-2703534
*            Movement from AC to ER.
*******************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ER.PARAMETER
*
    IF REC THEN
        R.TEMP = ''
        R.TEMP = REC
        REC<ER.PAR.MATCH.FIELD> = ''
        REC<ER.PAR.TOLERANCE> = ''
* FIRST LOWER THE EXISTING MATCH FIELD AND TOLERANCE
        MATCH.FIELD = LOWER(R.TEMP<13>)
        TOLERANCE = LOWER(R.TEMP<14>)
        REC<ER.PAR.MATCH.FIELD,1> = MATCH.FIELD
        REC<ER.PAR.TOLERANCE,1> = TOLERANCE
*
        IF ID = "SYSTEM" THEN
* extend these conditions to ER and EP
            REC<ER.PAR.EXP.FUNDS.TYPE,1> = "ER"
            REC<ER.PAR.EXP.TYPE.CR.DR,1> = "C"
            REC<ER.PAR.PAY.FUNDS.TYPE,1> = "RECEIPT"
            REC<ER.PAR.PAY.TYPE.CR.DR,1> = "D"
            REC<ER.PAR.ACCT.BAL.FIELD,1> = "ER"
*
            REC<ER.PAR.EXP.FUNDS.TYPE,-1> = "EP"
            REC<ER.PAR.EXP.TYPE.CR.DR,-1> = "D"
            REC<ER.PAR.PAY.FUNDS.TYPE,-1> = "PAYMENT"
            REC<ER.PAR.PAY.TYPE.CR.DR,-1> = "C"
            REC<ER.PAR.ACCT.BAL.FIELD,-1> = "EP"
            REC<ER.PAR.MATCH.FIELD,-1> = MATCH.FIELD
            REC<ER.PAR.TOLERANCE,-1> = TOLERANCE
*
            REC<ER.PAR.EXP.FUNDS.TYPE,-1> = "ERR"
            REC<ER.PAR.EXP.TYPE.CR.DR,-1> = "C"
            REC<ER.PAR.PAY.FUNDS.TYPE,-1> = "RR"
            REC<ER.PAR.PAY.TYPE.CR.DR,-1> = "D"
            REC<ER.PAR.ACCT.BAL.FIELD,-1> = "ER"
*
* For the new funds type 'VALUE.DATE' is an optional input
*
            CTR = DCOUNT(REC<ER.PAR.EXP.FUNDS.TYPE>, VM)
            REC<ER.PAR.MATCH.FIELD,CTR,-1> = 'ACCOUNT.ID'
            REC<ER.PAR.TOLERANCE,CTR,-1> = ''
            REC<ER.PAR.MATCH.FIELD,CTR,-1> = 'CCY.AMOUNT'
            REC<ER.PAR.TOLERANCE,CTR,-1> = ''
        END
    END
*
RETURN
*
END
