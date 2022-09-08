* @ValidationCode : MjoxNjQ2ODQxMTcxOkNwMTI1MjoxNDk4NzQwNjQwNzE1OnZpanU6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDUuMjAxNzA1MTctMTIyODo2OjU=
* @ValidationInfo : Timestamp         : 29 Jun 2017 18:20:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : viju
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 5/6 (83.3%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201705.20170517-1228
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

 *-----------------------------------------------------------------------------
* <Rating>0</Rating>
 *-----------------------------------------------------------------------------
    $PACKAGE AA.Account
     SUBROUTINE CONV.AA.ACCOUNT.PC.201109(REC.ID,R.RECORD,YFILE)
 *------------------------------------------------------------------------------
 * Conversion routine to set PASSBOOK field in the Account Property Class to "NO"
 *
 *------------------------------------------------------------------------------
*** <desc>Modification History </desc>
* Modification History:
*
* 29/06/17 - Task : 2177177
*            Defect : 2169657
*            During conversion, should not use the varaible name. Insted of this use variable position number.
*
*** </region>
*-----------------------------------------------------------------------------
 

     $INSERT I_COMMON
     $INSERT I_EQUATE
     $INSERT I_F.AA.ACCOUNT

     R.RECORD<28> = "NO"

     RETURN
 *---------------------------------------------------------------------------------
 END
