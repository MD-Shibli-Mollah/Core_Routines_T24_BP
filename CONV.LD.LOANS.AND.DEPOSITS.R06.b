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
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LD.Contract
    SUBROUTINE CONV.LD.LOANS.AND.DEPOSITS.R06(LD.ID, LD.REC, LD.FILE)
**************************************************************************************************
* This conversion routine will update the value of FWD.PROJ field from LMM.INSTALL.CONDS
* to all the existing LD.LOANS.AND.DEPOSITS records at the time of upgrade.
*
**************************************************************************************************
*       MODIFICATION LOG
*       ----------------
*
* 12/02/08 - CI_10053663
*             Conversion routine to populate FWD.PROJ value in LD contracts
*             from LMM.INSTALL.CONDS.
**************************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LMM.INSTALL.CONDS

**************************************************************************************************
* equate
    EQU LD.FWD.PROJ TO 226,   ;* LD.LOANS.AND.DEPOSITS field FWD.PROJ
        LD30.FWD.PROJ TO 123      ;* FWD.PROJ field in LMM.INSTALL.CONDS

* main conversion process
PROCESS.CONVERSION:
*-----------------
    IF LD.REC<LD.FWD.PROJ> THEN
        RETURN                ;* return when FWD.PROJ has some value
    END ELSE
        GOSUB INITIALISE      ;* file opfs and read to be done only when a record is to be processed
        IF NOT(LMM.ERR) AND LMM.REC<LD30.FWD.PROJ> THEN
            LD.REC<LD.FWD.PROJ> = LMM.REC<LD30.FWD.PROJ>    ;* assign FWD.PROJ in LD with the value in INSTALL.CONDS
        END
    END

    RETURN
**************************************************************************************************
INITIALISE:
*--------------
    FN.LMM.INST.CONDS = 'F.LMM.INSTALL.CONDS'     ;*file name
    F.LMM.INST.CONDS = ''                         ;* file variable - opened inside EB.READ.PARAMETER
    LMM.ID = ''                                   ;* LMM.ID - EB.READ.PARAMETER to return the appropriate id
    LMM.REC = ''                                  ;*  LMM record
    LMM.ERR = ''                                  ;* error variable
* returns the appropriate company record - handles also the EMC installations
    CALL EB.READ.PARAMETER(FN.LMM.INST.CONDS, 'N', '', LMM.REC, LMM.ID, F.LMM.INST.CONDS, LMM.ERR)

    RETURN

**************************************************************************************************
END
