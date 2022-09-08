* @ValidationCode : MjoxMjM4NzU2NjQ1OkNwMTI1MjoxNTcwNzg5NTU1NjM2OmthamFheXNoZXJlZW46LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOS4yMDE5MDgyMy0wMzA1Oi0xOi0x
* @ValidationInfo : Timestamp         : 11 Oct 2019 15:55:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kajaayshereen
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201909.20190823-0305
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>1767</Rating>
*-----------------------------------------------------------------------------
$PACKAGE ST.ExchangeRate

SUBROUTINE EB.WRITE.EXCHANGE.RATES(CONTRACT.ID,ARRAY.1,ARRAY.2,ARRAY.3)

* Subroutine to update SETTLEMENT.RATES file.
* The schedule dates and types are obtained from
* LD.SCHEDULE.DEFINE.
* This program is called from LD.LOANS.AND.DEPOSITS
* both at input and at authorisation.
*
*  ARRAY.1 will have 'LD.AUTH.SR' when its called from LD during
*             authorisation of a LD record.
* From now on,  (CI_10055864)
*      LD input at INAU - will create SR in INAU with INPUTTER= <TNO>_LD.AUTO
*      LD is authorised - will authorise SR with INPUTTER = <OPERATOR>
*
*****************************************************************************
*               MODIFICATION LOG
*               ----------------
* 12/10/01 - BG_100000140
*            Bugs in FX LD. Related CD is EN_10000119
*
* 24/10/01 - BG_100000158
*            Consider the drawdown account also while
*            creating the SETTLEMENT.RATES file
*
* 29/10/01 - BG_100000177
*            If the contract is call/notice
*            and the drawdown currency is
*            the same as the liquidation
*            currency then do not
*            create SETTLEMENT.RATES record
*
* 09/11/01 - BG_100000210
*            Bugs in FX-LD.
*
* 26/02/02 - BG_100000593
*            Restructured the program for generic call
*
* 20/05/02 - CI_10002018
*            Records in the SETTLEMENT.RATES file  created by a LD is not
*            properly updated with the AUDIT details.
*
* 23/05/02 - EN_10000410
*            Changes made to store and restore V value.
* 06/03/03 - CI_10007215
*            SETTLEMENT.RATES needs to be populated for
*            all schedule types if they have different
*            currency
*
* 16/02/04 - CI_10017408
*            Changes to update company code and dept code for new
*            record in LD.
*
* 03/06/04 - CI_10020316
*            Reversed LD causes Trans Journal difference.
*
* 01/09/04 - CI_10022788
*            The routine is now called from LD.EOD4.PROCESS as well,
*            to update the Exchange rates of contracts turning CUR from
*            FWD. Routine has also been cleaned up of unnecessary
*            initialisations.
*
* 05/06/08 - CI_10055883
*            FIX for updation of SETTLEMENT.RATES for LD records.
*            This routine will be called both during INAU and AUTH stage
*            of a LD record input.
*            At INAU stage, it will write to $NAU file and at auth
*            stage to the LIVE file.
*
* 23/03/09 - BG_100022911
*            Variable DEAL.CCY uninitialisation problem during authorisation
*
* 09/10/09 - CI_10066863
*            SETTLEMENT.RATES updated wrongly during amendment
*
* 11/11/11 - Task_306728
*			 Ref : Defect_302899
*	         Mismatch of common variable FULL.FNAME while restoring back
*
* 11/04/2017 - Enhancement-1765879/Task-2101385 - sathiyavendan@temenos.com
*              Remove dependency of code in ST products
*
* 11/10/19 - Enhancement 2822520 / Task 3380702
*            Code changed done for componentisation and to avoid errors while compilation
*            using strict compile
*************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SETTLEMENT.RATES
    $INSERT I_F.COMPANY
    $INSERT I_F.USER          ;*CI_10017408 -S/E
    $INSERT I_F.SPF
*
* If ID not equal to LD return


*     Initialise variables and open files

    GOSUB INITIALISE

    GOSUB GET.LD.SETTLEMENT.RATES

    V = SAVE.V      ;* EN_10000410 S/E
