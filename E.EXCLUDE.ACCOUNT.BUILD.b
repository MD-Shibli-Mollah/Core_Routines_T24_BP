* @ValidationCode : MjotNDk5ODQ1MjQ4OkNwMTI1MjoxNTg5MjYzNDM5MDUyOmJzYXVyYXZrdW1hcjo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA1LjIwMjAwNDE3LTE1NDI6Njc6NTc=
* @ValidationInfo : Timestamp         : 12 May 2020 11:33:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 57/67 (85.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202005.20200417-1542
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AC.ModelBank
SUBROUTINE E.EXCLUDE.ACCOUNT.BUILD(ACCOUNT.IDS)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 10/11/16 - Defect 1907470 / Task 1920918
*            For individual level block, excluding customer is not allowed
*            so updating customer id in workfile is avoided.
*
* 08/11/19 - Defect 3414106 / Task 3424773
*            For UXP browser , the enquiry request formed in id format 
*            "...id...". so, it is trimmed.
*
* 12/05/20 - Defect 3719764 / Task 3739759
*            Removing changes done via 3414106 as opernad is now fixed as EQ
*            at enquiry level only so exact id of CUSTOMER.MASS.BLOCK only will
*            come in ACCOUNT.IDS without any leading or trailing charaters
*-----------------------------------------------------------------------------
    $USING AC.Config
    $USING AC.ModelBank
    $USING AC.AccountOpening
    $USING EB.Reports
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.TransactionControl
    $USING EB.Service
    $USING EB.Iris
*-----------------------------------------------------------------------------

    POS = ''
    LOCATE "BLOCK.ID" IN ACCOUNT.IDS<2,1> SETTING POS THEN ;* Get Block if from the selection field
        BLOCK.ID = ACCOUNT.IDS<4,POS>
        EB.Reports.setDFields("BLOCK.ID") ;* Set the common to pass for GetMassBlockInfo
        EB.Reports.setDLogicalOperands("1")
        ACCOUNT.IDS<3,POS> = 'CT' ;* Change the operand as CT instead of EQ since the workfile is updated as BlockID*...
        EB.Reports.setDRangeAndValue(BLOCK.ID)
    END

    R.MASS.BLOCK = '' ; R.MASS.BLOCK.ERR = ''
    R.MASS.BLOCK = AC.Config.CustomerMassBlock.ReadNau(BLOCK.ID, R.MASS.BLOCK.ERR)
    IF R.MASS.BLOCK.ERR NE '' THEN ;* If the block is not in INAU return error
        EB.Reports.setEnqError("AC-CMB.E.INVALID.MASS.BLOCK.RECORD")
        RETURN
    END ELSE
        GOSUB BLOCK.BASED.ENQ.INIT
    END

RETURN
*-----------------------------------------------------------------------------
BLOCK.BASED.ENQ.INIT:

    IF R.MASS.BLOCK<AC.Config.CustomerMassBlock.CmbDefineExclusion> EQ 'YES' THEN ;* Only process record put on hold with define exclusion set
        EB.DataAccess.FLoad("F.CUSTOMER.MASS.BLOCK", BLOCK.ID, R.MASS.BLOCK) ;* Load the record to pass the next called routine
        AC.ModelBank.GetMassBlockInfo(OUT.ARRAY) ;* Call this api to get the account/customer ids that matches the defined selection
        GOSUB UPLOAD.DATA ;* For each selected record update workfile
    END ELSE
        EB.Reports.setEnqError("AC-CMB.E.INVALID.MASS.BLOCK.RECORD")
    END

RETURN

*-----------------------------------------------------------------------------

*** <region name= UPLOAD.DATA>
UPLOAD.DATA:
*** <desc> </desc>

* Clear the existing records for the same massblock before loading again
    FN.CMB.FILE = "F.AC.MASS.BLOCK.EXCLUSION"
    F.CMB.FILE = ''
    EB.DataAccess.Opf(FN.CMB.FILE, F.CMB.FILE)
    FN.CMB.FILE<2> = "WITH @ID LIKE ":BLOCK.ID:"*..."
    EB.Service.ClearFile(FN.CMB.FILE, F.CMB.FILE) ;* Clear records matching the passed selection

    INCLUDE.AC.ACCTS = R.MASS.BLOCK<AC.Config.CustomerMassBlock.CmbIncludeAcAccounts> ;* Flag to filter AA accounts only
    BLOCK.TYPE = R.MASS.BLOCK<AC.Config.CustomerMassBlock.CmbBlockingType> ;* Flag to filter AA accounts only

    ID.LIST = FIELDS(OUT.ARRAY,'|',1) ;* Get customer or account ids
    CUST.ID = ''
    IF R.MASS.BLOCK<AC.Config.CustomerMassBlock.CmbSelApplication> MATCHES "CUSTOMER":@VM:"" THEN ;* Block is at customer level or individual cust
        CUS.CNT = DCOUNT(ID.LIST,@FM) ;* Returned ids will be customer ids, get customer accounts and update workfile
        FOR CUS.POS = 1 TO CUS.CNT
            CUST.ID = ID.LIST<CUS.POS>
            ACCOUNT.ID.LIST = AC.AccountOpening.CustomerAccount.Read(CUST.ID, Error)
            IF BLOCK.TYPE NE "INDIVIDUAL" THEN ;* For Individual type of block customer itself cannot be excluded
                WORK.ID = BLOCK.ID:"*":CUST.ID:'*' ;* Create a record for customer itself to feciliatate customer level exclude
                AC.ModelBank.MassBlockExclusion.Write(WORK.ID, "")
            END
            GOSUB WRITE.WORFILE ;* Update work file
        NEXT CUS.POS
    END ELSE
        ACCOUNT.ID.LIST = ID.LIST
        GOSUB WRITE.WORFILE ;*  Update work file
    END

    EB.TransactionControl.JournalUpdate("")

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= WRITE.WORFILE>
WRITE.WORFILE:
*** <desc> Update work file</desc>

    ACC.CNT = DCOUNT(ACCOUNT.ID.LIST,@FM)
    FOR ACC.POS = 1 TO ACC.CNT
        ACCT.ID = ACCOUNT.ID.LIST<ACC.POS>

        IF NOT(CUST.ID) OR INCLUDE.AC.ACCTS NE "YES" THEN ;* Read account if the Cust id not known or all accounts not included
            R.ACCOUNT = AC.AccountOpening.Account.Read(ACCT.ID, Error)
            CUSTOMER.ID = R.ACCOUNT<AC.AccountOpening.Account.Customer>
        END ELSE
            CUSTOMER.ID = CUST.ID
        END

        IF INCLUDE.AC.ACCTS NE "YES" AND NOT(R.ACCOUNT<AC.AccountOpening.Account.ArrangementId>) THEN
            CONTINUE ;* If not all accounts included and not arrangement account then skip the record
        END

        WORK.ID = BLOCK.ID:"*":CUSTOMER.ID:'*':ACCT.ID
        AC.ModelBank.MassBlockExclusion.Write(WORK.ID, "")
    NEXT ACC.POS

RETURN
*** </region>

END
