* @ValidationCode : MjoxMTgyOTAzMzMzOkNwMTI1MjoxNTQzODE2OTc3MjQzOnJhdmluYXNoOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTEuMjAxODEwMjItMTQwNjotMTotMQ==
* @ValidationInfo : Timestamp         : 03 Dec 2018 11:32:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ravinash
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* Modification History
*
* 24/10/18 - Enhancement 2822523 / Task 2826365
*          - Incorporation of  EB_SystemTables component
*
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*************************************************************************
***
*** E.GET.DEPT.LEVEL
***
*** Routine called from enquiry to parse the arguments from the enquiry
*** common area into a format which the routine GET.DEPT.LEVEL can
*** use. The return value from GET.DEPT.LEVEL is stored in O.DATA.
***
*** Expects O.DATA to be in the form DAO*LEVEL
***
*************************************************************************
$PACKAGE EB.SystemTables
SUBROUTINE E.GET.DEPT.LEVEL
*************************************************************************
	$USING EB.SystemTables
    $INSERT I_EQUATE
    $USING EB.Reports

*** Break the fields out from the concat form

    LEVEL = FIELD(O.DATA,'*',2)
    OFFICER = FIELD(O.DATA,'*',1)

*** And call the normal routine

    BOSS = ''

    CALL GET.DEPT.LEVEL(BOSS,OFFICER,LEVEL)

    O.DATA = BOSS

END
