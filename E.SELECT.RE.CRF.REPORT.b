* @ValidationCode : Mjo3MzkxMDYwNzI6Q3AxMjUyOjE1Mzg5OTg5MTQ0NTA6cHVuaXRoa3VtYXI6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTAuMjAxODA5MDYtMDIzMjoxNzU6MTUy
* @ValidationInfo : Timestamp         : 08 Oct 2018 17:11:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : punithkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 152/175 (86.8%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180906-0232
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-60</Rating>
*-----------------------------------------------------------------------------
$PACKAGE RE.ModelBank

SUBROUTINE E.SELECT.RE.CRF.REPORT(SEL.IDS)
*
* This is a nofile enquiry routine to fetch all the re.stat.line.cont ids
*
*----------------------------------------------------------------------
* Modification log:
*------------------
* 09/09/05 - EN_10002664
*            Restrucure of reporting pgms to consistantly
*            use RE.RETURN.EXTRACT
*
* 30/01/06 - GLOBUS_BG_100010124
*            Currency wise details and TOTAL line details not displaying
*            correctly - Resolved.
*
* 07/12/06 - CI_10045983
*            Customer name display problem in CRB report for SEC.TRADES.
*
* 13/03/07 - EN_10003255
*            Modified to call DAS to select data.
*
* 22/05/07 - CI_10049171
*            Changes done to resolve the problem of blank lines between
*            customer details CRB report on the same line
*
* 28/05/07 - CI_10049359
*            System fatals out while running the equiry CRB.REPORT,when
*            Sc not installed.
*
* 26/06/07 - CI_10050000
*            Modifying the changes done through CI_10049171 slightly,
*            to resolve the performance problem.
*
* 22/10/07 - CI_10052064
*            The select statement has to be changed to select records
*            correctly in non-jbase database environments.
*
*22/01/08 -  CI_10053399
*            Key level records for PL keys will be included in FXXX.RE.CRF.XXXX file.
*            Blank lines which appear in the report due to PL key level records
*            need to be suppressed.
*
* 02/03/08 - CI_10053943
*            Warning message in ENQUIRY.REPORT .
*
* 04/08/08 - CI_10057050
*            CRB GL does not show line heading and description
*
* 10/06/11 - Defect - 216884 / Task - 225502
*            Blank pages are displayed in CRB report when PL.DETAILS is set as NO in RE.EXTRACT.PARAMS
*
* 20/06/2014 - DEFECT 1026239 / TASK 1034032
*              Return to the enquiry if CRB flat file is not present for the given report.
*
* 19/04/15 - Enhancement - 1263572
*            TO avoid duplicate common variables, frequent variables are added in
*            in a common insert file.
*
* 05/10/18 - Defect 2794524// Task 2798866
*            When the last line has definition with PROFT.APPLIC.ID = PL and has the balance as 0.with no contracts under that line.
*            code is changed to LINE.ARRAY<PREV.LINE.NO> = RE.CRF.ID.LIST. To assign the list to proper line no.
*
*----------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.RE.EXTRACT.PARAMS
    $INSERT I_E.CRB.REPORT.COMMON
    $INSERT I_F.RE.STAT.LINE.CONT
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_DAS.COMMON
    $INSERT I_DAS.RE.CRF
    $INSERT I_DAS.RE.STAT.LINE.CONT
    $INSERT I_F.COMPANY
    $INSERT I_RE.REPORT.GEN.FILES.COMMON
*
*------------------------------------------------------------------------
*
    GOSUB INIT

    IF ETEXT OR ENQ.ERROR THEN
        ETEXT = ''
        RETURN
    END

    GOSUB GET.SS.RECORD       ;* Get the details from the crb report

    GOSUB BUILD.BASE.LIST     ;* Fetch all the base crf report id list

    IF SEL.IDS THEN

        GOSUB APPEND.SLC.IDS  ;* Populate re.stat.line.cont ids along with header ids.

    END

RETURN
*--------------------------------------------------------------------
INIT:
*----
    SEL.IDS = ''
    REPORT.NAME = D.RANGE.AND.VALUE<1,1,1>

    FN.RE.CRF.REPORT = 'F.RE.CRF.':REPORT.NAME
    FN.RE.CRF.REPORT<2> = 'NO.FATAL.ERROR'
    F.RE.CRF.REPORT = ''
    CALL OPF(FN.RE.CRF.REPORT, F.RE.CRF.REPORT)

    IF NOT(FILEINFO(F.RE.CRF.REPORT,0)) THEN
        ENQ.ERROR = "Report not found in the company" ;* Return from main, if the file not present.
        RETURN
    END

    FN.RE.STAT.LINE.CONT = 'F.RE.STAT.LINE.CONT'
    F.RE.STAT.LINE.CONT = ''
    CALL OPF(FN.RE.STAT.LINE.CONT, F.RE.STAT.LINE.CONT)

    FN.RE.STAT.LINE.BAL = 'F.RE.STAT.LINE.BAL'
    F.RE.STAT.LINE.BAL = ''
    CALL OPF(FN.RE.STAT.LINE.BAL, F.RE.STAT.LINE.BAL)

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    LOCATE 'SC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING SC.INSTALLED THEN
        FN.SECURITY.MASTER = "F.SECURITY.MASTER"
        F.SECURITY.MASTER = ""
        CALL OPF(FN.SECURITY.MASTER,F.SECURITY.MASTER)
    END ELSE
        SC.INSTALLED = ''
    END

    FN.DEALER.DESK = "F.DEALER.DESK"
    F.DEALER.DESK = ""
    CALL OPF(FN.DEALER.DESK,F.DEALER.DESK)

    CALL CACHE.READ('F.RE.EXTRACT.PARAMS', REPORT.NAME, R.EXTRACT.PARAMS.REC,ER)

*Get all the allowed PL prefixes for all position types.
    POS.TYPE.LIST = ''
    ERR.MSG = ''
    CALL GET.PL.GAAP.TYPE(POS.TYPE.LIST,ERR.MSG)
    PL.PREFIXES = POS.TYPE.LIST<2>:@VM:POS.TYPE.LIST<3>:@VM:POS.TYPE.LIST<4>


RETURN
*--------------------------------------------------------------------
BUILD.BASE.LIST:
*--------------
    CLEARSELECT

    SEL.IDS      = dasReCrfById
    THE.ARGS     = ''
    TABLE.SUFFIX = ''

    IF C$MULTI.BOOK THEN
        SEL.IDS    = dasReCrfIdLikeById
        THE.ARGS = ID.COMPANY ;* @ID LK ...ID.COMPANY...
    END

    SEL.IDS<2> = 'RE.CRF.':REPORT.NAME

    CALL DAS('RE.CRF',SEL.IDS,THE.ARGS,TABLE.SUFFIX)
*
    IF SEL.IDS THEN
        GOSUB BUILD.LINE.ARRAY
    END

RETURN

*--------------------------------------------------------------------
APPEND.SLC.IDS:
*------------------

    FN.RE.STAT.LINE.CONT = 'F.RE.STAT.LINE.CONT'
    F.RE.STAT.LINE.CONT = ''
    CALL OPF(FN.RE.STAT.LINE.CONT,F.RE.STAT.LINE.CONT)
*
    CONT.LIST = dasReStatLineContIdLikeById

* Need a '.' after the report name so has to be quoted so we seperate
* that '.' from the wildcard.

    THE.ARGS ='"' :"'" : REPORT.NAME : ".'" : '...' : '"'

    IF C$MULTI.BOOK THEN
        CONT.LIST   = dasReStatLineContIdLikeIdLikeById
        THE.ARGS<2> = '"...':"'":ID.COMPANY:"'":'"'
    END
    TABLE.SUFFIX = ''
    CALL DAS('RE.STAT.LINE.CONT',CONT.LIST,THE.ARGS,TABLE.SUFFIX)

    LOOP
        REMOVE CONT.ID FROM CONT.LIST SETTING YPOS
    WHILE CONT.ID:YPOS

        LINE.NO = FIELD(CONT.ID, '.', 2,1) + 0
        IF LINE.ARRAY<LINE.NO> THEN
            LINE.ARRAY<LINE.NO> = 'BLANK.LINE':@VM:CONT.ID:@VM:LINE.ARRAY<LINE.NO>
        END ELSE
            LINE.ARRAY<LINE.NO> = 'BLANK.LINE':@VM:CONT.ID
        END

    REPEAT

    GOSUB REMOVE.BLANK.FIELDS
    CONVERT @VM TO @FM IN LINE.ARRAY
    SEL.IDS = LINE.ARRAY

RETURN
*--------------------------------------------------------------------
GET.SS.RECORD:
*------------

    SS.RECORD = ''
    SS.ID = 'RE.CRF.':REPORT.NAME
    CALL GET.STANDARD.SELECTION.DETS(SS.ID,SS.RECORD)
    LOCATE 'LOCAL.BALANCE' IN SS.RECORD<SSL.SYS.FIELD.NAME,1> SETTING LOCAL.BALANCE.POSN THEN
        LOCAL.BALANCE.POSN = SS.RECORD<SSL.SYS.FIELD.NO,LOCAL.BALANCE.POSN>
    END

    LOCATE 'FOREIGN.BALANCE' IN SS.RECORD<SSL.SYS.FIELD.NAME,1> SETTING FOREIGN.BALANCE.POSN THEN
        FOREIGN.BALANCE.POSN = SS.RECORD<SSL.SYS.FIELD.NO,FOREIGN.BALANCE.POSN>
    END

    LOCATE 'CONSOL.KEY' IN SS.RECORD<SSL.SYS.FIELD.NAME,1> SETTING CONSOL.KEY.POSN THEN
        CONSOL.KEY.POSN = SS.RECORD<SSL.SYS.FIELD.NO,CONSOL.KEY.POSN>
    END
    LOCATE 'LINE.TOTAL' IN SS.RECORD<SSL.SYS.FIELD.NAME,1> SETTING LINE.TOTAL.POSN THEN
        LINE.TOTAL.POSN = SS.RECORD<SSL.SYS.FIELD.NO,LINE.TOTAL.POSN>
    END
    LOCATE 'DEAL.BALANCE' IN SS.RECORD<SSL.SYS.FIELD.NAME,1> SETTING DEAL.BALANCE.POSN THEN
        DEAL.BALANCE.POSN = SS.RECORD<SSL.SYS.FIELD.NO,DEAL.BALANCE.POSN>
    END
    LOCATE 'DEAL.LCY.BALANCE' IN SS.RECORD<SSL.SYS.FIELD.NAME,1> SETTING DEAL.LCY.BALANCE.POSN THEN
        DEAL.LCY.BALANCE.POSN = SS.RECORD<SSL.SYS.FIELD.NO,DEAL.LCY.BALANCE.POSN>
    END
    LOCATE 'CURRENCY' IN SS.RECORD<SSL.SYS.FIELD.NAME,1> SETTING CURRENCY.POSN THEN
        CURRENCY.POSN = SS.RECORD<SSL.SYS.FIELD.NO,CURRENCY.POSN>
    END

RETURN
*-------------------------------------------------------------------------------
BUILD.LINE.ARRAY:
*----------------

    YIDX = 0
    LINE.ARRAY = ''
    PREV.LINE.NO = '' ; RE.CRF.ID.LIST = ''
    LOOP
        YIDX += 1
        RE.CRF.ID = SEL.IDS<YIDX>
    WHILE RE.CRF.ID DO
          
        LINE.NO = FIELD(RE.CRF.ID, '*', 1)['.',2,1] + 0

        Y.PL.FLAG = FIELD(FIELD(RE.CRF.ID, '*', 3), '.', 1)

        BEGIN CASE

            CASE FIELD(RE.CRF.ID, '*',4) EQ 'ZZY'
                CONTINUE

*Check PL prefix in the consol key matches any of the available PL prefixes defined in FX.POS.TYPE
            CASE Y.PL.FLAG MATCHES PL.PREFIXES AND FIELD(RE.CRF.ID, '*', 4) EQ ''
                CONTINUE

            CASE FIELD(RE.CRF.ID, '*', 3) = 'TOTAL'
                RE.CRF.ID = 'BLANK.LINE':@VM:RE.CRF.ID:@VM:'BLANK.LINE'

        END CASE

        IF PREV.LINE.NO THEN
            IF LINE.NO NE PREV.LINE.NO THEN
                LINE.ARRAY<PREV.LINE.NO> = RE.CRF.ID.LIST
                RE.CRF.ID.LIST = RE.CRF.ID
            END ELSE
                RE.CRF.ID.LIST := @VM:RE.CRF.ID
            END
        END ELSE
            RE.CRF.ID.LIST = RE.CRF.ID
        END

        PREV.LINE.NO = LINE.NO

    REPEAT

    IF LINE.NO NE PREV.LINE.NO THEN
	    LINE.ARRAY<PREV.LINE.NO> = RE.CRF.ID.LIST   ;*the case when Last line in the RE.CRF.XXX list has no value to be assigned to RE.CRF.ID.LIST
    END ELSE
        LINE.ARRAY<LINE.NO> = RE.CRF.ID.LIST   ;*normal case when last line has values to update in the LINE.ARRAY
    END
    
RETURN
*------------------------------------------------------------------------------
REMOVE.BLANK.FIELDS:
*-------------------

    Y.CNT =  COUNT(LINE.ARRAY, @FM) + 1

    YIDX = 0
    DUMMY.ARRAY = ''
    LOOP
        YIDX += 1
        RE.CRF.ID = LINE.ARRAY<YIDX>
    WHILE YIDX <= Y.CNT  DO
        IF RE.CRF.ID THEN
            DUMMY.ARRAY := @FM:RE.CRF.ID
        END
    REPEAT
    DEL DUMMY.ARRAY<1>
    LINE.ARRAY = DUMMY.ARRAY

RETURN

*-------------------------------------------------------------------------------------------
END
