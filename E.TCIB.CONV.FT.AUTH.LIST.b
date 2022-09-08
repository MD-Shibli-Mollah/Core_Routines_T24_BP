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
* <Rating>30</Rating>
*-----------------------------------------------------------------------------
*Description: This conversion routine is used to display the sigantory signed users
*----------------------------------------------------------------------------------
    $PACKAGE T4.ModelBank
    SUBROUTINE E.TCIB.CONV.FT.AUTH.LIST
*-----------------------------------------------------------------------------------
* Modification Details:
*=====================
*
* 14/07/15 - Enhancement 1326996 / Task 1399947
*			 Incorporation of T components
*-----------------------------------------------------------------------------------
    $USING EB.Reports
    $USING FT.Contract
    $USING ST.Customer

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN

*---------------------------------------------------------------------------------
INITIALISE:
*----------

    FT.ID = EB.Reports.getOData()
    RETURN

*--------------------------------------------------------------------------------
PROCESS:
*-------
    R.FT = FT.Contract.FundsTransfer.ReadNau(FT.ID,FT.ERR)
    IF NOT(FT.ERR) THEN
        Y.SIG = R.FT<FT.Contract.FundsTransfer.Signatory>
        IF Y.SIG NE '' THEN
            Y.CNT = DCOUNT(Y.SIG,@VM)
            CHANGE @VM TO '@' IN Y.SIG
            Y.S = '1'
            LOOP
            WHILE Y.S LE Y.CNT
                Y.SIGNATORY = FIELDS(Y.SIG,'@',Y.S)
                R.CUS = ST.Customer.Customer.Read(Y.SIGNATORY,CUS.ERR)
                IF NOT(CUS.ERR) THEN
                    CUS.NAME<-1> = R.CUS<ST.Customer.Customer.EbCusShortName>
                END
                Y.S++
            REPEAT
            CONVERT @FM TO "," IN CUS.NAME
            EB.Reports.setOData('')
            EB.Reports.setOData(CUS.NAME)
        END ELSE
            EB.Reports.setOData('')
        END
    END

    RETURN
    END
