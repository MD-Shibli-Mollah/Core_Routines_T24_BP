* @ValidationCode : MjozNjUxMzI2Njg6Q3AxMjUyOjE1OTg4MDg5MDQyMzI6a2JoYXJhdGhyYWo6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjE1OjE1
* @ValidationInfo : Timestamp         : 30 Aug 2020 23:05:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 15/15 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.VAL.DATE.TIME(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* It returns date and time in the format YYYY-MM-DDTHH:MM:SS
*-----------------------------------------------------------------------------
*******************************************************************
*
*
* Incoming parameters:
*
* APPL.ID   - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val- returns date and time in the format YYYY-MM-DDTHH:MM:SS
*
*******************************************************************
* Modification History :
*
* 31/01/2020 - Enhancement 3562849 / Task 3562851
*              CI #3 - Mapping Routines
*
* 02/03/2020 - Enhancement 3572828 / Task 3572830
*              EMIR-ND CI #3 - Mapping Routines
*
* 08/06/2020 - Enhancement 3715904 / Task 3786684
*              EMIR changes for DX
*
* 27/08/20 - Enhancement 3793940 / Task 3793943
*            CI#3 - Mapping routines - Part II
*-----------------------------------------------------------------------------

    $USING EB.SystemTables

    GOSUB INITIALISE ; *
    GOSUB PROCESS ; *

RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    TodayDate = ""
    Time = ""
    DateTimeFormat = ""
    RET.VAL = ""

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    IF (APPL.ID[1,2] EQ "FR") OR (APPL.ID[1,2] EQ "ND") OR (APPL.ID[1,2] EQ "SW") OR (APPL.ID[1,2] EQ "DX") OR (APPL.ID[1,2] EQ "FX") THEN
        
        TodayDate = OCONV(DATE(),'D-') ;*For eg: 01-24-2020
        Time = FIELD(TIMEDATE(), ' ',1) ;*For eg: 11:28:31
        DateTimeFormat = TodayDate[7,4]:"-":TodayDate[1,2]:"-":TodayDate[4,2]:"T":Time:"Z" ;*For eg: 2020-01-24T11:28:31Z
        RET.VAL = DateTimeFormat
    END
    
RETURN
*** </region>

END


