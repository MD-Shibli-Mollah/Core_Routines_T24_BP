* @ValidationCode : MjotMTE5OTI2MDg0ODpDcDEyNTI6MTYwODE0NTY3MjU5NTp2ZWxtdXJ1Z2FuOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMC4yMDIwMDkyOS0xMjEwOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Dec 2020 00:37:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : velmurugan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE VL.Config
SUBROUTINE VL.UPDATE.STP.RESPONSE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
    $USING VL.Config
    $USING EB.SystemTables

    GOSUB INITIALIZE
    GOSUB UPDATE.STP.RESPONSE
RETURN

*-----------------------------------------------------------------------------
*** <region name= INITIALIZE>
*** <desc> </desc>
INITIALIZE:
    TXN.ID = EB.SystemTables.getIdNew()
    CO.CODE = EB.SystemTables.getIdCompany()
    APPLIC = EB.SystemTables.getApplication()
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UPDATE.STP.RESPONSE>
*** <desc> </desc>
UPDATE.STP.RESPONSE:
    STP.RES.ID = TXN.ID:"*":CO.CODE
    R.STP.RESPONSE<VL.Config.VlStpResponse.VlsApplication> = APPLIC
    VL.Config.VlStpResponse.Write(STP.RES.ID, R.STP.RESPONSE)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

END

