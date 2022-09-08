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

*-----------------------------------------------------------------------------
* <Rating>-81</Rating>
*-----------------------------------------------------------------------------
* Version 5 18/05/01  GLOBUS Release No. G12.0.00 29/06/01
*
    $PACKAGE DX.ModelBank
    SUBROUTINE E.DX.MONITOR.STP.PROCESS(RESULTS.LIST)
*
*------------------------------------------------------------------------
*
* Enquiry to do stuff
*
*------------------------------------------------------------------------
*
* 20/03/07 - EN_10003276
*            Creation
*
* 04/06/15 - EN-1322379 / Tak-1328842
*            Incorporation of DX_ModelBank
*
*------------------------------------------------------------------------
*
    $USING DX.Foundation
    $USING DX.Configuration
    $USING EB.DataAccess
    $USING ST.CompanyCreation
    $USING EB.API
    $USING EB.SystemTables
    $INSERT I_DAS.DX.ITEM.STATUS
*
*------------------------------------------------------------------------
*
*** <region name= MAIN.LOOP>
***
*** <desc>Main program loop</desc>

    GOSUB INITIALISATION
    GOSUB SELECT.RECORDS.FOR.PROCESSING
    GOSUB PROCESS.DATA

    RETURN ; * To calling program

*** </region>
*
*------------------------------------------------------------------------
*
*** <region name= INITIALISATION>
INITIALISATION:
*** <desc>Set up variables etc</desc>

    RESULTS.LIST = ""
    EB.SystemTables.setCacheOff(1); * Prevent the cache being used


    FN.OFS.RESPONSE.QUEUE = 'F.OFS.RESPONSE.QUEUE'
    F.OFS.RESPONSE.QUEUE = ''
    R.OFS.RESPONSE.QUEUE = ''
    EB.DataAccess.Opf(FN.OFS.RESPONSE.QUEUE, F.OFS.RESPONSE.QUEUE)


    FN.DX.PARAMETER = 'F.DX.PARAMETER'
    F.DX.PARAMETER  = ''
    DX.PAR.ERR = ''
    ST.CompanyCreation.EbReadParameter(FN.DX.PARAMETER,'N','',R.DX.PARAMETER,'SYSTEM',F.DX.PARAMETER,DX.PAR.ERR)

    STP.TIMEOUT = R.DX.PARAMETER<DX.Configuration.Parameter.ParStpTimeout>

    RETURN

*** </region>
*
*------------------------------------------------------------------------
*
*** <region name= SELECT.RECORDS.FOR.PROCESSING>
SELECT.RECORDS.FOR.PROCESSING:
*** <desc>Select records with status STO or STP</desc>
*
* Select records with status STO or STP using a DAS query
*

    TABLE.NAME = "DX.ITEM.STATUS"
    ID.LIST.LOCAL = dasDxItemStatusGetStpItemsByDateTime
    THE.ARGS = ""
    TABLE.SUFFIX = ""
    EB.DataAccess.Das(TABLE.NAME, ID.LIST.LOCAL, THE.ARGS, TABLE.SUFFIX)

    RETURN

*** </region>
*
*------------------------------------------------------------------------
*
*** <region name= PROCESS.DATA>
PROCESS.DATA:
*** <desc>Process the DX.ITEM.STATUS records</desc>
*
* Process the DX.ITEM.STATUS records
*

    LOOP WHILE READNEXT ID FROM ID.LIST.LOCAL DO
        * Read the DX.ITEM.STATUS record to obtain Status

        DX.ITEM.STATUS.LOCAL = ID
        DX.Foundation.GetItemStatus(DX.ITEM.STATUS.LOCAL)

        DX.CURRENT.STATUS   = DX.ITEM.STATUS.LOCAL<DX.Foundation.ItemStatus.IsCurrStatus>
        DX.OFS.MESSAGE.ID   = DX.ITEM.STATUS.LOCAL<DX.Foundation.ItemStatus.IsCurrOfsMessageId>
        DX.STATUS.CURR.DATE = DX.ITEM.STATUS.LOCAL<DX.Foundation.ItemStatus.IsCurrDate>
        DX.STATUS.CURR.TIME = DX.ITEM.STATUS.LOCAL<DX.Foundation.ItemStatus.IsCurrTime>
        DX.STATUS.TIMEOUT   = ""

        IF STP.TIMEOUT THEN
            * Determine time since STP message created
            DX.STATUS.ELAPSED.DAYS     = "C"
            TODAY.LOCAL = EB.SystemTables.getToday()
            EB.API.Cdd("", DX.STATUS.CURR.DATE, TODAY.LOCAL, DX.STATUS.ELAPSED.DAYS)
            DX.STATUS.ELAPSED.TIME     = TIME() - ICONV(DX.STATUS.CURR.TIME, "MT")
            DX.STATUS.ELAPSED.SECONDS  = (DX.STATUS.ELAPSED.DAYS * 86400) + DX.STATUS.ELAPSED.TIME
            DX.STATUS.TIMEOUT = OCONV(DX.STATUS.ELAPSED.SECONDS, "MTS")
            IF DX.STATUS.ELAPSED.SECONDS < STP.TIMEOUT THEN
                * Prevent timeout reporting
                STP.TIMEOUT = ""
            END
        END

        GOSUB INTERPRET.RESULTS

    REPEAT

    RETURN

