* @ValidationCode : Mjo0MjE3MTAyNjI6Q3AxMjUyOjE1NzE3MzczODkzNTY6c3VkaGFyYW1lc2g6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6LTE6LTE=
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
    SUBROUTINE AA.PRD.PRF.TC.AVAILABILITY
*-----------------------------------------------------------------------------
* Properties and Methods for AA.PRD.PRF.TC.AVAILABILITY
*-----------------------------------------------------------------------------
* Modification History:
* 07/12/2016 - Enhancement 1825131/ Task 1825578
*              Avialability property class definition
*
*  21/10/19 - Enhancement : 2851854
*             Task : 3396231
*             Code changes has been done as a part of AA to AF Code segregation
*-----------------------------------------------------------------------------
    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Template
    $USING AF.Framework
*-----------------------------------------------------------------------------
    EB.Template.setCMethods('')
    EB.Template.setCProperties('')
*-----------------------------------------------------------------------------
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PTitle>='AA Product Proof - Availability Property'; EB.Template.setCProperties(tmp);* Screen title
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PEquatePrefix>='AA.TC.AVAIL'; EB.Template.setCProperties(tmp);* Use to create I_F.XX.TABLE
*-----------------------------------------------------------------------------
*
    SAVE.APPL = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication('AA.PRD.PRF.TC.AVAILABILITY')
*
    AF.Framework.PropertyTemplate()
*
    EB.SystemTables.setApplication(SAVE.APPL)
*
    RETURN
*-----------------------------------------------------------------------------
    END
