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
* <Rating>-43</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Config
    SUBROUTINE CONV.SW.MOVE.REVAL.FIELDS.R11(YID,R.SWAP.PARAMETER,FN.SWAP.PARAMETER)
*---------------------------------------------------------------------------------
* Modification history
*---------------------------------------------------------------------------------
*
* 22/09/10  -  Defect 18083 / Task 33157
*             Linear method of NPV revaluation.
*
* 20/08/15 - Defect 1433711 / Task 1443709
*            Fatal  error in conversion CONV.SW.MOVE.REVAL.FIELDS.R11
* --------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_F.SWAP.REVAL.PARAMETER
    $INSERT I_F.COMPANY

* First Check is made whether the SWAP product is installed in the respective company, if not return  
    
    SW.POS = ''
    LOCATE "SW" IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING SW.POS ELSE
    RETURN
    END
         
    GOSUB INITIALISE
    GOSUB READ.SS.RECORD
    GOSUB MOVE.FLDS.TO.SWAP.REVAL.PARM

    RETURN

*----------
INITIALISE:
*-----------
    FN.STAND.SELECTION = "F.STANDARD.SELECTION"
    F.STAND.SELECTION = ""
    CALL OPF(FN.STAND.SELECTION,F.STAND.SELECTION)
    FN.STD.SELN.NAU = 'F.STANDARD.SELECTION$NAU'
    F.STD.SELN.NAU = ''
    CALL OPF(FN.STD.SELN.NAU,F.STD.SELN.NAU)
    
    SUFFIX.FILE = FIELD(FN.SWAP.PARAMETER,'$',2)
    IF SUFFIX.FILE = '' THEN
        FN.SWAP.REVAL.PARAMETER = 'F.SWAP.REVAL.PARAMETER'
    END ELSE
        FN.SWAP.REVAL.PARAMETER = 'F.SWAP.REVAL.PARAMETER':'$':SUFFIX.FILE
    END
    F.SWAP.REVAL.PARAMETER = ""
    CALL OPF(FN.SWAP.REVAL.PARAMETER,F.SWAP.REVAL.PARAMETER)
    F.SWAP.PARAMETER = ""
    CALL OPF(FN.SWAP.PARAMETER,F.SWAP.PARAMETER)
    R.SWAP.REVAL.PARAMETER = ""
    CALL F.READ(FN.SWAP.REVAL.PARAMETER,YID,R.SWAP.REVAL.PARAMETER,F.SWAP.REVAL.PARAMETER,ERR)

    RETURN

*---------------
READ.SS.RECORD:
*---------------

* Get the standard selection record details for SWAP.PARAMETER and SWAP.REVAL.PARAMETER

    APPLN = "SWAP.PARAMETER"
    CALL GET.STANDARD.SELECTION.DETS(APPLN,SWAP.PARM.SS)
    NEW.REVAL.APPLN = "SWAP.REVAL.PARAMETER"
    CALL GET.STANDARD.SELECTION.DETS(NEW.REVAL.APPLN,NEW.SWAP.REV.PARM)
    IF NOT(NEW.SWAP.REV.PARM) THEN
        CALL F.READ(FN.STD.SELN.NAU,NEW.REVAL.APPLN,NEW.SWAP.REV.PARM,F.STD.SELN.NAU,ERR.SW.REVAL.PARM)
    END

    RETURN

*----------------------------
MOVE.FLDS.TO.SWAP.REVAL.PARM:
*----------------------------

* Fields to be moved are stored in MOVED.FIELDS array and the value of those fields in SWAP.PARAMETER are moved to the new file SWAP.REVAL.PARAMETER.
*

    MOVED.FIELDS = "CCY.REVAL.PL.CATEG:VM:CCY.REVAL.CR.CODE:VM:CCY.REVAL.DR.CODE:VM:COUPON.CURVE.RATE:VM:AS.SHORT.PER.RATE:VM:AS.LONG.PER.RATE:VM:LB.SHORT.PER.RATE:VM:LB.LONG.PER.RATE:VM:NPV.FWD.RATE:VM:NPV.ACCR.ADJ:VM:ZCR.CALC.ALT.MTHD"
    TOTAL.MOVED.FIELDS = COUNT(MOVED.FIELDS,'VM')
    FOR COUNTER.VAR = 1 TO TOTAL.MOVED.FIELDS
        FLD.IN.SWAP.PARM = FIELD(MOVED.FIELDS,':VM:',COUNTER.VAR)

        CALL FIELD.NAMES.TO.NUMBERS(FLD.IN.SWAP.PARM,SWAP.PARM.SS,OLD.FLD.NO,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
        CALL FIELD.NAMES.TO.NUMBERS(FLD.IN.SWAP.PARM,NEW.SWAP.REV.PARM,NEW.FLD.NO,YAFS,YAVS,YASS,DATA.TYPES,ERR.MSGS)

        R.SWAP.REVAL.PARAMETER<NEW.FLD.NO> = R.SWAP.PARAMETER<OLD.FLD.NO>
        R.SWAP.PARAMETER<OLD.FLD.NO> = ""

    NEXT COUNTER.VAR

    ZERO.COUP.RATE.VALUE = FIELD(MOVED.FIELDS,':VM:',TOTAL.MOVED.FIELDS+1,1)
    CALL FIELD.NAMES.TO.NUMBERS(ZERO.COUP.RATE.VALUE,SWAP.PARM.SS,ALT.MTD.FLD.NO,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
    IF R.SWAP.PARAMETER<ALT.MTD.FLD.NO> = "YES" THEN
        R.SWAP.REVAL.PARAMETER<SW.REVAL.PARAM.ZERO.COUPON.RATE> = "ALT"
        R.SWAP.PARAMETER<ALT.MTD.FLD.NO> = ""
    END

    R.SWAP.REVAL.PARAMETER<SW.REVAL.PARAM.DISCOUNT.FORMULA> = "1"

    GOSUB GET.AUDIT.INFO

    WRITE R.SWAP.REVAL.PARAMETER ON F.SWAP.REVAL.PARAMETER, YID
    WRITE R.SWAP.PARAMETER ON F.SWAP.PARAMETER, YID
    RETURN


*---------------
GET.AUDIT.INFO:
*---------------

* update audit field information

    OLD.AUDIT.START = 35
    NEW.AUDIT.START = 22
    FOR AUDIT.CTR = 0 TO 8
        R.SWAP.REVAL.PARAMETER<NEW.AUDIT.START+AUDIT.CTR> = R.SWAP.PARAMETER<OLD.AUDIT.START + AUDIT.CTR>
    NEXT AUDIT.CTR
    RETURN
END
