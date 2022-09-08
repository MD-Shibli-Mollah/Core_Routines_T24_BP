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

    $PACKAGE AA.ModelBank
    SUBROUTINE E.MB.AA.GET.REDEEM.PROP.FMT
*-----------------------------------------------------------------------------
**** <region name= Program description>
*** <desc> </desc>
*
* Format the output and convert to VM
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification history>
*** <desc> </desc>
* Modification History :
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>

   $USING EB.Reports

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    tmp.O.DATA = EB.Reports.getOData()
    CONVERT '~' TO @VM IN tmp.O.DATA
    EB.Reports.setVmCount(DCOUNT(tmp.O.DATA, @VM))
    EB.Reports.setOData(tmp.O.DATA)
    EB.Reports.setOData(EB.Reports.getOData()<1,EB.Reports.getVc()>)

    RETURN
*** </region>
*-----------------------------------------------------------------------------

    END
