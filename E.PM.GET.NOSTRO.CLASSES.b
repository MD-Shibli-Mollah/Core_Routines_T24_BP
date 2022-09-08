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
* <Rating>130</Rating>
*-----------------------------------------------------------------------------
* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05

    $PACKAGE PM.Reports
    SUBROUTINE E.PM.GET.NOSTRO.CLASSES(PARAM.ID, BAL.TYPES, NOSTRO.CLASSES)

* This subroutine will return the valid PM classes for nostro movements
* based on the details input on the PM.AC.PARAM record. The returned list
* contains only the 3rd and 4th characters of the all position classes
* which relate to nostro movements. This is because the PM.AC.PARAM record
* defines only the classes which relate to account balances or accruals
* and not the on-line movements. However the 3rd and 4th characters of
* any online movement class will be the same as those for the balance
* classes.
*
* INPUT
* =====
* PARAM.ID                : ID of PM.AC.PARAM record to use, ie CAS etc
* BAL.TYPES               : List of fields from PM.AC.PARAM from which
*                           classes are to be selected. This allows the
*                           calling routine to ask for just balance type
*                           classes or accrual type classes etc...
*
* OUTPUT
* ======
* NOSTRO.CLASSES          : List of 2 char class sub strings which are
*                           common to all nostro classes and which can
*                           therefore be compared to any other class to
*                           determine if it is a nostro class. The
*                           characters in question are the 3rd and 4th
*                           of the 5 character class. These are seperated
*                           by field marks.
*
************* Modifications ******************
*
* 26/10/15 - EN_1226121 / Task 1511358
*	      	 Routine incorporated
*
*-----------------------------------------------------------------------------
    $USING AC.Config
    $USING PM.Config
    $USING EB.DataAccess
    $USING PM.Reports

*-----------------------------------------------------------------------------

    F.ACCOUNT.CLASS = ''
    EB.DataAccess.Opf("F.ACCOUNT.CLASS",F.ACCOUNT.CLASS)

    F.PM.AC.PARAM = ''
    EB.DataAccess.Opf("F.PM.AC.PARAM",F.PM.AC.PARAM)

    NOSTRO.CLASSES = ''
    ER1 = ""
    NOSTRO.CLASS.REC = ""
    F.ACCOUNT.CLASS = AC.Config.AccountClass.Read("NOSTRO", ER1)
    IF ER1 THEN
        RETURN
    END
    NOSTRO.CATEGS = NOSTRO.CLASS.REC<AC.Config.AccountClass.ClsCategory>
    ER2 = ""
    AC.PARAM.REC = ""
    AC.PARAM.REC = PM.Config.AcParam.Read(PARAM.ID, ER2)
    IF ER2 THEN
        AC.PARAM.REC = ''
    END

    LOOP
        REMOVE CATEG FROM NOSTRO.CATEGS SETTING DELIM
    WHILE CATEG
        VM.NO = 0
        LOOP
            VM.NO += 1
            FROM.CATEG = AC.PARAM.REC<PM.Config.AcParam.ApCategoryFrom, VM.NO>
            TO.CATEG = AC.PARAM.REC<PM.Config.AcParam.ApCategoryTo, VM.NO>
        WHILE FROM.CATEG
            IF CATEG GE FROM.CATEG AND CATEG LE TO.CATEG THEN
                FLD.CNT = 0
                LOOP
                    FLD.CNT += 1
                    FLD.NO = BAL.TYPES<FLD.CNT>
                WHILE FLD.NO
                    TEST.CATEG = AC.PARAM.REC<FLD.NO,VM.NO>[3,2]
                    IF TEST.CATEG THEN
                        LOCATE TEST.CATEG IN NOSTRO.CLASSES<1> SETTING POSN ELSE
                        NOSTRO.CLASSES<-1> = TEST.CATEG
                    END
                END
            REPEAT
        END
    REPEAT
    REPEAT
*

    RETURN


******
    END
