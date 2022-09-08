* @ValidationCode : Mjo5MjI1ODA1OTg6Y3AxMjUyOjE2MDExOTE0NTMyNDY6c2Fpa3VtYXIubWFra2VuYTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTotMTotMQ==
* @ValidationInfo : Timestamp         : 27 Sep 2020 12:54:13
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
* A new routine (E.MB.GET.UNC.RUN.BALANCE) has been introduced to Show the cumulative of the Unallocated
* credit & running balance of the arrangement. This new routine is called from an existing enquiry
*(AA.REPORT.DEPOSIT).This will return the result for Today's date.
*
* Input  (ACCOUNT.ID)   - Account Number
* Output (O.DATA)       - Unallocated Credit followd by Current Balance( delimiter by "*")
*                         (UNCTOTAL : "*" : CURR.TOTAL)
$PACKAGE AD.ModelBank
SUBROUTINE E.MB.GET.UNC.RUN.BALANCE

    $USING BF.ConBalanceUpdates
    $USING RE.ConBalanceUpdates
    $USING EB.Reports


    GOSUB PROCESS
RETURN

PROCESS:
    ACCOUNT.ID = EB.Reports.getOData() ; UNC.TOTAL = ""; CURR.TOTAL = "" ;
    TYPE = "UNCACCOUNT":@FM:"CURACCOUNT"
    NO.OF.REC = DCOUNT(TYPE,@FM)
    LOOP
        BAL.TYPE = TYPE<NO.OF.REC,1>
    WHILE BAL.TYPE
        BF.ConBalanceUpdates.AcGetEcbBalance(ACCOUNT.ID, BAL.TYPE, SUB.TYPE, BAL.DATE,ECB.BALANCE,ECB.BAL.LCY)
        BEGIN CASE
            CASE BAL.TYPE EQ "UNCACCOUNT"
                UNC.TOTAL = ECB.BALANCE
            CASE BAL.TYPE EQ "CURACCOUNT"
                CURR.TOTAL = ECB.BALANCE
        END CASE
        NO.OF.REC -= 1
    REPEAT
    EB.Reports.setOData(UNC.TOTAL : "*": CURR.TOTAL)
RETURN
END
