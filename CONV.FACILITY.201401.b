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

*----------------------------------------------------------
* <Rating>-1</Rating>
*----------------------------------------------------------
    $PACKAGE SL.Facility
    SUBROUTINE CONV.FACILITY.201401(FAC.ID, FAC.REC, SLL.FILE)
*----------------------------------------------------------
*** <region name= Modifications>
*** <desc> </desc>
*
* * Modifications
*** </region>
***********************************************************
*** <region name= Inserts>
*** <desc>Inserts </desc>

    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU FAC.PARTICIPANT.LIMIT TO 41
*** Assign the participant limit to 'NO' for existing contracts
    IF FAC.REC<FAC.PARTICIPANT.LIMIT> EQ '' THEN
        FAC.REC<FAC.PARTICIPANT.LIMIT> = 'NO'
    END
*** </region>
    RETURN
END
