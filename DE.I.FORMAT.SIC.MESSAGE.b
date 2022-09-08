* @ValidationCode : Mjo1OTEzNjU3MDM6Q3AxMjUyOjE1ODIwMzQwMzM1Mzg6c3RhbnVzaHJlZToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAzLjIwMjAwMjEyLTA2NDY6MTY0OjQ3
* @ValidationInfo : Timestamp         : 18 Feb 2020 19:23:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 47/164 (28.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.20200212-0646
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* Version 7 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-154</Rating>
$PACKAGE DE.Clearing
SUBROUTINE DE.I.FORMAT.SIC.MESSAGE
*
* This routine will extract the field tags from the received SIC message
* and build from each a flat message in the layout defined by the message
* table. This will then be picked up by FT.IN.PROCESSING or equivalent
* The field locations and tag names are held in common ISIC$MESSAGE.MAP
*         1. SIC field number
*         2. Position in DE.O.MSG for extraction
*         3. Mandatory field Y/N
*         4. Conversion type for data eg date, amount
* The received SIC message type is contained in the first line of the raww
* SIC message following the # character.
*
*------------------------------------------------------------------------
*                    M O D I F I C A T I O N S
*
* 21/04/92 - GB9200262
*            merge Hypo pif HY9200307. Format PTT C10 and C11 messages
*            correctly.
*
* 22/07/97 - GB9700841
*            Date change to ensure century compliance
*
* 16/07/03 - CI_10010874
*            The dimension array R.MESSAGE was increased to
*            last field in the record, namely AUDIT.DATE.TIME
*            to aviod the system being fatalling out with
*            "Array subscript out of range" message.
*
* 08/03/07 - BG_100013209
*            CODE.REVIEW changes.
*
* 20/03/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE and generating .component
*
* 20/08/15 - Enhancement 1265068/ Task 1464647
*          - Routine incorporated
*
* 19/04/18 - Defect 2555587/ Task 2557255
*          - As ISIC$MESSAGE.MAP introduced as common variable, componentisation done on use of ISIC$MESSAGE.MAP varible
*
* 17/09/19 - Enhancement 3357571 / Task 3357573
*            Changes done for Movement of contact preferences to a separate Master Data Module from Delivery
*
*------------------------------------------------------------------------
    $USING EB.Utility
    $USING DE.Config
    $USING DE.Clearing
    $USING DE.Inward
    $USING DE.Outward
    $USING DE.ModelBank
    $USING PY.Config

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)

    IF DE.Inward.getVDebug() THEN
        PRINT "DE.I.FORMAT.SIC.MESSAGE IS RUNNING"          ;* BG_100013209 - S
    END   ;* BG_100013209 - E

*
* Initialise
*
    DIM R.DETAIL(50)
    DIM R.MESSAGE(DE.Config.Message.MsgAuditDateTime)         ;*      CI_10010874 -  S/E
    MAT R.MESSAGE = ""
    MAT R.DETAIL = ""         ;* Holds the DE.O.MSG record
    SIC.MESSAGE = ""          ;* The message to be built
    DE.Inward.setOutput("")
    NL = CHARX(010) ;* Line feed character
    I.WAY = "#"     ;* Message direction = out
    O.WAY = ">"     ;* Direction = in
*
* Read the raw SIC message
*
    REC.ID = DE.Inward.getRKey()
    ER = ''
    SIC.MESSAGE = DE.ModelBank.IMsg.Read(REC.ID, ER)
    IF ER THEN
        SIC.MESSAGE = ""
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, "Error - Message record does not exist")
        GOSUB WRITE.REPAIR
    END
*
* Decide on the SIC Message type
*
    SIC.MESSAGE.TYPE = SIC.MESSAGE<1>[2,3]
    DEL SIC.MESSAGE<1>
***!      IF SIC.MESSAGE<1>[1,4] = "<02>" THEN DEL SIC.MESSAGE<1>
*
* Now begin to build up the message
* First we must get the mapping rules from common
*
    LOCATE SIC.MESSAGE.TYPE IN DE.Clearing.getIsicMessageType()<1> SETTING SIC.MESS.POS ELSE
