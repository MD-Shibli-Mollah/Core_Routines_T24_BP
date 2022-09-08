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
* <Rating>-35</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE V.MB.AMED.ACCT

**************************************************************
* Add joint card
**************************************************************
* 15/12/2010 - New Development
* Purpose: To validate the joint holder
*
* 07/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
**************************************************************

    $USING EB.SystemTables
    $USING AC.AccountOpening
    $USING AC.ModelBank
    $USING EB.ErrorProcessing

    IF EB.SystemTables.getMessage() NE 'VAL' THEN
        RETURN
    END

    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------


PROCESS:
    Y.ACC = EB.SystemTables.getRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivAccount)
    IF NOT(Y.ACC) THEN
        RETURN
    END

    Y.CUS = EB.SystemTables.getRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivCustomer)
    Y.ADD.J = EB.SystemTables.getRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivAddJointHolder)
    Y.ADD.R = EB.SystemTables.getRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivAddRelation)
    Y.ADDON = EB.SystemTables.getRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivJointCard)
    Y.JOINT.CUS = '' ; Y.JOINT.CUS = EB.SystemTables.getRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivJointCustomer)

    IF Y.JOINT.CUS EQ 'Yes' THEN
        IF Y.ADD.J EQ '' OR Y.ADD.R EQ '' THEN
            EB.SystemTables.setEtext('AC-JOINT.RELATION.MANDATORY')
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END
    END

    EB.SystemTables.setEtext('')
    IF Y.CUS EQ Y.ADD.J AND Y.ADD.J NE '' THEN
        EB.SystemTables.setEtext('AC-JOINT.SAME.CUST')
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END

    R.ACCOUNT = '' ; ERR.ACC = ''
    R.ACCOUNT = AC.AccountOpening.tableAccount(Y.ACC, ERR.ACC)

    IF R.ACCOUNT THEN
        IF R.ACCOUNT<AC.AccountOpening.Account.JointHolder> NE '' THEN
            Y.EXST.JOINT = '' ; Y.EXST.JOINT = R.ACCOUNT<AC.AccountOpening.Account.JointHolder>
            LOCATE Y.ADD.J IN Y.EXST.JOINT<1,1> SETTING Y.POS THEN
            EB.SystemTables.setEtext('AC-JOINT.EXIST')
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END
    END

    IF R.ACCOUNT<AC.AccountOpening.Account.JointHolder> NE '' THEN
        IF EB.SystemTables.getEtext() EQ '' THEN
            JOINT.HOLDER = R.ACCOUNT<AC.AccountOpening.Account.JointHolder>:@VM:Y.ADD.J
            RELATIVE.CODE = R.ACCOUNT<AC.AccountOpening.Account.RelationCode>:@VM:Y.ADD.R
            EB.SystemTables.setRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivJointHolder,JOINT.HOLDER )
            EB.SystemTables.setRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivRelationCode, RELATIVE.CODE)
        END
    END ELSE
        IF EB.SystemTables.getEtext() EQ '' THEN
            EB.SystemTables.setRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivJointHolder, Y.ADD.J)
            EB.SystemTables.setRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivRelationCode, Y.ADD.R)
        END
    END
    END
    RETURN

INIT:
    Y.ACC = ''
    Y.CUS = ''
    Y.ADD.J = ''
    Y.ADD.R = ''
    Y.POS = ''
    RETURN

OPEN.FILES:
    RETURN
*-----------------------------------------------------------------------------
    END
