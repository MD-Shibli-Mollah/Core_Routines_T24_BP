* @ValidationCode : Mjo1MzY3NDA0MTQ6Q3AxMjUyOjE1ODIwOTg1MTExMTY6c3RhbnVzaHJlZToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAzLjIwMjAwMjEyLTA2NDY6NzY6MTA=
* @ValidationInfo : Timestamp         : 19 Feb 2020 13:18:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 10/76 (13.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.20200212-0646
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-39</Rating>
*-----------------------------------------------------------------------------
$PACKAGE ST.ModelBank

SUBROUTINE E.CU.GET.PREFER.CUS.ADDRESS(ID.LIST)
*
******************************************************************************
*
*   Incoming
*   CUSTOMER.ID - Customer Id
*   ADDRESS.LOCATION - PRIMARY,SECONDARY,..
*   CARRIER.ID - Carrier Id say SWIFT,PRINT,XML,SMS
*
*   Outgoing
*   ID.LIST - Contains records to be displayed in the following format
*             ADDRESS.ID*CARRIER*ADDRESS.
*             The ADDRESS component will be Street address if CARRIER is PRINT,
*             Phone number if carrier is SMS, Email address if it is EMAIL and
*             so on.,
******************************************************************************
*   Modification History
*
*   09/08/10 - Enhancement 43265, Task 43268
*              Customer Services
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 02/05/17 - Enhancement 1765879 / Task 2106068
*            Routine is not processed if DE product is not installed in the current company
*
* 17/09/19 - Enhancement 3357571 / Task 3357573
*            Changes done for Movement of contact preferences to a separate Master Data Module from Delivery
*
******************************************************************************
*
    $INSERT I_DAS.DE.ADDRESS
*
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.DataAccess
    $USING EB.API
    $USING PY.Config

    GOSUB INITIALISE
    IF NOT(EB.Reports.getEnqError()) THEN
        GOSUB PROCESS
    END
*
RETURN
*-----------------------------------------------------------------------------
**** <region name= INITIALISE>
*** <desc>Initialise variables </desc>
*
***********
INITIALISE:
***********
*
    deInstalled = ''
    EB.API.ProductIsInCompany('DE', deInstalled)

    IF NOT(deInstalled) THEN
        EB.Reports.setEnqError('EB-PRODUCT.NOT.INSTALLED')
        RETURN
    END
    
    CARRIER.ID = ''

    LOCATE 'CUSTOMER.ID' IN EB.Reports.getDFields() SETTING CUS.POS THEN
        CUSTOMER.ID = EB.Reports.getDRangeAndValue()<CUS.POS>  ;* get the customer id
    END

    LOCATE 'ADDRESS.LOCATION' IN EB.Reports.getDFields() SETTING ADD.POS THEN
        ADDRESS.LOCATION = EB.Reports.getDRangeAndValue()<ADD.POS>       ;* get the  address location id
    END
*
    LOCATE 'CARRIER.ID' IN EB.Reports.getDFields() SETTING CAR.POS THEN
        CARRIER.ID = EB.Reports.getDRangeAndValue()<CAR.POS>   ;* get the message id
    END

    IF NOT(CARRIER.ID) THEN
        CARRIER.ID = 'PRINT'
    END
*
    R.ADDRESS = ''
    ADDRESS.ID = ''
*
RETURN
*
*** </region>
*
********
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Main Processing </desc>
*
********
PROCESS:
********
*
    ADD.ID = EB.SystemTables.getIdCompany():'.C-':CUSTOMER.ID:'.':CARRIER.ID
    THE.LIST = DAS.DE.ADDRESS$ADDRLOCATE
    THE.ARGS = ADD.ID:'...':@FM:ADDRESS.LOCATION
    TABLE.SUFFIX = ''
    DE.ADD.LIST = ''
    YSEL = 0
    EB.DataAccess.Das("DE.ADDRESS",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    DE.ADD.LIST = THE.LIST
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
        EB.Reports.setEnqError('ADDRESS RECORD NOT FOUND FOR THIS CUSTOMER/CARRIER')
        RETURN
    END
*
    ADDRESS.ID = DE.ADD.LIST<1>
    tmp.ENQ.ERROR = EB.Reports.getEnqError()
    R.ADDRESS = PY.Config.tableAddress(ADDRESS.ID,tmp.ENQ.ERROR)
    EB.Reports.setEnqError(tmp.ENQ.ERROR)
    IF EB.Reports.getEnqError() THEN
        RETURN
    END

    BEGIN CASE

        CASE CARRIER.ID EQ 'PRINT'
            FOR I = PY.Config.Address.AddBranchnameTitle TO PY.Config.Address.AddCountry
                IF R.ADDRESS<I> THEN
                    FLD.CNT +=1
                    ADDRESS<1,FLD.CNT> = R.ADDRESS<I>
                END
            NEXT I

        CASE CARRIER.ID EQ 'SWIFT' OR CARRIER.ID EQ 'TELEX'
            ADDRESS = R.ADDRESS<PY.Config.Address.AddDeliveryAddress>

        CASE CARRIER.ID EQ 'EMAIL'
            ADDRESS = R.ADDRESS<PY.Config.Address.AddEmail1>

        CASE CARRIER.ID EQ 'SMS'
            ADDRESS = R.ADDRESS<PY.Config.Address.AddSms1>

        CASE 1
            ADDRESS = R.ADDRESS<PY.Config.Address.AddBranchnameTitle>

    END CASE

    ID.LIST<-1> = ADDRESS.ID:'*':CARRIER.ID:'*':ADDRESS
*
RETURN
*
*** </region>
*
*-----------------------------------------------------------------------------
END
