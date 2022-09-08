* @ValidationCode : MjotMjEwNjgzMzExNzpDcDEyNTI6MTU3MTczNzc3NzM0MjpzdWRoYXJhbWVzaDoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6MTg6MTg=
* @ValidationInfo : Timestamp         : 22 Oct 2019 15:19:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 18/18 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.TC.LICENSING.RECORD(RET.ERROR)
*-----------------------------------------------------------------------------
* Description :
* Record routine for the property class TC.LICENSING
*-----------------------------------------------------------------------------
* Modification History :
*
* 09/07/2018 - Enhancement 2669405 / Task 2779868
*              TCUA : TC Licensing - User and Role Licensing for Master Arrangements
*
*  21/10/19 - Enhancement : 2851854
*             Task : 3396231
*             Code changes has been done as a part of AA to AF Code segregation
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $USING AA.Framework
    $USING EB.SystemTables
    $USING AO.Framework
    $USING AF.Framework
*** </region>
************************************************************************************
*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>
*
    GOSUB INITIALISE
    GOSUB PROCESS
*
RETURN
*** </region>

***********************************************************************************
*** <region name= Initialise>
*** <desc>File variables and local variables</desc>
INITIALISE:
* Fetch the master arrangement id
    masterArrangement = AA.Framework.getRArrangementActivity()<AA.Framework.ArrangementActivity.ArrActMasterArrangement> ;* get MasterArrangement
RETURN
*** </region>
************************************************************************************
*** <region name= Main process>
*** <desc>main processing block in the sub-routine</desc>
PROCESS:
*
    BEGIN CASE
        CASE AF.Framework.getProductArr() MATCHES AA.Framework.AaArrangement:@VM:AA.Framework.Simulation AND masterArrangement NE ""  ;* If its from the arrangement level and master arrangement
            nullvalue=""
* Make NoOfUsers and NoOfRoles as NOINPUT fields. So user is not allowed to amend.
            tmp=EB.SystemTables.getT(AO.Framework.TcLicensing.AaTcLicenNoOfUsers)     ;* NoOfUsers field is made NOINPUT
            tmp<3>="NOINPUT"
            EB.SystemTables.setT(AO.Framework.TcLicensing.AaTcLicenNoOfUsers, tmp)
            EB.SystemTables.setRNew(AO.Framework.TcLicensing.AaTcLicenNoOfUsers, nullvalue) ;* set the field to Null
    
            tmp=EB.SystemTables.getT(AO.Framework.TcLicensing.AaTcLicenNoOfRoles)     ;* NoOfRoles field is made NOINPUT
            tmp<3>="NOINPUT"
            EB.SystemTables.setT(AO.Framework.TcLicensing.AaTcLicenNoOfRoles, tmp)
            EB.SystemTables.setRNew(AO.Framework.TcLicensing.AaTcLicenNoOfRoles, nullvalue) ;* set the field to Null
    END CASE

RETURN
*** </region>
************************************************************************************
END
