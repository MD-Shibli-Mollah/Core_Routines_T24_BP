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

* Version n dd/mm/yy  GLOBUS Release No. 200508 04/07/05
*-----------------------------------------------------------------------------
* <Rating>1166</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MD.Fees
    SUBROUTINE CONV.MD.CSN.RATE.CHANGE.R06

* This is to be run as a file routine.
* Conversion is from INT to FIN of MD.CSN.RATE.CHANGE
* Also since the FILE.CONTROL would have got released before
* the conversion procedure, now the FILE.CONTROL would show as
* FIN type file . There is a possibility that this routine may get
* executed for n companies, which should not happen.
* Just run it once for all companies.
***************************************************************************************
*
* 07/07/05 - CI_10032080
*            Only process Lead companies and check for MD product
*
* 14/10/06 - CI_10044856
*            Fatal error in Load. Company while running CONV.MD.CSN.RATE.CHANGE routine.
***************************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.MD.CSN.RATE.CHANGE
    $INSERT I_F.COMPANY

    DIM FVINT.CSN.FILE(3)
    FINT.CSN.FILE = 'F.MD.CSN.RATE.CHANGE'
    MAT FVINT.CSN.FILE = ''
    F.COMPANY = ''
    INT.FILE.PRESENT = 1
    FILE.SFX = "":FM:"$NAU":FM:"$HIS"
    SAVE.ID.COMPANY = ID.COMPANY

    OPEN '',FINT.CSN.FILE TO FVINT.CSN.FILE(1) ELSE INT.FILE.PRESENT = 0
    OPEN '','F.COMPANY' TO F.COMPANY ELSE
        TEXT = "UNABLE TO OPEN COMPANY FILE"
        CALL FATAL.ERROR("CONV.MD.CSN.RATE.CHANGE.R06")
    END

    IF INT.FILE.PRESENT THEN



        OPEN '','F.MD.CSN.RATE.CHANGE$NAU' TO FVINT.CSN.FILE(2) ELSE NULL

        OPEN '','F.MD.CSN.RATE.CHANGE$HIS' TO FVINT.CSN.FILE(3) ELSE NULL

        GOSUB SELECT.COMP.RECORDS
        GOSUB PROCESS.RECORDS
        GOSUB REMOVE.VOC.ENTRIES


* The VOC for the INT file and the file F.MD.CSN.RATE.CHANGE has to be
* removed.

    END


    RETURN

**********************************************************************
SELECT.COMP.RECORDS:

    SEL.CMD = 'SELECT F.MNEMONIC.COMPANY'
    EXECUTE SEL.CMD
    READLIST MNE.COMPS ELSE MNE.COMPS = ''
    OPEN '','F.MNEMONIC.COMPANY' TO F.MNE.COMPANY ELSE
        TEXT = "UNABLE TO OPEN MNEMONIC COMPANY"
        CALL FATAL.ERROR("CONV.MD.CSN.RATE.CHANGE.R06")

    END
    CALL OPF('F.COMPANY',F.COMPANY)


    RETURN
**********************************************************************
PROCESS.RECORDS:

    SELECT F.COMPANY
    LOOP READNEXT ID ELSE ID = "" WHILE ID <> ''
        COMP.REC = ''
        CER = ''
        CALL F.READ('F.COMPANY',ID,COMP.REC,F.COMPANY,CER)
        IF COMP.REC<EB.COM.CONSOLIDATION.MARK> EQ 'N' AND NOT(CER) THEN
            IF ID NE ID.COMPANY THEN
                CALL LOAD.COMPANY(ID)
            END
            IF R.COMPANY(EB.COM.FINANCIAL.MNE) = R.COMPANY(EB.COM.MNEMONIC) THEN          ;* Lead Company
                LOCATE 'MD' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING POSN ELSE      ;* find product
                    POSN = 0
                END
                IF POSN THEN
                    MNE = R.COMPANY(EB.COM.MNEMONIC)
                    FOR SFX.IND = 1 TO 3
                        FFIN.TO.FILE = 'F':MNE:'.MD.CSN.RATE.CHANGE':FILE.SFX<SFX.IND>
                        FFIN.FILE = ''
                        OPEN '',FFIN.TO.FILE TO FFIN.FILE ELSE
                            TEXT = "UNABLE TO OPEN FILE ":FFIN.TO.FILE
                            CALL FATAL.ERROR("CONV.MD.CSN.RATE.CHANGE.R06")
                        END
                        SEL.CMD = "SELECT F.MD.CSN.RATE.CHANGE":FILE.SFX<SFX.IND>:" WITH CO.CODE EQ ":ID.COMPANY
                        EXECUTE SEL.CMD
                        READLIST CSN.LIST ELSE CSN.LIST = ''
                        LOOP
                            REMOVE CSN.ID FROM CSN.LIST SETTING MPOS
                        WHILE CSN.ID:MPOS

                            READ R.CSN.REC FROM FVINT.CSN.FILE(SFX.IND),CSN.ID ELSE R.CSN.REC = ''
                            IF R.CSN.REC THEN
                                WRITE R.CSN.REC TO FFIN.FILE,CSN.ID ON ERROR NULL
                                DELETE FVINT.CSN.FILE(SFX.IND),CSN.ID
                            END

                        REPEAT
                    NEXT SFX.IND
                END
            END
        END
    REPEAT

    RETURN
**********************************************************************
REMOVE.VOC.ENTRIES:
    F.VOC = ''
    OPEN '','VOC' TO F.VOC ELSE
        TEXT = "UNABLE TO OPEN VOC"
        CALL FATAL.ERROR("CONV.MD.CSN.RATE.CHANGE")
    END
    SH.RM ="REMOVE"
    RETURN.CODE = ''

    FOR IND.SFX = 1 TO 3
        READ R.VOC FROM F.VOC,FINT.CSN.FILE:FILE.SFX<IND.SFX> ELSE R.VOC = ''
        IF R.VOC THEN
            FPATH = R.VOC<2>
            DELETE F.VOC,FINT.CSN.FILE:FILE.SFX<IND.SFX>
            CALL SYSTEM.CALL(SH.RM,"",FPATH,"",RETURN.CODE)

        END
    NEXT IND.SFX

    RETURN
**********************************************************************
END
