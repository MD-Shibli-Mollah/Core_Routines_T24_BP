* @ValidationCode : MTotMTk1NDk4NzIzMDpVVEYtODoxNDcwMDYzNDA0OTgzOmthbmFuZDoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxNjA3LjE=
* @ValidationInfo : Timestamp         : 01 Aug 2016 20:26:44
* @ValidationInfo : Encoding          : UTF-8
* @ValidationInfo : User Name         : kanand
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201607.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.Channels
    SUBROUTINE E.TC.CONV.IBAN.ID
*-----------------------------------------------------------------------------
* Description
*--------------------
* This conversion routine is used to fetch the IBAN account number from the account application
*-------------------
* Routine type       : Conversion Routine.
* IN Parameters      : ACCT.ID
* Out Parameters     : IBAN ID
*
*-----------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 26/05/16 - Enhancement - 1694533 / Task - 1748326
*            TCIB16 Product Development
*
*-----------------------------------------------------------------------------

    $USING AC.AccountOpening
    $USING EB.Reports
*-----------------------------------------------------------------------------
    GOSUB OPEN.FILES
    GOSUB PROCESS
    RETURN
*------------------------------------------------------------------------------
OPEN.FILES:
*-----------
* Opening account table

    RETURN
*-------------------------------------------------------------------------------------------------
PROCESS:
*-------
    ALT.ACCT.TYPE = ''; IBAN.VAR = ''; R.ACCOUNT = '' ; ERR.ACCOUNT = '';*Initialising variables

    ACCT.ID = EB.Reports.getOData() ;*current id
    IBAN.VAR = "T24.IBAN";*Variable to locate IBAN id for the account

    R.ACCOUNT = AC.AccountOpening.Account.Read(ACCT.ID, ERR.ACCOUNT)            ;*Reading account table
    ALT.ACCT.TYPE = R.ACCOUNT<AC.AccountOpening.Account.AltAcctType>    ;*Account type

    EB.Reports.setOData("NA");*Initialising default value as NA

    LOCATE IBAN.VAR IN ALT.ACCT.TYPE<1,1> SETTING POS THEN
    IBAN.ID = R.ACCOUNT<AC.AccountOpening.Account.AltAcctId,POS>
    IF IBAN.ID NE '' THEN
        EB.Reports.setOData(IBAN.ID);*Re-assigning the IBAN account number as result data
    END
    END


    RETURN

    END
