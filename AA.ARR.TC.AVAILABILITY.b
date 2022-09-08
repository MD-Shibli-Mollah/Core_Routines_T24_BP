* @ValidationCode : MjoxMzY3MTc1NTg4OkNwMTI1MjoxNjQ3OTM2Mjg5NjAwOnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Mar 2022 14:04:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0

*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.ARR.TC.AVAILABILITY
*-----------------------------------------------------------------------------
* Properties and Methods for AA.ARR.TC.AVAILABILITY
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
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PTitle> = 'AA Arrangement - Connect Availability'; EB.Template.setCProperties(tmp);* Screen title
    tmp=EB.Template.getCProperties(); tmp<EB.Template.PEquatePrefix>='AA.TC.AVAIL'; EB.Template.setCProperties(tmp);* Use to create I_F.XX.TABLE
*-----------------------------------------------------------------------------
*
    SAVE.APPL = EB.SystemTables.getApplication()
    EB.SystemTables.setApplication('AA.ARR.TC.AVAILABILITY')
*
    AF.Framework.PropertyTemplate()
*
    EB.SystemTables.setApplication(SAVE.APPL)
*
RETURN
*-----------------------------------------------------------------------------
END
