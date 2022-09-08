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
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.Config
    SUBROUTINE CONV.ACCOUNT.PARAMETER.201402(ID,R.ACCT.PAR,FILE)
*-----------------------------------------------------------------------------
* Modification History:
* 22/01/2014 - Defect 886665 / Task 893538
*              Conversion introduced to set the field UPD.CONT.ACTIVITY in
*              ACCOUNT.PARAMETER table based on the comment/text "NO.UPDATE"
*              from the ADDITIONAL.INFORMATION field in the PGM.FILE of the
*              CONT.ACTIVITY record.
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

* Read the PGM.FILE and update the field UPD.CONT.ACTIVITY in account.parameter
    NO.UPDATE.CONT.ACTIVITY = ''
    PGM.FILE.ID = "CONT.ACTIVITY"
    ADDITIONAL.INFO = ""
    R.PGM.FILE = ""
    F.PGM.FILE = ""
    POS = ""
    ERR = ""

    CALL F.READ("F.PGM.FILE",PGM.FILE.ID,R.PGM.FILE,F.PGM.FILE,ERR)     ;* Read pgm.file of CONT.ACTIVITY
    IF NOT(ERR) THEN
        ADDITIONAL.INFO = R.PGM.FILE<3>                                 ;* Store the values from the field ADDITIONAL.INFO to a local variable
        CONVERT "." TO FM IN ADDITIONAL.INFO
        LOCATE 'NOUPDATE' IN ADDITIONAL.INFO SETTING POS THEN           ;* Look if there is any comment with NOUPDATE, which means CONT.ACTIVITY not be updated
            NO.UPDATE.CONT.ACTIVITY = 1                                 ;* Set flag for no updation
        END
    END

    IF NO.UPDATE.CONT.ACTIVITY THEN
        R.ACCT.PAR<104> = "NO"                                          ;* Set the parameter field in the Account.Parameter record
    END

    RETURN
    END
