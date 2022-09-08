* @ValidationCode : MjoxODQ0NjY2NzM0OmNwMTI1MjoxNTg1MDM2NDMzMDE2OmluZGh1bWF0aGlzOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDMuMDo5Nzo4OQ==
* @ValidationInfo : Timestamp         : 24 Mar 2020 13:23:53
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : indhumathis
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 89/97 (91.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 5 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-37</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DE.Reports
SUBROUTINE E.DISP.DE.I.MSG
*
*
* 21/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 02/07/12 - Enhancement - 326577 / Task 381154
*            To display the Tag Description in Inward Message coding is added.
*
* 30/07/14 - Defecy 995764/ Task 1043463
*			 Included logic to handle Swift Messages [For example MT564]with : as part of tag value.
*
**07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
* 04/11/15 - Defect 1519653 / Task 1522501
*            While running the enquiry INCOMING.MSG.DETS, system not displaying the values in line by line
*            instead displaying the whole message in a single line. This happens in Oracle database.
*            Code changes done as below:
*            Conversion of <cr> and <lf> done together in single line inorder to be compatible in Oracle database.
*
* 14/03/19 - Defect 3032636:/task 3036150: Incorrect TAG expansion in Inward Enquiry
*             INC.MSG.DETS
*
* 24/03/20 - Defect 3646742 / Task 3655416
*            Code changes done to display the full tag value for the tags which are separated by ":".
*******************************************************************************
    $USING DE.Config
    $USING DE.Reports
    $USING EB.Reports

*
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    YKEY = EB.Reports.getOData()
*
    YREC = DE.Config.IHistory.Read(YKEY, ER)
    IF YREC THEN
* Message will begin with {1:F01SWHQBEBBAXXX0013009909}{2:I103SWHQBEBBXXXXN}
* Where block 2 contains the message type, extract the message type from there
        MSG.TYPE = ""
        IF YREC[1,4] = '{1:F' THEN
            MSG.TYPE.POS = INDEX(YREC,'{2:',1)
            IF YREC[MSG.TYPE.POS+3, 1] = 'I'  OR YREC[MSG.TYPE.POS+3, 1] = 'O' THEN
                MSG.TYPE  = YREC[MSG.TYPE.POS+4,3]
            END
        END
        CONVERT @SM TO "" IN YREC
        CONVERT @VM TO @FM IN YREC        ;* If SWIFT
        YREC = LOWER(YREC)    ;* YREC variable contains Inward String
        CONVERT CHARX(010):CHARX(013) TO @VM IN YREC ;* Converting <cr> and <lf> together to VM.
        NO.OF.TAGS = DCOUNT(YREC,@VM)
        FULL.TAG.LEN = ''
        FORM.TAG = ''
        LEN.VAL = ''
        FOR I = 2 TO NO.OF.TAGS
            GOSUB GET.TAG.VALUES
        NEXT I
        Y.HEADER = FIELD(YREC,@VM,1)
        YREC = Y.HEADER : @VM : Y1.REC
        EB.Reports.setRRecord(YREC<1>)
        tmp.R.RECORD = EB.Reports.getRRecord()
        EB.Reports.setVmCount(COUNT(tmp.R.RECORD,@VM)+(EB.Reports.getRRecord() NE ""))
    END ELSE
        EB.Reports.setRRecord("");* BG_100013037 - S
    END   ;* BG_100013037 - E
    YREC = DE.Config.IHeaderArch.Read(YKEY, ER)
    IF YREC THEN
        R.REC.TEMP = EB.Reports.getRRecord()
        R.REC.TEMP := @FM:YREC
        EB.Reports.setRRecord(R.REC.TEMP)
    END
RETURN
*--------------
GET.TAG.VALUES:
*--------------
    GET.VALUES = FIELD(YREC,@VM,I)       ;* Tag separation
    GET.TAG = FIELD(GET.VALUES,':',2)   ;* Contains tag number
    GOSUB DETERMINE.TRANSLATION ; *
    Y.DESC = R.DE.TRANS<DE.Config.Translation.TraDescription,1,1>   ;* Getting description from translation of the particular tag
    TAG.DESC = Y.DESC
    FIRST.TAG.VALUE = FIELD(GET.VALUES,':',1)
    SECOND.TAG.VALUE = FIRST.TAG.VALUE :":" : GET.TAG       ;* Concatenating with tag number separated by ":"
    THIRD.TAG.VALUE = SECOND.TAG.VALUE : ":" : TAG.DESC     ;* Concatenating tag number and tag description
    TAG.LEN = LEN(THIRD.TAG.VALUE)
    LEN.VAL<1,-1> = TAG.LEN
    GET.LEN = FIELD(LEN.VAL,@VM,1)
    IF TAG.LEN LT GET.LEN THEN
        CURR.LEN = GET.LEN - TAG.LEN    ;* Calculating length of tag and space is given accordingly for proper alignment
        FULL.TAG.LEN = CURR.LEN + 4
    END ELSE
        IF TAG.LEN GT GET.LEN THEN
            FULL.TAG.LEN = TAG.LEN - GET.LEN
        END
    END
    IF NOT(FULL.TAG.LEN) THEN
        FULL.TAG.LEN = 4
    END
    Y.MULTI.COLON.TAG = ''
    Y.MULTI.COLON.TAG =  INDEX(GET.VALUES,"::",1)
    TAG.VALUE.POS = LEN(SECOND.TAG.VALUE) + 2
    TAG.VALUES = GET.VALUES[TAG.VALUE.POS,99] ;* Contains the entire tag value
    IF Y.MULTI.COLON.TAG THEN ;* Parse the values of the Swift Tags with : in data Part[for Example MT564]
        FOURTH.TAG.VALUE = THIRD.TAG.VALUE : SPACE(FULL.TAG.LEN) : "::" :FIELD(GET.VALUES,'::',2)   ;* Concatenating tag no,tag
    END ELSE
        FOURTH.TAG.VALUE = THIRD.TAG.VALUE : SPACE(FULL.TAG.LEN) : ":" :TAG.VALUES    ;* Concatenating tag no,tag desc and tag values

    END
    IF GET.TAG NE '' THEN
        FORM.TAG<1,-1> = FOURTH.TAG.VALUE
    END ELSE
        FORM.TAG<1,-1> = GET.VALUES
    END
    Y1.REC = FORM.TAG
RETURN

*-----------------------------------------------------------------------------

*** <region name= DETERMINE.TRANSLATION>
DETERMINE.TRANSLATION:
*** <desc> </desc>
* Get the message specific translation, if not availabe then go for tag specific
    IF MSG.TYPE THEN
        DE.TRANS.ID = "SW" : GET.TAG :"-":MSG.TYPE
        GOSUB READ.TRANSLATION ; *
    END

    IF R.DE.TRANS EQ "" THEN
        DE.TRANS.ID = "SW" : GET.TAG
        GOSUB READ.TRANSLATION ; *
    END

    IF R.DE.TRANS EQ "" AND MSG.TYPE THEN
        DE.TRANS.ID = "SW" : GET.TAG[1,2] :"X-":MSG.TYPE
        GOSUB READ.TRANSLATION ; *
    END
    IF R.DE.TRANS EQ "" THEN
        DE.TRANS.ID = "SW" : GET.TAG[1,2] :"X"
        GOSUB READ.TRANSLATION ; *
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= READ.TRANSLATION>
READ.TRANSLATION:
*** <desc> </desc>
    R.DE.TRANS = ""
    REC.ERR = ""
    R.DE.TRANS = DE.Config.Translation.CacheRead(DE.TRANS.ID, REC.ERR)
RETURN
*** </region>

END


