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

* Version 1 15/12/05  GLOBUS Release No. DEV 
*-----------------------------------------------------------------------------
* <Rating>476</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.CashFlow
    SUBROUTINE CONV.CATEG.ENT.FWD
************************************************************************
* Conversion routine to make CATEG.ENT.FWD a key only file.
************************************************************************
* Modification History:
*
*
*
************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CATEG.ENTRY

    YF.CATEG.ENT.FWD = "F.CATEG.ENT.FWD"
    F.CATEG.ENT.FWD = ""
    CALL OPF(YF.CATEG.ENT.FWD,F.CATEG.ENT.FWD)

    F.CATEG.ENTRY = ""
    CALL OPF("F.CATEG.ENTRY",F.CATEG.ENTRY)

    PRINT @(5,9):
    SELECT.COMMAND = "SELECT ":YF.CATEG.ENT.FWD
    YCATEGORIES = ""
    CALL EB.READLIST(SELECT.COMMAND, YCATEGORIES, "CONV.CATEG", "", "")

    PRINT @(5,6): "Converting CATEG.ENT.FWD ":

    LOOP
        REMOVE YCAT FROM YCATEGORIES SETTING YDELIM
        IF YCAT THEN
            PRINT @(5,7):"Converting ":YCAT
            READ YR.CAT.ENT.FWD FROM F.CATEG.ENT.FWD, YCAT THEN
*
                IF INDEX(YCAT,"-",1) THEN         ;* Converted already
                    YR.CAT.ENT.FWD = YCAT["-",4,1]          ;* Entry id
                    WRITE YR.CAT.ENT.FWD TO F.CATEG.ENT.FWD, YCAT
                END ELSE
                    LOOP
                        REMOVE YCAT.ENT.ID FROM YR.CAT.ENT.FWD SETTING YID.DELIM
                        IF YCAT.ENT.ID THEN
                            READ YR.CATEG.ENTRY FROM F.CATEG.ENTRY,YCAT.ENT.ID THEN
                                YNEW.ID = YR.CATEG.ENTRY<AC.CAT.PL.CATEGORY>:"-":YR.CATEG.ENTRY<AC.CAT.SYSTEM.ID>:"-":YR.CATEG.ENTRY<AC.CAT.CURRENCY>:"-":YCAT.ENT.ID
                                WRITE YCAT.ENT.ID TO F.CATEG.ENT.FWD,YNEW.ID
                            END ELSE NULL
                        END
                    UNTIL YID.DELIM = 0
                    REPEAT
                    DELETE F.CATEG.ENT.FWD,YCAT
                END
            END ELSE NULL
        END
    UNTIL YDELIM = 0
    REPEAT

    RETURN
    END
