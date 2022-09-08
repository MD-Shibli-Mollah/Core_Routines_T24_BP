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
* <Rating>-8</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ET.Contract
    SUBROUTINE CONV.SECURITY.TRANS.R07.LOAD

*----------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SPF
    $INSERT I_F.COMPANY
    $INSERT I_CONV.SECURITY.TRANS.R07.COMMON
    $INSERT I_ET.CONTRACT.COMMON        ;* Included Component Common
*-------------------------------------------------------
* 17/07/06 - CI_10042634
*            Conversion for security trans record
*
* 23/03/15 - EN 1269516 Task 1293594
*            Componentization project - PWM

*-------------------------------------------------------
*
    F.COMPANY = ''
    CALL OPF('F.COMPANY',F.COMPANY)

    FN.ET.SECURITY.TRANS = 'F.SECURITY.TRANS'
    F.ET.SECURITY.TRANS = ''
    CALL OPF(FN.ET.SECURITY.TRANS,F.ET.SECURITY.TRANS)

* Check out the previous release and process the conversion accordingly.
* Here start field and end field represents set of ET fields position in previous release
* Incre field represents number of fields to shift the set of ET fields in trans record

    PREVIOUS.RELEASE = R.SPF.SYSTEM<SPF.PREVIOUS.RELEASE>
    BEGIN CASE
    CASE PREVIOUS.RELEASE[1,5] = 'G13.2'
        START.FIELD = 90
        END.FIELD = 97
        INCRE.FIELD = 7
    CASE PREVIOUS.RELEASE[1,5] = 'G14.0'
        START.FIELD = 91
        END.FIELD =98
        INCRE.FIELD = 6
    CASE PREVIOUS.RELEASE[1,5] = 'G14.1'
        START.FIELD = 92
        END.FIELD =99
        INCRE.FIELD = 5
    CASE PREVIOUS.RELEASE[1,5] = 'R05.0'
        START.FIELD = 95
        END.FIELD = 102
        INCRE.FIELD = 2
    CASE 1
    END CASE
*
    RETURN
*
END
