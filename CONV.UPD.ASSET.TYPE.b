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

* Version 3 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>37</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.BalanceUpdates
    SUBROUTINE CONV.UPD.ASSET.TYPE(ACCOUNT.ID)
*-----------------------------------------------------------------------------
* Program Description
*
* Update the Open.Asset.Type field on ACCOUNT
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 07/01/05 - EN_10002375
*            New routine
*
* 12/12/08 - BG_100021277
*            F.READ, F.WRITE, F.DELETE and F.RELEASE are changed to READ, WRITE,
*            DELETE and RELEASE respectively.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_EOD.AC.CONV.ENTRY.COMMON

*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB READ.ACCOUNT

*     ---------------------------------------------------------------     *
***   Ignore New ACCOUNTS as EOD.ACCT.ACTIVITY will update Asset.Type   ***
*     ---------------------------------------------------------------     *

    IF R.ACCOUNT<AC.CONSOL.KEY> = "" THEN
        GOSUB RELEASE.ACCOUNT
    END ELSE
        GOSUB DETERMINE.ASSET.TYPE
        GOSUB WRITE.ACCOUNT
    END


    RETURN

*-----------------------------------------------------------------------------
INITIALISE:

    R.ACCOUNT = ''
    ASSET.TYPE = ''

    RETURN

*-----------*
READ.ACCOUNT:
*-----------*

    R.ACCOUNT = ""
    READU R.ACCOUNT FROM F.ACCOUNT, ACCOUNT.ID ELSE
        R.ACCOUNT = ''
        E = "IC.RTN.MISS.FILE.F.ACCOUNT.ID":FM:ACCOUNT.ID
        GOTO FATAL.ERROR
    END

    RETURN

*--------------*
RELEASE.ACCOUNT:
*--------------*

    RELEASE F.ACCOUNT, ACCOUNT.ID

    RETURN

*------------*
WRITE.ACCOUNT:
*------------*

    WRITE R.ACCOUNT TO F.ACCOUNT, ACCOUNT.ID

    RETURN

*----------*
FATAL.ERROR:
*----------*

    TEXT = E ; CALL FATAL.ERROR ("EOD.ACCT.ACTIVITY.RECORD")
    RETURN

*-------------------*
DETERMINE.ASSET.TYPE:
*-------------------*

    INIT.TYPE = 'CONV'
    MVMT.AMT = ''
    CALL AC.DETERMINE.INIT.ASSET.TYPE(ACCOUNT.ID,R.ACCOUNT,INIT.TYPE,MVMT.AMT)
    R.ACCOUNT<AC.OPEN.ASSET.TYPE> = INIT.TYPE

    RETURN

*-----------------------------------------------------------------------------
*
END
