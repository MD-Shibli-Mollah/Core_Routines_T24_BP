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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.VAL.OPEN.BAL
*----------------------------------------------------------------------
* This routine is used to get the opening balance to be used for
* display in the VAL.STMT.ENT.BOOK enquiry
*
* INCOMING PARAMETER  - Y.INP.DATA which is opening bal.
* OUTGOING PARAMETER  - O.DATA which is opening balance amount
*----------------------------------------------------------------------

    $USING AC.ModelBank
    $USING EB.Reports
*
    Y.INP.DATA = AC.ModelBank.getYopenBal()
    EB.Reports.setOData(Y.INP.DATA)
    RETURN
*
    END
