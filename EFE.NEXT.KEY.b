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
* <Rating>79</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OP.ModelBank
    SUBROUTINE EFE.NEXT.KEY(NEXT.KEY,RAW.DATA,EXTRA)
*-------------------------------------------------------------------------
*
* A routine designed to be called by EB.FORMAT.ENTRY which will return the next
* key number to use for the base key.
*
* NEXT.KEY is the value returned and in the whole key e.g. 100103.100800.xx
* RAW.DATA we assume has the base key in it  (e.g. 100103.100800.) from the EB.FORMAT record
* EXTRA has the file name plus the format delimited by "-"
*
* NOT TO BE USED IN LIVE ENVIRONMENT AS IT IS SUCH A HACK
*
*-------------------------------------------------------------------------

    $USING EB.DataAccess
*
    EQUATE MAX.KEY.SUFFIX TO 99
*
 
    GOSUB INITIALISE
    GOSUB FIND.NEXT.KEY
*
    RETURN
*
**************************************************************************
INITIALISE:
**************************************************************************
*
    FILE.NAME = FIELD(EXTRA,"-",1)
    FORMATTING = FIELD(EXTRA,"-",2)
    FN.FILE = "F.":FILE.NAME
    F.FILE = ""
    EB.DataAccess.Opf(FN.FILE,F.FILE)
    KEY.STEM = RAW.DATA<1>    ;*** just in case
    NEXT.KEY = ""
*
    RETURN
*
**************************************************************************
FIND.NEXT.KEY:
**************************************************************************
*
    KEY.SUFFIX = 1
    USE.THIS.ONE = @FALSE
    LOOP
        IF FORMATTING THEN KEY.SUFFIX = FMT(KEY.SUFFIX,FORMATTING)
        DUMMYKEY = KEY.STEM:KEY.SUFFIX
*
        READ DUMMYREC FROM F.FILE, DUMMYKEY ELSE
            USE.THIS.ONE = @TRUE
        END
    UNTIL USE.THIS.ONE OR KEY.SUFFIX > MAX.KEY.SUFFIX DO
        KEY.SUFFIX += 1
    REPEAT
*
    IF KEY.SUFFIX LE MAX.KEY.SUFFIX THEN
        NEXT.KEY = DUMMYKEY
    END
*
    RETURN
*
END
