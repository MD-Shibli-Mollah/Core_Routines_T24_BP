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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OP.ModelBank
    SUBROUTINE APPL.CALC.AGE(AGE,AGEONDATE,BIRTHDAY)
* Input subroutine
* 04-03-16 - 1653120
*            Incorporation of components
    
    $USING OP.ModelBank
    
*
*** check if the customer is in the file and then load the details
*
    AGE = ""
    AGE = AGEONDATE[1,4] - BIRTHDAY[1,4]
    BEGIN CASE
    CASE AGEONDATE[5,2] < BIRTHDAY[5,2]
        AGE -= 1
    CASE AGEONDATE[5,2] = BIRTHDAY[5,2]
        IF AGEONDATE[7,2] < BIRTHDAY[7,2] THEN
            AGE -= 1
        END
    END CASE

    RETURN
END
