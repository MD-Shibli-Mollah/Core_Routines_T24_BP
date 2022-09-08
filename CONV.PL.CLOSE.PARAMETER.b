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
* <Rating>-104</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.YearEnd
    SUBROUTINE CONV.PL.CLOSE.PARAMETER
*______________________________________________________________________________________
*
* This conversion routine will loop through the Company record and check if it
* is a Lead company. In that case, it will read the Batch record for PL.MOVE.TO.AL to determine
* the frequency of the batch if one is defined.
* The following default values will be set:
*   PL.CLOSE.REPORTS:   'DAILY'  pointing to the record from RE.STAT.REQUEST
*   PL.CLOSE.RUN.FREQ : Yearly
*   PL.TYPES.TO.EXCLUDE: All Contigent P&L
*   AL.GROUPING:         First element in the 'PROFIT&LOSS' record in CONSOLIDATE.COND.
* Since the batch PL.MOVE.TO.AL will now run at FIN level and not at FRP level. The batch record
* held for the books will be deleted.
*______________________________________________________________________________________
*
* Modification logs:
* -----------------
* 21/01/07 - GLOBUS_EN_10003112
*            New routine
* 06/03/07 - EN_10003235
*            To add two new fields in PL.CLOSE.PARAMETER.
*            PLC.REP.TYPE and PL.CLOSE.HALT.PROCESS
* 27/03/07 - BG_100013447
*            Change the override. Change of field name
* 18/09/07 - BG_100015214
*            F.WRITE entries were not committed to disk when being
*            used by the conversion process. It worked under batch
*            as F.WRITE goes directly to disk in batch.
*
* 05/01/09 - BG_100021500
*            CACHE.READ and F.READ is changed to READ. F.WRITE and F.DELETE is changed to
*            WRITE and DELETE respectively.
*
* 09/06/09 - CI_10063434
*            REPORT field is changed to use TXN.JOURNAL.PRINT report
*
* 17/12/09 - BG_100026249
*            No need to populate contingent PL type in TYPE.TO.EXCLUDE field
*______________________________________________________________________________________
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.BATCH
    $INSERT I_F.PL.CLOSE.PARAMETER
    $INSERT I_F.CONSOLIDATE.COND
    $INSERT I_F.COMPANY.CHECK
*______________________________________________________________________________________
*
    GOSUB INITIALISE          ;* Initialise and open files here

*** <region name= Main Process>
***


    COMP.IDX = 0
    SAVE.CO.CODE = ID.COMPANY
    COMP.LIST = R.COMP.CHECK<EB.COC.COMPANY.CODE>
    NO.OF.COMP = DCOUNT(COMP.LIST,VM)

    FOR COMP.CNT = 1 TO NO.OF.COMP
        COMP.ID = COMP.LIST<1,COMP.CNT>

        HOLD.RECORD = ""
        GOSUB CALL.LOAD.COMPANY
        COMP.MNE = R.COMPANY(EB.COM.MNEMONIC)

        USING.COM = R.COMP.CHECK<EB.COC.USING.COM,COMP.CNT>
        USING.MNE = R.COMP.CHECK<EB.COC.USING.MNE,COMP.CNT>
        GOSUB CHECK.BATCH.RECORD        ;*
        GOSUB CREATE.PL.CLOSE.PARAM     ;*  Create PL.CLOSE.PARAMETER record.
        IF USING.COM THEN
            GOSUB DELETE.BATCH.RECORD   ;*    ;* Delete the FRP record
        END
    NEXT COMP.CNT

    COMP.ID = SAVE.CO.CODE
    GOSUB CALL.LOAD.COMPANY

    RETURN
*** </region>
*______________________________________________________________________________________
*
*** <region name= INITIALISE>
INITIALISE:
*----------

    FN.BATCH= 'F.BATCH'
    F.BATCH = ''
    CALL OPF(FN.BATCH,F.BATCH)

    FN.BATCH.NAU = 'F.BATCH$NAU'
    F.BATCH.NAU = ""
    CALL OPF(FN.BATCH.NAU,F.BATCH.NAU)

    FN.COMPANY.CHECK = 'F.COMPANY.CHECK'
    F.COMPANY.CHECK = ''
    CALL OPF(FN.COMPANY.CHECK,F.COMPANY.CHECK)

    R.COMP.CHECK = ""
    READ R.COMP.CHECK FROM F.COMPANY.CHECK, 'FIN.FILE' ELSE
        R.COMP.CHECK = ''
    END

    GOSUB OPEN.FILES
    COND.REC = ""
    CALL RE.READ.CONSOLIDATE.COND('PROFIT&LOSS',COND.REC,"")
    RETURN
*** </region>
*______________________________________________________________________________________
*
*** <region name= CALL.LOAD.COMPANY>
CALL.LOAD.COMPANY:
*-----------------
    IF COMP.ID <> ID.COMPANY THEN
        CALL LOAD.COMPANY(COMP.ID)
        GOSUB OPEN.FILES
    END

    RETURN


