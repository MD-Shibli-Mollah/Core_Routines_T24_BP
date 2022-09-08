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

* Version 6 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.Reports
    SUBROUTINE E.FX.F.DATE
*
*          ENQUIRY ROUTINE USED BY FX.NET.OPEN & FX.OPEN.POS
*******************************************************************************
*
* 25/11/08 - BG_100021002
*            Rating Reduction
*
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine
*******************************************************************************



    $USING FX.Config
    $USING EB.Utility
    $USING ST.CompanyCreation
    $USING EB.DataAccess
    $USING ST.Config
    $USING EB.SystemTables
    $USING EB.Reports

*
    NO.OF.DAYS = ""
    EB.DataAccess.Dbr("FX.PARAMETERS":@FM:FX.Config.Parameters.PSpotInternal:@FM:".A", "FX.PARAMETERS",NO.OF.DAYS)
    NO.OF.DAYS +=1
    RETURN.DATE = ""
    RETURN.CODE = ""
    RETURN.DIS = ""
*
    LOCAL.COUNTRY = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry)
    IF LOCAL.COUNTRY = "" THEN
        LOCAL.COUNTRY = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalRegion)[1,2]
    END
*
    tmp.R.DATES.EB.Utility.Dates.DatToday = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday)
    ST.Config.WorkingDay("",tmp.R.DATES.EB.Utility.Dates.DatToday,"",NO.OF.DAYS:"W","", LOCAL.COUNTRY,"",RETURN.DATE,RETURN.CODE,RETURN.DIS)
    EB.SystemTables.setRDates(EB.Utility.Dates.DatToday, tmp.R.DATES.EB.Utility.Dates.DatToday)
    EB.Reports.setOData(RETURN.DATE)
    RETURN
    END
