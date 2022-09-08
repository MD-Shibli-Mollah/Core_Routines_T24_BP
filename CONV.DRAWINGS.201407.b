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
* <Rating>-14</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Contract
    SUBROUTINE CONV.DRAWINGS.201407(DRAW.ID,R.DR.REC,YFILE)
*** <region name= Modifications>
*** <desc> </desc>
*
* Modifications
*
* 21/4/14 - TASK : 893997
*           Import LC to default documents and others based on incoterms and mode of shipment in Drawings application
*           REF : 893344
*
*** </region>
*-------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>

    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU TF.DR.DRAWING.TYPE TO 1
    EQU TF.DR.DISCREPANCY TO 33
    EQU TF.DR.CON.DISCREPANCY TO 267

*
*** </region>
*---------------------------------------------------------------------------
*** <region name= Populate fields>
*** <desc>Populate the fields during conversion </desc>

    GOSUB POPULATE.DR.FIELDS
    RETURN
*** </region>
*---------------------------------------------------------------------------
*** <region name= POPULATE.DR.FIELDS>
*** <dec> </desc>
*==================
POPULATE.DR.FIELDS:
*==================
    IF R.DR.REC<TF.DR.DRAWING.TYPE> EQ 'CO' THEN
        NO.OF.DISC = DCOUNT(R.DR.REC<TF.DR.DISCREPANCY>,VM)
        FOR DISC.TXT = 1 TO NO.OF.DISC
            R.DR.REC<TF.DR.CON.DISCREPANCY,DISC.TXT> = R.DR.REC<TF.DR.DISCREPANCY,DISC.TXT>
        NEXT DISC.TXT
    END
    RETURN
*** </region>
*---------------------------------------------------------------------------
    END
