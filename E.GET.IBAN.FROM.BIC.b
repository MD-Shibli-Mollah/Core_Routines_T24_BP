* @ValidationCode : MjoxNDUxOTQxMzI0OkNwMTI1MjoxNTk3ODQxMTA4OTQ0OmJzYXVyYXZrdW1hcjoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6MjU6MjI=
* @ValidationInfo : Timestamp         : 19 Aug 2020 18:15:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 22/25 (88.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
$PACKAGE IN.Config

SUBROUTINE E.GET.IBAN.FROM.BIC(IBAN.NO)
*-----------------------------------------------------------------------------
*<doc>
* Enquiry routine that used for fetching the IBAN from the input BIC/INST.NAME and CITY.HEADING.
* @author tejomaddi@temenos.com
* @stereotype Application
* @IN_Config
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 02/06/12 - Enhancement 379826/SI 167927
*            Payments - Development for IBAN.
*
* 11/10/13 - Enhancement 785613 / Task 809936
*            Supporting IBAN Plus Directory (SWIFT 2013 changes), IBAN related information
*            is no more available in DE.BIC, changes done to get IBAN PLUS id in the enquiry
*
* 19/08/20 - Defect 3886076 / Task 3921269
*            Enquiry getIBANfromBIC not working when INST.NAME and CITY.HD contains spaces
*-----------------------------------------------------------------------------
* <region name= Inserts>
    $USING EB.Reports
    $USING IN.Config
* </region>
*-----------------------------------------------------------------------------

    IBAN.PLUS.ID = ''
    BIC.ID = ''
    AC.NO = ''
    INST.NAME = ''
    CITY.HD  = ''

    LOCATE "BIC.ID" IN EB.Reports.getDFields()<1> SETTING PR.POS THEN
        BIC.ID = EB.Reports.getDRangeAndValue()<PR.POS>
    END

    LOCATE "AC.NO" IN EB.Reports.getDFields()<1> SETTING AC.POS THEN
        AC.NO = EB.Reports.getDRangeAndValue()<AC.POS>
    END

    LOCATE "INST.NAME" IN EB.Reports.getDFields()<1> SETTING INST.POS THEN
        INST.NAME = EB.Reports.getDRangeAndValue()<INST.POS>
        CONVERT @SM TO " " IN INST.NAME ;* Institution Name can have spaces which are converted to SM in CONCAT.LIST.PROCESSOR. So convert them back to original
    END

    LOCATE "CITY.HD" IN EB.Reports.getDFields()<1> SETTING PR.POS THEN
        CITY.HD = EB.Reports.getDRangeAndValue()<PR.POS>
        CONVERT @SM TO " " IN CITY.HD   ;* City can have spaces which are converted to SM in CONCAT.LIST.PROCESSOR. So convert them back to original
    END

    LOCATE "NAT.ID" IN EB.Reports.getDFields()<1> SETTING PR.POS THEN
        IBAN.PLUS.ID = EB.Reports.getDRangeAndValue()<PR.POS>
    END

    IN.Config.Getibanfrombic(BIC.ID, AC.NO, INST.NAME, CITY.HD, IBAN.PLUS.ID, RET.IBAN, RET.CD)
    IBAN.NO = RET.IBAN

RETURN
*-----------------------------------------------------------------------------
END
