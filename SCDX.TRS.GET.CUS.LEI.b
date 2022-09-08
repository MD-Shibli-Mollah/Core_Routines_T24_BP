* @ValidationCode : MjotOTk1NDk4ODQwOkNwMTI1MjoxNjEwMzg3MTA0OTQwOnJkZWVwaWdhOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMjgtMDYzMDoxNDoxNA==
* @ValidationInfo : Timestamp         : 11 Jan 2021 23:15:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 14/14 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.GET.CUS.LEI(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine returns the LEI of the Customer mentioned in TXN.DATA for updation
* in SCDX.ARM.MIFID.DATA for reporting purpose
* LEI will be determined in the below priority:
* 1) Legal Entity Id, if mentioned in OC.CUSTOMER
* 2) Legal Id, if mentioned in CUSTOMER where LEGAL.DOC.NAME is LEI
*
* Incoming parameters:
**********************
* TXN.ID   -   Transaction ID of the contract.
* TXN.REC  -   A dynamic array holding the contract.
* TXN.DATA -   Data passed based on setup done in TX.TXN.BASE.MAPPING
*
* Outgoing parameters:
**********************
* RET.VAL  -  LEI of the Customer passed in TXN.DATA
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

    $USING ST.CustomerService
    $USING ST.CompanyCreation
    $USING ST.Customer
    $USING SC.Config
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE        ; *Initialise the variables required for processing
    GOSUB PROCESS           ; *Process to return the LEI of the Customer
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

    RET.VAL = ''
    CUSTOMER.NO = TXN.DATA
         
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc>Process to return the LEI of Customer for reporting purpose </desc>

    GOSUB GET.CUS.LEI   ; *Get the LEI defined for the Customer either from the OC.CUSTOMER or CUSTOMER record

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.CUS.LEI>
GET.CUS.LEI:
*** <desc>Get the LEI defined for the Customer either from the OC.CUSTOMER or CUSTOMER record </desc>
    
    IF NOT(CUSTOMER.NO) THEN
        RETURN
    END

* Fetch the LEI/NCI code for the customer
    SC.Config.GetCusLeiNci(CUSTOMER.NO, LEI.NCI)
    RET.VAL = FIELD(LEI.NCI,'-',3)

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
