* @ValidationCode : MjoyMTA5MjcyNjMxOkNwMTI1MjoxNTk5NDc2MjMyNDkxOmtiaGFyYXRocmFqOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTo1MjozNg==
* @ValidationInfo : Timestamp         : 07 Sep 2020 16:27:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/52 (69.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.CHECK.NEW.DEAL(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
 
******************************************************************
* Modification History:
*
* 31/03/20 - Enhancement 3660935 / Task 3660937
*            CI#3 - Mapping Routines - Part I
*
* 02/04/20 - Enhancement - 3661703 / Task - 3661706
*            CI#2 Mapping Routines Part-1
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
* 28/08/20 - Enhancement 3793912/ Task 3793913
*            CI#2 - Mapping routines - Part I
******************************************************************


*The purpose of the routine is to check whether the user creates the new deal.
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
            IF NdDealRec EQ '' THEN
                RET.VAL = 1
            END ELSE
                RET.VAL = 0
            END
         
        CASE APPL.ID[1,2] EQ "SW"
            SwDealErr = ''
            SwDealRec =  SW.Contract.Swap.Read(APPL.ID, SwDealErr)
            IF SwDealRec EQ '' THEN
                RET.VAL = 1
            END ELSE
                RET.VAL = 0
            END
        
        CASE APPL.ID[1,2] EQ "FR"
            FrDealErr = ''
            FrDealRec =  FR.Contract.FraDeal.Read(APPL.ID, FrDealErr)
            IF FrDealRec EQ '' THEN
                RET.VAL = 1
            END ELSE
                RET.VAL = 0
            END
            
        CASE APPL.ID[1,2] EQ "DX"
            DxDealErr = ''
            DxDealRec =  DX.Trade.Trade.Read(APPL.ID, DxDealErr)
            IF DxDealRec EQ '' THEN
                RET.VAL = 1
            END ELSE
                RET.VAL = 0
            END
            
        CASE APPL.ID[1,2] EQ "FX"
            FxDealErr = ''
            FxDealRec = FX.Contract.Forex.Read(APPL.ID, FxDealErr)
            IF FxDealRec EQ '' THEN
                RET.VAL = 1
            END ELSE
                RET.VAL = 0
            END
    END CASE
RETURN
*** </region>
