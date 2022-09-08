* @ValidationCode : MjoxMDYxMTI1MDQ6Q3AxMjUyOjE2MTg0OTgxMjU5NTA6c3VndW1hcnM6NjowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMDoyMjA6OTc=
* @ValidationInfo : Timestamp         : 15 Apr 2021 20:18:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sugumars
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 97/220 (44.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>733</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Framework
SUBROUTINE CONV.AA.ID.COMP.CHANGE(REC.ID, R.RECORD, FN.FILE)
*-----------------------------------------------------------------------------
*
* 10/07/13 - Enhancement :  662993 / Task : 725117
*            Conversion routine to change the key of AA.PRD.DES.XXX, AA.PRD.PRF.XXX and AA.PRD.CAT.XXX
*            Where XXX is the property class which supports variation
*
* 29-Nov-13 - Defect 841498/Task 850727
*             Dont run conversion if the key is already in new format.
*
* 20-Apr-17 - Enhancement : 841498/Task : 2094511
*             Conversion support for 'INTEREST COMPENSATION' property class
*------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.CHARGE
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACTIVITY.RESTRICTION
    $INSERT I_F.AA.PERIODIC.CHARGES
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.ACTIVITY.CHARGES
    $INSERT I_F.AA.ELIGIBILITY
    $INSERT I_F.AA.OFFICERS
    $INSERT I_F.AA.PREFERENTIAL.PRICING
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise</desc>

INITIALISE:

    FV.FILE = ''
    CALL OPF(FN.FILE, FV.FILE)
    FULL.ID = REC.ID
    LEVEL = FIELDS(FN.FILE, ".", 4)     ;* DES/PRF/CAT??

    CURR.PROP.CLASS = FIELD(FIELD(FN.FILE,"$",1),".",5,99)  ;* Property class of the file

    CCY.PROP.CLASS = 'INTEREST':VM:'CHARGE':VM:'TERM.AMOUNT':VM:'ACTIVITY.RESTRICTION':VM:'PERIODIC.CHARGES'
    
    CCY.SPECIFIC = ''
    LOCATE CURR.PROP.CLASS IN CCY.PROP.CLASS<1,1> SETTING CLASS.POS THEN
        CCY.SPECIFIC = 1
    END

    DO.KEY.CONVERSION = '1'      ;* Flag to indicate that conversion need not be run since the key is already in new format

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc>Main control logic in the sub-routine</desc>
PROCESS:

    GOSUB GET.FIELD.NO
    GOSUB DO.CONVERSION
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Field no>
*** <desc>Get filed nos for the id comp</desc>
GET.FIELD.NO:

    BEGIN CASE

        CASE CURR.PROP.CLASS EQ 'INTEREST'
            ID.COMP.1 = 72
            ID.COMP.2 = 73
            ID.COMP.3 = 74
            ID.COMP.4 = 75
            ID.COMP.5 = 76
            ID.COMP.6 = 77

        CASE CURR.PROP.CLASS EQ 'CHARGE'
            ID.COMP.1 = 59
            ID.COMP.2 = 60
            ID.COMP.3 = 61
            ID.COMP.4 = 62
            ID.COMP.5 = 63
            ID.COMP.6 = 64

        CASE CURR.PROP.CLASS EQ 'TERM.AMOUNT'
            ID.COMP.1 = 47
            ID.COMP.2 = 48
            ID.COMP.3 = 49
            ID.COMP.4 = 50
            ID.COMP.5 = 51
            ID.COMP.6 = 52

        CASE CURR.PROP.CLASS EQ 'ACTIVITY.RESTRICTION'
            ID.COMP.1 = 68
            ID.COMP.2 = 69
            ID.COMP.3 = 70
            ID.COMP.4 = 71
            ID.COMP.5 = 72
            ID.COMP.6 = 73

        CASE CURR.PROP.CLASS EQ 'PERIODIC.CHARGES'
            ID.COMP.1 = 50
            ID.COMP.2 = 51
            ID.COMP.3 = 52
            ID.COMP.4 = 53
            ID.COMP.5 = 54
            ID.COMP.6 = 55

        CASE CURR.PROP.CLASS EQ 'ACCOUNT'
            ID.COMP.1 = 69
            ID.COMP.2 = 70
            ID.COMP.3 = 71
            ID.COMP.4 = 72
            ID.COMP.5 = 73
            ID.COMP.6 = 74

        CASE CURR.PROP.CLASS EQ 'OFFICERS'
            ID.COMP.1 = 47
            ID.COMP.2 = 48
            ID.COMP.3 = 49
            ID.COMP.4 = 50
            ID.COMP.5 = 51
            ID.COMP.6 = 52

        CASE CURR.PROP.CLASS EQ 'ELIGIBILITY'
            ID.COMP.1 = 59
            ID.COMP.2 = 60
            ID.COMP.3 = 61
            ID.COMP.4 = 62
            ID.COMP.5 = 63
            ID.COMP.6 = 64

        CASE CURR.PROP.CLASS EQ 'ACTIVITY.CHARGES'
            ID.COMP.1 = 44
            ID.COMP.2 = 45
            ID.COMP.3 = 46
            ID.COMP.4 = 47
            ID.COMP.5 = 48
            ID.COMP.6 = 49

        CASE CURR.PROP.CLASS EQ 'PREFERENTIAL.PRICING'
            ID.COMP.1 = 75
            ID.COMP.2 = 76
            ID.COMP.3 = 77
            ID.COMP.4 = 78
            ID.COMP.5 = 79
            ID.COMP.6 = 80
        
        CASE CURR.PROP.CLASS EQ 'INTEREST.COMPENSATION'
            ID.COMP.1 = 50
            ID.COMP.2 = 51
            ID.COMP.3 = 52
            ID.COMP.4 = 53
            ID.COMP.5 = 54
            ID.COMP.6 = 55

    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Do conversion>
*** <desc>Do conversion for the selected file</desc>

DO.CONVERSION:

    BEGIN CASE

        CASE CCY.SPECIFIC AND LEVEL EQ 'DES'

            IF R.RECORD<ID.COMP.4> EQ '' AND R.RECORD<ID.COMP.1> THEN         ;* Conversion has not run. If the 4th comp is populated with date, conversion has already run or the key is fine. Dont rerun for this key
                OLD.ID = FULL.ID
                OLD.DATED.XREF.ID = CURR.PROP.CLASS
                OLD.DATED.XREF.ID := '*':R.RECORD<ID.COMP.1>
                OLD.DATED.XREF.ID := AA$SEP:R.RECORD<ID.COMP.2>

* New key - ConditionId-Ccy-Variation-Date

                NEW.ID = R.RECORD<ID.COMP.1>          ;* Condition id
                NEW.ID := AA$SEP:R.RECORD<ID.COMP.2>  ;* Currency
                NEW.ID := AA$SEP  ;* variation
                NEW.ID := AA$SEP:R.RECORD<ID.COMP.3>  ;* Date, Push to 4th position

                R.RECORD<ID.COMP.4> = R.RECORD<ID.COMP.3>
                R.RECORD<ID.COMP.3> = ''

* Dated xref new key - Popertyclass*ConditionId-Ccy-Variation

                NEW.DATED.XREF.ID = CURR.PROP.CLASS
                NEW.DATED.XREF.ID := '*':R.RECORD<ID.COMP.1>    ;* Condition Id
                NEW.DATED.XREF.ID := AA$SEP:R.RECORD<ID.COMP.2> ;* Currency
                NEW.DATED.XREF.ID := AA$SEP:R.RECORD<ID.COMP.3> ;* Variation

                FN.DATED.XREF = 'F.AA.PRD.DES.DATED.XREF'
                GOSUB DO.DATED.FILE.CONV
            END ELSE
                DO.KEY.CONVERSION = 0 ;* Dont run conversion again
            END


        CASE CCY.SPECIFIC AND LEVEL MATCHES 'PRF':VM:'CAT'

            IF R.RECORD<ID.COMP.6> EQ '' AND R.RECORD<ID.COMP.1> THEN         ;* Conversion has not run. If the 6th comp is populated with date, conversion has already run or the key is already in new format. Dont rerun for this key
                OLD.ID = FULL.ID
                OLD.DATED.XREF.ID = R.RECORD<ID.COMP.1>         ;* Product
                OLD.DATED.XREF.ID := AA$SEP:R.RECORD<ID.COMP.2> ;* Property
                OLD.DATED.XREF.ID := AA$SEP:R.RECORD<ID.COMP.3> ;* currency

* New key - Product-Property-Ccy-Variation-Effperiod-Date

                NEW.ID = R.RECORD<ID.COMP.1>          ;* Product
                NEW.ID := AA$SEP:R.RECORD<ID.COMP.2>  ;* Property
                NEW.ID := AA$SEP:R.RECORD<ID.COMP.3>  ;* Currency
                NEW.ID := AA$SEP  ;* Variation
                NEW.ID := AA$SEP:R.RECORD<ID.COMP.4>  ;* Effective period, Push to 5th position
                NEW.ID := AA$SEP:R.RECORD<ID.COMP.5>  ;* Date push to 6th position

                R.RECORD<ID.COMP.6> =  R.RECORD<ID.COMP.5>
                R.RECORD<ID.COMP.5> = R.RECORD<ID.COMP.4>
                R.RECORD<ID.COMP.4> = ''

* Dated xref new key - Product-Property-Ccy-Variation

                NEW.DATED.XREF.ID = R.RECORD<ID.COMP.1>         ;* Product
                NEW.DATED.XREF.ID := AA$SEP:R.RECORD<ID.COMP.2> ;* property
                NEW.DATED.XREF.ID := AA$SEP:R.RECORD<ID.COMP.3> ;* Currency
                NEW.DATED.XREF.ID := AA$SEP:R.RECORD<ID.COMP.4> ;* Variation

                IF LEVEL EQ 'PRF' THEN
                    FN.DATED.XREF = 'F.AA.PRD.PRF.DATED.XREF'
                END ELSE
                    FN.DATED.XREF = 'F.AA.PRD.CAT.DATED.XREF'
                END
                GOSUB DO.DATED.FILE.CONV
            END ELSE
                DO.KEY.CONVERSION = 0 ;* Dont run conversion again
            END

        CASE NOT(CCY.SPECIFIC) AND LEVEL EQ 'DES'

            IF R.RECORD<ID.COMP.3> EQ '' AND R.RECORD<ID.COMP.1> THEN         ;* Conversion has not run. If the 3rd comp is populated with date, conversion has already run or the key is already in new format. Dont rerun for this key
                OLD.ID = FULL.ID
                OLD.DATED.XREF.ID = CURR.PROP.CLASS
                OLD.DATED.XREF.ID := '*':R.RECORD<ID.COMP.1>

* New key - ConditionId-Variation-Date

                NEW.ID = R.RECORD<ID.COMP.1>          ;* Condition id
                NEW.ID := AA$SEP  ;* variation
                NEW.ID := AA$SEP:R.RECORD<ID.COMP.2>  ;* Date

                R.RECORD<ID.COMP.3> = R.RECORD<ID.COMP.2>
                R.RECORD<ID.COMP.2> = ''

* Dated xref new key - Popertyclass*ConditionId-Variation

                NEW.DATED.XREF.ID = CURR.PROP.CLASS
                NEW.DATED.XREF.ID := '*':R.RECORD<ID.COMP.1>    ;* Condition Id
                NEW.DATED.XREF.ID := AA$SEP:R.RECORD<ID.COMP.2> ;* Variation

                FN.DATED.XREF = 'F.AA.PRD.DES.DATED.XREF'
                GOSUB DO.DATED.FILE.CONV
            END ELSE
                DO.KEY.CONVERSION = 0 ;* Dont run conversion again
            END


        CASE NOT(CCY.SPECIFIC) AND LEVEL MATCHES 'PRF':VM:'CAT'

            IF R.RECORD<ID.COMP.5> EQ '' AND R.RECORD<ID.COMP.1> THEN         ;* Conversion has not run. If the 5th comp is populated with date, conversion has already run or the key is already in new format. Dont rerun for this key

                OLD.ID = FULL.ID
                OLD.DATED.XREF.ID = R.RECORD<ID.COMP.1>         ;* Product
                OLD.DATED.XREF.ID := AA$SEP:R.RECORD<ID.COMP.2> ;* Property

* New key - Product-Property-Variation-Effperiod-Date

                NEW.ID = R.RECORD<ID.COMP.1>          ;* Product
                NEW.ID := AA$SEP:R.RECORD<ID.COMP.2>  ;* Property
                NEW.ID := AA$SEP  ;* Variation
                NEW.ID := AA$SEP:R.RECORD<ID.COMP.3>  ;* Effective period, Push to 4th position
                NEW.ID := AA$SEP:R.RECORD<ID.COMP.4>  ;* Date push to 5th position

                R.RECORD<ID.COMP.5> = R.RECORD<ID.COMP.4>
                R.RECORD<ID.COMP.4> = R.RECORD<ID.COMP.3>
                R.RECORD<ID.COMP.3> = ''

* Dated xref new key - Product-Property-Ccy-Variation

                NEW.DATED.XREF.ID = R.RECORD<ID.COMP.1>         ;* Product
                NEW.DATED.XREF.ID := AA$SEP:R.RECORD<ID.COMP.2> ;* property
                NEW.DATED.XREF.ID := AA$SEP:R.RECORD<ID.COMP.3> ;* Variation

                IF LEVEL EQ 'PRF' THEN
                    FN.DATED.XREF = 'F.AA.PRD.PRF.DATED.XREF'
                END ELSE
                    FN.DATED.XREF = 'F.AA.PRD.CAT.DATED.XREF'
                END
                GOSUB DO.DATED.FILE.CONV
            END ELSE
                DO.KEY.CONVERSION = 0 ;* Dont run conversion again
            END

    END CASE

    IF DO.KEY.CONVERSION THEN ;* No issues in converting. Go ahead
        REC.ID = NEW.ID       ;* Change the key format. Conversion details run will take care to update the record with passed new id
        DELETE FV.FILE , OLD.ID         ;* Delete the existing record
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Dated.xref file conversion>
*** <desc>Conversion to change the key of dated xref file</desc>

DO.DATED.FILE.CONV:

    FV.DATED.XREF = ''
    CALL OPF(FN.DATED.XREF , FV.DATED.XREF)
    CALL F.READ(FN.DATED.XREF, OLD.DATED.XREF.ID, R.DATED.XREF, FV.DATED.XREF, ERR)       ;* Fetch the record with old id
    IF R.DATED.XREF THEN
        WRITE R.DATED.XREF TO FV.DATED.XREF, NEW.DATED.XREF.ID        ;* Write record with new key format
        DELETE FV.DATED.XREF, OLD.DATED.XREF.ID   ;* Delete old key record
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------

END
