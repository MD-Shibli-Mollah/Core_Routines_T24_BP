* @ValidationCode : Mjo1NzA2ODYwMTU6Q3AxMjUyOjE1OTk2NDIwMjY0NjQ6YW5pdHRhcGF1bDozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6Njk6NDc=
* @ValidationInfo : Timestamp         : 09 Sep 2020 14:30:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : anittapaul
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 47/69 (68.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.ALT.ID.TYPE
*-----------------------------------------------------------------------------
************************************
*
* This is a conversion routine for the enquiry to fetch the value of ALT.ACCT.ID & ALT.ACCT.TYPE
*
************************************
*MODIFICATION HISTORY
*
* 21/02/14 - 923966
*            Modification to the Overview screen to display Posting Restrict & Alternate Account ID
*
* 16/05/14 - 999076/999082
*            Read Account record in history if the account is not in live.
*
* 09/03/17 - Task : 2047003 / Defect :2045367
*            System does not show output while executing enquiries with closed arrangements.
*
* 03/06/19 - Task: 3167839
*            Defect : 3159294
*            ACCOUNT$SIM to be read for the arrangement which simulated but not in live.
*
* 26/08/2020 - Task        : 3930267
*              Enhancement : 3930273
*              Skip account read if account id starts with AA and read account details from account property.
*
************************************

    $USING AC.AccountOpening
    $USING EB.DataAccess
    $USING EB.Reports
    $USING EB.DatInterface
    $USING AA.Account
    $USING AA.Framework
    
    
    ACCOUNT.ID = EB.Reports.getOData()['%',1,1]
    SIM.REF = EB.Reports.getOData()['%',2,1]

    IF ACCOUNT.ID[1,2] EQ "AA" THEN ;* For account id starting with AA fetch the account details from the arrangement conditions record.
        ACCOUNT.REC = ''
        ARRANGEMENT.REF = ACCOUNT.ID
        IF SIM.REF THEN ;* if simulation ref
            ARRANGEMENT.ID = ARRANGEMENT.REF:"///1"  ;* set the simulation flag.
        END
        AA.Framework.GetArrangementConditions(ARRANGEMENT.ID, "ACCOUNT", "", "" , "" , ACCOUNT.REC , "")
        ACCOUNT.REC = RAISE(ACCOUNT.REC)
        ALT.AC.ID = ACCOUNT.REC<AA.Account.Account.AcAltId>
        ALT.AC.TYPE = ACCOUNT.REC<AA.Account.Account.AcAltIdType>
    END ELSE
        F.ACCOUNT.LOC = ''
    
        R.ACCOUNT = ''
        FN.ACCOUNT.HIS = 'F.ACCOUNT$HIS' ; F.ACCOUNT.HIS = ''
        EB.DataAccess.Opf(FN.ACCOUNT.HIS,F.ACCOUNT.HIS) ;*Required as to read the History record of ACCOUNT$HIS file.

        TEMP.DATA = ''
        IF SIM.REF THEN
            EB.DatInterface.SimRead(SIM.REF,'F.ACCOUNT',ACCOUNT.ID, R.ACCOUNT, "", SIM.FLG, RET.ERR)
        END ELSE
            R.ACCOUNT = AC.AccountOpening.Account.Read(ACCOUNT.ID, RET.ERR)
        END
    
        IF R.ACCOUNT THEN
            ALT.AC.ID = R.ACCOUNT<AC.AccountOpening.Account.AltAcctId>
            ALT.AC.TYPE = R.ACCOUNT<AC.AccountOpening.Account.AltAcctType>
        END ELSE
            EB.DataAccess.ReadHistoryRec(F.ACCOUNT.HIS,ACCOUNT.ID,R.ACCOUNT,HIS.ERR)
            ALT.AC.ID = R.ACCOUNT<AC.AccountOpening.Account.AltAcctId>
            ALT.AC.TYPE = R.ACCOUNT<AC.AccountOpening.Account.AltAcctType>
        END
    END

    CNT.TYPE = DCOUNT(ALT.AC.TYPE,@VM)
    CNT.INT = 1

    IF CNT.TYPE EQ 3 THEN
        GOSUB CHECK.3.CONDITION
    END ELSE
        GOSUB CHECK.2.CONDITION
    END
RETURN

CHECK.2.CONDITION:
*-----------------
    LOOP
    WHILE CNT.INT LE CNT.TYPE
        IF ALT.AC.ID<1,CNT.INT> AND ALT.AC.TYPE<1,CNT.INT> THEN
            ALT.ACCT = ALT.AC.TYPE<1,CNT.INT>
            TEMP.DATA<-1> = ALT.ACCT:'~':ALT.AC.ID<1,CNT.INT>
        END
        CNT.INT++
    REPEAT
    CHANGE @FM TO '*' IN TEMP.DATA
    EB.Reports.setOData(TEMP.DATA:'*':ALT.AC.ID)
RETURN

CHECK.3.CONDITION:
*--------------

    LOOP
    WHILE CNT.INT LT CNT.TYPE
        IF ALT.AC.ID<1,CNT.INT> AND ALT.AC.TYPE<1,CNT.INT> THEN
            ALT.ACCT = ALT.AC.TYPE<1,CNT.INT>
            TEMP.DATA<-1> = ALT.ACCT:'~':ALT.AC.ID<1,CNT.INT>
        END
        CNT.INT++
    REPEAT

    IF TEMP.DATA NE '' THEN
        TEM.DATA<-1> = TEMP.DATA
    END

    IF CNT.INT EQ CNT.TYPE AND ALT.AC.ID<1,CNT.TYPE> AND ALT.AC.TYPE<1,CNT.TYPE> THEN
        ALT.ACCT = ALT.AC.TYPE<1,CNT.INT>
        TEM.DATA<-1> = ALT.ACCT:'~':ALT.AC.ID<1,CNT.TYPE>
    END


    CHANGE @FM TO '*' IN TEM.DATA
    EB.Reports.setOData(TEM.DATA:'*':ALT.AC.ID)
RETURN
END
