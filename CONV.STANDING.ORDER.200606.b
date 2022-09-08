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

* Version n dd/mm/yy  GLOBUS Release No. 200606 05/06/06
*-----------------------------------------------------------------------------
* <Rating>64</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.StandingOrders

    SUBROUTINE CONV.STANDING.ORDER.200606(ID.VAR, R.STANDING.ORDER, F.STO)

* This conversion routine will be called from the CONVERSION.DETAILS record
* CONV.STANDING.ORDER.200606. It will Write the file STO.FREQ.DATE with id as CURR.FREQ.DATE*STANDING.ORDER.ID.
* It has been written as part of CD EN_10002959. Now the COB processing will select this file with a
* filter mechanism to process the STOs.
*-----------------------
* Modification log:
*----------------------
*
* 25/07/07 - BG_100014725
*            This Routine has been changed as RECORD routine.
*
* 31/01/08 - CI_10053518
*            Additional fix to the CD BG_100014725. Removed OPF stmt of STANDING.ORDER
*            which is not necessary.
*
* 09/06/09 - CI_10063470
*            STO.FREQ.DATE is getting built for the records that does not have frequency field
*            updated.
*
* 09/02/15 - Enhancement 1214535 / Task 1218721
*            Moved the routine from FT to AC. Also included the Package name
*
*---------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STANDING.ORDER

*****************************************************************************
    SAVE.ID.COMPANY = ID.COMPANY

    GOSUB INITIALISE
    GOSUB MAIN.PROCESS

    IF SAVE.ID.COMPANY NE ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END
    RETURN
******************************************************************************

INITIALISE:
**********
* opening file STANDING.ORDER
    CURR.COMPANY = R.STANDING.ORDER<STO.CO.CODE>
    IF CURR.COMPANY NE ID.COMPANY THEN
        CALL LOAD.COMPANY(CURR.COMPANY)
    END
* opening file STO.FREQ.DATE
    FN.STO.FREQ.DATE = 'F.STO.FREQ.DATE'
    F.STO.FREQ.DATE = ''
    R.STO.FREQ.DATE = ''
    CALL OPF(FN.STO.FREQ.DATE,F.STO.FREQ.DATE)
    RETURN
*********************************************************************************

MAIN.PROCESS:
************

    IF FILE.TYPE NE 1 OR R.STANDING.ORDER<STO.CURR.FREQ.DATE> EQ '' THEN
        RETURN
    END

    Y.STO.FREQ.DATE = R.STANDING.ORDER<STO.CURR.FREQ.DATE>:'*':ID.VAR
    READ R.STO.FREQ.DATE FROM F.STO.FREQ.DATE, Y.STO.FREQ.DATE ELSE R.STO.FREQ.DATE = 1
        IF R.STO.FREQ.DATE THEN
            R.STO.FREQ.DATE = ''
            WRITE R.STO.FREQ.DATE TO F.STO.FREQ.DATE, Y.STO.FREQ.DATE
            END
            RETURN
