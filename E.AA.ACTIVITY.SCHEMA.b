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
* <Rating>-72</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.ACTIVITY.SCHEMA(IDS)
*
** Routine to build the activity schema for an enquiry
** Will use a nofile enquiry on the product
*
*** <region name= MODIFICATION DESCRIPTION>
*
* 14/03/14 - Enhancement : 912247
*            Task : 912263
*            New arguement OUT.DELETE added in AA.BUILD.ACTIVITY.RECORD routine.
*
*** </region>
*-------------------------------------------------------------------------------

    $USING AA.Framework
    $USING EB.Reports
    $USING EB.Interface

*
    COMMON/AASCHEMA/PROP.ACT.LIST
*
    GOSUB GET.VALUES
    GOSUB BUILD.AA.SCHEMA
    GOSUB GET.ACT.FOR.EACH.ACT

    RETURN

GET.VALUES:
    LOCATE "PRODUCT" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    PRODUCT = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    PRODUCT = ''
    END
*
    LOCATE "ACTIVITY.NAME"IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    ACTIVITY = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    ACTIVITY = ''
    END
*
    LOCATE "PROPERTY.NAME" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    PROPERTY = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    PROPERTY = ""
    END
*
    LOCATE "ACTIVITY.TYPE" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN     ;*HARTEST -S
    ACT.TYPE = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    ACT.TYPE = ''
    END   ;*HARTEST -E
*
    RETURN
*****************************
BUILD.AA.SCHEMA:
*****************************
    SCHEMA.LIST = ''
    ERR.MSG = ''
    AA.Framework.BuildActivitySchema(PRODUCT, ACTIVITY, ACT.TYPE, RET.LIST, ERR.MSG)
    RET.LIST = SORT(RET.LIST) ;*Sort it

    RETURN
******************************
GET.ACT.FOR.EACH.ACT:
******************************
    ACT.CNT = 1; IDS = ''
    PROP.ACT.LIST = ''
    LOOP
        REMOVE ACTIVITY.ID FROM RET.LIST SETTING ACT.POS
    WHILE ACTIVITY.ID:ACT.POS
        IF ACTIVITY THEN
            PROCESS.FLG = ACTIVITY EQ ACTIVITY.ID
        END ELSE
            PROCESS.FLG = ACTIVITY.ID['-',3,1] EQ PROPERTY OR NOT(PROPERTY)
        END
        IF PROCESS.FLG THEN   ;*Process only when both are NULL OR when a match is there
            IF NOT(ACTIVITY.ID['*',2,1]) OR ACTIVITY.ID['-',2,1] NE 'AGE.BILLS' THEN
                ACTION.LIST = ''
                PROP.CLASS.LIST = ''
                PROP.LIST = ''
                PROCESS.TYPE = 'INP'
                GOSUB STORE.GTS.COMMON  ;*Need to restore GTS common variables
                SAVE.ACTIVITY.ID = ACTIVITY.ID    ;*In case of linked activities save and restore as activity.id will be changed then
                AA.Framework.BuildActivityRecord('NEW','',EFFECTIVE.DATE,PRODUCT,ACTIVITY.ID,PROCESS.TYPE,'','','',PROP.CLASS.LIST,PROP.LIST,'','',ACTION.LIST,'', '', ERR.MSG)
                ACTIVITY.ID = SAVE.ACTIVITY.ID
                GOSUB RESTORE.GTS.COMMON          ;*Restore the GTS variables now
            END
            GOSUB BUILD.PROP.ACT.LIST
        END
    REPEAT

    RETURN
******************************
BUILD.PROP.ACT.LIST:

    PROP.ACT = ''
    CONVERT '.' TO ' ' IN ACTION.LIST
    PROP.ACT<1,-1> = LOWER(ACTION.LIST):'@':LOWER(PROP.LIST)
    PROP.ACT.LIST<-1> = ACTIVITY.ID:'~':PROP.ACT
    IDS<-1> = ACT.CNT         ;*Just pass the field postions to use it in E.AA.ACT.SCHEMA.REC
    ACT.CNT += 1

    RETURN
********************************
STORE.GTS.COMMON:

    SV.GTSACTIVE = EB.Interface.getGtsactive()
    SV.OFS$SOURCE.REC = EB.Interface.getOfsSourceRec()
    EB.Interface.setGtsactive(1)
    EB.Interface.setOfsSourceRec('')

    RETURN
********************************
RESTORE.GTS.COMMON:

    EB.Interface.setGtsactive(SV.GTSACTIVE)
    EB.Interface.setOfsSourceRec(SV.OFS$SOURCE.REC)

    RETURN
********************************
    END
