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
* <Rating>-66</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.MB.REPORT.LINE.DETAIL(ENQ.DATA)
*-----------------------------------------------------------------------------
* Description:
*-------------
* This is a build routine for REPORT.LINE.DETAIL enquiry file. If line number
* is given then append the ID.COMPANY. If line number is not given then get the
* ‘catch all item’ line number from EB.CONSOL.ASSET.LINE and EB.CONSOL.PROFIT.LINE.
*-----------------------------------------------------------------------------
* Modification History:
*----------------------
* 19/09/14 - Enhancement - 1068928 / Task - 1106681
*            New build routine.
*-----------------------------------------------------------------------------
*    
    $USING RE.Consolidation
    $USING EB.SystemTables
    $USING RE.ModelBank
*-----------------------------------------------------------------------------
*
    GOSUB INITIALISE
    GOSUB PROCESS
*
    RETURN
*
*-----------------------------------------------------------------------------
INITIALISE:
*----------
*
    RETURN
*
*-----------------------------------------------------------------------------
PROCESS:
*-------
*
    LOCATE 'REP.NAME.LINE.NO' IN ENQ.DATA<2,1> SETTING ENQ.FIELD.POS THEN ;* Line number is given so show only that line number
        ENQ.DATA<4,ENQ.FIELD.POS> = ENQ.DATA<4,ENQ.FIELD.POS>:EB.SystemTables.getIdCompany()
    END ELSE
        GOSUB GET.DEFAULT.LINE.NO
    END
*
    RETURN
*-----------------------------------------------------------------------------
GET.DEFAULT.LINE.NO:
*-------------------
*
    R.RCAL = ''
    Y.ERR = ''
    R.RCAL = RE.Consolidation.ConsolAssetLine.Read('}', Y.ERR)
    IF R.RCAL THEN
        GOSUB FIND.CAL.LINE.NO
    END
*
    R.RCPL = ''
    Y.ERR = ''
    R.RCPL = RE.Consolidation.ConsolProfitLine.Read('}', Y.ERR)
    IF R.RCPL THEN
        GOSUB FIND.CPL.LINE.NO
    END
*
    CONVERT @FM TO ' ' IN LINE.NO.LIST ;* Convert it to space so that core routine will change it to SM marker
*
    ENQ.DATA<2,1> = 'REP.NAME.LINE.NO'
    ENQ.DATA<3,1> = 'EQ'
    ENQ.DATA<4,1> = LINE.NO.LIST
*
    RETURN
*-----------------------------------------------------------------------------
FIND.CAL.LINE.NO:
*----------------
    LOCATE '{{DAL' IN R.RCAL<RE.Consolidation.ConsolAssetLine.CalType,1> SETTING DAL.TYPE.POS THEN ;* Catch all items for non contingent
        LOCATE 'MBGL' IN R.RCAL<RE.Consolidation.ConsolAssetLine.CalReportName,DAL.TYPE.POS,1> SETTING DAL.REP.POS THEN ;* Get for MBGL report
            LINE.NO = 'MBGL.':R.RCAL<RE.Consolidation.ConsolAssetLine.CalReportLine,DAL.TYPE.POS,DAL.REP.POS>:'.':EB.SystemTables.getIdCompany()
            LOCATE LINE.NO IN LINE.NO.LIST SETTING LINE.POS ELSE
                LINE.NO.LIST<LINE.POS> = LINE.NO
            END
        END
    END
    LOCATE '{{DOF' IN R.RCAL<RE.Consolidation.ConsolAssetLine.CalType,1> SETTING DOF.TYPE.POS THEN ;* Catch all items for contingent
        LOCATE 'MBGL' IN R.RCAL<RE.Consolidation.ConsolAssetLine.CalReportName,DOF.TYPE.POS,1> SETTING DOF.REP.POS THEN ;* Get for MBGL report
            LINE.NO = 'MBGL.':R.RCAL<RE.Consolidation.ConsolAssetLine.CalReportLine,DOF.TYPE.POS,DOF.REP.POS>:'.':EB.SystemTables.getIdCompany()
            LOCATE LINE.NO IN LINE.NO.LIST SETTING LINE.POS ELSE
                LINE.NO.LIST<LINE.POS> = LINE.NO
            END
        END
    END

    RETURN
*-----------------------------------------------------------------------------
FIND.CPL.LINE.NO:
*----------------
    LOCATE '{{DAL' IN R.RCPL<RE.Consolidation.ConsolProfitLine.CplApplicId,1> SETTING DAL.APPLIC.POS THEN ;* Catch all items for non contingent
        LOCATE 'MBGL' IN R.RCPL<RE.Consolidation.ConsolProfitLine.CplReportName,DAL.APPLIC.POS,1> SETTING DAL.REP.POS THEN ;* Get for MBGL report
            LINE.NO = 'MBGL.':R.RCPL<RE.Consolidation.ConsolProfitLine.CplReportLine,DAL.APPLIC.POS,DAL.REP.POS>:'.':EB.SystemTables.getIdCompany()
            LOCATE LINE.NO IN LINE.NO.LIST SETTING LINE.POS ELSE
                LINE.NO.LIST<LINE.POS> = LINE.NO
            END
        END
    END
    LOCATE '{{DOF' IN R.RCPL<RE.Consolidation.ConsolProfitLine.CplApplicId,1> SETTING DOF.APPLIC.POS THEN ;* Catch all items for contingent
        LOCATE 'MBGL' IN R.RCPL<RE.Consolidation.ConsolProfitLine.CplReportName,DOF.APPLIC.POS,1> SETTING DOF.REP.POS THEN ;* Get for MBGL report
            LINE.NO = 'MBGL.':R.RCPL<RE.Consolidation.ConsolProfitLine.CplReportLine,DOF.APPLIC.POS,DOF.REP.POS>:'.':EB.SystemTables.getIdCompany()
            LOCATE LINE.NO IN LINE.NO.LIST SETTING LINE.POS ELSE
                LINE.NO.LIST<LINE.POS> = LINE.NO
            END
        END
    END
    RETURN
*-----------------------------------------------------------------------------
    END
