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
    $PACKAGE MD.Foundation

    SUBROUTINE CONV.MD.INVOCATION.HIST.201512(MD.INV.ID, MD.INV.REC, MD.INV.FILE)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/11/15 - Task : 1529827
*            Addition of new field - INV.STATUS in MD.INVOCATION.HIST.
*            This field to be defaulted as EXECUTE in existing records.
*            Enhancement : 1270195
*
*-----------------------------------------------------------------------------

    EQU MD.INV.INV.STATUS TO 1
    EQU MD.INV.AMOUNT TO 2
*-----------------------------------------------------------------------------
    NO.OF.INV = ''
    INV.IDX = ''
    
    NO.OF.INV = DCOUNT(MD.INV.REC<MD.INV.AMOUNT>,@VM)
    FOR INV.IDX = 1 TO NO.OF.INV

        IF MD.INV.REC<MD.INV.INV.STATUS,INV.IDX> EQ '' THEN   ;* Invocation Status being Null indicates Settled claims in existing records
            MD.INV.REC<MD.INV.INV.STATUS,INV.IDX> = 'EXECUTE'    ;* Default the Status - EXECUTE
        END

    NEXT INV.IDX
    
    RETURN

    END
