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
* <Rating>-59</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScfAdvisoryFees
    SUBROUTINE CONV.SC.ADV.FEES.ACT.200712(ID.SC.ADV.FEES.ACT, R.SC.ADV.FEES.ACT, FN.SC.ADV.FEES.ACT)
*-----------------------------------------------------------------------------
* This conversion routine will update the new SECURITY.CCY fields with the currency
* and values applicable to that currency
*-----------------------------------------------------------------------------
* Modification History:
*
* 30/10/07 - EN_10003555
*            SAR-2007-09-03-0003
*
*
* 04/01/08 - GLOBUS_BG_100016549 - dgearing@temenos.com
*            fatal error in conversion process, security.currency not set and
*            wrong field for tot.avg.ast.bal
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

    EQU REFERENCE.CCY TO 1, DAY.NO TO 2,
    SUB.AST.TYPE TO 3, NOMINAL TO 4,
    NOMINAL.LCY TO 5, ASSET.BAL TO 6,
    ASST.BAL.SCY TO 7, ASSET.ID TO 8,
    SECURITY.CCY TO 9, PRODUCT TO 10, TOT.AVG.NOMINAL TO 14,
    TOT.AVG.NOM.LCY TO 15, TOT.AVG.AST.BAL TO 16,
    TOT.AVG.AST.SCY TO 17, SECURITY.CODE TO 24

    CCY.MKT = 1
    SECURITY.MASTER.ID = FIELD(ID.SC.ADV.FEES.ACT,'.',2)
    PORTFOLIO.NO = FIELD(ID.SC.ADV.FEES.ACT,'.',1)
    YEAR.MONTH = FIELD(ID.SC.ADV.FEES.ACT,'.',3)
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

    NO.OF.DAYS = DCOUNT(R.SC.ADV.FEES.ACT<DAY.NO>,VM)
    FOR DAY = 1 TO NO.OF.DAYS
        CCY.DATE = YEAR.MONTH:R.SC.ADV.FEES.ACT<DAY.NO,DAY>
        NO.OF.SUB.ASSETS = DCOUNT(R.SC.ADV.FEES.ACT<SUB.AST.TYPE,DAY>,SM)
        FOR ASSET = 1 TO NO.OF.SUB.ASSETS
            IF NOT(DOING.SECURITY) THEN
                GOSUB GET.FROM.SUB.ASSET          ;* get data from sub.asset & sc.pos.asset records
            END ELSE
                SECURITY.CURRENCY = R.SECURITY.MASTER<SC.SCM.SECURITY.CURRENCY>
                PRODUCT.ID = "SC"
            END

            AMOUNT.TO.CONV = R.SC.ADV.FEES.ACT<ASSET.BAL,DAY,ASSET>
            GOSUB CALL.EXCHRATE
            R.SC.ADV.FEES.ACT<ASST.BAL.SCY,DAY,ASSET> = AMOUNT.REQUIRED
            R.SC.ADV.FEES.ACT<SECURITY.CCY,DAY,ASSET> = SECURITY.CURRENCY
            R.SC.ADV.FEES.ACT<PRODUCT,DAY,ASSET> = PRODUCT.ID
        NEXT ASSET

        AMOUNT.TO.CONV = R.SC.ADV.FEES.ACT<TOT.AVG.AST.BAL,DAY>
        GOSUB CALL.EXCHRATE
        R.SC.ADV.FEES.ACT<TOT.AVG.AST.SCY,DAY> = AMOUNT.REQUIRED
    NEXT DAY

    IF DOING.SECURITY THEN
        R.SC.ADV.FEES.ACT<SECURITY.CODE> = SECURITY.MASTER.ID
    END

    RETURN

*-----------------------------------------------------------------------------
CALL.EXCHRATE:

    AMOUNT.REQUIRED = ''
    D1="" ; D2="" ; D3="" ; D4="" ; RET.CODE=""
    CCY.BUY = LCCY
    IF CCY.DATE THEN
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

*-----------------------------------------------------------------------------
FATAL:
***********
*
    CALL FATAL.ERROR('CONV.SC.ADV.FEES.ACT.200712')
*
    RETURN

*-----------------------------------------------------------------------------
*** <region name= GET.FROM.SUB.ASSET>
GET.FROM.SUB.ASSET:
*** <desc>get data from sub.asset & sc.pos.asset records</desc>

* for assets build the key from portfolio.subasset.asset
* do a cache.read on sub.asset.type for the asset.
    SUB.ASSET.TYPE.ID = R.SC.ADV.FEES.ACT<SUB.AST.TYPE,DAY,ASSET>
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
            PRODUCT.ID = R.SC.POS.ASSET<SC.PAS.APPLICATION,1>
        END ELSE
* sc.pos.asset no longer exists, but we can get the product from
* asset.type, need to set security.currency otherwise exchrate call will crash
            CALL CACHE.READ('F.ASSET.TYPE',ASSET.TYPE.ID,R.ASSET.TYPE,'')
            SECURITY.CURRENCY = LCCY    ;* don't know! but set to prevent fatal
            PRODUCT.ID = R.ASSET.TYPE<3>          ;* Val.interface field
        END
    END

    RETURN
*** </region>
END
