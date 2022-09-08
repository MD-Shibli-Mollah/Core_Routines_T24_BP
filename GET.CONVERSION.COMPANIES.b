* @ValidationCode : MjotMjUyOTMwNjY0OkNwMTI1MjoxNTk5NDcxMjM5NjE3OmFyZWVma2hhbmI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMjAwOS4yMDIwMDgyOC0xNjE3Oi0xOi0x
* @ValidationInfo : Timestamp         : 07 Sep 2020 15:03:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : areefkhanb
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 6 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>1595</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.Conversion
SUBROUTINE GET.CONVERSION.COMPANIES(CLASSIFICATION,PGM.NAME,COMPANIES)
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.COMPANY.CHECK
    $INSERT I_F.MNEMONIC.COMPANY
    $INSERT I_F.PGM.FILE
    $INSERT I_TSA.COMMON
    $INSERT I_T24.UPGRADE.COMMON
*
* This subroutine forms part of the release procedures.  It
* determines which companies a program should be run in depending
* on the level of the program.  It is called from CONVERSION.PGMS and
* CREATE.INAU.RECORDS
*
* Companies is passed back as a sub-valued field as this is how it is
* required to update the conversion program records.
*
*-------------------------------------------------------------------------------------------
* Modifications:
* --------------
* 06/08/96 - GB9601085
*            Check the CONVERSION.DETAILS file if the conversion
*            is not on the PGM.FILE and set the product from there.
*
* 17/01/97 - GB9700051
*            If the program is an installation level program, check all
*            companies to see if the product is installed in any of
*            them (it was originally assumed that the product must be
*            installed in the master company, but this does not always
*            seem to be the case)
*
* 14/04/08 - CI_10054703/Ref: HD0805803
*            Populate FIN.MNE and COM correctly in R.Company so that conversions are run
*            properly.
*
* 24/03/2020  - Task 3655942 / Enhancement 2822523
*               Incorporation of EB.Conversion component
*
* 07/09/2020 - Task 3952542 / Defect 3949984
*              RUN.PGM field is set to '0' for conversion 'CONV.DE.ADDRESS.201509' in CONVERSION.PGMS>R16 record.
*-------------------------------------------------------------------------------------------
* Initialise variables
*
    DIM SAVED.R.COMPANY(EB.COM.AUDIT.DATE.TIME)
    MAT SAVED.R.COMPANY = MAT R.COMPANY
    COMPANIES = ''
    IF CLASSIFICATION = '' THEN CLASSIFICATION = 'INT'
*
    IF PGM.NAME = '' THEN RETURN
*
* Open files
*
    OPEN '','F.COMPANY'TO F.COMPANY ELSE
        ETEXT ='EB.RTN.CANT.OPEN.F.COMPANY'
        GOTO FATAL.ERROR
    END
*
    OPEN '','F.CONVERSION.DETAILS' TO F.CONVERSION.DETAILS ELSE
        ETEXT ='EB.RTN.CANT.OPEN.F.CONVERSION.DETAILS'
        GOTO FATAL.ERROR
    END
*
    OPEN '','F.MNEMONIC.COMPANY'TO F.MNEMONIC.COMPANY ELSE
        ETEXT ='EB.RTN.CANT.OPEN.F.MNEMONIC.COMPANY'
        GOTO FATAL.ERROR
    END
*
    OPEN '','F.PGM.FILE'TO F.PGM.FILE ELSE
        ETEXT ='EB.RTN.CANT.OPEN.F.PGM.FILE'
        GOTO FATAL.ERROR
    END
*
* Get the product from the program from the PGM.FILE record if it exists,
* or the CONVERSION.DETAILS record otherwise
*
    PRODUCT.CODE = ''
    READ R.PGM.FILE FROM F.PGM.FILE,PGM.NAME THEN
        PRODUCT.CODE = R.PGM.FILE<EB.PGM.PRODUCT>
    END ELSE

* If not on the PGM.FILE try the CONVERSION.DETAILS file

        READ R.CONVERSION.DETAILS FROM F.CONVERSION.DETAILS, PGM.NAME THEN
            PRODUCT.CODE = R.CONVERSION.DETAILS<EB.Conversion.ConversionDetails.ConvProduct>
        END ELSE
            ETEXT = 'EB.RTN.CANT.READ.F.CONVERSION.DETAILS.OR.F.PGM.FILE':@FM:PGM.NAME
            GOTO FATAL.ERROR
        END
    END
*
* If program level is INT, get the master company
*
    IF CLASSIFICATION = 'INT' THEN
*
        OPEN '','F.COMPANY.CHECK'TO F.COMPANY.CHECK ELSE
            ETEXT ='EB.RTN.CANT.OPEN.F.COMPANY.CHECK'
            GOTO FATAL.ERROR
        END
*
* Read the MASTER record from the company file to determine the master
* company code
*
        READ R.MASTER FROM F.COMPANY.CHECK,'MASTER' ELSE
            ETEXT ='EB.RTN.CANT.READ.MASTER.F.COMPANY.CHECK'
            GOTO FATAL.ERROR
        END
        MASTER.COMPANY = TRIM(R.MASTER<EB.COC.COMPANY.CODE>)
        IF MASTER.COMPANY = '' THEN MASTER.COMPANY = ID.COMPANY
