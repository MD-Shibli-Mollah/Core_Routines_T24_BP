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

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-4</Rating>
*
* 25/4/15 - 1322379
*           Incoporation of components
*
*-----------------------------------------------------------------------------
    $PACKAGE FD.Reports
    SUBROUTINE E.CALL.MATDATE
*
*
    $USING ST.Config
    $USING EB.API
    $USING EB.Reports
    $USING EB.SystemTables

** This routine will return the maturity date of call notice contract
** assuming that the notice period is satisfied
** Incoming : O.DATA - Notice period:"-":CCY
** Outgoing : O.DATA - Today plus N working days
*
    DAYS.NOTICE = EB.Reports.getOData()["-",1,1]
    CCY = EB.Reports.getOData()["-",2,1]
    IF DAYS.NOTICE LT 1000 THEN
        YDATE = EB.SystemTables.getToday()
        IF CCY THEN
            COUNTRY.CODE = CCY[1,2]
            DEFAULT.DATE = "" ; RETURN.CODE = ""
            ST.Config.WorkingDay("" , YDATE, "", DAYS.NOTICE, "", COUNTRY.CODE, "", DEFAULT.DATE, RETURN.CODE, "")
            EB.Reports.setOData(DEFAULT.DATE)
        END ELSE
            YDISP = DAYS.NOTICE:"C"
            EB.API.Cdt("",YDATE,YDISP)
            EB.Reports.setOData(YDATE)
        END
    END ELSE
        EB.Reports.setOData(DAYS.NOTICE)
    END
*
    END
