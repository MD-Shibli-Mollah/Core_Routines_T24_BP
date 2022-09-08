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
* <Rating>135</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MG.RateChange
    SUBROUTINE CONV.MG.RATE.EXCEPTION
*-----------------------------------------------------
* 15/12/08 - BG_100021299
*            Conversion fails while running RUN.CONVERSION.PGMS
*
*-----------------------------------------------------
*
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.COMPANY
    $INSERT I_F.MG.RATE.EXCEPTION
    $INSERT I_F.FILE.CONTROL
*
    ETEXT = ''
    SAVE.ID.COMPANY = ID.COMPANY
*
* Loop through each company
* Not for Consolidation and Reporting companies
*
    FN.MG.RATE.EXCEPTION = 'F.MG.RATE.EXCEPTION'
    FV.MG.RATE.EXCEPTION = ''
    CALL OPF(FN.MG.RATE.EXCEPTION,FV.MG.RATE.EXCEPTION)
*
    CLEARFILE FV.MG.RATE.EXCEPTION
    FN.FILE.CONTROL = 'F.FILE.CONTROL'
    FV.FILE.CONTROL = ''
    CALL OPF(FN.FILE.CONTROL,FV.FILE.CONTROL)
*
    FILE.CONTROL.ID = "MG.RATE.EXCEPTION"
    FILE.CONTROL.REC = ''
    FILE.CONTROL.ERR = ''
    READ FILE.CONTROL.REC FROM FV.FILE.CONTROL ,FILE.CONTROL.ID THEN
        FILE.CONTROL.REC<EB.FILE.CONTROL.CLASS> = "FIN"
        WRITE FILE.CONTROL.REC TO FV.FILE.CONTROL,FILE.CONTROL.ID
    END
*
*
    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')
    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
    WHILE K.COMPANY:COMP.MARK
        ER = ''
        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
        IF R.COMPANY(EB.COM.MNEMONIC) NE R.COMPANY(EB.COM.FINAN.FINAN.MNE) THEN
            LOCATE 'MG' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING FOUND.POS THEN
                FILE.ID = "MG.RATE.EXCEPTION"
                CALL EBS.CREATE.FILE(FILE.ID,'',ER)
                IF ER THEN
                    E = 'UNABLE TO CREATE ':FILE.ID
                    GOTO FATAL.ERROR
                END
            END
        END
    REPEAT
*
* Processing now complete for all companies.
* Change back to the original company if we have changed.
*
    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END
*
    RETURN
*
FATAL.ERROR:
*
    E = "FATAL ERROR OPENING FILE"
    CALL ERR
    CALL PGM.BREAK
    RETURN
*
END
*
*
