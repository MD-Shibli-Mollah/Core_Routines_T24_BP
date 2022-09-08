* @ValidationCode : MjoxODQxNjA4MjAxOkNwMTI1MjoxNjEwMzk3NzIyMzExOnJkZWVwaWdhOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMjgtMDYzMDo1OTo1OA==
* @ValidationInfo : Timestamp         : 12 Jan 2021 02:12:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 58/59 (98.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.FIRM.CODE(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine returns the National Id for the defined investment firm for
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
* RET.VAL  -  National Id for the defined investment firm
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
    $USING ST.CompanyCreation
    $USING EB.SystemTables
    $USING SC.ScoFoundation
    $USING DX.Trade
    $USING ST.CustomerService
    $USING ST.Customer
    $USING EB.Delivery
    $USING SC.Config
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to fetch National Id for the defined investment firm
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

    RET.VAL = ''
    CUSTOMER.NO = ''
    INSTRUCTION.MKR = ''
* Check if EW is installed
    EW.INSTALLED = ''
    EB.Delivery.ValProduct("EW","","",EW.INSTALLED,"")

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc>Process to fetch country of the branch of the investment firm</desc>

    GOSUB GET.CUSTOMER.NO ; *Get the customer no for which the National id needs to be retrieved
    GOSUB GET.NATIONAL.ID ; *Get the National Id for the defined investment firm

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.CUSTOMER.NO>
GET.CUSTOMER.NO:
*** <desc>Get the customer no for which the National id needs to be retrieved </desc>
    
    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
* If EW is installed, then fetch the value from Local reference field,
* Else, refer the value from the core field
            IF EW.INSTALLED THEN
                LOC.FLD.POSN = ''
                SC.ScoFoundation.GetLocRef("SEC.TRADE","TAP.ORDER.INIT",LOC.FLD.POSN)
                IF LOC.FLD.POSN AND TXN.REC<SC.SctTrading.SecTrade.SbsLocalRef,LOC.FLD.POSN> EQ 'BANK' THEN ;* Do when the Local reference field TAP.ORDER.INIT is found
                    LOC.FLD.POSN = ''
                    SC.ScoFoundation.GetLocRef("SEC.TRADE","TAP.INSTR.MKR",LOC.FLD.POSN)
                    IF LOC.FLD.POSN THEN ;* Do when the Local reference field TAP.INSTR.MKR is found
                        CUSTOMER.NO    = TXN.REC<SC.SctTrading.SecTrade.SbsLocalRef,LOC.FLD.POSN>
                    END
                END
            END
        
        CASE TXN.ID[1,5] EQ "DXTRA"
            CUSTOMER.NO    = TXN.DATA
    END CASE

* When the value is mentioned in the format L/N-CustomerNo-LEI/NCI code, fetch the customer from the second part    
    IF CUSTOMER.NO[1,2] MATCHES 'N-':@VM:'L-' THEN
        INSTRUCTION.MKR = CUSTOMER.NO           ;* Store the original Value 
        CUSTOMER.NO = FIELD(CUSTOMER.NO,'-',2)  ;* Get the customer no
    END
    

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.NATIONAL.ID>
GET.NATIONAL.ID:
*** <desc>Get the National Id for the defined investment firm </desc>

    IF NOT(CUSTOMER.NO) THEN
        RETURN
    END

* When the National Id is directly mentioned in the field Instruction Maker, then directly fetch them
    IF INSTRUCTION.MKR[1,2] EQ 'N-' AND FIELD(INSTRUCTION.MKR,'-',3) THEN
        RET.VAL = FIELD(INSTRUCTION.MKR,'-',3)
        RETURN
    END

* Pass the customer number to arrive at the NCI.CODE based on SC.NCI.PRIORITY & SC.NCI.PARAMETER setups
    LEI.NCI = ''
    SC.Config.GetCusLeiNci(CUSTOMER.NO, LEI.NCI)
    IF LEI.NCI[1,2] EQ 'N-' THEN
        RET.VAL = FIELD(LEI.NCI,'-',3)
        RETURN
    END
    
* Fetch the National id from the OC.CUSTOMER record
    OC.CUS.ERR = ''
    OC.CUSTOMER.REC = ST.Customer.OcCustomer.CacheRead(CUSTOMER.NO, OC.CUS.ERR)
    RET.VAL = OC.CUSTOMER.REC<ST.Customer.OcCustomer.CusNationalId>
    
    IF RET.VAL THEN
        RETURN ;* National Id retreived, hence ignore the below process
    END

* Fetch the National id from the Customer record
    R.CUSTOMER = ''
    ST.CustomerService.getRecord(CUSTOMER.NO, R.CUSTOMER)
    LEGAL.DOC.NAME  = R.CUSTOMER<ST.CustomerService.CustomerRecord.legalDocName>
    LOCATE 'NATIONAL.ID' IN LEGAL.DOC.NAME<1,1> SETTING POS THEN
        RET.VAL     = R.CUSTOMER<ST.CustomerService.CustomerRecord.legalId, POS>
    END

RETURN
*** </region>
END
