* @ValidationCode : Mjo1MjIyOTc5OkNwMTI1MjoxNDg3MDc2NjAxMDg2OnJzdWRoYTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Feb 2017 18:20:01
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
    SUBROUTINE AA.PRD.DES.TC.AVAILABILITY
*-----------------------------------------------------------------------------
* Properties and Methods for AA.PRD.DES.TC.AVAILABILITY
*-----------------------------------------------------------------------------
* Modification History:
* 07/12/2016 - Enhancement 1825131/ Task 1825578
*              Avialability property class definition
*-----------------------------------------------------------------------------
    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Template
    $USING AF.Framework
*-----------------------------------------------------------------------------
    EB.Template.setCMethods('')
    EB.Template.setCProperties('')
*-----------------------------------------------------------------------------
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PTitle>='Connect Availability'; EB.Template.setCProperties(tmp);* Screen title
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PEquatePrefix>='AA.TC.AVAIL'; EB.Template.setCProperties(tmp);* Use to create I_F.XX.TABLE
*-----------------------------------------------------------------------------
*
    SAVE.APPL = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication('AA.PRD.DES.TC.AVAILABILITY')
*
    AF.Framework.PropertyTemplate()
*
    EB.SystemTables.setApplication(SAVE.APPL)
*
    RETURN
*-----------------------------------------------------------------------------
    END
