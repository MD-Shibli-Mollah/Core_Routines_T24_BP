* @ValidationCode : Mjo2MjEyMTYxNTA6Q3AxMjUyOjE1ODMzMDYyMjkxNzg6aW5kaHVtYXRoaXM6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMjAwMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 04 Mar 2020 12:47:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : indhumathis
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-101</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CG.ChargeConfig
SUBROUTINE CONV.FT.COMM.TYPE.HISTORY.R8(ID,REC,FILE)
*************************************************************************
*   Build FT.COMM.TYPE.HISTORY from FT.COMMISSION.TYPE$HIS for existing sites.
*   Note - The live record is also included in the index and includes all
*          index's for previous years.
*-----------------------------------------------------------------------------
* INCOMING - ID  : FT.COMMISION.TYPE ID
*            REC : FT.COMMISION.TYPE Record
*            FILE: FT.COMMISION.TYPE File
*-------------------------------------------------------------------------
* Modifications:
*
* 08/11/07 - EN_10003564 / BG_100016110
*            New routine.

******************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
*-----------------------------------------------------------------------------
*
    IF INDEX(FILE,'$',1) THEN
* Only process the live file.
        RETURN
    END
*
    GOSUB INITIALISE
*
* The history list starts with the live record.
    GOSUB PROCESS.LIVE.RECORD
*
* Process each $HIS item if they exist.
    IF LIVE.CURR.NO > 1 THEN
        GOSUB PROCESS.HIS.RECORDS
    END
* Flush any outstanding .HISTORY record.
    GOSUB WRITE.HISTORY.RECORD
*
* Write the Previous years to the current HISTORY record.
    WRITEV PREVIOUS.YEARS ON F.TARGET, LIVE.ID, TARGET.PREV.YEARS

RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> Initialise files and variables </desc>
*
* Equate field numbers to position manually, do no use $INSERT
    EQU FT.CTH.EFFECTIVE.DATE TO 1,
    FT.CTH.COMM.TYPE.CURR.NO TO 2,
    FT.CTH.PREVIOUS.YEARS TO 3,
    FT4.CURR.NO TO 41,
    FT4.DATE.TIME TO 43
*
* TARGET = .HISTORY concat file to write to.
* SOURCE = $HIS file.
*
    FN.SOURCE = FILE
    FN.SOURCE.HIS    = 'F.FT.COMMISSION.TYPE$HIS'
    FN.TARGET        = 'F.FT.COMM.TYPE.HISTORY'
* Fields in the .HISTORY file.
    TARGET.EFFECTIVE.DATE = FT.CTH.EFFECTIVE.DATE
    TARGET.CURR.NO        = FT.CTH.COMM.TYPE.CURR.NO
    TARGET.PREV.YEARS      = FT.CTH.PREVIOUS.YEARS
* Fields in the $HIS file
    SOURCE.CURR.NO        = FT4.CURR.NO
    SOURCE.DATE.TIME      = FT4.DATE.TIME
*
    F.TARGET = ''
    CALL OPF(FN.TARGET,F.TARGET)
*
    F.SOURCE.HIS = ''
    CALL OPF(FN.SOURCE.HIS,F.SOURCE.HIS)

    TARGET.ID = ''
    R.TARGET = ''
    SAVED.YEAR = '' ; * The loops previous year.
*
    PREVIOUS.YEARS = '' ;*Used to write back to the latest record.
    LIVE.ID = ''
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.LIVE.RECORD>
PROCESS.LIVE.RECORD:
*** <desc> Process the current record, creating the list with this record first. </desc>
* Ensure the live record is part of .HISTORY
*
    CURR.NO  = REC<SOURCE.CURR.NO>
    DATE.TIME = REC<SOURCE.DATE.TIME,1>
    GOSUB DATE.TIME.PROCESSING

* As this is the first time R.TARGET is used we can just assign to the first VM.
    R.TARGET<TARGET.EFFECTIVE.DATE> = HIS.DATE
    R.TARGET<TARGET.CURR.NO> = CURR.NO
