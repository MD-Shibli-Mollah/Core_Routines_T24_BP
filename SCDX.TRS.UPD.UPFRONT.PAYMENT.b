* @ValidationCode : MjoxNjE3MTQwMzY5OkNwMTI1MjoxNjA1OTAzMzM4NTkyOnJkZWVwaWdhOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzoxNzoxNw==
* @ValidationInfo : Timestamp         : 21 Nov 2020 01:45:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 17/17 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.UPFRONT.PAYMENT(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine to return Upfront payment if upfront Security is used in transaction
* for updation in SCDX.ARM.MIFID.DATA for reporting purpose
* Attached as the link routine in TX.TXN.BASE.MAPPING for updation in
* Database SCDX.ARM.MIFID.DATA
* Incoming parameters:
**********************
* TXN.ID   -   Transaction ID of the contract.
* TXN.REC  -   A dynamic array holding the contract.
* TXN.DATA -   Data passed based on setup done in TX.TXN.BASE.MAPPING
*
* Outgoing parameters:
**********************
* RET.VAL  -  Upfront Payment amount
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*
* 20/11/2020 - Task - 4083678
*              To identify if the upfront payment is involved in the transaction
*              based on Transaction code used 
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts and control logic</desc>

    $USING SC.SctTrading
    $USING ST.CompanyCreation
    $USING SC.Config
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to return Upfront payment if upfront Security is used in transaction
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>
    
    RET.VAL = ''

    R.SC.PARAMETER = '' ; SC.PARAM.ERROR = ''
    ST.CompanyCreation.EbReadParameter('F.SC.PARAMETER','N','',R.SC.PARAMETER,'','',SC.PARAM.ERROR)
    IF R.SC.PARAMETER<SC.Config.Parameter.ParamUpfrontDirect> THEN
        UPFRONT.TXN.CODES       = R.SC.PARAMETER<SC.Config.Parameter.ParamUpfrontTxnCode>
    END
            
            
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc>Process to return Upfront payment if upfront Security is used in transaction reporting purpose </desc>

    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
            IF TXN.REC<SC.SctTrading.SecTrade.SbsCuOrderNos> AND TXN.REC<SC.SctTrading.SecTrade.SbsCustTransCode,1> MATCHES UPFRONT.TXN.CODES THEN
                RET.VAL = TXN.REC<SC.SctTrading.SecTrade.SbsBrNetAmTrd,1>
            END
                            
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
