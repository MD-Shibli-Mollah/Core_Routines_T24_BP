* @ValidationCode : MjotMjcwNTkyOTI6Q3AxMjUyOjE1NjQ1NjMyMjI3OTQ6c3JhdmlrdW1hcjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA3LjIwMTkwNjEyLTAzMjE6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Jul 2019 14:23:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>263</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.StmtPrinting
SUBROUTINE CONV.STMT.NARR.FORMAT.TYPE
*-----------------------------------------------------------------------------
* Modification History:
*----------------------
* 30/07/19 - Enhancement 3246717 / Task 3181742
*            TI Changes - Component moved from ST to AC.
*
*-----------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
** This routine moves all records from Fxxx.STMT.NARR.FORMAT
** to F.STMT.NARR.FORMAT
*
    SEL.CMD = "SELECT F.COMPANY SAVING MNEMONIC"
    CALL EB.READLIST(SEL.CMD, CO.LIST, "", "", "")
*
    F.STMT.NARR.FORMAT = ""
    CALL OPF("F.STMT.NARR.FORMAT",F.STMT.NARR.FORMAT)      ; * Open to F....
    F.STMT.NARR.FORMAT$NAU = ""
    CALL OPF("F.STMT.NARR.FORMAT$NAU",F.STMT.NARR.FORMAT$NAU)        ; * Open to F....
    F.STMT.NARR.FORMAT$HIS = ""
    CALL OPF("F.STMT.NARR.FORMAT$HIS",F.STMT.NARR.FORMAT$HIS)        ; * Open to F....
*
    LOOP
        REMOVE MNE FROM CO.LIST SETTING YD
    WHILE MNE:YD
        OPEN "F":MNE:".STMT.NARR.FORMAT" TO F.SNF THEN
            SEL.CMD = "SELECT F":MNE:".STMT.NARR.FORMAT"
            ID.LIST = ""
            CALL EB.READLIST(SEL.CMD,ID.LIST,"","","")
            LOOP
                REMOVE YID FROM ID.LIST SETTING YD2
            WHILE YID:YD2
                READ YR.SNF FROM F.SNF, YID THEN
                    READ YR.SNF.NEW FROM F.STMT.NARR.FORMAT, YID ELSE
                        WRITE YR.SNF TO F.STMT.NARR.FORMAT, YID
                    END
                END
            REPEAT
        END
        OPEN "F":MNE:".STMT.NARR.FORMAT$NAU" TO F.SNF THEN
            SEL.CMD = "SELECT F":MNE:".STMT.NARR.FORMAT$NAU"
            ID.LIST = ""
            CALL EB.READLIST(SEL.CMD,ID.LIST,"","","")
            LOOP
                REMOVE YID FROM ID.LIST SETTING YD2
            WHILE YID:YD2
                READ YR.SNF FROM F.SNF, YID THEN
                    READ YR.SNF.NEW FROM F.STMT.NARR.FORMAT$NAU, YID ELSE
                        WRITE YR.SNF TO F.STMT.NARR.FORMAT$NAU, YID
                    END
                END
            REPEAT
        END
        OPEN "F":MNE:".STMT.NARR.FORMAT$HIS" TO F.SNF THEN
            SEL.CMD = "SELECT F":MNE:".STMT.NARR.FORMAT$HIS"
            ID.LIST = ""
            CALL EB.READLIST(SEL.CMD,ID.LIST,"","","")
            LOOP
                REMOVE YID FROM ID.LIST SETTING YD2
            WHILE YID:YD2
                READ YR.SNF FROM F.SNF, YID THEN
                    READ YR.SNF.NEW FROM F.STMT.NARR.FORMAT$HIS, YID ELSE
                        WRITE YR.SNF TO F.STMT.NARR.FORMAT$HIS, YID
                    END
                END
            REPEAT
        END
    REPEAT
*
RETURN
*
END
