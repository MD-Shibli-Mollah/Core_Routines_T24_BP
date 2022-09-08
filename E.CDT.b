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

* Version 2 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-18</Rating>
*
* 25/4/15 - 1322379
*           Incoporation of components
*
*-----------------------------------------------------------------------------
    $PACKAGE FD.Reports
    SUBROUTINE E.CDT(RETURN.DATE, REGION.CODE, START.DATE, NO.DAYS)
*

    $USING EB.API
    $USING EB.SystemTables
** This routine is used to call CDT as an I-Descriptor item for
** applications.
** PARAMETERS :
**  RETURN.DATE - Output the result
**  REGION.CODE - The Region or Local country or NULL (default Local)
**  START.DATE  - The base date for the call (default TODAY)
**  NO.DAYS     - +1C , -2W etc
*
    RETURN.DATE = ""
    EB.SystemTables.setEtext("")
    BEGIN CASE
        CASE NO.DAYS MATCHES "1N0N"
            NO.DAYS = "+":NO.DAYS:"C"
        CASE NO.DAYS MATCHES "'+'1N0N":@VM:"'-'1N0N"
            NO.DAYS := "C"
        CASE NOT(NO.DAYS MATCHES "'+'1N0N'C'":@VM:"'+'1N0N'W'":@VM:"'-'1N0N'C'":@VM:"'-'1N0N'W'")
            RETURN.DATE = "INVALID NO DAYS"
    END CASE
*
    IF LEN(REGION.CODE) = 2 THEN      ;* BG_100018509 S/E
        REGION.CODE := "00"
    END
*
    IF START.DATE = "" THEN            ;* BG_100018509 S/E
        START.DATE = EB.SystemTables.getToday()
    END
*
    IF NOT(RETURN.DATE) THEN
        *
        EB.API.Cdt(REGION.CODE, START.DATE, NO.DAYS)
        *
        IF EB.SystemTables.getEtext() THEN
            RETURN.DATE = EB.SystemTables.getEtext()
        END ELSE
            RETURN.DATE = START.DATE
        END
    END
*
    RETURN
    END
