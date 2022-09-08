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
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.StandingOrders

    SUBROUTINE CONV.STANDING.ORDER.G15.0(STO.ID,STO.REC,STO.FILE)
*******************************************************************
* 24/05/07 - CI_10049305
*            STANDING.ORDER field CURR.FREQ.DATE was not updated when
*            CONVERSION.PGMS are processed by RUN.CONVESION service.
*
* 09/02/15 - Enhancement 1214535 / Task 1218721
*            Moved the routine from FT to AC. Also included the Package name
*
********************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE

    EQU STO.CURRENT.FREQUENCY TO 6
    EQU STO.CURR.FREQ.DATE TO 97
    HIS.OR.NAU.FILE = INDEX(STO.FILE,'$',1)  ;* CI_10049305 S/E
    IF STO.REC<STO.CURRENT.FREQUENCY> AND NOT(HIS.OR.NAU.FILE) THEN ;* CI_10049305 S/E
        STO.REC<STO.CURR.FREQ.DATE> = STO.REC<STO.CURRENT.FREQUENCY>[1,8]
    END

    RETURN
    END
