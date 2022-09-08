* @ValidationCode : MjoxMzkxNTgwMTI3OkNwMTI1MjoxNjA1OTAzMzM3MjcyOnJkZWVwaWdhOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzoyNzoyNw==
* @ValidationInfo : Timestamp         : 21 Nov 2020 01:45:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 27/27 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.CONDITION.CHECK(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* This routine determines whether the database file SCDX.ARM.MIFID.DATA
* needs to be updated or not.
* This routine will be attached in TX.CONDITION of SEC.TRADE & DX.TRADE
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*
* 20/11/2020 - Task - 4083678
*              If upfront security in SEC.TRADE holds value, then it will not
*              be reported as this is dummy trade
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts and control logic</desc>

    $USING ST.CompanyCreation
    $USING DX.Configuration
    $USING SC.Config
    $USING EB.SystemTables
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    IF DO.PROCESS THEN
        GOSUB PROCESS       ; *Process to check whether the database SCDX.ARM.MIFID.DATA updation is required for transaction
    END
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

    DO.PROCESS = 0 ; RET.VAL = 0
    IF EB.SystemTables.getMessage() EQ 'AUT' THEN
        DO.PROCESS = 1
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to check whether the database SCDX.ARM.MIFID.DATA updation is required for transaction </desc>

    BEGIN CASE
        CASE APPL.ID[1,2] EQ "SC"
            R.SC.PARAMETER = '' ; SC.PARAM.ERROR = ''
            ST.CompanyCreation.EbReadParameter('F.SC.PARAMETER','N','',R.SC.PARAMETER,'','',SC.PARAM.ERROR)
            GOSUB CHECK.UPFRONT.PAYMENT ; *Check if it is upfront payment trade
            RET.VAL = R.SC.PARAMETER<SC.Config.Parameter.ParamTransactionReporting> EQ 'YES' AND NOT(UPRONT.PAYMENT)
            
        CASE APPL.ID[1,2] EQ "DX"
            R.DX.PARAMETER = '' ; DX.PARAM.ERROR = ''
            ST.CompanyCreation.EbReadParameter('F.DX.PARAMETER','N','',R.DX.PARAMETER,'SYSTEM','',DX.PARAM.ERROR)
            RET.VAL = R.DX.PARAMETER<DX.Configuration.Parameter.ParTransactionReporting> EQ 'YES'
                        
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.UPFRONT.PAYMENT>
CHECK.UPFRONT.PAYMENT:
*** <desc>Check if it is upfront payment trade </desc>

    UPRONT.PAYMENT          = ''
    IF APPL.REC<SC.SctTrading.SecTrade.SbsUpfrontSec> THEN
        UPRONT.PAYMENT = 'YES'
    END
    
RETURN
*** </region>

END
