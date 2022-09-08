* @ValidationCode : MjotMTcxNzI2ODQwMjpDcDEyNTI6MTU5MzYwMDY1MTEyNTpqYWJpbmVzaDoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6Njk6Njc=
* @ValidationInfo : Timestamp         : 01 Jul 2020 16:20:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jabinesh
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 67/69 (97.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.MB.GET.BALANCE
*----------------------------------------------------------------------------
* Modification History

* 13/06/18 - Defect 2597034 / Task 2628208
*            Merge balances for HVT accounts and write it in cache to fetch correct working balances if notional
*            merge has not happened at time enquiry is executed
*
* 05/05/2020 - Defect 3715459 / Task 3727836
*              Routine is enhanced to return the internal amount of Limit following Validation and utilisation structure.
*-----------------------------------------------------------------------------

    $USING LI.Config
    $USING EB.DataAccess
    $USING LI.LimitTransaction
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING AC.HighVolume
    $USING AC.API
    $USING EB.SystemTables
    

    GOSUB INIT
    GOSUB PROCESS

RETURN

INIT:

    R.LIMIT = ''
    ERR.LIMIT = ''
    YPREV.FILE = ''
    CACHE.LOADED = ''        ;* Flag to indicate if ECB is updated in cache
    GOSUB CLEAR.CACHE         ;* Clear R.EB.CONTRACT.BALANCES on entry

RETURN

PROCESS:

    O.DATA.VAL = EB.Reports.getOData()
    IF FIELD(O.DATA.VAL,'.',2) OR O.DATA.VAL[1,2] EQ 'LI' THEN  ;* Record to be fetched for all the limits following both old and new structure
        LIMIT.ID = O.DATA.VAL
        DIM LIMIT(EB.SystemTables.SysDim)
        R.RECORD.VAL = EB.Reports.getRRecord()
        MATPARSE LIMIT FROM R.RECORD.VAL
        LIMIT.REC  = ''
        LIMIT.REC = LI.Config.Limit.Read(LIMIT.ID, ERR.LIMIT)
        IF NOT(ERR.LIMIT) THEN
            MATPARSE LIMIT FROM LIMIT.REC
        END
        IF LIMIT(LI.Config.Limit.Account) # '' THEN
            GOSUB CHECK.HVT
        END
        O.DATA.VAL = ''
        LI.LimitTransaction.LimitGetAccBals(MAT LIMIT,'','',O.DATA.VAL)
        IF LIMIT(LI.Config.Limit.Account) # '' AND CACHE.LOADED THEN
            GOSUB CLEAR.CACHE         ;* Clear R.EB.CONTRACT.BALANCES on exit
        END
        EB.Reports.setOData(O.DATA.VAL)
        ACT.LIMIT = LIMIT(LI.Config.Limit.OnlineLimit)<1,1> + O.DATA.VAL
        EB.Reports.setOData(ACT.LIMIT)
    END ELSE
        EB.Reports.setOData("")
    END
RETURN

CHECK.HVT:
* For each account limked to LIMIT, check if is is HVT or not. For HVT accounts, perform merge and update ECB is cache
*
    YNO.OF.ACCOUNTS = DCOUNT(LIMIT(LI.Config.Limit.Account),@VM)
    FOR YAV = 1 TO YNO.OF.ACCOUNTS
        YCOMP.MNE = LIMIT(LI.Config.Limit.AccCompany)<1,YAV>
        YKEY = LIMIT(LI.Config.Limit.Account)<1,YAV>
        GOSUB GET.ACCOUNT.RECORD ;* Read the account record
        IF NOT(READ.ERR) THEN
            HVT.PROCESS = ""
            AC.HighVolume.CheckHvt(YKEY, ACC.REC, "", "", HVT.PROCESS, "", "", ERR)  ;* Read the account record to find if account is set as HVT, if not then continue as before
            IF HVT.PROCESS EQ "YES" THEN
                RESPONSE = ''
                AC.HighVolume.HvtMergeECB(YKEY, RESPONSE)  ;* load cache with amounts
                IF RESPONSE EQ 1 THEN
                    CACHE.LOADED = 1
                END
            END
        END
    NEXT YAV
*
RETURN

GET.ACCOUNT.RECORD:
*
    ACC.REC = ""
    READ.ERR = ""
    AC.AccountOpening.GetAccountCompany(YCOMP.MNE);* Get the lead company mnemonic of the account company to open the file
    YF.ACCOUNT = "F":YCOMP.MNE:".ACCOUNT" ;* Open the file when the company changes
    IF YF.ACCOUNT <> YPREV.FILE THEN
        YPREV.FILE = YF.ACCOUNT
        F.ACCOUNT = ""
        EB.DataAccess.Opf(YF.ACCOUNT, F.ACCOUNT)
    END

    EB.DataAccess.FRead(YF.ACCOUNT, YKEY, ACC.REC, F.ACCOUNT, READ.ERR) ;* Read account record
*
RETURN

CLEAR.CACHE:
* Cache needs to be cleared on entry and exit of routine for HVT accounts
*
    ACTION = "ClearCache"
    R.EB.CONTRACT.BALANCES = ''
    RESPONSE = ''   ;* Can be returned as RECORD NOT FOUND, INVALID ID, INVALID ACTION CODE, etc
    AC.API.EbCacheContractBalances('', ACTION, R.EB.CONTRACT.BALANCES, RESPONSE)
*
RETURN
*
END
