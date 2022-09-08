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

* Version n dd/mm/yy  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>-36</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AI.ModelBank
    SUBROUTINE EB.MB.IBUSER.FORM.CHECK.RECORD
**************************************************************
* Internet Bamking User creation
**************************************************************
* 15/12/2010 - New Development
* Purpose: To check the customer is having IB User and to Amend the
*          arrangement record by Exclude and Include provision.
*
* 18/05/15 - Enhancement-1326996/Task-1327012
*			 Incorporation of AI components
*
**************************************************************
    $USING AI.ModelBank
    $USING EB.ARC
    $USING EB.Browser
    $USING EB.Display
    $USING EB.SystemTables

    $INSERT I_DAS.EB.EXTERNAL.USER

    GOSUB INITIALISE
    GOSUB FIELD.VALIDATIONS
    RETURN


INITIALISE:
***********

    EB.Browser.SystemGetuservariables(YR.VARIABLE.NAMES,YR.VARIABLE.VALUES)
    LOCATE 'CURRENT.CUSTOMER' IN YR.VARIABLE.NAMES SETTING YR.POS.1 THEN
    YR.CUSTOMER.ID = YR.VARIABLE.VALUES<YR.POS.1>
    END
    RETURN


FIELD.VALIDATIONS:
******************

    TABLE.NAME   = "EB.EXTERNAL.USER"
    TABLE.SUFFIX = ""
    DAS.LIST     = DAS.EXT$CUSTOMER
    ARGUMENTS = YR.CUSTOMER.ID

    CALL DAS(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)


    Y.EXTERN.ID = DAS.LIST<1>

    IF NOT(Y.EXTERN.ID) THEN
        EB.SystemTables.setRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerPrefferedLogin, '')
        EB.SystemTables.setRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerArrangementNo, '')
        EB.SystemTables.setRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerInclude, '')
        EB.SystemTables.setRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerExclude, '')

        tmp=EB.SystemTables.getT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerArrangementNo); tmp<3>='NOINPUT'; EB.SystemTables.setT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerArrangementNo, tmp)
        tmp=EB.SystemTables.getT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerInclude); tmp<3>='NOINPUT'; EB.SystemTables.setT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerInclude, tmp)
        tmp=EB.SystemTables.getT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerExclude); tmp<3>='NOINPUT'; EB.SystemTables.setT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerExclude, tmp)
        GOSUB REFRESH.FLD
        RETURN
    END

    R.EB.EXTERNAL.USER = '' ; ERR.EB.EXTERNAL.USER = ''
    R.EB.EXTERNAL.USER = EB.ARC.ExternalUser.Read(Y.EXTERN.ID, ERR.EB.EXTERNAL.USER)

    IF R.EB.EXTERNAL.USER THEN
        EB.SystemTables.setRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerPrefferedLogin, Y.EXTERN.ID)
        IF R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuArrangement> THEN
            EB.SystemTables.setRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerArrangementNo, R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuArrangement>)
            tmp=EB.SystemTables.getT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerPrefferedLogin); tmp<3>='NOINPUT'; EB.SystemTables.setT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerPrefferedLogin, tmp)
        END ELSE
            EB.SystemTables.setRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerArrangementNo, '')
        END
    END ELSE
        EB.SystemTables.setRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerPrefferedLogin, '')
        EB.SystemTables.setRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerArrangementNo, '')
        EB.SystemTables.setRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerInclude, '')
        EB.SystemTables.setRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerExclude, '')

        tmp=EB.SystemTables.getT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerArrangementNo); tmp<3>='NOINPUT'; EB.SystemTables.setT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerArrangementNo, tmp)
        tmp=EB.SystemTables.getT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerInclude); tmp<3>='NOINPUT'; EB.SystemTables.setT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerInclude, tmp)
        tmp=EB.SystemTables.getT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerExclude); tmp<3>='NOINPUT'; EB.SystemTables.setT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerExclude, tmp)
    END
    GOSUB REFRESH.FLD
    RETURN

REFRESH.FLD:
    TEMP.AF  = EB.SystemTables.getAf()
    EB.Display.RefreshField(TEMP.AF, '')

    RETURN

    END
