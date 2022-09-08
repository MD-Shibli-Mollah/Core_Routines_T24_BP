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

*-----------------------------------------------------------------------------
* <Rating>-15</Rating>
*-----------------------------------------------------------------------------
* Version 4 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*
    $PACKAGE SW.Foundation
    SUBROUTINE CONV.SW.DETERMINE.SETTLEMENT.INFO(ACCOUNT.CURRENCY,ACCOUNT.PAYMENT,ACCOUNT.TYPE,SETTLEMENT.INFO)
*
*************************************************************************
*                                                                       *
*  Routine     :  CONV.SW.DETERMINE.SETTLEMENT.INFO                          *
*                                                                       *
*************************************************************************
*                                                                       *
*  Description : Routine to determine Client principal / interest       *
*                settlement details.                                    *
*                                                                       *
*                Arguments supplied :                                   *
*                                                                       *
*                ACCOUNT.CURRENCY    Currency of account.               *
*                ACCOUNT.PAYMENT     'PAYMENT', 'RECEIPT', or null.     *
*                ACCOUNT.TYPE        'PRINCIPAL', 'INTEREST', or null.  *
*                                                                       *
*                Arguments returned :                                   *
*                                                                       *
*                SETTLEMENT.INFO     Settlement details.                *
*                                                                       *
*                  Format -                                             *
*                                                                       *
*                  SETTLEMENT.INFO<1> Client Account number.            *
*                  SETTLEMENT.INFO<2> Cust code of intermediary bank.   *
*                  SETTLEMENT.INFO<3> Address of Intermediary (raised). *
*                  SETTLEMENT.INFO<4> Cust code of bank.                *
*                  SETTLEMENT.INFO<5> Banks address (raised).           *
*                  SETTLEMENT.INFO<6> Beneficiary account number.       *
*                  SETTLEMENT.INFO<7> Bank to bank narrative (raised).  *
*                  SETTLEMENT.INFO<8> External Account Number for nostro*
*                                                                       *
*************************************************************************
*                                                                       *
*  Modifications :                                                      *
*                                                                       *
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CONV.SWAP
    $INSERT I_SW.COMMON
    $INSERT I_F.CUSTOMER
    $INSERT I_F.ACCOUNT
*
*************************************************************************
*
* assume that ACCOUNT.CURRENCY is in R$SWAP<SW.SET.CURRENCY>
* the logic to get the best match is as follows:
* 1. ACCOUNT.TYPE is more significant than ACCOUNT.PAYMENT
* 2. exact match wins don't care (null value in contract)
* 3. don't care wins mismatch
* 4. the ones without mismatch are more favourable than the ones have
*
*************************************************************************
*
    BEST.MATCH = -1
    SETTLEMENT.INFO = ""
*
    IDX = 0
    LOOP IDX+=1 UNTIL R$SWAP<SW.SET.CURRENCY,IDX> = ""
*
        IF ACCOUNT.CURRENCY = R$SWAP<SW.SET.CURRENCY,IDX> THEN
*
* 2 for exact match
* 1 for don't care
* 0 for mismatch
*
            GOSUB GET.SETTL.INFO

        END
*
    REPEAT
*
    RETURN
*

GET.SETTL.INFO:

    IF ACCOUNT.TYPE = R$SWAP<SW.SET.TYPE,IDX> THEN
        ACC.MATCH = 2
    END ELSE
        IF R$SWAP<SW.SET.TYPE,IDX> = '' THEN
            ACC.MATCH = 1
        END ELSE
            ACC.MATCH = 0
        END
    END
*
    IF ACCOUNT.PAYMENT = R$SWAP<SW.SET.PAY.RECEIPT,IDX> THEN
        ACC.MATCH := 2
    END ELSE
        IF R$SWAP<SW.SET.PAY.RECEIPT,IDX> = '' THEN
            ACC.MATCH := 1
        END ELSE
            ACC.MATCH := 0
        END
    END
*
* make sure the one without mismatch is GT the one has
*
    IF INDEX(ACC.MATCH, '0', 1) THEN
        ACC.MATCH = 0:ACC.MATCH
    END ELSE
        ACC.MATCH = 1:ACC.MATCH
    END
*
    IF ACC.MATCH + 0 > BEST.MATCH THEN
        BEST.MATCH = ACC.MATCH
*
        SETTLEMENT.INFO<1> = R$SWAP<SW.ACCOUNT.NUMBER,IDX>
        SETTLEMENT.INFO<2> = R$SWAP<SW.INTERMEDIARY,IDX>
        SETTLEMENT.INFO<3> = RAISE(R$SWAP<SW.INTERM.ADD,IDX>)
        SETTLEMENT.INFO<4> = R$SWAP<SW.ACCT.WITH.BANK,IDX>
        SETTLEMENT.INFO<5> = RAISE(R$SWAP<SW.ACC.WITH.ADD,IDX>)
        SETTLEMENT.INFO<6> = R$SWAP<SW.BEN.ACCOUNT,IDX>
        SETTLEMENT.INFO<7> = RAISE(R$SWAP<SW.BANK.NARR,IDX>)
*
** Return the external account number
*
        CUST.NO = "" ; EXT.ACC.NO = ""
        CALL DBR("ACCOUNT":FM:AC.CUSTOMER, R$SWAP<SW.ACCOUNT.NUMBER,IDX>, CUST.NO)
        IF CUST.NO THEN
            CALL GET.EXT.ACC.NO(CUST.NO, R$SWAP<SW.ACCOUNT.NUMBER,IDX>, EXT.ACC.NO)
        END
        SETTLEMENT.INFO<8> = EXT.ACC.NO
*
    END
*
    RETURN


END
