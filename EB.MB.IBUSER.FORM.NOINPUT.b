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
* <Rating>-16</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AI.ModelBank
    SUBROUTINE EB.MB.IBUSER.FORM.NOINPUT

**************************************************************
* Cross validation on Inter Banking User
**************************************************************
* 13/12/2010 - New Development
* Purpose    -  The routine repeat the validation same as Field validation.
* Developed By - Abinanthan K B
**************************************************************
*Modification History
*-----------------------------------------------------------------------------
* 18/05/15 - Enhancement-1326996/Task-1327012
*			 Incorporation of AI components
*-----------------------------------------------------------------------------
    $USING AI.ModelBank
    $USING EB.SystemTables
    $USING EB.ARC
    $USING EB.Display

    IF EB.SystemTables.getRNew(AI.ModelBank.EbMbIbuserForm.EbMbSevZerArrangementNo) EQ '' THEN
        tmp=EB.SystemTables.getT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerArrangementNo); tmp<3>='NOINPUT'; EB.SystemTables.setT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerArrangementNo, tmp)
        tmp=EB.SystemTables.getT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerInclude); tmp<3>='NOINPUT'; EB.SystemTables.setT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerInclude, tmp)
        tmp=EB.SystemTables.getT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerExclude); tmp<3>='NOINPUT'; EB.SystemTables.setT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerExclude, tmp)
    END ELSE
        tmp=EB.SystemTables.getT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerPrefferedLogin); tmp<3>='NOINPUT'; EB.SystemTables.setT(AI.ModelBank.EbMbIbuserForm.EbMbSevZerPrefferedLogin, tmp)
    END
    GOSUB REFRESH.FLD
    RETURN

REFRESH.FLD:
    TEMP.AF = EB.SystemTables.getAf()
    EB.Display.RefreshField(TEMP.AF, '')

    RETURN
    END
