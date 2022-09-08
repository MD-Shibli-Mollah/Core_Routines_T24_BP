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
* <Rating>-70</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ChargeConfig
    SUBROUTINE CONV.CONDITION.PRIORITY.G15(ID,R.RECORD,YFILE)
    $INSERT I_COMMON
    $INSERT I_EQUATE
******************************************************************************************
*Modification.description:
*06/06/04 - EN_10002237
*           Conversion routine for redesign of condition.priroity
*           enhancement
*07/07/04 - BG_100006931
*           Convert fields with spaces to '.'
*27/07/04 - BG_100006991
*               Changed F.WRITE to WRITE
*
*30/09/04 - BG_100007348
*           Assign New Company Code Value Through This Program.
*
*05/04/06 - CI_10040330
*           Variable uninitialised error when running Conversions during upgrade.
*
*09/12/09 - CI_10068084
*           TAX.GEN.CONDITION record is not converted properly when upgrading from G14007 to R09.
*
******************************************************************************************
    OLD.RECORD = R.RECORD
    NEW.RECORD = ''
    NEW.RECORD<1> = OLD.RECORD<1>
    NO.OF.ITEMS = DCOUNT(OLD.RECORD<38>,VM)
    GOSUB IDENTIFY.PRIORITY.FIELDS
    GOSUB UPDATE.CONVERSION.RECORD
    GOSUB COPY.AUDIT.INFO
    R.RECORD = NEW.RECORD
    RETURN
*******************************************************************************************
COPY.AUDIT.INFO:
*****************
* Copy the audit fields from the old record to the new record. In the old record, the audit fields start
* at 49 and in the new template it start at 7 - so copy the 9 audit fields

    NEW.AUDIT.START = 7
    OLD.AUDIT.START = 49
    FOR AUDIT.CTR = 0 TO 8
        NEW.RECORD<NEW.AUDIT.START+AUDIT.CTR> = OLD.RECORD<OLD.AUDIT.START + AUDIT.CTR>
    NEXT AUDIT.CTR
    RETURN
