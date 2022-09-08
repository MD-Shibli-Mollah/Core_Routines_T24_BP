* @ValidationCode : MjotNzE1ODA3NTA4OkNwMTI1MjoxNTgwODAxMDkyMzc2OmthamFheXNoZXJlZW46LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkxMS4xOi0xOi0x
* @ValidationInfo : Timestamp         : 04 Feb 2020 12:54:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kajaayshereen
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201911.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 4 08/06/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>260</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LI.Config
SUBROUTINE CONVERT.LIMIT.PARAM
*
*
* 11/09/02 - EN_10001097
*            Conversion of error messages to error codes.
*
* 04/02/20 - Enhancement 2822520 / Task 3569554
*            Strict compiler changes
*
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BD.PURCH.SALE
    $USING LI.Config
    
    PRINT @(10,5):
    PRINT "THIS PROGRAM UPDATES THE 'SYSTEM' RECORD IN "
    PRINT @(10,6):
    PRINT "'LIMIT.PARAMETER' FILE."
    PRINT @(10,7):
    PRINT
    PRINT @(10,8):
    PRINT "FOR 'BD.PURCH.SALE' APPLICATION THE DECISION.FIELD "
    PRINT @(10,9):
    PRINT " IS CHANGED TO  ":BD.BPS.LIMIT.CHECK:'- LIMIT.CHECK'
    PRINT @(5,11):
    PRINT "*** AUTHORISE THE LIMIT.PARAMETER RECORD AFTER RUNNING THIS PROGRAM ***"
    TEXT = 'OK TO CONTINUE'
    CALL OVE
    IF TEXT <> 'Y' THEN RETURN
*
    REC.UPD = ''
    F.LIMIT.PARAMETER.NAU = ''
    CALL OPF('F.LIMIT.PARAMETER$NAU',F.LIMIT.PARAMETER.NAU)
    F.LIMIT.PARAMETER = ''
    CALL OPF('F.LIMIT.PARAMETER',F.LIMIT.PARAMETER)
    K.LIMIT = 'SYSTEM' ; R.LIM = ''
    READU R.LIM FROM F.LIMIT.PARAMETER, K.LIMIT ELSE
        E = 'LI.RTN.REC.NOT.FOUND.ON.FILE.F.LIMIT.PARAMETER':@FM:K.LIMIT:@VM:'F.LIMIT.PARAMETER'
        GOTO FATAL
    END
    CUR.POS = 1
LOC.NEXT:
    LOCATE 'BD.PURCH.SALE' IN R.LIM<LI.Config.LimitParameter.ParApplication,CUR.POS> SETTING POS ELSE POS = 0
    IF POS THEN
        IF R.LIM<LI.Config.LimitParameter.ParDecisField,POS,1> <> '' THEN
            R.LIM<LI.Config.LimitParameter.ParDecisField,POS,1> = BD.BPS.LIMIT.CHECK
        END
        CUR.POS = POS + 1
        REC.UPD = 1
        GOTO LOC.NEXT
    END
    RELEASE F.LIMIT.PARAMETER, K.LIMIT
    IF REC.UPD THEN
        R.LIM<LI.Config.LimitParameter.ParRecordStatus> = 'IHLD'
        WRITE R.LIM TO F.LIMIT.PARAMETER.NAU, K.LIMIT
    END ELSE
        PRINT @(10,13):"APPLICATION 'BD.PURCH.SALE' NOT FOUND"
        PRINT @(10,14):'NO UPDATES DONE.'
    END
*
    PRINT @(10,16):
    PRINT 'PROCESSING COMPLETE...'
    PRINT @(10,17):
    PRINT 'PRESS ANY KEY TO RETURN'
    INPUT XXX
RETURN
FATAL:
*-----
    TEXT = E
    CALL FATAL.ERROR('CONVERT.LIMIT.PARAM')
END
