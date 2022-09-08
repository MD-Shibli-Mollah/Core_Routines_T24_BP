* @ValidationCode : MjotNDk0NTgwNTQzOkNwMTI1MjoxNDg4NTUzNTIxMDcwOmVyc2hhZDotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 03 Mar 2017 20:35:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ershad
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-38</Rating>
*-----------------------------------------------------------------------------
     $PACKAGE T5.ModelBank
     SUBROUTINE E.TC.SEC.MASTER.CHECK
*-----------------------------------------------------------------------------------------------------------------
* Description      : Conversion routine to create the record from MF.ORDER or SEC.OPEN.ORDER version
* Linked With      : ENQUIRY>TCIB.CUS.SECURITY.POSITIONS
*-----------------------------------------------------------------------------------------------------------------
* Modification Details:
* 29/12/15 - Defect - 1535262 / Task - 1588295
*               To check whether record is to be created from MF.ORDER or SEC.OPEN.ORDER version based on security id
* 28/02/17 - Defect - 2032637 / Task - 2038754
*               Enquiry TCIB.CUS.SECURITY.POSITIONS raises fatal error if MF product not installed
*=============================================================================================================

    $USING EB.Reports
    $USING MF.Config
    $USING SC.ScoSecurityMasterMaintenance
    $USING EB.SystemTables
    
    GOSUB INIT
    GOSUB CHECK.SPF.LICENSE
    GOSUB PROCESS
*
    RETURN
*---------------------------------------------------------------------------------------------
INIT:
*----
*Initialise required variables
    
    R.SECURITY.MASTER  = ''
    R.MF.FUND.MASTER  = ''
    MUTUAL.FUND.FLAG='N'
    SECURITY.ID=''                                ;* Initialize Security
    MUTUAL.FUNDS=''
    SECURITY.MASTER.ERR=''
    MF.FUND.MASTER.ERR=''
    MF.LIC.FLAG=''
    Y.SPF.PRODUCT=''
    Y.PROD.POS=''
      
    RETURN
*---------------------------------------------------------------------------------------------
CHECK.SPF.LICENSE:
*----------------
*To check the MF module in SPF
*
    Y.SPF.PRODUCT = EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts>   ;* Get the list of all product from SPF
    CHANGE @VM TO @FM IN Y.SPF.PRODUCT
*
    LOCATE 'MF' IN Y.SPF.PRODUCT SETTING Y.PROD.POS THEN    ;* Locate the MF module in the list
        MF.LIC.FLAG  = 'MF'       ;* If MF module is available in SPF, then set the MF license flag
    END
*
    RETURN
*---------------------------------------------------------------------------------------------
PROCESS:
*------
* To get the flag for fetching record

    SECURITY.ID = EB.Reports.getOData()           ;* To get ID of security
    IF SECURITY.ID AND MF.LIC.FLAG THEN
        R.SECURITY.MASTER = SC.ScoSecurityMasterMaintenance.tableSecurityMaster(SECURITY.ID, SECURITY.MASTER.ERR)      ;* Read the record with security id in 
        MUTUAL.FUNDS = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmMutualFund>        ;*Extract the value in Mutual fund field
        IF MUTUAL.FUNDS THEN  
            R.MF.FUND.MASTER = MF.Config.tableFundMaster(SECURITY.ID, MF.FUND.MASTER.ERR)      ;* Read the record with security id in MF.FUND.MASTER
            IF R.MF.FUND.MASTER NE "" AND MF.FUND.MASTER.ERR EQ "" THEN           ;* Setting the flag when security is present in MF.FUND.MASTER
                MUTUAL.FUND.FLAG='Y'
            END
        END
    END
    EB.Reports.setOData(MUTUAL.FUND.FLAG);*Sending the flag value

    RETURN 
*------------------------------------------------------------------------------------------------
END
*------------------------------------------------------------------------------------------------

