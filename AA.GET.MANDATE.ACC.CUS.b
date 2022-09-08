* @ValidationCode : Mjo1ODc1MjY5MTY6SVNPLTg4NTktMToxNTQ3NjM1MjEwNTE5OmpoYWxha3ZpajoxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwNy4yMDE3MDYyMy0wMDM1OjI0OjIw
* @ValidationInfo : Timestamp         : 16 Jan 2019 16:10:10
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : jhalakvij
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 20/24 (83.3%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201707.20170623-0035
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.ModelBank
SUBROUTINE AA.GET.MANDATE.ACC.CUS(MandateAccount,MandateCustomer,MandateId,Application,ApplicationId,MAT ApplicationRecord.Recv,CustomerData)

* Subroutine to return amount for mandate checking purposes. This is used as API linked to EB.MANDATE.PARAMETER with Key as FUNDS.TRANSFER

*---------------------------------------------------------------------------------------------------------------------------------------

* Example Input:
* MandateAccount = '02000000005' ;* Mandate Account
* MandateCustomer = "12345" ;* Mandate Customer. Either MandateAcount or MandateCustomer will be present.
* MandateId ="12345.20091222-2" ;* EB.MANDATE id
* Application = 'FT' ;* Current Application
* ApplicationId = 'FT0935600001' ;* FT Id
* ApplicationRecord.Recv = FT record from R.NEW in dimensioned array format
*---------------------------------------------------------------------------------------------------------------------------------------
* 13/07/17 - Defect : 2182761 / Task : 2192655
*            New routine introduced to check Mandates required.
*            Currently this routine checks if Debit Account is AA Lending account from FT transaction when we do AA Disbursement through FT
*            and skips Mandate checks by passing CustomerData as Null.
*---------------------------------------------------------------------------------------------------------------------------------------
    $USING FT.Contract
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AC.AccountOpening
*---------------------------------------------------------------------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS
    
RETURN
*---------------------------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the Required Variable used in this API </desc>
INITIALISE:
*----------
    CustomerData= ""   ;* Default
    DIM ApplicationRecord.Recv(EB.SystemTables.SysDim)
    ApplicationRecord = ""
RETURN
*** </region>

*---------------------------------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Here we are checking whether Debit Account number in FT transaction is AA Account and Product Line is Lending if so Skip Mandate Check. </desc>
PROCESS:
*------
    MATBUILD ApplicationRecord FROM ApplicationRecord.Recv

    ACC.NO = ApplicationRecord<FT.Contract.FundsTransfer.DebitAcctNo> ;* Get the Debit Account number from FT to see if it is a AA Account.
    ACC.ERR = ''
    R.ACCOUNT = AC.AccountOpening.Account.Read(ACC.NO, ACC.ERR)
    IF R.ACCOUNT<AC.AccountOpening.Account.ArrangementId> NE "" THEN ;* If the Debit Account in FT is AA account and Product Line is Lending then Mandates are not required.
        ArrFullId = R.ACCOUNT<AC.AccountOpening.Account.ArrangementId> ;* Pass the Arrangement ID
        ArrangementRecord = "" ;* Arrangement record
        AA.Framework.GetArrangement(ArrFullId, ArrangementRecord, "") ;* Some basic details may be required from Arrangement record, so get it.
        IF ArrangementRecord<AA.Framework.Arrangement.ArrProductLine> EQ "LENDING" THEN ;* Check the Product Line is Lending for AA Account if so skip Mandate check.
            CustomerData = "" ;* Pass it as Null so that system skips Mandate Processing.
        END ELSE
            CustomerData = ApplicationRecord<FT.Contract.FundsTransfer.DebitCustomer>
        END
    END ELSE
        CustomerData = ApplicationRecord<FT.Contract.FundsTransfer.DebitCustomer>
    END
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------

END
