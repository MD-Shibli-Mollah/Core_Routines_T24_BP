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
* <Rating>69</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OP.ModelBank
    SUBROUTINE OR.PRINT.FORM

*28/02/2011 RHW      Move document name tag to inside the main xml
*03/03/2011 RHW      Replace any & characters with "and"


    $USING OP.ModelBank
    $USING EB.DataAccess
    $USING EB.API
    $USING EB.SystemTables


    IF EB.SystemTables.getComi() THEN

        GOSUB INITIALISE
        GOSUB PROCESS
    END

    RETURN


INITIALISE:
    YR.EB.PRINT.FORMS = 'EB.PRINT.FORMS'
    FN.EB.PRINT.FORMS = 'F.':YR.EB.PRINT.FORMS
    FV.EB.PRINT.FORMS = ''
    EB.DataAccess.Opf(FN.EB.PRINT.FORMS,FV.EB.PRINT.FORMS)

    FN.LOCAL.OUTPUT = 'LOCAL.EFSOUT'
    FV.LOCAL.OUTPUT = ''
    OPEN FN.LOCAL.OUTPUT TO FV.LOCAL.OUTPUT ELSE NULL

        RETURN


PROCESS:
        YR.OUTPUT.REC = EB.SystemTables.getDynArrayFromRNew()
        YR.APPLICATION = EB.SystemTables.getApplication()
        ID.NEW.VAL = EB.SystemTables.getIdNew()
        EB.API.ReadXml(ID.NEW.VAL,YR.APPLICATION,YR.OUTPUT.REC)
        CHANGE "&" TO "and" IN YR.OUTPUT.REC

        APP.VER = EB.SystemTables.getApplication():EB.SystemTables.getPgmVersion()
        R.EB.PRINT.FORMS = ""
        EB.DataAccess.FRead(FN.EB.PRINT.FORMS,APP.VER,R.EB.PRINT.FORMS,FV.EB.PRINT.FORMS,RTN.ERROR)
        IF R.EB.PRINT.FORMS = "" THEN
            YR.OUTPUT.REC.ID = APP.VER
        END ELSE
            YR.OUTPUT.REC.ID = R.EB.PRINT.FORMS<OP.ModelBank.PrintForms.EbPriTwoThrForm>
        END
        *
*** Now insert the document name tag inside the main xml structure
        *
        documentTag = "<formName>":YR.OUTPUT.REC.ID:"</formName>"
        firstEndMarker = INDEX(YR.OUTPUT.REC,">",1)
        newOutputRec = YR.OUTPUT.REC[1,firstEndMarker]:documentTag:YR.OUTPUT.REC[firstEndMarker+1,999999]
        WRITE newOutputRec TO FV.LOCAL.OUTPUT,YR.OUTPUT.REC.ID:"-":EB.SystemTables.getIdNew()
            EB.SystemTables.setComi("")
            *
            RETURN

        END
