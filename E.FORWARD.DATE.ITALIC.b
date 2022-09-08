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
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.FORWARD.DATE.ITALIC(GET.VALUE,SET.VALUE)

* New routine has been developed to display the date in italic if the payment done
* in forward dated
*-----------------------------------------------------------------------------
    $USING EB.SystemTables


    GET.VALUE = ICONV(GET.VALUE,"D")
    CURRENT.DATE = EB.SystemTables.getToday()
    CURRENT.DATE = ICONV(CURRENT.DATE,"D")
    IF GET.VALUE GT CURRENT.DATE THEN
        SET.VALUE = "Italic" ;* If payment happened greater then today then it will be displayed in italic format
    END

    RETURN
    END
