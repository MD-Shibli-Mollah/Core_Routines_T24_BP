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
* <Rating>-67</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccEntitlements
    SUBROUTINE CONV.SC.ENT.MANUAL.R08

* Conversion Routine for the removal of SC.ENT.MANUAL concat file and
* updating MANUAL.CREATION field in Entitlement as 'YES'
*
* 12/05/07 - EN_10003330
*            DB Benchmark changes to improve Corporate Action Scalability
*
*
* 09/04/09 - GLOBUS_CI_10062039
*            Only compilation for change in common file
*
* 03/12/09 - DEFECT - 8864
*            Fatal Error while running Conversion CONV.SC.ENT.MANUAL.R08
*            in companies in which doesn't have SC product .
*******************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY.CHECK
    $INSERT I_DAS.COMMON
    $INSERT I_DAS.COMPANY
    $INSERT I_DAS.SC.ENT.MANUAL
    $INSERT I_F.ENTITLEMENT
    $INSERT I_F.COMPANY
    GOSUB MAIN.PROCESS

    RETURN

*---------------
MAIN.PROCESS:
*---------------
* Loop through each company

    SAVE.COMPANY = ID.COMPANY

    FN.COMPANY.CHECK = 'F.COMPANY.CHECK'
    F.COMPANY.CHECK = ''
    CALL OPF(FN.COMPANY.CHECK, F.COMPANY.CHECK)

    COMP.LIST = DAS.COMPANY$REAL.COMPANIES
    THE.ARGS = ''
    TABLE.SUFFIX = ''
    CALL DAS('COMPANY', COMP.LIST, THE.ARGS, TABLE.SUFFIX)

    LOOP
        REMOVE K.COMPANY FROM COMP.LIST SETTING MORE.COMP
    WHILE K.COMPANY:MORE.COMP

        READ R.COMP.CHECK FROM F.COMPANY.CHECK, 'FINANCIAL' THEN
            LOCATE K.COMPANY IN R.COMP.CHECK<EB.COC.COMPANY.CODE,1> SETTING POS ELSE
                CONTINUE
            END
        END

        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
        LOCATE 'SC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING SC.INSTALLED THEN
            GOSUB PROCESS.EACH.COMPANY
        END
    REPEAT

    IF ID.COMPANY <> SAVE.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.COMPANY)
    END

    RETURN

*----------------------
PROCESS.EACH.COMPANY:
*----------------------

    GOSUB OPEN.FILES

    MANUAL.ENT.LIST = dasAllIds
    THE.ARGS = ''
    TABLE.SUFFIX = ''
    CALL DAS('SC.ENT.MANUAL', MANUAL.ENT.LIST, THE.ARGS, TABLE.SUFFIX)

    LOOP
        REMOVE LIST.REF FROM MANUAL.ENT.LIST SETTING MORE.REC
    WHILE LIST.REF:MORE.REC

        R.SC.ENT.MANUAL = ''
        READ R.SC.ENT.MANUAL FROM F.SC.ENT.MANUAL, LIST.REF ELSE
            CONTINUE
        END

        LOOP
            REMOVE ENT.ID FROM R.SC.ENT.MANUAL SETTING MORE.ENT
        WHILE ENT.ID:MORE.ENT

            GOSUB UPD.INAU.ENT

            GOSUB UPD.AUT.ENT

            GOSUB UPD.HIST.ENT

        REPEAT

        DELETE F.SC.ENT.MANUAL, LIST.REF

    REPEAT

    RETURN


*-------------
OPEN.FILES:
*-------------

    FN.SC.ENT.MANUAL = 'F.SC.ENT.MANUAL'
    F.SC.ENT.MANUAL = ''
    CALL OPF(FN.SC.ENT.MANUAL, F.SC.ENT.MANUAL)

    FN.ENTITLEMENT = 'F.ENTITLEMENT'
    F.ENTITLEMENT = ''
    CALL OPF(FN.ENTITLEMENT, F.ENTITLEMENT)

    FN.ENTITLEMENT.NAU = 'F.ENTITLEMENT$NAU'
    F.ENTITLEMENT.NAU = ''
    CALL OPF(FN.ENTITLEMENT.NAU, F.ENTITLEMENT.NAU)

    FN.ENTITLEMENT.HIS = 'F.ENTITLEMENT$HIS'
    F.ENTITLEMENT.HIS = ''
    CALL OPF(FN.ENTITLEMENT.HIS, F.ENTITLEMENT.HIS)

    RETURN

*----------------
UPD.INAU.ENT:
*----------------

* INAU file

    R.ENT.NAU = ''
    READ R.ENT.NAU FROM F.ENTITLEMENT.NAU, ENT.ID THEN
        IF R.ENT.NAU<SC.ENT.MANUAL.CREATION> <> "YES" THEN
            R.ENT.NAU<SC.ENT.MANUAL.CREATION> = "YES"
            WRITE R.ENT.NAU ON F.ENTITLEMENT.NAU, ENT.ID
        END
    END

    RETURN

*---------------
UPD.AUT.ENT:
*---------------

* LIVE file

    R.ENT = ''
    READ R.ENT FROM F.ENTITLEMENT, ENT.ID THEN
        IF R.ENT<SC.ENT.MANUAL.CREATION> <> "YES" THEN
            R.ENT<SC.ENT.MANUAL.CREATION> = "YES"
            WRITE R.ENT ON F.ENTITLEMENT, ENT.ID
        END
    END

    RETURN

*---------------
UPD.HIST.ENT:
*---------------

* HISTORY file

    R.ENT.HIS = ''
    SEQ.NO = 1
    LOOP
        HIS.ID = ENT.ID:';':SEQ.NO
    WHILE HIS.ID
        READ R.ENT.HIS FROM F.ENTITLEMENT.HIS, HIS.ID ELSE
            EXIT
        END
        IF R.ENT.HIS<SC.ENT.MANUAL.CREATION> <> "YES" THEN
            R.ENT.HIS<SC.ENT.MANUAL.CREATION> = "YES"
            WRITE R.ENT.HIS ON F.ENTITLEMENT, HIS.ID
        END
        SEQ.NO += 1
    REPEAT

    RETURN

    END
