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

* Version 3 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-54</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Reports
    SUBROUTINE E.SEL.DE.O.HDR2(YID.LIST)
*
    $USING EB.DataAccess
    $USING DE.Reports
    $USING EB.SystemTables
    $USING EB.Reports
*
*
* 06/03/07 - BG_100013209
*            CODE.REVIEW changes.
*
* 06/03/07 - EN_10003245
*            Data Access Service - FT - Application Changes
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
*************************************************************************************************************
*
*
    LOCATE "DELIVERY.DATE" IN EB.Reports.getDFields()<1> SETTING DATE.POS ELSE
    RETURN      ;* BG_100013209 - S
    END   ;* BG_100013209 - E
*
***!      YID.LIST = ""
***!      YLIST.ID = "DEL.ENQ":TNO
    YSENT.FIXED = "SSELECT F.DE.O.HISTORY.QUEUE"
***!      YSENTENCE = "";YOPERAND = D.LOGICAL.OPERANDS<DATE.POS>
***!      YVALUES = D.RANGE.AND.VALUE<DATE.POS>
***!*
***!      ON YOPERAND GOSUB EQU,
***!      RANGE,
***!      LESS.THAN,
***!      GREATER.THAN,
***!      NOT.EQUAL,
***!      LK,
***!      UL,
***!      LESS.THAN.EQ,
***!      GREATER.THAN.EQ,
***!      NOT.RANGE
*
** Select All the other delivery queues so that a list can be built of
** all the formatted but not yet printed messages
*
    TABLE.NAME = 'DE.FORM.TYPE'
    THE.LIST = EB.DataAccess.DasAllIds
    THE.ARGS = ''
    TABLE.SUFFIX = ''
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    YCONCAT.IDS = THE.LIST
    IF YCONCAT.IDS THEN

        GOSUB READ.RECORD     ;* BG_100013209 - S / E

    END
*
    IF YID.LIST THEN

        GOSUB GET.YID.LIST    ;* BG_100013209 - S / E

    END
*
    RETURN
*
*----------------------------------------------------------------------
*
* BG_100013209 - S
*===========
READ.RECORD:
*===========

    LOOP
        REMOVE YFORM.TYPE FROM YCONCAT.IDS SETTING YD
        EB.SystemTables.setEtext("")
        YFILE = "F.DE.O.PRI.":YFORM.TYPE
        F.DE.PRI = "":@FM:"NO.FATAL.ERROR"
        EB.DataAccess.Opf(YFILE, F.DE.PRI)
        IF EB.SystemTables.getEtext() = "" THEN
            READ YREC FROM F.DE.PRI, "N" THEN
                GOSUB GET.PRI.LIST
            END
            READ YREC FROM F.DE.PRI, "P" THEN
                GOSUB GET.PRI.LIST
            END
            READ YREC FROM F.DE.PRI, "U" THEN
                GOSUB GET.PRI.LIST
            END
        END
    WHILE YD
    REPEAT
    RETURN
*
*************************************************************************************************************
*
*============
GET.YID.LIST:
*============
    YSTORE.LIST = YID.LIST ; YID.LIST = ""
    LOOP
        REMOVE YY FROM YSTORE.LIST SETTING YDELIM
        YDE.MSG.NO = FIELD(YY,".",2)
        IF YDE.MSG.NO = "1" THEN        ;* Only accept 1
            IF YID.LIST THEN
                YID.LIST := @FM:FIELD(YY,".",1)
            END ELSE
                YID.LIST = FIELD(YY,".",1)
            END
        END
    WHILE YDELIM
    REPEAT

    RETURN          ;* BG_100013209 - E
*
*************************************************************************************************************
*
GET.PRI.LIST:
*===========
*
    IF YFORM.TYPE MATCHES "SWIFT":@VM:"SIC":@VM:"TELEX" THEN
        IF YID.LIST THEN
            YID.LIST := @FM:YREC         ;* BG_100013209 - S
        END ELSE
            YID.LIST = YREC
        END         ;* BG_100013209 - E
    END ELSE
        IF YID.LIST THEN
            YID.LIST := @FM:RAISE(YREC<2>)         ;* BG_100013209 - S
        END ELSE
            YID.LIST = RAISE(YREC<2>)
        END         ;* BG_100013209 - E
    END
*
    RETURN
*
*
    END
*------------------------------------------------------------------------------------------
