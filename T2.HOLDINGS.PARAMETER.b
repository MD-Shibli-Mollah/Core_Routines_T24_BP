* @ValidationCode : MjoxMTUyMjA2NzI6Y3AxMjUyOjE1NTIyMjIxMzE5ODA6c211Z2VzaDotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDMuMTotMTotMQ==
* @ValidationInfo : Timestamp         : 10 Mar 2019 18:18:51
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE T2.HOLDINGS.PARAMETER
*-----------------------------------------------------------------------------
*<doc>
* TODO add a description of the application here.
* @author youremail@temenos.com
* @stereotype Application
* @package TODO define the product group and product, e.g. infra.eb
* </doc>
*-----------------------------------------------------------------------------
* TODO - You MUST write a .FIELDS routine for the field definitions
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 10/03/19 - Task 3018257 (Enhancement 2875480)
*            Parameter table for customer Holdings

* ----------------------------------------------------------------------------

* <region name= Inserts>
    $USING EB.Template
* </region>
*-----------------------------------------------------------------------------
    EB.Template.setTableName('T2.HOLDINGS.PARAMETER');* Full application name including product prefix
    EB.Template.setTableTitle('T2.HOLDINGS.PARAMETER');* Screen title
    EB.Template.setTableStereotype('H');* H, U, L, W or T
    EB.Template.setTableProduct('T2');* Must be on EB.PRODUCT
    EB.Template.setTableSubproduct('');* Must be on EB.SUB.PRODUCT
    EB.Template.setTableClassification('INT');* As per FILE.CONTROL
    EB.Template.setTableSystemclearfile('Y');* As per FILE.CONTROL
    EB.Template.setTableRelatedfiles('');* As per FILE.CONTROL
    EB.Template.setTableIspostclosingfile('');* As per FILE.CONTROL
    EB.Template.setTableEquateprefix('T2.HP');* Use to create I_F.EB.LOG.PARAMETER
*-----------------------------------------------------------------------------
    EB.Template.setTableIdprefix('');* Used by EB.FORMAT.ID if set
    EB.Template.setTableBlockedfunctions('');* Space delimeted list of blocked functions
    Table.trigger = ''        ;* Trigger field used for OPERATION style fields
*-----------------------------------------------------------------------------

RETURN
END
