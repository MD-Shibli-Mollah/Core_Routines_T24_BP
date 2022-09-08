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

* Version 4 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-134</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.GET.LAST.MATCH
*
**********************************************************************
*
*
* This routine is designed to be called from the enquiry system
* via the CONVERSION field, and performs several functions dependant
* on the data passed in O.DATA (contents of FIELD field in enquiry record).
*
* The common variable O.DATA will contain various elements of data
* separated by ;'s, the first element delimited by ; will contain
* the function number to be performed.
*
*
* Function 0
* ----------
*
* Function to select all the ids from the specified file and
* store these in a common area, for later use.
* This should be used with the DISPLAY.BREAK field set to ONCE
* i.e processed at the begining once only.
*
* Input:
*      O.DATA      - Common variable (I_ENQUIRY.COMMON)
*                  Contents of field FIELD in the enquiry record
*                  should be in format:
*
*                  function;filename
*
*                  E.g 0;GROUP.DEBIT.INT
*                      This would select all the ids from the
*                      GROUP.DEBIT.INT file and store these
*                      in the common block.
*
*
* Function 1
* ----------
*
* Function to return the last id from a list of ids which match
* the first few characteres of an id passed in O.DATA (enquiry
* FIELD contents, common variable)
*
* Input:
*   O.DATA      - Common variable (I_ENQUIRY.COMMON)
*                 should contain, function;filename;firstpartid
*
*
* Output:
*   O.DATA      - Last id from the file which matched the first few
*                 characters passed.
*
* E.g:
* If the file F.GROUP.DEBIT.INT contains id's:
*     1GBP19920602
*     1GBP19920603
*     .
*     .
*     1GBP19920610
*     1JPY19920602
*     1USD19920602
*     .
*     .
*
* Then if O.DATA contained "F.GROUP.DEBIT.INT;1GBP", the routine
* would return 1GBP19920610 in argument O.DATA.
*
*
* Function 2
* ----------
*
* Similar to Function 1 above, except the match is dependant on
* the best fit (less than or equal to) compared to id passed.
*
* Input:
*
*   O.DATA            - function:filename;firstpartid;lastpartid
*                       This will normally be used to match ids
*                       which contain dates etc.
*
*
* E.g GROUP.DEBIT.INT contains ids,
*     1GBP19920602
*     1GBP19920701
*     .
*     .
* Then we may pass O.DATA as 2;F.GROUP.DEBIT.INT;1GBP;19920617
* The routine should then return id that is the last one which
* is less than or equal, i.e 1GBP19920602.
*
*
* Function 3
* ----------
*
* This will extract a substring of chars from the data passed in O.DATA.
*
*     O.DATA          - function;N;data
*                       where N can be of format "stchar,length" or just
*                       a number. E.g if O.DATA = 3;4;1GBP19920602,
*                       then the last 4 chars of the data would be
*                       extracted, i.e 0602 and returned.
*
*
*******************************************************************
*
* Modifications
* -------------
*
* 22/01/93 - GB9300142
*            Introduce new function 0 (described above) which
*            selects the file and stores the ids for later use.
*
* 04/02/05 - CI_10027052
*            Performance changes to remove the looping to all records.
*
* 06/12/06 - CI_10045948
*            Problem with MM.PM.LIQUIDITY.PERIOD.CSU enquiry.
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*******************************************************************
    $USING EB.Reports
    $USING EB.DataAccess
    $USING AC.ModelBank
*--- Main process.

    GOSUB INITIALISE
    BEGIN CASE
        CASE WHICH.FUNCTION = 0
            GOSUB SLCT.FILE       ;* Select all records from file
        CASE WHICH.FUNCTION = 1 OR WHICH.FUNCTION = 2
            GOSUB DO.GET.LAST.MATCH
        CASE WHICH.FUNCTION = 3
            GOSUB DO.EXTRACT.CHARS
        CASE 1
    END CASE
    RETURN

