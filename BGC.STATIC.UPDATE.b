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

* Version 5 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>2211</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FT.Clearing
    SUBROUTINE BGC.STATIC.UPDATE
*
* 20/02/2008 - BG_100017213
*              F.READ of ACCOUNT.CLASS and FT.LOCAL.CLEARING changed to CACHE.READ.
*
* 19/03/2011 - Task 374516
*              Changes done not to update BGC.STATIC table if it is internal account.
*
* 16/03/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
* 20/05/2016 - Defect 1736219 / Task 1737395
*              For other cases, ID.NEW is passed ac account ID, read the account record to get customer ID
*
*     BGC STATIC UPDATE
*     =================
*
    $USING FT.LocalClearing
    $USING AC.AccountOpening
    $USING AC.Config
    $USING ST.CompanyCreation
    $USING ST.Customer
    $USING FT.Clearing
    $USING EB.SystemTables

    $INSERT I_CustomerService_NameAddress
    $INSERT I_CustomerService_Profile
*
    DIM R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStBlockCode), R.CUSTOMER.BGC.ACCOUNT(FT.LocalClearing.CustomerBgcAccount.BgcAcDate), R.ACCOUNT(AC.AccountOpening.Account.AuditDateTime), R.ACCOUNT.BGC.INFO(FT.LocalClearing.AccountBgcInfo.AcctBgcAuditDateTime)