*** </region>
*
*------------------------------------------------------------------------
*
*** <region name= INTERPRET.RESULTS>
INTERPRET.RESULTS:
*** <desc>Build output record</desc>

    BEGIN CASE

        CASE DX.CURRENT.STATUS = "STO"

            OFS.MESSAGE.ID = DX.OFS.MESSAGE.ID: ".1"
            GOSUB CHECK.RECORD.STATUS
            IF OFS.ERROR.MESSAGE THEN
                RESULTS.LIST<-1> = ID: "*" : OFS.ERROR.MESSAGE : "*" : DX.STATUS.CURR.DATE : "*" : DX.STATUS.CURR.TIME : "*" : DX.STATUS.TIMEOUT: "*" : DX.STP.TIMEOUT
            END

        CASE DX.CURRENT.STATUS = "STC"

            OFS.MESSAGE.ID = DX.OFS.MESSAGE.ID: ".2"
            GOSUB CHECK.RECORD.STATUS

            IF OFS.ERROR.MESSAGE THEN
                RESULTS.LIST<-1> = ID: "*" : OFS.ERROR.MESSAGE : "*" : DX.STATUS.CURR.DATE : "*" : DX.STATUS.CURR.TIME : "*" : DX.STATUS.TIMEOUT: "*" : DX.STP.TIMEOUT
            END

            FIRST.OFS.ERROR.MESSAGE = OFS.ERROR.MESSAGE
            FIRST.IS.MISSING = IS.MISSING

            OFS.MESSAGE.ID = DX.OFS.MESSAGE.ID: ".1"
            GOSUB CHECK.RECORD.STATUS

            IF OFS.ERROR.MESSAGE THEN
                RESULTS.LIST<-1> = ID: "*" : OFS.ERROR.MESSAGE : "*" : DX.STATUS.CURR.DATE : "*" : DX.STATUS.CURR.TIME : "*" : DX.STATUS.TIMEOUT: "*" : DX.STP.TIMEOUT
            END

        CASE 1
            * Record ststus has changed - Ignore this
    END CASE

    RETURN

*** </region>
*
*------------------------------------------------------------------------
*
*** <region name= CHECK.RECORD.STATUS>
CHECK.RECORD.STATUS:
*** <desc>Check the record</desc>

* With the DX.ITEM.STATUS record get the time stamp and the ID of the OFS message

    OFS.ERROR.MESSAGE = ""
    DX.STP.TIMEOUT = "NO"

    EB.DataAccess.FRead(FN.OFS.RESPONSE.QUEUE, OFS.MESSAGE.ID, R.OFS.RESPONSE.QUEUE, F.OFS.RESPONSE.QUEUE, IS.MISSING)

    IF IS.MISSING THEN
        * No OFS.RESPONSE.QUEUE record, OFS has not processed this
        IF STP.TIMEOUT THEN
            * Report a timeout condition
            OFS.ERROR.MESSAGE = "STP Timeout has been exceeded"
            DX.STP.TIMEOUT = "YES"
        END ELSE
            * STP Timeout has not been set so don't report overdue items
        END
    END ELSE
        * OFS.RESPONSE.QUEUE record exists
        IF R.OFS.RESPONSE.QUEUE<1> = -1 THEN
            * FAIL message - report it
            OFS.ERROR.MESSAGE = R.OFS.RESPONSE.QUEUE<2>
        END ELSE
            * PASS message - do nothing
        END
    END

    RETURN

*** </region>
*
*-----------------------------------------------------------------------------

    END
