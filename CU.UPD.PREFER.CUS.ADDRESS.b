* @ValidationCode : MjotMTA4ODc5MzA3OTpDcDEyNTI6MTU3MDc3MjkwNjM1NzprYWphYXlzaGVyZWVuOjI6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA5LjIwMTkwODIzLTAzMDU6NjM6NDY=
* @ValidationInfo : Timestamp         : 11 Oct 2019 11:18:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kajaayshereen
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 46/63 (73.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201909.20190823-0305
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
$PACKAGE ST.Customer
SUBROUTINE CU.UPD.PREFER.CUS.ADDRESS(CUSTOMER.ID, ADDRESS.LOCATION, CARRIER.ID, R.DE.ADDRESS, RET.ADDRESS.ID, ER)
*
******************************************************************************
*
*   Incoming
*   CUSTOMER.ID - Customer Id
*   ADDRESS.LOCATION - DE.MESSAGE Id
*   CARRIER.ID - Carrier Id say SWIFT,PRINT,XML,SMS
*   R.DE.ADDRESS - Full address to be updated
*
*   Outgoing
*   RET.ADDRESS.ID - Return DE.ADDRESS Id
*   ER - Error if any
*
******************************************************************************
*   Modification History
*
*   09/08/10 - Enhancement 43265, Task 43268
*              Customer Services
*
*   02/05/17 - Enhancement 1765879 / Task 2118235
*              Removal of dependency on non-core products
*
* 11/10/19 - Enhancement 2822520 / Task 3380737
*            Code changed done for componentisation and to avoid errors while compilation
*            using strict compile
******************************************************************************
*

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.COMMON
    $INSERT I_DAS.DE.ADDRESS
*
* Changes for dependency removal of ST on non-core products
    isDeInstalled = ''
    CALL Product.isInCompany("DE", isDeInstalled)
    IF NOT(isDeInstalled) THEN ;* Check if DE installed in company
        RETURN
    END
* Process only when DE installed since writes customer address to DE.ADDRESS file.
    
    GOSUB INITIALISE
    IF NOT(ER) THEN
        GOSUB PROCESS
    END
*
RETURN
**** <region name= INITIALISE>
*** <desc>Initialisation of variables </desc>
*
***********
INITIALISE:
***********
*
    IF NOT(CUSTOMER.ID) THEN
        ER = 'CUSTOMER NOT SUPPLIED'
        RETURN
    END
*
    IF NOT(ADDRESS.LOCATION) THEN
        ER = 'ADDRESS LOCATION NOT FOUND'
    END
*
    IF NOT(CARRIER.ID) THEN
        CARRIER.ID = 'PRINT'
    END
*
    RET.ADDRESS.ID = ''
*
    F.DE.ADDRESS = ''
    FN.DE.ADDRESS = 'F.DE.ADDRESS'
    CALL OPF(FN.DE.ADDRESS,F.DE.ADDRESS)
*
RETURN
*
*** </region>
*
**** <region name= PROCESS>
*** <desc>Main process </desc>
*
********
PROCESS:
********
*
    ADD.ID = ID.COMPANY:'.C-':CUSTOMER.ID:'.':CARRIER.ID
    THE.LIST = DAS.DE.ADDRESS$ADDRLOCATE
    THE.ARGS = ADD.ID:'...':@FM:ADDRESS.LOCATION
    TABLE.SUFFIX = ''
    DE.ADD.LIST = ''
    CALL DAS("DE.ADDRESS",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    DE.ADD.LIST = THE.LIST
*
    DE.ADD.CNT = DCOUNT(DE.ADD.LIST,@FM)
*
    FOR BUB.CNT = 1 TO DE.ADD.CNT-1
        FOR NXT.BUB.CNT = BUB.CNT+1 TO DE.ADD.CNT
            IF FIELD(DE.ADD.LIST<BUB.CNT>,'.',4) GT FIELD(DE.ADD.LIST<NXT.BUB.CNT>,'.',4) THEN
                TEMP.DE.ADD = DE.ADD.LIST<BUB.CNT>
                DE.ADD.LIST<BUB.CNT> = DE.ADD.LIST<NXT.BUB.CNT>
                DE.ADD.LIST<NXT.BUB.CNT> = TEMP.DE.ADD
            END
        NEXT NXT.BUB.CNT
    NEXT BUB.CNT
*
    IF NOT(DE.ADD.LIST) THEN
        ER = 'ADDRESS RECORD NOT FOUND FOR THIS CUSTOMER/CARRIER'
        RETURN
    END
*
    IF FIELD(DE.ADD.LIST<1>,'.',4,2) EQ 'PRINT' THEN
        RET.ADDRESS.ID = DE.ADD.LIST<2>
    END ELSE
        RET.ADDRESS.ID = DE.ADD.LIST<1>
    END
*
    IF NOT(RET.ADDRESS.ID) THEN
        ER = 'ADDRESS RECORD NOT FOUND FOR THIS CUSTOMER/CARRIER'
    END
*
    IF RET.ADDRESS.ID AND R.DE.ADDRESS THEN
        CALL F.WRITE(FN.DE.ADDRESS, RET.ADDRESS.ID, R.DE.ADDRESS)
    END
*
RETURN
*
*** </region>
*
END
