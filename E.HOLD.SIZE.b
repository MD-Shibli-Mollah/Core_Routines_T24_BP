* @ValidationCode : MjotNzMwODg5NDY0OkNwMTI1MjoxNTQzMjM5Nzk3NDUwOnJhdmluYXNoOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTEuMjAxODEwMjItMTQwNjotMTotMQ==
* @ValidationInfo : Timestamp         : 26 Nov 2018 19:13:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ravinash
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*
$PACKAGE EB.Reports
SUBROUTINE E.HOLD.SIZE
*
*---------------------------------------------------------------------
* Modification History :
*
* 29/10/18 - Enhancement 2822523 / Task 2832287
*          - Incorporation of EB_Reports component
*
*---------------------------------------------------------------------
* Routine to return the size of the report in 2Kb chunks
*
*--------------------------------------------------------------------
*
    $USING EB.Reports
    COMMON /ENQHOLD/ C$F.HOLD, C$USER.LIST, C$REPORT.LIST
*
*-------------------------------------------------------------------
*
    READ REC FROM C$F.HOLD, EB.Reports.getOData() ELSE
        REC = ''
    END
*
    IF REC THEN
        ODATA = LEN(REC) / 2000 + 1
        EB.Reports.setOData(ODATA)
    END ELSE
        EB.Reports.setOData("")
    END
*
RETURN
*
*-----------------------------------------------------------------
END
