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
* <Rating>260</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE MB.CALCULATE.AGE(AGE,IN.AGE.ON.DATE,IN.DATE.OF.BIRTH)
*-----------------------------------------------------------------------------
*
* Subroutine Type       :       PROCEDURE
* Attached to           :       Version API to raise Error/Override when Opening a Minor Account
* Attached as           :       Procedure Call
* Primary Purpose       :       Calculate the Age of the Customer
*
* Incoming:
* ---------
* IN.AGE.ON.DATE           :       Date as of which the age needs to be calculated. If Null, defaulted to TODAY
* IN.DATE.OF.BIRTH         :       Date of Birth. If not supplied, an Error is set
*
* Outgoing:
* ---------
* AGE                   :       Age as of AGE.ON.DATE
*
*
* Error Variables:
* ----------------
* E                     :      Error raised if Date of Birth is not supplied or is not a Valid Date
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* 27 OCT 2010 - Sathish PS
*               New Development for SI RMB1 Refresh Retail Model Bank
*               Age Calculation ripped off of Woody's code.
*
* 04/07/2013 -  Defect - 707451 / Task - 721213
*               Initialised IN2D.T1.
*
* 07/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Interface
    $USING EB.Utility

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

    RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

    AGE = AGE.ON.DATE[1,4] - DATE.OF.BIRTH[1,4]

    BEGIN CASE

        CASE AGE.ON.DATE[5,2] < DATE.OF.BIRTH[5,2]
            AGE -= 1

        CASE AGE.ON.DATE[5,2] = DATE.OF.BIRTH[5,2]
            IF AGE.ON.DATE[7,2] < DATE.OF.BIRTH[7,2] THEN
                AGE -= 1
            END

    END CASE

    RETURN          ;* from PROCESS
*-----------------------------------------------------------------------------------
* <New Subroutines>

* </New Subroutines>
*-----------------------------------------------------------------------------------*
*//////////////////////////////////////////////////////////////////////////////////*
*////////////////P R E  P R O C E S S  S U B R O U T I N E S //////////////////////*
*//////////////////////////////////////////////////////////////////////////////////*
INITIALISE:

    PROCESS.GOAHEAD = 1
    AGE = ""
    AGE.ON.DATE = IN.AGE.ON.DATE
    DATE.OF.BIRTH = IN.DATE.OF.BIRTH
    IN2D.T1 = ''
    IN2D.N1 = 11 ; IN2D.T1<1> = 'D' ; IN2D.T1<2> = '1000'

    RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:

    RETURN          ;* From OPEN.FILES
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
    LOOP.CNT = 1 ; MAX.LOOPS = 4
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        BEGIN CASE
            CASE LOOP.CNT EQ 1
                IF UNASSIGNED(AGE.ON.DATE) OR NOT(AGE.ON.DATE) THEN
                    AGE.ON.DATE = EB.SystemTables.getToday()
                END ELSE
                    SAVE.COMI = EB.SystemTables.getComi() ; SAVE.ETEXT = EB.SystemTables.getEtext() ; SAVE.DISPLAY = EB.SystemTables.getVDisplay()
                    EB.SystemTables.setComi(AGE.ON.DATE)
                    EB.Utility.InTwod(IN2D.N1,IN2D.T1)
                    IF EB.SystemTables.getEtext() THEN
                        EB.SystemTables.setEtext('')
                        EB.SystemTables.setE('EB-RMB1.MB.CALCULATE.AGE.INVALID.AGE.ON.DATE')
                        tmp=EB.SystemTables.getE(); tmp<2,1>=AGE.ON.DATE; EB.SystemTables.setE(tmp)
                    END
                    EB.SystemTables.setComi(SAVE.COMI); EB.SystemTables.setEtext(SAVE.ETEXT); EB.SystemTables.setVDisplay(SAVE.DISPLAY)
                END

            CASE LOOP.CNT EQ 2
                IF NOT(DATE.OF.BIRTH) THEN
                    EB.SystemTables.setE('EB-RMB1.MB.CALCULATE.AGE.DATE.OF.BIRTH.NOT.SUPPLIED')
                END

            CASE LOOP.CNT EQ 3
                IF NOT(LEN(DATE.OF.BIRTH)) 8 THEN
                    EB.SystemTables.setE('EB-RMB1.MB.CALCULATE.AGE.NOT.IN.YYYYMMDD.FORMAT')
                    tmp=EB.SystemTables.getE(); tmp<2,1>=DATE.OF.BIRTH; EB.SystemTables.setE(tmp)
                END

            CASE LOOP.CNT EQ 4
                SAVE.COMI = EB.SystemTables.getComi() ; SAVE.ETEXT = EB.SystemTables.getEtext() ; SAVE.DISPLAY = EB.SystemTables.getVDisplay()
                EB.SystemTables.setComi(DATE.OF.BIRTH)
                EB.Utility.InTwod(IN2D.N1,IN2D.T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setEtext('')
                    EB.SystemTables.setE('EB-RMB1.MB.CALCULATE.AGE.INVALID.DATE.OF.BIRTH')
                    tmp=EB.SystemTables.getE(); tmp<2,1>=DATE.OF.BIRTH; EB.SystemTables.setE(tmp)
                END
                EB.SystemTables.setComi(SAVE.COMI); EB.SystemTables.setEtext(SAVE.ETEXT); EB.SystemTables.setVDisplay(SAVE.DISPLAY)

        END CASE

        LOOP.CNT += 1

        IF EB.SystemTables.getE() THEN
            PROCESS.GOAHEAD = 0
        END

    REPEAT

    RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
    END
