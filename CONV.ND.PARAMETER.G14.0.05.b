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
* <Rating>677</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.Config
    SUBROUTINE CONV.ND.PARAMETER.G14.0.05

*MODFICATION HISTORY:
*--------------------
* 02/02/04 - BG_100006146 & BG_100006183
*           Introduce this routine for FILE ROUTINE
*           as ND.PARAMETER FILE.CONTROL classification
*           was changed from FIN to INT
*
* 25/02/04 - BG_100006330
*            Bug Fixes for ND.PARAMETER
*
* 07/07/07 - BG_100014538
*            Changes done to save and restore the R.COMPANY Common Variable
*            to avoid any crash in RUN.CONVERSION.PGMS while upgrading from
*            lower release to higher release.
*
* 18/12/07 - BG_100016363 / REF: TTS0707692
*            To reclassify the ND product under FX product.
*
*********************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.FILE.CONTROL
*
    LOCATE 'FX' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING PROD.EXIST ELSE PROD.EXIST = ''
    IF NOT(PROD.EXIST) THEN RETURN

    DIM R.COMPANY(EB.COM.AUDIT.DATE.TIME)
    DIM YSAVE.R.COMPANY(EB.COM.AUDIT.DATE.TIME)
    DIM R.FILE.CONTROL(10)

    MAT YSAVE.R.COMPANY = MAT R.COMPANY
    FILE.NAME = 'ND.PARAMETER'

*
    OPEN '','VOC' TO F.VOC ELSE
        ERROR.MSG = 'CANNOT OPEN VOC FILE'
        GOTO PROGRAM.ERROR
    END
*
    OPEN "","F.FILE.CONTROL" TO F.FILE.CONTROL ELSE
        ERROR.MSG = "UNABLE TO OPEN F.FILE.CONTROL"
        GOTO PROGRAM.ERROR
    END
*
    MATREAD R.FILE.CONTROL FROM F.FILE.CONTROL,FILE.NAME ELSE RECORD.EXISTS = 0 ; MAT R.FILE.CONTROL = ''
    F.COMPANY = ''
    CALL OPF('F.COMPANY',F.COMPANY)
*
    SELECT F.COMPANY
    LOOP
        READNEXT COMPANY ELSE COMPANY = "" UNTIL COMPANY = ""
        COMPANY.LIST<-1> = COMPANY
    REPEAT
*
    LOOP REMOVE COMPANY FROM COMPANY.LIST SETTING D UNTIL COMPANY = ""
        MATREADU R.COMPANY FROM F.COMPANY,COMPANY ELSE
            MAT R.COMPANY = ''
            ERROR.MSG ="EB.RTN.INVALID.COMP.CODE"
            GOTO PROGRAM.ERROR
        END
        FILE.CLASSIFICATION = 'FIN'
        Y.FILE.NAME = FILE.NAME
        $INSERT I_MNEMONIC.CALCULATION
        CREATE.NAME = "F": MNEMONIC: ".": FILE.NAME
        DELETE F.VOC, CREATE.NAME       ;* Remove voc entry - if present
    REPEAT
    ERROR.MSG = ''
    FILE.CLASSIFICATION = R.FILE.CONTROL(EB.FILE.CONTROL.CLASS)
    Y.FILE.NAME = "F.": FILE.NAME       ;* BG_100006330 - S
    DELETE F.VOC, Y.FILE.NAME ;* BG_100006330 - E
    CALL EBS.CREATE.FILE(FILE.NAME,'',ERROR.MSG)

PROGRAM.ERROR:
*
    PRINT ERROR.MSG:'   hit <cr>':
    MAT R.COMPANY = MAT YSAVE.R.COMPANY
    RETURN
END
