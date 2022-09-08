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
* <Rating>-41</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScfSafekeepingFees
    SUBROUTINE CONV.SC.SAFEKEEP.ACT.200712(ID.SAFEKEEP.ACT, R.SAFEKEEP.ACT, FN.SAFEKEEP.ACT)
*-----------------------------------------------------------------------------
* This conversion routine will update the new SECURITY.CCY fields with the currency
* and values applicable to that currency
*-----------------------------------------------------------------------------
* Modification History:
*
* 30/10/07 - EN_10003555
*            SAR-2007-09-03-0003
*
* 05/02/08 - GLOBUS_CI_10053569
*            Common variables defined in PRE.ROUTINE is not distributed
*            across multiple threads as PRE.ROUTINE is run only in a single thread,
*            hence system crashes while using these common variables.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SECURITY.MASTER

* Initialise
    GOSUB INITIALISATION

* Clear fields

    GOSUB PROCESS.FIELDS

    RETURN

*-----------------------------------------------------------------------------
INITIALISATION:

    EQU DAY.NO TO 1,      CLOSING.NOM TO 2,
    CLOSING.NOM.LCY TO 3,    ASSET.BAL.LCY TO 4,
    AVG.CL.NOM.LCY TO 5,  AVG.CLOSING.NOM TO 6,
    AVG.AST.BAL.LCY TO 7,    ASSET.BAL.SCY TO 8,
    AVG.AST.BAL.SCY TO 9,
    SECURITY.CCY TO 17,         PRODUCT TO 18,
    SECURITY.CODE TO 19

    CCY.MKT = 1
    SECURITY.MASTER.ID = FIELD(ID.SAFEKEEP.ACT,'.',3)
    PORTFOLIO.NO = FIELD(ID.SAFEKEEP.ACT,'.',1)
    YEAR.MONTH = FIELD(ID.SAFEKEEP.ACT,'.',4)
    CCY.DATE = ''

    FN.SECURITY.MASTER = 'F.SECURITY.MASTER'
    F.SECURITY.MASTER = ''
    CALL OPF(FN.SECURITY.MASTER,F.SECURITY.MASTER)

    FN.SC.POS.ASSET = 'F.SC.POS.ASSET'
    F.SC.POS.ASSET = ''
    CALL OPF(FN.SC.POS.ASSET,F.SC.POS.ASSET)

    R.SECURITY.MASTER = ''
    YERR = ''
    CALL F.READ(FN.SECURITY.MASTER,SECURITY.MASTER.ID,R.SECURITY.MASTER,F.SECURITY.MASTER,YERR)
    IF YERR THEN
        TEXT = YERR
        GOSUB FATAL
    END

    SECURITY.CURRENCY = R.SECURITY.MASTER<SC.SCM.SECURITY.CURRENCY>

    RETURN

*-----------------------------------------------------------------------------

PROCESS.FIELDS:

    NO.OF.DAYS = DCOUNT(R.SAFEKEEP.ACT<DAY.NO>,VM)
    FOR DAY = 1 TO NO.OF.DAYS

        CCY.DATE = YEAR.MONTH:R.SAFEKEEP.ACT<DAY.NO,DAY>

        AMOUNT.TO.CONV = R.SAFEKEEP.ACT<ASSET.BAL.LCY,DAY>
        GOSUB CALL.EXCHRATE
        R.SAFEKEEP.ACT<ASSET.BAL.SCY,DAY> = AMOUNT.REQUIRED

        AMOUNT.TO.CONV = R.SAFEKEEP.ACT<AVG.AST.BAL.LCY,DAY>
        GOSUB CALL.EXCHRATE
        R.SAFEKEEP.ACT<AVG.AST.BAL.SCY,DAY> = AMOUNT.REQUIRED

    NEXT DAY

    R.SAFEKEEP.ACT<SECURITY.CCY> = SECURITY.CURRENCY
    R.SAFEKEEP.ACT<SECURITY.CODE> = SECURITY.MASTER.ID
    R.SAFEKEEP.ACT<PRODUCT> = "SC"

    RETURN

CALL.EXCHRATE:

    AMOUNT.REQUIRED = ''
    D1="" ; D2="" ; D3="" ; D4="" ; RET.CODE=""
    CCY.BUY = LCCY
    IF CCY.DATE NE '' THEN
        CCY.BUY<1,2> = CCY.DATE
    END
    IF CCY.BUY<1,1> = SECURITY.CURRENCY OR AMOUNT.TO.CONV = 0 THEN
        AMOUNT.REQUIRED = AMOUNT.TO.CONV
    END ELSE
        CALL EXCHRATE (CCY.MKT, CCY.BUY, AMOUNT.TO.CONV, SECURITY.CURRENCY, AMOUNT.REQUIRED, D1,D2,D3,D4,RET.CODE)
    END
    IF ETEXT <> "" THEN
        TEXT = ETEXT
        GOSUB FATAL
    END

    RETURN

***********
FATAL:
***********
*
    CALL FATAL.ERROR('CONV.SC.SAFEKEEP.ACT.200712')
*
END
