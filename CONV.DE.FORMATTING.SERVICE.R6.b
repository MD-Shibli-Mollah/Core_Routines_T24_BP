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

*
*-----------------------------------------------------------------------------
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Config
    SUBROUTINE CONV.DE.FORMATTING.SERVICE.R6(YID, YREC, YFILE)
*
***********************************************
* As Formatting phantom is changed to Service,
* following files are created for each carrier:
* 1. Create the activation file, <carrier>.OUT.LIST
* 2. Create a new batch record with the id, <carrier>.OUT and put it into 'IHLD'
* 3. Create a new tsa.service record with the id, <carrier>.OUT and put it into 'IHLD'
*
* Similarly create the above 3 record for Inward Service also, ie.,
* 1. Create the activation file, <carrier>.IN.LIST
* 2. Create a new batch record with the id, <carrier>.IN and put it into 'IHLD'
* 3. Create a new tsa.service record with the id, <carrier>.IN and put it into 'IHLD'
*
***********************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
* No processing required for the carriers that are unauthorised or that are in history
    CARRIER.IN.NAU = INDEX(YFILE, '$NAU', 1)
    CARRIER.IN.HIS = INDEX(YFILE, '$HIS', 1)
    IF CARRIER.IN.NAU OR CARRIER.IN.HIS THEN RETURN

    GOSUB OPEN.FILES

    GOSUB CREATE.NEEDED.FILES

    RETURN

OPEN.FILES:
***********

    FN.FILE.CONTROL = 'F.FILE.CONTROL'
    F.FILE.CONTROL = ''
    CALL OPF(FN.FILE.CONTROL, F.FILE.CONTROL)

    FN.BATCH = 'F.BATCH'
    F.BATCH = ''
    CALL OPF(FN.BATCH, F.BATCH)

    FN.BATCH.NAU = 'F.BATCH$NAU'
    F.BATCH.NAU = ''
    CALL OPF(FN.BATCH.NAU, F.BATCH.NAU)

    FN.TSA.SERVICE = 'F.TSA.SERVICE'
    F.TSA.SERVICE = ''
    CALL OPF(FN.TSA.SERVICE, F.TSA.SERVICE)

    FN.TSA.SERVICE.NAU = 'F.TSA.SERVICE$NAU'
    F.TSA.SERVICE.NAU = ''
    CALL OPF(FN.TSA.SERVICE.NAU, F.TSA.SERVICE.NAU)

    RETURN

CREATE.NEEDED.FILES:
********************

    CARRIER = YID

*******************
* FOR OUTWARD CARRIER
*******************
* Create the activation file for Formatting Service
    Y.OUT.FILE = CARRIER:'.OUT.LIST'
    GOSUB CREATE.FILE

* Create Batch process in IHLD
    ID.BATCH = CARRIER:'.OUT'
    GOSUB CREATE.BATCH.RECORD

* Create TSA.SERVICE in IHLD
    ID.TSA.SERVICE = ID.BATCH
    GOSUB CREATE.TSA.SERVICE.RECORD


*************************
* FOR INWARD CARRIER
*************************
* Create the activation file for Formatting Service
    Y.OUT.FILE = CARRIER:'.IN.LIST'
    GOSUB CREATE.FILE

* Create Batch process in IHLD
    ID.BATCH = CARRIER:'.IN'
    GOSUB CREATE.BATCH.RECORD

* Create TSA.SERVICE in IHLD
    ID.TSA.SERVICE = ID.BATCH
    GOSUB CREATE.TSA.SERVICE.RECORD


    RETURN

CREATE.FILE:
************
* Check whether file exists.  If it doesn't, create it and the file
* control record

    READ YR.FC FROM F.FILE.CONTROL, Y.OUT.FILE ELSE
        YR.FC = ""
        YR.FC<2> = "DE"
        YR.FC<4> = 2          ;* hashed file
        YR.FC<5> = 11
        YR.FC<6> = "INT"
        YR.FC<14> = '1'
        YR.FC<15> = TNO:'_':OPERATOR
        X = OCONV(DATE(),"D-")
        YDATE.TIME = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
        YR.FC<16> = YDATE.TIME
        YR.FC<17> = TNO:'_SYSTEM'
        YR.FC<18> = ID.COMPANY
        YR.FC<19> = '1'
        YR.FC<20> = ''
        YR.FC<21> = ''

        WRITE YR.FC TO F.FILE.CONTROL, Y.OUT.FILE
    END

    F.OUT.FILE = ""
    CALL OPF('F.':Y.OUT.FILE:FM:"NO.FATAL.ERROR",F.OUT.FILE)

    IF ETEXT THEN
        ETEXT = ""
        Y.ERROR.MSG = ""

        CALL EBS.CREATE.FILE(Y.OUT.FILE,"",Y.ERROR.MSG)

        IF Y.ERROR.MSG THEN
            CALL FATAL.ERROR('CONV.DE.FORMATTING.SERVICE - ERR IN CREATING FILES')
        END
    END

    RETURN

CREATE.BATCH.RECORD:
********************

    R.BATCH = ''
    READ R.BATCH FROM F.BATCH, ID.BATCH ELSE
        R.BATCH<4> = 'F'
        IF ID.BATCH = CARRIER:'.OUT' THEN
            R.BATCH<6> = 'DE.OUTWARD'   ;* Common Job name for processing outgoing messages
        END ELSE
            R.BATCH<6> = 'DE.INWARD'    ;* Common Job name for processing incoming messages
        END
        R.BATCH<8> = 'D'

        R.BATCH<16> = 'IHLD'
        R.BATCH<18> = TNO:'_':OPERATOR
        X = OCONV(DATE(),"D-")
        YDATE.TIME = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
        R.BATCH<19> = YDATE.TIME
        R.BATCH<21> = ID.COMPANY

        WRITE R.BATCH TO F.BATCH.NAU, ID.BATCH
    END

    RETURN

CREATE.TSA.SERVICE.RECORD:
**************************

    R.TSA.SERVICE = ''
    READ R.TSA.SERVICE FROM F.TSA.SERVICE, ID.TSA.SERVICE ELSE
        R.TSA.SERVICE<1> = 'DE FORMATTING SERVICE'
        R.TSA.SERVICE<3> = 'DE.FORMATTING.SERVICE'          ;* TSA.WORKLOAD.PROFILE
        R.TSA.SERVICE<5> = 'AUTO'
        R.TSA.SERVICE<6> = '10'

        R.TSA.SERVICE<14> = 'IHLD'
        R.TSA.SERVICE<16> = TNO:'_':OPERATOR
        X = OCONV(DATE(),"D-")
        YDATE.TIME = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
        R.TSA.SERVICE<17> = YDATE.TIME
        R.TSA.SERVICE<19> = ID.COMPANY

        WRITE R.TSA.SERVICE TO F.TSA.SERVICE.NAU, ID.TSA.SERVICE
    END

    RETURN

END
