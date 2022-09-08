* @ValidationCode : Mjo0NTc2NjU5OTpjcDEyNTI6MTU5OTY3NzQ0MzI0ODpzYWlrdW1hci5tYWtrZW5hOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTo5OTo5Mw==
* @ValidationInfo : Timestamp         : 10 Sep 2020 00:20:43
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 93/99 (93.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-58</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.ECB.VIEW
*-----------------------------------------------------------------------------
*              M O D I F I C A T I O N S
*
* 11/11/13 - DEFECT 823258 / TASK 832299
*			 The enquiry EB.CONTRACT.BALANCES.BALANCE misses out some transactions in the enquiry output.
*
* 11/11/19 - Defect 3380067/ Task 3424071
*            Fix provided for the case where Call/Notice contract would have the ECB with first subvalue set EcbMatDate to EcbMatDate as 0.
*            Looping is corrected to check the SM values properly from EcbMatDate to EcbDbMvmtLcl to have the Balances updated properly.
*            Existing Logic is made sure not be harmed. Additional fix to avoid unwanted looping is also incorporated.
*
* 09/09/20 - Enhancement 3932648 / Task 3952625
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*-----------------------------------------------------------------------------
** Routine to merge together EB.CONTRACT.BALANCES record for a
** given date to show only one figure for a balance
*

    $USING BF.ConBalanceUpdates
    $USING EB.Utility
    $USING EB.SystemTables
    $USING EB.Reports

*
    GOSUB INITIALISE
    GOSUB MERGE.BALANCES
    GOSUB REPLACE.BALANCES
*
RETURN
*
*-----------------------------------------------------------------------------
INITIALISE:
*
** Determine if we want the closing balance as of last working day
** or the current balance. The value passed from the enquiry will be
** CLOSING for as of last night or any other value for current
*
    IF EB.Reports.getOData() = "CLOSING" THEN
        CHECK.DATE = EB.SystemTables.getRDates(EB.Utility.Dates.DatLastPeriodEnd)
    END ELSE
        CHECK.DATE = EB.SystemTables.getToday()
    END
*
    MERGED.BALANCES = ''
    MAX.SM = ''     ;* Highest SM number
*
RETURN
*
*-----------------------------------------------------------------------------
MERGE.BALANCES:
*
** Look at each TYPE-SYSDATE and merge them all together into a single
** set of figures
*
    BAL.IDX = 0
    LOOP
        BAL.IDX += 1
        BAL.DATE = EB.Reports.getRRecord()<BF.ConBalanceUpdates.EbContractBalances.EcbTypeSysdate, BAL.IDX>
    WHILE BAL.DATE
        BALANCE.TYPE = BAL.DATE["-",1,1]
        SYS.DATE = BAL.DATE["-",2,1]
        BEGIN CASE
            CASE CHECK.DATE = EB.SystemTables.getToday()
                ADD.BALANCE = 1
            CASE SYS.DATE LE CHECK.DATE
                ADD.BALANCE = 1
            CASE 1
                ADD.BALANCE = ''
        END CASE
        IF ADD.BALANCE THEN
            GOSUB ADD.DETS
        END
    REPEAT
*
RETURN
*
*-----------------------------------------------------------------------------
ADD.DETS:
*
** Add the balance details into the array
*
    LOCATE BALANCE.TYPE IN MERGED.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbTypeSysdate,1> SETTING POS ELSE
        FOR IDX = BF.ConBalanceUpdates.EbContractBalances.EcbTypeSysdate TO BF.ConBalanceUpdates.EbContractBalances.EcbCurrAssetType
            MERGED.BALANCES<IDX,POS> = ''
        NEXT IDX
        MERGED.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbTypeSysdate,POS> = BALANCE.TYPE
    END
*
    SM.CNT = ''
    SMC = ''
    LOOP
        SMC += 1
        DETAILS.FOUND = ''    ;* Have to check all fields as mat date is not there always
        SmSeperatedValues = ''
        HighestSmSeperatedValues = ""
        FOR IDX = BF.ConBalanceUpdates.EbContractBalances.EcbMatDate TO BF.ConBalanceUpdates.EbContractBalances.EcbDbMvmtLcl
            
            SmSeperatedValues = COUNT(EB.Reports.getRRecord()<IDX, BAL.IDX>,@SM)+1
            IF SmSeperatedValues > HighestSmSeperatedValues THEN ;* EcbMatDate to EcbDbMvmtLcl is SM seperated
                HighestSmSeperatedValues = SmSeperatedValues   ;*To Have proper looping of all SM seperated Values under the respective EcbTypeSysdate
            END
        
            IF EB.Reports.getRRecord()<IDX, BAL.IDX, SMC> THEN
                DETAILS.FOUND = 1
                IDX = BF.ConBalanceUpdates.EbContractBalances.EcbDbMvmtLcl ;*stop additional looping
            END
        NEXT IDX
    WHILE DETAILS.FOUND OR (SMC LE HighestSmSeperatedValues);*first SM set can go as 0 in Call/Notice Contract hence the condition is required
    
        IF DETAILS.FOUND THEN   ;*start Condition
            GOSUB UPDATE.MERGED.BALANCES
        END ;*End Condtion
    
    REPEAT
*
RETURN
*-----------------------------------------------------------------------------
UPDATE.MERGED.BALANCES:
*
    MAT.DATE = EB.Reports.getRRecord()<BF.ConBalanceUpdates.EbContractBalances.EcbMatDate, BAL.IDX, SMC>
    IF MAT.DATE = '' THEN
        MAT.DATE = 'NONE'
    END
    LOCATE MAT.DATE IN MERGED.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbMatDate, POS, 1> SETTING MDPOS ELSE
        SM.CNT += 1
        IF SM.CNT GT MAX.SM THEN
            MAX.SM = SM.CNT
        END
        FOR IDX = BF.ConBalanceUpdates.EbContractBalances.EcbOpenBalance TO BF.ConBalanceUpdates.EbContractBalances.EcbDbMvmtLcl
            MERGED.BALANCES<IDX, POS, MDPOS> = ''
        NEXT IDX
        MERGED.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbMatDate, POS, MDPOS> = MAT.DATE
    END
*
** For previous dates merge them into the opening balance
*
    MERGED.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbOpenBalance, POS, MDPOS> += EB.Reports.getRRecord()<BF.ConBalanceUpdates.EbContractBalances.EcbOpenBalance, BAL.IDX,SMC>
    IF SYS.DATE LT CHECK.DATE THEN
        MERGED.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbOpenBalance, POS, MDPOS> += EB.Reports.getRRecord()<BF.ConBalanceUpdates.EbContractBalances.EcbCreditMvmt, BAL.IDX, SMC>
        MERGED.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbOpenBalance, POS, MDPOS> += EB.Reports.getRRecord()<BF.ConBalanceUpdates.EbContractBalances.EcbDebitMvmt, BAL.IDX, SMC>
    END ELSE
        MERGED.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbCreditMvmt, POS, MDPOS> += EB.Reports.getRRecord()<BF.ConBalanceUpdates.EbContractBalances.EcbCreditMvmt, BAL.IDX, SMC>
        MERGED.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbDebitMvmt, POS, MDPOS> += EB.Reports.getRRecord()<BF.ConBalanceUpdates.EbContractBalances.EcbDebitMvmt, BAL.IDX, SMC>
    END
*
*-----------------------------------------------------------------------------
RETURN
*
*-----------------------------------------------------------------------------
REPLACE.BALANCES:
*
** Replace the stored figures in the record with the newly merged balances
*
    FOR IDX = BF.ConBalanceUpdates.EbContractBalances.EcbTypeSysdate TO BF.ConBalanceUpdates.EbContractBalances.EcbCurrAssetType
        tmp=EB.Reports.getRRecord(); tmp<IDX>=MERGED.BALANCES<IDX>; EB.Reports.setRRecord(tmp)
    NEXT IDX
*
** Set VM.COUNT and SM.COUNT
*
    TYPE.SYS.DATE.CNT = DCOUNT(EB.Reports.getRRecord()<BF.ConBalanceUpdates.EbContractBalances.EcbTypeSysdate>, @VM)
    EB.Reports.setVmCount(TYPE.SYS.DATE.CNT)

* The below variable signfies the sm count with respect to balance type.
* In the above loop the sm count was not incremented properly. Hence the below is done.

    MAT.DATE.CNT = DCOUNT(EB.Reports.getRRecord()<BF.ConBalanceUpdates.EbContractBalances.EcbMatDate>,@VM)
    CNTR = '1'
    LOOP
    WHILE CNTR LE MAT.DATE.CNT
        SM.COUNTER = DCOUNT(EB.Reports.getRRecord()<BF.ConBalanceUpdates.EbContractBalances.EcbMatDate,CNTR>,@SM)
        TOT.SM.CNT<-1> = SM.COUNTER
        CNTR += 1
    REPEAT
    EB.Reports.setSmCount(MAXIMUM(TOT.SM.CNT))
*
RETURN
*-----------------------------------------------------------------------------
*
END
