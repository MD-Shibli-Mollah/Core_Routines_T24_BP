* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-88</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE USCORE.Foundation
    SUBROUTINE USCORE.AA.CUST.NAME.DETAILS
*-----------------------------------------------------------------------------
* Description   : This routine is conversion routine which call the generic
*                 routine to get account title
* Type          : Conversion Routine
* Linked With   : ENQUIRY>AA.DETAILS.ARRANGEMENT.AR.USCORE
* In Parameter  : O.DATA
* Out Parameter : O.DATA
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 20-JAN-2015   -  Defect 1223562
*                  Account Title need to be displayed in owner in Arrangement
*                  overview screen for Accounts
*
* 09/09/15 -       Task : 1447056
*                  Enhancement : 1434821
*                  Get the list of OWNERS from the CUSTOMER field.
*
*07-MAR-2016 - Enhancement - 1504339
*            - Task - 1655931
*            - US Feature Encapsulation
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Reports
    $USING AA.Framework
    $USING AA.Customer
    $USING ST.Customer
    $USING DE.Config
    $USING ST.Config
    $USING EB.Updates
    $USING USCORE.Foundation
    
    
    GOSUB INITIALISE
    GOSUB ADDR.COUNT
    GOSUB PROCESS
    RETURN

*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initalising the fiels variables and the local reference fields variables</desc>
*-----------------------------------------------------------------------------

    PROPERTY.CLASS = 'CUSTOMER'
    OUT.VALUE = ''

    LREF.APP = 'CUSTOMER'
    LREF.FIELDS = "MIDDLE.NAME":@VM:"CITY":@VM:"ZIP4"
    LREF.POS = ""
    EB.Updates.MultiGetLocRef(LREF.APP, LREF.FIELDS, LREF.POS)
    MIDDLE.NAME.POS =  LREF.POS<1,1>
    CITY.POS = LREF.POS<1,2>
    ZIP.POS = LREF.POS<1,3>

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*-------------------------------------------------------------------------
*** <region name= ADDR.COUNT>
ADDR.COUNT:
*** <desc> Process to get the count of address lines
* </desc>
*-------------------------------------------------------------------------

    Y.ARR.ID = EB.Reports.getOData()
    RETURNCONDS = ''
    AA.Framework.GetArrangementConditions(Y.ARR.ID, PROPERTY.CLASS, "","",RETURNED,RETURNCONDS,RETURNERR)
    AA.Customer.GetArrangementCustomer(ARRANGEMENT.ID, "", "", "", "", GL.CUSTOMER, RET.ERROR)
    
    RETURNCONDS = RAISE(RETURNCONDS)
    Y.CUST.ID = GL.CUSTOMER
    Y.OWNER = RETURNCONDS<AA.Customer.Customer.CusCustomer> ;* CR 16
    Y.OTHER.PARTY = RETURNCONDS<AA.Customer.Customer.CusOtherParty>
    Y.OWNER.CNT = DCOUNT(Y.OWNER,@VM)

    R.CUSTOMER = ST.Customer.Customer.Read(Y.CUST.ID, CUST.ERR)

    IF R.CUSTOMER THEN
        Y.SECTOR = R.CUSTOMER<ST.Customer.Customer.EbCusSector>
        IF Y.SECTOR GE '1000' AND Y.SECTOR LE '1999' THEN
            GOSUB ADDRESS.DETAILS
        END ELSE
            GOSUB CORP.PROCESS
        END

    END

    RETURN
*** </region>
*-------------------------------------------------------------------------

*-------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc>Process to get the value from generic routine and truncate the
* address part from fetched value.</desc>
*-------------------------------------------------------------------------

    Y.PR = ''

* Call to generic routine to get account title routine
    USCORE.Foundation.AaAcctTitling(Y.ARR.ID,Y.PR,Y.OUT)

* To display the fetched values as multivalued in the enquiry
    CHANGE @VM TO @FM IN Y.OUT
    Y.TOT.COUNT = DCOUNT(Y.OUT,@FM)