*
    SAVED.YEAR = HIS.YEAR

    LIVE.CURR.NO = CURR.NO
* Save to write back the previous years for fast retrieval of available years.
    LIVE.ID = ID:'*':HIS.YEAR
* Save to ensure that current year not part of the year index.
    LIVE.YEAR = HIS.YEAR
* Save to ensure that we do not put older CURR.NOs past the Live record.
    LIVE.DATE = HIS.DATE
* Ensure that REC which was passed to this routine is coppied into R.SOURCE.HIS
* which is the last record read.
    R.SOURCE.HIS = REC
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.HIS.RECORDS>
PROCESS.HIS.RECORDS:
*** <desc> Process each $HIS record, adding to the years index.</desc>
    START.CURR.NO = LIVE.CURR.NO-1

    FOR CURR.NO = START.CURR.NO TO 1 STEP -1
        SOURCE.HIS.ID = ID:';':CURR.NO
*
        R.SOURCE.HIS = ''
        CALL F.READ(FN.SOURCE.HIS, SOURCE.HIS.ID, R.SOURCE.HIS, F.SOURCE.HIS, ETEXT)
*
        IF R.SOURCE.HIS THEN
* DATE.TIME - the date the record was authorised - YYMMDD
            DATE.TIME = R.SOURCE.HIS<SOURCE.DATE.TIME,1>
            GOSUB DATE.TIME.PROCESSING
* Historic records can't take precedence over the live record.
            IF HIS.DATE < LIVE.DATE THEN
                GOSUB SAVE.TO.HISTORY
            END
        END
    NEXT CURR.NO
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= SAVE.TO.HISTORY>
SAVE.TO.HISTORY:
*** <desc> Save to the .HISTORY year index </desc>
    IF SAVED.YEAR AND (HIS.YEAR NE SAVED.YEAR) THEN
        GOSUB WRITE.HISTORY.RECORD
    END
*
* List is in date descending order, so if the date is already in
* the list then we have the latest curr.no already.
    LOCATE HIS.DATE IN R.TARGET<TARGET.EFFECTIVE.DATE,1> SETTING POS ELSE
        INS HIS.DATE BEFORE R.TARGET<TARGET.EFFECTIVE.DATE,POS>
        INS CURR.NO BEFORE R.TARGET<TARGET.CURR.NO,POS>
    END
    SAVED.YEAR = HIS.YEAR
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= WRITE.HISTORY.RECORD>
WRITE.HISTORY.RECORD:
*** <desc> Write the year record to .HISTORY </desc>
*
    IF R.TARGET AND SAVED.YEAR THEN
        TARGET.ID = ID:'*':SAVED.YEAR
        WRITE R.TARGET ON F.TARGET,TARGET.ID
        R.TARGET = ''
* Don't include the current records year as we will
* already of read that record.
        IF SAVED.YEAR NE LIVE.YEAR THEN
            PREVIOUS.YEARS<1,-1> = SAVED.YEAR
        END
    END
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= DATE.TIME.PROCESSING>
DATE.TIME.PROCESSING:
*** <desc> Perform DATE.TIME processing </desc>
* Incomming : DATE.TIME (DATE.TIME field - Authorised date)
*
    INT.DATE = DATE.TIME
    INT.DATE = ICONV(INT.DATE[5,2]:'.':INT.DATE[3,2]:'.':INT.DATE[1,2],'DE')
*
* HIS.YEAR - the year the record was authorised - YYYY
* HIS.TIME - the time the record was authorised - HH:MM
* HIS.DATE - the T24 date the record was authorised - YYYYMMDD
    HIS.YEAR = OCONV(INT.DATE,'DY4')
    HIS.TIME = DATE.TIME[7,4]
    HIS.DATE = HIS.YEAR : DATE.TIME[3,4]

    IF HIS.DATE > TODAY THEN
* If the DATE.TIME is in the future, treat as the banks current date.
        HIS.DATE = TODAY
        HIS.YEAR = TODAY[1,4]
    END
RETURN
*** </region>

END
