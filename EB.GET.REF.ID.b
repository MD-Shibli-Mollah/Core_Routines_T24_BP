* @ValidationCode : MjotMTY3NzEzMTgxOmNwMTI1MjoxNjE0MDYyOTY2MjY1OmJjYXBvb3J2YTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6ODo4
* @ValidationInfo : Timestamp         : 23 Feb 2021 12:19:26
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : bcapoorva
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 8/8 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AC.ModelBank

SUBROUTINE EB.GET.REF.ID
*-----------------------------------------------------------------------------
* Routine to modify transaction reference in the enquiry STMT.ENT.DETAIL
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 06/08/20 - Defect 3879312 / Task 3897876
*            In enquiry STMT.ENT.BOOK, while trying to view the DD record, system throws 'Application missing' error.
*            After adding APPLICATION as DD.DD in EB.SYSTEM.ID > DD record manually, system throws another error 'TOO MANY MNEMONIC CHAR.'
*            The error is due to record ID of DD.DDI is prefixed with 'DD'
*
* 21/20/20 - Defect 4029022 / Task 4036514
*            Enquiry STMT.ENT.DETAIL not displaying transaction full view on drilldown
*
* 15/02/21 - Defect 4220355 / Task 4232803
*            Drilldown in enquiry STMT.ENT.DETAIL not opening the record if it is a DD.RETURN transaction
*
*-----------------------------------------------------------------------------
    $USING EB.Reports

    IN.O.DATA = EB.Reports.getOData()
    OUT.O.DATA = ''

* In the enquiry STMT.ENT.BOOK, system throws another error 'TOO MANY MNEMONIC CHAR.'
* The error is due to record ID of DD.DDI is prefixed with 'DD'
* There are two applications which can have ID starting with DD which is DD.DDI and DD.RETURN.
* For DD.RETURN, ID will look like DDR... Truncating DD holds good for DD.DDI. But for DD.RETURN,
* this truncation is making the ID invalid. Hence checking if the id does not begin with DDR
    IF IN.O.DATA[1,2] EQ "DD" AND IN.O.DATA[1,3] NE "DDR" THEN
        OUT.O.DATA = IN.O.DATA[3,LEN(IN.O.DATA)-2]
    END ELSE
        OUT.O.DATA = IN.O.DATA
    END

    EB.Reports.setOData(OUT.O.DATA)

END
