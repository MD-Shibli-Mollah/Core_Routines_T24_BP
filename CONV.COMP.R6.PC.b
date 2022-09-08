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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PC.Contract
    SUBROUTINE CONV.COMP.R6.PC(Y.ID, R.PC.PERIOD, F.PC.PERIOD)
*-----------------------------------------------------------------------------
* This conversion will introduce one new field at 66 in COMPANY.PC<<pc.period>>
* records. This is copy of what the core actual conversion CONV.COMP.R6 will do.
*
* 31/07/08 - GLOBUS_CI_10057053
*            New conversion routine
*
* 27/08/08 - CI_10057478
*            For NAU & HIS files, process is not necessary
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CONVERSION.DETAILS

    BEGIN CASE
    CASE NOT(Y.ID LT TODAY AND R.PC.PERIOD<1> EQ 'OPEN')
        RETURN
    CASE F.PC.PERIOD[4] EQ "$HIS"
        RETURN
    CASE F.PC.PERIOD[4] EQ "$NAU"
        RETURN
    END CASE

*   Just populate those fields in CONVERSION.DETAILS and call .RUN routine
*   to do the actual conversion.
    R.CONVERSION = ''
    R.CONVERSION<EB.CONV.FILE.NAME> = "COMPANY.PC":Y.ID
    R.CONVERSION<EB.CONV.OLD.CO.CODE.POS> = "71"
    R.CONVERSION<EB.CONV.NEW.CO.CODE.POS> = "72"
    R.CONVERSION<EB.CONV.RE.RUN.FLAG> = "YES"
    R.CONVERSION<EB.CONV.ADD.FIELD.START> = "66"
    R.CONVERSION<EB.CONV.ADD.FIELD.NO> = "1"
    CALL CONVERSION.DETAILS.RUN(R.CONVERSION)

    RETURN
*-----------------------------------------------------------------------------
END
