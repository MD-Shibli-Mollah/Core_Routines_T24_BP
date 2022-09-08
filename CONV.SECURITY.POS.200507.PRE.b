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

* Version 3 02/06/00  GLOBUS Release No. G15.0.01 31/08/04
*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityPositionUpdate
    SUBROUTINE CONV.SECURITY.POS.200507.PRE
*-----------------------------------------------------------------------------
* Pre routine for conversion details CONV.SECURITY.POSITION.200507
* Will open all the SEC.ACC.MASTER files that the system has and pass
* them into the common.
*-----------------------------------------------------------------------------
* Modification History :
*
* 06/04/05 - GLOBUS_EN_10002471
*            New program
*
* 05/02/08 - GLOBUS_CI_10053569
*            Common variables defined in PRE.ROUTINE is not distributed
*            across multiple threads as PRE.ROUTINE is run only in a single thread,
*            hence system crashes while using these common variables.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_CONV.SECURITY.POS.200507.COMMON
    $INSERT I_F.COMPANY
*-----------------------------------------------------------------------------


    MAT SEC.ACC.MASTER.FILES = ''

* Open the current company SEC.ACC.MASTER file
    FN.SEC.ACC.MASTER = 'F.SEC.ACC.MASTER'
    F.SEC.ACC.MASTER = ''
    CALL OPF(FN.SEC.ACC.MASTER,F.SEC.ACC.MASTER)
    SEC.ACC.MASTER.FILES(1) = F.SEC.ACC.MASTER
    NEW.COMPANY.LIST = ID.COMPANY
    NEW.COMPANY.LIST<2> = FN.SEC.ACC.MASTER

    FN.COMPANY = 'F.COMPANY'
    F.COMPANY = ''
    CALL OPF(FN.COMPANY,F.COMPANY)

* select the other companies
    SELECT.STATEMENT = 'SELECT ':FN.COMPANY:' WITH @ID NE "':ID.COMPANY:'"'
    COMPANY.LIST = ''
    LIST.NAME = ''
    SELECTED = ''
    SYSTEM.RETURN.CODE = ''
    CALL EB.READLIST(SELECT.STATEMENT,COMPANY.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)

    LOOP
        REMOVE COMPANY.ID FROM COMPANY.LIST SETTING COMPANY.MARK
    WHILE COMPANY.ID : COMPANY.MARK
        COMPANY.REC = ''
        YERR = ''
        CALL F.READ(FN.COMPANY,COMPANY.ID,COMPANY.REC,F.COMPANY,YERR)
        ETEXT = ''
        SAM.FILE = 'F':COMPANY.REC<EB.COM.MNEMONIC>:'.SEC.ACC.MASTER':FM:'NO.FATAL.ERROR'
        CALL OPF(SAM.FILE,F.SAM.FILE)
        IF ETEXT = '' THEN
* if the file opened then add it to the list of available files.
            NEW.COMPANY.LIST<1,-1> = COMPANY.ID
            NEW.COMPANY.LIST<2,-1> = SAM.FILE<1>
            FILE.CNT = DCOUNT(NEW.COMPANY.LIST<1>,VM)
            SEC.ACC.MASTER.FILES(FILE.CNT) = F.SAM.FILE
        END
    REPEAT

    COMPANY.LIST = NEW.COMPANY.LIST
    NO.OF.COMPANIES = DCOUNT(NEW.COMPANY.LIST<1>,VM)

    RETURN

END
