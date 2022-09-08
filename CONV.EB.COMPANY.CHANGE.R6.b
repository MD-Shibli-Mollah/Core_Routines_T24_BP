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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MC.CompanyCreation
    SUBROUTINE CONV.EB.COMPANY.CHANGE.R6(ID,REC,FILE)
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.EB.COMPANY.CHANGE

    FN.EBC.CONTRACTS = 'F.EBC.CONTRACTS'
    F.EBC.CONTRACTS = ''
    CALL OPF(FN.EBC.CONTRACTS,F.EBC.CONTRACTS)

    CONTRACT.KEY = REC<EB.CC.APPLICATION>:'*':REC<EB.CC.CONTRACT.KEY>
    CALL F.READU(FN.EBC.CONTRACTS, CONTRACT.KEY, R.CONTRACT, F.EBC.CONTRACTS,ER,'')

    IF ER THEN
        R.CONTRACT = ID
        CALL F.WRITE(FN.EBC.CONTRACTS, CONTRACT.KEY, R.CONTRACT)
    END ELSE
        CALL F.RELEASE(FN.EBC.CONTRACTS,CONTRACT.KEY, F.EBC.CONTRACTS)
    END
    RETURN
END
