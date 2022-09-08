* @ValidationCode : MjotMTYzODI5NTU3MTpDcDEyNTI6MTU4NTA1MDkxMTk3MjpoZW1hbmFyYXlhbnI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMjAwNC4yMDIwMDMxMy0wNjUxOi0xOi0x
* @ValidationInfo : Timestamp         : 24 Mar 2020 17:25:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : hemanarayanr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202004.20200313-0651
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 1 15/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>517</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.Service
SUBROUTINE EB.PHANTOM.TEMPLATE
*-----------------------------------------------------------------------------
* Phantom description
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Modification History:
* --------------------
*
* 24/03/2020 - Enhancement : 2822523 / Task : 3656227
*              Incorporation of EB.Service component
*----------------------------------------------------------------------------

    $INSERT I_EQUATE
    $INSERT I_COMMON

*-----------------------------------------------------------------------------
*
    GOSUB INITIALISE

    LOOP

        GOSUB CHECK.SHUTDOWN
    UNTIL SHUTDOWN
        GOSUB YOUR.PHANTOM.PROCESS
        GOSUB UPDATE.RUN.STATUS
        SLEEP SLEEP.TIME

    REPEAT
*
RETURN

*-----------------------------------------------------------------------------
CHECK.SHUTDOWN:
* -------------
* Check to see if the EB.PHANTOM record has been set to 'stop' - used
* when the program is running in background mode.
*
    READU R.EB.PHANTOM FROM F.EB.PHANTOM, EB.PHANTOM.ID ELSE
        TEXT = "Cannot read EB.PHANTOM record &":@FM:EB.PHANTOM.ID
        GOTO FATAL.ERROR
    END
*
    IF R.EB.PHANTOM<EB.Service.Phantom.GtsPhantStopReq>[1,1]= "S" THEN
        SHUTDOWN = 1                    ; * Signal stop
        R.EB.PHANTOM<EB.Service.Phantom.TdRunStatus> = 'MANUAL SHUTDOWN'
        R.EB.PHANTOM<EB.Service.Phantom.TdStatus> = 'CLOSED'
        WRITE R.EB.PHANTOM TO F.EB.PHANTOM, EB.PHANTOM.ID
    END ELSE
*
        RELEASE F.EB.PHANTOM, EB.PHANTOM.ID
*
        ETEXT = ''
*
** If an error is returned in ETEXT, for example the ATM account
** cannot be opened, shutdown and record the reason why
*
        IF ETEXT THEN
            SHUTDOWN = 1
            YTXT = ETEXT
            GOSUB UPDATE.EB.PHANTOM.ERROR
        END
    END
*
RETURN
*
*----------------------------------------------------------------------------
UPDATE.EB.PHANTOM.ERROR:
*=======================
** Make sure EB.PHANTOM is tidied up when there are errors
*
    CALL TXT(YTXT)                     ; * Translate error
    IF NOT(R.EB.PHANTOM) THEN MATBUILD R.EB.PHANTOM FROM R.NEW
    R.EB.PHANTOM<EB.Service.Phantom.TdRunStatus> = "SHUTDOWN ERROR - ":YTXT
    R.EB.PHANTOM<EB.Service.Phantom.TdStatus> = 'CLOSED'
    WRITE R.EB.PHANTOM TO F.EB.PHANTOM,EB.PHANTOM.ID
*
RETURN
*
*-----------------------------------------------------------------------------
YOUR.PHANTOM.PROCESS:
*----------------------
** This section will invoke or perform the standard phantom processing
*
    RUN.STATUS = "LAST ACTIVITY AT ":TIMEDATE()
*
REM Type Phantom Process Code here.
    CRT "EXECUTING YOUR CODE"
*
RETURN
*
*-----------------------------------------------------------------------------
UPDATE.RUN.STATUS:
*=================
** Update the RUN Status field to show that there is some activity taking place
** this is monitored by the enquiry EP.MONITOR
*
    READU PHANT.REC FROM F.EB.PHANTOM, EB.PHANTOM.ID ELSE
        TEXT = "Cannot read EB.PHANTOM record &":@FM:EB.PHANTOM.ID
        GOTO FATAL.ERROR
    END
    PHANT.REC<EB.Service.Phantom.TdRunStatus> = RUN.STATUS       ; * Put the latest back
    WRITE PHANT.REC TO F.EB.PHANTOM, EB.PHANTOM.ID
*
RETURN
*
*-------------------------------------------------------------------------------
INITIALISE:
*=========
* Open files
* Read EB.PHANTOM  (with a view to checking the RUN status)

    FN.EB.PHANTOM = "F.EB.PHANTOM"
    F.EB.PHANTOM = ""
    CALL OPF(FN.EB.PHANTOM,F.EB.PHANTOM)
*
** Write out the EB.PHANTOM.RECORD to show it is active
*
    EB.PHANTOM.ID = ID.NEW
    MATREADU R.NEW FROM F.EB.PHANTOM, EB.PHANTOM.ID ELSE
        TEXT = "Cannot read EB.PHANTOM record &":@FM:EB.PHANTOM.ID
        GOTO FATAL.ERROR
    END
*
** Write back to EB.PHANTOM to show the correct status
*
    RUN.MODE = R.NEW(EB.Service.Phantom.GtsRunMode)
    R.NEW(EB.Service.Phantom.TdRunStatus) = "Started at ":TIMEDATE()
    R.NEW(EB.Service.Phantom.TdStatus) = "ACTIVE"
    MATWRITE R.NEW TO F.EB.PHANTOM, EB.PHANTOM.ID
*
* Set variables
*
    SHUTDOWN = ''
    RUN.STATUS = ''                    ; * Used to record the latest status and update EB.PHANTOM

* Set up a flag to establish the EB.PHANTOM status, i.e. to see if 'ACTIVE'
    IF R.NEW(EB.Service.Phantom.GtsRunMode) = 'INTERACTIVE' THEN INTERACTIVE = 1 ELSE INTERACTIVE = 0
*
* Set up a flag for the last time that a message was processed (initially
* set to zero).
    LAST.TIME.PROCESSED = 0

* Set up a 'SLEEP.TIME,' to pause the phantom processing, rather than it running
* continuously, without pausing processing.
    SLEEP.TIME = R.NEW(EB.Service.Phantom.TdSleepSecs)

RETURN
*-----------------------------------------------------------------------------
FATAL.ERROR:
*==========
*
    CALL FATAL.ERROR("EB.PHANTOM.TEMPLATE")
RETURN
*
END
