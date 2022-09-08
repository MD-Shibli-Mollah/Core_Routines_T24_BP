* @ValidationCode : MjotMTgxNDE2Nzc4ODpDcDEyNTI6MTU2NDU3MTQ1NjM2MTpzcmF2aWt1bWFyOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:40:56
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

* Version 1 14/03/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue
SUBROUTINE CONV.CHEQUE.ISSUE.G12.1.00(CI.ID, Y.CIREC, CI.FILE)
*Conversion to populate the field CHEQUE.STATUS in CHEQUE.ISSUE
*which is a  new field.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Issue as ST_ChqIssue and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*---------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    EQUATE CHEQUE.IS.CHEQUE.STATUS TO 1


    IF FILE.TYPE = 1 THEN
        Y.CIREC<1> = 90
    END
RETURN
END