RETURN
*
INITIALISE:
*~~~~~~~~~~
*
    DIM SR.REC(SR.AUDIT.DATE.TIME)
    DIM SR.TEMP.REC(SR.AUDIT.DATE.TIME)

    MAT SR.TEMP.REC = ''
    MAT SR.REC = ''
    DIM SR.REC.NAU(SR.AUDIT.DATE.TIME)
    MAT SR.REC.NAU = ''

    LD.AUTH.SR = '' ;* flag variable to write nau SR record to live file
    LD.UNAUTH.UPDATE = ''     ;* flag variable to create SR in nau stage
    SYSTEM.ONLINE = ''        ;* OPERATION.MODE of T24 system
    IF R.SPF.SYSTEM<SPF.OP.MODE> EQ 'O' THEN
        SYSTEM.ONLINE = 1     ;* flag variable
    END
    IF APPLICATION EQ 'LD.LOANS.AND.DEPOSITS' AND SYSTEM.ONLINE THEN  ;* only for LD online
        IF V$FUNCTION EQ 'I' THEN
            LD.UNAUTH.UPDATE = 1
        END
        IF V$FUNCTION EQ 'A'  THEN
            F.SR.NAU = ''
            READ.ERR = ''
            CALL F.MATREAD('F.SETTLEMENT.RATES$NAU',CONTRACT.ID, MAT SR.REC.NAU,SR.AUDIT.DATE.TIME,F.SR.NAU,NAU.ERR)
            IF ARRAY.1 EQ 'LD.AUTH.SR' THEN
                LD.AUTH.SR = 1          ;* flag to authorise SR records in INAU
            END
        END
    END

    SR.ID = CONTRACT.ID       ;* moved from GET.LD.SETTLEMENT.RATES para -


    DIM SAVE.R.NEW(V)
    DIM SAVE.R.OLD(V)         ;* CI_10002018 S
    MAT SAVE.R.NEW = MAT R.NEW
    MAT SAVE.R.OLD = MAT R.OLD          ;* CI_10002018 E
    SAVE.V = ''     ;* EN_10000401 S
    SAVE.V = V
    SAVE.INPUTTER = ''
    SAVE.INPUTTER = R.NEW(V-6)          ;* EN_10000410 E
    CUR.NO = 0
    FUTURE.USER.RATES = ''

    FN.CR = 'F.SETTLEMENT.RATES' ; FV.CR = ''
    CALL OPF(FN.CR, FV.CR)
    IF NOT(LD.AUTH.SR) THEN   ;* not required for authorising INAU SR record.
        CURRENCY.ARR = ''
        CURRENCY.ARR = FIELD(ARRAY.1,@FM,2)
        SET.DATES = ''
        SET.DATES = FIELD(ARRAY.1,@FM,1)
        DEAL.CCY = ''
        DD.CCY = ''
        SETTLEMENT.MKT = ''
        CONVERSION.TYPE = ''
        PROTECTION.CLAUSE = ''
        CUR.CCY = ''
        DEAL.CCY = ARRAY.3<1,1>
        SETTLEMENT.MKT = ARRAY.3<1,2>
        CONVERSION.TYPE = ARRAY.3<1,3>
        PROTECTION.CLAUSE = ARRAY.3<1,4>
        DD.CCY = ARRAY.3<1,5>
*
        EQU PR TO 1, INT TO 2, CH TO 3, CO TO 4, FE TO 5, DD TO 6
*
*  Get all the currencies of the accounts involved in the contract
*  and store them in the CURRENCY.ARR


* HISTORY is used to indicate if there are any historic event dates in the
* SETTLEMENT.RATES table

        HISTORY = ''
    END
RETURN
*
*
GET.LD.SETTLEMENT.RATES:
*~~~~~~~~~~~~~~~~~~~~~

*  Check if SETTLEMENT.RECORD is to be created
    IF NOT(LD.AUTH.SR) THEN   ;* not required for authorising INAU SR record.
        SR.RECORD.NEEDED = ''

        IF DEAL.CCY NE LCCY THEN        ;* CI_10020316 S
            SR.RECORD.NEEDED = 'TRUE'
        END         ;* CI_10020316 E

        CTR = 0
        CTR = DCOUNT(CURRENCY.ARR,@VM)
        FOR CHECK.INDEX = 1 TO CTR      ;* Except drawdown  * BG_100000158 S/E
            CUR.CCY = CURRENCY.ARR<1,CHECK.INDEX>
            CURR.COUNT=DCOUNT(CUR.CCY,@SM)         ;* CI_10007215 S
            FOR CURR.CHECK= 1 TO CURR.COUNT
                IF CUR.CCY<1,1,CURR.CHECK> AND CUR.CCY<1,1,CURR.CHECK> NE DEAL.CCY THEN   ;* CI_10007215 S
                    SR.RECORD.NEEDED = 'TRUE'
                END
            NEXT CURR.CHECK   ;* CI_10007215 E
        NEXT CHECK.INDEX

