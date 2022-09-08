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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
*   This routine is used for to convert the data after
*   inserting the below new fields in LIMIT.FX.PROFIT.LOSS
*   for the limit utilisation enchancement
*
*  2. NET.CURRENCY
*  3. TOT.BUY.POS
*  4. TOT.SELL.POS
*  10. MARGIN.AMT
*  11. TOTAL.CUS.LOSS
*  12. TOTAL.CUS.PROFIT
*  13. TOTAL.CUS.PL
*
*
    $PACKAGE LI.LimitTransaction
    SUBROUTINE CONV.LI.FX.PROFIT.LOSS.G14.1(ID,LI.FX.REC,YFILE)

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LIMIT.FX.PROFIT.LOSS
* Assigning LI.FX.REC to TEMP.REC which will hold the
* old position of all the fields
    TEMP.REC = LI.FX.REC
    YREC = ''
* Re-assigning of data to appropriate fields(old) due
* to addition of new fields
    YREC<1> = TEMP.REC<1>
    YREC<2> = ''
    YREC<3> = ''
    YREC<4> = ''
    YREC<5> = TEMP.REC<2>
    YREC<6> = TEMP.REC<3>
    YREC<7> = TEMP.REC<4>
    YREC<8> = TEMP.REC<5>
    YREC<9> = TEMP.REC<6>
    YREC<10>= ''
    YREC<11>= ''
    YREC<12>= ''
    YREC<13>= TEMP.REC<7>
    YREC<14>= TEMP.REC<8>
    YREC<15>= TEMP.REC<9>
    LI.FX.REC = YREC
    RETURN
END
