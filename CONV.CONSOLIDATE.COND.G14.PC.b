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
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PC.Contract
    SUBROUTINE CONV.CONSOLIDATE.COND.G14.PC
*--------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PC.PERIOD
    $INSERT I_F.CONVERSION.DETAILS
    $INSERT I_F.COMPANY

*******************************************************************************
* Modifications:
*--------------
*
* 22/05/07 - BG_100013941 /Ref: TTS0706189
*            As the File F.CONSILDATE.COND.PC20001130 will be created only during cob
*            the select must be modified to pick only PC.PERIOD records less than today.
*
******************************************************************************



    PC.INSTALLED = ''
    LOCATE 'PC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING PC.INSTALLED ELSE
        PC.INSTALLED = ''
    END
*
    IF PC.INSTALLED THEN
        FN.PC.PERIOD = 'F.PC.PERIOD'
        FV.PC.PERIOD = ''
        CALL OPF(FN.PC.PERIOD,FV.PC.PERIOD)

        SEL.CMD = "SELECT ":FN.PC.PERIOD:" WITH PERIOD.STATUS EQ 'OPEN' AND @ID LT ":TODAY
        ID.LIST = '' ; NO.SEL = '' ; ERR = ''
        CALL EB.READLIST(SEL.CMD,ID.LIST,'',NO.SEL,ERR)
        LOOP
            REMOVE ID FROM ID.LIST SETTING YID
        WHILE ID:YID
            R.CONVERSION = ''
            R.CONVERSION<EB.CONV.FILE.NAME> = "CONSOLIDATE.COND.PC":ID
            R.CONVERSION<EB.CONV.OLD.CO.CODE.POS> = "44"
            R.CONVERSION<EB.CONV.NEW.CO.CODE.POS> = "46"
            R.CONVERSION<EB.CONV.RE.RUN.FLAG> = "YES"
            R.CONVERSION<EB.CONV.ADD.FIELD.START> = "38"
            R.CONVERSION<EB.CONV.ADD.FIELD.NO> = "2"
            CALL CONVERSION.DETAILS.RUN(R.CONVERSION)
        REPEAT
    END
    RETURN
END
