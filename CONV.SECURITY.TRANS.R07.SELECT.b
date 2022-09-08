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
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ET.Contract
    SUBROUTINE CONV.SECURITY.TRANS.R07.SELECT
*
* Selects the security trans record for conversion
*
*--------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_CONV.SECURITY.TRANS.R07.COMMON
    $INSERT I_F.COMPANY
    $INSERT I_ET.CONTRACT.COMMON        ;* Included Component Common
*-------------------------------------------------------------------
* 16/07/06 - CI_10042634
*            Conversion for security trans record
*
* 23/03/15 - EN 1269516 Task 1293594
*            Componentization project - PWM

*--------------------------------------------------------------------
*

    LOCATE 'ET' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING PROD.POSN THEN
        SELECT.CMD = ''
        SELECT.CMD = 'SELECT ' :FN.ET.SECURITY.TRANS :' WITH *A':START.FIELD:' NE "" OR *A':START.FIELD+2:' NE ""'
        TRANS.LIST = '' ; YSEL = ''
        CALL EB.READLIST(SELECT.CMD,TRANS.LIST,'',YSEL,'')
    END

    IF TRANS.LIST THEN
        CALL BATCH.BUILD.LIST('',TRANS.LIST)
    END

    RETURN
END
