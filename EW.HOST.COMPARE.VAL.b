* @ValidationCode : MjoxNzgwNTE0MjIyOkNwMTI1MjoxNTY2OTc0NTY4NjY0OmJhaml0aDotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA1MzEtMDMxNDotMTotMQ==
* @ValidationInfo : Timestamp         : 28 Aug 2019 12:12:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bajith
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE EW.HostCompare
SUBROUTINE EW.HOST.COMPARE.VAL(ENQUIRY.DATA)
****************************************
* ROUTINE CALLED BY EW.HOST.COMPARE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 09/07/2019  SI - 3107672 / Enchancement- 3213200/TASK -3213203
*             EW HOST compare template and service changes
*-----------------------------------------------------------------------------
    $USING EW.HostCompare
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING EB.Service
 
* Continue only for the service - EW.HOST.COMPARE.ONLINE.SERVICE
    IF EB.Service.getBatchInfo()<3> NE 'EW.HOST.COMPARE.ONLINE.SERVICE' THEN
        RETURN
    END
    
    SEC.ACC.NO = ''
    SEC.ACC.NO = EB.Service.getBatchThreadKey()[" ",2,1]
   
    IF SEC.ACC.NO THEN
        ENQUIRY.DATA<2,1> = 'PORTFOLIO.ID'
        ENQUIRY.DATA<3,1> = 'EQ'
        ENQUIRY.DATA<4,1> = SEC.ACC.NO
    END
    
RETURN

END
