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
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.Config
    SUBROUTINE CONV.ACCOUNT.PARAMETER.201405(ID,R.ACCT.PAR,FILE)
*-----------------------------------------------------------------------------
* Modification History:
*
* 07/05/2014 - Defect  855516 / Task 1018548
*              Conversion introduced to set the field NET.LOCKED.OVERRIDE in
*              ACCOUNT.PARAMETER table based on the comment/text "NET.OD.AA"
*              from the ADDITIONAL.INFORMATION field in the PGM.FILE of the
*              ACCOUNT.PARAMETER record.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB INITIALISE
    GOSUB CHECK.NET.OD.AND.LOCKED.PARAM ;* To do conv for adding fields to account parameter for relating to netting entries for Overdrafts & Locked Amounts check

*-----------------------------------------------------------------------------
INITIALISE:
*----------

    NO.UPDATE.CONT.ACTIVITY = ""
    ADDITIONAL.INFO.FLAG = ""
    NEW.LOCKING.POSITION = ""
    ADDITIONAL.INFO = ""
    R.PGM.FILE = ""
    F.PGM.FILE = ""
    LOCK.COUNT = ""
    POS = ""
    ERR = ""

    RETURN
*-----------------------------------------------------------------------------
CHECK.NET.OD.AND.LOCKED.PARAM:
*-----------------------------
    PGM.FILE.ID = "ACCOUNT.PARAMETER"
    CALL F.READ("F.PGM.FILE",PGM.FILE.ID,R.PGM.FILE,F.PGM.FILE,ERR)   ;* Read pgm.file of ACCOUNT.PARAMETER
    IF NOT(ERR) THEN
        ADDITIONAL.INFO = R.PGM.FILE<3> ;* Store the values from the field ADDITIONAL.INFO to a local variable
        ADDITIONAL.INFO.FLAG = INDEX(ADDITIONAL.INFO, 'NET.OD.AA', 1) ;* Check for the value NET.OD.AA in the variable, and set the flag
    END

* If flag set, this means the client has been using the option of netting entires relating to AA for checking OD & Locked Amounts

    IF ADDITIONAL.INFO.FLAG THEN
        CHK.FIELD.COUNT = DCOUNT(R.ACCOUNT.PARAMETER<51>,VM)          ;* Get the total multivalue set for the field NET.OD.APPL in the account.parameter record
        NEW.FIELD.POS = CHK.FIELD.COUNT + 1       ;* Increase the count by one
        R.ACCT.PAR<51,NEW.FIELD.POS> = 'AA'       ;* Add a new multivalue set by defaulting the values AA & YES & YES which means
        R.ACCT.PAR<52,NEW.FIELD.POS> = 'YES'      ;* For all entries relating to application AA, net entries to check OD
        R.ACCT.PAR<53,NEW.FIELD.POS> = 'YES'      ;* as well net entries for checking the Locked Amounts
    END

    RETURN
*-----------------------------------------------------------------------------
    END
