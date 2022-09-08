* @ValidationCode : MjoxNjQ3OTQxMjY0OmNwMTI1MjoxNDg3MDc4NDk4Nzk3OmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Feb 2017 18:51:38
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201612.20161102-1142
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.MATURITY.DATE(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* For FOREX-It returns Value date ( in case of split value date the earliest date)
* For SWAP - It returns Value of MATURITY.DATE of the contract with CURR.NO 1
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
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
* Ret.val- Variable holding the value of MATURITY DATE.
*
*
*******************************************************************

    $USING FX.Contract
    $USING SW.Contract

*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB DETERMINE.FOR.T24.BANK

    RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISE </desc>

    RET.VAL=''

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
DETERMINE.FOR.T24.BANK:
*** <desc>PROCESS </desc>


    BEGIN CASE
            * FOREX- Maturity Date is the Value date ( in case of split value date the earliest date)
        CASE APPL.ID[1,2] EQ 'FX'

            RET.VAL = APPL.REC<FX.Contract.Forex.ValueDateBuy>
            BEGIN CASE

                CASE APPL.REC<FX.Contract.Forex.ValueDateBuy> EQ APPL.REC<FX.Contract.Forex.ValueDateSell>
                    RET.VAL = APPL.REC<FX.Contract.Forex.ValueDateBuy>
                CASE  APPL.REC<FX.Contract.Forex.ValueDateBuy> GT APPL.REC<FX.Contract.Forex.ValueDateSell>
                    RET.VAL = APPL.REC<FX.Contract.Forex.ValueDateSell>
                CASE APPL.REC<FX.Contract.Forex.ValueDateSell> GT APPL.REC<FX.Contract.Forex.ValueDateBuy>
                    RET.VAL = APPL.REC<FX.Contract.Forex.ValueDateBuy>

            END CASE
            * SWAP Contracts
            * Value of MATURITY.DATE of the contract with CURR.NO 1
        CASE APPL.ID[1,2] = 'SW'

            IF APPL.REC<SW.Contract.Swap.CurrNo> = '1' THEN
                RET.VAL = APPL.REC<SW.Contract.Swap.MaturityDate>
            END ELSE
                SWAP.ID = APPL.ID : ';1'
                R.SWAP$HIS = SW.Contract.Swap.ReadHis(SWAP.ID, ERR.MSG)
                * Before incorporation : CALL F.READ(FN.SWAP$HIS, SWAP.ID, R.SWAP$HIS, F.SWAP$HIS, ERR.MSG)
                RET.VAL = R.SWAP$HIS<SW.Contract.Swap.MaturityDate>

            END

    END CASE
    RETURN
*** </region>

*-----------------------------------------------------------------------------


    END
