* @ValidationCode : MjotMTE0NzcwODM5NTpDcDEyNTI6MTU3MTczNzM4OTQ4MTpzdWRoYXJhbWVzaDotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTAuMjAxOTA5MjAtMDcwNzotMTotMQ==
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

*-----------------------------------------------------------------------------
    $PACKAGE AO.Framework
    SUBROUTINE AA.PRD.PRF.TC.PRIVILEGES
*-----------------------------------------------------------------------------
* Properties and Methods for AA.PRD.PRF.TC.PRIVILEGES
*-----------------------------------------------------------------------------
* Modification History:
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            Tc Privileges property class
*-----------------------------------------------------------------------------
    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Template
    $USING AF.Framework
*-----------------------------------------------------------------------------
    EB.Template.setCMethods('')
    EB.Template.setCProperties('')
*-----------------------------------------------------------------------------
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PTitle>='AA Product Proof - TC Privileges'; EB.Template.setCProperties(tmp);* Screen title
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PEquatePrefix>='AA.TC.PRIV'; EB.Template.setCProperties(tmp);* Use to create I_F.XX.TABLE
*-----------------------------------------------------------------------------
*
    SAVE.APPL = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication('AA.PRD.PRF.TC.PRIVILEGES')
*
    AF.Framework.PropertyTemplate()
*
    EB.SystemTables.setApplication(SAVE.APPL)
*
    RETURN
*-----------------------------------------------------------------------------
    END
