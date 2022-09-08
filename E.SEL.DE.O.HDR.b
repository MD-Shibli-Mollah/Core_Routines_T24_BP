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

* Version 5 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-182</Rating>
    $PACKAGE DE.Reports
    SUBROUTINE E.SEL.DE.O.HDR(YID.LIST)
*
*
* 22/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 11/06/07 - CI_10049664
*            Form the correct id of the DE.O.HISTORY.QUEUE in the YVALUES variable
*            and populate the YID.LIST with the delivery id.
*
* 03/10/07 - CI_10051206
*            Enquiries OUTGOING.MSG is not working correctly.
*
* 15/04/10 - Task 33287
*            EB.READLIST has changed to DAS.
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
*************************************************************************************************************
    $USING DE.Reports
    $USING DE.Config
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.DataAccess

    $INSERT I_DAS.DE.O.HISTORY.QUEUE
*
    YF.DE.O.HISTORY.QUEUE = "F.DE.O.HISTORY.QUEUE"
*
    LOCATE "DELIVERY.DATE" IN EB.Reports.getDFields()<1> SETTING DATE.POS ELSE
    RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E
*
    YID.LIST = ""
    ID.FORMAT = ""
    YLIST.ID = "DEL.ENQ":EB.SystemTables.getTno()
    YSENT.FIXED = "SSELECT ":YF.DE.O.HISTORY.QUEUE
    YSENTENCE = "" ; YOPERAND = EB.Reports.getDLogicalOperands()<DATE.POS>
    YVALUES = EB.Reports.getDRangeAndValue()<DATE.POS>
*
    ON YOPERAND GOSUB EQUAL.TO,
    RANGE,
    LESS.THAN,
    GREATER.THAN,
    NOT.EQUAL,
    LK,
    UL,
    LESS.THAN.EQ,
    GREATER.THAN.EQ,
    NOT.RANGE
*
    IF YID.LIST THEN
        YSTORE.LIST = YID.LIST ; YID.LIST = ""
        LOOP
            REMOVE YY FROM YSTORE.LIST SETTING YDELIM
            GOSUB GET.YID.LIST
        WHILE YDELIM
        REPEAT
    END
*
    RETURN
*
*------------------------------------------------------------------------
*=========
EQUAL.TO:
*=========
*
    LOOP
        REMOVE YCONCAT.ID FROM YVALUES SETTING YD
        * To read records in old format
        YREC = DE.Config.OHistoryQueue.Read(YCONCAT.ID, ER)
        IF YREC THEN
            IF YID.LIST THEN
                YID.LIST := @FM:YREC
            END ELSE
                YID.LIST = YREC         ;*CI_10049664-E
            END
        END ELSE
            NULL    ;* BG_100013037 - S
        END         ;* BG_100013037 - E

        * To read records in new format
        THE.LIST = DAS.DE.O.HDR$BASED.ON.DATE
        THE.ARGS<1,1> = "EQ"
        THE.ARGS<2,1> = YCONCAT.ID
        ID.FORMAT = 'NEW'
        GOSUB PERFORM.SELECTION

    WHILE YD
    REPEAT
*
    RETURN
*
*------------------------------------------------------------------------
RANGE:
*====
*
    IF YVALUES<1,1,2> = "" THEN
        GOSUB EQUAL.TO
    END ELSE
        IF YVALUES<1,1,1> GT YVALUES<1,1,2> THEN
            YSEL1 = YVALUES<1,1,2> ; YSEL2 = YVALUES<1,1,1>
        END ELSE
            YSEL1 = YVALUES<1,1,1> ; YSEL2 = YVALUES<1,1,2>
        END

        THE.ARGS<1> = "GE":@VM:"LE"
        THE.ARGS<2> = YSEL1:@VM:YSEL2

        * To read records in old format
        THE.LIST = DAS.DE.O.HDR$BASED.ON.ID
        ID.FORMAT = 'OLD'
        GOSUB PERFORM.SELECTION

        * To read records in new format
        THE.LIST = DAS.DE.O.HDR$BASED.ON.DATE
        ID.FORMAT = 'NEW'
        GOSUB PERFORM.SELECTION
    END