*
* Select all the companies to see if the product is installed in just
* company (might not necessarily be installed in the master company).
* If the product is installed in any company, set COMPANIES to the
* master company
*
        SELECT F.COMPANY
        LOOP
            READNEXT CID ELSE CID = ''
        WHILE CID NE '' DO
*
            MATREAD R.COMPANY FROM F.COMPANY,CID ELSE
                ETEXT ='EB.RTN.CANT.READ.F.COMPANY':@FM:CID
                GOTO FATAL.ERROR
            END
*
            THIS.COMPANY = CID
            GOSUB INIT.FIN.MNE
            GOSUB CHECK.APPLICATION

        REPEAT

    END ELSE
*
* Build a list of all companies from the company file for the level
* specified.  Do not include non-consolidation companies
*
        MNEMONICS.USED = ''
        SELECT F.COMPANY
        LOOP
            READNEXT CID ELSE CID = ''
        WHILE CID NE '' DO
*
            MATREAD R.COMPANY FROM F.COMPANY,CID ELSE
                ETEXT ='EB.RTN.CANT.READ.F.COMPANY':@FM:CID
                GOTO FATAL.ERROR
            END
*
            GOSUB INIT.FIN.MNE

            IF R.COMPANY(EB.COM.CONSOLIDATION.MARK) = 'N' THEN
                Y.FILE.NAME = ''
                FILE.CLASSIFICATION = CLASSIFICATION
                $INSERT I_MNEMONIC.CALCULATION
                IF MNEMONIC THEN
                    LOCATE MNEMONIC IN MNEMONICS.USED<1> SETTING X ELSE
                        MNEMONICS.USED<-1> = MNEMONIC
                        READ R.MNEMONIC.COMPANY FROM F.MNEMONIC.COMPANY,MNEMONIC ELSE
                            ETEXT = 'EB.RTN.CANT.READ.F.MNEMONIC.COMPANY':@FM:MNEMONIC
                            GOTO FATAL.ERROR
                        END
*
* Do not include company if the application of the program has not been
* installed for this company
*
                        THIS.COMPANY = R.MNEMONIC.COMPANY<AC.MCO.COMPANY>
                        GOSUB CHECK.APPLICATION
                    END
                END
            END
        REPEAT

    END

    MAT R.COMPANY = MAT SAVED.R.COMPANY

RETURN
*
*
*-------------------------------------------------------------------------
*   S U B R O U T I N E S
*-------------------------------------------------------------------------
*
CHECK.APPLICATION:
*
* Check if the application has been installed for the current company and
* only add the current company to the company list if it has
*
    IF INDEX(TSA.SERVICE.NAME,'UPGRADE',1) THEN ;* Check if the services matches T24.UPGRADE or T24.UPGRADE.PRIMARY OR T24.FULL.UPGRADE
        SPLIT.MODULE = MODULES.SPLIT          ;* Get the list of split modules with parent modules
        CHANGE @VM TO '*' IN SPLIT.MODULE      ;* Change @VM to '*' to get the exact batch new company product
        CONV.PRODUCT = PRODUCT.CODE            ;* Take a copy of Conversion Product
        FINDSTR '*':CONV.PRODUCT IN SPLIT.MODULE SETTING CONV.PRODUCT.AF,CONV.PRODUCT.AV THEN    ;* Check if the batch new company product is present in split module list
            PRODUCT.CODE = FIELD(SPLIT.MODULE<CONV.PRODUCT.AF>,'*',1)  ;* Extract the parent module with AF position
        END
    END
    LOCATE PRODUCT.CODE IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING X THEN
        IF CLASSIFICATION = 'INT' THEN
            COMPANIES = MASTER.COMPANY
        END ELSE
            COMPANIES<1,1,-1> = THIS.COMPANY
        END
    END

RETURN
*
*-------------------------------------------------------------------------
INIT.FIN.MNE:
*------------
* Just populate here to avoid crash while opening the fin level file.

    IF R.COMPANY(EB.COM.FINANCIAL.MNE) = "" THEN
        R.COMPANY(EB.COM.FINANCIAL.MNE) = R.COMPANY(EB.COM.MNEMONIC)
        R.COMPANY(EB.COM.FINANCIAL.COM) = CID
    END

RETURN
*
*-------------------------------------------------------------------------
*   E X I T   P R O G R A M
*-------------------------------------------------------------------------
FATAL.ERROR:
*
* If a fatal error has occurred, still set companies to ID.COMPANY
* as, if this program is being run as part of the release procedures,
* a fatal error will not cause the release to fall over.  (Normally the
* only error which could occur at this stage would be a missing pgm file
* file.  The release procedure would print this message as a warning).
*
    COMPANIES = ID.COMPANY

    MAT R.COMPANY = MAT SAVED.R.COMPANY

END
