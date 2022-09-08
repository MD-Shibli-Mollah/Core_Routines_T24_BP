* @ValidationCode : MjotMTM1Mjc3OTU4MzpDcDEyNTI6MTU5NDgxMTgzNjI1NDpqYWJpbmVzaDoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6MTQ6MTQ=
* @ValidationInfo : Timestamp         : 15 Jul 2020 16:47:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jabinesh
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 14/14 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 2 25/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.LIMIT.ACCOUNT.OS
*--------------------------------------------------------------------------------
*** <region name= Program Description>
***
*  It will call the core accounting routine to get the account outstanding balance.
*
*** </region>
*--------------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* Output
*
*** </region>
*--------------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Change descriptions</desc>
* Modification History :
*
* 03/11/2016 - Task : 1902891
*              Enhancement : 1864620
*              Get outstanding balance of the account.
*
* 15/07/2020 - Enhancement 3713736 / Task 3833781
*              Size of the limit dimension array changed to C$SYSDIM.
*** </region>
*--------------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>Inserts used in the sub-routine</desc>

    $USING LI.LimitTransaction
    $USING EB.Reports
    $USING LI.Config
    $USING EB.SystemTables

*** </region>
*--------------------------------------------------------------------------------
*
*** <region name= Main Program block>
*** <desc>Main processing logic</desc>

    GOSUB GET.ACCOUNT.OS.BALANCE

RETURN
*** </region>
*--------------------------------------------------------------------------------

*** <region name= Get Account Os Balance>
*** <desc>Get account outstanding balance</desc>
GET.ACCOUNT.OS.BALANCE:

    DIM LIMIT(EB.SystemTables.SysDim) ;
    MAT LIMIT = ''
    LIMIT.ID =  EB.Reports.getOData()
    R.LIMIT = LI.Config.Limit.Read(LIMIT.ID, ERR.LIMIT)
    MATPARSE LIMIT FROM R.LIMIT
    
    ACCOUNT.OS.AMOUNT = 0
    LI.LimitTransaction.LimitGetAccBals(MAT LIMIT,'','',ACCOUNT.OS.AMOUNT)
    
    IF ACCOUNT.OS.AMOUNT GT 0 THEN         ;* If the total balance is in credit do not bother so make it as 0
        ACCOUNT.OS.AMOUNT = 0
    END
    
    EB.Reports.setOData(ACCOUNT.OS.AMOUNT)

RETURN
*-----------------------------------------------------------------------------
END
