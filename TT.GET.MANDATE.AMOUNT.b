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
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE TT.ModelBank
    SUBROUTINE TT.GET.MANDATE.AMOUNT(MandateAccount,MandateCustomer,MandateId,Application,ApplicationId,MAT ApplicationRecord.Recv,AmountData)

* Subroutine to return amount for mandate checking purposes. This is used as API linked to EB.MANDATE.PARAMETER with Key as TELLER

    $USING TT.Contract
    $USING EB.SystemTables


* Example Input:
* MandateAccount = '02000000005' ;* Mandate Account
* MandateCustomer = "12345" ;* Mandate Customer. Either MandateAcount or MandateCustomer will be present.
* MandateId ="1.20091222-2" ;* EB.MANDATE id
* Application = 'TELLER' ;* Current Application
* ApplicationId = 'TT0935600001' ;* Teller Id
* ApplicationRecord.Recv = Teller record from R.NEW in dimensioned array format


    AmountData= 0   ;* Default
    DIM ApplicationRecord.Recv(EB.SystemTables.SysDim)
    ApplicationRecord = ''

    MATBUILD ApplicationRecord FROM ApplicationRecord.Recv
* Checks based on Mandate Account. Used if MandateAccount is returned from ACCOUNT API attached to EB.MANDATE.PARAMETER
* has mandates attached to it or its customer.

    IF ApplicationRecord<TT.Contract.Teller.TeDrCrMarker> = 'DEBIT' THEN


        * Get Amount from Side 1 as it is debit for respective Account
        LOCATE MandateAccount IN ApplicationRecord<TT.Contract.Teller.TeAccountOne,1> SETTING ACFOUNDPOS THEN
        IF ApplicationRecord<TT.Contract.Teller.TeCurrencyOne> = EB.SystemTables.getLccy() THEN
            AmountData = ApplicationRecord<TT.Contract.Teller.TeAmountLocalOne,ACFOUNDPOS> ;* Default Local
        END ELSE
            AmountData = ApplicationRecord<TT.Contract.Teller.TeAmountFcyOne,ACFOUNDPOS>
        END
    END

    END ELSE

    IF ApplicationRecord<TT.Contract.Teller.TeAccountTwo> = MandateAccount THEN
        IF ApplicationRecord<TT.Contract.Teller.TeCurrencyTwo> = EB.SystemTables.getLccy() THEN
            AmountData = ApplicationRecord<TT.Contract.Teller.TeAmountLocalTwo>  ;* Default Local
        END ELSE
            AmountData = ApplicationRecord<TT.Contract.Teller.TeAmountFcyTwo>
        END
    END         ;* Return back to Main
    END

    RETURN          ;*Return back to Main
    END
