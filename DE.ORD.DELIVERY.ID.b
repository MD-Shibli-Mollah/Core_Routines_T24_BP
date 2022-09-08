* @ValidationCode : MjoxNTk5NjExMDQ1OkNwMTI1MjoxNTg0MDA0ODAxOTE3OnNoYXNoaWRoYXJyZWRkeXM6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAzLjIwMjAwMjEyLTA2NDY6LTE6LTE=
* @ValidationInfo : Timestamp         : 12 Mar 2020 14:50:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : shashidharreddys
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.20200212-0646
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE DE.Messaging
SUBROUTINE DE.ORD.DELIVERY.ID
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 11/03/20 - Enhancement 3613636 / Task 3631445
*            Default Routine to trigger for SETR01200104/SETR01300104/SETR01400104/SETR01600104 for ID and Function validations.
*
* 12/03/20 - Enhancement 3613636 / Task 3631445
*            Allowing I functions for the Above Mentioned Dynamic Applications.
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.DataAccess

    GOSUB INITIALISE
    GOSUB PROCESS
RETURN

*-----------------------------------------------------------------------------
INITIALISE:
    Id = EB.SystemTables.getIdNew()
    App = EB.SystemTables.getApplication()
    Fun = EB.SystemTables.getVFunction()
    AllowedFunc<1> = 'I'
    AllowedFunc<1,-1> = 'A'
    Rec = ''
    Er = ''
    
    FnAppName = 'F.':App
    FAppName = ''
    EB.DataAccess.Opf(FnAppName, FAppName)
RETURN

*-----------------------------------------------------------------------------
PROCESS:
    
    IF NOT(Fun MATCHES AllowedFunc) THEN                ;* only I and A functions are allowed
        EB.SystemTables.setE("EB-FUNCT.NOT.ALLOWED.FOR.THIS.APP")
        RETURN
    END
    
    EB.DataAccess.FRead(FnAppName, Id, Rec, FAppName, Er)
    IF Rec THEN                                         ;* Amendment Not Allowed For the excisting Records
        EB.SystemTables.setE('EB-REC.ALREADY.EXISTS')
    END
RETURN
*-----------------------------------------------------------------------------
END
