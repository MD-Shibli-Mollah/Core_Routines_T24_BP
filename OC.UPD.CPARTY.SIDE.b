* @ValidationCode : Mjo4MTAwNjE3MjI6Q3AxMjUyOjE1OTE5NzI1Nzk3NDg6c3RoZWphc3dpbmk6MTI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NTo5Njo4OQ==
* @ValidationInfo : Timestamp         : 12 Jun 2020 20:06:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sthejaswini
* @ValidationInfo : Nb tests success  : 12
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 89/96 (92.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-84</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Reporting

SUBROUTINE OC.UPD.CPARTY.SIDE(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
**<Routine description>
*
*The routine will be attached as a link routine in tx.txn.base.mapping record to determine whether the
*T24 bank is buyer or seller.
*
*
* Incoming parameters:
*
* APPL.ID  - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val - "B" -when t24 bank is buyer.
*         - "S"  -when t24 bank is seller.
*
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
* 14/04/20 - Enhancement 3689595 / Task 3689597
*            CI#2 - Mapping routines - Part I
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
*-----------------------------------------------------------------------------

    $USING SW.Contract
    $USING FX.Contract
    $USING FR.Contract
    $USING DX.Trade
*-----------------------------------------------------------------------------

    GOSUB INITIALISE ; *INITIALISE
    GOSUB PROCESS ; *PROCESS

RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISE </desc>

    CURRENCY=''
    RET.VAL=''
    PurchaseOrSale = ''

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>PROCESS </desc>


    BEGIN CASE

        CASE APPL.ID[1,2] EQ 'FX';*Sort the 2 currencies alphabetically.

            CURRENCY<1> =APPL.REC<FX.Contract.Forex.CurrencyBought>
            CURRENCY<2> =APPL.REC<FX.Contract.Forex.CurrencySold>
            SORT.CURRENCY = SORT(CURRENCY);*sort 2 currencies
            CURRENCY.1 = SORT.CURRENCY<1>

            IF CURRENCY.1 EQ APPL.REC<FX.Contract.Forex.CurrencyBought> THEN;*If t24 bank is buying the first ccy,then BUYER else SELLER.
                RET.VAL= 'B'
            END ELSE
                RET.VAL ='S'
            END


        CASE APPL.ID[1,2] EQ 'ND'

            IF APPL.REC<FX.Contract.NdDeal.NdDealBuySellInd> EQ 'BUY' THEN;*when t24 bank is buyer,then ret val is 'B' else 'S'
                RET.VAL ='B'
            END ELSE
                RET.VAL='S'
            END

        CASE APPL.ID[1,2] EQ 'FR'
            PurchaseOrSale = APPL.REC<FR.Contract.FraDeal.FrdPurchaseSale>
            IF PurchaseOrSale EQ "PURCHASE" THEN
                RET.VAL = "B"
            END ELSE
                RET.VAL = "S"
            END
        
        CASE APPL.ID[1,2] EQ 'DX'
            PurchaseOrSale = APPL.REC<DX.Trade.Trade.TraPriBuySell>
            IF PurchaseOrSale EQ "BUY" THEN
                RET.VAL = "B"
            END ELSE
                RET.VAL = "S"
            END
                
        CASE APPL.ID[1,2] EQ 'SW'

            AS.RATE.KEY = APPL.REC<SW.Contract.Swap.AsRateKey>
            LB.RATE.KEY=APPL.REC<SW.Contract.Swap.LbRateKey>

            BEGIN CASE

                CASE AS.RATE.KEY AND NOT(LB.RATE.KEY) ;*float - fixed swap
                    RET.VAL = 'B' ;*buyer is the one who pays fixed rate..hence T24 bank

                CASE NOT(AS.RATE.KEY) AND LB.RATE.KEY ; *fixed -float swap
                    RET.VAL = 'S';*seller is the one who pays float rate

                CASE AS.RATE.KEY AND LB.RATE.KEY;*float float (basis swap)

*Fetch schedule type and date freq details fron the swap contract.

                    AS.TYPE = APPL.REC<SW.Contract.Swap.AsType>
                    LB.TYPE = APPL.REC<SW.Contract.Swap.LbType>
                    AS.DATE.FREQ = APPL.REC<SW.Contract.Swap.AsDateFreq>
                    LB.DATE.FREQ=APPL.REC<SW.Contract.Swap.LbDateFreq>

                    SCHED.TYPE = AS.TYPE
                    DATE.FREQ=AS.DATE.FREQ
                    GOSUB CHECK.FREQ ;*check for shorter frequency.

                    AS.SCHED.FREQ = SCHED.FREQ

                    SCHED.TYPE = LB.TYPE
                    DATE.FREQ=LB.DATE.FREQ
                    GOSUB CHECK.FREQ;*check for shorter frequency.

                    LB.SCHED.FREQ=SCHED.FREQ

                    GOSUB CHECK.SHORT.DURATION ; *

            END CASE
    END CASE

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CHECK.FREQ>
CHECK.FREQ:
*** <desc> </desc>

*Locate IP schedule

    LOCATE 'IP' IN SCHED.TYPE<1,1> SETTING POS THEN
        IP.DATE.FREQ = DATE.FREQ<1,POS>;*fetch the date freq of corresponding IP schedule.
    END

    FREQ = IP.DATE.FREQ[9,5];*Fetch freq part from the date entered..

    IF FREQ NE '' THEN;*if freq defined and not adhoc schedule

        BEGIN CASE

            CASE FREQ[1,1] EQ 'D';*for daily freq

                SCHED.FREQ = 1


            CASE FREQ[1,1] EQ 'W';*for weekly freq

                SCHED.FREQ = 2

            CASE FREQ[1,1] EQ 'M';*for monthly freq

                SCHED.FREQ = 3

        END CASE

    END
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CHECK.SHORT.DURATION>
CHECK.SHORT.DURATION:
*** <desc> </desc>

    BEGIN CASE

        CASE AS.SCHED.FREQ EQ LB.SCHED.FREQ;*In case of same duration,check for spread.

            GOSUB CHECK.SPREAD;*if spread undefined,then logic open for clients.

        CASE AS.SCHED.FREQ LT LB.SCHED.FREQ;*Asset Ip payments scheduled for shorter duration.

            RET.VAL = 'S';*Seller is the one who receives shorter duration.

        CASE LB.SCHED.FREQ LT AS.SCHED.FREQ;*Liability payments scheduled for shorter duration.

            RET.VAL='B';*Buyer is the one who pays shorter duration.Here T24 bank.

    END CASE


RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CHECK.SPREAD>
CHECK.SPREAD:
*** <desc> </desc>

    AS.SPREAD = APPL.REC<SW.Contract.Swap.AsSpread>
    LB.SPREAD =APPL.REC<SW.Contract.Swap.LbSpread>

    BEGIN CASE

        CASE AS.SPREAD AND NOT(LB.SPREAD)

            RET.VAL = 'S';*T24 bank receives spread.

        CASE LB.SPREAD AND NOT(AS.SPREAD);*T24 bank pays spread..hence buyer.

            RET.VAL ='B'

    END CASE

*If spread defined on both sides,then logic open for clients.

RETURN
*** </region>

END





