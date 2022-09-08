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
* <Rating>-32</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.StandingOrders

    SUBROUTINE STO.ACCRUAL.SPLIT.MONTH
*
************************************************************************
*                                                                      *
*  Routine     :  STO.ACCRUAL.SPLIT.MONTH                                    *
*                                                                      *
************************************************************************
*                                                                      *
*  Description :  This routine will run in the start of day only after *
*                 a split month end to process schedules due on the    *
*                 days between the 1st and the next working day.       *
*                                                                      *
*                                                                      *
************************************************************************
*                                                                      *
*  Modifications :                                                     *
*                                                                      *
* 08/10/99 - GB9901412
*            Initial version                                           *
*                 Initial version.                                     *
*
* 02/07/07 - BG_100014234
*            Incorrect no. of arguments
*
* 09/02/15 - Enhancement 1214535 / Task 1218721
*            Moved the routine from FT to AC. Also included the Package name
*                                                                *
************************************************************************

    $USING EB.Utility
    $USING EB.API
    $USING AC.StandingOrders
    $USING EB.SystemTables

*
************************************************************************
*
*************
MAIN.PROCESS:
*************
*
* check split month end
*
    IF EB.SystemTables.getToday()[5,2] <> EB.SystemTables.getRDates(EB.Utility.Dates.DatLastWorkingDay)[5,2] THEN
        IF EB.SystemTables.getToday()[2] <> '01' THEN        ;* split month end
            *
            * save current period end date
            *
            SAVE.PERIOD.END = EB.SystemTables.getRDates(EB.Utility.Dates.DatPeriodEnd)
            *
            * calculate yesterday's date
            *
            YESTERDAY = EB.SystemTables.getToday()
            EB.API.Cdt('', YESTERDAY, '-1C')
            *
            * Set period end to yesterday so that STO.EOD.ACCRUAL will pick up
            * the standing order accrual left by the last EOD process
            *
            EB.SystemTables.setRDates(EB.Utility.Dates.DatPeriodEnd, YESTERDAY)
            ST.ID.DAT = ''    ;*BG_100014234 - S
            ST.ID.DAT = EB.SystemTables.getIdNew():'*':YESTERDAY
            AC.StandingOrders.StoEodAccrual(ST.ID.DAT)       ;*BG_100014234 - E
            *
            * restore period end date before ending the start of day batch
            *
            EB.SystemTables.setRDates(EB.Utility.Dates.DatPeriodEnd, SAVE.PERIOD.END)
            *
        END
    END
*
    RETURN
*
    END
