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

* Version 3 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FD.Contract
    SUBROUTINE CONV.FD.FID.ORDER(FD.ORD.ID, FD.ORD.REC, FD.ORD.FILE)
*-----------------------------------------------------------------------------
* This is a conversion routine used to update the POOLING.NOTICE field
* for existing FD.FID.ORDER. Since POOLING.NOTICE idescriptor is removed
* and introduced as a new field.
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB INITIALISE
    GOSUB SET.POOLING.NOTICE
    RETURN

*-----------------------------------------------------------------------------
INITIALISE:

    EQU FD.ORD.POOLING.NOTICE TO 82
    EQU FD.ORD.FID.TYPE TO 2
    EQU FD.ORD.FIDUCIARY.NO TO 54
    EQU FD.ORD.PRIN.CHANGE TO 65
    EQU FD.ORD.CHANGE.STATUS TO 67
    EQU FD.ORD.REIMBURSE.DATE TO 68
    EQU FD.ORD.REIMBURSE.STATUS TO 69
    RETURN

*-----------------------------------------------------------------------------
SET.POOLING.NOTICE: * to set field value

    IF FD.ORD.REC<FD.ORD.POOLING.NOTICE> EQ '' THEN         ;* Since this field was not present in existing record

* The following condition is given in FD.ORDER.CROSSVAL for new records.
        IF FD.ORD.REC<FD.ORD.FID.TYPE> = "NOTICE" AND (FD.ORD.REC<FD.ORD.FIDUCIARY.NO> = "" OR (FD.ORD.REC<FD.ORD.REIMBURSE.STATUS> = "REQUESTED" AND FD.ORD.REC<FD.ORD.REIMBURSE.DATE> <> "") OR (INDEX(FD.ORD.REC<FD.ORD.CHANGE.STATUS>,"REQUESTED",1) <> 0 AND FD.ORD.REC<FD.ORD.PRIN.CHANGE> <> "")) THEN
            FD.ORD.REC<FD.ORD.POOLING.NOTICE> = 1
        END ELSE
            FD.ORD.REC<FD.ORD.POOLING.NOTICE> = 0 ;* fixed type
        END
    END
    RETURN
END