*     Check if Contract.Rates record exists for this id
*     i.e., modifying existing record or it is a new record

        NEW.RECORD = ''
        AMEND.RECORD = ''
        SR.ID = CONTRACT.ID
        CALL F.MATREAD(FN.CR, SR.ID, MAT SR.REC, SR.AUDIT.DATE.TIME,FV.CR,SR.READ.ERR)
        V = SR.AUDIT.DATE.TIME          ;* CI_10002018 S
        DIM YR.NEW(V)
        MAT YR.NEW = MAT SR.REC         ;* CI_10002018 E
        IF SR.READ.ERR EQ '' THEN
* The record should not be deleted right away
* check whether there are any historic event dates
* if any historic event dates exist they should not be deleted
*
            GOSUB CHECK.FOR.HISTORIC.EVENT.DATES
            IF NOT(HISTORY) AND NOT(SR.RECORD.NEEDED) THEN
                GOTO GET.LD.SETTLEMENT.RATES.EXIT
            END
            CUR.NO = SR.REC(SR.CURR.NO)
        END

        IF SR.READ.ERR THEN
            NEW.RECORD = 'TRUE'         ;* new record
        END ELSE
            AMEND.RECORD = 'TRUE'       ;* Amending record
        END
*
*
* If not new record update the existing record
*
        IF NOT(SR.RECORD.NEEDED) THEN
            IF NOT(HISTORY) THEN
                GOTO GET.LD.SETTLEMENT.RATES.EXIT
            END ELSE
                GOTO LD.WRITE.SETTLEMENT.RATES
            END
        END

*     Check if a record exists in ld.schedule.define$nau
* If the contract type is BULLET, update only the
* liquidation schedules
*
*
        TTLTYPE = ''          ;* No of schedule types for the contract
        CTR = 0
        CTR = DCOUNT(CURRENCY.ARR,@VM)
        EVE.DATE = ''
        FOR I = 1 TO CTR
            EVE.DATE = SET.DATES<1,I>
            IF NOT(EVE.DATE) THEN GOTO SKIP.DT
            LOCATE EVE.DATE<1> IN SR.TEMP.REC(SR.EVENT.DATE)<1,1> BY "AR" SETTING POSY ELSE
                ACCT.CCY = ''
                ACCT.CCY = CURRENCY.ARR<1,I>
                CURR.COUNT=DCOUNT(ACCT.CCY,@SM)    ;* CI_10007215 S
                FOR CURR.CHECK= 1 TO CURR.COUNT
                    IF ACCT.CCY<1,1,CURR.CHECK> NE DEAL.CCY THEN      ;* CI_10007215
                        LOCATE EVE.DATE<1> IN SR.TEMP.REC(SR.EVENT.DATE)<1,1> BY "AR" SETTING CUS.POSY ELSE CUS.POSY = 0
                        IF NOT(CUS.POSY) THEN     ;* CI_10007215
                            INS EVE.DATE BEFORE SR.TEMP.REC(SR.EVENT.DATE)<1,POSY>
                        END   ;* CI_10007215
                    END
                NEXT CURR.CHECK         ;* CI_10007215 E
            END
SKIP.DT:
        NEXT I
        FOR I = 1 TO CTR
            EVE.DATE = SET.DATES<1,I>
            LOCATE EVE.DATE<1> IN SR.TEMP.REC(SR.EVENT.DATE)<1,1> BY "AR" SETTING POSY ELSE
            END
            ACCT.CCY = ''
            ACCT.CCY = CURRENCY.ARR<1,I>
            CURR.COUNT=DCOUNT(ACCT.CCY,@SM)        ;* CI_10007215 S
            FOR CURR.CHECK= 1 TO CURR.COUNT
                IF ACCT.CCY<1,1,CURR.CHECK> NE DEAL.CCY OR ACCT.CCY<1,1,CURR.CHECK> # DD.CCY THEN
                    LOCATE ACCT.CCY<1,1,CURR.CHECK> IN SR.TEMP.REC(SR.EVENT.CCY)<1,POSY,1> SETTING CCY.POS ELSE
                        INS ACCT.CCY<1,1,CURR.CHECK> BEFORE SR.TEMP.REC(SR.EVENT.CCY)<1,POSY,1>     ;* CI_10007215
