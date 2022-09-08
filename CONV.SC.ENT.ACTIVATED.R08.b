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
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccEntitlements
    SUBROUTINE CONV.SC.ENT.ACTIVATED.R08
* Conversion Routine for the removal of SC.ENT.ACTIVATED records.

* 14/05/07 - EN_10003330
*            DB Benchmark changes to improve Corporate Action Scalability
*
* 09/04/09 - GLOBUS_CI_10062039
*            Only compilation for change in common file
*
* 08/04/10 - DEFECT - 38712
*            Fatal Error while running Conversion in R09 .
*
*-------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY.CHECK
    $INSERT I_DAS.COMMON
    $INSERT I_DAS.COMPANY
    $INSERT I_DAS.SC.ENT.ACTIVATED
    $INSERT I_F.COMPANY

    GOSUB MAIN.PROCESS

    RETURN

*-----------------
MAIN.PROCESS:
*-----------------

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

    RETURN

*----------------------
PROCESS.EACH.COMPANY:
*----------------------

    FN.SC.ENT.ACTIVATED = 'F.SC.ENT.ACTIVATED'
    F.SC.ENT.ACTIVATED = ''
    CALL OPF(FN.SC.ENT.ACTIVATED, F.SC.ENT.ACTIVATED)

    ENT.ACTIVATED.LIST = dasAllIds
    THE.ARGS = ''
    TABLE.SUFFIX = ''
    CALL DAS('SC.ENT.ACTIVATED', ENT.ACTIVATED.LIST, THE.ARGS, TABLE.SUFFIX)

    LOOP
        REMOVE LIST.REF FROM ENT.ACTIVATED.LIST SETTING MORE.ENT
    WHILE LIST.REF:MORE.ENT
        DELETE F.SC.ENT.ACTIVATED,LIST.REF
    REPEAT

    RETURN

    END
