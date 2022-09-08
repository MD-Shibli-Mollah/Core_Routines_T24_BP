* @ValidationCode : MToxNzQyMjI5NTI5OmNwMTI1MjoxNDY1Nzk2NTYwNDkwOmNraXJhbjotMTotMTowOjA6ZmFsc2U6Ti9B
* @ValidationInfo : Timestamp         : 13 Jun 2016 11:12:40
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : ckiran
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>211</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Foundation
    SUBROUTINE MB.DX.MT202.MAPPING(MAT HANDOFF.REC,ERR.MSG)
*==============================================================================
*  This Routine is attached to the DE.MAPPING records of 202.DX.N
*   HANDOFF.REC contains the whole HANDOFF record.
*   ERR.MSG contains value if the HANDOFF record could not be read.
*Array 9.1 contains TRANS.REF
*Array 9.2 contains VALUE.DATE
*Array 9.3 contains PREMIUM.CCY
*Array 9.4 contains PREMIUM.AMOUNT
*Array 9.5 contains INTERMEDIARY.CUST
*Array 9.6 contains INTERMEDIARY C/D
*Array 9.7 contains CPY NUMBER
*Array 9.8 contains CPY ADDRESS
*Array 9.9 contains CPY BANK A/C
*Array 9.10 contains CUSTOMER / BENIFICIRY NO
*===============================================================================
*                         MODIFICATION HISTORY
*===============================================================================
* 13/08/13 -  Defect 457457 / Task 457916
*             This Routine contains the mapping information in user defined array
*
* 15/04/13 - Defect 643773 / Task 650221
*            Tag 57 of MT202 is appearing with wrong information and position.
*
* 01/03/16  - Defect 1322379 / Task 1632301
* 			  Incorporation of the routine
*===============================================================================



    $USING AC.AccountOpening
    $USING DX.Trade
    $USING EB.DataAccess


*-------------------------------------------------------------------------------


    PRI.BUY.SELL = HANDOFF.REC(3)<DX.Trade.Trade.TraPriBuySell>
    HEADER.ACCOUNT = HANDOFF.REC(1)<DX.Trade.Transaction.TxAccount>

    R.ACCOUNT = AC.AccountOpening.Account.Read(HEADER.ACCOUNT, ACC.ERR)
* Before incorporation : CALL F.READ('F.ACCOUNT',HEADER.ACCOUNT,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    HEADER.CUSTOMER = R.ACCOUNT<AC.AccountOpening.Account.Customer>

    HANDOFF.REC(9)<1> = HANDOFF.REC(1)<DX.Trade.Transaction.TxSourceId>
    HANDOFF.REC(9)<2> = HANDOFF.REC(1)<DX.Trade.Transaction.TxPremValDate>

    BEGIN CASE
        CASE PRI.BUY.SELL EQ 'BUY'
            HANDOFF.REC(9)<3> = HANDOFF.REC(1)<DX.Trade.Transaction.TxAccCcy>
            HANDOFF.REC(9)<4> = HANDOFF.REC(1)<DX.Trade.Transaction.TxPremPostAmt>
            HANDOFF.REC(9)<5> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecIntrBkNo>
            HANDOFF.REC(9)<6> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecIntrAdd>
            HANDOFF.REC(9)<7> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecCpyNo>
            HANDOFF.REC(9)<8> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecCpyAdd>
            HANDOFF.REC(9)<9> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecCpyBnkAcc>

            IF HANDOFF.REC(3)<DX.Trade.Trade.TraSecCpyNo> NE '' THEN
                *When customer information found that should be considered
                HANDOFF.REC(9)<7> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecCpyNo>
            END ELSE
                * Else the address should be considered
                HANDOFF.REC(9)<7> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecCpyAdd>
            END



            IF HANDOFF.REC(3)<DX.Trade.Trade.TraSecBenNo> EQ '' AND HANDOFF.REC(3)<DX.Trade.Trade.TraSecBenAdd> EQ '' THEN
                HANDOFF.REC(9)<10> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecCustNo>
            END ELSE
                HANDOFF.REC(9)<10> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecBenNo>
                HANDOFF.REC(9)<11> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecBenAdd>
            END

            HANDOFF.REC(9)<12> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecBk2bkIn>
            HANDOFF.REC(9)<13> = HEADER.CUSTOMER

            HANDOFF.REC(9)<14> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriCpyNo>
            HANDOFF.REC(9)<15> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriCpyBnkAcc>
            IF HANDOFF.REC(3)<DX.Trade.Trade.TraPriCpyNo> NE '' THEN
                *When customer information found that should be considered
                HANDOFF.REC(9)<14> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriCpyNo>
            END ELSE
                * Else the address should be considered
                HANDOFF.REC(9)<14> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriCpyAdd>
            END

        CASE PRI.BUY.SELL EQ 'SELL'
            HANDOFF.REC(9)<3> = HANDOFF.REC(1)<DX.Trade.Transaction.TxAccCcy>
            HANDOFF.REC(9)<4> = HANDOFF.REC(1)<DX.Trade.Transaction.TxPremPostAmt>
            HANDOFF.REC(9)<5> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriIntrBkNo>
            HANDOFF.REC(9)<6> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriIntrAdd>
            HANDOFF.REC(9)<7> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriCpyNo>
            HANDOFF.REC(9)<8> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriCpyAdd>
            HANDOFF.REC(9)<9> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriCpyBnkAcc>


            IF HANDOFF.REC(3)<DX.Trade.Trade.TraPriCpyNo> NE '' THEN
                *When customer information found that should be considered
                HANDOFF.REC(9)<7> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriCpyNo>
            END ELSE
                * Else the address should be considered
                HANDOFF.REC(9)<7> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriCpyAdd>
            END


            IF HANDOFF.REC(3)<DX.Trade.Trade.TraPriBenNo> EQ '' AND HANDOFF.REC(3)<DX.Trade.Trade.TraPriBenAdd> EQ '' THEN
                HANDOFF.REC(9)<10> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriCustNo>
            END ELSE
                HANDOFF.REC(9)<10> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriBenNo>
                HANDOFF.REC(9)<11> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriBenAdd>
            END

            HANDOFF.REC(9)<12> = HANDOFF.REC(3)<DX.Trade.Trade.TraPriBk2bkIn>
            HANDOFF.REC(9)<13> = HEADER.CUSTOMER
            HANDOFF.REC(9)<14> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecCpyNo>
            HANDOFF.REC(9)<15> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecCpyBnkAcc>
            IF HANDOFF.REC(3)<DX.Trade.Trade.TraSecCpyNo> NE '' THEN
                *When customer information found that should be considered
                HANDOFF.REC(9)<14> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecCpyNo>
            END ELSE
                * Else the address should be considered
                HANDOFF.REC(9)<14> = HANDOFF.REC(3)<DX.Trade.Trade.TraSecCpyAdd>
            END

    END CASE

    RETURN

*-------------------------------------------------------------------------------
    END
