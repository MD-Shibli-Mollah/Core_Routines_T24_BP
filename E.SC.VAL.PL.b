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

* Version 7 22/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>444</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvReports
    SUBROUTINE E.SC.VAL.PL
*
************************************************************
*
*    SUBROUTINE TO CALCULATE PORTFOLIO GRAND TOTAL IN REF.CCY
*
* 20/04/15 - 1323085
*            Incorporation of components
************************************************************
*
*   LOCAL1 = REF.CCY * EQUATED IN E.SC.VAL.REF.CCY
*
*
********************************************************************
*
    $USING ST.ExchangeRate
    $USING SC.ScvValuationUpdates
    $USING EB.Reports
    $USING SC.ScvReports
    $USING EB.SystemTables

    REF.CCY = EB.SystemTables.getLocalOne()
    IF EB.Reports.getOData() THEN RETURN
*
    tmp.ID = EB.Reports.getId()
    SEC.ACC.NO = FIELD(tmp.ID,'.',1,1)
    EB.Reports.setId(tmp.ID)
    TOT.ARRAY = ''
*
*
    CCY2 = REF.CCY
*
    R.SC.VAL = '' ; EB.SystemTables.setEtext('')
    tmp.ETEXT = EB.SystemTables.getEtext()
    R.SC.VAL = SC.ScvValuationUpdates.ValPositions.Read(SEC.ACC.NO, tmp.ETEXT)
* Before incorporation : CALL F.READ('F.SC.VAL.POSITIONS',SEC.ACC.NO,R.SC.VAL,'',tmp.ETEXT)
    EB.SystemTables.setEtext(tmp.ETEXT)
    IF EB.SystemTables.getEtext() THEN EB.Reports.setOData(1); RETURN
*
    ASSET.KEYS = R.SC.VAL
*
    LOOP
        REMOVE K.SC.POS.ASSET FROM ASSET.KEYS SETTING END.ASSET
        R.SC.POS.ASSET.LOCAL = '' ; EB.SystemTables.setEtext('')
        tmp.ETEXT = EB.SystemTables.getEtext()
        R.SC.POS.ASSET.LOCAL = SC.ScvValuationUpdates.tablePosAsset(K.SC.POS.ASSET,tmp.ETEXT)
        EB.SystemTables.setEtext(tmp.ETEXT)
        IF EB.SystemTables.getEtext() THEN EB.Reports.setOData(1); RETURN
        COUNT.RECS = COUNT(R.SC.POS.ASSET.LOCAL<1>,@VM) + (R.SC.POS.ASSET.LOCAL NE '')
        *
        FOR REC.NO = 1 TO COUNT.RECS
            SEC.CCY = R.SC.POS.ASSET.LOCAL<3,REC.NO>
            CCY1 = SEC.CCY
            *
            IF CCY1 = CCY2 THEN
                IF R.SC.POS.ASSET.LOCAL<1,REC.NO>[1,2] NE 'FX' THEN
                    TOT.ARRAY<1,-1> = R.SC.POS.ASSET.LOCAL<7,REC.NO>
                END
            END ELSE
                VAL1 = R.SC.POS.ASSET.LOCAL<7,REC.NO>
                VAL2 = ''
                RET.CODE = '' ; RATE = ''
                ST.ExchangeRate.Exchrate("1",CCY1,VAL1,CCY2,VAL2,'',RATE,'','',RET.CODE)
                tmp.ETEXT = EB.SystemTables.getEtext()
                IF NOT(tmp.ETEXT) AND NOT(RET.CODE<2>) THEN
                    TOT.ARRAY<1,-1> = VAL2
                END ELSE
                    TOT.ARRAY<1,-1> = 1
                END
            END
            *
        NEXT REC.NO
        *
    WHILE END.ASSET DO REPEAT
*
    EB.Reports.setOData(SUM(TOT.ARRAY))
*
    RETURN
*
    END
