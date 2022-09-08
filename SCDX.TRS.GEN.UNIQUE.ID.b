* @ValidationCode : Mjo0NTk2ODI3Mzk6Q3AxMjUyOjE2MDQ2NjIzNTE0MjU6cmRlZXBpZ2E6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOS4yMDIwMDgyOC0xNjE3Ojk6OQ==
* @ValidationInfo : Timestamp         : 06 Nov 2020 17:02:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 9/9 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.GEN.UNIQUE.ID(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine will generate Unique id for the SCDX.ARM.MIFID.DATA database
* file.
* Attached as the routine in TX.TXN.BASE.MAPPING for Database SCDX.ARM.MIFID.DATA
* Incoming parameters:
**********************
* TXN.ID   -   Transaction ID of the contract.
* TXN.REC  -   A dynamic array holding the contract.
* TXN.DATA -   Data passed based on setup done in TX.TXN.BASE.MAPPING
*
* Outgoing parameters:
**********************
* RET.VAL  -   Unique id for the SCDX.ARM.MIFID.DATA
*              Unique id will be in below format:
*              Transaction reference appended with Data and Time
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables for process
    GOSUB PROCESS       ; *Process to generate the unique ID for SCDX.ARM.MIFID.DATA

RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables for process </desc>
    
    RET.VAL = ''

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc>Process to generate the unique ID for SCDX.ARM.MIFID.DATA </desc>

    SYS.DATE    = OCONV(DATE(),"D-")   ;*convert date to user readable format

    TIME.STAMP  = TIMEDATE()           ;*get 24 hour time format

    RET.VAL     = TXN.ID:SYS.DATE[9,2]:SYS.DATE[1,2]:SYS.DATE[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]:TIME.STAMP[7,2];*append date and time with transaction reference

RETURN
*** </region>

END
