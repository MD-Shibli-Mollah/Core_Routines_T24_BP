* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Template
    SUBROUTINE TEMPLATE.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine YOURAPPLICATION.FIELDS
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
* 19/10/07 - EN_10003543
*            New Template changes
*
* 14/11/07 - BG_100015736
*            Exclude routines that are not released
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>

    $USING EB.Template
*** </region>
*-----------------------------------------------------------------------------
    EB.Template.TableDefineid("TABLE.NAME.ID", EB.Template.T24String) ;* Define Table id
*-----------------------------------------------------------------------------
    EB.Template.TableAddfield(fieldName, fieldType, args, neighbour) ;* Add a new fields
    EB.Template.FieldSetcheckfile(fileName)        ;* Use DEFAULT.ENRICH from SS or just field 1
    EB.Template.TableAddfielddefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
    EB.Template.TableAddfieldwitheblookup(fieldName,virtualTableName,neighbour) ;* Specify Lookup values
    EB.Template.FieldSetdefault(defaultValue) ;* Assign default value
*-----------------------------------------------------------------------------
    EB.Template.TableSetauditposition() ;* Populate audit information
*-----------------------------------------------------------------------------
    RETURN
*-----------------------------------------------------------------------------
    END
