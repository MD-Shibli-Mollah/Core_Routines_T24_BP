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

* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-114</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE CONV.REPORT.CONTROL.G15.0

* The REPORT.CONTROL records have corrupted ever since the introduction
* of conversion details CONV.REPORT.CONTROL.G12.0.1 and CONV.REPORT.CONTROL.G12.1.0
* This routine/conversion has been introduced to resolve this.
*
* Modifications:
* -------------
*
* 04/11/04 - CI_10024481
*            Creation
*
* 17/01/07 - CI_10046722
*            System throws error message
*            on authorising the REPORT.CONTROL data records
*            Ref:TTS0705398
*------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB INITIALISE          ;* Open up required files and set variables
    GOSUB CONV.HISTORY        ;* convert records in $HIS file
    GOSUB CONV.NAU  ;* convert records in $NAU file
    GOSUB CONV.LIVE ;* convert records in LIVE file

    RETURN

*--------------------------------------------------------------------------
INITIALISE:
*---------

    FN.REPORT.CONTROL = 'F.REPORT.CONTROL'
    F.REPORT.CONTROL = ''
    CALL OPF(FN.REPORT.CONTROL,F.REPORT.CONTROL)

    FN.REPORT.CONTROL$HIS ='F.REPORT.CONTROL$HIS'
    F.REPORT.CONTROL$HIS = ''
    CALL OPF(FN.REPORT.CONTROL$HIS,F.REPORT.CONTROL$HIS)


    FN.REPORT.CONTROL$NAU = 'F.REPORT.CONTROL$NAU'
    F.REPORT.CONTROL$NAU = ''
    CALL OPF(FN.REPORT.CONTROL$NAU,F.REPORT.CONTROL$NAU)

    ID.AND.CURR.NO = ''
    CONV.NAME = 'CONV.REPORT.CONTROL.G15.0'

* Fill up the audit details and populate afresh

    INPUTTER = TNO:'_':CONV.NAME
    AUTHORISER = INPUTTER
    TIME.STAMP = TIMEDATE()
    X = OCONV(DATE(),"D-")
    X = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
    DEPT.CODE = R.USER<6>     ;* Get it from the USER who is running this conversion

    RETURN
*--------------------------------------------------------------------------
CONV.HISTORY:
*----------

* Converting the records in the $HIS file
*

    AUTHORISER = INPUTTER
    FROM.NAU = @FALSE         ;* This is not $NAU file

    SELECT.STMT = 'SSELECT ':FN.REPORT.CONTROL$HIS:' BY-DSND @ID'     ;* sort select by desending

    GOSUB SELECT.RECORDS      ;* go and select records from $HIS file

    LATEST.ID = '' ; K.REPORT = ''
    LOOP REMOVE K.REPORT FROM REPORT.CONTROL.IDS SETTING POS
    WHILE K.REPORT:POS
        READ R.REPORT.CONTROL FROM F.REPORT.CONTROL$HIS,K.REPORT THEN
            EXACT.ID = FIELD(K.REPORT,';',1)      ;* get the ID part
            CURR.NO = FIELD(K.REPORT,';',2)       ;* get the CURR.NO part

            IF LATEST.ID NE EXACT.ID THEN         ;* If a New Id
                ID.AND.CURR.NO<1,-1> = EXACT.ID   ;* Id part
                ID.AND.CURR.NO<2,-1> = CURR.NO    ;* The CURR.NO of the most recently modified
                LATEST.ID = EXACT.ID    ;* so that we enter the if only for the next id
            END

            GOSUB CONVERT.RECORD        ;* go and convert

            WRITE R.REPORT.CONTROL TO F.REPORT.CONTROL$HIS,K.REPORT

        END
    REPEAT

    RETURN
*--------------------------------------------------------------------------
CONV.NAU:
*-------

* Converting the records in the $NAU file
*
    AUTHORISER = '' ;* do not fill in Authoriser details
    FROM.NAU = @TRUE

    SELECT.STMT = 'SELECT ':FN.REPORT.CONTROL$NAU
    GOSUB SELECT.RECORDS
    K.REPORT = ''
    LOOP REMOVE K.REPORT FROM REPORT.CONTROL.IDS SETTING POS
    WHILE K.REPORT:POS
        READ R.REPORT.CONTROL FROM F.REPORT.CONTROL$NAU,K.REPORT THEN
            LOCATE K.REPORT IN ID.AND.CURR.NO<1,1> SETTING POS THEN   ;* cheking whether this ID is present in the $HIS file
                CURR.NO = ID.AND.CURR.NO<2,POS>   ;* Yes, it is in $HIS file. Getting CURR.NO of the most recently one
                CURR.NO += 1  ;* So, I should be +1
            END ELSE
                CURR.NO = R.REPORT.CONTROL<44>
            END
            GOSUB CONVERT.RECORD        ;* go and conver
            WRITE R.REPORT.CONTROL TO F.REPORT.CONTROL$NAU,K.REPORT
        END
    REPEAT

    RETURN