*
*=====MAIN CONTROL=======================================================
*
    BEGIN CASE
        CASE EB.SystemTables.getApplication()='CUSTOMER'
            *
            ** CHECK IF ANY CHANGE MADE COULD AFFECT THE BGC REGISTRATION
            ** DETAILSFOR THE CUSTOMER ELSE RETURN
            *
            YBGC.CHANGE = ""
            BEGIN CASE
                CASE EB.SystemTables.getROld(ST.Customer.Customer.EbCusShortName) <> EB.SystemTables.getRNew(ST.Customer.Customer.EbCusShortName)
                    YBGC.CHANGE = 1
                CASE EB.SystemTables.getROld(ST.Customer.Customer.EbCusStreet) <> EB.SystemTables.getRNew(ST.Customer.Customer.EbCusStreet)
                    YBGC.CHANGE = 1
                CASE EB.SystemTables.getROld(ST.Customer.Customer.EbCusTownCountry) <> EB.SystemTables.getRNew(ST.Customer.Customer.EbCusTownCountry)
                    YBGC.CHANGE = 1
                CASE EB.SystemTables.getROld(ST.Customer.Customer.EbCusResidence) <> EB.SystemTables.getRNew(ST.Customer.Customer.EbCusResidence)
                    IF (EB.SystemTables.getROld(ST.Customer.Customer.EbCusResidence) = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry) OR EB.SystemTables.getRNew(ST.Customer.Customer.EbCusResidence) = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry)) THEN
                        YBGC.CHANGE = 1
                    END
            END CASE
            *
            IF NOT(YBGC.CHANGE) THEN
                RETURN  ;* No relevant changes
            END
            *
            ACC.ID=''; CUSTOMER.ID=EB.SystemTables.getIdNew()
            * BGC-registered customer must have cross-reference record....
            GOSUB READ.CUSTOMER.BGC.ACCOUNT
            IF ER THEN RETURN
            * ...and accounts must be 'live'...
            GOSUB CUSTOMER.STATUS
            IF NOT(BGC.STATUS) THEN RETURN
            * ...and no previous update made since the last tape...
            GOSUB READ.BGC.STATIC
            IF NOT(ER) THEN RETURN
            * ...in which case, update customer fields from R.OLD
            customerProfile = ''
            customerNameAddress = ''
            customerProfile<Profile.residence> = EB.SystemTables.getROld(ST.Customer.Customer.EbCusResidence)
            customerNameAddress<NameAddress.shortName> = EB.SystemTables.getROld(ST.Customer.Customer.EbCusShortName)
            customerNameAddress<NameAddress.street> = EB.SystemTables.getROld(ST.Customer.Customer.EbCusStreet)
            customerNameAddress<NameAddress.townCountry> = EB.SystemTables.getROld(ST.Customer.Customer.EbCusTownCountry)

            GOSUB UPDATE.CUSTOMER.FIELDS
            GOSUB WRITE.BGC.STATIC
        CASE EB.SystemTables.getApplication()='ACCOUNT'
            *
            * Obtain the position of the account bgc sort code within the local ref.
            *
            ACC.ID=EB.SystemTables.getIdNew();CUSTOMER.ID=EB.SystemTables.getRNew(AC.AccountOpening.Account.Customer)
            IF NOT(NUM(ACC.ID)) THEN
                RETURN
            END
            R.FT.LOCAL.CLEARING = ''
            R.FT.LOCAL.CLEARING = FT.Clearing.LocalClearing.CacheRead('SYSTEM', ER)
            *
            LOCATE  'AC.BGC.BRANCH' IN R.FT.LOCAL.CLEARING<FT.Clearing.LocalClearing.LcReqLocrefName,1> SETTING LOCPOSN THEN
            LOCPOSN = R.FT.LOCAL.CLEARING<FT.Clearing.LocalClearing.LcReqLocrefPos,LOCPOSN>
        END ELSE
            LOCPOSN = 1
        END
        ** CHECK IF ANY CHANGES HAVE BEEN MADE WHICH COULD INMPACT
        ** ON BGC REGISTRATION FOR THE ACCOUNTS ELSE RETURN.
        *
        YBGC.CHANGE = 0
        IF EB.SystemTables.getRNew(AC.AccountOpening.Account.Currency) = EB.SystemTables.getLccy() THEN
            BEGIN CASE
                CASE EB.SystemTables.getRNew(AC.AccountOpening.Account.RecordStatus)[1,1] = "H"
                    YBGC.CHANGE = 1
                CASE EB.SystemTables.getROld(AC.AccountOpening.Account.Category) <> EB.SystemTables.getRNew(AC.AccountOpening.Account.Category)
                    YBGC.CHANGE = 1
                CASE EB.SystemTables.getROld(AC.AccountOpening.Account.PostingRestrict) <> EB.SystemTables.getRNew(AC.AccountOpening.Account.PostingRestrict)
                    YBGC.CHANGE = 1
                CASE EB.SystemTables.getROld(AC.AccountOpening.Account.LocalRef)<1,LOCPOSN> <> EB.SystemTables.getRNew(AC.AccountOpening.Account.LocalRef)<1,LOCPOSN>
                    YBGC.CHANGE = 1
            END CASE
        END
        IF NOT(YBGC.CHANGE) THEN
            RETURN  ;* No relevant changes
        END
        *

        BEGIN CASE
            CASE EB.SystemTables.getRNew(AC.AccountOpening.Account.RecordStatus)[1,1]='H'     ;* re-opening
                UPDATE.CODE=4
            CASE EB.SystemTables.getIdOld()=''        ;* new account
                UPDATE.CODE=1
            CASE 1      ;* changes
                UPDATE.CODE=2
        END CASE
        IF UPDATE.CODE = 4 THEN
            CATEGORY = EB.SystemTables.getRNew(AC.AccountOpening.Account.Category)
            GOSUB ACCOUNT.STATUS
            IF NOT(BGC.STATUS) THEN RETURN
        END ELSE
            IF UPDATE.CODE#1 THEN
                * in the case of changes, check cross-reference file...
                GOSUB READ.CUSTOMER.BGC.ACCOUNT
                IF ER THEN UPDATE.CODE=1 ELSE
                * ...which should contain details of the account
                GOSUB CUSTOMER.ACCOUNT.STATUS
                IF NOT(BGC.STATUS) THEN UPDATE.CODE=1
            END
        END
        IF UPDATE.CODE=1 THEN
            * otherwise refer to category codes for account status
            CATEGORY = EB.SystemTables.getRNew(AC.AccountOpening.Account.Category)
            GOSUB ACCOUNT.STATUS
        END
        IF NOT(BGC.STATUS) THEN RETURN
    END
    GOSUB READ.BGC.STATIC
    IF ER THEN
        * update customer details if not already present...
        GOSUB READ.CUSTOMER
        GOSUB UPDATE.CUSTOMER.FIELDS
    END
    LOCATE ACC.ID IN R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStAccountNumber)<1,1> SETTING VMC ELSE
* ... and account details if not present
    IF UPDATE.CODE#1 THEN
        GOSUB READ.ACCOUNT.BGC.INFO
