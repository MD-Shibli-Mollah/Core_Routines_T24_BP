* @ValidationCode : MjotNjIxOTcxNDAzOkNwMTI1MjoxNTQ3MDI5OTA4NDEzOmphYmluZXNoOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTIuMjAxODExMjMtMTMxOToxNjoxNA==
* @ValidationInfo : Timestamp         : 09 Jan 2019 16:01:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jabinesh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 14/16 (87.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AC.AccountOpening
SUBROUTINE AC.DELETE.ALTERNATE.ACCOUNT(AltAcctList,UpdStatus)
*-----------------------------------------------------------------------------
* 06/12/2018 - Enhancement 2849854 / Task - 2849880

* This API has to be called during AA simulation. This routine accepts 2 arguments.
* Alternate account ids are passed in the first argument.Each record delimited with @FM and values delimited with @VM
* Second argument returns the update status, whether DELETE was successful or not.
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $USING EB.TransactionControl
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    IF AltAcctList NE '' THEN
        GOSUB PROCESS
    END

RETURN
*-----------------------------------------------------------------------------
PROCESS:
********
    AcctListCnt = DCOUNT(AltAcctList,@FM)

    FOR IDX = 1 TO AcctListCnt
        AltAcctkey = AltAcctList<IDX,1>
        AltAcctRec = AltAcctList<IDX,2>
        EB.TransactionControl.ConcatFileUpdate('F.ALTERNATE.ACCOUNT', AltAcctkey, AltAcctRec, 'D', 'AL')
    NEXT IDX

    IF NOT(EB.SystemTables.getE()) THEN
        UpdStatus = 'SUCCESS'
    END ELSE
        UpdStatus = 'FAIL'
    END
    
RETURN
*-----------------------------------------------------------------------------

END

