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
* <Rating>49</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.CashFlow
    SUBROUTINE CONV.CATEG.ENT.FWD.G141
******************************************************************************************

* In lower releases than G141, the categ.ent.fwd record format is different. The ID to the file
* is the category and the record contain the categ.entry.ids for that category.
* But from G141, the format of categ.ent.fwd is changed as below.
* ID : CATEGORY-SYSTEM.ID-CURRENCY-CATEG.ENTRY.ID ; Record : CATEG.ENRTY.ID
* Hence this conversion converts all the old format categ.ent.fwd's to the new format.

*******************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CATEGORY
    $INSERT I_F.STMT.ENTRY

    FN.CATEG.ENT.FWD = "F.CATEG.ENT.FWD"
    FV.CATEG.ENT.FWD = ""
    CALL OPF(FN.CATEG.ENT.FWD,FV.CATEG.ENT.FWD)

    FN.CATEG.ENTRY = "F.CATEG.ENTRY"
    FV.CATEG.ENTRY = ''
    CALL OPF(FN.CATEG.ENTRY,FV.CATEG.ENTRY)

    FN.CATEGORY = "F.CATEGORY"
    FV.CATEGORY = ""
    CALL OPF(FN.CATEGORY,FV.CATEGORY)

    EOL = '' ; CATEG.ENT.FWD.ID = ''

    SSELECT FV.CATEG.ENT.FWD

    LOOP
        READNEXT CATEG.ENT.FWD.ID ELSE
            EOL = 1
        END
    UNTIL EOL

        R.CATEGORY = '' ; YERR = ''
        CALL F.READ(FN.CATEGORY,CATEG.ENT.FWD.ID,R.CATEGORY,FV.CATEGORY,YERR)
        IF YERR THEN
            CONTINUE
        END

        R.CATEG.ENT.FWD = '' ; ER = '' ; NO.OF.SEL = ''

        CALL F.READ(FN.CATEG.ENT.FWD,CATEG.ENT.FWD.ID,R.CATEG.ENT.FWD,FV.CATEG.ENT.FWD,ER)

        IF NOT(ER) THEN
            NO.OF.SEL = DCOUNT(R.CATEG.ENT.FWD,FM)

            FOR I = 1 TO NO.OF.SEL

                R.CATEG.ENTRY = '' ; ERR = '' ; Y.CURRENCY = '' ; Y.SYSTEM.ID = '' ; Y.ID = ''

                CALL F.READ(FN.CATEG.ENTRY,R.CATEG.ENT.FWD<I>,R.CATEG.ENTRY,FV.CATEG.ENTRY,ERR)

                IF NOT(ERR) THEN
                    Y.SYSTEM.ID = R.CATEG.ENTRY<AC.STE.SYSTEM.ID>
                    Y.CURRENCY = R.CATEG.ENTRY<AC.STE.CURRENCY>
                    Y.ID = CATEG.ENT.FWD.ID:"-":Y.SYSTEM.ID:"-":Y.CURRENCY:"-":R.CATEG.ENT.FWD<I>

                    WRITE R.CATEG.ENT.FWD<I> TO FV.CATEG.ENT.FWD, Y.ID
                END

            NEXT I
            DELETE FV.CATEG.ENT.FWD, CATEG.ENT.FWD.ID
        END

    REPEAT

    RETURN
END
****************************************************************************************************
