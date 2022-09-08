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
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Pricing
    SUBROUTINE CONV.DX.MARKET.PRICE.R16(YID, R.RECORD, FN.FILE)
*-----------------------------------------------------------------------------
*This routine will handel the conversion of multivalue fields to subvalue in DX.MARKET.PRICE
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*-----------------------------------------------------------------------------
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc> </desc>
INITIALISE:

    R.NEW.RECORD = R.RECORD
    FLD.POS = ''

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
*** <desc> </desc>
PROCESS:

    FOR FLD.POS = 11 TO 16 ;* From 11th TO 16th are to be moved to subvalue
        R.NEW.RECORD<FLD.POS> = LOWER(R.RECORD<FLD.POS>)
    NEXT FLD.POS

    R.RECORD = R.NEW.RECORD ;* Pass back changed record

    RETURN
*** </region>
    END
