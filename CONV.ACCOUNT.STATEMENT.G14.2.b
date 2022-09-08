* @ValidationCode : MjotMTYwNzMxMTI5ODpDcDEyNTI6MTU2NDU2MzIyMjcxODpzcmF2aWt1bWFyOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA2MTItMDMyMTotMTotMQ==
* @ValidationInfo : Timestamp         : 31 Jul 2019 14:23:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.StmtPrinting
SUBROUTINE CONV.ACCOUNT.STATEMENT.G14.2(AC.STMT.ID,R.AC.STMT,F.AC.STMT)
*************************************************************************
* Conversion routine to populate value in the filed Message type if the
* value in SEND.MSG.TYPE is YES.
* --------------------------------------------------------------------
* Modification Log:
* -----------------
* 30/01/04 - EN_10002181
*
* 30/07/19 - Enhancement 3246717 / Task 3181742
*            TI Changes - Component moved from ST to AC.
*
*************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
*************************************************************************
    IF R.AC.STMT<29,1> EQ 'Y' THEN     ; *   AC.STA.SEND.MSG.TYPE
        R.AC.STMT<28,1> = '942'         ; * AC.STA.MESSAGE.TYPE
    END
RETURN
END
*************************************************************************
