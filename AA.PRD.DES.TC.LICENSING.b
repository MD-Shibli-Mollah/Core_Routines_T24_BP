* @ValidationCode : MjotMTA0MDIzMzEwNzpDcDEyNTI6MTUzNzYzNDg4Mzk4NTpydGFuYXNlOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTAuMjAxODA5MTgtMTExNTotMTotMQ==
* @ValidationInfo : Timestamp         : 22 Sep 2018 19:48:03
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rtanase
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180918-1115
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.PRD.DES.TC.LICENSING
*-----------------------------------------------------------------------------
* Properties and Methods for AA.PRD.DES.TC.LICENSING
*-----------------------------------------------------------------------------
* Modification History:
*
* 09/07/2018 - Enhancement 2669405 / Task 2779868
*              TCUA : TC Licensing - User and Role Licensing for Master Arrangements
*-----------------------------------------------------------------------------
    $USING AA.Framework
    $USING AO.Framework
    $USING EB.SystemTables
    $USING EB.Template
    $USING AF.Framework
*-----------------------------------------------------------------------------
    EB.Template.setCMethods('')
    EB.Template.setCProperties('')
*-----------------------------------------------------------------------------
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PTitle>='AA Product DES - TC Licensing'; EB.Template.setCProperties(tmp);* Screen title
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PEquatePrefix>='AA.TC.LICEN'; EB.Template.setCProperties(tmp);* Use to create I_F.XX.TABLE
*-----------------------------------------------------------------------------
*
    SAVE.APPL = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication('AA.PRD.DES.TC.LICENSING')
*
    AF.Framework.PropertyTemplate()
*
    EB.SystemTables.setApplication(SAVE.APPL)
*
RETURN
*-----------------------------------------------------------------------------
END
