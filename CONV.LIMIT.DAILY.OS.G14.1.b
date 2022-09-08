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
*   This conversion routine is written for the limit utilisation
*   enchancement. A new field REPL.VALUE is added to LIMIT.DAILY.OS,
*   and this routine is used to convert the data for the above
*   said field.
*
*
    $PACKAGE LI.LimitTransaction
    SUBROUTINE CONV.LIMIT.DAILY.OS.G14.1(ID,LIMIT.OS.REC,YFILE)

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LIMIT.DAILY.OS
*
* Assigning LIMIT.OS.REC to TEMP.REC which will hold the
* old position of all the fields
    TEMP.REC = LIMIT.OS.REC
    YREC = ''
* Re-assigning of data to appropriate fields(old) due
* to addition of new fields
*
    YREC<1> = TEMP.REC<1>
    YREC<2> = TEMP.REC<2>
    YREC<3> = TEMP.REC<3>
    YREC<4> = TEMP.REC<4>
    YREC<5> = TEMP.REC<5>
    YREC<6> = TEMP.REC<6>
    YREC<7> = TEMP.REC<7>
    YREC<8> = TEMP.REC<8>
    YREC<9> = ''
    YREC<10>= TEMP.REC<9>
    YREC<11>= TEMP.REC<10>
    YREC<12>= TEMP.REC<11>
    YREC<13>= TEMP.REC<12>
    YREC<14>= TEMP.REC<13>
    YREC<15>= TEMP.REC<14>
    YREC<16>= TEMP.REC<15>
    YREC<17>= TEMP.REC<16>
    LIMIT.OS.REC = YREC
    RETURN
END
