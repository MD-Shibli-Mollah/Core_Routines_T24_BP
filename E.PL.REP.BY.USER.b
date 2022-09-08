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

* Version 2 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.PL.REP.BY.USER(ID.LIST)
*
* 01/03/07 - EN_10003231
*            Modified to call DAS to select data.
*

    $INSERT I_DAS.RE.PL.REPORT.WORK
    $USING RE.YearEnd
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING RE.ModelBank
*
    F.RE.PL.REPORT.WORK = ""
    F.RE.PL.REPORT.WORK.NAME = "F.RE.PL.REPORT.WORK"
    EB.DataAccess.Opf(F.RE.PL.REPORT.WORK.NAME,F.RE.PL.REPORT.WORK)

    ID.LIST = dasRePlReportWorkIdLike
    THE.ARGS = EB.SystemTables.getOperator() : '-' : EB.DataAccess.dasWildcard
    TABLE.SUFFIX = ''
    EB.DataAccess.Das('RE.PL.REPORT.WORK',ID.LIST,THE.ARGS,TABLE.SUFFIX)

    RETURN

    END
