* @ValidationCode : MjoxMDMyMTgwNzIyOkNwMTI1MjoxNjAxMDE4NTIxOTk1OnNiaGFyYXRoaToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA3LjIwMjAwNzAxLTA2NTc6MTk6MTk=
* @ValidationInfo : Timestamp         : 25 Sep 2020 12:52:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sbharathi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 19/19 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-29</Rating>
*-----------------------------------------------------------------------------
$PACKAGE VP.Config
SUBROUTINE VP.UPDATE.DES.SELECT
*
*-----------------------------------------------------------------------------
*
* Modification History :
*
* 14\11\11 - Task 234981
*            AML Service.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*            Routine incorporated
*
*-----------------------------------------------------------------------------
*
    $USING EB.DataAccess
    $USING EB.Service
    $USING VP.Config
    $INSERT I_DAS.AML.TXN.ENTRY
    $INSERT I_DAS.AML.TXN.ENTRY.NOTES
*
    GOSUB INITIALISE
    GOSUB SELECT.LIST
    GOSUB BUILD.LIST
*
RETURN
*
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialising variables goes here</desc>
*
INITIALISE:
***********
*
    SELE.ID.LIST = ''
*
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BUILD.BASE.LIST>
*** <desc>Building list file</desc>
*
SELECT.LIST:
****************
*
    TABLE.NAME = 'AML.TXN.ENTRY'
    TABLE.SUFFIX = ''
    THE.ARGS = ''
    THE.LIST = 'ALL.IDS'
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SELE.ID.LIST = THE.LIST
   
    
RETURN
*-----------------------------------------------------------------------------
BUILD.LIST:
*-----------
    LIST.PARAMETERS = ''
    LIST.PARAMETERS<1> = 'F.AML.TXN.ENTRY'
    EB.Service.BatchBuildList(LIST.PARAMETERS,SELE.ID.LIST)

RETURN
*
*** </region>
*-----------------------------------------------------------------------------
END
