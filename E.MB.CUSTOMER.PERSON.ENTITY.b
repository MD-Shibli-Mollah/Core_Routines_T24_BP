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
* <Rating>-71</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE E.MB.CUSTOMER.PERSON.ENTITY(ENQ.DATA)
*-----------------------------------------------------------------------------
* This is the nofile enquiry routine attached to STANDARD.SELECTION record
* NOFILE.CUSTOMER.PERSON.ENTITY for the enquiry CUST.PER.ENT.LIST.
* This enquiry is attached to the version record of CUSTOMER.RELATIONSHIP
* table. This enquiry will produce the drop down list for the fields
* ORIG.PARTY.ID and REL.PARTY.ID.
*------------------------------------------------------------------------------
* Modification History
*---------------------
*
* 18/02/2013 - Defect 511499
*              Creation
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*------------------------------------------------------------------------------
    $INSERT I_DAS.CUSTOMER
    $INSERT I_DAS.PERSON.ENTITY
    $INSERT I_CustomerService_NameAddress

    $USING EB.SystemTables
    $USING EB.Reports
    $USING ST.Customer
    $USING EB.DataAccess

    GOSUB INITIALISE
    GOSUB PROCESS

*----------
INITIALISE:
*----------

    FN.PERSON.ENTITY = 'F.PERSON.ENTITY'
    F.PERSON.ENTITY = ''

    LOCATE "ENQ.DATA" IN EB.Reports.getDFields()<1> SETTING PARTY.POS THEN
    E.VALUE = EB.Reports.getDRangeAndValue()<PARTY.POS>
    END

    RETURN.VALUE = ''

    RETURN

*-------
PROCESS:
*-------

    BEGIN CASE

        CASE E.VALUE EQ 'CUSTOMER'
            GOSUB GET.CUSTOMER.LIST

        CASE E.VALUE EQ 'PERSON'
            GOSUB GET.PERSON.LIST

        CASE E.VALUE EQ 'ENTITY'
            GOSUB GET.ENTITY.LIST

    END CASE

    ENQ.DATA<-1> = RETURN.VALUE

    RETURN

*-----------------
GET.CUSTOMER.LIST:
*-----------------

    TABLE.NAME = 'CUSTOMER'
    THE.LIST = DAS.CUSTOMER$SORTED
    THE.ARGS = ''
    TABLE.SUFFIX = ''
    EB.DataAccess.Das(TABLE.NAME,THE.LIST, THE.ARGS,TABLE.SUFFIX)

    LOOP
        REMOVE CUS.ID FROM THE.LIST SETTING POS
    WHILE CUS.ID:POS
        prefLang = EB.SystemTables.getLngg()
        customerNameAddress = ''
        customerKey = CUS.ID
        CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
        RETURN.VALUE<-1> = CUS.ID:'*':customerNameAddress<NameAddress.shortName>
    REPEAT

    RETURN

*---------------
GET.PERSON.LIST:
*---------------

    TABLE.NAME = 'PERSON.ENTITY'
    THE.LIST = dasPersonEntityByPerson
    THE.ARGS = ''
    TABLE.SUFFIX = ''
    EB.DataAccess.Das(TABLE.NAME,THE.LIST, THE.ARGS,TABLE.SUFFIX)
    GOSUB GET.NAME

    RETURN

*---------------
GET.ENTITY.LIST:
*---------------

    TABLE.NAME = 'PERSON.ENTITY'
    THE.LIST = dasPersonEntityByEntity
    THE.ARGS = ''
    TABLE.SUFFIX = ''
    EB.DataAccess.Das(TABLE.NAME,THE.LIST, THE.ARGS,TABLE.SUFFIX)
    GOSUB GET.NAME

    RETURN

*--------
GET.NAME:
*--------

    LOOP
        REMOVE PE.ID FROM THE.LIST SETTING POS
    WHILE PE.ID:POS
        R.PERSON.ENTITY = ''
        R.PERSON.ENTITY = ST.Customer.tablePersonEntity(PE.ID, ERR)
        RETURN.VALUE<-1> = PE.ID:'*':R.PERSON.ENTITY<ST.Customer.PersonEntity.PerEntName,EB.SystemTables.getLngg()>
    REPEAT

    RETURN
*-----------------------------------------------------------------------------
    END