*
    RETURN
*
*------------------------------------------------------------------------
*=========
LESS.THAN:
*=========
*
    YSEL1 = YVALUES<1,1,1>

    THE.ARGS<1> = "LT"
    THE.ARGS<2> = YSEL1

* To read records in old format
    THE.LIST = DAS.DE.O.HDR$BASED.ON.ID
    ID.FORMAT = 'OLD'
    GOSUB PERFORM.SELECTION

* To read records in new format
    THE.LIST = DAS.DE.O.HDR$BASED.ON.DATE
    ID.FORMAT = 'NEW'
    GOSUB PERFORM.SELECTION
*
    RETURN
*
*------------------------------------------------------------------------
*============
GREATER.THAN:
*============
*
    YSEL1 = YVALUES<1,1,1>
    THE.ARGS<1> = "GT"
    THE.ARGS<2> = YSEL1

* To read records in old format
    THE.LIST = DAS.DE.O.HDR$BASED.ON.ID
    ID.FORMAT = 'OLD'
    GOSUB PERFORM.SELECTION

* To read records in new format
    THE.LIST = DAS.DE.O.HDR$BASED.ON.DATE
    ID.FORMAT = 'NEW'
    GOSUB PERFORM.SELECTION
*
    RETURN
*
*------------------------------------------------------------------------
*=========
NOT.EQUAL:
*=========
*
* To read records in old format
    THE.LIST = DAS.DE.O.HDR$BASED.ON.ID
    ID.FORMAT = 'OLD'
    LOOP
        REMOVE YCONCAT.ID FROM YVALUES SETTING YD
        THE.ARGS<1,-1> = "NE"
        THE.ARGS<2,-1> = YCONCAT.ID
    WHILE YD
    REPEAT
    GOSUB PERFORM.SELECTION

* To read records in new format

    YVALUES.NEW = EB.Reports.getDRangeAndValue()<DATE.POS>
    THE.LIST = DAS.DE.O.HDR$BASED.ON.DATE
    ID.FORMAT = 'NEW'
    LOOP
        REMOVE YCONCAT.ID.NEW FROM YVALUES.NEW SETTING YD.NEW
        THE.ARGS<1,-1> = "NE"
        THE.ARGS<2,-1> = YCONCAT.ID.NEW
    WHILE YD.NEW
    REPEAT
    GOSUB PERFORM.SELECTION
*
    RETURN
*
*------------------------------------------------------------------------
*===
LK:
*===
*
    YSEL1 = YVALUES<1,1,1>

    THE.ARGS<1> = "LK"
    THE.ARGS<2> = YSEL1:"..."

* To read records in old format
    THE.LIST = DAS.DE.O.HDR$BASED.ON.ID
    ID.FORMAT = 'OLD'
    GOSUB PERFORM.SELECTION

* To read records in new format
    THE.LIST = DAS.DE.O.HDR$BASED.ON.DATE
    ID.FORMAT = 'NEW'
    GOSUB PERFORM.SELECTION
*
    RETURN
*
*------------------------------------------------------------------------
*===
UL:
*===
*
    YSEL1 = YVALUES<1,1,1>
    THE.ARGS<1> = "UL"
    THE.ARGS<2> = YSEL1:"..."
* To read records in old format
    THE.LIST = DAS.DE.O.HDR$BASED.ON.ID
    ID.FORMAT = 'OLD'
    GOSUB PERFORM.SELECTION

* To read records in new format
    THE.LIST = DAS.DE.O.HDR$BASED.ON.DATE
    ID.FORMAT = 'NEW'
    GOSUB PERFORM.SELECTION
*
    RETURN
*
*------------------------------------------------------------------------
*=============
LESS.THAN.EQ:
*=============
*
    YSEL1 = YVALUES<1,1,1>
    THE.ARGS<1> = "LE"
    THE.ARGS<2> = YSEL1
