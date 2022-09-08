* @ValidationCode : MjoxOTIxMjA1OTU4OkNwMTI1MjoxNDk4NTYyMTQ1NDQ5OnNhdGhpc2hrdW1hcmo6MzowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDcuMjAxNzA2MjMtMDAzNTozODozNg==
* @ValidationInfo : Timestamp         : 27 Jun 2017 16:45:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sathishkumarj
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/38 (94.7%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201707.20170623-0035
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*----------------------------------------------------------------------------
	$PACKAGE EB.Channels
	SUBROUTINE E.NOFILE.TC.RECORD.COUNT(RETURN.DATA)
*----------------------------------------------------------------------------
* Description
*----------------------------------------------------------------------------
* Nofile routine to provide count of unauthorised/authorised records
* IN Parameter  : Application and Status
* OUT Parameter : Count of records
*----------------------------------------------------------------------------
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            Authorised and Unauthorised record count.
*
* 06/04/17 - Defect 2080033 / Task 2080452
*            Unauth - Arrangements & External User counts are not displaying in home screen
*----------------------------------------------------------------------------
	$USING EB.Reports
	$USING EB.DataAccess
	$INSERT I_DAS.AA.ARRANGEMENT.ACTIVITY
	$INSERT I_DAS.AA.ARRANGEMENT
*
	GOSUB INITIALISE
	GOSUB PROCESS
	RETURN.DATA=RECORD.COUNT
*
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
*Initialise required variables
	RECORD.STATUS='' ;* Initialsie Record Status
	APPLICATION.NAME ='' ;* Initialsie Application Name
	RECORD.COUNT='' ;* Initialise record count
	* Get application name and record status
	LOCATE 'APPLICATION.NAME' IN EB.Reports.getDFields()<1> SETTING APP.POS THEN
	    APPLICATION.NAME=EB.Reports.getDRangeAndValue()<APP.POS>
	END
	LOCATE 'RECORD.STATUS' IN EB.Reports.getDFields()<1> SETTING STATUS.POS THEN
	    RECORD.STATUS=EB.Reports.getDRangeAndValue()<STATUS.POS>
	END
*
RETURN
*----------------------------------------------------------------------------------
PROCESS:
* To get count of Unauthorised / Authorised records
BEGIN CASE
    CASE APPLICATION.NAME EQ 'AA.ARRANGEMENT' ;* Get count for arrangement
        IF RECORD.STATUS EQ 'AUTH' THEN
            THE.LIST=DasAaArrangement$OverdueReport
            THE.ARGS="ARR.STATUS":@VM:"PRODUCT.LINE":@FM:"AUTH":@VM:"ONLINE.SERVICES"
            EB.DataAccess.Das(APPLICATION.NAME,THE.LIST,THE.ARGS,"")
        END ELSE
            THE.LIST=DAS$COUNT.AUTH.UNAUTH.ARRANGEMENTS
            THE.ARGS='TC'
            EB.DataAccess.Das("AA.ARRANGEMENT.ACTIVITY",THE.LIST,THE.ARGS,"$NAU")

        END
    CASE APPLICATION.NAME NE 'AA.ARRANGEMENT' ;* Get count for other applications
        IF RECORD.STATUS EQ 'AUTH' THEN
            THE.LIST=EB.DataAccess.DasAllIds
            EB.DataAccess.Das(APPLICATION.NAME,THE.LIST,"","")
        END ELSE
            THE.LIST=EB.DataAccess.DasAllIds
            EB.DataAccess.Das(APPLICATION.NAME,THE.LIST,"","$NAU")
        END
END CASE
    RECORD.COUNT=DCOUNT(THE.LIST,@FM)
*
RETURN
*----------------------------------------------------------------------------------
END
