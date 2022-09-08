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
* <Rating>261</Rating>
*-----------------------------------------------------------------------------
* Version 3 25/05/01  GLOBUS Release No. 200508 30/06/05

    $PACKAGE AC.StandingOrders

    SUBROUTINE CONV.STO
*   17 SEP 92
*    Convert existing STANDING.ORDER records for new fields
*-----------------------------------------------------------------------------
* Modifications:
* --------------
*
* 09/02/15 - Enhancement 1214535 / Task 1218721
*            Moved the routine from FT to AC. Also included the Package name
*
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STANDING.ORDER

*************************************************************************

    GOSUB INITIALISE                   ; * Special Initialising

*************************************************************************

* Main Program Loop

    LOOP
        Z += 1
        YSELFILE.NAME = FIELD(YFILE.LIST,":",Z)
        YFILE.NAME = 'F.':YSELFILE.NAME
    UNTIL YSELFILE.NAME = "" DO
        F.STANDING.ORDER = ''
        CALL OPF(YFILE.NAME,F.STANDING.ORDER)
        *
        SELECT.STATEMENT = 'SELECT F':R.COMPANY(3):'.':YSELFILE.NAME
        YSTO.ID.LIST = ""
        CALL EB.READLIST(SELECT.STATEMENT, YSTO.ID.LIST, "", "", "")
        PREVIOUS.REC = ""
        Y.END = ""
        LOOP
            YSTO = YSTO.ID.LIST<1>
        UNTIL YSTO = "" OR Y.END = "END" DO
            DEL YSTO.ID.LIST<1>
            NEW.REC = ""
            PREVIOUS.REC = ""
            ETEXT = ''
            READU PREVIOUS.REC FROM F.STANDING.ORDER,YSTO ELSE PREVIOUS.REC = ""
                YCOUNT.MV = COUNT(PREVIOUS.REC,FM) + 1
                IF YCOUNT.MV < (START.FIELD+NO.OF.FIELDS) THEN
                    NEW.REC = PREVIOUS.REC
                    FOR X = START.FIELD TO EN.FIELD STEP - 1
                        NEW.REC = REPLACE(NEW.REC,X+NO.OF.FIELDS;PREVIOUS.REC<X>)
                        NEW.REC = REPLACE(NEW.REC,X;"")
                    NEXT X
                    CRT CRT.KEY.POS:YSTO
                    WRITE NEW.REC TO F.STANDING.ORDER,YSTO
                    END ELSE
                        RELEASE F.STANDING.ORDER,YSTO
                        IF ETEXT THEN CALL EXCEPTION.LOG('S','FT','CONV.STO','','','','F.STANDING.ORDER',YSTO,'','','')
                    END
                REPEAT

MAIN.REPEAT:
            REPEAT

V$EXIT:
            RETURN                             ; * From main program

*************************************************************************
            *                      S u b r o u t i n e s                            *
*************************************************************************

INITIALISE:

            *      CALL OPF('TEMP.STO',F.STANDING.ORDER)
            *
            Z = 0
            NO.OF.FIELDS = 6
            START.FIELD = 43
            EN.FIELD = 31
            YFILE.LIST = 'STANDING.ORDER:STANDING.ORDER$NAU:STANDING.ORDER$HIS'
            CRT.DIS.MESS = "NOW UPDATING STANDING.ORDER     : "
            CRT.DIS.POS = @(10,12)
            CRT.KEY.POS = @(38,12)
            CRT CRT.DIS.POS:CRT.DIS.MESS

            RETURN

*************************************************************************

        END
