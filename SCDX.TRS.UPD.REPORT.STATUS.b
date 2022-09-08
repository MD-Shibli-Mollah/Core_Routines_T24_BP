* @ValidationCode : MjoxMzY1MzM2NTY2OkNwMTI1MjoxNjA0ODM3NTAyMTk2OnJkZWVwaWdhOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzoyMDoyMA==
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 20/20 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.REPORT.STATUS(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine fetches the Mifid Report Status inputted in the Transaction
* If EW is installed, then fetch the value from Local reference field,
* Else, refer the value from the core field
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
* RET.VAL  -  Mifid Report Status from the Transaction
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts and control logic</desc>

    $USING SC.SctTrading
    $USING ST.CompanyCreation
    $USING EB.SystemTables
    $USING SC.ScoFoundation
    $USING EB.Delivery
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to fetch the Mifid Reporting status
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

* Check if EW is installed
    EW.INSTALLED = ''
    EB.Delivery.ValProduct("EW","","",EW.INSTALLED,"")
    
    RET.VAL = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to fetch the Mifid Reporting status </desc>

    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
* If EW is installed, then fetch the value from Local reference field,
* Else, refer the value from the core field
            IF EW.INSTALLED THEN
                LOC.FLD.POSN = ''
                SC.ScoFoundation.GetLocRef("SEC.TRADE","TAP.REPORT.STAT",LOC.FLD.POSN)
                IF LOC.FLD.POSN THEN
                    RET.VAL    = TXN.REC<SC.SctTrading.SecTrade.SbsLocalRef,LOC.FLD.POSN>
                END
            END ELSE
                RET.VAL    = TXN.DATA
            END
        
    END CASE
    
RETURN
*** </region>

END
