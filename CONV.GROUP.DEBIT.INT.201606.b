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
* <Rating>-45</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.Config
    SUBROUTINE CONV.GROUP.DEBIT.INT.201606(ID, R.GDI,FILE)
*-----------------------------------------------------------------------------
* @author punithkumar@temenos.com
*
*Conversion routine to update the DR.MIN.VALUE by prefixing with group’s currency(Ex: 100 to USD100) 
*for GROUP.DEBIT.INT application 
*-----------------------------------------------------------------------------
* Modification History :
* 12/05/2016 - Defect 1693157 / Task 1724419
*              New Convertion introduced in the upgrade process in order to update
*              DR.MIN.VALUE prefixed with currency based on its group’s currency
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.API
    $USING IC.Config

*-----------------------------------------------------------------------------
    
    GOSUB INITIALISE
    GOSUB UPDATE.DR.MIN.VALUE
    
    RETURN

*****************************************************************************
INITIALISE:
**********
    DR.MIN.VAL=''
    DR2.MIN.VAL =''
    MIN.VAL = ''
    NEW.MIN.VAL = ''
    
    RETURN

*****************************************************************************
*Update the DR.MIN.VALUE prefixing with currency
UPDATE.DR.MIN.VALUE:
*******************
    DR.MIN.VAL = R.GDI<IC.Config.GroupDebitInt.GdiDrMinValue>
    DR2.MIN.VAL = R.GDI<IC.Config.GroupDebitInt.GdiDrTwoMinValue>

    IF (DR.MIN.VAL NE '') AND NUM(DR.MIN.VAL[1,3]) THEN             ;*update only for value not prefixed with Currency during rerun
        MIN.VAL = DR.MIN.VAL
        GOSUB GET.NEW.MIN.VALUE
        R.GDI<IC.Config.GroupDebitInt.GdiDrMinValue> = NEW.MIN.VAL  ;*assign the new value
    END

    IF (DR2.MIN.VAL NE '') AND NUM(DR2.MIN.VAL[1,3]) THEN            ;*update only for value not prefixed with Currency during rerun
        MIN.VAL = DR2.MIN.VAL
        GOSUB GET.NEW.MIN.VALUE
        R.GDI<IC.Config.GroupDebitInt.GdiDrTwoMinValue> = NEW.MIN.VAL ;*assign the new value
    END

    RETURN

*****************************************************************************
*get the correct value to be replaced in the DR.MIN.VALUE field
GET.NEW.MIN.VALUE:
***************

        AMOUNT = MIN.VAL
        YGENCONDI = ID[1,LEN(ID)-11] ;*get the group condition
        CCY = ID[LEN(YGENCONDI)+1,3]
        NEW.MIN.VAL = CCY:AMOUNT     ;*append the currency

    RETURN

*****************************************************************************
    END
