* @ValidationCode : MjoxNjUwNTE3NDAyOkNwMTI1MjoxNTU4MTkxNjkzMTMzOnB1bml0aGt1bWFyOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDQuMjAxOTA0MTAtMDIzOTo0Mjo0MA==
* @ValidationInfo : Timestamp         : 18 May 2019 20:31:33
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : punithkumar
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 40/42 (95.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190410-0239
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG23(TAG,INSTRUCTION.CODE,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-29</Rating>
***********************************************************************************************
*
*
* Inward
*  Tag           -  The swift tag 23(Instruction code)
*
* Outward
*  OFS.DATA      - The corresponding application field in OFS format
************************************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 24/07/02 - EN_10000786
*            New Program
*
* 08/11/02 - BG_100002640
*            Use Quote function while storing the tag data as such in R.OFS.DATA
*
* 06/05/04 - EN_10002261
*            SWIFT related changes for bulk credit/debit processing
*
* 21/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
* 14/05/2019 - Defect 3107676 / Task 3128103
*              When an inward MT103 is processed, changes done so as to map tag 23 to FT record.
*
************************************************************************************
*
    $USING EB.SystemTables
    $USING SF.Foundation
*
* This is a repetitive tag. Hence the incoming ofs data will be
* separated by VMs

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE

    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E
    BEGIN CASE

        CASE TAG = '23E' OR TAG = '23'      ;* EN_10002261 - S/E

            NO.CRLF = DCOUNT(INSTRUCTION.CODE,@VM)
            FOR NO.VM = 1 TO NO.CRLF
                INSTRUCT.DATA = INSTRUCTION.CODE<1,NO.VM>
                INSTRUCT.DATA = QUOTE(INSTRUCT.DATA)  ;* BG_100002640 - s/e

                IF NO.VM = NO.CRLF THEN
                    COMMA.SEP = ''          ;* BG_100013037 - S
                END ELSE
                    COMMA.SEP = ','
                END     ;* BG_100013037 - E
                OFS.DATA :=FIELD.NAME:':':NO.VM:'=':INSTRUCT.DATA:COMMA.SEP
            NEXT NO.VM
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"':CHARX(251):INSTRUCTION.CODE     ;* EN_10002261 - S/E
                        
*For MT103 Tag 23, map BK.OPERATION.CODE field with values such as CRED/CRTS/SPAY/SPRI/SSTD
        CASE TAG = '23B'
            OFS.DATA := FIELD.NAME.23B:'=':QUOTE(INSTRUCTION.CODE)
            DE.I.FIELD.DATA = '"':FIELD.NAME.23B:'"':CHARX(251):INSTRUCTION.CODE
            
        CASE 1
            TAG.ERR = 'FIELD NOT MAPPED FOR TAG -':TAG

    END CASE
*
RETURN
*
************************************************************************************
INITIALISE:
************************************************************************************
*
    ER = ''
    END.POS = ''
    EB.SystemTables.setEtext('')
    CRLF = CHARX(013):CHARX(010)
    OFS.DATA = ''
    LEN.CRLF = LEN(CRLF)
    TAG.ERR = ''
*
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            FIELD.NAME = 'IN.INSTR.CODE'
			FIELD.NAME.23B = 'BK.OPERATION.CODE:1:1'
*
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*
    END CASE
*
RETURN
*
END
*
