* @ValidationCode : MjotMjA2OTMwMjI4MjpDcDEyNTI6MTQ4NzA3MzYyMDg5MDpyc3VkaGE6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxNzAyLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 14 Feb 2017 17:30:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AO.Framework
    SUBROUTINE TC.SERVICES
*-----------------------------------------------------------------------------
* Description:
* Application to specify privileges for External Users
*-----------------------------------------------------------------------------
* Modification History:
**
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            Tc Services and Operations
*-----------------------------------------------------------------------------
* <region name= Inserts>
    $USING EB.Template
* </region>
*-----------------------------------------------------------------------------
    EB.Template.setTableName('TC.SERVICES');* Full application name including product prefix
    EB.Template.setTableTitle('TC.SERVICES');* Screen title
    EB.Template.setTableStereotype('H');* H, U, L, W or T
    EB.Template.setTableProduct('EB');* Must be on EB.PRODUCT
    EB.Template.setTableSubproduct('');* Must be on EB.SUB.PRODUCT
    EB.Template.setTableClassification('INT');* As per FILE.CONTROL
    EB.Template.setTableSystemclearfile('Y');* As per FILE.CONTROL
    EB.Template.setTableRelatedfiles('');* As per FILE.CONTROL
    EB.Template.setTableIspostclosingfile('');* As per FILE.CONTROL
    EB.Template.setTableEquateprefix('TC.SVC')  ;* Use to create I_F.TC.SERVICES
*-----------------------------------------------------------------------------
    EB.Template.setTableIdprefix('');* Used by EB.FORMAT.ID if set
    EB.Template.setTableBlockedfunctions('');* Space delimeted list of blocked functions
    Table.trigger = ''        ;* Trigger field used for OPERATION style fields
*-----------------------------------------------------------------------------
    RETURN
*-----------------------------------------------------------------------------
    END
