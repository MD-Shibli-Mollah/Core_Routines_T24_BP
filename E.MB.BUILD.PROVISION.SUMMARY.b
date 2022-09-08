* @ValidationCode : Mjo0OTU4NTY0MjpDcDEyNTI6MTU5MjU1ODkxMTQyNTpqYWJpbmVzaDotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDEuMjAxOTEyMjQtMTkzNTotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Jun 2020 14:58:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jabinesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* Build routine to change the Operand from EQ to CT when queried for valid
* PV.ASSET.DETAIL record to display PVAD raised for all GAAPs for that contract
*
* 16/06/20 - Enhancement 3643380 / Task 3805515
*            To display provision summary for all GAAPs
*
*-----------------------------------------------------------------------------
$PACKAGE PV.ModelBank

SUBROUTINE E.MB.BUILD.PROVISION.SUMMARY(ENQ.DATA)

    $USING EB.SystemTables
    $USING PV.Config

    GOSUB INIT
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------
INIT:
*****
* Get the Department code of the current user
    
    R.PV.ASSET.DETAIL = ''
    ERR = ""
    
RETURN
*-----------------------------------------------------------------------------
PROCESS:
********
*
    LOCATE '@ID' IN ENQ.DATA<2,1> SETTING SEL.POS THEN
        CONTRACT.ID = ENQ.DATA<4,SEL.POS>
        SEL.OPERAND = ENQ.DATA<3,SEL.POS>
        IF SEL.OPERAND EQ "EQ" THEN
            R.PV.ASSET.DETAIL = PV.Config.AssetDetail.Read(CONTRACT.ID, ERR)
            IF R.PV.ASSET.DETAIL THEN
                ENQ.DATA<3,SEL.POS> = 'CT'
            END
        END
    END

RETURN
*-----------------------------------------------------------------------------
END
