* @ValidationCode : MjoxNTQyOTE1OTE0OkNwMTI1MjoxNTY0NTY5NzU0MjkxOnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:12:34
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
$PACKAGE CQ.Cards
SUBROUTINE CONV.CARD.CHARGE.200602
*--------------------------------------------------------------------
*This is a FILE.ROUTINE attached to the new CONVERSION.DETAILS record,
*CONV.CARD.CHARGE.200602. In this enhancement, file type of CARD.CHARGE
*has been changed from FTF to FIN. So, this routine copies records from
*FTF company to related FIN company.
*--------------------------------------------------------------------
* 11/04/06 - CI_10040446
*            WHILE condition is changed to check both delimiter and company id.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
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

    EQUATE CARD.CHG.INPUTTER TO 10
    EQUATE CARD.CHG.DATE.TIME TO 11
    EQUATE CARD.CHG.AUTHORISER TO 12
    EQUATE CARD.CHG.CO.CODE TO 13
    EQUATE CARD.CHG.DEPT.CODE TO 14

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS.PARA

RETURN
*----------
INITIALISE:
*----------
    FILE.CLASSIFICATION = ''
    R.FILE.CONTROL = ''
    R.CARD.CHARGE = ''
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
    Y.FIELD.NO = 0
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
    READ R.FILE.CONTROL FROM F.FILE.CONTROL,"CARD.CHARGE" ELSE
        Y.ETEXT = "Unable to read CARD.CHARGE record from F.FILE.CONTROL"
        GOSUB FATAL.ERROR
    END
*Get the list of Companies in which the conversion for a FIN type file has to be run
    CALL GET.CONVERSION.COMPANIES("FIN","CARD.CHARGE",Y.CONV.COMPANIES)
    LOOP
        REMOVE Y.FIN.COMPANY FROM Y.CONV.COMPANIES SETTING Y.COMP.DLIM
    WHILE Y.FIN.COMPANY:Y.COMP.DLIM     ;*CI_10040446 - S/E
        GOSUB LOAD.COMPANY.DETAILS
        IF Y.FIN.COMPANY NE Y.FTF.COMPANY THEN
*If the FTF and FIN Companies are different, copy LIVE,$NAU and $HIS files from FTF to FIN
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
                Y.FILE.NAME = "CARD.CHARGE":Y.SUFFIX
                GOSUB COPY.FILES
            NEXT
        END
    REPEAT
*Restore the MNEMONIC, ID.COMPANY and R.COMPANY values before returning from here
    MNEMONIC = SAVE.MNEMONIC
    MAT R.COMPANY = MAT SAVE.COMPANY
    ID.COMPANY = SAVE.COMPANY.ID

RETURN
*--------------------   ;*Load the Company IDs and Mnemonics for processing
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
*Create CARD.CHARGE files(LIVE,$NAU and $HIS) in FIN Company for copying the records
    CALL EBS.CREATE.FILE("CARD.CHARGE","",Y.ETEXT)
    IF Y.ETEXT THEN
        GOSUB FATAL.ERROR
    END

RETURN
*----------
COPY.FILES:
*----------
    FN.FTF.CARD.CHARGE = 'F':MNEMONIC:'.':Y.FILE.NAME       ;*Source file
    F.FTF.CARD.CHARGE = ''
    OPEN '',FN.FTF.CARD.CHARGE TO F.FTF.CARD.CHARGE ELSE
        Y.ETEXT = "Unable to open File : ":FN.FTF.CARD.CHARGE
        GOSUB FATAL.ERROR
    END
    FN.FIN.CARD.CHARGE = 'F':Y.FIN.MNE:'.':Y.FILE.NAME      ;*Destination file
    F.FIN.CARD.CHARGE = ''
    OPEN '',FN.FIN.CARD.CHARGE TO F.FIN.CARD.CHARGE ELSE
        Y.ETEXT = "Unable to open file ":FN.FIN.CARD.CHARGE
        GOSUB FATAL.ERROR
    END

    SELECT F.FTF.CARD.CHARGE
    Y.EOF = 0       ;*Not end of file
    LOOP
        IF NOT(Y.EOF) THEN
            READNEXT Y.FTF.CC.ID ELSE Y.EOF = 1   ;*End of file reached
        END
    UNTIL Y.EOF
        READ R.CARD.CHARGE FROM F.FIN.CARD.CHARGE,Y.FTF.CC.ID THEN
            Y.PAST.CONV.CNT += 1
        END ELSE
            READ R.CARD.CHARGE FROM F.FTF.CARD.CHARGE,Y.FTF.CC.ID ELSE
                Y.ETEXT = "Unable to read ":Y.FTF.CC.ID:" record from ":FN.FTF.CARD.CHARGE
                GOSUB FATAL.ERROR
            END
*Add new AUDIT field values for the record in FIN company
            Y.DATE.TIME = Y.DATE.TIME[9,2]:Y.DATE.TIME[1,2]:Y.DATE.TIME[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
            R.CARD.CHARGE<CARD.CHG.INPUTTER> = TNO:"_":APPLICATION    ;*Inputter
            R.CARD.CHARGE<CARD.CHG.DATE.TIME> = Y.DATE.TIME ;*Date and Time
            R.CARD.CHARGE<CARD.CHG.AUTHORISER> = TNO:"_":APPLICATION  ;*Authoriser
            R.CARD.CHARGE<CARD.CHG.CO.CODE> = Y.FIN.COMPANY ;*CO.CODE
            R.CARD.CHARGE<CARD.CHG.DEPT.CODE> = R.USER<EB.USE.DEPT.CODE>        ;*DEPT.CODE

            WRITE R.CARD.CHARGE TO F.FIN.CARD.CHARGE,Y.FTF.CC.ID
            Y.CONV.CNT += 1   ;*To hold the total number of presently converted records
            CALL SF.CLEAR(1,5,"CONVERTING:     ":FN.FIN.CARD.CHARGE)
        END

    REPEAT
*Append the details of summary report for sending to calling routine
    SUMMARY.REPORT<-1> = FMT(FN.FIN.CARD.CHARGE,'30L'):" CONVERTED         ":FMT(Y.CONV.CNT,'6R0,')
    SUMMARY.REPORT<-1> = FMT(FN.FIN.CARD.CHARGE,'30L'):" ALREADY CONVERTED ":FMT(Y.PAST.CONV.CNT,'6R0,')
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
