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
*-----------------------------------------------------------------------------
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ET.Contract
    SUBROUTINE CONV.SECURITY.TRANS.R07(TRANS.ID)
**********************************************************
* This record routine is attached in the CONVERSION.DETAILS
* record for SECURITY.TRANS. This routine will move the field values
* during conversion. This is for the ET clients upgrading from Lower releases to R06.
*
* 16/07/06 - CI_10042634
*            Conversion for security trans record
*
* 23/03/15 - EN 1269516 Task 1293594
*            Componentization project - PWM
*
* 02/03/16 - DEFECT:1649291 TASK:1650466
*            Compilation Warnings - Private Wealth (SEC,WEA)
****************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_CONV.SECURITY.TRANS.R07.COMMON
    $INSERT I_SC.SCOSECURITYPOSITIONUPDATE.COMMON
    $INSERT I_ET.CONTRACT.COMMON        ;* Included Component Common

* Select and Process each security trans record
    YERR = '' ; R.TRANS = '' ; R.SEC.TRANS = ''
    CALL F.READ('F.SECURITY.TRANS',TRANS.ID,R.TRANS,'',YERR)
    R.SEC.TRANS = R.TRANS
* This for loop is used to shift the set of ET fields to new position
    FOR FIELD.NO = START.FIELD TO END.FIELD
        R.SEC.TRANS<FIELD.NO+INCRE.FIELD> = R.TRANS<FIELD.NO>
    NEXT FIELD.NO
    UPTO.NEW.FIELD = (START.FIELD+INCRE.FIELD) - 1
* This for loop is used to populate null value for the newly introduced fields in trans record
    FOR NEW.FIELD.POS = START.FIELD TO UPTO.NEW.FIELD
        R.SEC.TRANS<NEW.FIELD.POS> = ''
    NEXT NEW.FIELD.POS
    WRITE R.SEC.TRANS TO F.SECURITY.TRANS, TRANS.ID
    END
