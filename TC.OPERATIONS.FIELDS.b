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
* <Rating>-32</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE TC.OPERATIONS.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine TC.OPERATIONS.FIELDS
*
* @author ershad@temenos.com
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
*
* 14/11/13 - Enhancement - 696313/Task - 696344
*            TCIB-Corporate- Phase1- Webservice to expose Role based functionalities
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>

    $USING EB.Template
*** </region>
*-----------------------------------------------------------------------------
    Temp.Str = EB.Template.T24String
    Temp.FieldNoInput = EB.Template.FieldNoInput
    EB.Template.TableDefineid("@ID", Temp.Str)        ;* Define Table id
*-----------------------------------------------------------------------------

*  CALL Table.addField(fieldName, fieldType, args, neighbour)        ;* Add a new fields
*  CALL Field.setCheckFile(fileName)   ;* Use DEFAULT.ENRICH from SS or just field 1
*  CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
*  CALL Table.addFieldWithEbLookup(fieldName,virtualTableName,neighbour)       ;* Specify Lookup values
*  CALL Field.setDefault(defaultValue) ;* Assign default value

    fieldName = "XX.LL.DESCRIPTION"
    fieldLength = "35"
    fieldType = "A"
    neighbour = ""
    EB.Template.TableAddfielddefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = "XX.ALLOWED.CHANNEL"
    fieldLength = "35"
    fieldType = "A"
    neighbour = ""
    EB.Template.TableAddfielddefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
    EB.Template.FieldSetcheckfile('EB.CHANNEL')         ;* Use DEFAULT.ENRICH from SS or just field 1

    EB.Template.TableAddfield("RESERVED.10", Temp.Str, Temp.FieldNoInput,"")
    EB.Template.TableAddfield("RESERVED.9", Temp.Str, Temp.FieldNoInput,"")
    EB.Template.TableAddfield("RESERVED.8", Temp.Str, Temp.FieldNoInput,"")
    EB.Template.TableAddfield("RESERVED.7", Temp.Str, Temp.FieldNoInput,"")
    EB.Template.TableAddfield("RESERVED.6", Temp.Str, Temp.FieldNoInput,"")
    EB.Template.TableAddfield("RESERVED.5", Temp.Str, Temp.FieldNoInput,"")
    EB.Template.TableAddfield("RESERVED.4", Temp.Str, Temp.FieldNoInput,"")
    EB.Template.TableAddfield("RESERVED.3", Temp.Str, Temp.FieldNoInput,"")
    EB.Template.TableAddfield("RESERVED.2", Temp.Str, Temp.FieldNoInput,"")
    EB.Template.TableAddfield("RESERVED.1", Temp.Str, Temp.FieldNoInput,"")

*-----------------------------------------------------------------------------
    EB.Template.TableSetauditposition()       ;* Populate audit information
*-----------------------------------------------------------------------------
    RETURN
*-----------------------------------------------------------------------------
    END
