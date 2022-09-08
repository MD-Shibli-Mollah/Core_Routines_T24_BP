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

* Version 3 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>1426</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE CONV.ENQ.VER.G12.2.1
*
* For each ENQUIRY version rec, check for NXT.LVL.DESC field
* and convert them to NXT.DESC
*
*-----------------------------------------------------------
*
* 28/10/02 - GLOBUS_BG_100002538
*            Select stmt was not compatible in Universe
*            Include locate to deal with -01.01 and -01
*
*---------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.VERSION

    GOSUB OPEN.FILES

    FILE.NAME = 'F.VERSION'
    FILE.VAR = F.VERSION
    GOSUB SELECT.LOOP.WRITE   ;* select live records

    FILE.NAME = 'F.VERSION$NAU'
    FILE.VAR = F.VERSION.NAU
    GOSUB SELECT.LOOP.WRITE   ;* Now do unauth recs

    FILE.NAME = 'F.VERSION$HIS'
    FILE.VAR = F.VERSION.HIS
    GOSUB SELECT.LOOP.WRITE   ;* Lastly do history recs

    RETURN          ;* Return to calling routine
*
*************************************************************************
*
OPEN.FILES:

    OPEN '', 'F.VERSION' TO F.VERSION ELSE NULL
    OPEN '', 'F.VERSION$NAU' TO F.VERSION.NAU ELSE NULL
    OPEN '', 'F.VERSION$HIS' TO F.VERSION.HIS ELSE NULL
    RETURN
*
***********************************************************************
*
SELECT.LOOP.WRITE:
    EXECUTE 'SELECT ': FILE.NAME :' LIKE ENQUIRY,... CAPTURING JUNK'  ;* _BG_100002538
*
* For each VERSION enquiry record locate 'NXT.LVL.DESC' in any field
* containing enquiry fields and change it to 'NXT.DESC'
*

    LOOP READNEXT V.ID ELSE V.ID = '' UNTIL V.ID = ''
        VER.REC = ''
        READ VER.REC FROM FILE.VAR, V.ID THEN
            AF = EB.VER.FIELD.NO
            LOOP    ;* for each field
                IF AF = EB.VER.TABLE.VAL.ASSOC THEN         ;* sub values exist in this field
                    NO.VMS = ''
                    NO.VMS = COUNT(VER.REC<AF>, VM) + 1
                    FOR XX = 1 TO NO.VMS
                        POSN = ''
                        LOCATE 'NXT.LVL.DESC' IN VER.REC<AF,XX,1> SETTING POSN THEN
                            VER.REC<AF,XX,POSN> = 'NXT.DESC'
                        END
                        POSN = ''
                        LOCATE 'NXT.LVL.DESC-1' IN VER.REC<AF,XX,1> SETTING POSN THEN
                            VER.REC<AF,XX,POSN> = 'NXT.DESC-1'
                        END
                        POSN = ''
                        LOCATE 'NXT.LVL.DESC-1.1' IN VER.REC<AF,XX,1> SETTING POSN THEN
                            VER.REC<AF,XX,POSN> = 'NXT.DESC-1.1'
                        END
                        POSN = ''
                        LOCATE 'NXT.LVL.DESC-01' IN VER.REC<AF,XX,1> SETTING POSN THEN
                            VER.REC<AF,XX,POSN> = 'NXT.DESC-01'
                        END
                        POSN = ''
                        LOCATE 'NXT.LVL.DESC-01.01' IN VER.REC<AF,XX,1> SETTING POSN THEN
                            VER.REC<AF,XX,POSN> = 'NXT.DESC-01.01'
                        END
                    NEXT XX
                END ELSE      ;* If no sub values exist
                    POSN = ''
                    LOCATE 'NXT.LVL.DESC' IN VER.REC<AF,1> SETTING POSN THEN
                        VER.REC<AF,POSN> = 'NXT.DESC'
                    END
                    POSN = ''
                    LOCATE 'NXT.LVL.DESC-1' IN VER.REC<AF,1> SETTING POSN THEN
                        VER.REC<AF,POSN> = 'NXT.DESC-1'
                    END
                    POSN = ''
                    LOCATE 'NXT.LVL.DESC-1.1' IN VER.REC<AF,1> SETTING POSN THEN
                        VER.REC<AF,POSN> = 'NXT.DESC-1.1'
                    END
                    POSN = ''
                    LOCATE 'NXT.LVL.DESC-01' IN VER.REC<AF,1> SETTING POSN THEN
                        VER.REC<AF,POSN> = 'NXT.DESC-01'
                    END
                    POSN = ''
                    LOCATE 'NXT.LVL.DESC-01.01' IN VER.REC<AF,1> SETTING POSN THEN
                        VER.REC<AF,POSN> = 'NXT.DESC-01.01'
                    END
                END ;* end of checking thru sv's
            UNTIL AF = EB.VER.TABLE.VAL.ASSOC
                BEGIN CASE
                CASE AF = EB.VER.FIELD.NO  ; AF = EB.VER.RIGHT.ADJ.FIELD
                CASE AF = EB.VER.RIGHT.ADJ.FIELD  ; AF = EB.VER.NOINPUT.FIELD
                CASE AF = EB.VER.NOINPUT.FIELD  ; AF = EB.VER.NOCHANGE.FIELD
                CASE AF = EB.VER.NOCHANGE.FIELD   ; AF = EB.VER.REKEY.FIELD.NO
                CASE AF = EB.VER.REKEY.FIELD.NO   ; AF = EB.VER.AUTOM.FIELD.NO
                CASE AF = EB.VER.AUTOM.FIELD.NO   ; AF = EB.VER.MANDATORY.FIELD
                CASE AF = EB.VER.MANDATORY.FIELD   ; AF = EB.VER.VALIDATION.FLD
                CASE AF = EB.VER.VALIDATION.FLD   ; AF = EB.VER.TABLE.VAL.ASSOC
                END CASE
            REPEAT  ;* for each field
        END         ;* only if record exists
*
        WRITE VER.REC TO FILE.VAR, V.ID

    REPEAT          ;* for each record
*
    RETURN          ;* for next file
********************************************************************************

*
END
