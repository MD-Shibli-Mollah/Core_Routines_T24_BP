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
* <Rating>-101</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Engine
    SUBROUTINE CONV.PM.TRAN.ACTIVITY.G14.1
*
*
*
* NEW ROUTINE
*
* This routine was written to convert the PM record ids in
* PM.TRAN.ACTIVITY and to update the CONTRACT.TRAN.ACTIVITY file.
* *REAL and *FWD are attached to the record ids, based on the
* TRAN.PROC.DETL (date) field value and the txn records present
* in the LIVE and NAU files(for FT txns).
*
* 06/02/04 - BG_100006167(EN_10001961)
*
* 05/04/05 - CI_10028905
*            Remove Unnecessary OPF of Data Capture And Teller.
*
*  27/05/08 - CI_10055646
*             When appending PM.TRAN.ACTIVITY ids with *REAL and *FWD,
*           Transaction references in PM.DLY.POSN.CLASS are also appended with *REAL,*FWD.
*
*************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.DATA.CAPTURE
    $INSERT I_F.TELLER
    $INSERT I_F.DATES
    $INSERT I_F.PM.TRAN.ACTIVITY
    $INSERT I_F.PM.DLY.POSN.CLASS
*************************************************************************
*
    GOSUB INITIALISE
*
    COMMAND.PM = 'SELECT ':FN.PM.TRAN.ACTIVITY
    CALL EB.READLIST(COMMAND.PM, RECORD.LIST.PM, '', NO.OF.PM, PM.R.CODE)

    LOOP
        REMOVE RECORD.ID FROM RECORD.LIST.PM SETTING RECORD.POS
    WHILE RECORD.ID : RECORD.POS
        BEGIN CASE
        CASE RECORD.ID[1,2] = "FT"
            GOSUB PROCESS.PM.FT
            GOSUB CONTRACT.FILE.UPDATE
        CASE RECORD.ID[1,2] = "TT" OR RECORD.ID[1,2] = "DC"
            GOSUB PROCESS.PM.TT.DC
            GOSUB CONTRACT.FILE.UPDATE
        END CASE

    REPEAT

    RETURN
*
*----------
INITIALISE:
*----------
* Open the PM.TRAN.ACTIVITY, CONTRACT.TRAN.ACTIVITY, FUNDS.TRANSFER, TELLER
*    and DATA.CAPTURE
*
    FN.PM.TRAN.ACTIVITY = 'F.PM.TRAN.ACTIVITY'
    F.PM.TRAN.ACTIVITY = ''
    CALL OPF(FN.PM.TRAN.ACTIVITY,F.PM.TRAN.ACTIVITY)
*
    FN.FUNDS.TRANSFER = 'F.FUNDS.TRANSFER'
    F.FUNDS.TRANSFER = ''
    CALL OPF(FN.FUNDS.TRANSFER,F.FUNDS.TRANSFER)

    FN.FUNDS.TRANSFER$NAU = 'F.FUNDS.TRANSFER$NAU'
    F.FUNDS.TRANSFER$NAU = ''
    CALL OPF(FN.FUNDS.TRANSFER$NAU,F.FUNDS.TRANSFER$NAU)

*
    FN.CONTRACT.TRAN.ACTIVITY = 'F.CONTRACT.TRAN.ACTIVITY'
    F.CONTRACT.TRAN.ACTIVITY = ''
    CALL OPF(FN.CONTRACT.TRAN.ACTIVITY,F.CONTRACT.TRAN.ACTIVITY)

    FN.PM.DLY.POSN.CLASS = "F.PM.DLY.POSN.CLASS"
    F.PM.DLY.POSN.CLASS = ""
    CALL OPF(FN.PM.DLY.POSN.CLASS,F.PM.DLY.POSN.CLASS)

*

*
    RETURN
*
*****************************

PROCESS.PM.FT:
*-------------
    RECORD.ID.FT = FIELD(RECORD.ID,'*',1)
    READ R.PM.TRAN.ACTIVITY FROM F.PM.TRAN.ACTIVITY, RECORD.ID THEN
        DELETE F.PM.TRAN.ACTIVITY, RECORD.ID

* Locate the txn in LIVE file or else in the NAU file.

        CALL F.READ(FN.FUNDS.TRANSFER,RECORD.ID.FT,R.FT,F.FUNDS.TRANSFER,FERR)

        IF FERR THEN
            CALL F.READ(FN.FUNDS.TRANSFER$NAU,RECORD.ID.FT,R.FT,F.FUNDS.TRANSFER$NAU,FNERR)
        END

        IF NOT(FERR) OR NOT(FNERR) THEN

            IF (R.FT<FT.PROCESSING.DATE> EQ R.DATES(EB.DAT.TODAY)) THEN
                RECORD.ID = RECORD.ID.FT:'*REAL'
            END ELSE
                RECORD.ID = RECORD.ID.FT:'*FWD'
            END

        END ELSE
            RECORD.ID = RECORD.ID.FT:'*REAL'
        END

        WRITE R.PM.TRAN.ACTIVITY ON F.PM.TRAN.ACTIVITY , RECORD.ID

    END
