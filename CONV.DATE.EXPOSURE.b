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
* <Rating>240</Rating>
*-----------------------------------------------------------------------------
* Version 46 25/10/00 GLOBUS Release No. G14.0.00 03/07/03
*
*************************************************************************
*
    $PACKAGE AC.CashFlow
    SUBROUTINE CONV.DATE.EXPOSURE
*
*************************************************************************
* The structure of DATE.EXPOSURE is changed from being keyed on DATE to
* ACCOUNT.DATE
* This routine will read the DATE.EXPOSURE file and for each date,
* will loop through the statment ids, read the stmt id and
* create the record by ACCOUNT.DATE, then Each stmt.id will be deleted
* from the DATE record
*************************************************************************
* Maintenance
* 24/11/03 - BG_100005712
*            NOT TO CALL F.WRITE and F.DELETE
*
* 04/10/05 - CI_10035458
*            System was not writing the record in DATE.EXPOSURE file since
*            the variable ACCT.DATE.ARRAY was null. System was locating with
*            New key in ACCT.DATE.ARRAY and if the key was not exist it was
*            comming out from the para insted of forming the array with new
*            values.
*
* 23/04/08 - CI_10054915(CSS REF:HD0807337)
*            Changes done such that DATE.EXPOSURE file will be updated for
*            all the companies.
*
*************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATE.EXPOSURE
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.COMPANY.CHECK

*************************************************************************
*
    SAVE.ID.COMPANY = ID.COMPANY

    F.COMPANY.CHECK = ''
    CALL OPF("F.COMPANY.CHECK", F.COMPANY.CHECK)

    CALL F.READ("F.COMPANY.CHECK", "FINANCIAL", COMP.CHECK.REC, F.COMPANY.CHECK, "")
    COMP.LIST = DCOUNT(COMP.CHECK.REC<EB.COC.COMPANY.CODE>,VM)

    FOR I = 1 TO COMP.LIST

        IF COMP.CHECK.REC<EB.COC.COMPANY.CODE,I> <> ID.COMPANY THEN
            CALL LOAD.COMPANY(COMP.CHECK.REC<EB.COC.COMPANY.CODE,I>)
        END
        GOSUB INITIALISE
        GOSUB SELECT.DATE.EXPOSURE
    NEXT I

    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END


    RETURN
*
*************************************************************************
INITIALISE:
*      Open files
*
* BG_100004334 S.OB.
    FN.DATE.EXPOSURE = 'F.DATE.EXPOSURE' ; F.DATE.EXPOSURE = ''

    CALL OPF(FN.DATE.EXPOSURE,F.DATE.EXPOSURE)
*      BG_100004334 E

    FN.STMT.ENTRY = 'F.STMT.ENTRY' ; F.STMT.ENTRY = ""

    CALL OPF(FN.STMT.ENTRY, F.STMT.ENTRY)

* BG_100004334
    FN.ACCOUNT.EXPOSURE = 'F.ACCOUNT.EXPOSURE' ; F.ACCOUNT.EXPOSURE = ""
    CALL OPF(FN.ACCOUNT.EXPOSURE, F.ACCOUNT.EXPOSURE)
* Initialise Variables


    ACC.ID = 0
    WRITE.ACC =0
    NO.OF.RECS = 0
    NO.OF.ACTS = 0
    AC.EXP.REC = ""
    ACCT.DATE.ARRAY = ""
    RETURN

*************************************************************************
*
SELECT.DATE.EXPOSURE:
*
    EX.STMT = 'SELECT ':FN.DATE.EXPOSURE

    SEL.LIST = "" ; SYS.ERROR = ""
    CALL EB.READLIST(EX.STMT, SEL.LIST, "", NO.OF.RECS, SYS.ERROR)


    IF SEL.LIST = "" THEN

        RETURN
    END ELSE

        LOOP
            REMOVE EXP.ID FROM SEL.LIST SETTING POS

        WHILE EXP.ID:POS DO


            IF NOT(INDEX(EXP.ID,"-",1)) THEN

                EXP.REC = ""

                READ EXP.REC FROM F.DATE.EXPOSURE, EXP.ID THEN

                    LOOP
                        REMOVE STMT.ID FROM EXP.REC SETTING STMT.MARKER


                    WHILE STMT.ID:STMT.MARKER
                        GOSUB PROCESS.STMTS
                    REPEAT
                END
                GOSUB UPDATE.DATE.EXPOSURE
                DELETE F.DATE.EXPOSURE,EXP.ID
            END

        REPEAT

    END
    RETURN
****************************************************************************
UPDATE.DATE.EXPOSURE:

* Now update the DATE.EXPOSURE with array

    IF ACCT.DATE.ARRAY THEN
        NUM.ACTS = DCOUNT(ACCT.DATE.ARRAY,@FM)

        FOR ACT = 1 TO NUM.ACTS
            ACCT.REC = ""
            ACCT.DATE = ""
            ACCT.DATE = ACCT.DATE.ARRAY<ACT>
            ACCT.REC = RAISE(AC.EXP.REC<ACT>)
            WRITE ACCT.REC TO F.DATE.EXPOSURE, ACCT.DATE
        NEXT ACT
    END


    RETURN

***********************************************************************************************

PROCESS.STMTS:

    STMT.REC = ""
* Create the record under the new key
    READ STMT.REC FROM F.STMT.ENTRY, STMT.ID ELSE STMT.REC = ''
    IF STMT.REC THEN
        ACCT = STMT.REC<AC.STE.ACCOUNT.NUMBER>

        EXP.DATE = EXP.ID

        GOSUB UPDATE.ACCOUNT.EXPOSURE   ;* BG_100004334

        EXP.KEY = ACCT:"-":EXP.DATE


* Update array with Account-Date and stmts

        LOCATE EXP.KEY IN ACCT.DATE.ARRAY<1> BY 'AL' SETTING EXP.POS THEN

            AC.EXP.REC<EXP.POS,-1> = STMT.ID
* Create the record under the new key

        END ELSE

            ACCT.DATE.ARRAY = INSERT(ACCT.DATE.ARRAY,EXP.POS,0,0,EXP.KEY)
            AC.EXP.REC = INSERT(AC.EXP.REC,EXP.POS,0,0,STMT.ID)

        END
    END
    RETURN
*************************************************************************
UPDATE.ACCOUNT.EXPOSURE:

    ACCT.EXPO.REC = ""
    READ ACCT.EXPO.REC FROM F.ACCOUNT.EXPOSURE, ACCT ELSE ACCT.EXPO.REC = ''


    LOCATE EXP.DATE IN ACCT.EXPO.REC<1> BY 'AL' SETTING ACCT.POS ELSE
        ACCT.EXPO.REC = INSERT(ACCT.EXPO.REC,ACCT.POS,0,0,EXP.DATE)
    END


    IF ACCT.EXPO.REC THEN
        WRITE ACCT.EXPO.REC TO F.ACCOUNT.EXPOSURE, ACCT
    END
    RETURN

***************************************************************************
END
