* @ValidationCode : MjotOTkwMjMxNzYxOkNwMTI1MjoxNTQxNzYwNjc3Mzg3OmhhcnJzaGVldHRncjoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODEwLjIwMTgwOTA2LTAyMzI6Njk6NTQ=
* @ValidationInfo : Timestamp         : 09 Nov 2018 16:21:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 54/69 (78.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180906-0232
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 2 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-105</Rating>
*-----------------------------------------------------------------------------

$PACKAGE OC.Parameters
SUBROUTINE OC.IDENTIFY.GEN.PARTY( MODULE.NAME , DEAL.CPARTY , BANK.CPARTY , GENERATING.CPARTY , Reserved1 , Reserved2)
*-----------------------------------------------------------------------------
* Routine to identify the generating party.This routine is called from OC.GENERATE.UNIQUE.ID
* Incoming parameters
*                       MODULE.NAME - Contains the application name
*                       DEAL.CPARTY - The deal counterparty
*                       BANK.CPARTY - The T24 bank
* Outgoing parameters
*                       GENERATING.CPARTY - The generating party that generates the UTI value
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*-----------------------------------------------------------------------------
* 07/06/06 - EN_923925
*            Swap clearing phase 1 - Unique transaction identifier
*
* 30/12/15 - EN_1226121 / Task 1568411
*            Incorporation of the routine
*
* 15/02/16 - EN 1573781 / Task 1630758
*            OC Valid Unit Test Failures
*
* 08/10/18 - Enh 2789746 / Task 2789749
*            Changing OC.Parameters to ST.Customer to access OC.CUSTOMER
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main section>


    $USING EB.SystemTables
    $USING EB.API
    $USING OC.Parameters
    $USING ST.CompanyCreation
    $USING EB.DataAccess
    $USING ST.Customer

    GOSUB INITIALISE
    GOSUB GET.GEN.CPARTY

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
INITIALISE:
***

    R.OC.CUSTOMER = ''
    REG.ID = ''
    COUNTRY = ''
    GEOG.BLOCK = ''

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get gen cparty>
GET.GEN.CPARTY:
***
* Read OC.CUSTOMER of the deal cparty
*

    R.OC.CUSTOMER = ST.Customer.OcCustomer.Read(DEAL.CPARTY, ERR1)
* Before incorporation : CALL F.READ('F.OC.CUSTOMER',DEAL.CPARTY,R.OC.CUSTOMER,tmp.F.OC.CUSTOMER,ERR1)


    IF NOT (ERR1) THEN
        REPORTING.CUSTOMER = R.OC.CUSTOMER<ST.Customer.OcCustomer.CusReportingCustomer>

* If reporting customer is 'YES' for a deal counter party , then deal counterparty is the generating counter party

        IF REPORTING.CUSTOMER EQ 'YES' THEN
            GENERATING.CPARTY = DEAL.CPARTY

        END ELSE
            GOSUB GET.REG.CLASSIFICATION
        END
    END

RETURN
*** </region>
*-------------------------------------------------------------------------------
*** <region name= Get Reg Classification>
GET.REG.CLASSIFICATION:
***

    REG.ID = OC.Parameters.getROcParam()<OC.Parameters.OcParameter.ParamRegulator>
    COUNTRY = OC.Parameters.getROcRegulator()<OC.Parameters.OcRegulator.RegCountry>
    GEOG.BLOCK = OC.Parameters.getROcRegulator()<OC.Parameters.OcRegulator.RegGeographicalBlock>

    GOSUB REGULATION

RETURN

***</REGION>
*----------------------------------------------------------------------------------
*** <region name= Regulation>
REGULATION:
***

    OC.CUS.ID = DEAL.CPARTY
    GOSUB GET.OC.CUSTOMER
    DCP.REG.CLASS = R.OC.CUS<ST.Customer.OcCustomer.CusRegulatoryClass>
    VAL.REG.CLASS = DCP.REG.CLASS
    PRIORITY = ''

    GOSUB GET.PRIORITY

    DCP.PRIORITY = PRIORITY   ;* Priority of the deal counterparty

    BCP.REG.CLASS = OC.Parameters.getROcParam()<OC.Parameters.OcParameter.ParamRegulatoryClass>
    VAL.REG.CLASS = BCP.REG.CLASS
    PRIORITY = ''

    GOSUB GET.PRIORITY

    BCP.PRIORITY = PRIORITY   ;* Priority of the bank counterparty

    BEGIN CASE

        CASE (DCP.PRIORITY EQ BCP.PRIORITY)
            OC.Parameters.GenPartyFromAppl( MODULE.NAME,DEAL.CPARTY,BANK.CPARTY,GENERATING.CPARTY,'','')

* When deal counterparty takes the highest priority, it is assigned as the generating party to generate the UTI
        CASE (DCP.PRIORITY LT BCP.PRIORITY)
            GENERATING.CPARTY = DEAL.CPARTY

* When bank counterparty takes the highest priority, it is assigned as the generating party to generate the UTI
        CASE 1
            GENERATING.CPARTY = BANK.CPARTY

    END CASE

RETURN

***</REGION>
*----------------------------------------------------------------------------------
*** <region name= GET.OC.CUSTOMER>
GET.OC.CUSTOMER:
***

    R.OC.CUS = ST.Customer.OcCustomer.Read(OC.CUS.ID, ERR6)
* Before incorporation : CALL F.READ('F.OC.CUSTOMER',OC.CUS.ID,R.OC.CUS,tmp.F.OC.CUSTOMER,ERR6)

RETURN
***</REGION>
*----------------------------------------------------------------------------------
*** <region name= GET.PRIORITY>
GET.PRIORITY:
***
    BEGIN CASE

        CASE COUNTRY EQ 'US' OR GEOG.BLOCK EQ 'AMERICA'
            GOSUB DODD.FRANK.PRIORITY

        CASE COUNTRY EQ 'EU' OR GEOG.BLOCK EQ 'EUROPE'
            GOSUB EMIR.PRIORITY

    END CASE

RETURN

***</REGION>
*----------------------------------------------------------------------------------
*** <region name= DODD.FRANK.PRIORITY>
DODD.FRANK.PRIORITY:
***
    BEGIN CASE

        CASE VAL.REG.CLASS EQ 'SWAP.DEALER'
            PRIORITY = 1

        CASE VAL.REG.CLASS EQ 'MAJOR.SWAP.PARTICIPANT'
            PRIORITY = 2

    END CASE

RETURN
*------------------------------------------------------------
*** <region name= EMIR.PRIORITY>
EMIR.PRIORITY:
***
    BEGIN CASE

        CASE VAL.REG.CLASS EQ 'FINANCIAL.COUNTERPARTY'
            PRIORITY = 1

        CASE VAL.REG.CLASS EQ 'NON-FINANCIAL.COUNTERPARTY+'
            PRIORITY = 2

        CASE VAL.REG.CLASS EQ 'NON-FINANCIAL.COUNTERPARTY-'
            PRIORITY = 3

    END CASE

RETURN
END
