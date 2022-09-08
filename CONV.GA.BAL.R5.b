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
* <Rating>92</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.GroupAccrual
    SUBROUTINE CONV.GA.BAL.R5
*
* 25/07/05 - EN_10002526
*            Group Accrual performance ad co.code to @ID
*
* 26/07/06 - CI_10042923
*            Remove the cache off stuff and replace with journal update as its simpler
*            if online and CACHE.OFF is set then we also need RUNNING.UNDER.BATCH set

************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.GROUP.ACCRUAL.BALANCES
    FN.GROUP.ACCRUAL.BALANCES = "F.GROUP.ACCRUAL.BALANCES" ; F.GROUP.ACCRUAL.BALANCES = ""
    CALL OPF(FN.GROUP.ACCRUAL.BALANCES,F.GROUP.ACCRUAL.BALANCES)
*
* Select the group accrual parameter file and update the frequencies where necessary
*
    SELECT F.GROUP.ACCRUAL.BALANCES
    COUNTER = 0
    LOOP READNEXT ID ELSE ID = "" WHILE ID <> ''
        COUNTER +=1 ;* flush to disk every 10 records while online
        CALL F.READU(FN.GROUP.ACCRUAL.BALANCES,ID,R.BAL,F.GROUP.ACCRUAL.BALANCES,ER,"")
        CO.CODE = FIELD(ID,"-",6)

        IF R.BAL<GA.BAL.CONSOL.KEY> THEN          ;* allow for re run
            IF CO.CODE THEN   ;* We are re running - make sure RE.CONSOL.IC is correctly updated
                OLD.BAL.ID = FIELD(ID,'-',1,5)
                NEW.ID = ID
            END ELSE
                OLD.BAL.ID = ID
                NEW.ID = ID:"-":ID.COMPANY
            END
            YKEY.CON = R.BAL<GA.BAL.CONSOL.KEY>

            LINK.CRF = YKEY.CON:FM:OLD.BAL.ID
            LINK.PROCESS = "" ; LINK.PROCESS<2> = "REMOVE"
            CALL RE.UPDATE.LINK.FILE(LINK.CRF, LINK.PROCESS)          ;* remove old record id

            LINK.CRF = YKEY.CON:FM:NEW.ID
            CALL RE.UPDATE.LINK.FILE(LINK.CRF, "")          ;* add new record id
        END

        IF CO.CODE = "" THEN  ;* delete old balance records and rewrite with new key
            CALL F.DELETE(FN.GROUP.ACCRUAL.BALANCES,ID)
            R.BAL<GA.BAL.CO.CODE> = ID.COMPANY
            NEW.ID = ID:"-":ID.COMPANY
            CALL F.WRITE(FN.GROUP.ACCRUAL.BALANCES,NEW.ID,R.BAL)
        END ELSE
            CALL F.RELEASE(FN.GROUP.ACCRUAL.BALANCES,ID,F.GROUP.ACCRUAL.BALANCES)
        END
        IF COUNTER GE 10 THEN
            CALL JOURNAL.UPDATE(ID)
            COUNTER = 0
        END
    REPEAT
    IF COUNTER GT 0 THEN ; * flush the last updates
        CALL JOURNAL.UPDATE(ID)
        COUNTER = 0
    END
    RETURN
END
