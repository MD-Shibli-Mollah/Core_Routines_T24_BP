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
* <Rating>4</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.Contract
    SUBROUTINE CONV.AZ.HIST.FILES.R05
*
* 23/01/06 - CI_10038463
*            New conversion routine to update AZ.ACCOUNT>CURR.HIST.NO and
*            AZ.SCHEDULES>CURR.HIST.NO.
*
* 28/03/06 - EN_10002878
*            AZ modify history record updates.CURR.HIST.NO removed from AZ.ACCOUNT.
*
* 22/06/07 - CI_10049932
*            Changes made to select the COMPANY record with CONSOLIDATION.MARK set to "N".
*******************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.MNEMONIC.COMPANY
    $INSERT I_F.COMPANY
    $INSERT I_F.SPF
    $INSERT I_DAS.COMPANY
*

    SAVE.ID.COMPANY = ID.COMPANY

    COMPANIES = dasCompanyRealCompaniesById
    CALL DAS("COMPANY",COMPANIES,'','')

    LOOP
        REMOVE K.COMPANY FROM COMPANIES SETTING MORE.COMPANIES
    WHILE K.COMPANY:MORE.COMPANIES

        IF K.COMPANY NE ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
        LOCATE 'AZ' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING AZ.INSTALLED THEN
            GOSUB COMPANY.INITIALISATION          ;* COMPANY specific initialisation
            GOSUB PROCESS
        END

    REPEAT


    IF ID.COMPANY NE SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN


*-----------------------------------------------------------------------------
COMPANY.INITIALISATION:
* COMPANY specific initialisation
* open files and read records specific to each company


    FN.AZ.ACCOUNT = 'F.AZ.ACCOUNT' ; FV.AZ.ACCOUNT = ''
    CALL OPF(FN.AZ.ACCOUNT,FV.AZ.ACCOUNT)

    FN.AZ.SCHEDULES = 'F.AZ.SCHEDULES' ; FV.AZ.SCHEDULES = ''
    CALL OPF(FN.AZ.SCHEDULES,FV.AZ.SCHEDULES)

    FN.AZ.SCHEDULES.HIST = 'F.AZ.SCHEDULES.HIST' ; FV.AZ.SCHEDULES.HIST = ''
    CALL OPF(FN.AZ.SCHEDULES.HIST,FV.AZ.SCHEDULES.HIST)
*
    RETURN


*-----------------------------------------------------------------------------
PROCESS:
*

    FN.FILE = FN.AZ.SCHEDULES.HIST
    FILE.TO.WRITE = FV.AZ.SCHEDULES ; FIELD.TO.WRITE = 61
    GOSUB WRITE.FILES

    RETURN

*-----------------------------------------------------------------------------

WRITE.FILES:
    SEL.HIST = 'SSELECT ':FN.FILE:' WITH @ID LIKE ...-':TODAY:'...'
    CALL EB.READLIST(SEL.HIST,ID.LIST,'','',HIS.ERR)

    LAST.AZ.ID = ''; REC.TO.WRITE = '' ; AZ.COUNTER = ''
    LOOP
        REMOVE ID FROM ID.LIST SETTING YD
    WHILE YD:ID
        AZ.ID = FIELD(ID,'-',1)

        IF AZ.ID NE LAST.AZ.ID THEN
            IF LAST.AZ.ID THEN
                READU REC.TO.WRITE FROM FILE.TO.WRITE, AZ.ID   THEN
                    REC.TO.WRITE <FIELD.TO.WRITE > = TODAY:'-':AZ.COUNTER
                    WRITE REC.TO.WRITE TO FILE.TO.WRITE,AZ.ID
                END
            END
            LAST.AZ.ID = AZ.ID
            AZ.COUNTER = 1    ;* Initialise
        END ELSE    ;* Add to the end
            AZ.COUNTER += 1
        END
    REPEAT
    IF LAST.AZ.ID THEN
        READU REC.TO.WRITE FROM FILE.TO.WRITE, AZ.ID   THEN
            REC.TO.WRITE <FIELD.TO.WRITE > = TODAY:'-':AZ.COUNTER
            WRITE REC.TO.WRITE TO FILE.TO.WRITE,AZ.ID
        END
    END
    RETURN

*-----------------------------------------------------------------------------
*
END
