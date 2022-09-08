* @ValidationCode : MjoxOTUxNzk1OTMyOkNwMTI1MjoxNTI0NzM1NDUzMDU3OmJvdml5YTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDMuMjAxODAyMjAtMDE1MTotMTotMQ==
* @ValidationInfo : Timestamp         : 26 Apr 2018 15:07:33
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : boviya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201803.20180220-0151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 4 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PM.Reports
SUBROUTINE E.VAL.CALENDAR

* This subroutine validates whether the calendar inputted is a valid record
* in PM.CALENDAR.
*
*
* 19/03/18 - Enhancement 2501455 / Task 2501458
*            Development #1 - Selection modifications
*
*---------------------------------------------------------------------
  
    $USING PM.Config
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.Template
    
    
    GOSUB INITIALISE ; *Initialise the variables.
    GOSUB PROCESS ; *Validate the calendar

RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables. </desc>

    EB.SystemTables.setE('')
    EB.SystemTables.setEtext('')


RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Validate the calendar </desc>

    EB.SystemTables.setComi(EB.Reports.getOData())                             ;*first do IN2 validaion
    N1 = '5.1'
    T1 = 'A'
    EB.Template.In2a(N1, T1)

    tmp.ETEXT = EB.SystemTables.getEtext()
    IF NOT(tmp.ETEXT) THEN
        CAL.ID = EB.Reports.getOData()
        ER = ""
        CAL.REC = PM.Config.Calendar.Read(CAL.ID, ER)                                               ;*read PM.CALENDAR
        IF ER THEN                                                                                  ;*if not present in PM.CALENDAR
            EB.SystemTables.setEtext('PM.RTN.INVALID.CALENDAR':@FM:CAL.ID)
        END

        EB.SystemTables.setE(EB.SystemTables.getEtext())
        
    END
    
RETURN
*** </region>

END


