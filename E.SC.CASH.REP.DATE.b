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

* Version 5 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>93</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvReports
    SUBROUTINE E.SC.CASH.REP.DATE
*
*     Last updated by SECURITIES (ANDREAS) at 11:39:11 on 10/28/1986.
*
************************************************************
*
*   SUBROUTINE TO EXTRACT THE LAST RUN DATE FROM THE SC.CASH.FLOW
*   FILE FOR THE SC.VAL.CASH REPORT
*
*   AUTHOR  : A.K.
*   DATE    : 28/10/86
*
* 20/04/15 - 1323085
*            Incorporation of components
************************************************************
*

******************************************************************
*
    $USING ST.Config
    $USING EB.DataAccess
    $USING EB.Reports
    $USING EB.SystemTables

    IF EB.Reports.getOData() THEN RETURN
    V$DATE = ''
    tmp.DATA.FILE.NAME = EB.Reports.getDataFileName()
    EB.DataAccess.Dbr(tmp.DATA.FILE.NAME:@FM:'1','REPORT.DATE',V$DATE)
    EB.Reports.setDataFileName(tmp.DATA.FILE.NAME)
    IF EB.SystemTables.getEtext() THEN
        LAST.RUN.DATE = ''
    END ELSE
        LAST.RUN.DATE = ''
        ST.Config.DieterDate(V$DATE,LAST.RUN.DATE,'D4E')
    END
    EB.Reports.setOData(LAST.RUN.DATE)
    RETURN
*
    END
