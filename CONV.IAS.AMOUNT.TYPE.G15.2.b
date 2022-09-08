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
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IA.Accounting
    SUBROUTINE CONV.IAS.AMOUNT.TYPE.G15.2
*********************************************************
* Conversion routine to default values for flds LCY.AMT.TYPE,
* ACCTNG.STAGE , ACCTNG.TYPE in IAS.AMOUNT.TYPES
*
**********************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.IAS.AMOUNT.TYPE
***********************************************************

MAIN:
*****
    GOSUB INIT

    SEL.COMMAND = 'SELECT F.IAS.AMOUNT.TYPE'
    AMOUNT.TYPES = ''
    CALL EB.READLIST(SEL.COMMAND,AMOUNT.TYPES,"", "" , "" )
    IF AMOUNT.TYPES THEN
        LOOP
            REMOVE AMT.TYPE FROM AMOUNT.TYPES SETTING MORE.AMT
        WHILE AMT.TYPE:MORE.AMT
            R.AMOUNT.TYPE = ''
            READ.ERR = ''
            CALL F.READ(FN.IAS.AMOUNT.TYPE,AMT.TYPE,R.AMOUNT.TYPE,F.IAS.AMOUNT.TYPE,READ.ERR)
            IF NOT(READ.ERR)  THEN
                R.AMOUNT.TYPE<IAS.AT.LCY.AMT.TYPE> = 'N'
                R.AMOUNT.TYPE<IAS.AT.ACCTNG.STAGE> = 'AT-INP'
                R.AMOUNT.TYPE<IAS.AT.ACCTNG.TYPE> = 'NON-CONTINGENT'
		WRITE R.AMOUNT.TYPE TO F.IAS.AMOUNT.TYPE , AMT.TYPE
            END ELSE
                GOSUB FATAL.ERROR
            END
        REPEAT
    END

    RETURN
**************************************************************
INIT:
******
    FN.IAS.AMOUNT.TYPE = 'F.IAS.AMOUNT.TYPE'
    F.IAS.AMOUNT.TYPE = ''
    CALL OPF(FN.IAS.AMOUNT.TYPE,F.IAS.AMOUNT.TYPE)

    RETURN
****************************************************************
FATAL.ERROR:
************
    CALL FATAL.ERROR('CONV.IAS.AMOUNT.TYPE.G15.2')

    RETURN
****************************************************************
END
