* @ValidationCode : Mjo1MjIyNzQ1Mjc6Q3AxMjUyOjE1NjQ1NzExNjkwODQ6c3JhdmlrdW1hcjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA4LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:36:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>53</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CQ.ChqFees
    SUBROUTINE CONV.CHEQUE.CHARGE.200602
*--------------------------------------------------------------------
*This is a FILE.ROUTINE attached to the new CONVERSION.DETAILS record,
*CONV.CHEQUE.CHARGE.200602. In this enhancement, file type of CHEQUE.CHARGE
*has been changed from FTF to FIN. So, this routine copies records from
*FTF company to related FIN company.
*--------------------------------------------------------------------
* 11/04/06 - CI_10040446
*            WHILE condition is changed to check both delimiter and company id.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Fees as ST_ChqFees and include $PACKAGE
*	
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*--------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_CONV.COMMON
    $INSERT I_F.COMPANY
    $INSERT I_F.MNEMONIC.COMPANY
    $INSERT I_F.USER
    $INSERT I_F.FILE.CONTROL

    EQUATE CHEQUE.CHG.INPUTTER TO 28
    EQUATE CHEQUE.CHG.DATE.TIME TO 29
    EQUATE CHEQUE.CHG.AUTHORISER TO 30
    EQUATE CHEQUE.CHG.CO.CODE TO 31
    EQUATE CHEQUE.CHG.DEPT.CODE TO 32


    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS.PARA

    RETURN
*----------
INITIALISE:
*----------
    FILE.CLASSIFICATION = ''
    R.FILE.CONTROL = ''
    R.CHEQUE.CHARGE = ''
    R.MNEMONIC.COMPANY = ''

    Y.CONV.COMPANIES = ''
    Y.FIN.COMPANY = ''
    Y.FTF.COMPANY = ''
    Y.FILE.TYPE = ''
    Y.SUFFIX = ''
    Y.COMP.DLIM = 0
    Y.FILE.NAME = ''
    Y.FIN.MNE = ''
    Y.FTF.CC.IDS = ''
    Y.FIN.CC.IDS = ''
    Y.FTF.CC.ID = ''
    Y.FTF.DLIM = 0
    Y.PAST.CONV.CNT = 0
    Y.CONV.CNT = 0
    Y.FTF.ID.POS = ''
    Y.ETEXT = ''
    Y.FIELD = 0
    Y.DATE.TIME = OCONV(DATE(),"D-")

    SUMMARY.REPORT = R.USER<EB.USE.USER.NAME>:' ':TIMEDATE()
    SAVE.COMPANY.ID = ID.COMPANY
    SAVE.MNEMONIC = MNEMONIC
    DIM SAVE.COMPANY(C$SYSDIM)
    MAT SAVE.COMPANY = MAT R.COMPANY

    RETURN
*----------
OPEN.FILES:
*----------
    FN.COMPANY = "F.COMPANY"
    F.COMPANY = ''
    CALL OPF(FN.COMPANY,F.COMPANY)

    FN.FILE.CONTROL = "F.FILE.CONTROL"
    F.FILE.CONTROL = ''
    CALL OPF(FN.FILE.CONTROL,F.FILE.CONTROL)

    FN.MNEMONIC.COMPANY = "F.MNEMONIC.COMPANY"
    F.MNEMONIC.COMPANY = ''
    CALL OPF(FN.MNEMONIC.COMPANY,F.MNEMONIC.COMPANY)

    RETURN

*------------
PROCESS.PARA:
*------------
    READ R.FILE.CONTROL FROM F.FILE.CONTROL,"CHEQUE.CHARGE" ELSE
        Y.ETEXT = "Unable to read CHEQUE.CHARGE record from F.FILE.CONTROL"
        GOSUB FATAL.ERROR
    END
*Get the list of companies in which the conversion for a FIN type file has to be run
    CALL GET.CONVERSION.COMPANIES("FIN","CHEQUE.CHARGE",Y.CONV.COMPANIES)
    LOOP
        REMOVE Y.FIN.COMPANY FROM Y.CONV.COMPANIES SETTING Y.COMP.DLIM
    WHILE Y.FIN.COMPANY:Y.COMP.DLIM     ;*CI_10040446 - S/E
        GOSUB LOAD.COMPANY.DETAILS
        IF Y.FIN.COMPANY NE Y.FTF.COMPANY THEN
*If the FTF and FIN companies are different, copy LIVE,$NAU and $HIS files from FTF to FIN
            GOSUB CREATE.FIN.FILES
            FOR Y.FILE.TYPE = 1 TO 3
                BEGIN CASE
                CASE Y.FILE.TYPE EQ 1
                    Y.SUFFIX = ""
                CASE Y.FILE.TYPE EQ 2
                    Y.SUFFIX = "$NAU"
                CASE Y.FILE.TYPE EQ 3
                    Y.SUFFIX = "$HIS"
                END CASE
                Y.FILE.NAME = "CHEQUE.CHARGE":Y.SUFFIX
                GOSUB COPY.FILES
            NEXT
        END
    REPEAT
*Restore the MNEMONIC, ID.COMPANY and R.COMPANY values before returning from here
    MNEMONIC = SAVE.MNEMONIC
    MAT R.COMPANY = MAT SAVE.COMPANY
    ID.COMPANY = SAVE.COMPANY.ID

    RETURN
