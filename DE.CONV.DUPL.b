* @ValidationCode : MjoxMzM4OTA5NDI2OkNwMTI1MjoxNTQ3MDI3MjA2NTY5OnN1amF0YXNpbmdoOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTIuMjAxODExMjMtMTMxOTo0OjQ=
* @ValidationInfo : Timestamp         : 09 Jan 2019 15:16:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sujatasingh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 4/4 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE DE.API
SUBROUTINE DE.CONV.DUPL(FORMAT.SWIFT.REC, MESSAGE.REC, PASS.VALUE, SWIFT.FIELD.VALUE, ERR.MSG)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 31/12/18 - Defect 2914378 / Task 2927112
*            Resubmitted Swift Messages are not marked as duplicate.
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING DE.Outward
    $USING DE.Config
*-----------------------------------------------------------------------------

    AV1 = EB.SystemTables.getAv()
* When header is resubmitted the field MSG.PDE is updated with PDE and its been checked for updating DUPL value
    IF DE.Outward.getRHead(DE.Config.OHeader.HdrPosDupEntry)<1,AV1> EQ 'PDE' THEN
        PASS.VALUE = 'DUPL'
    END
END 

 
