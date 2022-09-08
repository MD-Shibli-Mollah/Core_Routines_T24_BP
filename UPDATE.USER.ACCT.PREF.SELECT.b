* @ValidationCode : Mjo0NDY3NTYyNDQ6Q3AxMjUyOjE1MjMzNzAyNjA3MTk6c2FudG9zaHByYXNhZDotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxODA0LjIwMTgwNDA3LTAxMDU6LTE6LTE=
* @ValidationInfo : Timestamp         : 10 Apr 2018 19:54:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : santoshprasad
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201804.20180407-0105
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-41</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.ARC
SUBROUTINE UPDATE.USER.ACCT.PREF.SELECT
*-----------------------------------------------------------------------------
* This is the select routine of the service UPDATE.USER.ACCT.PREF
*-----------------------------------------------------------------------------
* Modifications:
* 18/05/15 - Enhancement - 1226758 / Task: 1347374
*            Create and update account groups based on channel permission
*
* 13/07/15 - Enhancement - 1326996 / Task 1399931
*            Incorporation of EB_ARC component
*
*15/03/18 - Defect - 2500881 / Task : 2505944
*            Closed accounts are not removed from TCIB. CHANNEL.PERMISSION.LIST is null for accounts closed.
*            If CHANNEL.PERMISSION.LIST is empty, then ID.list is passed with 'ACCT.CLOSED'. This flag is used in UPDATE.USER.ACCT.PREF
*            to read closed accounts and remove from user accounts groups.
*
* 29/03/18 - Defect - 2523170 / Task : 2529524
*             Citco Closed accounts are not removed from TCIB in case of multi company
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.Service
    
    $INSERT I_DAS.COMMON
    $INSERT I_DAS.EB.EXTERNAL.USER
    $INSERT I_DAS.CHANNEL.PERMISSION.LIST
*
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB PROCESS
*
RETURN
*-----------------------------------------------------------------------------
*** <region name= Initialisation>
INITIALISE:
* Initialise required variables
    ID.LIST = ''    ;*Initialising variables
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Open Files>
OPENFILES:
* Open required files
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
* Process the Channel Permission List
    ID.LIST=dasAllIds
    CALL DAS('CHANNEL.PERMISSION.LIST',ID.LIST,'','')
    EB.Service.BatchBuildList(LIST.PARAMETERS,ID.LIST)
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