* To remove the address part from the fetched value Y.OUT
    EB.Reports.setVmCount(Y.TOT.COUNT - ADDR.CNT)
    VC = EB.Reports.getVc()
    O.DATA = Y.OUT<VC>
    EB.Reports.setOData(O.DATA)

    RETURN
*** </region
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
*** <region name= CORP.PROCESS>
CORP.PROCESS:
*** <desc>Process to get the corporate customer name if he belongs to corpoprate process</desc>
*-----------------------------------------------------------------------------

    IF Y.OTHER.PARTY EQ '' THEN
        GOSUB ADDRESS.DETAILS
    END
    IF Y.OTHER.PARTY THEN
        LOOP
            REMOVE Y.CUSTOMER FROM Y.OTHER.PARTY SETTING Y.POS
        WHILE Y.CUSTOMER:Y.POS
            R.CUSTOMER = ''
            R.CUSTOMER = ST.Customer.Customer.Read(Y.CUSTOMER, CUST.ERR)

            GOSUB ADDRESS.DETAILS

        REPEAT
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
*** <region name= ADDRESS.DETAILS>
ADDRESS.DETAILS:
*** <desc></desc>
*-----------------------------------------------------------------------------

    Y.STREET = R.CUSTOMER<ST.Customer.Customer.EbCusStreet>
    Y.TOWN.COUNTRY = R.CUSTOMER<ST.Customer.Customer.EbCusTownCountry>
    Y.CITY = R.CUSTOMER<ST.Customer.Customer.EbCusLocalRef,CITY.POS>
    Y.POST.CODE = R.CUSTOMER<ST.Customer.Customer.EbCusPostCode>
    Y.ZIP = R.CUSTOMER<ST.Customer.Customer.EbCusLocalRef,ZIP.POS>
    Y.NATIONALITY = R.CUSTOMER<ST.Customer.Customer.EbCusNationality>

    BEGIN CASE

    CASE (Y.NATIONALITY NE 'US') AND (Y.STREET NE '') AND (Y.TOWN.COUNTRY NE '')

        GOSUB COUNTRY.NAME
        CITY.LINE = Y.CITY:' ':Y.POST.CODE:' ':Y.ZIP
        ADDRESS.ARRAY = Y.STREET:@VM:Y.TOWN.COUNTRY:@VM:CITY.LINE:@VM:COUNTRY.NAME

    CASE (Y.STREET EQ '') AND (Y.TOWN.COUNTRY NE '') AND (Y.NATIONALITY NE 'US')

        GOSUB COUNTRY.NAME
        CITY.LINE = Y.CITY:' ':Y.POST.CODE:' ':Y.ZIP
        ADDRESS.ARRAY = Y.TOWN.COUNTRY:@VM:CITY.LINE:@VM:COUNTRY.NAME

    CASE (Y.TOWN.COUNTRY EQ '') AND (Y.STREET NE '') AND (Y.NATIONALITY NE 'US')

        GOSUB COUNTRY.NAME
        CITY.LINE = Y.CITY:' ':Y.POST.CODE:' ':Y.ZIP
        ADDRESS.ARRAY = Y.STREET:@VM:CITY.LINE:@VM:COUNTRY.NAME

    CASE Y.NATIONALITY EQ 'US'
        CITY.LINE = Y.CITY:' ':Y.POST.CODE:' ':Y.ZIP
        ADDRESS.ARRAY = Y.STREET:@VM:Y.TOWN.COUNTRY:@VM:CITY.LINE

    END CASE

    ADDR.CNT = DCOUNT(ADDRESS.ARRAY,@VM)

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
COUNTRY.NAME:
*-----------------------------------------------------------------------------
    R.COUNTRY = ''
   
    R.COUNTRY = ST.Config.Country.Read(Y.NATIONALITY,COUNT.ERR)
    IF R.COUNTRY THEN
        COUNTRY.NAME = R.COUNTRY<ST.Config.Country.EbCouCountryName,1>
    END

    RETURN
*-----------------------------------------------------------------------------

END
*-----------------------------------------------------------------------------


