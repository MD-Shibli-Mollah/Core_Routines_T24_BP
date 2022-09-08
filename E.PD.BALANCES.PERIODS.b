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
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PD.ModelBank
    SUBROUTINE E.PD.BALANCES.PERIODS
**************************************************************************
*
* This routine is used by the PD balance enquiry to determine the periods
* defined by the user and passes them back through O.DATA. This will
* later be compared to determine whether or not a break period should
* be executed.
*
* Incoming : O.DATA (contains periods e.g. 30 60 90 etc.)
* Outgoing : O.DATA (contains periods e.g. 30]60]90 etc. where ] = VM )
*
* 30/09/97 - GB9701100
*
**************************************************************************

    $USING EB.Reports
    $USING EB.SystemTables

*  strip out unnecessary stuff and return periods multi-valued

    tmp.ID = EB.Reports.getId()
    tmp.TODAY = EB.SystemTables.getToday()
    OVERDUE.DAYS = ICONV(tmp.TODAY,'D2') - ICONV(FIELD(tmp.ID,'-',2),'D2')
    EB.SystemTables.setToday(tmp.TODAY)
    EB.Reports.setId(tmp.ID)
    tmp.O.DATA = EB.Reports.getOData()
    PERIODS = FIELD(tmp.O.DATA,'*',1)
    EB.Reports.setOData(tmp.O.DATA)
    tmp.O.DATA = EB.Reports.getOData()
    THIS.PERIOD = FIELD(tmp.O.DATA,'*',2)
    EB.Reports.setOData(tmp.O.DATA)
    tmp.O.DATA = EB.Reports.getOData()
    NEXT.PERIOD = FIELD(tmp.O.DATA,'*',3)
    EB.Reports.setOData(tmp.O.DATA)

    IF NEXT.PERIOD = 9999 THEN
        RETURN
    END   ;* BG_100018584 S/E
    IF THIS.PERIOD = '' THEN
        IF FIELD(PERIODS,' ',1) NE '0' THEN
            PERIODS = '0 ':PERIODS
        END
        THIS.PERIOD = FIELD(PERIODS,' ',1)
        NEXT.PERIOD = FIELD(PERIODS,' ',2)
    END

    IF OVERDUE.DAYS GT NEXT.PERIOD THEN
        POSITION = INDEX(' ':PERIODS:' ',' ':NEXT.PERIOD:' ',1) + (THIS.PERIOD = 0)
        POSITION = ((POSITION - 1) / 3) + 1
        NO.OF.PERIODS = DCOUNT(PERIODS,' ')

        FOR V$LOOP = POSITION TO NO.OF.PERIODS
            THIS.PERIOD = FIELD(PERIODS,' ',V$LOOP)
            NEXT.PERIOD = FIELD(PERIODS,' ',V$LOOP + 1)

            GOSUB CHK.NXT.PERIOD        ;* BG_100018584 S/E

        NEXT V$LOOP
    END

    IF THIS.PERIOD = 0 THEN
        THIS.PERIOD = 'ZERO'
    END   ;* BG_100018584 S/E
    EB.Reports.setOData(PERIODS:'*':THIS.PERIOD:'*':NEXT.PERIOD)

    RETURN
*--------------------------------------------------------------------------------------
CHK.NXT.PERIOD:
*-------------
    IF NEXT.PERIOD = '' THEN
        NEXT.PERIOD = 9999
        V$LOOP = NO.OF.PERIODS
    END ELSE
        IF OVERDUE.DAYS GT THIS.PERIOD AND OVERDUE.DAYS LE NEXT.PERIOD THEN
            V$LOOP = NO.OF.PERIODS
        END
    END
    RETURN


    END