*  Check for any FUTURISTIC USER DEFINED RATES
                        USER.DEFINED.RATE = ''
                        SEARCH.STR = EVE.DATE:ACCT.CCY
                        F.INDEX = ''
                        FIND SEARCH.STR IN FUTURE.USER.RATES SETTING F.INDEX THEN
                            USER.DEFINED.RATE = FUTURE.USER.RATES<F.INDEX,2>
                            INS USER.DEFINED.RATE BEFORE SR.TEMP.REC(SR.EV.APPL.RATE)<1,POSY,1>
                        END
                    END
                END
            NEXT CURR.CHECK   ;* CI_100007215 E
        NEXT I
    END
* TTLTYPE contains the number of Schedule Types for the contract


LD.WRITE.SETTLEMENT.RATES:

    IF NOT(LD.AUTH.SR) THEN   ;* not necessary for new INAU SR record
        SR.TEMP.REC(SR.CONTRACT.CCY) = DEAL.CCY
        SR.TEMP.REC(SR.PROTECTION.CLAUSE) = PROTECTION.CLAUSE         ;* Default value
        SR.TEMP.REC(SR.SETTLEMENT.MARKET) = SETTLEMENT.MKT
        SR.TEMP.REC(SR.CONVERSION.TYPE) = CONVERSION.TYPE
        SR.TEMP.REC(SR.AMOUNT.TYPE) = SR.REC(SR.AMOUNT.TYPE)
        SR.TEMP.REC(SR.EXCG.RATE) = SR.REC(SR.EXCG.RATE)
        SR.TEMP.REC(SR.ACCOUNT) = SR.REC(SR.ACCOUNT)
        SR.TEMP.REC(SR.CURR.NO) = SR.REC(SR.CURR.NO)        ;* CI_10002018 S/E
        SR.TEMP.REC(SR.CO.CODE) =  ID.COMPANY     ;* CI_10017408 -S
        SR.TEMP.REC(SR.DEPT.CODE) = R.USER<EB.USE.DEPARTMENT.CODE>    ;* CI_10017408 -E
    END
    BEGIN CASE      ;* CI_10022788-S
        CASE LD.AUTH.SR ;* for SR update INAU to live, read INAU , populate AUDIT fields and write directly or using
            GOSUB WRITE.TO.FILE   ;* write, delete, auth and hist write for INAU SR records
        CASE NEW.RECORD OR AMEND.RECORD
            GOSUB GET.AUDIT.FIELDS.DATA
            GOSUB UPDATE.SR.REC
            IF LD.UNAUTH.UPDATE THEN        ;* write to NAU file
                CALL F.MATWRITE('F.SETTLEMENT.RATES$NAU',SR.ID,MAT SR.TEMP.REC,SR.AUDIT.DATE.TIME)
            END ELSE    ;* write to live file
                CALL F.MATWRITE(FN.CR, SR.ID, MAT SR.TEMP.REC, SR.AUDIT.DATE.TIME)
            END
        CASE NOT(SYSTEM.ONLINE)   ;* RUNNING.UNDER.BATCH
            GOSUB UPDATE.SR.REC
            GOSUB WRITE.SETTLEMENT.RATES

        CASE OTHERWISE
            GOSUB WRITE.SETTLEMENT.RATES
    END CASE        ;* CI_10022788-E

GET.LD.SETTLEMENT.RATES.EXIT:
RETURN          ;*  GET.LD.SETTLEMENT.RATES
*
*
*
*
WRITE.SETTLEMENT.RATES:
*~~~~~~~~~~~~~~~~~~~~
*     save variables

    IF SR.TEMP.REC(1) EQ '' THEN
        RETURN
    END
    SR.TEMP.FULL.NAME = FULL.FNAME
    SR.TEMP.FILE = F.FILE
    SR.TEMP.ID.CONCATFILE = ID.CONCATFILE
    F.FILE$NAU.SR.TEMP = F.FILE$NAU
    F.FILE$HIS.SR.TEMP = F.FILE$HIS
    SR.TEMP.APPL = APPLICATION
    SR.TEMP.ID.NEW = ID.NEW

