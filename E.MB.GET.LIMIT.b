* @ValidationCode : MjotNDA5MTU0NTA1OkNwMTI1MjoxNTg4ODU2OTY0ODQxOmJoYXJhdGhzaXZhOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDQuMDoxODoxNg==
* @ValidationInfo : Timestamp         : 07 May 2020 18:39:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bharathsiva
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/18 (88.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202004.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LI.ModelBank

SUBROUTINE E.MB.GET.LIMIT
*----------------------------------------------------------------------------
*
* Modification history:
*-----------------------
*
* 05/05/2020 - Defect 3715459 / Task 3727836
*              Routine is enhanced to return the internal amount of Limit following Validation and utilisation structure.
*
*-----------------------------------------------------------------------------

    $USING LI.Config
    $USING EB.Reports

    GOSUB INIT
    GOSUB PROCESS

RETURN

INIT:
    R.LIMIT = ''
    ERR.LIMIT = ''
    LIM.CHK = ''
    O.DATA.VALUE = EB.Reports.getOData()
RETURN

PROCESS:
    LIM.CHK = FIELD(O.DATA.VALUE,'.',2)
    IF LIM.CHK NE "" OR O.DATA.VALUE[1,2] EQ 'LI' THEN  ;* Record to be fetched for all the limits following both old and new structure
        LIMIT.ID = O.DATA.VALUE
        R.LIMIT = LI.Config.Limit.Read(LIMIT.ID, ERR.LIMIT)
        ACT.LIMIT = R.LIMIT<LI.Config.Limit.InternalAmount>
        EB.Reports.setOData(ACT.LIMIT)
    END ELSE
        EB.Reports.setOData("NULL")
    END
RETURN
*-----------------------------------------------------------------------------
END