***!                  BRANCH.NUMBER=R.OLD(AC.LOCAL.REF)<1,1>
        BRANCH.NUMBER = ""
        POSTING.RESTRICT.VAL=EB.SystemTables.getROld(AC.AccountOpening.Account.PostingRestrict)
        WENST.ADRESSEN=R.ACCOUNT.BGC.INFO(FT.LocalClearing.AccountBgcInfo.AcctBgcCpartyRequired)
        BLOCK.CODE=R.ACCOUNT.BGC.INFO(FT.LocalClearing.AccountBgcInfo.AcctBgcBlockCode)
    END ELSE
        BRANCH.NUMBER='';POSTING.RESTRICT.VAL=''; WENST.ADRESSEN=''; BLOCK.CODE = ""
    END
    GOSUB UPDATE.ACCOUNT.FIELDS
    GOSUB WRITE.BGC.STATIC
    END
    CASE EB.SystemTables.getApplication() = "ACCOUNT.BGC.INFO"
    ACC.ID = EB.SystemTables.getIdNew()
    GOSUB READ.ACCOUNT
    CUSTOMER.ID = R.ACCOUNT(AC.AccountOpening.Account.Customer)
    CATEGORY = R.ACCOUNT(AC.AccountOpening.Account.Category)
    GOSUB ACCOUNT.STATUS
    IF NOT(BGC.STATUS) THEN RETURN
    GOSUB READ.BGC.STATIC
    IF ER THEN
        * update customer details if not already present...
        GOSUB READ.CUSTOMER
        GOSUB UPDATE.CUSTOMER.FIELDS
    END
    LOCATE ACC.ID IN R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStAccountNumber)<1,1> SETTING VMC ELSE
* ... and account details if not present
    UPDATE.CODE = 2
    BRANCH.NUMBER = ""
    POSTING.RESTRICT.VAL = R.ACCOUNT(AC.AccountOpening.Account.PostingRestrict)
    BLOCK.CODE = EB.SystemTables.getROld(FT.LocalClearing.AccountBgcInfo.AcctBgcBlockCode)
    WENST.ADRESSEN=EB.SystemTables.getROld(FT.LocalClearing.AccountBgcInfo.AcctBgcCpartyRequired)
    GOSUB UPDATE.ACCOUNT.FIELDS
    GOSUB WRITE.BGC.STATIC
    END
    CASE 1          ;* end-of-day account closure
    ACC.ID=EB.SystemTables.getIdNew()
    GOSUB READ.ACCOUNT
    CUSTOMER.ID=R.ACCOUNT(AC.AccountOpening.Account.Customer)
    UPDATE.CODE=3
    GOSUB READ.CUSTOMER.BGC.ACCOUNT
***!            IF ER THEN RETURN
    GOSUB CUSTOMER.ACCOUNT.STATUS
    IF NOT(BGC.STATUS) THEN RETURN
    GOSUB READ.BGC.STATIC
    IF ER THEN
        * update customer details if not already present...
        GOSUB READ.CUSTOMER
        GOSUB UPDATE.CUSTOMER.FIELDS
    END
    LOCATE ACC.ID IN R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStAccountNumber)<1,1> SETTING VMC ELSE
* ... and account details if not present
    BRANCH.NUMBER='';POSTING.RESTRICT.VAL=''; WENST.ADRESSEN=''; BLOCK.CODE=''
    GOSUB UPDATE.ACCOUNT.FIELDS
    GOSUB WRITE.BGC.STATIC
    END
    END CASE
    RETURN
*
*-----READ CUSTOMER/BGC ACCOUNT------------------------------------------
*
READ.CUSTOMER.BGC.ACCOUNT:

    MAT R.CUSTOMER.BGC.ACCOUNT=''; ER='' ; CUSTOMER.BGC.ACCOUNT.REC = ''
    CUSTOMER.BGC.ACCOUNT.REC = FT.LocalClearing.CustomerBgcAccount.Read(CUSTOMER.ID, ER)
    MATPARSE R.CUSTOMER.BGC.ACCOUNT FROM CUSTOMER.BGC.ACCOUNT.REC
    RETURN
*
*-----CUSTOMER STATUS----------------------------------------------------
*
CUSTOMER.STATUS:
    VMC=COUNT(R.CUSTOMER.BGC.ACCOUNT(FT.LocalClearing.CustomerBgcAccount.BgcAcAccountNumber),@VM)+1
    BGC.STATUS=0
