* @ValidationCode : MjoxNzU5NzQ5MTk3OkNwMTI1MjoxNjEwMzk3NzIwODkxOnJkZWVwaWdhOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMjgtMDYzMDozMjozMg==
* @ValidationInfo : Timestamp         : 12 Jan 2021 02:12:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 32/32 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.FIRM.CTRY(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine returns the country of the branch of the investment firm for
* the person responsible for the execution of the transaction
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
* RET.VAL  -  Country of the branch of the investment firm
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*
* 06/01/2021 - SI: 4015370/ Enh: 4149404 / Task: 4149408
*              LEI NCI Handling - TRS Reporting
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts and control logic</desc>

    $USING SC.SctTrading
    $USING EB.Delivery
    $USING SC.ScoFoundation
    $USING ST.CustomerService
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to fetch the country of the branch of the investment firm
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

    RET.VAL = ''
    CUSTOMER.NO = ''
    
* Check if EW is installed
    EW.INSTALLED = ''
    EB.Delivery.ValProduct("EW","","",EW.INSTALLED,"")
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to fetch country of the branch of the investment firm</desc>

    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
* If EW is installed, then fetch the value from Local reference field,
* Else, refer the value from the core field
            IF EW.INSTALLED THEN
                LOC.FLD.POSN = ''
                SC.ScoFoundation.GetLocRef("SEC.TRADE","TAP.INSTR.MKR",LOC.FLD.POSN)
                CUSTOMER.NO    = TXN.REC<SC.SctTrading.SecTrade.SbsLocalRef,LOC.FLD.POSN>
            END ELSE
                CUSTOMER.NO    = TXN.DATA
            END
        
        CASE TXN.ID[1,5] EQ "DXTRA"
            CUSTOMER.NO    = TXN.DATA

    END CASE

* When the Instruction maker is mentioned in the format L/N-CustomerNo-LEI/NCI code, fetch the customer from the second part
    IF CUSTOMER.NO[1,2] MATCHES 'L-':@VM:'N-' THEN
        CUSTOMER.NO = FIELD(CUSTOMER.NO,'-',2)
    END

    GOSUB GET.CUS.RESIDENCE ; *Get the residence of the customer

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.CUS.RESIDENCE>
GET.CUS.RESIDENCE:
*** <desc>Get the residence of the customer </desc>

* Fetch the Residence from the Customer record
    IF NOT(CUSTOMER.NO) THEN
        RETURN
    END
    
    R.CUSTOMER = ''
    ST.CustomerService.getRecord(CUSTOMER.NO, R.CUSTOMER)
    RET.VAL  = R.CUSTOMER<ST.CustomerService.CustomerRecord.residence>

RETURN
*** </region>

END
