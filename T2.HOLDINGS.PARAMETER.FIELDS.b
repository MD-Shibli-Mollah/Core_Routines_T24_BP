* @ValidationCode : MjoyMTA5ODM0MDE6Q3AxMjUyOjE1NTY1MjY2MTMwNzQ6c211Z2VzaDotMTotMTowOjE6dHJ1ZTpOL0E6REVWXzIwMTkwMy4xOi0xOi0x
* @ValidationInfo : Timestamp         : 29 Apr 2019 14:00:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_201903.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE T2.HOLDINGS.PARAMETER.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine T2.HOLDINGS.PARAMETER.FIELDS
*
* @author tcoleman@temenos.com
* @stereotype fields template
* @uses Table
* @public Table Creation
* @package infra.eb
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
*
* 10/03/19 - Task 3018257 (Enhancement 2875480)
*            Parameter table fields for customer Holdings
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $USING EB.SystemTables
    $USING EB.Template
    $USING ST.Config
*** </region>
*-----------------------------------------------------------------------------
    EB.SystemTables.setIdF('@ID')
    EB.SystemTables.setIdN('6')
    EB.SystemTables.setIdT("":@FM:'SYSTEM')
*-----------------------------------------------------------------------------

    EB.Template.TableAddfieldwitheblookup("XX<HOLDINGS.TYPE", "HOLDINGS.TYPE", '')
    EB.Template.TableAddfielddefinition("XX-PRODUCT.LINE",35,'A','')  ;
    EB.Template.FieldSetcheckfile("AA.PRODUCT.LINE")
    EB.Template.TableAddfielddefinition("XX-PRODUCT.GROUP",35,'A','') ;
    EB.Template.FieldSetcheckfile("AA.PRODUCT.GROUP")
    EB.Template.TableAddfielddefinition("XX-PRODUCT",35,'A','')  ;
    EB.Template.FieldSetcheckfile("AA.PRODUCT")
    EB.Template.TableAddfielddefinition("XX-SECURITY.FILTER",60,'A','') ;
    EB.Template.TableAddfielddefinition("XX-API.HOOK.ROUTINE",50,'A','');
    EB.Template.FieldSetcheckfile("EB.API")
    EB.Template.TableAddreservedfield("XX-RESERVED.10")
    EB.Template.TableAddreservedfield("XX-RESERVED.09")
    EB.Template.TableAddreservedfield("XX-RESERVED.08")
    EB.Template.TableAddreservedfield("XX-RESERVED.07")
    EB.Template.TableAddreservedfield("XX>RESERVED.06")
    EB.Template.TableAddreservedfield("RESERVED.05")
    EB.Template.TableAddreservedfield("RESERVED.04")
    EB.Template.TableAddreservedfield("RESERVED.03")
    EB.Template.TableAddreservedfield("RESERVED.02")
    EB.Template.TableAddreservedfield("RESERVED.01")
    
*-----------------------------------------------------------------------------
    EB.Template.TableSetauditposition()         ;* Poputale audit information
*-----------------------------------------------------------------------------


RETURN
*-----------------------------------------------------------------------------
END
