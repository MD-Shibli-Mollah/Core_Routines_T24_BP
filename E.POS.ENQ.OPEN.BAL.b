* @ValidationCode : MjoxMTUwMDg4MTEwOkNwMTI1MjoxNTQzODM0NDg0OTQyOnJhdmluYXNoOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTEuMjAxODEwMjItMTQwNjo4OTo2Nw==
* @ValidationInfo : Timestamp         : 03 Dec 2018 16:24:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ravinash
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 67/89 (75.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>471</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.ModelBank
	
SUBROUTINE E.POS.ENQ.OPEN.BAL
*
* 14/25/96 - GB9601487
*            Created
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.POS.MVMT.TODAY
*
* 26/01/98 - GB9800050
*            Read from the enquiry data file selected and not
*            POS.MVMT.TODAY
*
* 04/03/98 - GB9800195
*            Show OUR.REF as NO.ITEMS
*
* 29/05/08 - BG_100018472
*            Changes done to overwrite the number of records
*            selected by the enquiry POS.MVMT.TODAY as this
*            routine will filter out all the records raised as
*            yesterday.
*
* 26/04/2017 - Defect -2087298 / Task-2102791
*              While viewing the record from POS.MVMT.YESTERDAY
*              enquiry execution, system displays wrong results.
*
* 26/05/17 - Task - 2126523 /Enhancement - 2117822
*            AC product availability check has been done on the Company. If AC is not installed RETURN.
*
* 03/12/18 - Enhancement 2822523 / Task 2884607
*          - Incorporation of EB_ModelBank component.
*-----------------------------------------------------------------------------

    CALL Product.isInCompany("AC", AC.isInstalled) ;*Check for AC module in the company'

    IF NOT(AC.isInstalled) THEN
        ENQ.ERROR="EB-PRODUCT.NOT.INSTALLED":@FM:"AC"
        RETURN
    END


    MESSAGE = 'CALCULATING OPENING BALANCE'
    CALL DISPLAY.MESSAGE(MESSAGE,3)
*
    LOCATE "ONLINE.ONLY" IN ENQ.SELECTION<2,1> SETTING OL.POS THEN
        ONLINE.ONLY = ENQ.SELECTION<4,OL.POS>[1,1]
    END ELSE
        ONLINE.ONLY = ''
    END
*
    LOCATE "AMOUNT.RANGE" IN ENQ.SELECTION<2,1> SETTING AMT.POS THEN
        AMT.START = ENQ.SELECTION<4,AMT.POS>[' ',1,1]
        AMT.END = ENQ.SELECTION<4,AMT.POS>[' ',2,1]
        IF AMT.END = '' THEN AMT.END = AMT.START
    END ELSE
        AMT.START = '' ; AMT.END = ''
    END

MAIN.PARA:
*=========
*
* Select file to be read
*
    KEY.LIST = ID:@FM:ENQ.KEYS
    NKEY = KEY.LIST ;* Build list of keys for enquiry
    NEW.KEYS = ''
    YPOS.OPEN.BAL = 0
*
* Read the correct record and store in R.RECORD
*
    LOOP
        REMOVE YKEY FROM NKEY SETTING YD
        AST.POS = INDEX(YKEY,'*',1)
        IF AST.POS THEN
            AST.POS += 1
            SEQ.NO = YKEY['*',2,1]
*           SEQ.NO += 0

            IF SEQ.NO = '' THEN
                SEQ.NO = '0'
            END
        END
*
    UNTIL YKEY = ""
*
        IF SEQ.NO = '0' OR AMT.START NE '' OR ONLINE.ONLY = 'Y' THEN
            GOSUB READ.FILE
            BEGIN CASE
                CASE SEQ.NO = '0'
                    YPOS.OPEN.BAL += R.RECORD<PSE.AMOUNT.FCY>
                CASE ONLINE.ONLY = 'Y' AND INDEX('BC', R.RECORD<PSE.SYSTEM.STATUS>, 1) > 0    ;* Ignore EOD stuff
                CASE AMT.START NE ''        ;* Check is amount is in range
                    IF ABS(R.RECORD<PSE.AMOUNT.FCY>) LT AMT.START OR ABS(R.RECORD<PSE.AMOUNT.FCY>) GT AMT.END THEN
                    END ELSE
                        IF NEW.KEYS THEN
                            NEW.KEYS := @FM:YKEY
                        END ELSE
                            NEW.KEYS = YKEY
                        END
                    END
                CASE 1
                    IF NEW.KEYS THEN
                        NEW.KEYS := @FM:YKEY
                    END ELSE
                        NEW.KEYS = YKEY
                    END
            END CASE
        END ELSE
            IF NEW.KEYS THEN
                NEW.KEYS := @FM:YKEY
            END ELSE
                NEW.KEYS = YKEY
            END
        END
*
    REPEAT
    O.DATA = YPOS.OPEN.BAL
*
    IF NEW.KEYS<1> THEN
        YKEY = NEW.KEYS<1>
        GOSUB READ.FILE
    END ELSE
        R.RECORD = ''
        R.RECORD<PSE.OUR.REFERENCE> = 'NO.ITEMS'
    END
    OFS$ENQ.KEYS = DCOUNT(NEW.KEYS,@FM)
    ID = NEW.KEYS<1>
    DEL NEW.KEYS<1>
    ENQ.KEYS = NEW.KEYS

*
* Now clear out the message
*
    MESSAGE = ' '
    CALL DISPLAY.MESSAGE(MESSAGE, '3')
*
RETURN
*
READ.FILE:
*=========
*

    READ R.RECORD FROM F.DATA.FILE, YKEY ELSE NULL
    IF R.RECORD<PSE.CURRENCY> MATCHES "":@VM:LCCY THEN
        R.RECORD<PSE.AMOUNT.FCY> = R.RECORD<PSE.AMOUNT.LCY> ;* makes calculation easier
    END
RETURN
*
END