*     update
    FULL.FNAME = FN.CR
    F.FILE = FV.CR
    APPLICATION = 'SETTLEMENT.RATES'
    ID.NEW = SR.ID
    MAT R.NEW = ''  ;* Nullify R.NEW, it will contain LD record details
    SR.TEMP.REC(SR.CURR.NO) -= 1        ;* Decrement the CURR.NO by 1, since it will be increment in AUTH.AND.HIST.WRITE
    V = SR.AUDIT.DATE.TIME
    MAT R.NEW = MAT SR.TEMP.REC         ;* CI_10002018 S/E
    CALL AUTH.AND.HIST.WRITE

*     restore variables
    MAT R.NEW = MAT SAVE.R.NEW          ;* CI_10002018 S
    MAT R.OLD = MAT SAVE.R.OLD          ;* CI_10002018 E
    F.FILE = SR.TEMP.FILE
    F.FILE$NAU = F.FILE$NAU.SR.TEMP
    F.FILE$HIS = F.FILE$HIS.SR.TEMP
    APPLICATION = SR.TEMP.APPL
    FULL.FNAME = SR.TEMP.FULL.NAME
    ID.CONCATFILE = SR.TEMP.ID.CONCATFILE
    ID.NEW = SR.TEMP.ID.NEW

RETURN          ;* WRITE.SETTLEMENT.RATES

*
GET.AUDIT.FIELDS.DATA:
*~~~~~~~~~~~~~~~~~~~~~
*
    IF LD.UNAUTH.UPDATE THEN  ;* to updae SR record in $NAU file
        SR.TEMP.REC(SR.INPUTTER) = TNO:'_LD.AUTO' ;* for INAU SR record
        SR.TEMP.REC(SR.RECORD.STATUS) = 'INAU'
    END ELSE
        SR.TEMP.REC(SR.INPUTTER) = SAVE.INPUTTER
        SR.TEMP.REC(SR.AUTHORISER) = TNO:"_":OPERATOR
    END
    TIME.STAMP = TIMEDATE()
    X = OCONV(DATE(),"D-")
    DT = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
    SR.TEMP.REC(SR.DATE.TIME) = DT
    IF NOT(LD.AUTH.SR) THEN   ;* Update the CURR.NO only during UNAUTH stage, during authorisation it will be taken from SR$NAU record
        SR.TEMP.REC(SR.CURR.NO) = IF CUR.NO = 0 THEN 1 ELSE (CUR.NO + 1)
    END

RETURN          ;* GET.AUDIT.FIELDS.DATA

*
*************************************************************************
CHECK.FOR.HISTORIC.EVENT.DATES:
*******************************
*
    HISTORY = ''
    NO.DATES = DCOUNT(SR.REC(SR.EVENT.DATE),@VM)
    FOR DATE.INDEX = 1 TO NO.DATES
        CHECK.EVENT.DATE = SR.REC(SR.EVENT.DATE)<1,DATE.INDEX>
        GOSUB CHECK.DATE
    NEXT DATE.INDEX
    IF NOT(HISTORY) AND NOT(SR.RECORD.NEEDED) THEN
        CALL F.DELETE(FN.CR, SR.ID)
        GOTO GET.LD.SETTLEMENT.RATES.EXIT
    END
RETURN
*
CHECK.DATE:
***********

    REGION = ''
    DAYS = 'C'
    REGION = R.COMPANY(EB.COM.LOCAL.REGION)
    IF REGION = " " THEN
        REGION = "00"
    END
    REGION = REGION:R.COMPANY(EB.COM.LOCAL.COUNTRY)
    CALL CDD(REGION,CHECK.EVENT.DATE,TODAY,DAYS)
    IF DAYS GT 0 THEN         ;* CI_10007215 S-E
        HISTORY = 'TRUE'