* To read records in old format
    THE.LIST = DAS.DE.O.HDR$BASED.ON.ID
    ID.FORMAT = 'OLD'
    GOSUB PERFORM.SELECTION

* To read records in new format
    THE.LIST = DAS.DE.O.HDR$BASED.ON.DATE
    ID.FORMAT = 'NEW'
    GOSUB PERFORM.SELECTION
*
    RETURN
*
*------------------------------------------------------------------------
*===============
GREATER.THAN.EQ:
*===============
*
    YSEL1 = YVALUES<1,1,1>
    THE.ARGS<1> = "GE"
    THE.ARGS<2> = YSEL1

* To read records in old format
    THE.LIST = DAS.DE.O.HDR$BASED.ON.ID
    ID.FORMAT = 'OLD'
    GOSUB PERFORM.SELECTION

* To read records in new format
    THE.LIST = DAS.DE.O.HDR$BASED.ON.DATE
    ID.FORMAT = 'NEW'
    GOSUB PERFORM.SELECTION
*
    RETURN
*
*------------------------------------------------------------------------
*=========
NOT.RANGE:
*=========
*
    IF YVALUES<1,1,2> = "" THEN
        GOSUB NOT.EQUAL
    END ELSE
        IF YVALUES<1,1,1> GT YVALUES<1,1,2> THEN
            YSEL1 = YVALUES<1,1,2> ; YSEL2 = YVALUES<1,1,1>
        END ELSE
            YSEL1 = YVALUES<1,1,1> ; YSEL2 = YVALUES<1,1,2>
        END

        THE.ARGS<1> = "LT":@VM:"GT"
        THE.ARGS<2> = YSEL1:@VM:YSEL2
        * To read records in old format
        THE.LIST = DAS.DE.O.HDR$BASED.ON.ID
        ID.FORMAT = 'OLD'
        GOSUB PERFORM.SELECTION

        * To read records in new format
        THE.LIST = DAS.DE.O.HDR$BASED.ON.DATE
        ID.FORMAT = 'NEW'
        GOSUB PERFORM.SELECTION
    END
*
    RETURN
*
*------------------------------------------------------------------------
*=================
PERFORM.SELECTION:
*=================
*
    YCONCAT.IDS = ""
    THE.TABLE = 'DE.O.HISTORY.QUEUE'
    EB.DataAccess.Das(THE.TABLE, THE.LIST, THE.ARGS, '')
    YCONCAT.IDS = THE.LIST

    IF YCONCAT.IDS THEN
        LOOP
            REMOVE YCONCAT.ID FROM YCONCAT.IDS SETTING YD
            GOSUB READ.YID.LIST         ;* BG_100013037 - S / E
        WHILE YD
        REPEAT
    END
*
    RETURN
*
*------------------------------------------------------------------------
* BG_100013037 - S
*============
GET.YID.LIST:
*============
    YDE.MSG.NO = FIELD(YY,".",2)
    IF YDE.MSG.NO = "1" THEN  ;* Only accept 1
        IF YID.LIST THEN
            YID.LIST := @FM:FIELD(YY,".",1)
        END ELSE
            YID.LIST = FIELD(YY,".",1)
        END
    END
    RETURN
*------------------------------------------------------------------------
*=============
READ.YID.LIST:
*=============
    IF ID.FORMAT = 'OLD' THEN
        YREC = DE.Config.OHistoryQueue.Read(YCONCAT.ID, READ.ER)
        IF YREC THEN
            YID = YREC        ;*CI_10049664-S
            GOSUB ADD.INTO.LIST
        END
    END ELSE
        YID = FIELD(YCONCAT.ID,"-",1)   ;*CI_10049671-S
        GOSUB ADD.INTO.LIST
    END
    RETURN          ;* BG_100013037 - E
*------------------------------------------------------------------------
*=============
ADD.INTO.LIST:
*=============

    IF YID.LIST THEN
        YID.LIST := @FM:YID
    END ELSE
        YID.LIST = YID        ;*CI_10049664-E
    END
    RETURN
*------------------------------------------------------------------------
    END
