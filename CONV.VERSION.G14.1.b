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
* <Rating>197</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Versions
    SUBROUTINE CONV.VERSION.G14.1

************************************************************************
*  Conversion routine for updating EB.API with all the validation routines
*  found in VERSION.
*
*  11/12/03 - GLOBUS_BG_100005819
*            Added audit trail info
* 08/04/04 - CI_10018849
*            When RUN.CONVERSION.PGMS is run after upgrade, the
*            conversion CONV.VERSION.G14.1 does not create EB.API records
*
* 01/06/10 - Task-48952, Defect-46850
*            EB.API records created during upgrade should also contains the Audit details.
*
************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.USER

    GOSUB INITIALISE
    GOSUB VERSION.GETSELECT
    GOSUB PROCESS.VERSION

    RETURN

************************************************************************
INITIALISE:

    F.EB.API = ''
    FN.EB.API = 'F.EB.API'
    CALL OPF(FN.EB.API, F.EB.API)

    F.VERSION = ''
    FN.VERSION = 'F.VERSION'
    CALL OPF(FN.VERSION, F.VERSION)

*Equate the fields to corresponding location

    EQUATE EB.VER.VALIDATION.RTN TO 59
    EQUATE EB.VER.INPUT.ROUTINE TO 63
    EQUATE EB.VER.AUTH.ROUTINE  TO 64
    EQUATE EB.VER.ID.RTN TO 74
    EQUATE EB.VER.CHECK.REC.RTN TO 75
    EQUATE EB.VER.AFTER.UNAU.RTN TO 76
    EQUATE EB.VER.BEFORE.AUTH.RTN TO 77

    EQUATE EB.API.PROTECTION.LEVEL TO 2
    EQUATE EB.API.SOURCE.TYPE TO 3
    EQUATE EB.API.CURR.NO TO 35
    EQUATE EB.API.INPUTTER TO 36
    EQUATE EB.API.DATE.TIME TO 37
    EQUATE EB.API.AUTHORISER TO 38
    EQUATE EB.API.CO.CODE TO 39
    EQUATE EB.API.DEPT.CODE TO 40

    RETURN

*************************************************************************
VERSION.GETSELECT:

    VERSION.SELECT.COMMAND ='SSELECT F.VERSION'
    CALL EB.READLIST(VERSION.SELECT.COMMAND, VERSION.ID.LIST, "", VERSION.RECORD.SELECTED,"")

    RETURN

*************************************************************************
PROCESS.VERSION:

    FOR VERSION.COUNT = 1 TO VERSION.RECORD.SELECTED

        READ R.VERSIONS FROM F.VERSION, VERSION.ID.LIST<VERSION.COUNT> THEN ; * CI_10018849

            THIS.SUBROUTINE = R.VERSIONS<EB.VER.INPUT.ROUTINE>
            GOSUB CHECK.SUBROUTINE.EXISTS

            THIS.SUBROUTINE = R.VERSIONS<EB.VER.AUTH.ROUTINE>
            GOSUB CHECK.SUBROUTINE.EXISTS

            THIS.SUBROUTINE = R.VERSIONS<EB.VER.CHECK.REC.RTN>
            GOSUB CHECK.SUBROUTINE.EXISTS

            THIS.SUBROUTINE = R.VERSIONS<EB.VER.AFTER.UNAU.RTN>
            GOSUB CHECK.SUBROUTINE.EXISTS

            THIS.SUBROUTINE = R.VERSIONS<EB.VER.BEFORE.AUTH.RTN>
            GOSUB CHECK.SUBROUTINE.EXISTS

            THIS.SUBROUTINE = R.VERSIONS<EB.VER.VALIDATION.RTN>
            GOSUB CHECK.SUBROUTINE.EXISTS

            THIS.SUBROUTINE = R.VERSIONS<EB.VER.ID.RTN>
            GOSUB CHECK.SUBROUTINE.EXISTS

        END ; * CI_10018849 S/E
    NEXT VERSION.COUNT

    RETURN

*************************************************************************
CHECK.SUBROUTINE.EXISTS:

    R.EB.API = ""

    IF THIS.SUBROUTINE <> "" THEN

        IF THIS.SUBROUTINE[1, 4] <> "ENQ " THEN

            ROUTINE.LIST = RAISE( THIS.SUBROUTINE )

            TOTAL.RECORD = DCOUNT(ROUTINE.LIST, FM)

            FOR ROUTINE.COUNT = 1 TO TOTAL.RECORD

                ROUTINE.ID = ROUTINE.LIST<ROUTINE.COUNT>

                IF ROUTINE.ID[1, 1] = "@" THEN
                    ROUTINE.ID = ROUTINE.ID[2, 99]
                END

                READ R.EB.API FROM F.EB.API, ROUTINE.ID ELSE R.EB.API = '' ; * CI_10018849 S/E

                    IF R.EB.API = "" THEN
                        GOSUB WRITE.RECORD
                    END

                NEXT ROUTINE.COUNT
            END
        END

        RETURN

*************************************************************************
WRITE.RECORD:
        *

        R.EB.API<EB.API.PROTECTION.LEVEL> = "FULL"
        R.EB.API<EB.API.SOURCE.TYPE> = "BASIC"

        *Update the audit details
        TIME.STAMP = TIMEDATE()   ;*Current time and date
        AUDIT.TIME = OCONV(DATE(),"D-")
        R.EB.API<EB.API.CURR.NO> = 1
        R.EB.API<EB.API.INPUTTER> = TNO:"_CONV.VERSION.G14.1"
        R.EB.API<EB.API.DATE.TIME> = AUDIT.TIME[9,2]:AUDIT.TIME[1,2]:AUDIT.TIME[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
        R.EB.API<EB.API.AUTHORISER> = TNO:"_CONV.VERSION.G14.1"
        R.EB.API<EB.API.CO.CODE> = ID.COMPANY
        R.EB.API<EB.API.DEPT.CODE> = R.USER<EB.USE.DEPARTMENT.CODE>

        WRITE R.EB.API TO F.EB.API, ROUTINE.ID ; * CI_10018849 S/E

        RETURN
        *
        *-----------------------------------------------------------------------------
    END
