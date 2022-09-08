* @ValidationCode : Mjo5MTIyNzc3MzI6Q3AxMjUyOjE1OTk0NzYyMzUyNDk6a2JoYXJhdGhyYWo6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjc0OjY0
* @ValidationInfo : Timestamp         : 07 Sep 2020 16:27:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 64/74 (86.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.CHECK.AMEND.EMIR.MIFID(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)

******************************************************************
* Modification History:
*
* 31/03/20 - Enhancement 3660935 / Task 3660937
*            CI#3 - Mapping Routines - Part I
*
* 02/04/20 - Enhancement - 3661703 / Task - 3661706
*            CI#2 Mapping Routines Part-1
*
* 14/04/20 - Enhancement 3689595 / Task 3689597
*            CI#2 - Mapping routines - Part I
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
* 28/08/20 - Enhancement 3793912/ Task 3793913
*            CI#2 - Mapping routines - Part I
******************************************************************


*The purpose of the routine is to check whether the user amend the deal in both action type and MIFID report status.
*Then it will produce both OC.TRADE.DATA and OC.MIFID.DATA.
*Incoming parameters:

*Appl.id - Id of application linked to tax engine.
*Appl.rec - Application record.
*Field.pos-Decision field name

*Outcoming parameters

* Ret.val - 1/0

******************************************************************

    $USING FX.Contract
    $USING FR.Contract
    $USING SW.Contract
    $USING DX.Trade
*----------------------------------------------------------------------------
    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *

RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> </desc>
    NdDealRec = ''
    SwDealRec = ''
    FrDealRec = ''
    DxDealRec = ''
    ActionType = ''
    MifidReportStatus = ''
    RET.VAL = 0
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    BEGIN CASE
        CASE APPL.ID[1,2] EQ "ND"
            NdDealErr = ''
            NdDealRec =  FX.Contract.NdDeal.Read(APPL.ID, NdDealErr)
            IF NdDealRec NE '' THEN
                ActionType = APPL.REC<FX.Contract.NdDeal.NdDealActionType>
                MifidReportStatus = APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
                IF (ActionType NE NdDealRec<FX.Contract.NdDeal.NdDealActionType>) AND (MifidReportStatus NE NdDealRec<FX.Contract.NdDeal.NdDealMifidReportStatus>) THEN
                    RET.VAL = 1
                END ELSE
                    RET.VAL = 0
                END
            END
        
        CASE APPL.ID[1,2] EQ "SW"
            SwDealErr = ''
            SwDealRec =  SW.Contract.Swap.Read(APPL.ID, SwDealErr)
            IF SwDealRec NE '' THEN
                ActionType = APPL.REC<SW.Contract.Swap.ActionType>
                MifidReportStatus = APPL.REC<SW.Contract.Swap.MifidReportStatus>
                IF (ActionType NE SwDealRec<SW.Contract.Swap.ActionType>) AND (MifidReportStatus NE SwDealRec<SW.Contract.Swap.MifidReportStatus>) THEN
                    RET.VAL = 1
                END ELSE
                    RET.VAL = 0
                END
            END
        
        CASE APPL.ID[1,2] EQ "FR"
            FrDealErr = ''
            FrDealRec =  FR.Contract.FraDeal.Read(APPL.ID, FrDealErr)
            IF FrDealRec NE '' THEN
                ActionType = APPL.REC<FR.Contract.FraDeal.FrdActionType>
                MifidReportStatus = APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
                IF (ActionType NE FrDealRec<FR.Contract.FraDeal.FrdActionType>) AND (MifidReportStatus NE FrDealRec<FR.Contract.FraDeal.FrdMifidReportStatus>) THEN
                    RET.VAL = 1
                END ELSE
                    RET.VAL = 0
                END
            END
            
        CASE APPL.ID[1,2] EQ "DX"
            DxDealErr = ''
            DxDealRec =  DX.Trade.Trade.Read(APPL.ID, DxDealErr)
            IF DxDealRec NE '' THEN
                ActionType = APPL.REC<DX.Trade.Trade.TraActionType>
                MifidReportStatus = APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
                IF (ActionType NE DxDealRec<DX.Trade.Trade.TraActionType>) AND (MifidReportStatus NE DxDealRec<DX.Trade.Trade.TraMifidReportStatus>) THEN
                    RET.VAL = 1
                END ELSE
                    RET.VAL = 0
                END
            END
            
        CASE APPL.ID[1,2] EQ "FX"
            FxDealErr = ''
            FxDealRec =  FX.Contract.Forex.Read(APPL.ID, FxDealErr)
            IF FxDealRec NE '' THEN
                ActionType = APPL.REC<FX.Contract.Forex.ActionType>
                MifidReportStatus = APPL.REC<FX.Contract.Forex.MifidReportStatus>
                IF (ActionType NE FxDealRec<FX.Contract.Forex.ActionType>) AND (MifidReportStatus NE FxDealRec<FX.Contract.Forex.MifidReportStatus>) THEN
                    RET.VAL = 1
                END ELSE
                    RET.VAL = 0
                END
            END
    END CASE
RETURN
*** </region>
