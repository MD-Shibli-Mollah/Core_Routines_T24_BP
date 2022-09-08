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
* <Rating>280</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccEventCapture
    SUBROUTINE CONV.DIARY.R06(DIARY.ID,R.DIARY,FP.DIARY)

* Conversion Routine
* The way entitlement nostro settled is changed in R6.
* New field in DIARY is introduced to hold no of entitlements fully settled for broker side.
* This conversion populates new field ENTL.SETTLED in DIARY for existing records.
* Also populates ENTL.CREATED,ENTL.AUTHORISED for brokers.
**** <region name= Program Modification History>
*** <desc>Program Modification History </desc>
* 29/09/07 - GLOBUS_CI_10050566
*            Integration of UBS fixes - Restoration of Nostro functionality
*
*
* 27/11/07 - GLOBUS_CI_10052653
*            ENTL.SETTLED field is updated incorrectly for Broker
*
*** </region>
********************************************************************************
*** <region name= Inserts>
*** <desc>Inserts </desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE

*** </region>

    IF FP.DIARY[4] EQ '$NAU' OR FP.DIARY[4] EQ '$HIS' THEN
        RETURN
    END
    IF R.DIARY<129> NE 'YES' AND R.DIARY<130> NE 'YES' THEN
        RETURN      ;* 129 - CASH.HOLD.SETTLE
    END

    FN.CONCAT.DIARY = 'F.CONCAT.DIARY'
    F.CONCAT.DIARY = ''
    CALL OPF(FN.CONCAT.DIARY,F.CONCAT.DIARY)

    FN.SC.CON.ENTITLEMENT = 'F.SC.CON.ENTITLEMENT'
    F.SC.CON.ENTITLEMENT = ''
    CALL OPF(FN.SC.CON.ENTITLEMENT,F.SC.CON.ENTITLEMENT)

    FN.ENTITLEMENT = 'F.ENTITLEMENT'
    F.ENTITLEMENT = ''
    CALL OPF(FN.ENTITLEMENT,F.ENTITLEMENT)

    FN.ENTITLEMENT.NAU = 'F.ENTITLEMENT$NAU'
    F.ENTITLEMENT.NAU = ''
    CALL OPF(FN.ENTITLEMENT.NAU,F.ENTITLEMENT.NAU)

    FN.SC.SETT.ENTRIES = 'F.SC.SETT.ENTRIES'
    F.SC.SETT.ENTRIES = ''
    CALL OPF(FN.SC.SETT.ENTRIES,F.SC.SETT.ENTRIES)

    FN.SC.SETTLEMENT = 'F.SC.SETTLEMENT'
    F.SC.SETTLEMENT = ''
    CALL OPF(FN.SC.SETTLEMENT,F.SC.SETTLEMENT)

    FN.SC.SETTLEMENT.NAU = 'F.SC.SETTLEMENT$NAU'
    F.SC.SETTLEMENT.NAU = ''
    CALL OPF(FN.SC.SETTLEMENT.NAU,F.SC.SETTLEMENT.NAU)

    FN.SC.SETTLEMENT.HIS = 'F.SC.SETTLEMENT$HIS'
    F.SC.SETTLEMENT.HIS = ''
    CALL OPF(FN.SC.SETTLEMENT.HIS,F.SC.SETTLEMENT.HIS)

    DIARY.TYPE.ID = R.DIARY<4>
    ER = '' ; R.DIARY.TYPE = ''
    CALL F.READ('F.DIARY.TYPE',DIARY.TYPE.ID,R.DIARY.TYPE,'',ER)

    READ.ERROR = '' ; R.SC.PARAM = ''
    CALL EB.READ.PARAMETER('F.SC.PARAMETER','N','',R.SC.PARAM,'','',READ.ERROR)

    IF R.DIARY.TYPE<26> <> 'YES' THEN
        RETURN
    END
    GOSUB UPDATE.ENTL.SETTLED

    RETURN

*******************
UPDATE.ENTL.SETTLED:
*******************

    DEP.POS = 1
    CHECK.SETTLEMENT = 0
    DEP.SETTLED.ARRAY = ''

    DEP.ARRAY = R.DIARY<50>
    LOOP
        REMOVE DEP.NO FROM DEP.ARRAY SETTING FOUND
    WHILE DEP.NO
        IF R.DIARY<53,DEP.POS> AND R.DIARY<62,DEP.POS> EQ '' AND R.DIARY<67,DEP.POS> THEN
            CHECK.SETTLEMENT = 1
        END
        IF NOT(R.DIARY<53,DEP.POS>) OR R.DIARY<62,DEP.POS> NE '' AND R.DIARY<67,DEP.POS> THEN       ;* 62 - STATEMENT.NO
            R.DIARY<69,DEP.POS> = R.DIARY<67,DEP.POS>
            DEP.SETTLED.ARRAY<-1> = DEP.NO
        END
        DEP.POS += 1
    REPEAT
    IF CHECK.SETTLEMENT THEN
        GOSUB CHECK.SETTLEMENT
    END

    RETURN

