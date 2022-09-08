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

* Version 2 06/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-9</Rating>
*-----------------------------------------------------------------------------

    $PACKAGE LC.Contract

    SUBROUTINE LC.GET.PORTION.NO

    $USING LC.Contract
    $USING EB.SystemTables

************************************************************
    !1/12/99 GB9901566
    !        This program will populate the PORTION.NO which is the order
    !        in which the mixed payment set was inputted. Since most of
    !        the amendments to LC will result in only the differential
    !        amount being updated this field is important to know where
    !        is the position of the current set in R.OLD and R.NEW.LAST
*
* 20/02/07 - BG_100013043
*            CODE.REVIEW changes.
*
*
* 24/11/14- TASK : 1165602
*			 LC Componentization and Incorporation
*			 DEF : 990544
*
***************************************************************

    PORT.ARRAY=EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPortionNo)
    PORT.ARRAY.OLD=EB.SystemTables.getROld(LC.Contract.LetterOfCredit.TfLcPortionNo)
    IF EB.SystemTables.getRNewLast(1) NE '' THEN
        PORT.ARRAY.OLD=EB.SystemTables.getRNewLast(LC.Contract.LetterOfCredit.TfLcPortionNo)
    END
    IF EB.SystemTables.getROld(1) NE '' OR EB.SystemTables.getRNewLast(1) NE '' THEN
        IF EB.SystemTables.getComi() NE "" AND EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPortionNo) EQ "" THEN
            tmp=EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPortionNo)
            temp.Av = EB.SystemTables.getAv()
            tmp<1,temp.Av>=1
            EB.SystemTables.setRNew(LC.Contract.LetterOfCredit.TfLcPortionNo, tmp)
        END
        IF EB.SystemTables.getComi() NE "" AND EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPortionNo)<1,EB.SystemTables.getAv()> EQ "" THEN
            MAX.NO=MAXIMUM(PORT.ARRAY)
            MAX.NO.OLD=MAXIMUM(PORT.ARRAY.OLD)
            IF MAX.NO LT MAX.NO.OLD THEN
                MAX.NO=MAX.NO.OLD       ;* BG_100013043 - S
            END     ;* BG_100013043 - E
            tmp=EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPortionNo)
            temp.Av = EB.SystemTables.getAv()
            tmp<1,temp.Av>=MAX.NO + 1
            EB.SystemTables.setRNew(LC.Contract.LetterOfCredit.TfLcPortionNo, tmp)
        END
    END
    RETURN
    END
