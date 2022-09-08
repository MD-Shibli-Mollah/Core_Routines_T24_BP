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

* Version 3 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoReports
    SUBROUTINE E.VAL.SEC.TRANSFER.ID
*************************************************************************
*
*		Sub-routine to Validate SECURITY.TRANSFER ID
*
*************************************************************************
* 23/09/02 - EN_10001200
*            Conversion of error messages to error codes.
*
* 30/07/06 - GLOBUS_BG_100011675
*            alpha numeric security.transfer id
* 24-07-2015 - 1415959
*             Incorporation of components
*************************************************************************

    $USING EB.Utility
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING EB.Reports

*************************************************************************

    IF LEN(EB.Reports.getOData()) NE 16 THEN  ; * BG_100011675 s
        GOSUB REFORMAT.ID
    END   ; * BG_100011675 e

    IF NOT(EB.Reports.getOData() MATCH "'SECTSC'5N5X") THEN  ; * BG_100011675

        EB.SystemTables.setE('SC.RTN.INVALID.REFERENCE.NO')
        EB.ErrorProcessing.Err() ; V$ERROR = 1
    END ELSE
        IF EB.Reports.getOData()[12,5] = 0 THEN
            EB.SystemTables.setE('SC.RTN.INVALID.REFERENCE.NO')
            EB.ErrorProcessing.Err() ; V$ERROR = 1
        END
    END

    RETURN

*-----------------------------------------------------------------------------
REFORMAT.ID:
* get id into correct format
* BG_100011675 new subroutine

    JUL.PROCESSDATE = EB.SystemTables.getRDates(EB.Utility.Dates.DatJulianDate)[3,5]

    IF LEN(EB.Reports.getOData()) <= 5 THEN

        EB.Reports.setOData("SECTSC":JUL.PROCESSDATE:FMT(EB.Reports.getOData(),"5'0'R"))

    END ELSE

        IF LEN(EB.Reports.getOData()) = 10 THEN

            EB.Reports.setOData("SECTSC":EB.Reports.getOData())
        END
        IF EB.Reports.getOData()[1,2] = "SC" THEN
            EB.Reports.setOData("SECT":EB.Reports.getOData())
        END
    END

    RETURN
