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
    SUBROUTINE CONV.SAFECUSTODY.EXT.200712(ID.SAFECUSTODY.EXT, R.SAFECUSTODY.EXT, FN.SAFECUSTODY.EXT)
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

    EQU CUSTOMER TO 1,        DEPOSITORY TO 2,
    SECURITY.CODE TO 3,    PRICE.CURRENCY TO 4,
    ACT.CLOSING.NOM TO 5,    ACT.CL.NOM.LCY TO 6,
    MARKET.PRICE TO 7,   PRICE.CCY.XRATE TO 8,
    ACT.MRKT.VAL.LCY TO 9,         EXT.DATE TO 10,
    MARKET.VAL.LCY TO 11,  CLOSING.NOM.LCY TO 12,
    CL.NOM.IN.LCY TO 13,  AVG.CLOSING.NOM TO 14,
    AVG.CL.NOM.LCY TO 15,  AVG.AST.BAL.LCY TO 16,
    MARKET.VAL.SCY TO 17,
    AVG.AST.BAL.SCY TO 18,        PORTFOLIO TO 27,
    ACT.MRKT.VAL.SCY TO 28,
    SECURITY.CCY TO 29,          PRODUCT TO 30

    CCY.MKT = 1
    SECURITY.MASTER.ID = FIELD(ID.SAFECUSTODY.EXT,'.',3)
    IF INDEX(SECURITY.MASTER.ID,';',1) THEN
        SECURITY.MASTER.ID = FIELD(SECURITY.MASTER.ID,';',1)
    END
    PORTFOLIO.NO = FIELD(ID.SAFECUSTODY.EXT,'.',1)

    CCY.DATE = ''
    MAIN.CCY.DATE = ''

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

    RETURN

*-----------------------------------------------------------------------------

PROCESS.FIELDS:

    SECURITY.CURRENCY = R.SECURITY.MASTER<SC.SCM.SECURITY.CURRENCY>

    NO.OF.DAYS = DCOUNT(R.SAFECUSTODY.EXT<EXT.DATE>,VM)
    FOR DAY = 1 TO NO.OF.DAYS

        CCY.DATE = R.SAFECUSTODY.EXT<EXT.DATE,DAY>
        IF NOT(MAIN.CCY.DATE) THEN
            MAIN.CCY.DATE = CCY.DATE
        END

        AMOUNT.TO.CONV = R.SAFECUSTODY.EXT<MARKET.VAL.LCY,DAY>
        GOSUB CALL.EXCHRATE
        R.SAFECUSTODY.EXT<MARKET.VAL.SCY,DAY> = AMOUNT.REQUIRED

        AMOUNT.TO.CONV = R.SAFECUSTODY.EXT<AVG.AST.BAL.LCY,DAY>
        GOSUB CALL.EXCHRATE
        R.SAFECUSTODY.EXT<AVG.AST.BAL.SCY,DAY> = AMOUNT.REQUIRED

    NEXT DAY

    CCY.DATE = MAIN.CCY.DATE

    AMOUNT.TO.CONV = R.SAFECUSTODY.EXT<ACT.MRKT.VAL.LCY>
    GOSUB CALL.EXCHRATE
    R.SAFECUSTODY.EXT<ACT.MRKT.VAL.SCY> = AMOUNT.REQUIRED

    R.SAFECUSTODY.EXT<SECURITY.CCY> = SECURITY.CURRENCY
    R.SAFECUSTODY.EXT<PRODUCT> = "SC"

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
    CALL FATAL.ERROR('CONV.SAFECUSTODY.EXT.200712')
*
END