*----------
INITIALISE:
*----------

    tmp.O.DATA = EB.Reports.getOData()
    WHICH.FUNCTION = FIELD(tmp.O.DATA,";",1)          ;* Extract the function
    IF WHICH.FUNCTION GT 2 THEN
        RETURN
    END

    FNAME = FIELD(tmp.O.DATA,";",2)         ;* Extract filename part
    IF FNAME[1,2] = 'F.' THEN
        SEL.FILE = FNAME      ;* Filename to be select
    END ELSE
        SEL.FILE = "F.":FNAME
    END
    F.SEL.FILE = ""
    EB.DataAccess.Opf(SEL.FILE,F.SEL.FILE)

    FIRST.PART.ID = FIELD(tmp.O.DATA,";",3) ;* Extract first part of id
    FPID.LEN = LEN(FIRST.PART.ID)       ;* Num chars in firt part of id

    IF WHICH.FUNCTION = 2 THEN
        LAST.PART.ID = FIELD(tmp.O.DATA,";",4)        ;* Last part of id
        LPID.LEN = LEN(LAST.PART.ID)    ;* Length of last part of id
    END

    FN.FOUND = 1
    FILE.NAME.LIST = AC.ModelBank.getGlmFnameList()
    LOCATE SEL.FILE IN FILE.NAME.LIST<1> SETTING GLM.FNAME.POS ELSE
    FN.FOUND = 0
    END
    IF NOT(FN.FOUND) THEN     ;* Store the filename for future reference
        FILE.NAME.LIST<GLM.FNAME.POS> = SEL.FILE
        AC.ModelBank.setGlmFnameList(FILE.NAME.LIST)
        DO.SELECT = 1         ;* Set flag to do selection on file
    END ELSE
        DO.SELECT = 0         ;* Filename already selected and stored...no
    END

    RETURN

*----------
SLCT.FILE:
*----------

    IF DO.SELECT THEN         ;* Select records from file
        EB.DataAccess.CacheRead(SEL.FILE,'SSelectARs',ID.LIST,ER)
        GLM.ID.LISTS = AC.ModelBank.getGlmIdList()
        GLM.ID.LISTS<GLM.FNAME.POS> = LOWER(ID.LIST)
        AC.ModelBank.setGlmIdList(GLM.ID.LISTS)
    END
    RETURN

*-----------------
DO.GET.LAST.MATCH:
*-----------------

    FID.FIND = 0
*
    LIST.OF.IDS = ""          ;* Matching list.
    NUM.FIDS = 0    ;* Match list counter.
*
    IF DO.SELECT THEN
        EB.DataAccess.CacheRead(SEL.FILE,'SSelectARs',ID.LIST,ER)
        GLM.ID.LISTS = AC.ModelBank.getGlmIdList()
        GLM.ID.LISTS<GLM.FNAME.POS> = LOWER(ID.LIST)
        AC.ModelBank.setGlmIdList(GLM.ID.LISTS)
    END ELSE
        GLM.ID.LISTS = AC.ModelBank.getGlmIdList()
        ID.LIST = RAISE(GLM.ID.LISTS<GLM.FNAME.POS>)
    END
*
    EOF.LIST = 0    ;* End flag to stop scanning.
    FID.POS = 0     ;* Start position for scanning.
*
    START.ID = FIRST.PART.ID
    LOCATE START.ID IN ID.LIST BY 'AR' SETTING FID.POS ELSE
    NULL
    END
*--- Get the matched Ids.
    LOOP
        FID = ID.LIST<FID.POS>
    WHILE EOF.LIST = 0
        GOSUB BUILD.MATCH.LIST
    REPEAT

    EB.Reports.setOData(LIST.OF.IDS<NUM.FIDS>);* Return last id from list of matches
    RETURN
*
*----------------
BUILD.MATCH.LIST:
*----------------

    IF NOT(FID) THEN
        EOF.LIST = 1          ;* All Ids scanned.
    END
    IF FID[1,FPID.LEN] = FIRST.PART.ID THEN       ;* First part of id matches
        FID.FIND = 1
        IF (WHICH.FUNCTION = 2) THEN
            IF (FID[LPID.LEN] GT LAST.PART.ID) THEN
                EOF.LIST = 1
                RETURN
            END
        END
        NUM.FIDS += 1   ;  LIST.OF.IDS<NUM.FIDS> = FID
    END ELSE
        IF FID.FIND THEN
            EOF.LIST = 1
        END
    END
    FID.POS +=1     ;* Increment the start position.
*
    RETURN

*----------------
DO.EXTRACT.CHARS:
*----------------

    tmp.O.DATA = EB.Reports.getOData()
    WHICH.CHARS = FIELD(tmp.O.DATA,";",2)   ;* Start and end pos of chars
    CHAR.DATA = FIELD(tmp.O.DATA,";",3)     ;* Extract the data portion
*
    IF INDEX(WHICH.CHARS,",",1) THEN    ;* Start end length specified
        ST.CHAR = FIELD(WHICH.CHARS,",",1)        ;* Start pos in data
        NUM.CHARS = FIELD(WHICH.CHARS,",",2)      ;* Number of chars to extract
        EB.Reports.setOData(CHAR.DATA[ST.CHAR,NUM.CHARS])
    END ELSE        ;* Assume extract last n chars
        IF NUM(WHICH.CHARS) AND (WHICH.CHARS NE "") THEN
            EB.Reports.setOData(CHAR.DATA[WHICH.CHARS]);* Extract chars from end of data
        END
    END
    RETURN
*
    END
