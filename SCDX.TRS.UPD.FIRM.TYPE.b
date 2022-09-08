* @ValidationCode : MjoxMDU2MjExMjk2OkNwMTI1MjoxNjEwNDI3MjI1NzI2OnJkZWVwaWdhOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMjgtMDYzMDo0MTozOQ==
* @ValidationInfo : Timestamp         : 12 Jan 2021 10:23:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 39/41 (95.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.FIRM.TYPE(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine returns the execution within Firm type based on value inputted in the Transaction
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
* RET.VAL  -  Execution within Firm type
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
    $USING SC.ScoFoundation
    $USING EB.Delivery
    $USING SC.Config
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to fetch the execution within Firm type
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

    RET.VAL = ''
    
* Check if EW is installed
    EW.INSTALLED = ''
    EB.Delivery.ValProduct("EW","","",EW.INSTALLED,"")
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to fetch execution within Firm type </desc>

    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
* If EW is installed, then fetch the value from Local reference field,
* Else, refer the value from the core field
            IF EW.INSTALLED THEN
                LOC.FLD.POSN = ''
                SC.ScoFoundation.GetLocRef("SEC.TRADE","TAP.INSTR.MKR",LOC.FLD.POSN)
                IF LOC.FLD.POSN THEN
                    INSTRUCTION.MKR    = TXN.REC<SC.SctTrading.SecTrade.SbsLocalRef,LOC.FLD.POSN>
                END
            END ELSE
                INSTRUCTION.MKR    = TXN.DATA
            END
        
        CASE TXN.ID[1,5] EQ "DXTRA"
            INSTRUCTION.MKR    = TXN.DATA
    END CASE

    GOSUB GET.FIRM.ID.TYPE ; *Based on Firm code that will be reported, determine the ID.TYPE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.FIRM.ID.TYPE>
GET.FIRM.ID.TYPE:
*** <desc>Based on Firm code that will be reported, determine the ID.TYPE </desc>

    CUSTOMER.NO = INSTRUCTION.MKR
    IF INSTRUCTION.MKR[1,2] MATCHES 'N-':@VM:'L-' THEN
        CUSTOMER.NO = FIELD(INSTRUCTION.MKR,'-',2)
    END
    
    LEI.NCI = ''
    SC.SctTrading.ScdxTrsUpdFirmCode(TXN.ID,TXN.REC,TXN.DATA,LEI.NCI)
    SC.Config.GetLeiNciIdType(CUSTOMER.NO, LEI.NCI, ID.TYPE)
    BEGIN CASE
        CASE ID.TYPE EQ 'NIDN'
            RET.VAL = 1
        CASE ID.TYPE EQ 'NORE'
            RET.VAL = 3
        CASE ID.TYPE EQ 'CCPT'
            RET.VAL = 4
        CASE ID.TYPE EQ 'CONCAT'
            RET.VAL = 5
    END CASE
    
RETURN
*** </region>
END
