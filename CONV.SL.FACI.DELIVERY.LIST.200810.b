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
    $PACKAGE SL.Delivery
    SUBROUTINE CONV.SL.FACI.DELIVERY.LIST.200810(SL.ID,SL.REC,SL.FILE)
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*-----------------------------------------------------------------------------
* 08/09/08 - BG_100019840
*            Conversion routine for SL.FACI.DELIVERY.LIST IDs
*
* 22/09/08 - BG_100020048
*            SL.FACI.DELIVERY.LIST records are not converted properly
*
*-----------------------------------------------------------------------------
    FILE.VAR= ''
    CONT.I = ''     ;* BG_100020048 - S/E
    CALL OPF(SL.FILE,FILE.VAR)
    NO.OF.CONT =COUNT(SL.REC,FM)        ;* count the no of contracts on the same date
    FOR CONT.I=1 TO NO.OF.CONT
        WRITE SL.REC<CONT.I> TO FILE.VAR,SL.ID:"-":SL.REC<CONT.I>     ;* write the record with ID as date-contracrt$id
    NEXT CONT.I
    DELETE FILE.VAR,SL.ID     ;* delete the existing record from the list
    SL.ID = SL.ID:"-":SL.REC<CONT.I+1>  ;* BG_100020048 - S
    SL.REC = SL.REC<CONT.I+1> ;* BG_100020048 - E
    RETURN

END
