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

* Version n dd/mm/yy  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>-93</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ReportGeneration
    SUBROUTINE CONV.RE.PRINT.DEAL.RPT.R06(BATCH.ID , R.BATCH , BATCH.FILE)
*----------------------------------------------------------------------------- 
* Conversion for
* 1) Populating jobs RE.UPDT.STAT.LINE.CONT , RE.UPDATE.LINE.BAL.MVMT , RE.BUILD.LINE.MVMT present  in
*    Batch RE.UPD.LINE.BAL.MVMT as this made OB.
*
* 2) Replacing the job RE.GET.DEAL.DETAILS with  RE.OUTPUT.EXTRACT
*
* 3) Replacing the job RE.PRINT.DEAL.DETAILS with  RE.OUTPUT.EXTRACT.MISMATCH
*
* 4) Adding EB.PRINT job with an ENQUIRY CRB.REPORT
*-------------------------------------------------------------------------------
* MODIFICATION LOG:
*------------------
* 05/10/2005 - BG_100009498
*              Conversion routine for CRB restructuring SAR.
*
* 11/10/2005 - BG_100009539
*              Changed to Record Routine.
*
* 25/10/2005 - CI_10035981
*              Build RE.EXTRACT.PARAMS & RE.RETURN.EXTRACT records if not available
*              but specified for reporting.
*
* 20/01/2006 - GLOBUS_BG_100009983
*              Changes done to write ENQUIRY.REPORT record to generate
*              CRB report during COB.
*
* 14/02/2006 - GLOBUS_BG_100010258
*              Changes done to reset the variable REP.NAMES'S pointer.
*              And added verification jobs.
*
* 12/02/2010 - DEFECT 21648 / TASK 21892
*              Read the RE.EXTRACT.PARAMS & RE.RETURN.EXTRACT records with LOCK.
*          
*--------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.BATCH
    $INSERT I_F.DATES
    $INSERT I_F.USER
*---------------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB ADD.BATCH.JOBS

    RETURN
*---------------------------------------------------------------------------------
INITIALISE:
*---------
    NEXT.RUN.DATE = TODAY
    REP.NAMES = ''
    JOB.VERIFY = ''

    FN.RE.EXTRACT.PARAMS = 'F.RE.EXTRACT.PARAMS'
    F.RE.EXTRACT.PARAMS = ''
    CALL OPF(FN.RE.EXTRACT.PARAMS,F.RE.EXTRACT.PARAMS)

    FN.RE.RETURN.EXTRACT = 'F.RE.RETURN.EXTRACT'
    F.RE.RETURN.EXTRACT = ''
    CALL OPF(FN.RE.RETURN.EXTRACT,F.RE.RETURN.EXTRACT)

    FN.RE.STAT.REPORT.HEAD = 'F.RE.STAT.REPORT.HEAD'
    F.RE.STAT.REPORT.HEAD = ''
    CALL OPF(FN.RE.STAT.REPORT.HEAD,F.RE.STAT.REPORT.HEAD)

    F.ENQUIRY.REPORT = ''
    FN.ENQUIRY.REPORT = 'F.ENQUIRY.REPORT'
    CALL OPF(FN.ENQUIRY.REPORT,F.ENQUIRY.REPORT)

    RETURN
