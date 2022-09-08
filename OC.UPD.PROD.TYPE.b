* @ValidationCode : Mjo1MDg5NDk4MzE6Q3AxMjUyOjE1ODI4OTUwMDk2Njk6cHJpeWFkaGFyc2hpbmlrOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDIuMjAyMDAxMTctMjAyNjoyMjoxNA==
* @ValidationInfo : Timestamp         : 28 Feb 2020 18:33:29
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : priyadharshinik
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 14/22 (63.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.PROD.TYPE(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* It returns "UPI" if UNIQUE.PROD.ID is present.
* This is the common routine for the FX,ND,SWAP,FRA and DX.
*-----------------------------------------------------------------------------
*******************************************************************
*
*
* Incoming parameters:
*
* APPL.ID   - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val- returns "UPI" if UNIQUE.PROD.ID is present.
*
*
*******************************************************************
* Modification History :
*
* 31/01/2020 - Enhancement 3562849 / Task 3562851
*              CI #3 - Mapping Routines
*
*-----------------------------------------------------------------------------

    $USING ST.Customer
    $USING EB.SystemTables
    $USING FR.Contract
    $USING FX.Contract
    $USING SW.Contract
    $USING DX.Trade
    
    GOSUB INITIALISE ; *
    GOSUB PROCESS ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    UniProdId = ""
    RET.VAL = ""
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>

    BEGIN CASE
    
        CASE APPL.ID[1,2] = 'FX'
            UniProdId = APPL.REC<FX.Contract.Forex.UniqueProdId>
        
        CASE APPL.ID[1,2] = 'SW'
            UniProdId = APPL.REC<SW.Contract.Swap.UniProdId>
    
        CASE APPL.ID[1,2] = 'FR'
            UniProdId = APPL.REC<FR.Contract.FraDeal.FrdUniqueProdId>
            
        CASE APPL.ID[1,2] = 'ND'
            UniProdId = APPL.REC<FX.Contract.NdDeal.NdDealUniqueProdId>
            
        CASE APPL.ID[1,2] = 'DX'
            UniProdId = APPL.REC<DX.Trade.Trade.TraUniProdId>
    END CASE
    
    IF UniProdId THEN
        RET.VAL = "UPI"
    END

RETURN
*** </region>

END


