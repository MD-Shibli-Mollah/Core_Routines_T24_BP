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

* Version 4 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.TXN.DATE
*-----------------------------------------------------------------------------
*
* Enquiry routine to return a date in YYYYMMDD format from a
* 1.    transaction ref XXYYDDDNNNNN or XXXXYYDDDNNNNN
* 2.    julian date YYDDD or YYYYDDD
*
* GB9800960 - 30/07/1998
*             Change date validation to ensure century compliance.
*
* CI_10066736 - 10/10/09
*             Incorrect date format when the year less than 2011
*
*------------------------------------------------------------------------
*
    $USING EB.Reports
*
*------------------------------------------------------------------------
*
    tmp.O.DATA = EB.Reports.getOData()
    LENGTH = LEN(tmp.O.DATA[";",1,1])       ;* Ignore history bit
*
    BEGIN CASE
        CASE LENGTH = 12          ;* XXYYDDDNNNNN
            JULIAN = EB.Reports.getOData()[3,5]
            GOSUB CONVERT.DATE
        CASE LENGTH = 14          ;* XXXXYYDDDNNNNN
            JULIAN = EB.Reports.getOData()[5,5]
            GOSUB CONVERT.DATE
        CASE LENGTH = 16          ;* XXXXXXYYDDDNNNNN
            JULIAN = EB.Reports.getOData()[7,5]
            GOSUB CONVERT.DATE
        CASE LENGTH = 7 ;* YYYYDDD
            JULIAN = EB.Reports.getOData()[3,5]
            GOSUB CONVERT.DATE
        CASE LENGTH = 5 ;* YYDDD
            JULIAN = EB.Reports.getOData()
            GOSUB CONVERT.DATE
        CASE 1
            NULL
    END CASE
*
    RETURN
*
*-----------------------------------------------------------------------
*
CONVERT.DATE:
*
    IF NUM(JULIAN) THEN

        IF JULIAN[1,2] = 0 THEN
            YEAR = '31/12/99' ;* Take previous year end date when the year from Julian date as "00". For e.g: 2000
        END ELSE    ;* Year from Julian date not equal to '00'
            YEAR = "31/12/": FMT(JULIAN[1,2]-1,"2'0'R")     ;* Take previous year end date e.g :Year from julian date: 03, Then FMT(03-1,"2'0'R") = 02
        END

        INTERNAL = ICONV(YEAR, "D2E")+JULIAN[3,3] ;* The no.of days from 01/JAN/1968 to end of the Previous year + Nth day of current year
        DT = OCONV(INTERNAL,"D.E")      ;* Convert the internal date in to external date format(User understandable form). For e.g: DD.MM.YYYY
        EB.Reports.setOData(DT[4]: DT[4,2]: DT[1,2]);* Form the data as: YYYYMMDD
    END

    RETURN
*
*------------------------------------------------------------------------
    END
