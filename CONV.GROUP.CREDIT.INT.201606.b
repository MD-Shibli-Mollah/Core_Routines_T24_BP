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
    SUBROUTINE CONV.GROUP.CREDIT.INT.201606(ID, R.GCI,FILE)
*-----------------------------------------------------------------------------
* @author punithkumar@temenos.com
*
*Conversion routine to update the CR.MIN.VALUE by prefixing with group’s currency(Ex: 100 to USD100) 
*for GROUP.CREDIT.INT application 
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
    GOSUB UPDATE.CR.MIN.VALUE

    RETURN
    
*****************************************************************************
INITIALISE:
**********
    CR.MIN.VAL=''
    CR2.MIN.VAL =''
    MIN.VAL = ''
    NEW.MIN.VAL = ''

    RETURN

*****************************************************************************
*Update the CR.MIN.VALUE prefixing with currency
UPDATE.CR.MIN.VALUE:
*******************
    CR.MIN.VAL = R.GCI<IC.Config.GroupCreditInt.GciCrMinValue>
    CR2.MIN.VAL = R.GCI<IC.Config.GroupCreditInt.GciCrTwoMinValue>

    IF (CR.MIN.VAL NE '') AND NUM(CR.MIN.VAL[1,3]) THEN              ;*update only for value not prefixed with Currency during rerun
        MIN.VAL = CR.MIN.VAL
        GOSUB GET.NEW.MIN.VALUE
        R.GCI<IC.Config.GroupCreditInt.GciCrMinValue> = NEW.MIN.VAL  ;*assign the new value

    END

    IF (CR2.MIN.VAL NE '') AND NUM(CR2.MIN.VAL[1,3]) THEN             ;*update only for value not prefixed with Currency during rerun
        MIN.VAL = CR2.MIN.VAL
        GOSUB GET.NEW.MIN.VALUE
        R.GCI<IC.Config.GroupCreditInt.GciCrTwoMinValue> = NEW.MIN.VAL ;*assign the new value
    END

    RETURN

*****************************************************************************
*get the correct value to be replaced in the CR.MIN.VALUE field
GET.NEW.MIN.VALUE:
***************

        AMOUNT = MIN.VAL
        YGENCONDI = ID[1,LEN(ID)-11] ;*get the group condition
        CCY = ID[LEN(YGENCONDI)+1,3]
        NEW.MIN.VAL = CCY:AMOUNT     ;*append the currency

    RETURN

*************************************************************************

    END