*---------------------------------------------------------------------------------
ADD.BATCH.JOBS:
*-------------

    IF INDEX(BATCH.ID,'RE.PRINT.DEAL.RPT',1) THEN

        *---    Replace bath job RE.GET.DEAL.DETAILS with new job RE.OUTPUT.EXTRACT - should be 4rth job in this batch.
        LOCATE "RE.GET.DEAL.DETAILS" IN R.BATCH<6,1> SETTING JOB.POSN THEN
            R.BATCH<6,JOB.POSN> = "RE.OUTPUT.EXTRACT"
            R.BATCH<7,JOB.POSN> = 'RE.BUILD.LINE.MVMT'
            REP.NAMES = R.BATCH<11,JOB.POSN>      ;* report name(s) for populating the DATA fld for the next job.

            *---        Replace batch job RE.PRINT.DEAL.DETAILS with new job RE.OUTPUT.EXTRACT.MISMATCH - should be 5th job in this batch.
            LOCATE "RE.PRINT.DEAL.DETAILS" IN R.BATCH<6,1> SETTING JOB.POSN THEN
                R.BATCH<6,JOB.POSN> = "RE.OUTPUT.EXTRACT.MISMATCH"
                R.BATCH<7,JOB.POSN> = "RE.OUTPUT.EXTRACT"   ;* verification
                R.BATCH<11,JOB.POSN> = REP.NAMES  ;* datas from previous job.
            END

            *---        Populate RE.UPDT.STAT.LINE.CONT as the 1rst job
            INS 'RE.UPDT.STAT.LINE.CONT' BEFORE R.BATCH<6,1>
            SVM = 1
            GOSUB UPDATE.REL.FLDS

            *---        Populate RE.UPDATE.LINE.BAL.MVMT as the 2nd job
            INS 'RE.UPDATE.LINE.BAL.MVMT' BEFORE R.BATCH<6,2>
            SVM = 2 ; JOB.VERIFY = 'RE.UPDT.STAT.LINE.CONT'
            GOSUB UPDATE.REL.FLDS

            *---        Populate RE.BUILD.LINE.MVMT as the 3rd job
            INS 'RE.BUILD.LINE.MVMT' BEFORE R.BATCH<6,3>
            SVM = 3 ; JOB.VERIFY = 'RE.UPDATE.LINE.BAL.MVMT'
            GOSUB UPDATE.REL.FLDS

            *---        Populate EB.PRINT as the last job and attach an ENQUIRY
            INS 'EB.PRINT' BEFORE R.BATCH<6,6>
            SVM = 6 ; JOB.VERIFY = 'RE.OUTPUT.EXTRACT.MISMATCH'
            GOSUB UPDATE.REL.FLDS

            REP.NAME = '' ; REP.POS = '' ; IDX = 0
            LOOP
                REMOVE REP.NAME FROM REP.NAMES SETTING REP.POS
            WHILE REP.NAME:REP.POS
                IDX += 1
                ENQUIRY.REPORT.ID = 'CRB.REPORT.':REP.NAME
                GOSUB CREATE.ENQUIRY.REPORT
                R.BATCH<11,6,IDX> = 'ENQ ':ENQUIRY.REPORT.ID
            REPEAT

        END

        IF REP.NAMES THEN
            *---        Check RE.EXTRACT.PARAMS exists for the report(s) , if not create
            GOSUB CHECK.RE.EXTRACT.PARAM

            *---        Check RE.RETURN.EXTRACT exists for the report(s)  , if not create
            GOSUB CHECK.RE.RETURN.EXTRACT
        END
    END

    RETURN

*******************************************************************************
UPDATE.REL.FLDS:
****************

    FOR I = 7 TO 15
        BEGIN CASE
            CASE I = 7
                INS JOB.VERIFY BEFORE R.BATCH<I,SVM>
                JOB.VERIFY = ''
            CASE I = 8
                INS 'D' BEFORE R.BATCH<I,SVM>
            CASE I = 9
                INS NEXT.RUN.DATE BEFORE R.BATCH<I,SVM>
            CASE 1
                INS '' BEFORE R.BATCH<I,SVM>
        END CASE
    NEXT I

    RETURN

*****************************************************************************
CHECK.RE.EXTRACT.PARAM:
***********************

    REP.ID = '' ; REP.NAME = ''
    REP.NAMES = REP.NAMES     ;* Just to re-set the pointer
    LOOP
        REMOVE REP.NAME FROM REP.NAMES SETTING REP.ID
    WHILE REP.NAME:REP.ID

        READU RE.EXTRACT.PARAMS.REC FROM F.RE.EXTRACT.PARAMS , REP.NAME LOCKED
            RETURN ;* Return if record is locked, another agent may update the file
        END THEN
            CURR.NO = RE.EXTRACT.PARAMS.REC<21>
            RE.EXTRACT.PARAMS.REC<21> = CURR.NO +1
        END ELSE
            RE.EXTRACT.PARAMS.REC<1,1> = 1        ;* Narrative fld
            RE.EXTRACT.PARAMS.REC<1,2> = 2        ;* Narrative fld
            RE.EXTRACT.PARAMS.REC<6> = "CLOSING"  ;* Amount type to CLOSING
            RE.EXTRACT.PARAMS.REC<7> = "YES"      ;* Contrat details to YES
            RE.EXTRACT.PARAMS.REC<10> = "YES"     ;* Pl details to YES
            RE.EXTRACT.PARAMS.REC<13,1> = "AL.NET.CONSOL.KEY"
            RE.EXTRACT.PARAMS.REC<13,2> = "PL.NET.OPP.LINE"
            RE.EXTRACT.PARAMS.REC<21> = 1         ;* Curr no
        END
        IF RE.EXTRACT.PARAMS.REC<22> EQ 'SY_CONV.RE.PRINT.DEAL.RPT.R06' THEN
            RELEASE F.RE.EXTRACT.PARAMS , REP.NAME ;* Release the record,No need to update if already file is updated.
            RETURN
        END
        RE.EXTRACT.PARAMS.REC<11> = "LINE.IDS"    ;* New Key format to LINE.IDS
        RE.EXTRACT.PARAMS.REC<12> = "Y" ;* Populate CRB.REPORT to Y
        RE.EXTRACT.PARAMS.REC<13,3> = "NET.LINE.BAL"        ;* New Options

        RE.EXTRACT.PARAMS.REC<22> = 'SY_CONV.RE.PRINT.DEAL.RPT.R06'
        X = OCONV(DATE(),"D-")
        X = X[9,2]:X[1,2]:X[4,2]:TIMEDATE()[1,2]:TIMEDATE()[4,2]
        RE.EXTRACT.PARAMS.REC<23> = X
        RE.EXTRACT.PARAMS.REC<24> = 'SY_CONV.RE.PRINT.DEAL.RPT.R06'
        RE.EXTRACT.PARAMS.REC<25> = R.COMPANY(18)
        RE.EXTRACT.PARAMS.REC<26> = R.USER<6>

        WRITE RE.EXTRACT.PARAMS.REC ON F.RE.EXTRACT.PARAMS, REP.NAME

    REPEAT

    RETURN
