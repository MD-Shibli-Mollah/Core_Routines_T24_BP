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
* <Rating>-38</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DW.BiExport
    SUBROUTINE DW.SAMPLE.TRANSFORM.API(DwFileName, dwID, dwRecord, isHeader)

*--------------------------------------------------------------
* Routine to transform data
*
* Author : yourname
* Date   : date of creation
*--------------------------------------------------------------
* Modification History:
*----------------------
*
*--------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DW.COMMON
    $INSERT I_DW.EXPORT.INFO.COMMON
    $INSERT I_F.DW.EXPORT
    $INSERT I_F.DW.EXPORT.PARAM
    $INSERT I_F.CUSTOMER
    $INSERT I_F.SECTOR

    GOSUB Initialise          ;*Initialise any local variables
    GOSUB ProcessData         ;*Process or transform the data
    RETURN

*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc>Initialise any local variables </desc>
    SEC.ID = ''
    R.SEC.RECORD = ''
    R.TR.RECORD = ''

    FN.TR.FILE.NAME = "F.":DwFileName
    F.TR.FILE.NAME = ''

    CALL OPF(FN.TR.FILE.NAME,F.TR.FILE.NAME)

    CALL F.READ(FN.TR.FILE.NAME, dwID, R.TR.RECORD, F.TR.FILE.NAME, ERR)

    SEC.ID = R.TR.RECORD<EB.CUS.SECTOR>

    FN.SEC.FILE.NAME = "F.SECTOR"
    F.SEC.FILE.NAME = ''

    CALL OPF(FN.SEC.FILE.NAME,F.SEC.FILE.NAME)

    CALL F.READ(FN.SEC.FILE.NAME,SEC.ID,R.SEC.RECORD,F.SEC.FILE.NAME,ER)

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= ProcessData>
ProcessData:
*** <desc>Process or transform the data </desc>

    IF isHeader THEN
        dwRecord := @FM:'SECTOR.DESCRIPTION':@FM:'TEST.FIELD.1':@FM:'TEST.FIELD.2'
    END ELSE
        fld.cnt = DCOUNT(dwRecord,FLD.SEP)
        no.of.flds = 3 ;* denotes how many fields to be added newly - here 3
        IF no.of.flds = 1 THEN
            fld.pos = fld.cnt
        END ELSE
            no.of.flds = no.of.flds-1
            fld.pos = fld.cnt-no.of.flds           
        END
        SHRT.DESC = R.SEC.RECORD<EB.SEC.DESCRIPTION>
        dwRecord<fld.pos> := SHRT.DESC
        dwRecord<fld.pos+1> := 'TEST.VALUE.1'
        dwRecord<fld.pos+2> := 'TEST.VALUE.2'

*        dwRecord := @FM:SHRT.DESC
    END
    RETURN
*** </region>

END
