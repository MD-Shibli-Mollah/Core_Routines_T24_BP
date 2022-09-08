* @ValidationCode : MjotMTI3ODg5MjY4NTpDcDEyNTI6MTU5NzEzNDU0MjE5Njpza2F5YWx2aXpoaToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6NDo0
* @ValidationInfo : Timestamp         : 11 Aug 2020 13:59:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 4/4 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*------------------------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYSTC.DD.FORMAT.API(ddItemId, DdItemRecord, ioMessage, reserved1, reserved2, reserved3)
*-----------------------------------------------------------------------------
* This API is attached in DD.OUT.FORMAT>LclRoutine which maps the clearingNatureCode as REP if REP.FLAG in DD.ITEM is Yes
*-----------------------------------------------------------------------------
* Modification History :
* 3/8/2020 - Enhancement 3614846/Task 3854892 -Afriland - SYSTAC (CEMAC) - Resubmission of Direct Debits - Clearing
*-----------------------------------------------------------------------------
    $USING DD.Contract
*-----------------------------------------------------------------------------
    IF DdItemRecord<DD.Contract.Item.ItemRepresentationFlag> EQ 'YES' THEN
        ioMessage<210> = 'REP'   ;* DDIClearing nature code
    END
RETURN
END
