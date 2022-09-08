* @ValidationCode : MjoxMzU3MjMzOTI3OkNwMTI1MjoxNjE4ODk4NzE0MzA4OnNsYWtzaG1pbmFyYXNpbW1hbjoxNTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4yMDIxMDMwMS0wNTU2OjI0NjoyMjE=
* @ValidationInfo : Timestamp         : 20 Apr 2021 11:35:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : slakshminarasimman
* @ValidationInfo : Nb tests success  : 15
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 221/246 (89.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
* Subroutine Type : Subroutine

* Incoming        : ENQ.DATA

* Outgoing        : ENQ.DATA Common Variable
 
* Attached to     : AA.DETAILS.XXX where XXX stands for the property classes

* Attached as     : Build Routine in the Field BUILD.ROUTINE

* Primary Purpose : To return the appropriate arrangement condition for the property

* Incoming        : Common variable ENQ.DATA Which contains all the
*                 : enquiry selection criteria details

* Change History  :

* Version         : First Version

* Author          : vhariharane@temenos.com
************************************************************
*MODIFICATION HISTORY
*
* 17-Dec-2008 - BG_100021274
*               Changes made to remove the SORT as it does not go
*               well with the date sequence.
*
* 05-Jan-2009 - BG_100021514
*               SELECT criteria should be refined to pass SIM.REF
*               as String within quotes
*
* 30-Jan-2009 - CI_10060271
*               Usage of quotes changed in SELECT since it
*               did not go well with MS-SQL.
*
* 19/04/09 -  BG_100023284
*             "SELECT" has been changed to "SSELECT".
*
* 27/10/10 - Task 104426
*            Ref : HD1043593/99284(Defect)
*            For arrangement conditions, stop removing SELECT and
*            instead build the id by looking into the dated xref.
*
*            pass Sim Mode to AA.GET.ARRANGEMENT.PROPERTIES
*
* 05/03/11 - Task 166711
*            Ref: HD1100696/163392
*            For future dated arrangement set date as Arrangement start date
*            instead of setting TODAY
*
* 30/07/14 - Task : 1072965
*            Defect : 1071045
*            While doing reversal of an arrangement with Auto settlement.
*            The arrangement overview screen for reversal shows Error Message.
*
* 18/08/16 - Task : 1830201
*            Def  : 1822997
*            System should check the forward dated condition was deleted before picking up the appropriate property record.
*
* 11/08/16 - Task : 1893296
*            Defect : 1810450
*            To avoid passing null values to selection which result in "NULL KEY SPECIFIED" error.
*
* 03/10/16 - Task :
*            Defect :
*            A new S type IDesc field is introduced to merge the selection criteria instead of hard coded ENQ.DATA
*            that is currently overwritten with @ID
*
* 28/09/17 - Task :2291057
*            Defect :2278813
*            When the property condition is not defined system performs a SSELECT which causes performance issues
*
* 07/02/18 - Enhancement : 2460852
*            Task : 2460855
*		     Enquiry routine changes to facilitate inheritance only property
*
* 23/07/18 - Enhancement : 2688419
*            Task : 2688422
*            A new S type field is introduced to get the date and Return the @ID based on the given date.
*
* 24/02/21 - Task : 4247691
*            Defect : 4123876
*            When Term is extended due to update payment holiday activity triggered on arrangement then system
*            should display new term properly in Arrangement Overview.
*
* 19/04/2021 - Task : 4346460
*              Defect : 4340550
*              Find the Commitment and Term amount field in unauthorized overview screen
*
*************************************************************
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.BUILD.ARR.COND(ENQ.DATA)
************************************************************

    $USING AA.ProductFramework
    $USING EB.Reports
    $USING AA.Framework
    $USING EB.DataAccess
    $USING EB.DatInterface
    $USING EB.SystemTables


****************************
*
    GOSUB INITIALISE

    IF NOT(ENQ.ERROR) THEN   ;* Process only when there's no error in selection
        GOSUB PROCESS
    END
*
RETURN
****************************
INITIALISE:
****************************
*
    SIM.FLG = ''
    NAU.FLG = ''
    DATE.RECORD = ''
    RET.ID = ''
    RET.ERR = ''
    ARR.RECORD = ''
    PROPERTY.LIST = ''
    EXIT.FLG = ''
    MERGE.SELECTION = ""
    USER.DEFINED.DATE = ""     ;* To determine whether user requested for the specific date

    FILE.VERSION = ENQ.DATA<DCOUNT(ENQ.DATA,@FM)>

    LOCATE "ID.COMP.1" IN ENQ.DATA<2,1> SETTING ARR.POS THEN
        ARR.ID = ENQ.DATA<4,ARR.POS>
    END
    
    PROP.CURRENCY = ""
    LOCATE "ID.COMP.3" IN ENQ.DATA<2,1> SETTING ARR.POS THEN
        IF ENQ.DATA<4,ARR.POS> MATCHES "3A" THEN                ;* Whether it is a currency?
            PROP.CURRENCY = ENQ.DATA<4,ARR.POS>                 ;* Currency is passed for Inheritance Only properties
            DEL ENQ.DATA<2,ARR.POS>
            DEL ENQ.DATA<3,ARR.POS>
            DEL ENQ.DATA<4,ARR.POS>
        END
    END
    
;* read MERGE.SELECTION which S Type IDesc field
    LOCATE "MERGE.SELECTION" IN ENQ.DATA<2,1> SETTING MERGE.SEL.POS THEN
        MERGE.SELECTION = ENQ.DATA<4, MERGE.SEL.POS>
    END

* New selection field introduced in property classes interest, charge, limit, customer, paymentschedule, account
* Get the details when user requested by specific dates

    LOCATE "S.EFFECTIVE.DATE" IN ENQ.DATA<2,1> SETTING REQD.DATE.POS THEN
        USER.DEFINED.DATE = 1
        DATE.OPERAND = ENQ.DATA<3,REQD.DATE.POS> ;* Currently we'll support only EQ and RG
        DATE.VALUE = ENQ.DATA<4,REQD.DATE.POS> ;* Dates inputted by user
        
        GOSUB CheckError ;* To check the error
    END

    FV.AA.ARR = ""
    R.ARR = AA.Framework.Arrangement.Read(ARR.ID, RET.ERR)

    IF R.ARR<AA.Framework.Arrangement.ArrStartDate> GT EB.SystemTables.getToday() THEN
        CMP.DATE = R.ARR<AA.Framework.Arrangement.ArrStartDate>
    END ELSE
        CMP.DATE = EB.SystemTables.getToday()
    END

    BEGIN CASE
        CASE EB.Reports.getEnqSimRef() AND INDEX(FILE.VERSION,"SIM",1)
            SIM.FLG = 1
            FN.AA.SIM = "F.":EB.Reports.getREnq()<2>:"$SIM"
            FV.AA.SIM = ''
            EB.DataAccess.Opf(FN.AA.SIM,FV.AA.SIM)
            SIM.REF = EB.Reports.getEnqSimRef()
            R.SIM = AA.Framework.SimulationRunner.Read(SIM.REF, RET.ERR)
            CMP.DATE = R.SIM<AA.Framework.SimulationRunner.SimSimEndDate>     ;*For Simulation compare with End Date
        CASE INDEX(FILE.VERSION,"NAU",1)
            NAU.FLG = 1
            FN.AA.NAU = "F.":EB.Reports.getREnq()<2>:"$NAU"
            FV.AA.NAU = ''
            EB.DataAccess.Opf(FN.AA.NAU,FV.AA.NAU)
            SIM.REF = ''
    END CASE
*
    FN.AA = "F.":EB.Reports.getREnq()<2>
    FV.AA = ''
    EB.DataAccess.Opf(FN.AA,FV.AA)
    LIV.FLG = 1
*

    PROP.CLS = EB.Reports.getREnq()<2>['.',3,99]
    PROP.CLS = PROP.CLS['$',1,1]
*
RETURN
**********************
PROCESS:
**********************
*
    ARR.INFO = ARR.ID
    BEGIN CASE
        CASE SIM.FLG
            SIM.UPDATED = ''
            EB.DatInterface.SimRead(SIM.REF, 'F.AA.ARRANGEMENT.DATED.XREF', ARR.ID, DATE.RECORD, '', SIM.UPDATED, RET.ERR)
            ARR.INFO<6> = SIM.UPDATED       ;*If Sim Flag is required or not
        CASE 1
            DATE.RECORD = AA.Framework.ArrangementDatedXref.Read(ARR.ID, RET.ERR)
    END CASE

*** By default Arrangement Properties will not return Inheritance Only properties
*** if the property currency is passed then we need to take Inheritance Only properties
*** which contains currency in it.
    REQ.DATE = CMP.DATE
    IF PROP.CURRENCY THEN
        REQ.DATE<3> = "INCL.INHERIT.PROP"   ;* Ask to include Inheritance Only properties also
    END
    AA.Framework.GetArrangementProperties(ARR.INFO, REQ.DATE, ARR.RECORD, PROPERTY.LIST)
    AA.ProductFramework.GetPropertyClass(PROPERTY.LIST, PROPERTY.CLS.LIST)
    REQD.PROP.LIST = ''
    LOOP
        LOCATE PROP.CLS IN PROPERTY.CLS.LIST<1,1> SETTING PROP.CLS.POS THEN
            REQD.PROP.LIST<1,-1> = PROPERTY.LIST<1,PROP.CLS.POS>
            PROPERTY.CLS.LIST<1,PROP.CLS.POS> = ''
        END ELSE
            EXIT.FLG = 1
        END
    UNTIL EXIT.FLG
    REPEAT

    IF NAU.FLG THEN
        FIELD.POS = 3
    END ELSE
        FIELD.POS = 2
    END

    LOOP
        REMOVE PROPERTY FROM REQD.PROP.LIST SETTING PR.POS
    WHILE PROPERTY
***     Property currency is passed so get the record which currency part of this record.

        IF PROP.CURRENCY THEN
            PROPERTY = PROPERTY:AA.Framework.Sep:PROP.CURRENCY
        END
    
        LOCATE PROPERTY IN DATE.RECORD<1, 1> SETTING PROPERTY.POS THEN
        END

        BEGIN CASE

            CASE USER.DEFINED.DATE AND DATE.OPERAND EQ "RG" ;* When user requested records within some range
;* Record Id within some range retrieved here.
;* Incoming is S.EFFECTIVE.DATE RG 20091213 20091220
                START.DATE = FIELD(DATE.VALUE, ' ',1) ;* From which date
                END.DATE = FIELD(DATE.VALUE, ' ',2) ;* Until which date
                
                GOSUB AddSuffix ;* To add the suffix to the start and end date
                
                
                LOCATE START.DATE IN DATE.RECORD<FIELD.POS, PROPERTY.POS, 1> BY 'DR' SETTING START.POS THEN
                END
                LOCATE END.DATE IN DATE.RECORD<FIELD.POS, PROPERTY.POS, 1> BY 'DR' SETTING END.POS THEN
                END
                
                DATES.TO.BE.LOCATED = ""
                
                FOR DATE.LOCATE.POS = END.POS TO START.POS ;* Get all the dates within the range
                    IF DATE.RECORD<FIELD.POS, PROPERTY.POS, DATE.LOCATE.POS> THEN
                        DATES.TO.BE.LOCATED<1,-1> = DATE.RECORD<FIELD.POS, PROPERTY.POS, DATE.LOCATE.POS>
                    END
                NEXT DATE.LOCATE.POS
                
                TOT.DATES = DCOUNT(DATES.TO.BE.LOCATED,@VM)
                FOR EFF.DATE.POS = 1 TO TOT.DATES ;* Loop each date and find that date
                    CMP.DATE = DATES.TO.BE.LOCATED<1,EFF.DATE.POS>
                    GOSUB FIND.DATE       ;* Get it
                    GOSUB CreateReturnId ; *To create Return Id separated by space
                NEXT EFF.DATE.POS
            
            CASE USER.DEFINED.DATE AND DATE.VALUE EQ "ALL" ;* When user requested condition for all dates
;* All record Id are retrieved here.
;* Incoming is S.EFFECTIVE.DATE EQ ALL
                DATES.TO.BE.LOCATED = DATE.RECORD<FIELD.POS, PROPERTY.POS>
                TOT.DATES = DCOUNT(DATES.TO.BE.LOCATED,@SM)
                FOR EFF.DATE.POS = 1 TO TOT.DATES
                    CMP.DATE = DATES.TO.BE.LOCATED<1,1,EFF.DATE.POS>
                    GOSUB FIND.DATE       ;* Get it
                    GOSUB CreateReturnId ; *To create Return Id separated by space
                NEXT EFF.DATE.POS
                
            CASE (USER.DEFINED.DATE AND DATE.OPERAND EQ "EQ") OR NOT(USER.DEFINED.DATE)
                IF ENQ.DATA<1> EQ "AA.DETAILS.TERM.AMOUNT" THEN ;* Incase of AA.DETAILS.TERM.AMOUNT fetch the latest term amount condition date to display the term properly
                    CMP.DATE = DATE.RECORD<FIELD.POS,PROPERTY.POS,1>
                END ELSE
                    IF DATE.VALUE THEN
                        CMP.DATE = DATE.VALUE
                    END
                END
                GOSUB FIND.DATE       ;* Get it
                GOSUB CreateReturnId ; *To create Return Id separated by space
                
        END CASE
    REPEAT

* Building the Selection Criteria and supplying the values

    BEGIN CASE
        CASE RET.ID AND MERGE.SELECTION EQ "YES"
            GOSUB MERGE.ENQ.DATA
        CASE RET.ID
            ENQ.DATA<2,1> = "@ID"
            ENQ.DATA<3,1> = "EQ"
            ENQ.DATA<4,1> = RET.ID
        CASE 1 ;*To avoid unnecessary SSELECT on AA.ARR.XXX
            ENQ.DATA<2,1> = "@ID"
            ENQ.DATA<3,1> = "EQ"
            ENQ.DATA<4,1> = ARR.ID
    END CASE
RETURN

*** <region name= Merge the pre selection criteria>
*** <desc> </desc>
MERGE.ENQ.DATA:

    LOCATE "@ID" IN ENQ.DATA<2, 1> SETTING AT.ID.POS THEN
        ENQ.DATA<3, AT.ID.POS> = "EQ"
        ENQ.DATA<4, AT.ID.POS> = RET.ID
    END ELSE
        ENQ.DATA<2, -1> = "@ID"
        ENQ.DATA<3, -1> = "EQ"
        ENQ.DATA<4, -1> = RET.ID
    END

RETURN
*** </region>

****************************
FIND.DATE:
****************************
** If we are processing an arrangement the proeprty records will contain
** a sequence number. Each different version of the dated property will
** increment the sequence number for the date, for the first record there
** is not sequence number
** So when locating for the latest date check to see if a date is supplied with
** a sequence number, if not add a high sequence number so that the locate by DR
** returns the latest record
** For exmaple we will store 20070718.2 sm 20070718.1 sm 20070718 sm 20070716
** Looking for 20070717 should return 20070716
** looking for the latest 20070718 should return 20070718.2. If we don't add
** a sequence of .999 we would get 20070716
*
    ID.DATE = CMP.DATE
    IF NOT(INDEX(ID.DATE,".",1)) THEN
        SEARCH.DATE = ID.DATE:".999"
    END ELSE
        SEARCH.DATE = ID.DATE
    END

    LOCATE SEARCH.DATE IN DATE.RECORD<FIELD.POS, PROPERTY.POS, 1> BY 'DR' SETTING POS THEN          ;*  Locate to get the exact / nearest date...
        CHECK.DELETE = DATE.RECORD<6, PROPERTY.POS, POS>    ;* If that date having delete option then delete that date from dated xref.
        IF CHECK.DELETE THEN
            DEL DATE.RECORD<FIELD.POS, PROPERTY.POS, POS>
        END
    END

    LOCATE SEARCH.DATE IN DATE.RECORD<FIELD.POS, PROPERTY.POS, 1> BY 'DR' SETTING DATE.POS THEN     ;* Locate to get the exact / nearest date...
        NULL
    END
    LOC.DATE = DATE.RECORD<FIELD.POS, PROPERTY.POS, DATE.POS>         ;* Return the date for the position
    NO.AUTH.DATES = DCOUNT(DATE.RECORD<FIELD.POS,PROPERTY.POS>,@SM)
    NO.RNAU.DATES = DCOUNT(DATE.RECORD<4,PROPERTY.POS>,@SM)

    IF FIELD.POS = 2 AND (NO.RNAU.DATES NE NO.AUTH.DATES) THEN   ;* If authorised record date is picked and that is not the last date
        TEMP.DATE.RECORD = DATE.RECORD
        DEL.RNAU.POS = 4
        GOSUB CHECK.RNAU.AND.DELETE.DATES         ;* Check if the same date has been reversed
        DEL.RNAU.POS = 6
        GOSUB CHECK.RNAU.AND.DELETE.DATES         ;* Check if the same date has been deleted
    END

RETURN

*** </region>

*** <region name= Check for RNAU dates>
*** <desc> </desc>
****************************
CHECK.RNAU.AND.DELETE.DATES:
****************************

* Imagine a scenario like this:
* 04-Jan - IssueBill
* Today : 10-Jan
* When a backdated change interest is done effective 03-Jan, and authorised. When the rate change is reversed now, then the IB should replay effective
* the old rate(before the 03-Jan rate) even though AUTH dates for 03-Jan still exists. Hence ignoring the 03Jan rate when reversal dates exist

    EXIT.FLAG = ''

    IF DATE.RECORD<DEL.RNAU.POS,PROPERTY.POS> THEN ;* First check if there are any reversals at all
        LOOP
        UNTIL EXIT.FLAG
            IF DEL.RNAU.POS = 6 THEN
                TEMP.LOC.DATE = "DELETE*":LOC.DATE ;* Deleted conditions were preceeded with DELETE.
            END ELSE
                TEMP.LOC.DATE = LOC.DATE
            END
            FIND TEMP.LOC.DATE IN DATE.RECORD<DEL.RNAU.POS,PROPERTY.POS> SETTING FPOS,VPOS,SPOS THEN
                DEL TEMP.DATE.RECORD<FIELD.POS, PROPERTY.POS, DATE.POS>         ;* Delete the date from AUTH record so that it is not picked
                LOCATE SEARCH.DATE IN TEMP.DATE.RECORD<FIELD.POS, PROPERTY.POS, 1> BY 'DR' SETTING DATE.POS THEN        ;* Locate to get the exact / nearest date...
                    NULL
                END
                LOC.DATE = TEMP.DATE.RECORD<FIELD.POS, PROPERTY.POS, DATE.POS>  ;* This is the date prior to the reversed date. Take that.
                IF LOC.DATE = '' THEN   ;* Incase of NULL, dont try to locate. It might go on a indefinite loop. Dont ever allow that!
                    EXIT.FLAG = 1       ;* Escape chute!!
                END
            END ELSE
                EXIT.FLAG = 1 ;* Normal exit. We have found the last authorized date
            END
        REPEAT

    END

RETURN
*** </region>
****************************
*-----------------------------------------------------------------------------
*** <region name= CreateReturnId>
CreateReturnId:
*** <desc>To create Return Id separated by space </desc>
    ID.TO.ADD = ARR.ID:AA.Framework.Sep:PROPERTY:AA.Framework.Sep:LOC.DATE
    BEGIN CASE
        CASE NOT(LOC.DATE)
        CASE RET.ID
            RET.ID = RET.ID:' ':ID.TO.ADD
        CASE 1
            RET.ID = ID.TO.ADD
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= AddSuffix>
AddSuffix:
*** <desc> </desc>
    IF NOT(INDEX(START.DATE,".",1)) THEN
        START.DATE = START.DATE:".999"
    END
        
    IF NOT(INDEX(END.DATE,".",1)) THEN
        END.DATE = END.DATE:".999"
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckError>
CheckError:
*** <desc>To check the error </desc>
    IF DATE.OPERAND EQ "EQ" THEN ;* If user requested for any specific date then retrieve the effective record for that date
        CMP.DATE = DATE.VALUE
        IF FIELD(DATE.VALUE, ' ', 2) THEN ;* DATE1 DATE2 and operand selected as EQ it's invalid selection
            ENQ.ERROR = "Multiple dates not allowed for this operand"
            EB.Reports.setEnqError(ENQ.ERROR)
        END
    END
    
    IF NOT(DATE.OPERAND MATCHES "EQ" OR DATE.OPERAND MATCHES "RG") THEN
        ENQ.ERROR = "Selection for S.EFFECTIVE.DATE is currently supported EQ and RG"
        EB.Reports.setEnqError(ENQ.ERROR)
    END
RETURN
*** </region>
END
