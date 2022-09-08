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
* <Rating>-9</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FT.BulkProcessing
    SUBROUTINE CONV.FT.BULK.CREDIT.G13.0(FBC.ID,FBC.RECORD,F.FT.BULK.CREDIT)

* This subroutine converts FT.BULK.CREDIT with id as account.number-date
* as account.number-date-seq.number.
*------------------------------------------------------------------------------
*Modification History:
*---------------------
*
* 12/12/08 - BG_100021277
*            F.READ, F.WRITE, F.DELETE are replaced with READ, WRITE, DELETE
*            respectively.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*-------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE


*=======================
* Open files :
*=======================

    FV.FT.BULK.CREDIT = ""
    CALL OPF(F.FT.BULK.CREDIT,FV.FT.BULK.CREDIT)

    FV.FBC.ACCOUNT.LIST=""
    CALL OPF("F.FBC.ACCOUNT.LIST",FV.FBC.ACCOUNT.LIST)

*===================
* Process records :
*===================

    SAVE.FBC.RECORD = FBC.RECORD        ;* Will be used later .
    DELETE FV.FT.BULK.CREDIT, FBC.ID

    AC.DATE = FIELD(FBC.ID,';',1)
    ID.DATE = FIELD(FBC.ID,'-',2)
    READ R.BC.ACCT.LIST FROM FV.FBC.ACCOUNT.LIST, AC.DATE ELSE
        R.BC.ACCT.LIST<1> = 2
        R.BC.ACCT.LIST<2> = 1
    END
    WRITE R.BC.ACCT.LIST TO FV.FBC.ACCOUNT.LIST, AC.DATE

    HIS.SEQ.NO = FIELD(FBC.ID,';',2)
    FBC.ID = AC.DATE:'.1'
    IF HIS.SEQ.NO THEN
        FBC.ID = FBC.ID:';':HIS.SEQ.NO
    END
    FBC.RECORD = SAVE.FBC.RECORD
    FBC.RECORD<3> = 'YES'     ;* Populate Yes in SINGLE.PAYMENT field
    FBC.RECORD<13> = ID.DATE  ;* Populate Id date in this field
    RETURN
END