* also store the event date and the currencies with the two rates
*
        NO.CCYS = ''
        NO.CCYS = DCOUNT(SR.REC(SR.EVENT.CCY)<1,DATE.INDEX>,@SM)
        LOCATE CHECK.EVENT.DATE IN SR.TEMP.REC(SR.EVENT.DATE)<1,1> BY "AR" SETTING HIST.POS ELSE
            INS CHECK.EVENT.DATE BEFORE SR.TEMP.REC(SR.EVENT.DATE)<1,HIST.POS>
        END
        LOCATE CHECK.EVENT.DATE IN SR.TEMP.REC(SR.EVENT.DATE)<1,1> BY "AR" SETTING HIST.POS ELSE HIST.POS = ''
        FOR CCYS.INDEX = 1 TO NO.CCYS
            CCY.STR = SR.REC(SR.EVENT.CCY)<1,DATE.INDEX,CCYS.INDEX>
            CCY.SYS.RATE = SR.REC(SR.EV.SYS.RATE)<1,DATE.INDEX,CCYS.INDEX>
            CCY.APPL.RATE = SR.REC(SR.EV.APPL.RATE)<1,DATE.INDEX,CCYS.INDEX>
            INS CCY.STR BEFORE SR.TEMP.REC(SR.EVENT.CCY)<1,HIST.POS,1>
            INS CCY.SYS.RATE BEFORE SR.TEMP.REC(SR.EV.SYS.RATE)<1,HIST.POS,1>
            INS CCY.APPL.RATE BEFORE SR.TEMP.REC(SR.EV.APPL.RATE)<1,HIST.POS,1>
        NEXT CCYS.INDEX
    END ELSE
*
        NO.USER.RATES = ''
        NO.USER.RATES = DCOUNT(SR.REC(SR.EV.APPL.RATE)<1,DATE.INDEX>,@SM)
        FOR USER.RATE.INDEX = 1 TO NO.USER.RATES
            USER.RATE = ''
            USER.RATE = SR.REC(SR.EV.APPL.RATE)<1,DATE.INDEX,USER.RATE.INDEX>
            IF USER.RATE THEN
                USER.DATE = SR.REC(SR.EVENT.DATE)<1,DATE.INDEX>
                USER.CCY = SR.REC(SR.EVENT.CCY)<1,DATE.INDEX,USER.RATE.INDEX>
                FUTURE.USER.RATES<-1> = USER.DATE:USER.CCY:@VM:USER.RATE
            END
        NEXT USER.RATE.INDEX
*
    END
*
RETURN
*
UPDATE.SR.REC:
*~~~~~~~~~~~~~
*
* CI_10022788 - SR.REC variable done away with. Now all details
* are stored in SR.TEMP.REC variable.
    CTR = 0
    CTR = DCOUNT(ARRAY.2,@FM)
    KTR = 0
* During Batch, our aim is to update the Exchange rate. So dont
* un-necessarily expand the fields. Initialise them to NULL.
    IF RUNNING.UNDER.BATCH THEN
        SR.TEMP.REC(SR.AMOUNT.TYPE) = ''
        SR.TEMP.REC(SR.ACCOUNT) = ''
        SR.TEMP.REC(SR.EXCG.RATE) = ''
    END
    FOR YI = 1 TO CTR
        IF NOT(ARRAY.2<YI,1>) THEN GOTO SKIP.KTR
        KTR +=1
        SR.TEMP.REC(SR.AMOUNT.TYPE)<1,-KTR> = ARRAY.2<YI,1>
        SR.TEMP.REC(SR.ACCOUNT)<1,-KTR> = ARRAY.2<YI,2>
        SR.TEMP.REC(SR.EXCG.RATE)<1,-KTR> = ARRAY.2<YI,3>
SKIP.KTR:
    NEXT YI
*

RETURN          ;* UPDATE.SR.REC
*-------------------------------------------------------------------------------------------------------------
WRITE.TO.FILE:
*------------
* To handle updation of SETTLEMENT.RATES record
* 1. write INAU record to LIVE file and delete INAU record
* 2. write INAU record to LIVE file, delete INAU record and move the last
*    amended record to HISTORY file

    MAT SR.TEMP.REC = MAT SR.REC.NAU
    IF SR.TEMP.REC(1) EQ '' THEN
        RETURN
    END
    SR.TEMP.REC(SR.RECORD.STATUS) = ''  ;* INAU removed for live file
    GOSUB GET.AUDIT.FIELDS.DATA         ;* audit fields update
    IF SR.TEMP.REC(SR.CURR.NO)  = 1 THEN          ;* for new SR record
        CALL F.MATWRITE(FN.CR, SR.ID, MAT SR.TEMP.REC, SR.AUDIT.DATE.TIME)
    END ELSE        ;* for existing SR record amendments
        GOSUB WRITE.SETTLEMENT.RATES    ;* to call AUTH.AND.HIST.WRITE
    END
    CALL F.DELETE('F.SETTLEMENT.RATES$NAU',SR.ID) ;* Delete INAU record

RETURN
*-------------------------------------------------------------------------------------------------------------

END       ;*  end routine eb.write.contract.rates