*-------------------- ;*Load the Company IDs and Mnemonics for processing
LOAD.COMPANY.DETAILS:
*--------------------
    FILE.CLASSIFICATION = 'FTF'         ;*Set the file classification to get the MNEMONIC
    CALL LOAD.COMPANY(Y.FIN.COMPANY)
    $INSERT I_MNEMONIC.CALCULATION      ;*Get the MNEMONIC of the FTF company from R.COMPANY
    Y.FIN.MNE = R.COMPANY(EB.COM.MNEMONIC)
    READ R.MNEMONIC.COMPANY FROM F.MNEMONIC.COMPANY,MNEMONIC ELSE
        Y.ETEXT = "Unable to read ":MNEMONIC:" from F.MNEMONIC.COMPANY"
        GOSUB FATAL.ERROR
    END
    Y.FTF.COMPANY = R.MNEMONIC.COMPANY<AC.MCO.COMPANY>      ;*Get the ID of the FTF Company

    RETURN
*----------------
CREATE.FIN.FILES:
*----------------
*Create CHEQUE.CHARGE files(LIVE,$NAU and $HIS) in FIN company for copying the records
    CALL EBS.CREATE.FILE("CHEQUE.CHARGE","",Y.ETEXT)
    IF Y.ETEXT THEN
        GOSUB FATAL.ERROR
    END

    RETURN
*----------
COPY.FILES:
*----------
    FN.FTF.CHEQUE.CHARGE = 'F':MNEMONIC:'.':Y.FILE.NAME     ;*Source file
    F.FTF.CHEQUE.CHARGE = ''
    OPEN '',FN.FTF.CHEQUE.CHARGE TO F.FTF.CHEQUE.CHARGE ELSE
        Y.ETEXT = "Unable to open File : ":FN.FTF.CHEQUE.CHARGE
        GOSUB FATAL.ERROR
    END
    FN.FIN.CHEQUE.CHARGE = 'F':Y.FIN.MNE:'.':Y.FILE.NAME    ;*Destination file
    F.FIN.CHEQUE.CHARGE = ''
    OPEN '',FN.FIN.CHEQUE.CHARGE TO F.FIN.CHEQUE.CHARGE ELSE
        Y.ETEXT = "Unable to open file ":FN.FIN.CHEQUE.CHARGE
        GOSUB FATAL.ERROR
    END

    SELECT F.FTF.CHEQUE.CHARGE
    Y.EOF = 0       ;*Not end of file
    LOOP
        IF NOT(Y.EOF) THEN
            READNEXT Y.FTF.CC.ID ELSE Y.EOF = 1   ;*End of file reached
        END
    UNTIL Y.EOF
*Do check in both LIVE and $NAU files before copying
        READ R.CHEQUE.CHARGE FROM F.FIN.CHEQUE.CHARGE,Y.FTF.CC.ID THEN
            Y.PAST.CONV.CNT += 1
        END ELSE
            READ R.CHEQUE.CHARGE FROM F.FTF.CHEQUE.CHARGE,Y.FTF.CC.ID ELSE
                Y.ETEXT = "Unable to read ":Y.FTF.CC.ID:" record from ":FN.FTF.CHEQUE.CHARGE
                GOSUB FATAL.ERROR
            END
*Add new AUDIT field values for the record in FIN company
            Y.DATE.TIME = Y.DATE.TIME[9,2]:Y.DATE.TIME[1,2]:Y.DATE.TIME[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
            R.CHEQUE.CHARGE<CHEQUE.CHG.INPUTTER> = TNO:"_":APPLICATION          ;*Inputter
            R.CHEQUE.CHARGE<CHEQUE.CHG.DATE.TIME> = Y.DATE.TIME       ;*DATE.TIME
            R.CHEQUE.CHARGE<CHEQUE.CHG.AUTHORISER> = TNO:"_":APPLICATION        ;*Authoriser
            R.CHEQUE.CHARGE<CHEQUE.CHG.CO.CODE> = Y.FIN.COMPANY       ;*CO.CODE
            R.CHEQUE.CHARGE<CHEQUE.CHG.DEPT.CODE> = R.USER<EB.USE.DEPT.CODE>    ;*DEPT.CODE

            WRITE R.CHEQUE.CHARGE TO F.FIN.CHEQUE.CHARGE,Y.FTF.CC.ID
            Y.CONV.CNT += 1   ;*To hold the total number of presently converted records
            CALL SF.CLEAR(1,5,"CONVERTING:     ":FN.FIN.CHEQUE.CHARGE)
        END
    REPEAT
*Append the details of summary report for sending to calling routine
    SUMMARY.REPORT<-1> = FMT(FN.FIN.CHEQUE.CHARGE,'30L'):" CONVERTED         ":FMT(Y.CONV.CNT,'6R0,')
    SUMMARY.REPORT<-1> = FMT(FN.FIN.CHEQUE.CHARGE,'30L'):" ALREADY CONVERTED ":FMT(Y.PAST.CONV.CNT,'6R0,')
    Y.CONV.CNT = 0
    Y.PAST.CONV.CNT = 0

    RETURN
*-----------
FATAL.ERROR:
*-----------
*Any fail in file handling would result in fatal out from the operation
    CALL SF.CLEAR(8,22,Y.ETEXT)
    CALL PGM.BREAK

    RETURN
END
