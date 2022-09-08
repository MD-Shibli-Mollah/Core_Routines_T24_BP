* @ValidationCode : Mjo2NDI2NzQ2ODI6Q3AxMjUyOjE2MTUyMDY2MDAxMjY6c3ZhbXNpa3Jpc2huYTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 08 Mar 2021 18:00:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE QI.Reporting
SUBROUTINE QI.GET.TAX.TYPE(USDB.ID,USDB.REC,RES.IN.1,RES.IN.2,QI.TAX.TYPE,FATCA.TAX.TYPE,RES.OUT.1,ERROR.INFO)
*-----------------------------------------------------------------------------
* API to fetch tax type
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 24/02/2021 - En 4240470 / Task 4240473
*              API to fetch tax type
*
*-----------------------------------------------------------------------------
        
    $USING SC.SccEntitlements
    $USING QI.Config
    
    GOSUB INITIALISE ; *Read all the required tables
    GOSUB PROCESS ; *
       
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    ENT.ID = FIELD(USDB.ID,"*",4)
    ENT.ERR = ""
    ENT.REC = SC.SccEntitlements.Entitlement.Read(ENT.ID, ENT.ERR)
    
    QI.PARAM.REC = ""
    ERR.INFO = ""
    QI.Config.QiReadParameter("", QI.PARAM.REC, ERR.INFO, '', '', '')
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    BEGIN CASE
        CASE "*":QI.PARAM.REC<QI.Config.QiParameter.QiParQiTaxType> MATCHES ENT.REC<SC.SccEntitlements.Entitlement.EntScTaxType>
            QI.TAX.TYPE = "*":QI.PARAM.REC<QI.Config.QiParameter.QiParQiTaxType>
                  
        CASE "*":QI.PARAM.REC<QI.Config.QiParameter.QiParFatcaTaxType> MATCHES ENT.REC<SC.SccEntitlements.Entitlement.EntScTaxType>
            FATCA.TAX.TYPE = "*":QI.PARAM.REC<QI.Config.QiParameter.QiParFatcaTaxType>
    END CASE
    
*** </region>

END

