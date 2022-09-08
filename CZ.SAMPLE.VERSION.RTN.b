* @ValidationCode : Mjo5ODYxMjAwMTc6Q3AxMjUyOjE1NDQxMDMxMzY2MjY6a2hhcmluaToxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2OjIzOjIx
* @ValidationInfo : Timestamp         : 06 Dec 2018 19:02:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kharini
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 21/23 (91.3%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE CZ.CustomerActivity
SUBROUTINE CZ.SAMPLE.VERSION.RTN
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 05/12/17 - Enhancement 2325720 / Task 2360155
*            Sample version routine
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING CZ.Framework
    $USING CZ.CustomerActivity
    $USING ST.CustomerActivity
        
    GOSUB Initialisation ; *Initialisation of variables
        
    IF Message EQ "AUT" THEN            ;* If message is AUT
        ProcessStage = "AUTH"           ;* Its request for authroization process
    END
    
    BEGIN CASE
        CASE ProcessStage EQ "AUTH" AND AuthNo EQ "2" AND RecordStatus EQ "NAU"     ;* 1st level authroization! Wait for 2d level authroization to approve child messages
        CASE Message EQ "HLD"                                                       ;* Message put on HOLD! No process required for child! What happen if NAU record moved to HOLD?! Only way is .NOH!
        CASE ProcessStage EQ "AUTH"                                                                      ;* All right go on!
    
            EnableProcess = ''
            CZ.CustomerActivity.CzEnableProcess(EnableProcess) ;*check if the functionality is enabled
            EnableProcess = ''
            IF EnableProcess NE 'NO' THEN
                ST.CustomerActivity.CzProcessCusActivityTrigger(idNew, Application, '') ;*if enabled , then Process the CUSTOMER.ACTIVITY.TRIGGER
            END
        
    END CASE
   
RETURN
*-----------------------------------------------------------------------------

*** <region name= Initialisation>
Initialisation:
*** <desc>Initialisation of variables </desc>

    Message = EB.SystemTables.getMessage()
    idNew = EB.SystemTables.getIdNew()
    Application = EB.SystemTables.getApplication()
    AuthNo          = EB.SystemTables.getAuthNo()                               ;* Get the number of auth
    RecordStatus    = EB.SystemTables.getRNew(EB.SystemTables.getV() - 8)[2,3]  ;* Get the record status
    ProcessStage    = "UNAUTH"          ;* Default request for unauth process
    
RETURN
*** </region>

END

