* @ValidationCode : MjotMTg3NzU3NjA4NzpDcDEyNTI6MTYwNDgzNzUwMjM1MzpyZGVlcGlnYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA5LjIwMjAwODI4LTE2MTc6MTY6MTY=
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/16 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.DATE.TIME(LINE.RET)
*-----------------------------------------------------------------------------
* This routine updates the Date & time when the report has been generated
* via DFE, such that already generated records will be ignored during the
* next extraction.
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*-----------------------------------------------------------------------------
    $USING EB.Utility
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.API

    GOSUB INITIALISE ; *Initialise the variables for process
    GOSUB PROCESS    ; *Process to update the Date & Time after the generation such that it will ignored during next extraction

RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables for process </desc>
    SCDX.ARM.MIFID.DATA.ID = EB.Utility.getCTxnId()      ;* SCDX.ARM.MIFID.DATA id
    R.SCDX.ARM.MIFID.DATA = EB.Utility.getCApplRec()     ;* SCDX.ARM.MIFID.DATA record

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to update the Date & Time after the generation such that it will ignored during next extraction </desc>

* Get the field position of DATE.TIME from the SS Of SCDX.ARM.MIFID.DATA
    SS.ID = 'SCDX.ARM.MIFID.DATA' ; SS.REC = ''
    EB.API.GetStandardSelectionDets(SS.ID,SS.REC)
    LOCATE 'DATE.TIME' IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN
        FIELD.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,POS>
    END

    IF FIELD.POS AND R.SCDX.ARM.MIFID.DATA<FIELD.POS> EQ '' THEN            ;* Dont update time stamp if already updated
        R.SCDX.ARM.MIFID.DATA<FIELD.POS> = TIMEDATE()                       ;* Update system date and time in the SCDX.ARM.MIFID.DATA record.
        EB.DataAccess.FWrite(EB.Utility.getCFnFileNameArray()<1>,SCDX.ARM.MIFID.DATA.ID,R.SCDX.ARM.MIFID.DATA)      ;*Write to SCDX.ARM.MIFID.DATA
    END
    
RETURN
*** </region>
END
