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
    $PACKAGE ST.ChargeConfig
    SUBROUTINE CONV.XX.GEN.CONDITION.G15(ID,R.RECORD,YFILE)
    $INSERT I_COMMON
    $INSERT I_EQUATE
********************************************************************
*08/06/04 - EN_10002237
*           CONVERSION routine for all the GEN.CONDITION.RECORDS
*           as per the new design of condition.priroity
*31/08/04 - BG_100007160
*           The Internal File Fxxx.SCPM.GEN.CONDITION Was Not Updating
*           Correctly. The Record Was Blank.
*09/09/04 - BG_100007199
*           FT.GEN.CONDITION Was Not Creating Correctly Due To Null Problem.
*
*05/04/06 - CI_10040330
*           Variable uninitialised error when running Conversions during upgrade.
*
*09/12/09 - CI_10068084
*           TAX.GEN.CONDITION record is not converted properly when upgrading from G14007 to R09.
*

********************************************************************

*
* Note that this conversion should run after CONDITION.PRIORITY RECORDS changed to the new format
*
    OLD.RECORD = R.RECORD

    NEW.RECORD = ''
    NEW.RECORD<1> = OLD.RECORD<1>
    GOSUB IDENTIFY.COND.PRIORITY.REC
    GOSUB CONVERT.PRIORITIES:
    GOSUB COPY.AUDIT.INFO
    R.RECORD = NEW.RECORD


    RETURN
*******************************************************************************************
*
****************
COPY.AUDIT.INFO:
*****************
*
* Copy the audit fields from the old record to the new record. In the old record, the audit fields start
* at 49 and in the new template it start at 16 - so copy the 9 audit fields
*
    IF YID.COND = "STATEMENT" THEN
        NEW.AUDIT.START = 7
    END ELSE
        NEW.AUDIT.START = 6
    END
    OLD.AUDIT.START = NO.OF.VALS +2
    FOR AUDIT.CTR = 0 TO 8
        IF AUDIT.CTR = 2 OR AUDIT.CTR = 3 THEN
            MUL.CTR = COUNT(OLD.RECORD<OLD.AUDIT.START + AUDIT.CTR>,@VM)+1
            FOR AUDIT.AV = 1 TO MUL.CTR
                NEW.RECORD<NEW.AUDIT.START+AUDIT.CTR,AUDIT.AV> = OLD.RECORD<OLD.AUDIT.START + AUDIT.CTR,AUDIT.AV>
            NEXT AUDIT.AV

* Update INPUTTER field with the CONVERSION.DETAILS id, since it will not be updated in CONVERSION.DETAILS.RUN
* as the CO.CODE fields of these XX.GEN.CONDITION records CONVERSION.DETAILS will be blank.
*
            IF AUDIT.CTR = 2 THEN
                NEW.RECORD<NEW.AUDIT.START+AUDIT.CTR,AUDIT.AV+1> = TNO:"_":APPLICATION
            END
        END ELSE
            NEW.RECORD<NEW.AUDIT.START+AUDIT.CTR> = OLD.RECORD<OLD.AUDIT.START + AUDIT.CTR>
        END
    NEXT AUDIT.CTR
    RETURN
