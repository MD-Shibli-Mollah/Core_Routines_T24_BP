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
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE V.VAL.CARD.NUM

**************************************************************
* Field validation Routine
**************************************************************
* 13/12/2010 - New Development
* Purpose    -  Field validation for Card Number to check the digit
* Developed By - Abinanthan K B
*
* 07/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
**************************************************************

    $USING EB.SystemTables
    $USING EB.ErrorProcessing

    IF EB.SystemTables.getMessage() EQ 'VAL' THEN
        RETURN
    END

    IF LEN(EB.SystemTables.getComi()) LT 16 THEN
        EB.SystemTables.setEtext("EB-CARD.CHECK.DIGIT")
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END
    RETURN
    END
