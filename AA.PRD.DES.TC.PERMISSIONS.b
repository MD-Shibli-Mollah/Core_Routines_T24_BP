* @ValidationCode : MjoxMzM0MTk5NDkxOkNwMTI1MjoxNDg3MDczNjIxNjM5OnJzdWRoYTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Feb 2017 17:30:21
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
    SUBROUTINE AA.PRD.DES.TC.PERMISSIONS
*-----------------------------------------------------------------------------
* Properties and Methods for AA.PRD.DES.TC.PERMISSIONS
*-----------------------------------------------------------------------------
* Modification History:
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            Tc Permissions property class
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
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PTitle>='AA Product DES - TC Permissions'; EB.Template.setCProperties(tmp);* Screen title
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PEquatePrefix>='AA.TC.PERM'; EB.Template.setCProperties(tmp);* Use to create I_F.XX.TABLE
*-----------------------------------------------------------------------------
*
    SAVE.APPL = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication('AA.PRD.DES.TC.PERMISSIONS')
*
    AF.Framework.PropertyTemplate()
*
    EB.SystemTables.setApplication(SAVE.APPL)
*
    RETURN
*-----------------------------------------------------------------------------
    END