*
* The message details are not stored yet so we must add them
*
        ER = ''
        R.DE.FORMAT.SIC = DE.Clearing.FormatSic.Read(SIC.MESSAGE.TYPE, ER)
        tmp=DE.Clearing.getIsicMessageType(); tmp<SIC.MESS.POS>=SIC.MESSAGE.TYPE; DE.Clearing.setIsicMessageType(tmp)
        DE.Clearing.setIsicMessageMap(SIC.MESS.POS, 1, R.DE.FORMAT.SIC<DE.Clearing.FormatSic.SicfSicField>)
        DE.Clearing.setIsicMessageMap(SIC.MESS.POS, 2, R.DE.FORMAT.SIC<DE.Clearing.FormatSic.SicfFieldLoc>)
        DE.Clearing.setIsicMessageMap(SIC.MESS.POS, 3, R.DE.FORMAT.SIC<DE.Clearing.FormatSic.SicfMandatory>)
        DE.Clearing.setIsicMessageMap(SIC.MESS.POS, 4, R.DE.FORMAT.SIC<DE.Clearing.FormatSic.SicfConversion>)
*
    END
*
    FIELD.LIST = DE.Clearing.getIsicMessageMap(SIC.MESS.POS,1)
    FLD.CT = COUNT(FIELD.LIST,@VM)+(FIELD.LIST NE "")
    MAP.LOC = DE.Clearing.getIsicMessageMap(SIC.MESS.POS,2)
    MANDATORY = DE.Clearing.getIsicMessageMap(SIC.MESS.POS,3)
    CONVERSION = DE.Clearing.getIsicMessageMap(SIC.MESS.POS,4)
*
*
* We may need to extract value and sub values from YLOC
*
    LOOP
        MSG.FLD = SIC.MESSAGE<1>
        DEL SIC.MESSAGE<1>
    WHILE MSG.FLD DO
        FLD.TAG = FIELD(MSG.FLD[2,LEN(MSG.FLD)],">",1)

        GOSUB EXTRACT.VALUES  ;* BG_100013209 - S / E

        IF NOT(POS) THEN
            DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, "Error - unrecognised field in message ":FLD.TAG)
            GOSUB WRITE.REPAIR
        END
        YLOC = MAP.LOC<1,POS>
        YMAN = MANDATORY<1,POS>
        YCON = CONVERSION<1,POS>
        YF = FIELD(YLOC,".",1) ; YV = FIELD(YLOC,".",2) ; YS = FIELD(YLOC,".",3)
        IF NOT(YV) THEN
            YV = 1  ;* BG_100013209 - S
        END         ;* BG_100013209 - E

        IF NOT(YS) THEN
            YS = 1  ;* BG_100013209 - S
        END         ;* BG_100013209 - E
        FLD.DET = FIELD(MSG.FLD,">",2)
*
* If there is any conversion necessary it must be done here
*

        GOSUB CONVERSION.PROCESS        ;* BG_100013209 - S / E
        tmp=DE.Inward.getOutput(); tmp<YF,YV,YS>=FLD.DET; DE.Inward.setOutput(tmp)
*
*
    REPEAT
*
* Write to the priority queue and change the message type to SIC
*
    DE.MSG.TYPE = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    ER = ''
    REC.ID = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)
    R.MSG.REC = ''
    R.MSG.REC = DE.Config.Message.Read(REC.ID, ER)
    MATPARSE R.MESSAGE FROM R.MSG.REC
    IF ER THEN
        MAT R.MESSAGE = ""
        DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, "Error - Missing DE.MESSAGE record ":DE.MSG.TYPE)
        GOSUB WRITE.REPAIR
    END

    PRI.QUEUE = R.MESSAGE(DE.Config.Message.MsgApplicationQueue)
    DE.Inward.setRHead(DE.Config.IHeader.HdrAppQueue, PRI.QUEUE)
    DE.Inward.IEstablishRouting()
*
END.PGM:
RETURN
*
*-----------------------------------------------------------------------
WRITE.REPAIR:
*===========
* Add key to repair file
*
    DE.Inward.setRHead(DE.Config.IHeader.HdrDisposition, 'REPAIR')
    R.REPAIR = DE.Inward.getRKey()
    DE.Outward.UpdateIRepair(R.REPAIR,'')
RETURN TO END.PGM
RETURN
*
* Error has occurred.  Return to calling program
*
*
*************************************************************************************************************
*
*BG _100013209 - S
*==================
CONVERSION.PROCESS:
*==================


    BEGIN CASE
        CASE YCON = ""  ;* No conversion
        CASE YCON = "DATE"        ;* Drop the leading 19
            IF FLD.DET MATCHES "6N":@VM:"8N" THEN
