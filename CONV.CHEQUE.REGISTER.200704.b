* @ValidationCode : MjotMTA3ODkwNDA5MjpDcDEyNTI6MTU2NDU3ODAzMTM3NjpzcmF2aWt1bWFyOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMDotMTotMQ==
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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqSubmit
SUBROUTINE CONV.CHEQUE.REGISTER.200704(CI.ID,CI.REC,YFILE)

********************************************************************************
* 07/02/07 - EN_10003189
*            Conversion routine to add zeros to the ID which has sequence no
*            equal to 5 characters.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Submit as ST_ChqSubmit and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
********************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE

    IF LEN(CI.REC<11>) EQ '5' THEN
        CI.REC<11> = '00':CI.REC<11>
    END

RETURN
END
