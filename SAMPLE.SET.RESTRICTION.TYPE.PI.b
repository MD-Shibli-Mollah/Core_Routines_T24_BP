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

    $PACKAGE PP.StaticDataGUI
    SUBROUTINE SAMPLE.SET.RESTRICTION.TYPE.PI(iInputHook, oRestrictionDetails, oHookError)
*-----------------------------------------------------------------------------
* This subroutine is used to set how restriction present in given account should be handled
*
* Input/Output Parameters Details
* iInputHook : InputHook - Input parameter which contains account information
*    1 - companyID - Mnemonic of processing company
*    2 - accountNumber - account for which restriction needs to be checked
*    3 - accountCurrency - currency of the account
*    4 - ftNumber - transaction reference
*    5 - accountCompany - Mnemonic of company to which the account belongs to
* oRestrictionDetails : RestrictionDetails - Output parameter through restriction details are passed
*    1 - accountStatus - Status of account - Inactive, closed or active
*    2 - debitRestrictionType - Type of posting restriction set on account
*    3 - debitRestrictionDesc - Description of posting restriction
*       4 - creditRestrictionType - Type of posting restriction set on account
*    5 - creditRestrictionDesc - Description of posting restriction
*    6 - otherRestrictionType - Type of restriction other than posting restriction present in account
*    7 - otherRestrictionDesc - Description of other restriction present in account
* oHookError : DASError - Output parameter to send error
*      1 - error - set "RECORD NOT FOUND" if account could not be retrived
*
*-----------------------------------------------------------------------------
*
* Inserts:
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.POSTING.RESTRICT
    $INSERT I_BalanceInterfaceService_InputHook
    $INSERT I_BalanceInterfaceService_RestrictionDetail
    $INSERT I_DebitPartyDeterminationService_DASError
*
*-----------------------------------------------------------------------------
* Process
*
CALL TPSLogging("Start","SAMPLE HOOK PI","","")
    CALL TPSLogging("Input Parameter","SAMPLE HOOK PI","iInputHook: <":iInputHook:">","")

    GOSUB initialise ; *Initialise local variables and open files

    GOSUB process ; *Set restiction Details

    GOSUB finalise ; *Assign all the output parameter

CALL TPSLogging("Output Parameter","SAMPLE HOOK PI","oRestrictionDetails: <":oRestrictionDetails:">","")

CALL TPSLogging("Output Parameter","SAMPLE HOOK PI","oHookError: <":oHookError:">","")

RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>Initialise local variables and open files </desc>
    oRestrictionDetails = ''
    oHookError = ''
    accountNumber = iInputHook<InputHook.accountNumber>
    companyID = iInputHook<InputHook.companyID>
    ftNumber = iInputHook<InputHook.ftNumber>
    accountCompany = iInputHook<InputHook.accountCompany>
    accountCurrency = iInputHook<InputHook.accountCurrency>
    creditRestrictType = ''
    debitRestrictType = ''
    creditRestrictDesc = ''
    debitRestrictDesc = ''

    fnPostingRestriction = "F.POSTING.RESTRICT"
    postingRestrictionID = ''
    rPostingRestriction = ''
    fPostingRestriction = ''
    errorPostingRestriction = ''
    CALL OPF(fnPostingRestriction,fPostingRestriction)

    fnAccount = 'F.ACCOUNT'
    fAccount = ''
    rAccount = ''
    errorAccount = ''
    CALL OPF(fnAccount, fAccount)
    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc>Set restiction Details </desc>
    CALL F.READ(fnAccount,accountNumber,rAccount,fAccount,errorAccount)

    IF errorAccount THEN
        oHookError<DASError.error> = errorAccount
        RETURN
    END

    IF rAccount<AC.POSTING.RESTRICT> THEN
        postingRestrictionID = rAccount<AC.POSTING.RESTRICT>
        GOSUB getRestrictDetails        ;*Get the restriction details
    END
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= getRestrictDetails>
getRestrictDetails:
*** <desc>Get the restriction details </desc>
*  IF restrictions is found in account or customer then get details of the restriction and assign -Error at the end to handle it as error

*  Read the POSTING.RESTRICTION table with posting restriction ID passed
    CALL F.READ(fnPostingRestriction,postingRestrictionID,rPostingRestriction,fPostingRestriction,errorPostingRestriction)
    IF errorPostingRestriction THEN
        debitRestrictType = 'DEBIT-Error'
        debitRestrictDesc = 'Restriction found'
        creditRestrictType = 'CREDIT-Error'
        creditRestrictDesc = 'Restriction found'
        RETURN
    END

*  Check the restriction type 'DEBIT'
    IF rPostingRestriction<AC.POS.RESTRICTION.TYPE> EQ 'DEBIT' THEN

        IF debitRestrictType THEN
            debitRestrictDesc<1,-1> = rPostingRestriction<AC.POS.DESCRIPTION>
        END ELSE
            debitRestrictType = rPostingRestriction<AC.POS.RESTRICTION.TYPE>:'-Error'
            debitRestrictDesc = rPostingRestriction<AC.POS.DESCRIPTION>
        END
        *  Check the restriction type 'CREDIT'
    END
    IF rPostingRestriction<AC.POS.RESTRICTION.TYPE> EQ 'CREDIT' THEN

        IF creditRestrictType THEN
            creditRestrictDesc<1,-1> = rPostingRestriction<AC.POS.DESCRIPTION>
        END ELSE
            creditRestrictType = rPostingRestriction<AC.POS.RESTRICTION.TYPE>:'-Warning'
            creditRestrictDesc = rPostingRestriction<AC.POS.DESCRIPTION>
        END
        *  Check the restriction type 'ALL'
    END
    IF rPostingRestriction<AC.POS.RESTRICTION.TYPE> EQ 'ALL' THEN

        IF debitRestrictType THEN
            debitRestrictDesc<1,-1> = rPostingRestriction<AC.POS.DESCRIPTION>
        END ELSE
            debitRestrictType = 'DEBIT':'-Skip'
            debitRestrictDesc = rPostingRestriction<AC.POS.DESCRIPTION>
        END

        IF creditRestrictType THEN
            creditRestrictDesc<-1,1>= rPostingRestriction<AC.POS.DESCRIPTION>
        END ELSE
            creditRestrictType = 'CREDIT':'-Skip'
            creditRestrictDesc = rPostingRestriction<AC.POS.DESCRIPTION>
        END

    END

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= finalise>
finalise:
*** <desc>Assign all the output parameter </desc>

   oRestrictionDetails<RestrictionDetail.creditRestrictType> =creditRestrictType 
    oRestrictionDetails<RestrictionDetail.debitRestrictType> = debitRestrictType 
    oRestrictionDetails<RestrictionDetail.creditRestrictDesc> = creditRestrictDesc 
    oRestrictionDetails<RestrictionDetail.debitRestrictDesc> = debitRestrictDesc
    RETURN
*** </region>

    END
