* @ValidationCode : Mjo2NDA4MzA3NTc6Q3AxMjUyOjE1NzE3Mzc3NzczNzQ6c3VkaGFyYW1lc2g6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMC4yMDE5MDkyMC0wNzA3OjI5OjI5
* @ValidationInfo : Timestamp         : 22 Oct 2019 15:19:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 29/29 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AO.Framework
    SUBROUTINE AA.TC.PERMISSIONS.RECORD(RET.ERROR)
*--------------------------------------------------------------------------------------------------------------
* Description :
* Record routine for the property class TC.PERMISSIONS
*--------------------------------------------------------------------------------------------------------------
* Modification History:
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            Tc Permissions property class
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
    $USING EB.TransactionControl
    $USING EB.Interface
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
*
    RETURN
*** </region>
************************************************************************************
*** <region name= Main process>
*** <desc>main processing block in the sub-routine</desc>
PROCESS:
*
    tmp.VFUNCTION = EB.SystemTables.getVFunction()
    IF INDEX("ICH", tmp.VFUNCTION, 1) THEN
*** Customer field must be updated for all activities except Renewal
        GOSUB PROCESS.RECORD
    END
*
    RETURN
*** </region>
************************************************************************************
*** <region name= Main process>
*** <desc>main processing block in the sub-routine</desc>
PROCESS.RECORD:
*
    BEGIN CASE
        CASE AF.Framework.getProductArr() EQ AA.Framework.Product   ;* If its from the designer level
            GOSUB DESIGNER.DEFAULTS         ;* Ideally no defaults at the product level
        CASE AF.Framework.getProductArr() MATCHES AA.Framework.AaArrangement:@VM:AA.Framework.Simulation  ;* If its from the arrangement level
            CurrentActivityClass = AA.Framework.getRArrangementActivity()<AA.Framework.ArrangementActivity.ArrActActivityClass>
            CurrActivity = FIELD(CurrentActivityClass, AA.Framework.Sep, 2,2)   ;* it will be Change-Customer Activity
            Mode = EB.Interface.getOfsOperation()
            AF.Framework.DetermineProcessMode(ProcessMode)    ;* It is for identifying the OFS mode
            IF Mode EQ "BUILD" OR ProcessMode EQ "OFS" THEN
                GOSUB ARRANGEMENT.LEVEL.DEFAULTS      ;* Default and update all fields from arrangement level
            END
            GOSUB UPDATE.NOINPUT.TYPE
    END CASE

    RETURN
*** </region>
************************************************************************************
*** <region name= Designer Defaults>
*** <desc>Ideally no defaults at the product level </desc>
DESIGNER.DEFAULTS:
*** Don't Allow to Input any field values at product level except Description. Make all fields as Noinput.
*
    RETURN
*** </region>
************************************************************************************
*** <region name= Arrangement Level Defaults>
*** <desc>Default required at arrangement level</desc>
ARRANGEMENT.LEVEL.DEFAULTS:
*
    RETURN
*** </region>
************************************************************************************
*** <region name= Update Noinput Type>
*** <desc>Default required at arrangement level</desc>
UPDATE.NOINPUT.TYPE:
** Make Defined Product Groups as NOINPUT fields. So user is not allowed to amend.
    tmp=EB.SystemTables.getT(AO.Framework.TcPermissions.AaTcPermDefinedProductGroups)     ;* Defined product groups field is made NOINPUT
    tmp<3>="NOINPUT"
    EB.SystemTables.setT(AO.Framework.TcPermissions.AaTcPermDefinedProductGroups, tmp)
*
    RETURN
*** </region>
************************************************************************************
    END
