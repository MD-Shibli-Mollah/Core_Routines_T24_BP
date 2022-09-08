* @ValidationCode : MjotNjMxOTU4Mjg5OkNwMTI1MjoxNDkxNTcxMzA0NTEyOmFtYXJpbjoxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwMi4yMDE3MDEyOC0wMTM5Ojk6OQ==
* @ValidationInfo : Timestamp         : 07 Apr 2017 16:21:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : amarin
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 9/9 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.20170128-0139
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE ST.Config
*
* Implementation of ST.Config.Call_DasDeptAcctOfficerID
*
* OfficerID(IN) : 
* Result(OUT) : 
*
SUBROUTINE CALL.DAS.DEPT.ACCT.OFFICER.ID(OfficerID, Result)

*-----------------------------------------------------------------------------
* Program Description
* --- Routine for calling private DAS.DEPT.ACCT.OFFICER
*-----------------------------------------------------------------------------
* Modification History :
*
* 07.04.2017 - Task 2081301
*
*-----------------------------------------------------------------------------

    $INSERT I_DAS.DEPT.ACCT.OFFICER
    $INSERT I_DAS.DEPT.ACCT.OFFICER.NOTES
    
    $USING EB.DataAccess
    $USING ST.Config
    
    application = "DEPT.ACCT.OFFICER"
    acctOfficerRecord = DAS.DEPT.ACCT.OFFICER$OFFICER.ID
    tableSuffix = ''
    theArgs = OfficerID  
    
    EB.DataAccess.Das(application, acctOfficerRecord, theArgs, tableSuffix)

    Result = acctOfficerRecord
    
RETURN