* GB9700841
                EB.Utility.CheckDate(FLD.DET)
            END ELSE
                DE.Inward.setRHead(DE.Config.IHeader.HdrErrorCode, "ERROR - invalid DATE ":FLD.TAG)
                GOSUB WRITE.REPAIR
            END
        CASE YCON = "AMOUNT"      ;* A "." becomes a ","
            CONVERT ',' TO '.' IN FLD.DET
            IF FLD.DET[1] = "." THEN
                CONVERT "." TO '' IN FLD.DET          ;* BG_100013209 - S
            END         ;* BG_100013209 - E

        CASE YCON MATCHES "MULTI":@VM:"ADDRESS":@VM:"PTT"         ;* Convert values into NL

            GOSUB CONVERT.VALUES.TO.NULL    ;* BG_1000013209 - S / E

***!               CONVERT NL TO VM IN FLD.DET
        CASE YCON = "SWIFT"

            GOSUB CONVERT.NULL.TO.VALUES    ;* BG_1000013209 - S / E

        CASE 1
    END CASE
RETURN
*
*************************************************************************************************************
*
*=================
EXTRACT.VALUES:
*=================
    LOCATE FLD.TAG IN FIELD.LIST<1,1> SETTING POS ELSE
        POS = 0
        FOR V$NUM = 1 TO FLD.CT
            IF FIELD.LIST<1,V$NUM>[1,2] = FLD.TAG[1,2] THEN
                POS = V$NUM
                V$NUM = FLD.CT
            END
        NEXT V$NUM
    END

RETURN
*
*************************************************************************************************************
*
*=======================
CONVERT.VALUES.TO.NULL:
*=======================

    LOOP
    WHILE SIC.MESSAGE<1>[1,1] NE "<"
        IF SIC.MESSAGE<1> NE "" THEN    ;* Ignore null lines
            IF FLD.DET THEN   ;* The first line may be null
                FLD.DET := @VM:SIC.MESSAGE<1>
            END ELSE
                FLD.DET = SIC.MESSAGE<1>
            END
        END
        DEL SIC.MESSAGE<1>
    REPEAT
RETURN
*
*************************************************************************************************************
*

*-==========================
CONVERT.NULL.TO.VALUES:
*===========================

    IF SIC.MESSAGE<1>[1,1] NE "<" THEN
        GOSUB SET.FLD.DET
    END ELSE
*
** Try to obtain the customer number for the SWIFT address
*
        IF FLD.TAG[1] = "S" THEN
            BEGIN CASE
                CASE LEN(FLD.DET) = 12      ;* Omit the 9th char
                    YADDRESS.KEY = FLD.DET[1,8]:FLD.DET[10,3]
                CASE LEN(FLD.DET) = 11 OR LEN(FLD.DET) = 8
                    YADDRESS.KEY = FLD.DET
                CASE LEN(FLD.DET) = 9
                    YADDRESS.KEY = FLD.DET[1,8]
                CASE 1
                    YADDRESS.KEY = FLD.DET
            END CASE

            GOSUB READ.SWIFT.ADDRESS

        END
*
    END
RETURN
*
*************************************************************************************************************
*
*===========
SET.FLD.DET:
*==========
    LOOP
    WHILE SIC.MESSAGE<1>[1,1] NE "<"
        IF SIC.MESSAGE<1> NE "" THEN
            IF FLD.DET THEN
                FLD.DET := @VM:SIC.MESSAGE<1>
            END ELSE
                FLD.DET = SIC.MESSAGE<1>
            END
        END
        DEL SIC.MESSAGE<1>
    REPEAT
RETURN
*
*************************************************************************************************************
*
*===================
READ.SWIFT.ADDRESS:
*===================
    DE.ADDRESS.KEYS = PY.Config.SwiftAddress.Read(YADDRESS.KEY, ER)
    IF YADDRESS.KEY THEN
        IF FIELD(DE.ADDRESS.KEYS<1>,".",2)[1,2] = "C-" THEN
            FLD.DET = FIELD(DE.ADDRESS.KEYS<1>,".",2)[3,99]
        END
    END ELSE
        NULL        ;* Otherwise leave FLD.DET the same
    END

RETURN          ;* BG_100013209 - E
*
*************************************************************************************************************
END
