* @ValidationCode : Mjo5NTcwNzQzNzQ6Q3AxMjUyOjE1OTk1NjcwNjM1NDQ6a2JoYXJhdGhyYWo6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjM0OjI4
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:41:03
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 28/34 (82.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.DEL.TYPE(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* Populate "CASH".
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - CASH/NULL
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 31/03/20 - Enhancement 3660935 / Task 3660937
*            CI#3 - Mapping Routines - Part I
*
* 02/04/2020 - Enhancement - 3661737 / Task - 3661740
*              CI#3 Mapping Routines Part-2
*
* 14/04/20 - Enhancement 3689604 / Task 3689605
*            CI#3 - Mapping routines - Part II
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
* 27/08/20 - Enhancement 3793940 / Task 3793943
*            CI#3 - Mapping routines - Part II
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING FR.Contract
    $USING FX.Contract
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
    RET.VAL = ''
    MifidReportStatus = ''

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    BEGIN CASE
        CASE APPL.ID[1,2] EQ "ND"
            MifidReportStatus =  APPL.REC<FX.Contract.NdDeal.NdDealMifidReportStatus>
        
        CASE APPL.ID[1,2] EQ "SW"
            MifidReportStatus =  APPL.REC<SW.Contract.Swap.MifidReportStatus>
           
        CASE APPL.ID[1,2] EQ "FR"
            MifidReportStatus =  APPL.REC<FR.Contract.FraDeal.FrdMifidReportStatus>
            
        CASE APPL.ID[1,2] EQ "DX"
            MifidReportStatus =  APPL.REC<DX.Trade.Trade.TraMifidReportStatus>
                
        CASE APPL.ID[1,2] EQ "FX"
            MifidReportStatus =  APPL.REC<FX.Contract.Forex.MifidReportStatus>
            
    END CASE
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* For applns other than DX.TRADE
    IF MifidReportStatus EQ "NEWT" AND APPL.ID[1,2] NE 'DX' THEN
        RET.VAL = "CASH"
    END
* for DX.TRADE
* Possible entries: PHYS, CASH, OPTL; for DX - if SWAP.DELIVERY holds value Cash, then CASH option to be populated in database;
* if Physical then populate PHYS; if DELIVERY.DETAILS holds any value, then populate PHYS, if not then CASH
    
    IF MifidReportStatus EQ "NEWT" AND APPL.ID[1,2] EQ 'DX' THEN
        BEGIN CASE
            CASE APPL.REC<DX.Trade.Trade.TraSwapDelivery> EQ "CASH"
                RET.VAL = "CASH"
            CASE APPL.REC<DX.Trade.Trade.TraSwapDelivery> EQ "PHYSICAL"
                RET.VAL = "PHYS"
            CASE APPL.REC<DX.Trade.Trade.TraDeliveryDetails> NE ''
                RET.VAL = "PHYS"
            CASE APPL.REC<DX.Trade.Trade.TraDeliveryDetails> EQ ''
                RET.VAL = "CASH"
        END CASE
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
END