*****************************************************************************
CHECK.RE.RETURN.EXTRACT:
************************

    REP.ID = '' ; REP.NAME = ''
    REP.NAMES = REP.NAMES     ;* Just to re-set the pointer
    LOOP
        REMOVE REP.NAME FROM REP.NAMES SETTING REP.ID
    WHILE REP.NAME:REP.ID
        READU RE.RETURN.EXTRACT.REC FROM F.RE.RETURN.EXTRACT , REP.NAME LOCKED
            RETURN ;* Return if record is locked, another agent may update the file 
        END THEN
            RELEASE F.RE.RETURN.EXTRACT , REP.NAME
        END ELSE
            READ.ERR = ''
            CALL F.READ(FN.RE.STAT.REPORT.HEAD,REP.NAME,R.RE.STAT.REPORT.HEAD,F.RE.STAT.REP.HEAD,READ.ERR)

            RE.RETURN.EXTRACT.REC<1> = R.RE.STAT.REPORT.HEAD<1>       ;* Description fld.
            RE.RETURN.EXTRACT.REC<2> = REP.NAME
            RE.RETURN.EXTRACT.REC<3> = "YES"      ;* Set build DICT to "Yes"
            RE.RETURN.EXTRACT.REC<4> = "0001"     ;* Set the start line for report
            RE.RETURN.EXTRACT.REC<5> = "9999"     ;* Set the end line for the report

            RE.RETURN.EXTRACT.REC<12> = 1         ;* Curr no
            RE.RETURN.EXTRACT.REC<13> = 'SY_CONV.RE.PRINT.DEAL.RPT.R06'
            X = OCONV(DATE(),"D-")
            X = X[9,2]:X[1,2]:X[4,2]:TIMEDATE()[1,2]:TIMEDATE()[4,2]
            RE.RETURN.EXTRACT.REC<14> = X
            RE.RETURN.EXTRACT.REC<15> = 'SY_CONV.RE.PRINT.DEAL.RPT.R06'
            RE.RETURN.EXTRACT.REC<16> = R.COMPANY(18)
            RE.RETURN.EXTRACT.REC<17> = R.USER<6>

            WRITE RE.RETURN.EXTRACT.REC ON F.RE.RETURN.EXTRACT, REP.NAME
        END
    REPEAT

    RETURN

*******************************************************************************
CREATE.ENQUIRY.REPORT:
**********************

    R.HEAD = ''
    CALL CACHE.READ('F.RE.STAT.REPORT.HEAD', REP.NAME, R.HEAD,ER)

    READU R.ENQUIRY.REPORT FROM F.ENQUIRY.REPORT, ENQUIRY.REPORT.ID LOCKED
        RETURN ;* Return if record is locked, another agent may update the file  
    END THEN
        RELEASE F.ENQUIRY.REPORT, ENQUIRY.REPORT.ID
    END ELSE
        R.ENQUIRY.REPORT<1> = R.HEAD<1>
        R.ENQUIRY.REPORT<2,1> = "CRB.REPORT"
        R.ENQUIRY.REPORT<3,1,1> = "REPORT.NAME"
        R.ENQUIRY.REPORT<4,1,1> = "EQ"
        R.ENQUIRY.REPORT<5,1,1> = REP.NAME
        R.ENQUIRY.REPORT<7> = 'CRB.':REP.NAME
        R.ENQUIRY.REPORT<26> = 1        ;* Curr no
        R.ENQUIRY.REPORT<27> = 'SYS_CONV.RE.PRINT.DEAL.RPT.R06'       ;* Inputter
        X = OCONV(DATE(),"D-")
        X = X[9,2]:X[1,2]:X[4,2]:TIMEDATE()[1,2]:TIMEDATE()[4,2]
        R.ENQUIRY.REPORT<28> = X        ;* Date time
        R.ENQUIRY.REPORT<29> = 'SY_CONV.RE.PRINT.DEAL.RPT.R06'        ;* Authoriser
        R.ENQUIRY.REPORT<30> = R.COMPANY(18)      ;* Company Code
        R.ENQUIRY.REPORT<31> = R.USER<6>          ;* Department code

        WRITE R.ENQUIRY.REPORT ON F.ENQUIRY.REPORT, ENQUIRY.REPORT.ID
    END

    RETURN
*******************************************************************************
    END
