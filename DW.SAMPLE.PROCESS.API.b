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
* <Rating>-60</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DW.BiExport
    SUBROUTINE DW.SAMPLE.PROCESS.API(biFileName, rDwExport, biRecordId, tRow)
*______________________________________________________________________________________
*
* Incoming Parameters:
* -------------------
*  biFileName   - Current processing file name like CURRENCY, CATEG.ENTRY
*  rDwExport    - Current file DW.EXPORT record
*  biRecordId   - Record id of the biFileName
*  tRow         - will null or HEADING
*                       'HEADING' will be passed when there is no field definition in FIELD.NAME of rDwExport
* Outgoing Parameters:
* --------------------
*  tRow         - in case if HEADING is passed, then
*                    <<Column_Headings>>:'~':<<rBiRecord_CSV_row>>{:'~':<<rBiRecord_CSV_row>>}
*               - in case null is passed, just read the record and pass it back
*                    <<rBiRecord_CSV_row>>{:'~':<<rBiRecord_CSV_row>>}
*
* Program Description:
* --------------------
*
*______________________________________________________________________________________
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DW.EXPORT.INFO.COMMON
    $INSERT I_F.COMPANY

*   /// Initialized to avoid undefined variable as it is used below, actually no need this since CO.CODE will be available in the respective record
    EQU XX.CO.CODE TO 10
*______________________________________________________________________________________
*

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

*______________________________________________________________________________________
*
INITIALISE:

    columnHead = ''
    recSeparator = ''

*       /// This area of code is optional, and this is dynamic way of building the columns' headings when there is no fields defined at FIELD.NAME
*       /// field in DW.EXPORT record for this file.
    IF tRow EQ 'HEADING' THEN

*       /// FLD.SEP is common variable defined in I_DW.EXPORT.INFO.COMMON, will always have field marker (@FM).

        columnHead = 'LEAD.CO.MNE':FLD.SEP:'BRANCH.CO.MNE':FLD.SEP:'MIS.DATE':FLD.SEP:'COL.HEADING1':FLD.SEP:'COL.HEADING2':FLD.SEP:'COL.HEADING3'
        columnHead := FLD.SEP:'COL.HEADING4':FLD.SEP:'COL.HEADING5'

*       /// recSeparator is local variable, to be used to separate the records if in case this process routine returns more than one record at a time, first time
*       /// this should be set to '~', since this returns heading and actual tRow record

        recSeparator = '~'

    END

*       /// If any files to be opened, should be opened here using the common variable FILE.OPENED, which will be having null value
*       /// when the first time process routine is called and there are dimensioned common variables viz., FN.BI.FILE and F.BI.FILE available
*       /// to hold the files opened here (FN.BI.FILE - actual file name, F.BI.FILE - holds file variable, physical file name)
*       /// This section of code will be called only once, and all the files opened here will be held in the two file variables.
    IF NOT(FILE.OPENED) THEN

        MAT FN.BI.FILE = ''
        MAT F.BI.FILE = ''

        FN.BI.FILE(1) = 'F.':biFileName
        F.BI.FILE(1) = ''
        CALL OPF(FN.BI.FILE(1), F.BI.FILE(1))

        FN.BI.FILE(1) = 'F.FILE1'
        F.BI.FILE(1) = ''
        CALL OPF(FN.BI.FILE(2), F.BI.FILE(2))

*       ...
*       ...
*       ...

        FN.BI.FILE(20) = 'F.FILE20'
        F.BI.FILE(20) = ''
        CALL OPF(FN.BI.FILE(20), F.BI.FILE(20))

    END

*    /// Just assign this to tRow,, so that for 1st time alone, tRow will be returned along with heading.
    tRow = columnHead

    RETURN
*______________________________________________________________________________________
*
PROCESS:
*-------

*   /// Just for example, we are using the biRecordId to read two files and combining them with FLD.SEP and return to DW.EXPORT to produce CSV

    rBiRecord1 = '' ; T.ER1 = ''
    CALL F.READ(FN.BI.FILE(1), biRecordId, rBiRecord1, F.BI.FILE(1), T.ER1)

    rBiRecord2 = '' ; T.ER2 = ''
    CALL F.READ(FN.BI.FILE(2), biRecordId, rBiRecord2, F.BI.FILE(2), T.ER2)

    IF T.ER1 OR T.ER2 THEN
*       /// Return without processing further if in case there is some error
        RETURN
    END

    IF rBiRecord1 AND rBiRecord2 THEN

*       /// Merging two records read here. in case you have formed the dynamic headings, then build the row dynamically from the records read, else
*       /// just read with biFileName and return as it is.
        rBiRecord = rBiRecord1:FLD.SEP:rBiRecord2

*       /// While returning tRow from process routine, it should always return with three default values Lead Company mnemonic (LEAD.MNE - common variable)
*       /// Branch company mnemonic(COMP.MNE - common variable, but can be changed internally to populate right company data in Multi book setup as below)
*       /// and MIS date on which the extract is done, this should always be last working day (MIS.DATE common variable)

        tBranchMne = COMP.MNE
        IF ID.COMPANY NE rBiRecord<XX.CO.CODE> THEN
            tCompanyId = rBiRecord<XX.CO.CODE>
            CALL CACHE.READ('F.COMPANY', tCompanyId, R.COMP, ER)
            tBranchMne = R.COMP<EB.COM.MNEMONIC>
        END

*       /// recSeparator should be re-assigned to '~' when you are return more than one record( i.e., more than one row in CSV file) from process routine.
        tRow := recSeparator:LEAD.MNE:FLD.SEP:tBranchMne:FLD.SEP:MIS.DATE       ;* appended LEAD.MNE, COMP.MNE, and MIS.DATE here

        tRow := FLD.SEP:rBiRecord                                               ;* append the actual record to be returned in tRow back to DW Export
    END

    RETURN
*______________________________________________________________________________________
*
END
