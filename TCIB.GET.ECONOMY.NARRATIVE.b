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
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T5.ModelBank
    SUBROUTINE TCIB.GET.ECONOMY.NARRATIVE
*-----------------------------------------------------------------------------
*Conversion Routine to get the full Descrption from a AM.ECONOMY.REPORTS and returns the
*message by replacing ']' with a separator '~'
*@author arunjoshi@temenos.com
*INCOMING PARAMETER - O.DATA which is Market Narrative
*OUTGOING PARAMETER - O.DATA which is Market Narrative
*-----------------------------------------------------------------------------
* Modification History:
*---------------------
* 05/03/2014 - Enhancement - TCIB Wealth
*              Enhancement/Task ID - 641974/927795
* 29/04/2014 - Enhancement/Task ID - 641974/984685
*              Removed seperator for reports specific
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts
    $USING EB.Reports
    $USING AM.ModelBank
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>

    GOSUB INITIALISE
    GOSUB PROCESS

*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise commons and do OPF </desc>
INITIALISE:
*---------
    ECO.ID = EB.Reports.getOData()
    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> Converting the message </desc>
PROCESS:
*------
    R.ECO = AM.ModelBank.EconomyReports.Read(ECO.ID,ECO.ERR)
    IF NOT(ECO.ERR) THEN
        Y.MSG = R.ECO<AM.ModelBank.EconomyReports.Eco18Narrative>
        CONVERT @VM TO " " IN Y.MSG
        CONVERT "\" TO " " IN Y.MSG
        EB.Reports.setOData(Y.MSG)
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
