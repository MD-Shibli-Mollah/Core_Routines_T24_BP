* @ValidationCode : MjotMTE2OTM1NjgyNjpDcDEyNTI6MTU5OTU2NzA1NTUyNDprYmhhcmF0aHJhajo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6MzI6MzA=
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:40:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 30/32 (93.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.PRICE(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* If transaction is BUY - LEI code of the bank
* If transaction in SELL - Counterparty's LEGAL.ENTITY Id from OC.CUSTOMER, if not present fetch NATIONAL.ID
*
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - BANK.LEI/LEI of customer/ NATIONAL.ID of customer.
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 02/04/2020 - Enhancement - 3661737 / Task - 3661740
*              CI#3 Mapping Routines Part-2
*
* 27/08/20 - Enhancement 3793940 / Task 3793943
*            CI#3 - Mapping routines - Part II
*-----------------------------------------------------------------------------

    $USING SW.Contract
    $USING FX.Contract
    GOSUB Initialise ; *
    GOSUB Process ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc> </desc>
    PRICE = ""
    RET.VAL = ""
   
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= Process>
Process:
*** <desc> </desc>
    BEGIN CASE
        CASE APPL.ID[1,2] = "SW"
            CheckIfNewReport = APPL.REC<SW.Contract.Swap.MifidReportStatus> = "NEWT"
            IF CheckIfNewReport NE "" THEN
                BEGIN CASE
                    CASE APPL.REC<SW.Contract.Swap.LbFixedRate> NE "" AND APPL.REC<SW.Contract.Swap.LbRateKey> NE ""
                        RET.VAL = APPL.REC<SW.Contract.Swap.LbFixedRate>
                
                    CASE APPL.REC<SW.Contract.Swap.LbFixedRate> NE ""
                        RET.VAL = APPL.REC<SW.Contract.Swap.LbFixedRate>
        
                    CASE APPL.REC<SW.Contract.Swap.LbRateKey> NE ""
                        PRICE = APPL.REC<SW.Contract.Swap.LbRateKey> + APPL.REC<SW.Contract.Swap.LbSpread>
                        RET.VAL = PRICE
                END CASE
            END
        CASE APPL.ID[1,2] = "FX"
            CheckIfNewReport = APPL.REC<FX.Contract.Forex.MifidReportStatus> = "NEWT"
            IF CheckIfNewReport NE "" THEN
                BEGIN CASE
                    CASE APPL.REC<FX.Contract.Forex.DealType> EQ "FW"
                        RET.VAL = APPL.REC<FX.Contract.Forex.ForwardRate>
                    CASE  APPL.REC<FX.Contract.Forex.DealType> EQ "SW"
                        RET.VAL = APPL.REC<FX.Contract.Forex.ForwardRate> - APPL.REC<FX.Contract.Forex.SpotRate>
                END CASE
            END
    END CASE
RETURN
*** </region>
END


