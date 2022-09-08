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

* Version 6 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>289</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoReports
    SUBROUTINE E.SC.VAL.RUN.DATE
*
*     Last updated by SECURITIES (ANDREAS) at 09:23:21 on 10/10/1986.
*
************************************************************
*
*   SUBROUTINE TO EXTRACT THE LAST RUN DATE FROM THE BATCH
*   RECORD FOR SC.CASH.FLOW .
*
*   AUTHOR  : A.K.
*   DATE    : 10/10/86
*
* 23-07-2015 - 1415959
*             Incorporation of components
************************************************************
*

    $USING EB.Service
    $USING EB.DataAccess
    $USING ST.Config
    $USING EB.Reports

*
******************************************************************
*
    IF EB.Reports.getOData() THEN RETURN
*
* READ VALUATIONS BATCH RECORD TO EXTRACT THE
* LAST RUN DATE OF SC.CASH.FLOW
*
*      READ R.BATCH FROM F.BATCH,'SC.BATCH.REP' ELSE R.BATCH = ''

    R.BATCH = EB.Service.Batch.Read('SC.BATCH.REP', ER1)
* Before incorporation : CALL F.READ('F.BATCH','SC.BATCH.REP',R.BATCH,F.BATCH,ER1)
    IF ER1 NE '' THEN R.BATCH=''

    LOCATE 'SC.CASH.FLOW' IN R.BATCH<EB.Service.Batch.BatJobName,1> SETTING POS ELSE POS = 0
    IF POS THEN
        V$DATE = R.BATCH<EB.Service.Batch.BatLastRunDate,POS>
        LAST.RUN.DATE = ''
        ST.Config.DieterDate(V$DATE,LAST.RUN.DATE,'D4E')
    END ELSE
        LAST.RUN.DATE = ''
    END
    EB.Reports.setOData(LAST.RUN.DATE)
    RETURN
*
    END
