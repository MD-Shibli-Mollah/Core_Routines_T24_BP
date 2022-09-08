* @ValidationCode : MjoxNDk3NzQ5ODYyOmNwMTI1MjoxNDg0NzQwMzQ0MTUxOnJjb3JieTotMTotMTotMjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMjAtMDIyMTotMTotMQ==
* @ValidationInfo : Timestamp         : 18 Jan 2017 11:52:24
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : rcorby
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -20
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201612.20161120-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 2 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LI.Config
    SUBROUTINE LI.OVE.SECTORT(OVERRIDE,VARIABLES,SECTOR)
*
*     LIMIT/OVERDRAFT OVERRIDE SECTOR
*     ===============================
*
*     Customer sector code for limit & overdraft override messages.
*
*     OVERRIDE  = override text
*     VARIABLES = override variables
*     SECTOR    = (in) not used
*                 (out) sector
*
****************************************************************************************
* Modificatoin History
* ********************
*
* 26/09/08 - CI_10057958
*            ACCOUNT.ID is fetched correctly from the variable VARIABLES,
*            word OVERDARFT changed to lower case so that it matches with
*            override message given in OVERRIDE.CLASS.
*
* 14/09/10 - Task 76280
*            Change the reads to Customer to use the Customer
*            Service api calls
* 
****************************************************************************************

    $USING AC.AccountOpening
    $USING LI.Config
    $USING EB.SystemTables
    $INSERT I_CustomerService_Profile

*
    ACCOUNT=''
    ER=''
*
*=====MAIN CONTROL========================================================
*
    SECTOR=''
    BEGIN CASE
        CASE OVERRIDE MATCHES '..."overdraft"...'
            ACCOUNT.ID=VARIABLES<1,3>
            GOSUB ACCOUNT
        CASE OVERRIDE MATCHES '..."EXCESS"...'
            CUSTOMER.ID=FIELD(VARIABLES<1,COUNT(VARIABLES,@VM)+1>,'.',1)          ; * 3rd or 4th depending on exact text
            GOSUB CUSTOMER
    END CASE
    RETURN
*
*-----ACCOUNT------------------------------------------------------------
*
ACCOUNT:

    ACCOUNT = AC.AccountOpening.Account.Read(ACCOUNT.ID, ER)
    IF ER='' THEN
        CUSTOMER.ID=ACCOUNT<AC.AccountOpening.Account.Customer>
        GOSUB CUSTOMER
    END
    RETURN
*
*-----CUSTOMER-----------------------------------------------------------
*
CUSTOMER:

    customerKey = CUSTOMER.ID
    customerProfile = ''
    CALL CustomerService.getProfile(customerKey,customerProfile)
    IF EB.SystemTables.getEtext() ='' THEN
        SECTOR=customerProfile<Profile.sector>
    END ELSE
        EB.SystemTables.setEtext('')
    END
    RETURN
    END