* a customer is BGC-registered if any account exists...
    FOR I=1 TO VMC UNTIL BGC.STATUS
        * ...unless the latest update was a closure
        BGC.STATUS=(R.CUSTOMER.BGC.ACCOUNT(FT.LocalClearing.CustomerBgcAccount.BgcAcUpdateCode)<1,I>[1]#3)
    NEXT I
    RETURN
*
*-----CUSTOMER/ACCOUNT STATUS--------------------------------------------
*
CUSTOMER.ACCOUNT.STATUS:
    ACCOUNT.NUMBERS=R.CUSTOMER.BGC.ACCOUNT(FT.LocalClearing.CustomerBgcAccount.BgcAcAccountNumber)
    LOCATE ACC.ID IN ACCOUNT.NUMBERS<1,1> SETTING BGC.STATUS ELSE BGC.STATUS=0
    RETURN
*
*-----ACCOUNT STATUS-----------------------------------------------------
*
ACCOUNT.STATUS:
    R.ACCOUNT.CLASS=''; ER=''
    R.ACCOUNT.CLASS = AC.Config.AccountClass.CacheRead('U-BGCCURR', ER)
    CURRENT.AC.CATEGORIES=R.ACCOUNT.CLASS<AC.Config.AccountClass.ClsCategory>
* a new account should be registered if a current account...
    LOCATE CATEGORY IN CURRENT.AC.CATEGORIES<1,1> SETTING BGC.STATUS ELSE
    R.ACCOUNT.CLASS='';ER=''
    R.ACCOUNT.CLASS = AC.Config.AccountClass.CacheRead('U-BGCSAV', ER)
    SAVINGS.AC.CATEGORIES=R.ACCOUNT.CLASS<AC.Config.AccountClass.ClsCategory>
* ... or a savings account
    LOCATE CATEGORY IN SAVINGS.AC.CATEGORIES<1,1> SETTING BGC.STATUS ELSE BGC.STATUS=0
    END
    RETURN
*
*-----READ BGC STATIC----------------------------------------------------
*
READ.BGC.STATIC:
    MAT R.BGC.STATIC =''; ER='' ; BGC.STATIC.REC = ''
    FT.LocalClearing.BgcStaticLock(CUSTOMER.ID,BGC.STATIC.REC,ER,'','')
    MATPARSE R.BGC.STATIC FROM BGC.STATIC.REC

    RETURN
*
*-----UPDATE CUSTOMER FIELDS---------------------------------------------
*
UPDATE.CUSTOMER.FIELDS:

    R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStCountryCode)=customerProfile<Profile.residence>
    R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStCustomerName)=customerNameAddress<NameAddress.shortName>
    R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStAddress)=customerNameAddress<NameAddress.street>
***!      R.BGC.STATIC(BGC.ST.POSTCODE)=CUSTOMER(EB.CUS.TOWN.COUNTRY)[1,7]
    R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStPostcode)=customerNameAddress<NameAddress.townCountry>
    R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStCity)=customerNameAddress<NameAddress.townCountry>[10,99]
    RETURN
*
*-----UPDATE ACCOUNT FIELDS----------------------------------------------
*
UPDATE.ACCOUNT.FIELDS:
    VMC=COUNT(R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStAccountNumber),@VM)+(R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStAccountNumber)#'')+1
    R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStAccountNumber)<1,VMC>=ACC.ID
    R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStUpdateCode)<1,VMC>=UPDATE.CODE
    R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStBranchNumber)<1,VMC>=BRANCH.NUMBER
    R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStPostingRestrict)<1,VMC>=POSTING.RESTRICT.VAL
    R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStWenstAdressen)<1,VMC>=WENST.ADRESSEN
    R.BGC.STATIC(FT.LocalClearing.BgcStatic.BgcStBlockCode)<1,VMC>=BLOCK.CODE
    RETURN
*
*-----WRITE BGC STATIC---------------------------------------------------
*
WRITE.BGC.STATIC:
    MATBUILD BGC.STATIC.REC FROM R.BGC.STATIC
    FT.LocalClearing.BgcStaticWrite(CUSTOMER.ID,BGC.STATIC.REC,'')
    RETURN
*
*-----READ CUSTOMER------------------------------------------------------
*
READ.CUSTOMER:

    customerKey = CUSTOMER.ID
    prefLang = EB.SystemTables.getLngg()
    customerNameAddress = ''
    CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
    customerProfile = ''
    CALL CustomerService.getProfile(customerKey,customerProfile)

    RETURN
*
*-----READ ACCOUNT------------------------------------------------------
*
READ.ACCOUNT:
    MAT R.ACCOUNT=''; ER='' ; ACCOUNT.REC = ''
    ACCOUNT.REC = AC.AccountOpening.Account.Read(ACC.ID, ER)
    MATPARSE R.ACCOUNT FROM ACCOUNT.REC
    RETURN
*
*-----READ ACCOUNT.BGC.INFO------------------------------------------------------
*
READ.ACCOUNT.BGC.INFO:
    MAT R.ACCOUNT.BGC.INFO=''; ER='' ; ACCOUNT.BGC.INFO.REC = ''
    REC.ID = EB.SystemTables.getIdNew()
    ACCOUNT.BGC.INFO.REC = FT.LocalClearing.AccountBgcInfo.Read(REC.ID, ER)
    MATPARSE R.ACCOUNT.BGC.INFO FROM ACCOUNT.BGC.INFO.REC
    RETURN
    END
