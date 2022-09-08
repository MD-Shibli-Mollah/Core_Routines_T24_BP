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
* <Rating>-42</Rating>
*-----------------------------------------------------------------------------
* Version 6 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
    $PACKAGE SC.ScvReports
    SUBROUTINE E.SC.VAL.MARGIN
*
************************************************************
*
*    SUBROUTINE TO CALCULATE UTILISATION VALUE
*
*-----------------------------------------------------------------------------
* M O D I F I C A T I O N S
*-----------------------------------------------------------------------------
*
* 25/11/08 - GLOBUS_BG_100021004 - dadkinson@temenos.com
*            TTS0804595
*            Remove DBRs
*
* 20/04/15 - 1323085
*            Incorporation of components
*
* 17/02/16 - Enhancement 1192721/ Task 1634927
*            Reclassification of the units to ST module
*-----------------------------------------------------------------------------


    $USING SC.Config
    $USING EB.Reports
    $USING ST.Valuation

    INTERFACE = 'AC'
    GOSUB READ.VAL.INTERFACE ;* Read VAL.INTERFACE
    GOSUB READ.ASSET.BREAK   ;* Read ASSET.BREAK using ASSET.TYPE.CODE
    DEFAULT.SUB.AST = RETURNED.SUB.AST

    INTERFACE = 'LD'
    GOSUB READ.VAL.INTERFACE ;* Read VAL.INTERFACE
    GOSUB READ.ASSET.BREAK   ;* Read ASSET.BREAK using ASSET.TYPE.CODE
    LOANS.SUB.AST = RETURNED.SUB.AST

    INTERFACE = 'MM'
    GOSUB READ.VAL.INTERFACE ;* Read VAL.INTERFACE
    GOSUB READ.ASSET.BREAK   ;* Read ASSET.BREAK using ASSET.TYPE.CODE
    MM.SUB.AST = RETURNED.SUB.AST

    tmp.ID = EB.Reports.getId()
    K.SUB.AST = FIELD(tmp.ID,'.',2)
    EB.Reports.setId(tmp.ID)
    IF K.SUB.AST = DEFAULT.SUB.AST OR K.SUB.AST = LOANS.SUB.AST OR K.SUB.AST = MM.SUB.AST THEN
        IF EB.Reports.getOData() LT 0 THEN
            EB.Reports.setOData(EB.Reports.getOData())
        END ELSE
            EB.Reports.setOData(0)
        END
    END ELSE
        EB.Reports.setOData(0)
    END

    RETURN

*-----------------------------------------------------------------------------
*** <region name= READ.VAL.INTERFACE>
*** <desc>Read VAL.INTERFACE </desc>
READ.VAL.INTERFACE:
* BG_100021004  New Paragraph

    R.VAL.INTERFACE = ''
    YERR = ''
    R.VAL.INTERFACE = ST.Valuation.ValInterface.CacheRead(INTERFACE, YERR)
* Before incorporation : CALL CACHE.READ('F.VAL.INTERFACE',INTERFACE,R.VAL.INTERFACE,YERR)
    ASSET.TYPE.CODE = R.VAL.INTERFACE<1>

    RETURN

*** </region>

*-----------------------------------------------------------------------------
*** <region name= READ.ASSET.BREAK>
*** <desc>Read ASSET.BREAK </desc>
READ.ASSET.BREAK:
* BG_100021004  New Paragraph

    R.ASSET.BREAK = ''
    YERR = ''
    R.ASSET.BREAK = ST.Valuation.AssetBreak.CacheRead(ASSET.TYPE.CODE, YERR)
* Before incorporation : CALL CACHE.READ('F.ASSET.BREAK',ASSET.TYPE.CODE,R.ASSET.BREAK,YERR)
    RETURNED.SUB.AST = R.ASSET.BREAK<1>

    RETURN

*** </region>

    END
