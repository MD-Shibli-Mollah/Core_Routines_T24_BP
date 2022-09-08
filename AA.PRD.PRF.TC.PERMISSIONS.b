* @ValidationCode : MjoxNzQ1Njk4ODE6Q3AxMjUyOjE1NzE3MzczODk0MzY6c3VkaGFyYW1lc2g6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Oct 2019 15:13:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AO.Framework
    SUBROUTINE AA.PRD.PRF.TC.PERMISSIONS
*-----------------------------------------------------------------------------
* Properties and Methods for AA.PRD.PRF.TC.PERMISSIONS
*-----------------------------------------------------------------------------
* Modification History:
*
* 03/10/16 - Enhancement 1812222  / Task 1905849
*            Tc Permissions property class
*
*  21/10/19 - Enhancement : 2851854
*             Task : 3396231
*             Code changes has been done as a part of AA to AF Code segregation
*-----------------------------------------------------------------------------
    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Template
    $USING AO.Framework
    $USING AF.Framework
*-----------------------------------------------------------------------------
    EB.Template.setCMethods('')
    EB.Template.setCProperties('')
*-----------------------------------------------------------------------------
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PTitle>='AA Product Proof -TC Permissions'; EB.Template.setCProperties(tmp);* Screen title
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PEquatePrefix>='AA.TC.PERM'; EB.Template.setCProperties(tmp);* Use to create I_F.XX.TABLE
*-----------------------------------------------------------------------------
*
    SAVE.APPL = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication('AA.PRD.PRF.TC.PERMISSIONS')
*
    AF.Framework.PropertyTemplate()
*
    EB.SystemTables.setApplication(SAVE.APPL)
*
    RETURN
*-----------------------------------------------------------------------------
    END