****************
CHECK.SETTLEMENT:
****************

    ENTL.SETTLED = 0
    ER = '' ; R.CONCAT.DIARY = ''
    CALL F.READ(FN.CONCAT.DIARY,DIARY.ID,R.CONCAT.DIARY,F.CONCAT.DIARY,ER)

    LOOP
        REMOVE ENT.ID FROM R.CONCAT.DIARY SETTING FOUND
    WHILE ENT.ID
        ENT.ERR = '' ; R.ENTITLEMENT = ''
        CALL F.READ(FN.ENTITLEMENT,ENT.ID,R.ENTITLEMENT,F.ENTITLEMENT,ENT.ERR)
        BROKER.NO = R.ENTITLEMENT<127>
        BROKER.NO.ARRAY = ''
        LOCATE R.ENTITLEMENT<3> IN BROKER.NO<1,1> SETTING SAME.DEP.BRK ELSE
            IF BROKER.NO THEN
                BROKER.NO.ARRAY = R.ENTITLEMENT<3> : VM : BROKER.NO
            END ELSE
                BROKER.NO.ARRAY = R.ENTITLEMENT<3>
            END
        END
        BROKER.NO.ARRAY = RAISE(BROKER.NO.ARRAY)
        BROKER.NO.CNT = DCOUNT(BROKER.NO.ARRAY,FM)
        R.SC.SETT.ENTRIES = '' ; SETT.ERR = ''
        CALL F.READ(FN.SC.SETT.ENTRIES,ENT.ID,R.SC.SETT.ENTRIES,F.SC.SETT.ENTRIES,SETT.ERR)
        UNSETT.BROK.LIST = ''; BROKER.UNSETTLED = ''
        IF R.SC.SETT.ENTRIES THEN
            NO.OF.ENTRIES = DCOUNT(R.SC.SETT.ENTRIES,FM)
            FOR BR.CNT = 1 TO BROKER.NO.CNT
                FOR ENTRY.COUNT = 1 TO NO.OF.ENTRIES
                    FINAL.SV = DCOUNT(R.SC.SETT.ENTRIES<ENTRY.COUNT,6>,SM)
                    IF R.SC.SETT.ENTRIES<ENTRY.COUNT,6,FINAL.SV> EQ BROKER.NO.ARRAY<BR.CNT> THEN
                        UNSETT.BROK.LIST<-1> = R.SC.SETT.ENTRIES<ENTRY.COUNT,6,FINAL.SV>
* UNSETT.BROK.LIST holds a list of Broker and Depository which is unsettled in the Entitlement
                        EXIT
                    END
                NEXT ENTRY.COUNT
            NEXT BR.CNT

            IF UNSETT.BROK.LIST THEN
                SAVE.BROKER  = BROKER.NO.ARRAY
                CALL SC.CONV.CHK.BRK.SETTLEMENT(ENT.ID,BROKER.NO.ARRAY,BROKER.UNSETTLED)
                BROKER.NO.ARRAY = SAVE.BROKER

                GOSUB UPD.FOR.BROKER
            END ELSE
                GOSUB UPD.FOR.BROKER
            END
        END ELSE
            GOSUB UPD.FOR.BROKER
        END

    REPEAT

    RETURN

**************
UPD.FOR.BROKER:
**************

    BROKER.NO.CNT = DCOUNT(BROKER.NO.ARRAY,FM)
    FOR I = 1 TO BROKER.NO.CNT
        CURR.BROKER = BROKER.NO.ARRAY<I>
        LOCATE CURR.BROKER IN DEP.SETTLED.ARRAY<1> SETTING DEP.SETT.POS THEN
            CONTINUE
        END
        LOCATE CURR.BROKER IN BROKER.UNSETTLED<1> SETTING UNSETT.POS ELSE
            LOCATE CURR.BROKER IN R.DIARY<50,1> SETTING BROKER.POS THEN
                R.DIARY<69,BROKER.POS> += 1
            END
        END
    NEXT I

    RETURN

END
