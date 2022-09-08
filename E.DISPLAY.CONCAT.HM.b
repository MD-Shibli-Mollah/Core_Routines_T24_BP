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

* Version 1 21/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Reports
    SUBROUTINE E.DISPLAY.CONCAT.HM
*
* Subroutine to convert concat record to multi.valued for
* display by enquiries & manipulate the data according to the
* Selection Criteria.
*-----------------------------------------------------------------------
* Modification History:
*----------------------
*
* 26/04/2007 - EN_10003329
*              Selection field name typo error (addressed in Idesc sar).

* 03/03/16 - 1650861
*            Incoporation of Components
*-----------------------------------------------------------------------
*
    $USING EB.Utility
    $USING EB.SystemTables
    $USING EB.Reports

*-----------------------------------------------------------------------
*
    ENQ.DATA = EB.Reports.getEnqSelection()
    COMP.YM = '' ; DISP.REC = '' ; FULL.REC = ''
*
    POS = '' ; COMP.ID = ''
    LOCATE "@ID" IN ENQ.DATA<2,1> SETTING POS THEN
    COMP.ID = ENQ.DATA<4,POS>
    END
*
    POS = '' ; YMONTH = ''
    LOCATE "YEAR" IN ENQ.DATA<2,1> SETTING POS THEN         ; * EN_10003329 - S/E
    YMONTH = ENQ.DATA<4,POS>
    END ELSE
    YMONTH = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday)[1,4]
    END
*
    R.RECORD = EB.Reports.getRRecord()
    CONVERT @FM TO @VM IN R.RECORD     ; * Concat to multivalue
    EB.Reports.setRRecord(R.RECORD)
    tmp.R.RECORD = EB.Reports.getRRecord()
    EB.Reports.setVmCount(DCOUNT(tmp.R.RECORD,@VM)); * Number of multi values
    EB.Reports.setRRecord(tmp.R.RECORD)
    FULL.REC = EB.Reports.getRRecord()
*
    FOR I = 1 TO EB.Reports.getVmCount()
        COMP.YM = FULL.REC<1,I>
        IF COMP.ID THEN
            IF FIELD(COMP.YM,'.',1) EQ COMP.ID AND FIELD(COMP.YM,'.',2)[1,4] EQ YMONTH THEN
                DISP.REC<-1> = COMP.YM
            END
        END ELSE
            IF FIELD(COMP.YM,'.',2)[1,4] EQ YMONTH THEN
                DISP.REC<-1> = COMP.YM
            END
        END
    NEXT I
*
    CONVERT @FM TO @VM IN DISP.REC
    EB.Reports.setRRecord('')
    EB.Reports.setRRecord(DISP.REC)
*
    RETURN
    END
