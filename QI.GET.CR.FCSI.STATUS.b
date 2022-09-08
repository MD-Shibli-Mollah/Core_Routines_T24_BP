* @ValidationCode : MjotMTU3MDA4OTA3ODpDcDEyNTI6MTYxNjA2NjcwNTUyOTp2aGluZHVqYTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjA6MjE6MTk=
* @ValidationInfo : Timestamp         : 18 Mar 2021 16:55:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vhinduja
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 19/21 (90.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE QI.Reporting
SUBROUTINE QI.GET.CR.FCSI.STATUS(USDB.ID, RES.IN1, RES.IN2, RES.IN3, PORT.STATUS, ERROR.INFO, RES.OUT.2, RES.OUT.3)
*-----------------------------------------------------------------------------
* Description:
* ============
* This routine returns the Portfolio status which is fetched from FCSI table
*-----------------------------------------------------------------------------
* Modification History :
*========================
*
* 18/02/2021   - Enhancement 4240598  / Task 4240601
*            API to get a portfolio status
*
*   09/03/21 - SI 4272142 / Task 4240660
*              CR WITHOUT DATE
*
*-----------------------------------------------------------------------------
    $USING FA.CustomerIdentification
    $USING ST.Customer
    
    PORT.STATUS = ""
    ERROR.INFO = ""
    
    CUS.REL.ID = FIELD(USDB.ID,"*",2) ;*get a Customer relationship id
    
    IF CUS.REL.ID THEN
        
        CR.REC = ''
        CUS.REL.ERR = ''
        ST.Customer.ReadCrRecord(CUS.REL.ID, CR.REC, CUS.REL.ERR)
        
        IF CUS.REL.ERR THEN
            ERROR.INFO = "QI-CUS.REL.NOT.FOUND"
            RETURN
        END
        FCSI.ERR = ""
        FCSI.REC = FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.Read(CUS.REL.ID, FCSI.ERR) ;*Read FCSI record
        PORT.STATUS = FCSI.REC<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiPortfolioStatus>
        IF NOT(PORT.STATUS) THEN
            ERROR.INFO = "QI-PORT.STATUS.NOT.FOUND"
        END
        
    END ELSE
        ERROR.INFO = "QI-CUS.REL.NOT.FOUND"
    END

RETURN
END