*Update the transaction reference with *REAL,*FWD.

    GOSUB FORM.DLY.POSN.CLASS.IDS
    LOOP
        REMOVE DLY.POSN.CLASS.ID FROM DLY.POSN.CLASS.IDS SETTING DLY.POS
    WHILE DLY.POSN.CLASS.ID:DLY.POS

        READ R.PM.DLY.POSN.CLASS FROM F.PM.DLY.POSN.CLASS,DLY.POSN.CLASS.ID THEN

            LOCATE RECORD.ID.FT IN R.PM.DLY.POSN.CLASS<PM.DPC.TXN.REFERENCE,1> SETTING POS THEN

                R.PM.DLY.POSN.CLASS<PM.DPC.TXN.REFERENCE,POS> = RECORD.ID

            END
            WRITE R.PM.DLY.POSN.CLASS ON F.PM.DLY.POSN.CLASS,DLY.POSN.CLASS.ID
        END

    REPEAT
*
    RETURN
*
******************************

PROCESS.PM.TT.DC:
*-------------------
* Read the record from the file.

    RECORD.ID.DC.TT = FIELD(RECORD.ID,'*',1)

    READ R.PM.TRAN.ACTIVITY FROM F.PM.TRAN.ACTIVITY, RECORD.ID THEN

        DELETE F.PM.TRAN.ACTIVITY, RECORD.ID
        RECORD.ID = RECORD.ID.DC.TT:'*REAL'

        WRITE R.PM.TRAN.ACTIVITY ON F.PM.TRAN.ACTIVITY, RECORD.ID
    END
* Update the transaction reference with *REAL,*FWD.
    GOSUB FORM.DLY.POSN.CLASS.IDS
    LOOP
        REMOVE DLY.POSN.CLASS.ID FROM DLY.POSN.CLASS.IDS SETTING DLY.POS
    WHILE DLY.POSN.CLASS.ID:DLY.POS


        READ R.PM.DLY.POSN.CLASS FROM F.PM.DLY.POSN.CLASS,DLY.POSN.CLASS.ID THEN
            LOCATE RECORD.ID.DC.TT IN R.PM.DLY.POSN.CLASS<PM.DPC.TXN.REFERENCE,1> SETTING POS THEN

                R.PM.DLY.POSN.CLASS<PM.DPC.TXN.REFERENCE,POS> = RECORD.ID
            END

            WRITE R.PM.DLY.POSN.CLASS ON F.PM.DLY.POSN.CLASS,DLY.POSN.CLASS.ID
        END
    REPEAT
    RETURN



*****************************

CONTRACT.FILE.UPDATE:
*--------------------
*
* CONTRACT.TRAN.ACTIVITY concat file updation.
*

    DELETE F.CONTRACT.TRAN.ACTIVITY, FIELD(RECORD.ID,'*',1)

    CONCAT.ID = FIELD(RECORD.ID,'*',1)
    CONCAT.REC = RECORD.ID
    WRITE CONCAT.REC ON F.CONTRACT.TRAN.ACTIVITY, CONCAT.ID

    RETURN


*------------------------------------------------------------------------
FORM.DLY.POSN.CLASS.IDS:
*------------------------------------------
* Form a list of  DLY.POSN.CLASS.IDS from PM.TRAN.ACTIVITY record.

    NOPC = 1
    NOPC = DCOUNT(R.PM.TRAN.ACTIVITY<PM.CURRENCY.MARKET>,VM)
    DLY.POSN.CLASS.IDS = ""
    IDX = 1
    DAILY.POSN.CLASS.IDS = ""
    DPCI = ""

    FOR IDX = 1 TO NOPC

        DPCI = R.PM.TRAN.ACTIVITY<PM.POSN.CLASS,IDX>:".":R.PM.TRAN.ACTIVITY<PM.CURRENCY.MARKET,IDX>:".":R.PM.TRAN.ACTIVITY<PM.DEALER.DESK,IDX>
        DPCI :=".":R.PM.TRAN.ACTIVITY<PM.POSN.TYPE,IDX>:".":R.PM.TRAN.ACTIVITY<PM.CURRENCY,IDX>:".":R.PM.TRAN.ACTIVITY<PM.VALUE.DATE,IDX>:".":R.PM.TRAN.ACTIVITY<PM.VALUE.DATE.SFX,IDX>

        LOCATE DPCI IN DLY.POSN.CLASS.IDS<1> SETTING DPCI.POS ELSE

            DLY.POSN.CLASS.IDS<DPCI.POS> = DPCI

        END

    NEXT IDX

    RETURN

END
