* @ValidationCode : MjoxMDg0NTcxMzkwOkNwMTI1MjoxNTY0NTc4MDMxMzQ1OnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 18:30:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqSubmit
SUBROUTINE CONV.CHEQUE.BATCH.200706(CHEQUE.BATCH.ID,CHEQUE.BATCH.REC ,FILENAME)
* 13/03/07 - EN_10003259
*            Update FINAL.DATE as bank date if all the cheques in batch are
*            either cleared or returned.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Submit as ST_ChqSubmit and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    LAST.FOUR = FILENAME[4]
    IF LAST.FOUR = "$HIS" OR LAST.FOUR = "$NAU" THEN
        RETURN
    END
* only for LIVE records
    LOCATE 'CLEARING' IN CHEQUE.BATCH.REC<5,1> SETTING CLEARING.POS ELSE
        CHEQUE.BATCH.REC<14> = TODAY
    END
RETURN
END
