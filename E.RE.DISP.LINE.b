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
* <Rating>51</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.RE.DISP.LINE
*************************************************************
* Modification Log:
* 21/06/2001 - CI_10002363
*             This routine will check for the asset sign and profit sign
*             and display the balances according to the profit type and
*             profit sign defined in the RE.STAT.REP.LINE and display
*             the balances corresponding to the line.
*
* 01/03/07 - EN_10003231
*            Modified to call DAS to select data.
*
*************************************************************   
    $USING RE.Consolidation
    $USING RE.Config
    $USING EB.DataAccess
    $USING RE.ReportGeneration
    $USING EB.Reports
    $USING RE.ModelBank
************************************************************
*
    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN
*
************************************************************
INITIALISE:
*
    F.RE.STAT.LINE.CONT = ''
    EB.DataAccess.Opf("F.RE.STAT.LINE.CONT", F.RE.STAT.LINE.CONT)
    F.RE.STAT.REP.LINE = ''
    EB.DataAccess.Opf("F.RE.STAT.REP.LINE",F.RE.STAT.REP.LINE)
    PROFIT.SIGN = ''
    F.DISPLAY.FILE = ''
    FN.DISPLAY.FILE = 'F.DISPLAY.FILE'
    FV.DISPLAY.FILE = ''
    EB.DataAccess.Opf(FN.DISPLAY.FILE,FV.DISPLAY.FILE)
    R.DISPLAY.FILE = ''

    HEAD = ''
    RETURN
************************************************************
PROCESS:
*
    tmp.O.DATA = EB.Reports.getOData()
    EB.Reports.setId(FIELD(tmp.O.DATA,'*',2))
    EB.Reports.setOData(FIELD(tmp.O.DATA,'*',1))
    PTYPE = ''
    R.RE.STAT.REP.LINE = ''
    tmp.ID = EB.Reports.getId()
    R.RE.STAT.REP.LINE = RE.Config.StatRepLine.Read(tmp.ID, ERR)
    IF NOT(ERR) THEN
        PTYPE = R.RE.STAT.REP.LINE<RE.Config.StatRepLine.SrlProfitType>
    END
    IF PTYPE = 'RECORD' THEN
        RETURN
    END
    R.RE.STAT.LINE.CONT = RE.Consolidation.StatLineCont.Read(tmp.ID, ERR)
    PROFIT.SIGN = R.RE.STAT.LINE.CONT<RE.Consolidation.StatLineCont.SlcProfitLineSign>
    ASSET.SIGN = R.RE.STAT.LINE.CONT<RE.Consolidation.StatLineCont.SlcAssetSign>
    IF ASSET.SIGN # '' THEN
        OPP.ID = R.RE.STAT.LINE.CONT<RE.Consolidation.StatLineCont.SlcAssetOppLine>
    END ELSE
        OPP.ID = R.RE.STAT.LINE.CONT<RE.Consolidation.StatLineCont.SlcProfitOppLine>
    END
    HEAD = FIELD(tmp.ID,'.',1)
    OPP.ID = HEAD:'.':OPP.ID

    SEL.LIST = 'ALL.IDS'
    THE.ARGS = ''
    TABLE.SUFFIX = ''
    EB.DataAccess.Das ('DISPLAY.FILE', SEL.LIST, THE.ARGS, TABLE.SUFFIX)

    IF SEL.LIST THEN
        REMOVE DISP.ID FROM SEL.LIST SETTING POS
        IF DISP.ID = EB.Reports.getId() THEN
            READ R.DISPLAY.FILE FROM FV.DISPLAY.FILE, DISP.ID ELSE NULL
                EB.Reports.setOData(R.DISPLAY.FILE<1>)
                DELETE FV.DISPLAY.FILE,DISP.ID
                    RETURN
                END
            END ELSE
                TOT.BAL = EB.Reports.getOData()
                IF ASSET.SIGN # '' THEN
                    GOSUB ASSETS
                END ELSE
                    IF PROFIT.SIGN # '' THEN
                        GOSUB PROFIT
                    END
                END
            END
            RETURN
*************************************************************
PROFIT:
            IF PROFIT.SIGN = 'CREDIT' THEN
                IF TOT.BAL < 0 THEN
                    EB.Reports.setOData('0.00')
                    R.DISPLAY.FILE := TOT.BAL
                    WRITE R.DISPLAY.FILE ON FV.DISPLAY.FILE, OPP.ID


                    END
                END ELSE
                    IF PROFIT.SIGN = 'DEBIT' THEN
                        IF TOT.BAL > 0 THEN
                            EB.Reports.setOData('0.00')
                            R.DISPLAY.FILE := TOT.BAL
                            WRITE R.DISPLAY.FILE ON FV.DISPLAY.FILE, OPP.ID
                            END
                        END
                    END
                    RETURN

*************************************************************
ASSETS:
                    IF ASSET.SIGN = 'CREDIT' THEN
                        IF TOT.BAL < 0 THEN
                            EB.Reports.setOData('0.00')
                            R.DISPLAY.FILE := TOT.BAL
                            WRITE R.DISPLAY.FILE ON FV.DISPLAY.FILE, OPP.ID
                            END
                        END ELSE
                            IF ASSET.SIGN = 'DEBIT' THEN
                                IF TOT.BAL > 0 THEN
                                    EB.Reports.setOData('0.00')
                                    R.DISPLAY.FILE := TOT.BAL
                                    WRITE R.DISPLAY.FILE ON FV.DISPLAY.FILE, OPP.ID
                                    END
                                END
                            END
                            RETURN

************************************************************
                        END