*--------------------------------------------------------------------------------------------
OPEN.FILES:
*-----------
    CALL OPF(FN.BATCH,F.BATCH)
    FN.PL.CLOSE.PARAMETER = 'F.PL.CLOSE.PARAMETER'
    F.PL.CLOSE.PARAMETER = ""
    CALL OPF(FN.PL.CLOSE.PARAMETER,F.PL.CLOSE.PARAMETER)

    FN.PL.CLOSE.PARAMETER.NAU = "F.PL.CLOSE.PARAMETER$NAU"
    F.PL.CLOSE.PARAMETER.NAU = ""
    CALL OPF(FN.PL.CLOSE.PARAMETER.NAU,F.PL.CLOSE.PARAMETER.NAU)
    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CHECK.BATCH.RECORD>
CHECK.BATCH.RECORD:
***
    R.BATCH = ""
    NEXT.RUN.DATE = ""
    BATCH.ID = 'PL.MOVE.TO.AL'
    READ R.BATCH FROM F.BATCH, BATCH.ID ELSE
        BATCH.ID = COMP.MNE:'/PL.MOVE.TO.AL'
        READ R.BATCH FROM F.BATCH, BATCH.ID ELSE
            R.BATCH = ''
        END
    END

* If a next run date is defined in the batch record, it should be the first day of the next close out period
    PLC.POS = ""
    LOCATE 'PL.CLOSE.OUT' IN R.BATCH<BAT.JOB.NAME,1> SETTING PLC.POS THEN
        NEXT.RUN.DATE = R.BATCH<BAT.NEXT.RUN.DATE,PLC.POS>
    END ELSE
        NEXT.RUN.DATE = ""
    END

    IF NEXT.RUN.DATE <> "" THEN
        CALL CDT("",NEXT.RUN.DATE,"-1W")
    END

    IF NEXT.RUN.DATE <> R.COMPANY(EB.COM.FINANCIAL.YEAR.END)[1,8] THEN
        HOLD.RECORD = 1
    END ELSE
        HOLD.RECORD = ""

    END
    NEXT.RUN.DATE = R.COMPANY(EB.COM.FINANCIAL.YEAR.END)
    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CREATE.PL.CLOSE.PARAM>
CREATE.PL.CLOSE.PARAM:
***
    R.PLC.PARAM = ""
    READU R.PLC.PARAM FROM F.PL.CLOSE.PARAMETER, COMP.ID ELSE
    R.PLC.PARAM = ''
    END

    R.PLC.PARAM<PL.PAR.REPORT.TYPE,1,1> = "CRF"
    R.PLC.PARAM<PL.PAR.REPORT,1,1> = 'DAILY'      ;* Run the daily CRF reports

    R.PLC.PARAM<PL.PAR.REPORT.TYPE,2,1> = "RTN"
    R.PLC.PARAM<PL.PAR.REPORT,2,1> = "TXN.JOURNAL.PRINT"

    R.PLC.PARAM<PL.PAR.CLOSE.FREQ.DATE> = NEXT.RUN.DATE     ;* by default set it to yearly
    R.PLC.PARAM<PL.PAR.TYPES.TO.EXCLUDE> = "" 
    R.PLC.PARAM<PL.PAR.AL.GROUPING> = COND.REC<RE.CON.NAME,1,1>       ;* the first element of the Consolidate.Cond record
    X = OCONV(DATE(),"D-")
    X = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
    R.PLC.PARAM<PL.PAR.DATE.TIME> = X
    R.PLC.PARAM<PL.PAR.INPUTTER> = 'CONV.PL.CLOSE.PARAMETER'
    R.PLC.PARAM<PL.PAR.CO.CODE> = ID.COMPANY
    IF HOLD.RECORD THEN
        GOSUB UPDATE.OVERRIDE ;*
        R.PLC.PARAM<PL.PAR.RECORD.STATUS> = 'IHLD'
        WRITE R.PLC.PARAM TO F.PL.CLOSE.PARAMETER.NAU, COMP.ID
    END ELSE
        R.PLC.PARAM<PL.PAR.AUTHORISER> = 'CONV.PL.CLOSE.PARAMETER'
        R.PLC.PARAM<PL.PAR.CURR.NO> = 1
        WRITE R.PLC.PARAM TO F.PL.CLOSE.PARAMETER, COMP.ID
    END
    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= DELETE.BATCH.RECORD>
DELETE.BATCH.RECORD:


    NO.OF.BOOK = DCOUNT(USING.COM,SM)

    FOR BK.CNT = 1 TO NO.OF.BOOK
        BOOK.MNE = USING.MNE<1,1,BK.CNT>
        BATCH.ID = BOOK.MNE:'/PL.MOVE.TO.AL'
        DELETE F.BATCH, BATCH.ID
        DELETE F.BATCH.NAU, BATCH.ID
    NEXT BK.CNT
    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= UPDATE.OVERRIDE>
UPDATE.OVERRIDE:
**
    OVE.CNT = COUNT(R.PLC.PARAM<PL.PAR.OVERRIDE>,VM)+1


    TEXT = "Review CLOSE.RUN.FREQ- Batch date & Year end cycle differ"

    IF OVE.CNT = 1 THEN
        R.PLC.PARAM<PL.PAR.OVERRIDE,1> = TEXT
    END ELSE
        R.PLC.PARAM<PL.PAR.OVERRIDE,OVE.CNT> = R.PLC.PARAM<PL.PAR.OVERRIDE>:VM:TEXT
    END

    RETURN
*** </region>
    END