*************************************************************************************************
IDENTIFY.PRIORITY.FIELDS:
**************************
* The field PRIORITY.FIELD1, PRIORITY.FIELD2 - etc contain the fields that have been
* chosen for priority sequencing. Each field has 2 multivalues,
* 1st multivalue contains the field name, 2nd multivalue contains the checkfile for the same
* So assigning fields priority.item and prty.validation from there. No of fields chosen for
* priority allocations is got by counting the number of multivalues in PRIORITY.SEQU
*

    NEW.RECORD<2> = ''
    CP.FLD.NAME = ''

    FOR PRIORITY.ITEM = 1 TO NO.OF.ITEMS
        FIELD.NUMBER = OLD.RECORD<38,PRIORITY.ITEM>
        GOSUB IDENTIFY.PRIORITY.FILE

        PRIOR.ITEM.POSITION = 38 + PRIORITY.ITEM  ;* 39 is starting Position of priority.file

        IF OLD.RECORD<PRIOR.ITEM.POSITION,1> = 'INVST.PGM' THEN
            OLD.RECORD<PRIOR.ITEM.POSITION,1> = 'INVESTMENT.PROGRAM'
        END
        IF OLD.RECORD<PRIOR.ITEM.POSITION,1> = 'MNGD.ACT' THEN
            OLD.RECORD<PRIOR.ITEM.POSITION,1> = 'MANAGED.ACCOUNT'
        END

        CP.FLD.NAME = OLD.RECORD<PRIOR.ITEM.POSITION,1>
        CONVERT " " TO '.' IN CP.FLD.NAME         ;* convert null spaces to dots for field names (local ref)

        NEW.RECORD<3,PRIORITY.ITEM> = FILE.USED:'>':CP.FLD.NAME

        NEW.RECORD<4,PRIORITY.ITEM> = FIELD(OLD.RECORD<PRIOR.ITEM.POSITION,2>,'-',1,2)
        IF FIELD(NEW.RECORD<4,PRIORITY.ITEM>,'-',1) = 'LOCAL.REF.TABLE' THEN
            NEW.RECORD<4,PRIORITY.ITEM>='LOCAL.TABLE-':FIELD(NEW.RECORD<4,PRIORITY.ITEM>,'-',2)
        END

        FLD.NO = FIELD(NEW.RECORD<4,PRIORITY.ITEM>,'-',2)
        APPLN = FIELD(NEW.RECORD<4,PRIORITY.ITEM>,'-',1)
        FN.SS = "F.STANDARD.SELECTION"
        FV.SS = ''
        CALL OPF(FN.SS,FV.SS)
        R.SS.APPLN = ''
        CALL GET.STANDARD.SELECTION.DETS(APPLN,R.SS.APPLN)
        CALL FIELD.NAMES.TO.NUMBERS(FLD.NO,R.SS.APPLN,FLD.NAME,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
        NEW.RECORD<4,PRIORITY.ITEM> = APPLN:"-":FLD.NO
    NEXT PRIORITY.ITEM
    CONVERT '-' TO '>' IN NEW.RECORD<4>
    RETURN

*************************************************************************************************
IDENTIFY.PRIORITY.FILE:
**************************
* The priority files can be assigned by checking the field numbers in the priority.sequ array
* as the current structure is hardcoded.
*

    BEGIN CASE
    CASE FIELD.NUMBER = 2
        FILE.USED = 'ACCOUNT'
    CASE FIELD.NUMBER < 9
        FILE.USED = 'CUSTOMER'
    CASE FIELD.NUMBER = 9
        FILE.USED = 'SEC.ACC.MASTER'
    CASE FIELD.NUMBER = 10
        FILE.USED = 'SEC.ACC.MASTER'
    CASE  FIELD.NUMBER < 20
        FILE.USED = 'CUSTOMER'
    CASE FIELD.NUMBER < 29
        FILE.USED = 'ACCOUNT'
    CASE 1
        FILE.USED = 'SEC.ACC.MASTER'
    END CASE
    LOCATE FILE.USED IN NEW.RECORD<2,1> SETTING FOUND.FILE ELSE
        INS FILE.USED BEFORE NEW.RECORD<2,FOUND.FILE>
    END


    RETURN
*
*************************************************************************************************
UPDATE.CONVERSION.RECORD:
**************************
* The priority files can be assigned by checking the field numbers in the priority.sequ array
* as the current structure is hardcoded.
*
    GEN.COND.FILE = ""
    FN.CONVERSION.DETAILS = 'F.CONVERSION.DETAILS'
    F.CONVERSION.DETAILS = ''
    CALL OPF(FN.CONVERSION.DETAILS, F.CONVERSION.DETAILS)

    BEGIN CASE

    CASE ID = "SC.MANAGEMENT"
        GEN.COND.FILE = "SCPM.GEN.CONDITION"


    CASE ID = "FUNDS.TRANSFER"
        GEN.COND.FILE =  "FT.GEN.CONDITION"


    CASE ID = "FIDUCIARY"
        GEN.COND.FILE =  "FD.GEN.CONDITION"

    CASE ID = "LETTER.OF.CREDIT"
        GEN.COND.FILE =  "LC.GEN.CONDITION"

    CASE ID = "STATEMENT"
        GEN.COND.FILE =  "STMT.GEN.CONDITION"

    CASE ID = "SC.TRADING"
        GEN.COND.FILE =  "SCTR.GEN.CONDITION"

    CASE ID = "TAX"
        GEN.COND.FILE =  "TAX.GEN.CONDITION"

    CASE ID = "ACCOUNT"
        GEN.COND.FILE =  "ACCT.GEN.CONDITION"

    CASE ID = "SC.SAFEKEEPING"
        GEN.COND.FILE =  "SCSK.GEN.CONDITION"
    END CASE

    CONVERSION.RECORD.NAME = 'CONV.':GEN.COND.FILE:'.G15'
    CALL F.READ(FN.CONVERSION.DETAILS, CONVERSION.RECORD.NAME, R.CONVERSION.REC, F.CONVERSION.DETAILS, ER)
*
* Even if CO.CODE in CONVERSION.DETAIL of all XX.GEN.CONDITION is derived here dynamically, this cause a problem
* when there are two lead companies with different number of priorities defined.
* Hence the CO.CODE fields are nullified now. The Record routine CONV.XX.GEN.CONDITION.G15 for all GEN.CONDITION
* have logic to build its AUDIT fields.
*
    R.CONVERSION.REC<4> = ""
    R.CONVERSION.REC<5>= ""
*
* DO A WRITE INSTEAD OF F.WRITE AS THE XX.GEN.CONDITION RECORDS ARE NOT CONVERTED
* DUE TO THE CO.CODE VARIES WHEN DYNAMIC FIELDS ARE PRESENT DURING RUN.CONVERSION.PGMS
* THIS PROBLEM DOES NOT RASIE WHRN CONVERSION.DETAILS IS VERIFIED.
*
    WRITE R.CONVERSION.REC ON F.CONVERSION.DETAILS , CONVERSION.RECORD.NAME

    RETURN

*************************************************************************************************
*
END
