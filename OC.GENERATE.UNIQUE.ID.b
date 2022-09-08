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

* Version 2 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-71</Rating>
*-----------------------------------------------------------------------------

    $PACKAGE OC.Parameters
    SUBROUTINE OC.GENERATE.UNIQUE.ID(REPORT.TYPE,MODULE.NAME,DEAL.CPARTY,BANK.CPARTY,GENERATING.CPARTY,TRANSACTION.ID ,UNIQUE.ID,Reserved1,Reserved2)
*-----------------------------------------------------------------------------
* Routine to identify the generating party . Called from FOREX routine.
* Incoming parameters
*					REPORT.TYPE = Type of the report
*					MODULE.NAME = Name of the application
*					DEAL.CPARTY = Name of the deal counterparty
*					BANK.CPARTY = Name of the T24 Bank
*					TRANSACTION.ID = Transaction reference of the contract

* Outgoing parameters
*					GENERATING.CPARTY = The party responsible for generating the UTI
*					UNIQUE.ID = Unique transaction identifier
*
* Note : The common variables are loaded from OC.LOAD.COMMON used from FOREX routine.
* In case, this routine is called during COB, the common variables like R.OC.PARAM and R.OC.REGULATOR need to be loaded.
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*-----------------------------------------------------------------------------
* 07/06/06 - EN_923925
*            Swap clearing phase 1 - Unique transaction identifier
*
* 06/03/15 - Defect 1274383 / Task 1274803
*            UTI prefix should hold only 10 characters starting
*            from the 7th character of LEI in OC.PARAMETER
*
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main section>


    $USING OC.Parameters
    $USING ST.CompanyCreation
    $USING EB.SystemTables


    GOSUB INITIALISE
    GOSUB GET.COUNTRY
    GOSUB GET.UNIQUE.ID
    GOSUB GET.GENERATING.CPARTY
    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
INITIALISE:
***


    UTI.PREFIX = ''
    UTI = ''
    COUNTRY = ''
    GEOG.BLOCK = ''

    COMPANY.ID = EB.SystemTables.getIdCompany()

    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get unique id>
GET.UNIQUE.ID:
***
*The Unique Transaction Identifier is formed here
    USI.NAME.SPACE = OC.Parameters.getROcParam()<OC.Parameters.OcParameter.ParamUsiNameSpace>

    IF USI.NAME.SPACE THEN    ;* Assign USI.NAME.SPACE value as the prefix of UTI
        UTI.PREFIX = USI.NAME.SPACE
    END ELSE
        LEI = OC.Parameters.getROcParam()<OC.Parameters.OcParameter.ParamBankLei>
        UTI.PREFIX = LEI[7,10]          ;*Assign 10 characters starting from the 7th character of BANK.LEI as the prefix of UTI
    END

    UTI = UTI.PREFIX:TRANSACTION.ID

    IF (COUNTRY EQ 'EU') OR (GEOG.BLOCK EQ 'EUROPE') THEN ;* For european region, E02 is prefixed to the UTI
        UNIQUE.ID = 'E02':UTI
    END ELSE
        UNIQUE.ID = UTI
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------
***<region name - Get country>
GET.COUNTRY:
***
*Get country and geographical block from OC.REGULATOR
    COUNTRY = OC.Parameters.getROcRegulator()<OC.Parameters.OcRegulator.RegCountry>
    GEOG.BLOCK = OC.Parameters.getROcRegulator()<OC.Parameters.OcRegulator.RegGeographicalBlock>

    RETURN
***</region>
*-------------------------------------------------------------------
***<region name - Get generating cparty)
GET.GENERATING.CPARTY:
***
*Identified the generatin party
    OC.Parameters.IdentifyGenParty(MODULE.NAME , DEAL.CPARTY , BANK.CPARTY , GENERATING.CPARTY,'','')

*In case of the generating party not being the T24 bank, UTI is appended with TEMP
    LEAD.COMPANY = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialCom)
    IF NOT((GENERATING.CPARTY EQ COMPANY.ID) OR (GENERATING.CPARTY EQ LEAD.COMPANY)) THEN ;* If the generating party is not the T24 bank
        UNIQUE.ID = UNIQUE.ID:'TEMP'
    END

    RETURN
***</region>
    END