*--------------------------------------------------------------------------
CONV.LIVE:
*--------

* Converting the records in the LIVE file
*
    AUTHORISER = INPUTTER
    FROM.NAU = @FALSE

    SELECT.STMT = 'SELECT ':FN.REPORT.CONTROL
    GOSUB SELECT.RECORDS
    K.REPORT = '' ; R.REPORT.CONTROL = ''
    LOOP REMOVE K.REPORT FROM REPORT.CONTROL.IDS SETTING POS
    WHILE K.REPORT:POS

        READ R.REPORT.CONTROL FROM F.REPORT.CONTROL,K.REPORT THEN
            LOCATE K.REPORT IN ID.AND.CURR.NO<1,1> SETTING POS THEN   ;* Check whether Id is found in history file
                CURR.NO = ID.AND.CURR.NO<2,POS>   ;* yes found in history, get the CURR.NO
                CURR.NO += 1  ;* I Should be +1 of the CURR.NO found in history
            END ELSE
                CURR.NO = 1   ;* No history records for this ID, so CURR.NO should be 1
            END
            GOSUB CONVERT.RECORD        ;* go and conver

            WRITE R.REPORT.CONTROL TO F.REPORT.CONTROL,K.REPORT
        END
    REPEAT

    RETURN


*--------------------------------------------------------------------------
SELECT.RECORDS:
*-------------

    NO.SEL = '' ; SEL.ERR = '' ; K.REPORT = "" ; REPORT.CONTROL.IDS = ''
    CALL EB.READLIST(SELECT.STMT,REPORT.CONTROL.IDS,'',NO.SEL,SEL.ERR)

    RETURN
*--------------------------------------------------------------------------
CONVERT.RECORD:
*--------------

    FIELD.23 = R.REPORT.CONTROL<23>     ;* CRYSTAL.REPORT
    FIELD.32 = R.REPORT.CONTROL<32>     ;* REPORT.TRANSFORM
    FIELD.33 = R.REPORT.CONTROL<33>     ;* XML.TRANS.CONTEXT

    IF FIELD.23 NE 'YES' THEN ;* the following fields can have data only if this field is "YES"
        R.REPORT.CONTROL<24> = ''       ;* We cannot have any values unless the field CRYSTAL.REPORT contains "YES"
        R.REPORT.CONTROL<25> = ''       ;*  ""                          ""                            ""
        R.REPORT.CONTROL<26> = ''       ;*  ""                          ""                            ""
        R.REPORT.CONTROL<27> =''        ;*  ""                          ""                            ""
        R.REPORT.CONTROL<28> = ''       ;*  ""                          ""                            ""
        R.REPORT.CONTROL<29> = ''       ;*  ""                          ""                            ""
        R.REPORT.CONTROL<30> = ''       ;*  ""                          ""                            ""
        R.REPORT.CONTROL<31> = ''       ;*  ""                          ""                            ""
    END

    IF FIELD.32 THEN          ;* Checking for any junk data in this field
        ER = '' ; R.REPORT.TRANSFORM = ''
        CALL CACHE.READ('F.REPORT.TRANSFORM',FIELD.32,R.REPORT.TRANSFORM,ER)    ;* If the data here is valid one
        IF ER THEN  ;* ID not found in REPORT.TRANSFORM
            IF FROM.NAU THEN  ;* if $NAU records then check in the REPORT.TRANSFORM$NAU
                ER = ''
                CALL CACHE.READ('F.REPORT.TRANSFORM$NAU',FIELD.32,R.REPORT.TRANSFORM,ER)
            END
        END
        IF ER THEN  ;* Yes, this data is Junk
            R.REPORT.CONTROL<32> = ''   ;* clear the junk value
        END
    END

    IF FIELD.33 THEN          ;* Checking for any junk data in this field
        ER = '' ; R.XML.TRANS.CONTEXT = ''
        CALL CACHE.READ('F.XML.TRANS.CONTEXT',FIELD.33,R.XML.TRANS.CONTEXT,ER)  ;* If the data here is valid one
        IF ER THEN  ;* Not found in  F.XML.TRANS.CONTEXT
            IF FROM.NAU THEN  ;* if $NAU records then check in the F.XML.TRANS.CONTEXT$NAU
                ER = ''
                CALL CACHE.READ('F.XML.TRANS.CONTEXT$NAU',FIELD.33,R.XML.TRANS.CONTEXT,ER)
            END
        END
        IF ER THEN  ;* Yes, this data is Junk
            R.REPORT.CONTROL<33> = ''   ;* clear the junk value
        END
    END

* Populating the audit fields
*
    R.REPORT.CONTROL<44> = CURR.NO
    R.REPORT.CONTROL<45> = INPUTTER
    R.REPORT.CONTROL<46> = X
    R.REPORT.CONTROL<47> = AUTHORISER

    R.REPORT.CONTROL<48> = ID.COMPANY
    R.REPORT.CONTROL<49> = DEPT.CODE

    RETURN
END
