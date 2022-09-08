* @ValidationCode : MjoxMTkwODI2MzE5OkNwMTI1MjoxNTM5MDc0MTkxMDIyOnZrcmlzaG5hcHJpeWE6MzowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTAuMjAxODA5MjEtMTEzMDoyNjoyNg==
* @ValidationInfo : Timestamp         : 09 Oct 2018 14:06:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vkrishnapriya
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 26/26 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180921-1130
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PV.Config
SUBROUTINE PV.GET.RISK.SEGMENT(APP.NAME,CONTRACT.ID,CUSTOMER.ID,CONTRACT.DETAILS,RETURN.SEGMENT,SEGMENT.ERROR)
*-----------------------------------------------------------------------------
*
* In Parameters:
*---------------
* APP.NAME          - Holds the Application name
* CONTRACT.ID       - Holds the Contract ID
* CUSTOMER.ID       - Holds the Customer ID
* CONTRACT.DETAILS  - Holds the record of the CONTRACT.ID
*
* Out Parameters:
*---------------
* RETURN.SEGMENT    - Holds the derived RISK.SEGMENT
* SEGMENT.ERROR     - Holds error message if RISK.SEGMENT is not derived
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*   28/09/18    - ENHANCEMENT 2785691 / TASK 2785816
*                 New API to return the RISK.SEGMENT that is specified in the local ref field.
*                 If RISK.SEGMENT is not specified at the contract level , then the RISK.SEGMENT is derived from the customer record.
*
*-----------------------------------------------------------------------------

    $USING EB.Mandate
    $USING ST.CustomerService

    GOSUB INITIALISE                                                    ; *Intialise the Segment details
    GOSUB CALL.GET.TABLE.FIELD.POSITION                                 ; *To get the field position of the local ref field 'RISK.SEGMENT' attached at contract level
    RETURN.SEGMENT = CONTRACT.DETAILS<LOCAL.REF.POS,RISK.SEGMENT.POS>   ; *Return the RISK.SEGMENT that is attached at the contract
    IF NOT(RETURN.SEGMENT) THEN                                         ; *Derive the RISK.SEGMENT from the customer record if not specified at the contract level
        TEMP.APPLICATION = 'CUSTOMER'
        CUSTOMER.REC = ''
        CUST.ERR = ''
        ST.CustomerService.getRecord(CUSTOMER.ID, CUSTOMER.REC)         ; *Read the Customer record
        GOSUB CALL.GET.TABLE.FIELD.POSITION                             ; *To get the field position of the local ref field 'RISK.SEGMENT' attached at customer level
        RETURN.SEGMENT = CUSTOMER.REC<LOCAL.REF.POS,RISK.SEGMENT.POS>   ; *Return the RISK.SEGMENT that is attached at the customer record
        IF NOT(RETURN.SEGMENT) THEN
            SEGMENT.ERROR = 'SEGMENT NOT DEFINED'                       ; *Set the error message in SEGMENT.ERROR , if RISK.SEGMENT is not specified
        END
    END

RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Intialise the Segment details </desc>

    RETURN.SEGMENT = ''
    SEGMENT.ERROR = ''
    TEMP.APPLICATION = APP.NAME

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CALL.GET.TABLE.FIELD.POSITION>
CALL.GET.TABLE.FIELD.POSITION:
*** <desc>To get the field position of the local ref field 'RISK.SEGMENT' </desc>

    FIELD.NAME = 'SEGMENT'
    IS.LOCAL.REF = ''
    FIELD.POSITION = ''
    EB.Mandate.GetTableFieldPosition(TEMP.APPLICATION, FIELD.NAME, IS.LOCAL.REF, FIELD.POSITION, '', '') ;* call the api to get the field position of the local ref field
    LOCAL.REF.POS = FIELD.POSITION<1>                                   ; *FIELD.POSITION<1> holds the starting position of local ref fields
    RISK.SEGMENT.POS = FIELD.POSITION<2>                                ; *FIELD.POSITION<2> holds the position of RISK.SEGMENT
    
RETURN
*** </region>

END