*************************************************************************************************
*
*************************
CONVERT.PRIORITIES:
**************************
    ITEMS = '' ; NO.OF.ITEMS = 0
    VALUES = '' ; PRIORITIES = ''
    ITEMS = COND.PRIOR.REC<3>
    CONVERT VM TO SM IN ITEMS
    NO.OF.ITEMS = COUNT(ITEMS,SM)+1
    FOR  PRIORITY = 1 TO NO.OF.ITEMS
        PRIORITIES<-1> = PRIORITY
        IF YID.COND = "STATEMENT" THEN
            NEXT.PRIORITY = PRIORITY+1
            VALUES<-1> = OLD.RECORD<NEXT.PRIORITY+1>
        END ELSE
            IF OLD.RECORD<PRIORITY+1> = '' THEN
                VALUES<-1> = ' '
            END ELSE
                VALUES<-1> = OLD.RECORD<PRIORITY+1>
            END
        END
    NEXT PRIORITY
    CONVERT ' ' TO '' IN VALUES
    CONVERT FM TO SM IN PRIORITIES
    NO.OF.MULTIVALS = 0
    FOR ITM.VAL= 0 TO NO.OF.ITEMS
        IF YID.COND = "STATEMENT" THEN
            ITM.VAL = ITM.VAL+1
            NO.OF.VALS = NO.OF.ITEMS+1
        END ELSE
            NO.OF.VALS = NO.OF.ITEMS
        END
        VAL.CTR = COUNT(OLD.RECORD<2+ITM.VAL>, VM)+1
        IF VAL.CTR > NO.OF.MULTIVALS THEN
            NO.OF.MULTIVALS = VAL.CTR
        END
    NEXT ITM.VAL
    FOR AV = 1 TO NO.OF.MULTIVALS
        NEW.RECORD<2,AV> = ITEMS
        NEW.RECORD<3,AV> = PRIORITIES
        FOR AS = 1 TO NO.OF.VALS
            NEW.RECORD<4,AV,AS> = VALUES<AS,AV>
        NEXT AS
    NEXT AV
    NEW.RECORD<5> = ""
    IF YID.COND = "STATEMENT" THEN
        NEW.RECORD<NO.OF.VALS +3> = OLD.RECORD<2>
    END

    RETURN

*************************************************************************************************
*
*************************
IDENTIFY.COND.PRIORITY.REC:
**************************
*
* The priority files can be assigned by checking the field numbers in the priority.sequ array
* as the current structure is hardcoded.
*
    SAVE.YFILE = ''
    IF INDEX(YFILE,'$',1) THEN
        SAVE.YFILE = YFILE
        YFILE=FIELD(YFILE,'$',1)
    END

    BEGIN CASE
    CASE FIELD(YFILE,'.',2,99) = "SCPM.GEN.CONDITION"
        YID.COND = "SC.MANAGEMENT"
    CASE FIELD(YFILE,'.',2,99) =  "FT.GEN.CONDITION"
        YID.COND = "FUNDS.TRANSFER"
    CASE FIELD(YFILE,'.',2,99) =  "FD.GEN.CONDITION"
        YID.COND = "FIDUCIARY"
    CASE FIELD(YFILE,'.',2,99) =  "LC.GEN.CONDITION"
        YID.COND = "LETTER.OF.CREDIT"
    CASE FIELD(YFILE,'.',2,99) =  "STMT.GEN.CONDITION"
        YID.COND = "STATEMENT"
    CASE FIELD(YFILE,'.',2,99) =  "SCTR.GEN.CONDITION"
        YID.COND = "SC.TRADING"

    CASE FIELD(YFILE,'.',2,99) =  "TAX.GEN.CONDITION"
        YID.COND = "TAX"
    CASE FIELD(YFILE,'.',2,99) =  "ACCT.GEN.CONDITION"
        YID.COND = "ACCOUNT"

    CASE FIELD(YFILE,'.',2,99) =  "SCSK.GEN.CONDITION"
        YID.COND = "SC.SAFEKEEPING"
    END CASE
*
* To read the appropriate CONDITION.PRIORITY form the File Name with the Mnemonic itself.
*
    MNEMONIC = FIELD(YFILE,".",1)       ;* Get the Mnemonic part from File id.
    COMP.MNEMONIC = MNEMONIC[3]         ;* Remove the "F" prefix, to get the apt company mnemonic alone.

    FN = 'F':COMP.MNEMONIC:'.CONDITION.PRIORITY'
    FV = ''
    CALL OPF(FN,FV)
    CALL F.READ(FN,YID.COND,COND.PRIOR.REC,FV,ER)
    IF SAVE.YFILE THEN
        YFILE = SAVE.YFILE
    END

    RETURN
*
*************************************************************************************************
*
END
