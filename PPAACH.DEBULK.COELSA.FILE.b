* @ValidationCode : MjotMTk1NzYxOTM3NTpDcDEyNTI6MTU1ODY5ODMxMTExODpnbWFtYXRoYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA0LjIwMTkwMzIzLTAzNTg6NDE6MjI=
* @ValidationInfo : Timestamp         : 24 May 2019 17:15:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : gmamatha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 22/41 (53.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190323-0358
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPAACH.ClearingFramework
SUBROUTINE PPAACH.DEBULK.COELSA.FILE(iFileContent, iFileName, iQueueName, oFileInfo, oTransactions, oResponse)
*-----------------------------------------------------------------------------
*
* This is a new routine for debulking generic xml COELSA msgs in NON-ESB.
* INWARD.MAPPING service invokes this routine
*-----------------------------------------------------------------------------
* Modification History :
* 15/05/2019 - Enhancement 3131179 / Task 3131182
*              New debulkapi for COELSA non xml messages.
*
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    
    GOSUB initialise
    GOSUB process

RETURN
*-----------------------------------------------------------------------------
process:
*   init java api parameters
    calljArgs = ''
    calljArgs = iFileContent:":@FM:":iFileName:":@FM:":iQueueName
    oResponse = ''
    CALL TPSLogging("Input","PPAACH.DEBULK.COELSA.FILE","calljArgs: <":calljArgs:">","")
    
    EB.SystemTables.CallJavaApi(EB.API.ID,calljArgs,oTransactions,calljResp)
    IF calljResp NE '' THEN
        BEGIN CASE
            CASE calljResp = 1
                oResponse = 'JAVA CALL ERROR: Fatal Error creating Thread -':EB.API.ID
            CASE calljResp = 2
                oResponse = 'JAVA CALL ERROR: Cannot find the JVM.dll - ':EB.API.ID
            CASE calljResp = 3
                oResponse = 'JAVA CALL ERROR: Class ' : EB.API.ID : ' does not exist'
            CASE calljResp = 4
                oResponse = 'JAVA CALL ERROR: UNICODE conversion error - ':EB.API.ID
            CASE calljResp = 5
                oResponse = 'JAVA CALL ERROR: Method ' : EB.API.ID : ' does not exist'
            CASE calljResp = 6
                oResponse = 'JAVA CALL ERROR: Cannot find object Constructor - ':EB.API.ID
            CASE calljResp = 7
                oResponse = 'JAVA CALL ERROR: Cannot instantiate object - ':EB.API.ID
            CASE @TRUE
                oResponse = 'JAVA CALL ERROR: Unknown error ' : calljResp :' - ':EB.API.ID
        END CASE
    END ELSE
        IF oTransactions [1,3] EQ '1@@' THEN
            oTransactions = oTransactions[4,LEN(oTransactions)-3]
        END
        CHANGE "," TO @VM IN oTransactions
        oFileInfo = ''
    END
    CALL TPSLogging("Output","PPAACH.DEBULK.COELSA.FILE","oTransactions: <":oTransactions:">","")
    CALL TPSLogging("Output","PPAACH.DEBULK.COELSA.FILE","oFileInfo: <":oFileInfo:">","")

RETURN
*-----------------------------------------------------------------------------
initialise:
*   Intialise local variables here.
    oTransactions = ''
    calljResp = ''
    EB.API.ID = "PP.DEBULK.XML"
   
RETURN
*-----------------------------------------------------------------------------

END
