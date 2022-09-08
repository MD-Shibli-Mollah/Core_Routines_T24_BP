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
* <Rating>-62</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScfAdvisoryFees
    SUBROUTINE CONV.SC.ASSET.BAL.200712(ID.SC.ASSET.BAL, R.SC.ASSET.BAL, FN.SC.ASSET.BAL)
*-----------------------------------------------------------------------------
* This conversion routine will update the new SECURITY.CCY fields with the currency
* and values applicable to that currency
*-----------------------------------------------------------------------------
* Modification History:
*
* 30/10/07 - EN_10003555
*            SAR-2007-09-03-0003
*
* 04/01/08 - GLOBUS_BG_100016548 - dgearing@temenos.com
*            fatal error in conversion process, security.currency not set.
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
    $INSERT I_F.SUB.ASSET.TYPE
    $INSERT I_F.SC.POS.ASSET

* Initialise
    GOSUB INITIALISATION

* Clear fields
    GOSUB PROCESS.FIELDS

    RETURN

*-----------------------------------------------------------------------------
INITIALISATION:

    EQU CUSTOMER TO 1, REFERENCE.CCY TO 2,
    EXT.DATE TO 3, SUB.AST.TYPE TO 4,
    NOMINAL TO 5, NOMINAL.LCY TO 6,
    ASSET.BAL TO 7, AST.BAL.SCY TO 8,
    SECURITY.CCY TO 9, PRODUCT TO 10, ASSET.ID TO 11,
    TOT.ASSET.BAL TO 15, TOT.AVG.NOMINAL TO 16,
    TOT.AVG.NOM.LCY TO 17, TOT.AVG.AST.BAL TO 18,
    TOT.AST.BAL.SCY TO 19, TOT.AV.AS.BL.SC TO 20, PORTFOLIO TO 26,
    SECURITY.CODE TO 27

    CCY.MKT = 1
    SECURITY.MASTER.ID = FIELD(ID.SC.ASSET.BAL,'.',2)
    SECURITY.MASTER.ID = FIELD(SECURITY.MASTER.ID,';',1)    ;* allow for history keys
    PORTFOLIO.NO = FIELD(ID.SC.ASSET.BAL,'.',1)
    DOING.SECURITY = @TRUE
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
        DOING.SECURITY = @FALSE
    END

    RETURN

*-----------------------------------------------------------------------------
PROCESS.FIELDS:

    NO.OF.DAYS = DCOUNT(R.SC.ASSET.BAL<EXT.DATE>,VM)
    FOR DAY = 1 TO NO.OF.DAYS
        CCY.DATE = R.SC.ASSET.BAL<EXT.DATE,DAY>
        NO.OF.SUB.ASSETS = DCOUNT(R.SC.ASSET.BAL<SUB.AST.TYPE,DAY>,SM)
        FOR ASSET = 1 TO NO.OF.SUB.ASSETS
            IF NOT(DOING.SECURITY) THEN
                GOSUB GET.FROM.SUB.ASSET          ;* Get data from sub.asset and sc.pos.asset
            END ELSE
                SECURITY.CURRENCY = R.SECURITY.MASTER<SC.SCM.SECURITY.CURRENCY>
                R.SC.ASSET.BAL<PRODUCT,DAY,ASSET> = "SC"
            END

            AMOUNT.TO.CONV = R.SC.ASSET.BAL<ASSET.BAL,DAY,ASSET>
            GOSUB CALL.EXCHRATE
            R.SC.ASSET.BAL<AST.BAL.SCY,DAY,ASSET> = AMOUNT.REQUIRED

            R.SC.ASSET.BAL<SECURITY.CCY,DAY,ASSET> = SECURITY.CURRENCY
        NEXT ASSET

        AMOUNT.TO.CONV = R.SC.ASSET.BAL<TOT.ASSET.BAL,DAY>
        GOSUB CALL.EXCHRATE
        R.SC.ASSET.BAL<TOT.AST.BAL.SCY,DAY> = AMOUNT.REQUIRED

        AMOUNT.TO.CONV = R.SC.ASSET.BAL<TOT.AVG.AST.BAL,DAY>
        GOSUB CALL.EXCHRATE
        R.SC.ASSET.BAL<TOT.AV.AS.BL.SC,DAY> = AMOUNT.REQUIRED

    NEXT DAY

    RETURN

*-----------------------------------------------------------------------------
CALL.EXCHRATE:

    AMOUNT.TO.CONV += 0
    AMOUNT.REQUIRED = ''
    D1="" ; D2="" ; D3="" ; D4="" ; RET.CODE=""
    CCY.BUY = LCCY
    IF CCY.DATE THEN
        CCY.BUY<1,2> = CCY.DATE
    END
    IF CCY.BUY<1,1> NE SECURITY.CURRENCY AND AMOUNT.TO.CONV NE 0 THEN
* only do the conversion if the currencies differ and the amount to convert is not zero or null
        CALL EXCHRATE (CCY.MKT, CCY.BUY, AMOUNT.TO.CONV, SECURITY.CURRENCY, AMOUNT.REQUIRED, D1,D2,D3,D4,RET.CODE)
        IF ETEXT <> "" THEN
            TEXT = ETEXT
            GOSUB FATAL
        END
    END ELSE
        AMOUNT.REQUIRED = AMOUNT.TO.CONV
    END

    RETURN

*-----------------------------------------------------------------------------
FATAL:
***********
*
    CALL FATAL.ERROR('CONV.SC.ASSET.BAL.200712')
*
    RETURN

*-----------------------------------------------------------------------------
*** <region name= GET.FROM.SUB.ASSET>
GET.FROM.SUB.ASSET:
*** <desc>Get data from sub.asset and sc.pos.asset</desc>

* for assets build the key from portfolio.subasset.asset
* do a cache.read on sub.asset.type for the asset.
    SUB.ASSET.TYPE.ID = R.SC.ASSET.BAL<SUB.AST.TYPE,DAY,ASSET>
    R.SUB.ASSET.TYPE = ''
    YERR = ''
    CALL CACHE.READ('F.SUB.ASSET.TYPE',SUB.ASSET.TYPE.ID,R.SUB.ASSET.TYPE,YERR)
    IF NOT(YERR) THEN
        ASSET.TYPE.ID = R.SUB.ASSET.TYPE<SC.CSG.ASSET.TYPE.CODE>
        SC.POS.ASSET.ID = PORTFOLIO.NO:'.':SUB.ASSET.TYPE.ID:'.':ASSET.TYPE.ID
        R.SC.POS.ASSET = ''
        YERR = ''
        CALL F.READ(FN.SC.POS.ASSET,SC.POS.ASSET.ID,R.SC.POS.ASSET,F.SC.POS.ASSET,YERR)
        IF NOT(YERR) THEN
            SECURITY.CURRENCY = R.SC.POS.ASSET<SC.PAS.SECURITY.CCY,1>
            R.SC.ASSET.BAL<PRODUCT,DAY,ASSET> = R.SC.POS.ASSET<SC.PAS.APPLICATION,1>
        END ELSE
* sc.pos.asset no longer exists, but we can get the product from
* asset.type, must set currency to something otherwise the exchrate call
* will crash
            CALL CACHE.READ('F.ASSET.TYPE',ASSET.TYPE.ID,R.ASSET.TYPE,'')
            SECURITY.CURRENCY = LCCY    ;* don't know! but we have to set something
            R.SC.ASSET.BAL<PRODUCT,DAY,ASSET> = R.ASSET.TYPE<3>       ;* Val.interface field
        END
    END

    RETURN
*** </region>
END
