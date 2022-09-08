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
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OP.ModelBank
    SUBROUTINE E.USER.DEPT3.CODE

    $USING EB.Security
    $USING OP.ModelBank
    $USING EB.SystemTables

    GOSUB PROCESS
    RETURN


PROCESS:

    USER.ID=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDecisionThrUser)
    R.USER.VAL = EB.SystemTables.getRUser()
    R.USER.VAL = EB.Security.User.Read(USER.ID, Y.ERR)
    EB.SystemTables.setRUser(R.USER.VAL)
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDecisionThrDept, EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>)
    RETURN
    END
