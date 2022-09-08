* @ValidationCode : MjoxNTUzOTA3OTg4OkNwMTI1MjoxNjA1OTAzMzM3MjUwOnJkZWVwaWdhOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzoxOToxOQ==
* @ValidationInfo : Timestamp         : 21 Nov 2020 01:45:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 19/19 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.NOTIONAL.INCR.DECR(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine return whether Derivative Notional is Increment or Decrement
* for updation in SCDX.ARM.MIFID.DATA for reporting purpose
* Attached as the link routine in TX.TXN.BASE.MAPPING for updation in
* Database SCDX.ARM.MIFID.DATA
* Incoming parameters:
**********************
* TXN.ID   -   Transaction ID of the contract.
* TXN.REC  -   A dynamic array holding the contract.
* TXN.DATA -   Data passed based on setup done in TX.TXN.BASE.MAPPING
*
* Outgoing parameters:
**********************
* RET.VAL  -  Indication as to whether the transaction is an increase or
*             decrease of notional of a derivative contract
*             1 - Value of Pri/Sec Lots has been increased
*             2 - Value of Pri/Sec Lots has been decreased
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*
* 20/11/2020 - Task - 4083678
*              Changes in Sec Lots to update the Derivative notional
*              in report SCDX.ARM.MIFID.DATA
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts and control logic</desc>

    $USING DX.Trade
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to return whether Derivative Notional is Increment or Decrement
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

    RET.VAL = ''
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to return whether Derivative Notional is Increment or Decrement for reporting purpose </desc>

    BEGIN CASE
        CASE TXN.ID[1,5] EQ 'DXTRA'
            DX.TRADE.ID.HIS  = TXN.ID:';':TXN.REC<DX.Trade.Trade.TraCurrNo>
            R.DX.TRADE.HIS = DX.Trade.Trade.ReadHis(DX.TRADE.ID.HIS, HIS.ERR)
            IF NOT(HIS.ERR) THEN
                BEGIN CASE
                    CASE (TXN.REC<DX.Trade.Trade.TraPriLots,1> GT R.DX.TRADE.HIS<DX.Trade.Trade.TraPriLots,1>) OR (TXN.REC<DX.Trade.Trade.TraSecLots> GT R.DX.TRADE.HIS<DX.Trade.Trade.TraSecLots>)
                        RET.VAL = 1 ;* Increase in Notional in Derivative contract
                    CASE (TXN.REC<DX.Trade.Trade.TraPriLots,1> LT R.DX.TRADE.HIS<DX.Trade.Trade.TraPriLots,1>) OR (TXN.REC<DX.Trade.Trade.TraSecLots> LT R.DX.TRADE.HIS<DX.Trade.Trade.TraSecLots>)
                        RET.VAL = 2 ;* Decrease in Notional in Derivative contract
                END CASE
            END
            
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
