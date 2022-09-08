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
* <Rating>36</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccEventCapture
    SUBROUTINE CONV.SC.DIARY.DATES.R07

*   Conversion routine to change the Id of DIARY.DATES
*
********************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY

    GOSUB INITIALISE
    GOSUB SAVE.COMMON
    GOSUB PROCESS
    GOSUB RESTORE.COMMON
    RETURN

*----------
INITIALISE:
*----------
    DIM HOLD.R.NEW(C$SYSDIM)
    MAT HOLD.R.NEW = ''
    HOLD.ID.NEW = ''
    RETURN

*------------
SAVE.COMMON:
*------------
    HOLD.ID.NEW = ID.NEW
    MAT HOLD.R.NEW = MAT R.NEW
    SAVE.V = V
    RETURN

*---------
PROCESS:
*--------
    ORIG.COMPANY = ID.COMPANY
    SEL.CMD = "SELECT F.COMPANY WITH CONSOLIDATION.MARK EQ 'N'"

    COM.LIST = '' ;  YSEL = 0
    CALL EB.READLIST(SEL.CMD,COM.LIST,'',YSEL,'')
    LOOP
        REMOVE K.COMPANY FROM COM.LIST SETTING COMPANY.POS
    WHILE K.COMPANY:COMPANY.POS
        IF K.COMPANY NE ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
        LOCATE 'SC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING FOUND.POS THEN

* Run this process only if FINANCIAL.COM is equal to ID.COMPANY
            IF R.COMPANY(64) EQ ID.COMPANY THEN
                GOSUB PROCESS2
            END
        END         ;* END OF LOCATE
    REPEAT

*
* Restore the original company
    IF ID.COMPANY NE ORIG.COMPANY THEN
        CALL LOAD.COMPANY(ORIG.COMPANY)
    END
    RETURN

*--------------
RESTORE.COMMON:
*-------------
    MAT R.NEW = MAT HOLD.R.NEW
    ID.NEW = HOLD.ID.NEW
    V = SAVE.V

    RETURN

*--------
PROCESS2:
*--------
    FN.DIARY.DATES = 'F.DIARY.DATES'
    FV.DIARY.DATES = ''
    CALL OPF(FN.DIARY.DATES,FV.DIARY.DATES)
    SELECT FV.DIARY.DATES

    LOOP
        READNEXT DIARY.DATES.ID ELSE DIARY.DATES.ID = ''
    WHILE DIARY.DATES.ID NE ''
        IF FIELD(DIARY.DATES.ID,'*',2) THEN
            CONTINUE
        END
        CALL F.READ(FN.DIARY.DATES,DIARY.DATES.ID,R.REC.DIARY.DATES,FV.DIARY.DATES,READ.ERR)
        IF READ.ERR THEN
            CONTINUE
        END

        IF C$MULTI.BOOK THEN
            GOSUB PROCESS.MULTI.BOOK
        END ELSE
            NEW.DIARY.DATES.ID = DIARY.DATES.ID:'*':ID.COMPANY
            WRITE R.REC.DIARY.DATES TO FV.DIARY.DATES,NEW.DIARY.DATES.ID
            DELETE FV.DIARY.DATES,DIARY.DATES.ID
        END

    REPEAT
    RETURN

*------------------
PROCESS.MULTI.BOOK:
*------------------
    DIARY.CO.CODE.LIST = ''
    DIARY.DATES.REC = ''
    DIARY.COUNT = DCOUNT(R.REC.DIARY.DATES,FM)
    FOR CT = 1 TO DIARY.COUNT
        DIARY.ID = R.REC.DIARY.DATES<CT,3>
        DIARY.DATES.REC1 = R.REC.DIARY.DATES<CT>
        CONVERT VM TO '*' IN DIARY.DATES.REC1
        CALL F.READ('F.DIARY',DIARY.ID, R.DIARY, '', READ.DIARY.ERR)
        DIARY.CO.CODE = R.DIARY<173>
        LOCATE DIARY.CO.CODE IN DIARY.CO.CODE.LIST<1> SETTING POS THEN
            DIARY.DATES.REC<POS,-1> = DIARY.DATES.REC1
        END ELSE
            DIARY.CO.CODE.LIST<-1>  = DIARY.CO.CODE
            DIARY.DATES.REC<-1> = DIARY.DATES.REC1
        END
    NEXT CT

    DIARY.CO.CODE.COUNT = DCOUNT(DIARY.CO.CODE.LIST,FM)
    FOR I = 1 TO DIARY.CO.CODE.COUNT
        DIARY.DATES.RECORD = DIARY.DATES.REC<I>
        CONVERT VM TO FM IN DIARY.DATES.RECORD
        CONVERT '*' TO VM IN DIARY.DATES.RECORD
        DIARY.DATES.CO = DIARY.CO.CODE.LIST<I>
        NEW.DIARY.DATES.ID = DIARY.DATES.ID:'*':DIARY.DATES.CO
        WRITE DIARY.DATES.RECORD TO FV.DIARY.DATES,NEW.DIARY.DATES.ID
    NEXT I
    DELETE FV.DIARY.DATES,DIARY.DATES.ID
    RETURN

END
