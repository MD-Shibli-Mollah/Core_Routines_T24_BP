* @ValidationCode : Mjo3NTU5OTM1MTQ6Q3AxMjUyOjE2MTkxNTgzMDc2NDg6YW1vbmlzaGE6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTA0LjI6LTE6LTE=
* @ValidationInfo : Timestamp         : 23 Apr 2021 11:41:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : amonisha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202104.2
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*------------------------------------------------------------------------------
* <Rating>14209</Rating>
*------------------------------------------------------------------------------
$PACKAGE EB.Upgrade
SUBROUTINE CREATE.INAU.RECORDS
*
*
* This program forms part of the EBS release procedure. It transfers
* records from live files in the release account to unauthorised files in
* the current account.
* The filenames and record names of the records to be released are stored
* in F.RELEASE.RECORDS.
* Any records that are overwritten in a data account are written to the
* file F.REPLACED.RECORDS with a record id FILENAME>RECORDNAME.
*
*  Any change in this routine interms of status of release record , may need
* change in T24.AUTHORISE routines also. For e.g: Authorisation can be ignored for
* 1. File records which are directly released to LIVE, 2. W,L type files etc.
*
* Modifications:-
*
* 07/06/91   to allow data items from company mnemonic files to be released.
*
* 23/06/91 - GB9100214
*            Correct syntax errors in code for 'company mnemonic' file processing
*
* 15/05/92 - GB9200445
*            Do not use EXECUTE DELETE for redundant history records as
*            this will hang when a select list is active.
*
* 10/02/93 - GB9300232
*            Do not use 'V' to determine position of audit fields. When a file is being converted
*            and data being released at the same time then V is incorrect.
*
* 27/05/93 - GB9300955
*            If the audit fields do not exist on the live record then default their positions from
*            the number of fields on the record + 9
*
* 03/03/94 - GB92001106
*            Release the BATCH records as IHLD not INAU.
*
* 06/04/94 - GB9400456
*            Don't fatal error if there is no COMPANY.CHECK
*
* 04/05/94 - GB9400593
*            Don't add audit fields to default enquiries if they have been input. Delete those without
*            audit fields
*
* 23/06/94 - GB9400827
*            If a batch record is being released, write out a record for each company dependent on the
*            level of the batch record as specified on the BATCH.NEW.COMPANY file. Also error found that
*            records are being written out for however many companies there are, regardless of the
*            classification of the file (eg if there are 10 companies, records on installation level files
*            are written out 10 times
*
* 06/07/94 - GB9400843
*            If records are released from F.CONVERSION.PGMS, update the companies to run in field to the
*            companies from the release site (according to the program level), update the run pgm flag to
*            1 - pgm is to be run and the run status to null - pgm has not yet been run
*
* 07/07/94 - GB9400856
*            When releasing new batch records, default next run date according to batch stage and frequency.
*            Also when existing records are released, the following information will be copied from the live
*            record: default printer, batch environment, department code, next run date, last run date and
*            printer name. Also, release the records as INAU rather than IHLD, unless "data" is different
*            between the live and the released record. Also, open F.COMPANY.CHECK in the current account
*            rather the release account (appears no reason why this was being done).
*
* 16/09/94 - GB9301510
*            If releasing records to F.ASCII.VALUES file or id starts "STANDARD" and releasing to the
*            F.ASCII.VALU.TABLES file, release to the live file, rather than the unauthorised file.
*
* 16/09/94 - GB9401048
*            If releasing records to F.CONVERSION.PGMS which have been released on a previous release
*            of GLOBUS, copy the information from the live record if for any of the programs
*            which have previously been run
*
* 03/08/94 - GB9400926
*            F.RELEASE.DATA contains all the data records to be released.  The list of items to be
*            released is now held in a select list which is passed as a parameter. Data records are
*            stored with a key of filename>recordname. e.g.  F.BATCH>AC.END.OF.DAY. Also change E.TEXT
*            to E so that GLOBUS.RELEASE can pick up any error messages should they occur
*
* 07/10/94 - GB9401118
*            Do not use the COMMON R.USER, read the record as we may have release problems
*
* 01/11/94 - GB9401201
*            Do not cause a fatal error if pgm.file records are missing when releasing records
*            to F.CONVERSION.PGMS
*
* 24/01/95 - GB9400926
*            If releasing records to F.STANDARD.SELECTION, copy the user fields from the live record
*
* 01/05/95 - GB9500312
*            If releasing records to F.ARCHIVE, copy the run details fields from the live record
*            and clear the purge date
*
* 07/08/95 - GB9500908
*            Do not use R.USER to test whether the program is being run from within GLOBUS, since,
*            if the current release is before G6, R.USER will be a dimensioned array, but if the current
*            release is G6, R.USER will be a dynamic array
*
* 25/10/95 - GB9501248
*            Open F.REPLACED.RECORDS after it has been created if it did not already exist
*
* 07/12/95 - GB9501442
*            Error finding position of authoriser when releasing to type W files. Error also in that
*            building dynamic arrays from dimensioned arrays causes the dynamic array to be built with
*            the wrong number of fields if the last field was null
*
* 15/02/96 - GB9600186
*            Clear down the run information field in PGM.FILE records
*
* 11/04/96 - GB9600432
*            When releasing standard selection records, the user fields on new records are not being
*            cleared down (for existing records, the user fields are copied from the live record)
*            Also when releasing batch records with a new job with frequency "M", the next run date is
*            being set to the next month end date, rather than the current month end date
*
* 07/05/96 - GB9600580
*            Release HELPTEXT records to the live file, if the record is not present on the live file or
*            if the record on the live file has not been amended (i.e. it is the original record as released
*            by the release procedures) NOTE: The Helptext concat files (HELPTEXT.INDEX and HELPTEXT.TITLE
*            are rebuilt by REBUILD.HELPTEXT.INDEX, which is called from PERFORM.GLOBUS.RELEASE, at the end of the
*            release process.
*
* 28/06/96 - GB9600875
*            If the inputter on the live HELPTEXT record is null, write the released record to the live file
*            (i.e. assume the live record was originally converted from existing helptext files)
*
* 22/07/96 - GB9600979
*            If records are being released from the CONVERSION.DETAILS file then null the run history fields.
*            If the record exists on the live file then then copy the run history.  Also remove the clearing of
*            the RUN.INFO field on the PGM.FILE as this field no longer exists.
*
* 26/07/96 - GB9601042
*            When DE.MAPPING records are released the ROUTINE field should be cleared on the released record
*            and the ROUTINE copied from the live record.
*
* 29/07/96 - GB9601056
*            When Releasing Records with SY as the terminal number in the Authoriser field the 'system fields' get
*            set in the wrong place as the Else processing takes place in the Determine.V paragraph.
*
* 29/08/96 - GB9601205
*            When updating the ROUTINE field on DE.MAPPING records, ensure that only records in G7.0.07 or beyond
*            format are updated (record being released and existing live record)
*
* 03/09/96 - GB9601226
*            When releasing CONVERSION.PGMS records, if the product is not installed, set the RUN flag to 0 - not
*            to be run.  If record is being re-released, copy the details from the live record if the RUN flag is
*            0 (currently only copies details if the program has already been run). Also, if the companies
*            selected was previously null and are now present (product has been installed since last release),
*            set the RUN flag to 0.
*
* 19/09/96 - GB9601307
*            If the program is being called from DL.DEFINE (i.e. the release number and list name is DL.RESTORE),
*            write the records to the unauthorised file as IHLD.
*
* 28/11/96 - GB9601675
*            The overrides field is being set to numerous occurrences of null - shouldn't be updated for existing
*            records; set to null for new records
*
* 24/12/96 - GB9601782
*            If being called from DL.DEFINE.RUN (the data library restore), write PGM.FILE and HELPTEXT records to
*            the unauthorised file
*
* 27/02/98 - GB9800115
*            If releasing DB.SCRAMBLE.DEFINE records, copy the run information from the live record
*
* 11/06/98 - GB9800692
*            Check that $NAU is specified on the file control record before opening the $NAU file
*
* 04/08/98 - GB9800999
*            Do not release the run detail fields in EU.CONVERSION.PARAM
*
* 02/09/98 - GB9801071
*            Cater for multi entity processing environment. Check if part of a GAC account.
*
* 12/01/99 - GB9900040
*            Need to clear out and copy the company field as well.
*
* 02/03/99 - GB9900310
*            When checking for the occurrence of the inputter field, check that just the first value matches
*            (this field is now multi-valued)
*
* 13/07/99 - GB9900939
*            When selecting the companies for which to release batch records, consolidation and reporting
*            companies should be ignored.
*
* 21/02/00 - GB0000243
*          - Clear out unwanted data in certain fields on the OVERRIDE
*          - file before transferring to the client site. PJG.
*
* 21/06/00 - GB0001546
*            Clear CLASS.ID from EB.MESSAGE.CLASS.
*
* 19/04/01 - GB0101100
*            VOC records were not being released correctly (gave a fatal error - missing FILE.CONTROL record)
* 10/10/01 - GLOBUS_CI_10000375
*            CSS reference:  AM0100137 DE.MAPPING field DE.MAP.ROUTINE was being emptied when application DL.DEFINE
*            Verify function in RESTORE mode calls CREATE.INAU.RECORDS.  Stop this field from being emptied by the
*            DL.DEFINE application by checking RELEASE.NO for "DL.RESTORE"
*
* 26/09/02 - GLOBUS_EN_10001244
*            To handle the user defined fields in Message and Mapping. When the message and mapping files are being
*            upgraded, read the corresponding records on the clients live file and copy what's in their user fields
*            to the user field of the record being upgraded
*
* 21/10/02 - GLOBUS_EN_10001430
*          Conversion Of all Error Messages to Error Codes

* 28/10/02 - BG_100002577
*            Variable master undefined.
*
* 25/11/02 -  CI_10004888
*             Clear the user fields in F.STANDARD.SELECTION in COPY.RECORDS only when RELEASE.NO NE 'DL.RESTORE'.
*             Similarly copy the  user fields inthe LIVE record to RELEASE record only when RELEASE.NO
*              NE 'DL.RESTORE'.
* 19/12/02 - GLOBUS_BG_100003039
*            Release EB.ERROR records to $NAU file only if live records exits otherwise release the records to live.
*
* 27/12/02 - GLOBUS_CI_10005891
*            DL.DEFINE does not restore properly when records are created via OFS with RUN.MODE as PHANTOM
*
* 28/02/03 - GLOBUS_BG_100003666
*            Conversion of '$' to '_' in routine name.
*
* 28/02/03 - BG_100003656
*            Process status of online batch records should have a status 2 during release.
*
* 03/03/03 - BG_100003688
*            Corrections have been made to the changes done under the Change Document : BG_100003656
*
* 24/03/03 - BG_100003868
*            Conversion Problem with EB.ERROR fixed.
*
* 14/04/03 - BG_100004045
*            Create unauthorised records only if the live record and the released record is different
*
* 28/05/03 - GLOBUS_BG_100004305
*            Bug(qualified release number) fixes for Service Pack installation. While installing the service pack,
*            the service pack name should be formed by stripping the qualified rel no. 07 from SPG130072003050.
*
* 04/06/03 - GLOBUS_BG_100004358
*            Conversion "$" & "_"  to "."  in routine name. (overwrite/ignore the previous conversion of  "$" to "_").
*            This is to ensure that routines will compile and work in jBASE 4.1 and on non ASCII platforms.
*
* 13/06/03 - BG_100004481
*            Corrections in SP name modifications done under BG_100004305
*
* 29/07/03 - EN_10001891
*            All batch records to be released in status zero now
*
* 14/08/03 - CI_10011738
*            Override table details should retain when DL.DEFINE restore is done for a record.
*
* 20/10/03 - CI_10013836
*            The User fields from DE.MAPPING and DE.MESSAGE are not updated properly thru DL.DEFINE.
*
* 14/11/03 - CI_10014801
*            While releasing the DFP records, language component of the id must be checked with LANGUAGE table.
*            The common variable T.LANGUAGE contains mnemonics of all languages.
*
* 24/02/04 - BG_100006322
*            In int subroutine DELETE.HISTORY.RECORDS removed SELECT of $HIS records and replaced with read/deletes
*
*
* 12/04/04 - CI_10018949
*            The values of certain fields in OVERRIDE record need not be retained
*            when a live file exists in the target area while doing a DL.RESTORE.
*
* 25/05/04 - GLOBUS_BG_100007314
*            Code Review changes to core routines
*
* 28/09/04 - BG_100007315
*            Changes done in the method of releasing the online TSA.SERVICE records
*            1. Just like releasing the batch record check for the batch.new.company
*            and multi-company setup and release it accordingly.
*            2. If no previous live record exists release the service record in IHLD status.
*
* 29/12/04 - CI_10025932
*            Copy the user fields of DE.MAPPING and DE.MESSAGE while upgrading if only the release is greater
*            than or equal to 13.1 since the user fields are released only in 13.1
*
* 25/02/05 - CI_10027793
*            Don't load R.COMPANY if CONSOLIDATION.MARK is not set to "N".
*
* 14/11/05 - CI_10036412
*            Convert ALL in the USER profile to valid list of companies even if
*            GAC is not installed.
*            Ref:HD0514851
*
* 21/02/06 - CI_10039168
*            DL.DEFINE problem when record has a prefix already
*
* 14/02/07 - GLOBUS_BG_100012999
*            extend field length for list name to all for sar references
*            use in dim.test.cds
*
* 09/03/07 - EN_10003192
*            DAS Implementation
*
* 21/06/07 - BG_100014340
*            Changes done to populate the fields FINANCIAL.MNE, FINIANCIAL.COM
*            in R.COMPANY common variable, when it is null. This will solve
*            the crash while doing GLOBUS.RELEASE in upgrading from lower release
*            to higher release, before running the actual converison to
*            populate FINANCIAL.MNE/COM in COMPANY record.
*
* 29/06/07 - BG_100014449
*            Clear out few fields before releasing the TSA.SERVICE record.
*
* 28/08/07 - CI_10051067
*            The contents of the 'user' fields on DE.MAPPING records do not get
*            transferred to the new release records when upgrading from R5.009.
*
* 27/09/07 - CI_10051588
*            Additional fix for the above CD CI_10051067.
*
* 06/12/07 - CI_10052806
*            DL.DEFINE  does not update the correct company code
*
* 19/02/08 - BG_100017190
*            New RELEASE.NO T24.PRE.RELEASE added and a call is made to T24.PRE.RELEASE
*            to release TSM,T24.UPGRADE and their corresponding batch records
*            for running upgrade as service.
*
* 10/03/08 - CI_10053968
*            Prb - Unable to list FIN file exception records - CO.CODE updated wrongly.
*            Changes done to update Master Company in CO.CODE for INT level files
*            and to update individual Company codes for other files.
*
* 30/05/08 - CI_10055747
*            In REPORT.CONTROL application the value in the field REPORT.RETENTION is
*            not transferred to the restoring area throughDL.DEFINE
*            REF:HD0811684
* 12/05/08 - GLOBUS_EN_10003667
*                  Preparation of T24 Update for a particular module and cumulative Product
*                  Increase the length of the LIST.NAME input field.
*                  Ref:SAR-2008-01-17-0017.
*
* 13/03/08 - BG_100017107
*            CAN'T OPEN filename Error messages are seen while running GLOBUS.RELEASE
*            when records for CUS, FRP, FIN type are released from CORE.
*            Ref:TTS0800247
*  11/12/08 - CI_10059400
*             DL.DEFINE restores the COB record in TSA.SERVICE prefixed
*             with company mnemonic.
*
* 08/01/09 - BG_100021539
*            Uninitialised variable RELEASE.TO.LIVE.FILES used during upgrade.
*            Ref :TTS0804287
* 21/02/09 - CI_10060827(HD0904382)
*            PGM.FILE to be released into Live record through DL.DEFINE.
*
* 21/02/09 - BG_100022272
*            Error raised  during upgrade due product not installed in the system
*            REF:TTS0804717
*            When file control of filename doesn't exist then start releasing records of
*            Next file.
*
* 07/03/09 - BG_100022527
*            Update Release Changes
*
* 09/03/09 - BG_100022531
*            Revert the changes on the cd "BG_100022527"
*
* 11/03/09 - BG_100022535
*            The service record RUN.CONVERSION also to be released during T24.PRE.RELEASE
*            especially while upgrading from lower releases(say G12).
*            The service status for this should be 'STOP' while releasing
*
* 21/05/09 - BG_100023717
*            TSA.SERVICE records for SC.GRP.ORD.SERVICE released with non-existent user
*            Ref:TTS0907481
*
* 09/09/09 - BG_100025103
*            If the filename is "F.SY.PRODUCT.DEFINITION" then releases the corresponding
*            records to "IHLD" status during the upgrade.
*            TTS Ref:TTS0909313
*
* 12/10/09 - EN_10004355
*            Introduce a New routine CREATE.INAU.RECORDS.INITIALISE to load the basic common
*            variables and Records need to be released in "IHLD" status when ADDITIONAL.INFO
*            of corresponding PGM.RECORD mentioned as ".HLD"
*
* 20/10/09 - BG_100025540
*            Needs to read PGM.FILE from F.RELEASE.DATA for T24.UPGRADE service
*
* 13/04/10 - Task - 40078
*            Release the T24.UPDATE.RELEASE record to live
*
* 22/04/10 - 24343
*            Enhance EB.DICTIONARY, VERSION and ENQUIRY to support Model Bank Translation
*            To release EB.DICTIONARY in live files.
*
* 11/08/10 - Task - 75585 (Defect:49218)
*            Release EB.ERROR records in IHLD during DL.DEFINE, when Additional.Info
*            field is set to .HLD in PGM.FILE.
*
* 29/11/10 - Task:113483/Defect:110599
*            Unable to release the data records during updates installation if the length of the
*            update name exceeds 30 characters.
*
* 13/01/11 - Task - 129287
*            Release new records from PS.CONTEXT.LINK ,PS.QUERY ,PS.QUERY.VIEW to LIVE file directly
*            and amended records to NAU file.
*
* 24/02/11 - Task:160047(Defect:114307)
*            Unable to perform DL.RESTORE from BROWSER
*
* 02/06/11 - Task - 222553 (Defect 210740)
*            TSA.SERVICE records are not released properly while Upgrading from lower releases(below R08),
*            If case of the TEMP.RELEASE data records having below R08 field layout.
*            To avoid the mismatch, Field numbers are used instead of the Insert file as like Conversion process.
*
* 22/06/11 - Task - 231140 / Ref Enhancement - 222258
*            While restoring the records from DL.DEFINE application, records should be released as follows
*               a) Records should be released to the company specified in the COMP.TO.RESTORE field of DL.DEFINE application.
*               b) Follows normal release procedure if there is no company specified in the COMP.TO.RESTORE field.
*
* 01/08/11 - Task : 253832 / Ref Defect : 249777
*            When the new batch records are released, system should nullify the LAST.RUN.DATE field
*            of the batch record
*
* 11/11/11 - Task -307192 , Defect - 184935
*            To release all NEO records (like PS.QUERY etc) directly in LIVE.  Exception is to release only the amended records in INAU when 'NE' product is installed.
*
* 5/12/2011 - Defect:319230/Task:319244
*            Varibale initialized to avoid uninitialized variable error during T24.PRE.RELEASE.
*
* 11/1/2012 - Defect: 336856/Task:337473
*           While releasing OFS.SOURCE record, current OPERATOR should be defaulted in GENERIC.USER field.
*
* 24/01/2012 - Defect: 344653/Task:344658
*              EB.COMPONENT records need to be released in LIVE status directly even if the record exists in system
*
* 23/01/13 - Task : 566155 / Ref Story : 566161
*            Upgrade process in TAFJ platform
*
* 28/03/13 - Task : 635477 / Ref Defect : 619266
*            DE.MAPPING records should be released with values in MAP.ROUTINE fields
*
* 13/08/2013 - Task 753902 / Defect 729461
*            Records released via DL.DEFINE restoration & updates installation gets stored in
*            F.RELEASED.RECORDS.
*
* 13/12/2013 - Task : 862304
*             New Local reference fields introdcued for an application will be added at the bottom of LOCAL.REF.TABLE instead of replacing the entire record
*             When existing LOCAL.REF.TABLE is modified. Revised the insert file name
*
*  07/02/14   Task : 735160
*             Defect : 735156
*             Install changeset operation for windows
* 10/03/14    Task :935971
*             Defect : 935965
*            Reversing code for Install changeset operation for windows
*
* 25/03/14    Task :950977
*             Existing local reference should be ignored when the same local reference being released again in LOCAL.REF.TABLE
*
* 26/03/14 - Task : 951562 / Defect : 942448
*            INT file data records should always be released with respect to the master company record,
*            irrespective of the previous company record used to release FIN/CUS type data records.
*
* 14/09/13 - Task 768705 / EN-596458
*            Populate list of released records for upgrade also.
*
* 13/08/14 - Task 1085605 / Defect 1071587
*            NUMERIC.ID is calculated from F.LOCKING to update unique NUMERIC.ID
*            in EB.ERROR and OVERRIDE application
*
* 28/10/14 - Task 1151829 / SI 990544
*            Duplicate common variables re-pharse.
*
* 6/11/14  - Task 1160732
*            Enabling release mechanism to accept the Local hook routine change for the records
*            released via release mechanism. The core standard always can override the local change.
*
* 15/11/14 - Task 1169641 / Defect 1169598
*            correction for the fix 1160732.
*
* 16/02/15 - Task 1256472 / Defect : 1247613
*            Authoriser pattern must be checked in every DE.MESSAGE record before clearing 12 to 16 fields
*
* 13/02/15 - Task 1254130 / Defect 1245175
*            Release batch records for companies having CONSOLIDATION.MARK set as "A".
*
* 18/09/14 - Task 1270333 / Defect : 657208
*            Released EB.PRODUCT file into LIVE status.
*
* 20/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().
* 27/04/15 - Enhancement:1257342 / Task: 1329484
*            Special process for releasing TPS data records.
*
* 11/6/2015 - Defect:1365076 / Task:1374825
*             ASCII.VALUES need not be released to LIVE file as it overwrites all the user defined set up (overwrites APPLICATION, APP.VALUE.TBL etc field contents).
*
* 29/07/15  - Defect:1410813 / Task:1422783
*             TSA.SERVICE records are released properly using DL.DEFINE Pack.
*
* 10/09/15 - Task 1465231 / Defect : 1459230
*            Check that $HIS is specified on the file control record before opening the $HIS file
*
* 22/09/15 - Task 1422796 / Enhancement 1276655
*            1. Errors/warnings can be routed to TAF log.
*            2. CONVERSION.PGMS records can be released to LIVE file (except DL.RESTORE) if SPF>AUTO.UPGRADE=YES.
*            3. New TSA.SERVICE records can be released to INAU file with USER details populated from TSA.SERVICE>TSM record.
*
* 24/03/16 - Task 1675406 / Defect 1660994
*              In case it is a model data record released, append '_C' to inputter audit field
*
* 28/03/16 - Task 1678085 / Defect 1659991
*            If DAO id in release record is not found, DAO of user running the service is updated
*
* 30/03/16 - Task 1680740 / Defect 1674260
*             Facility to manage records contains dates in the ID during packageDataInstaller
*
* 06/04/16 - Task -1688782 / Defect 1674260
*               Addressing the compilation issue in TAFC
*
* 08/04/16 - Task 1714754 / Defect 1710004
*            Don't clear the User fields for T24.MODEL.PACKAGES installation done through packageDataInstaller
*
* 22/09/16 - Task 1867625 / Defect 1848765
*            Check file control classification before opening files in all companies
*
* 27/10/16 - Task 1905749 / Defect 1903678
*            FTF file type records are released properly
*
* 16/11/16 - Task 1926669 / Defect 1917956
*            Release the data records to LIVE file when installation done through packageDataInstaller
*
* 23/11/16 - Task 1934583 / Defect 1932828
*            While releasing BCON packages, audit fields are updated with correct values for W type files
*
* 24/11/16 - Task 1933909 / Defect 1920519
*            Records which have been auditted are released properly
*
* 23/12/16 - Task : 1962528 / Defect : 1960484
*            If the data records gets released through T24.MODEL.PACKAGES, the User fields for the application
*            DE.MESSAGE, DE.MAAPING and SS should not gets cleared.
*
* 10/01/17 - Task 1980749 / Defect 1980739
*            Reversing changes done as part of the defect 1917956
*
* 30/01/17 - Task : 2002688 / Defect : 1998721
*            If the data records gets released through T24.MODEL.PACKAGES, the fields of the application
*            OVERRIDE should not gets cleared.
*
* 19/01/17 - Task : 2013559
*            Physical order arrays returned from template and V = AUDIT.DATE.TIME
*            Table.endOfRecord can be used to identify record end position.
*            Record being released from temp.release can have data after audit fields if that application has neighbour fields inputted.
*            Audit position of record should be identified based on its F array.
*
* 17/04/17 - Task 2091595 / Defect 2090410
*            Correction for the fix done via defect 1848765. Corresponding company id to be updated in released records.
*
* 20/04/2017 - Task 2093742: Coding - Refactoring for CREATE.INAU.RECORDS fix done via task 2013559 and 2091595
*            Set V value if auditPos value exist for neighbour field feature.
*
* 29/05/2017 - Task 2138898/ Defect 2134926
*            - The existing Local reference fields introdcued for an application,
*              will be added at the bottom of LOCAL.REF.TABLE instead of replacing.
*
* 05/06/2017 - Task 2147326 / Defect 2135693
*            - FIN file (data record) has released wrongly in the Branch Company instead of Lead.
*
* 22/06/2017 - Task 2169570 / Defect 2169568
*            - Looping condition is infinite, to release the LRT record.
*
* 07/07/2017 - Task 2187381 / Defect 2186631
*              Date change service not to be prefixed with company mnemonic
*
*
* 15/09/2017    - Enhancement 2236780/ Task 2271738
*                System to trigger hook routine from EB.DATA.RELEASE.API.TABLE
*
* 25/09/2017    - Defect 2281031/ Task 2283569
*               - TAFC Compilation issue
*
* 26/10/17 - Task  2321034/ Defect 2316420
*            Correction for the fix done in defect 1848765. The DL.DEFINE should release data records to specific company as per COMP.TO.RELEASE field value.
*
* 09/02/18 - Task 2455348 / Enhancement 2448125
*            Data release mechanism to release coutry specific records
*
* 07/03/2018  - Task 2492274 / Defect 2454658
*             - System has support to release .d(data) record for specific company via PackageInstaller
* 09/03/18 - Task 2493574
*            Restructure data records before releasing it into original table in t24 system.
*            The data record will not get released in case it falls under obsolete criteria defined in T24.TABLE.RESTRUCTURE
*            for that table.
*
* 19/03/2018 - Task 2507651 / Enhancement 2504152
*              Release mechanism changes for CZ PDD data definition records
*              To cater to the need of releasing only relevant fields of CZ.CDP.DATA.DEFINITION record.
*
* 22/03/2018 - Task 2516375
*              T24.TABLE.RESTRUCTURE records released through T24.PRE.RELEASE for offline upgrade should set
*              RESTRUCTURE.STATUS=READY. For any correction on already existing T24.TABLE.RESTRUCTURE records
*              released to NAU via updates and status will be changed to READY during authorisation for clients.
*
* 20/03/2018 - Enhancement : 2473496 / Task : 2551009
*              Read and install .d records from table(F.DS.RELEASE.DATA) instead of directory(UD) for dspackage
*              server deployment using the common variable DeployInServer.
*
* 31/05/2018 - Task - 2611336
*              Reversal of task 2493574.
*              Data records released through t24 release mechanism need not require restructure as it is expected
*              latest data in temp release pack if there is any restructure definition added for that particular table in that build.
*
* 19/09/2018 - Defect - 2766798/Task - 2774354
*              changes to restore the values of LRT to language records.
*
* 26/09/2018 - Task 2781023
*              TSA.SERVICE records should be released to INAU during T24.UPGRADE.PRIMARY service as part of online upgrade is in progress.
*              So that T24.AUTHORISE can authorise this record.
*
* 07/02/19 - Defect - 2978755 / Task - 2980619
*              GENERIC.USER field value in the OFS.SOURCE should get update with value, which is present in the DS package.
*
* 08/02/19 - Enhancement 2822523 / Task 2909926
*            Incorporation of EB_Upgrade component
*
* 26/02/19 - Task 3008257 / Defect 3008094
*            Data records having ">" in the id are not released
*
* 08/03/19 - Task 3026684 / Defect 3026620
*            AA.CLASS.TYPE records should be loaded to live file during Upgrade process
*
* 21/03/19 - Task 3046572 / Defect 3046563
*             Handling release for infinity components
*
* 10/04/19 - Task: 3079358
*            Based on the newly added ADDITIONAL.MODULE field in PDC, we ignore records for the below condition
*            1)if PDC indicates an additional module but the record ID has a different module or no module at all
*
*
* 18/04/19 - Task 3094284
*            Correction for the fix done in 3079358.During the release of the BATCH record,
*            ensure the mnemonic of the company is not repeatedly added to the record ID
*
* 19/04/19 - Task 3094656
*          - Correction for the fix done in 3079358
*
* 24/04/19 - Defect: 3099257 / Task: 3099157
*            Data records without PDC must be released when they come via a package and not skipped
*
* 28/3/19 - Task 3058770
*           Load the PDD records only if CZ installed
*
* 30/5/19 - Task 3155967
*           F.RELEASED.RECORDS id affected due to fix from 3079358
*           Its id should be from RECORD.ID which was released to the table.
*
* 20/06/19 - Defect: 3185139 / Task: 3187886
*            Don not release record or log the error if the record is obsolete.
*
* 21/06/19 - Task 3189504 / Defect 3187860
*            Record status of amendment BATCH records released via primary upgrade service as a part of online upgrade
*            should be set as INAU.
*
* 05/07/19 - Task 3214710 / Defect 3214507
*            Post Upgrade batch to be released in Live instead of INAU
*
* 11/07/19 - Task 3224462 / Defect 3224384
*            EB.SYSGEN.DATA.CONTROL records should be loaded to live file during Upgrade process
*
* 19/07/19 - Task 3239698
*            Post Upgrade service and workload profile to be released in Live instead of INAU
*
* 19/07/19 - Task 3233211 / Enhancement 3218630
*            Load the sub modules list in the company variable if the product code present in the company record
*
* 25/07/2019 - Enhancement:2964763 / Task: 3193551
*              To include product in the audit section.
*
* 28/07/19 - Task 3252803
*            Post Upgrade batch to be released in Live instead of INAU
*
* 02/08/19 - Task 3268149 / Defect 3267763
*           Do not clear the user field of SS record when deployed via packager
*
* 25/07/19 - Task 3246438 / Defect 3247630
*            Handling the release of EM records
*
* 20/08/19 - Task 3295264 / Defect 3247630
*             Handling release for infinity components
*
* 06/11/19 - Task 3421752 / Defect 3421745
*             Removed Clearing tmp as we no need to select and clear a file.
*
* 16/12/19 - Task : 3489674 / Enhancement : 3433147
*            EB.MERGE.RELEASE.RECORD api called to retain client owned fields
*            configured in EB.ACCESS.PARAMETER
*
* 17/12/19 - Task 3493316 / Defect 3490652
*            If the NOFILE SS data record gets released through T24.MODEL.PACKAGES, RELEASE.RECORD will overwrite the LIVE record
*            The Final record will be the one released through package installer.
*
* 02/01/2020 - Task 3510217 / Defect 3505483
*              Merging Usr fields of SS for Release
*
* 22/01/2020 - Task 3548710 / Defect 3505483
*              Release T24.UXPB.COS in live
*
* 26/01/2020 - Task 3555938 / Defect 3505483
*              Retain the frequency from LIVE file for BATCH
*
* 12/02/2020 - Enhancement : 3523195 / Task : 3564346
*              Convert the JSON content into DataArray format.
*
* 04/03/2020 - Enhancement : 3523195 / Task : 3622407
*              Convert the JSON content into DataArray format.
*
* 09/03/2020 - Defect : 3626861 / Task : 3630320
*              Code Reversal of tasks - 3268149 and 3510217
*
* 18/03/2020 - Defect : 3643078 / Task : 3647400
*              Model Bank to R20AMR upgrade,we got authorization failure
*
* 03/04/2020 - Defect : 3626861 / Task : 3675504
*              fix for .d file Installation issue
*
* 13/04/2020 - Task 3689893 / Enhancement 3636658
*              If it is a zerobase product installation then update the audit section as 1_ZEROBASE in inputter
*
* 14/04/2020 - Defect 3626861 / Task 3691918
*              Allow release of split module records during Upgrade and Updates
*
* 14/04/2020 - Task: 3693123
*              Do not release ## records for base bank
*
* 20/04/2020 - Task: 3701490 / Defect: 3698403
*              Release RR.PARAM records for specific companies in which the ID application exists
*              Facility to check multiple product Installation in PDC
*
* 23/04/2020 - Task: 3708966 / Defect: 3701541
*              Split Module Issue in BATCH and TSA.SERVICE records
*
* 29/04/2020 - Task: 3719593
*              Release original records in the base bank environment irrespective of the availability of additional module
*
* 04/05/2020 - Task: 3726682 / Defect: 3726163
*              The variable CHECK.ADD.INFO cleared for each record process.
*
* 18/05/2020 - Task: 3752604 / Defect: 3752760
*              Date change is not happened for PP.CONTRACT records during .json upgrade.
*
* 15/06/2020 - Task: 3802481 / Defect: 3626861
*              Populate the associated multi value set fields using BAT.JOB.NAME for Batch records.
*
* 16/06/2020 - Task: 3804816 / Defect: 3626861
*              Calculate COB.STAGE.SEQ field for Batch records in CIR.
*
* 01/07/20 - Defect 3626861 / Task 3832596
*            Handling SYSTEM.VARIABLES in @ID of the application through json.
*
* 16/06/2020 - Task: 3712098
*              Allow more than one additional module. If at least one additional module is installed, do not release core record.
*
* 13/07/2020 - Enhancement : 3852722 / Task : 3852724
*              Release of records in IHLD via CREATE.INAU.RECORDS for JSON.
*
* 25/07/2020 - Task: 3876140
*              Releasing country specific records with several companies excluded
*
* 07/08/2020 - Task: 3899608 / Defect: 3900627
*              LRT release issue for PP.ORDER.ENTRY
*
* 19/08/2020 - Task: 3920749 / Defect: 3920655
*              Exclude the T24.FULL.UPGRADE service also for release.
*
*
* 26/08/2020 - Task: 3933071 / Defect: 3626861
*              Don't do the access parameter based merge if it is TMNS license.
*
* 18/08/2020 - Task 3898947
*              EB.MDAL.ENTITIES new records can be released in live. Amendment records can be released in INAU.
*
* 06/10/2020 - Task: 4004705 / Defect: 3626861
*              Ensure the SERVICE.CONTROL field as STOP status while deploying new TSA.SERVICE records.
*
* 21/10/20 - Task 4036053 / Defect 3626861
*            Company wise change the SYSTEM.VARIABLE value
*
* 14/12/2020 - Defect: 4123549 / Task: 4131380
*              Exclude Module definition in BATCH.NEW.COMPANY
*
* 12/01/2021 - Defect: 3626861 / Task: 4176110
*              Handling the DISABLE.NEW.RECORD error by adding _JSN in INPUTTER field.

* 20/01/21 - Task 4024187 / Enhancement 3915996
*            If there is a locking record for COMPANY.CREATE then call EBS.CREATE.FILE to release files.
*
* 12/02/21 - Task 4064337
*            Handling the release of EB.ADVICES records.
*
* 03/03/21 - Task 4262496 / Defect 3626861
*            Handling the BATCH.STAGE field in BATCH records.
*
* 26/03/21 - Enhancement 4280334 / Task 4300357
*            EB.TRANSACT.STANDARDS records need to be released in LIVE status directly.
*
* 26/03/21 - Enhancement 4280334 / Task 4298904
*            L3 cannot install new Batch records or new jobs , with BATCH.STAGES defined in it.
*
* 01/04/21 - Defect 3626861 / Task 4318059
*            Release country specific records in respective company.
*
* 22/04/2021 - Task 4346940
*              Release ONLINE.SERVICE to corresponding COB company groups along with the original TSA.SERVICE record.
*
************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_SCREEN.VARIABLES
    $INSERT I_F.USER
    $INSERT I_F.ARCHIVE
    $INSERT I_F.BATCH
    $INSERT I_F.BATCH.NEW.COMPANY
    $INSERT I_F.CONVERSION.PGMS
    $INSERT I_F.DATES
    $INSERT I_F.REPORT.CONTROL
    $INSERT I_F.REPGEN.CREATE
    $INSERT I_F.REPGEN.SORT
    $INSERT I_F.REPGEN.OUTPUT
    $INSERT I_F.SPF
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_F.FILE.CONTROL
    $INSERT I_F.COMPANY.CHECK
    $INSERT I_F.COMPANY
    $INSERT I_F.ENQUIRY
    $INSERT I_F.PGM.FILE
    $INSERT I_F.CONVERSION.DETAILS
    $INSERT I_F.DE.MAPPING
    $INSERT I_F.DB.SCRAMBLE.DEFINE
    $INSERT I_F.EU.CONVERSION.PARAM
    $INSERT I_F.OVERRIDE
    $INSERT I_F.EB.MESSAGE.CLASS
    $INSERT I_F.DE.MESSAGE
    $INSERT I_F.PGM.DATA.CONTROL
    $INSERT I_F.TSA.SERVICE
    $INSERT I_DAS.COMMON
    $INSERT I_DAS.COMPANY
    $INSERT I_F.OFS.SOURCE
    $INSERT I_TSA.COMMON
    $INSERT I_F.LOCAL.REF.TABLE
    $INSERT I_F.EB.ERROR
    $INSERT JBC.h
    $INSERT I_Table
    $INSERT I_F.CZ.CDP.DATA.DEFINITION ;* add insert to get the values from CZ.CDP.DATA.DEFINITION
    $INSERT I_EB.RELEASE.ESON.DS.IF
    $INSERT I_F.LANGUAGE
    $INSERT I_BATCH.FILES
    $INSERT I_GTS.COMMON
    $INSERT I_JSON.COMMON
    $INSERT I_F.SYSGEN
    $INSERT I_F.TSA.PARAMETER
    
    
    $USING EB.Upgrade
    
* Save contents of R.COMPANY in case they are used by any subsequent programs.  R.COMPANY will be
* updated if any batch records are released.  It will be reset after FINISH
*
    tmp = ''
    DIM R.SAVED.COMPANY(EB.COM.AUDIT.DATE.TIME)
    MAT R.SAVED.COMPANY = MAT R.COMPANY
    DIM R.COMPANY.CHK(EB.COM.AUDIT.DATE.TIME)
    MAT R.COMPANY.CHK = ''

    RELEASE.TO.LIVE.FILES = "F.EB.ERROR":@VM:"F.EB.SUB.PRODUCT":@VM:"F.EB.COMPONENT":@VM:"F.T24.UPDATE.RELEASE":@VM:"F.EB.DICTIONARY":@VM:"F.EB.PRODUCT":@VM:"F.DSL.MODEL.SOURCE":@VM:"F.EB.DATA.RELEASE.API.TABLE":@VM:"F.EB.SYSGEN.DATA.CONTROL":@VM:"F.EB.MDAL.ENTITIES"    ;*files to be created in live
* Removed specifying individual NEO application names here.

    GENERIC.USER = ''         ;* Generic user for all the Services TSM, RUN.CONVERSION,T24.UPGRADE
    SERVICE.STATUS = 'STOP'   ;* will hold the DEFAULT service status
    SERVICE.DATE = ''         ;*will hold the date on which service was started
    SERVICE.STARTED = ''      ;*to indicate the time when service was started
    releasedRecordsList = ''     ;* to hold released records list
    populateReleasedRecords = ''   ;* indicates whether released record ids to be loaded in an array releasedRecordsList
    saveReleasedRecordsList = ''   ;* released records list
    routineName = 'T24.MODIFY.RELEASE.DATA'                             ;* local routine naming convention
    localRoutineExist = ''
    returnInfo = ''
    CALL CHECK.ROUTINE.EXIST(routineName,localRoutineExist,returnInfo)       ;* check for routine existance

    
    DUMMY = @(0,0)
*
* Prompt user for release no.
*

    neoProductAvailable=0  ;* Variable to idendify whether NE product available in the system or nor
    LOCATE 'NE' IN R.SPF.SYSTEM<SPF.PRODUCTS,1> SETTING NE.POS THEN ;* Check if NE installed or not.
        neoProductAvailable=1  ;* NE product avaiable in the system
    END
    
    IF NOT(EB.Upgrade.getInitialiseCreateInauOpens()) THEN ;*If mostly used commons are not initialised
        EB.Upgrade.CreateInauRecordsInitialise() ;*Initalise everything
        IF E THEN
            GOTO FATAL.ERROR
        END
    END

    IF NOT(DeployInServer) THEN ;* Skip TXTINP
        YTEXT = 'RELEASE NO'
        tmp = EB.Upgrade.getReleaseIn2Type()
        CALL TXTINP(YTEXT,8,22,50,tmp);*Size limit of the release number has increased to 50
        EB.Upgrade.setReleaseIn2Type(tmp)
        IF COMI THEN EB.Upgrade.setReleaseNo(COMI)
        ELSE RETURN
        PRINT @(0,9):"RELEASE NUMBER IS ":EB.Upgrade.getReleaseNo()
*
* Prompt user for select list name
*
        YTEXT = 'SELECT LIST NAME'
        tmp = EB.Upgrade.getReleaseIn2Type()
        CALL TXTINP(YTEXT,8,22,100,tmp);*DL restore process from browser should hold the parameter as "DL.RESTORE".
        EB.Upgrade.setReleaseIn2Type(tmp)
        IF COMI THEN LIST.NAME = COMI
        ELSE RETURN
        PRINT @(0,11):"SELECT LIST NAME IS ":LIST.NAME
*
* Ask user if he wishes to continue or quit
*
        YTEXT = "Press <RETURN> to continue or 'Q' to quit. "
        LOOP
            CALL TXTINP(YTEXT,8,22,5,'A')
            PRINT @(8,22):COMI:S.CLEAR.EOL:
        UNTIL COMI = "" OR COMI = 'Y' OR COMI = "Q" OR COMI = "q"
        REPEAT
        PRINT @(8,22):S.CLEAR.EOL:
        IF COMI = "Q" OR COMI = "q" THEN RETURN
    END
    START.SERVICE.LIST = "TSM":@VM:"T24.UPGRADE"   ;* services that are to released with status as start
*
* Initialise variables
*
    DIM RELEASE.RECORD(500)
    DIM SAVED.RELEASE.RECORD(500)
    DIM LIVE.RECORD(500)
    DIM companyRecord(500)       ;* variable to pass company record to load sub modules
    DIM INAU.RECORD(500)
    DIM rMasterCompany(500)             ;* Varibale to hold master company
    MAT RELEASE.RECORD = ""
    MAT LIVE.RECORD = ""
    MAT INAU.RECORD = ""
    LOCAL.FILE = ""
    LOCAL.INAU.FILE = ""
    Y.FILE.NAME = ""          ;* Used by I_MNEMONIC.CALCULATION
    E = ""
    FN.PGM.DATA.CONTROL = 'F.PGM.DATA.CONTROL'
    EB.Upgrade.setFPgmDataControl('')
    PDC.RECORD = ''
    tmp = EB.Upgrade.getFPgmDataControl()
    CALL OPF(FN.PGM.DATA.CONTROL,tmp)   ;*open PGM.DATA.CONTROL file to be read for adding _C to audit stamp in released record
    EB.Upgrade.setFPgmDataControl(tmp)
*
    tmpFUser = EB.Upgrade.getFUser()
    READ YR.USER FROM tmpFUser, OPERATOR ELSE
        E = "Cannot read USER record for ":OPERATOR
        GOTO FATAL.ERROR
    END

    FILE.VAR = ''
    IF RUNNING.IN.TAFJ THEN    ;* Open the RELEASE.DATA file from the environment, not from temp.release
        FILE.VAR = 'F.RELEASE.DATA'   ;* RELEASE.DATA should not be opened from temp.release as it was already copied to the environment
    END ELSE
        FILE.VAR = "F.TEMP.RELEASE.DATA"
    END

    IF INDEX(TSA.SERVICE.NAME,'/',1) THEN
        serviceName = FIELD(TSA.SERVICE.NAME,'/',2) ;* get batch process name without company mnemonic
    END ELSE
        serviceName = TSA.SERVICE.NAME
    END
    
    IF R.SPF.SYSTEM<SPF.ONLINE.UPGRADE> AND (serviceName MATCHES 'T24.UPGRADE.PRIMARY':@VM:'T24.UPGRADE':@VM:'T24.FULL.UPGRADE') THEN           ;* for both primary upgrade and secondary upgrade services
        READ rTsaService FROM F.TSA.SERVICE, TSA.SERVICE.NAME ELSE
            rTsaService = ''
        END
    END
    IF FILEINFO(EB.Upgrade.getFvreleasedrecords(),0) THEN  ;* if file exist (for DL restoration,updates,upgrade etc...)
        populateReleasedRecords = 1   ;* set flag, to populate list of released records in an array
    END

    IF EB.Upgrade.getReleaseNo() = 'T24.PRE.RELEASE' THEN        ;*when the release is T24.PRE.RELEASE
        tmp = EB.Upgrade.getFReleasedData()
        OPEN "",FILE.VAR TO tmp ELSE         ;*try to open RELEASE.DATA from the upgrade path
            E ="CANNOT OPEN"  ;*set the error msg
            GOTO FATAL.ERROR
        END
        EB.Upgrade.setFReleasedData(tmp)
    END
    
    isZerobase = ''              ;* intialise before usage
    READ R.SYSGEN.LOCKING FROM F.LOCKING,'SYSGEN' THEN         ;* locking reord of SYSGEN
        CALL OPF("F.SYSGEN", F.SYSGEN)                 ;* Open file SYSGEN
        READ R.SYSGEN.REC FROM F.SYSGEN,"SYSTEM" THEN           ;* Read the SYSGEN record
            IF R.SYSGEN.REC<EB.SYG.SYSGEN.TYPE> EQ 'ZEROBASE' AND R.SYSGEN.REC<EB.SYG.SYSGEN.STATUS> NE 'COMPLETED' THEN        ;* If Sysgen status is not equal to completed and sysgen type is zerobase
                isZerobase = 1
            END
        END
    END

* Reread the company record, as R.COMPANY saved in common does not get
* updated if a new application has been added
*
    F.COMPANY = EB.Upgrade.getFCompany()
    MATREAD R.COMPANY FROM F.COMPANY,ID.COMPANY ELSE MAT R.COMPANY = ''
    modulesSplit = EB.Upgrade.getModulesSplit()             ;* get the modules split details
    IF modulesSplit THEN  ;* load only if present
        MAT companyRecord = MAT R.COMPANY        ;* save R.COMPANY in a variable
        GOSUB LOAD.SUB.MODULES           ;* load the sub module in the company record variable
        MAT R.COMPANY = MAT companyRecord        ;* restor the company
        MAT companyRecord = ''           ;* set it to null
    END
    
*
    YCOMPANY.CODE = ID.COMPANY
    GOSUB INIT.FIN.MNE
*
* Read MASTER from COMPANY.CHECK for master mnemonic
*
    F.COMPANY.CHECK = EB.Upgrade.getFCompanyCheck()
    READ R.MASTER FROM F.COMPANY.CHECK, 'MASTER' ELSE
*
* Change MASTER to 'MASTER' ;

        E = 'EB.RTN.CANT.READ.F.COMPANY.CHECK.MASTER':@FM:'MASTER'
        GOTO FATAL.ERROR
    END

    REM.COMPANY.CODE = R.MASTER<EB.COC.COMPANY.CODE>        ;* Get Master Company Code
    REM.COMPANY.MNE = TRIM(R.MASTER<EB.COC.COMPANY.MNE>)

    MATREAD rMasterCompany FROM F.COMPANY,REM.COMPANY.CODE ELSE ;* populate the master company
        MAT rMasterCompany = MAT R.COMPANY ;* rare scenario
    END
    IF modulesSplit THEN  ;* load only if present
        MAT companyRecord = MAT rMasterCompany         ;* save R.COMPANY in a variable
        GOSUB LOAD.SUB.MODULES           ;* load the sub module in the company record variable
        MAT rMasterCompany = MAT companyRecord        ;* restore the company
        MAT companyRecord = ''            ;* set it to null
    END
    CALL HUSHIT(1)
    EXECUTE "CLEARSELECT"
    CALL HUSHIT(0)
   
    tmp = EB.Upgrade.getFReplacedRecords()

    EB.Upgrade.setFReplacedRecords(tmp)
*
* Build up a list of valid company codes
*

    REL.COMPANY.LIST = ''
    
    COMPANY.CREATE = ''
    READ R.COMPANY.CREATE.LOCKING FROM F.LOCKING,'COMPANY.CREATE' THEN        ;* Check for the locking record COMPANY.CREATE
        OPEN 'F.COMPANY$NAU' TO F.COMPANY.NAU ELSE F.COMPANY.NAU = ''         ;* Open NAU comapny
        COMPANY.CREATE = 1                                 ;* To indicate company creation mode
        COMPANY.LIST = FIELD(CONTROL.LIST,'-',1)             ;* Get the company from locking record
        THE.LIST = COMPANY.LIST
    END ELSE
        THE.LIST = DAS$ALL.IDS
        THE.ARGS = ""
        TABLE.SUFFIX = ""
        CALL DAS("COMPANY",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    END
    ID.LIST = THE.LIST
    LOOP
        REMOVE CID FROM ID.LIST SETTING POS
    WHILE CID:POS   ;*EN_10003192 E
        REL.COMPANY.LIST<-1> = CID
        
    REPEAT
*
* Determine if running in a multicompany environment (for writing out
* batch records)
*
    MULTI.COMPANY = 0
    IF DCOUNT(REL.COMPANY.LIST,@FM) > 1 THEN      ;*GLOBUS_BG_100007314 -S
        MULTI.COMPANY = 1
    END   ;*GLOBUS_BG_100007314 -E
*
* GB9801071s
*
    IF EB.Upgrade.getReleaseNo() = 'DL.RESTORE' THEN   ;*when restoring data through DL.DEFINE
        COMPANY = ID.COMPANY  ;*assign the id.company
    END ELSE
        CO.ID = ''
        NO.OF.COMS = DCOUNT(YR.USER<EB.USE.COMPANY.CODE>,@VM)
        FOR I = 1 TO NO.OF.COMS
            COMPANY = YR.USER<EB.USE.COMPANY.CODE,I>
            IF COMPANY NE 'ALL' THEN
                CALL DBR("COMPANY":@FM:EB.COM.COMPANY.NAME:@FM:"L", COMPANY, COMI.E)
                IF NOT(ETEXT) THEN
                    I = NO.OF.COMS
                END
            END ELSE
                IF DCOUNT(REL.COMPANY.LIST,@FM) = 0 THEN
                    E ='EB.RTN.ERROR.SELECTING.F.COMPANY'
                    GOTO FATAL.ERROR
                END
                LOOP
                    REMOVE CO.ID FROM REL.COMPANY.LIST SETTING CO.MARK          ;*GLOBUS_BG_100007314 -S/E
                UNTIL CO.ID REPEAT
            END
        NEXT I
        IF (ETEXT AND CO.ID) OR YR.USER<EB.USE.COMPANY.CODE> = 'ALL' THEN
            COMPANY = CO.ID
        END
    END

*
* GB9801071e
*
    DEPT = YR.USER<EB.USE.DEPARTMENT.CODE>
*
* Read select list containing items to be released
*
    F.SAVED.LIST = EB.Upgrade.getFSavedList()
    READ ALL.DATA FROM F.SAVED.LIST,LIST.NAME ELSE  ;* If the read from SAVEDLIST fails, then read from F.DS.RELEASE.DATA
            
        IF DeployInServer THEN  ;* For DSPackage server deployment
            totalDataRec = DCOUNT(DataPackageList, @FM) ;* Obtain the data list count
            FOR dataCnt = 1 TO totalDataRec
                ALL.DATA<-1> = FIELD(DataPackageList<dataCnt>, '#', 2)  ;* Fetch the RECXXX IDs
            NEXT dataCnt
        END ELSE
            E = 'EB.RTN.CANT.READ.&SAVEDLISTS':@FM:LIST.NAME
            GOTO FATAL.ERROR
        END
    END
*
    ERROR.OCCURRED = 0
    ALL.PROCESSED = 0
    MAX.RECORDS = COUNT(ALL.DATA,@FM) + (ALL.DATA <> '')
    V$COUNT = 1

*************************************************************************
*                                                                       *
*   M A I N   P R O C E S S I N G   O F   S E L E C T                   *
*                                                                       *
*************************************************************************
START.NEXT.FILE:
*
    STARTING.POS = V$COUNT
    FILENAME = FIELD(ALL.DATA<STARTING.POS>,'>',1)
    ORIGINAL.FILENAME = FILENAME
    RECORD.LIST = ''
    CHECK.ADD.INFO = ''       ;*Flag to indicate the Application records need to be released in HOLD status
    DIM R.DATA.RECORD(500)
    F.RELEASED.DATA = EB.Upgrade.getFReleasedData()
    CZ.INSTALLED = ''
    CALL Product.isInSystem('CZ', CZ.INSTALLED)
    
    FOR V$COUNT = STARTING.POS TO MAX.RECORDS
        MAT R.DATA.RECORD =''
        PDC.REC.ID = ALL.DATA<V$COUNT>                  ;* Get the PDC ID to be read
        RECORD.ID  = FIELD(ALL.DATA<V$COUNT>,'>',2,999) ;* Read the record ID after the first ">" fully
        FILE.ID = FIELD(ALL.DATA<V$COUNT>,'>',1) ;* Read the file name
        IF FILE.ID EQ 'F.CZ.CDP.DATA.DEFINITION' THEN ;* If the file name is F.CZ.CDP.DATA.DEFINITION,
            IF NOT(CZ.INSTALLED) THEN
                CRT "Product CZ is not installed. Ignoring ":FILE.ID:'>':RECORD.ID:" record"
                V$COUNT +=1
                GOTO START.NEXT.FILE ;* If PRODUCT is not installed skip to the next file
            END
            MATREAD R.DATA.RECORD FROM F.RELEASED.DATA,ALL.DATA<V$COUNT> ELSE ;* Read F.CZ.CDP.DATA.DEFINITION>RECORD.ID
                E = "EB.RTN.CANT.READ.F.RELEASE.DATA":@FM:FILE.ID:@VM:RECORD.ID
                RETURN TO FATAL.ERROR
            END
            IF R.DATA.RECORD(1)[1,1] EQ '{' THEN
                JsonString = ''                      ;* Initialise before usage
                OperationMode = 'dataRecord'         ;* Initialise operationMode to dataRecord
                HeaderDetails = ''                   ;* Initialise before usage
                DataArray = ''                       ;* Initialise before usage
                OfsRequest = ''                      ;* Initialise before usage
                ErrMsg = ''                          ;* Initialise before usage
                IF CID EQ '' THEN
                    jsonCompanyId = REM.COMPANY.CODE        ;* Get the Master Company Code
                END ELSE
                    jsonCompanyId = CID
                END
                MATBUILD JsonString FROM R.DATA.RECORD      ;* change the record into dynamic record
                CALL EB.PARSE.JSON.STRING(JsonString, OperationMode, HeaderDetails, DataArray, OfsRequest, ErrMsg)  ;* call api to parse the json into dataArray format
                DynamicRecord = DataArray
                IF HeaderDetails<2> AND (HeaderDetails<2> NE RECORD.ID) THEN
                    RECORD.ID = HeaderDetails<2>            ;* restore the recordId after parsing json record
                END
                MATPARSE R.DATA.RECORD FROM DynamicRecord   ;*restore the record back to dimensioned record
            END
            PRODUCT.POS='' ;* Release the record only if the the PRODUCT field of the read record is in SPF
            LOCATE R.DATA.RECORD(CZ.CDS.PRODUCT) IN R.SPF.SYSTEM<SPF.PRODUCTS,1> SETTING PRODUCT.POS ELSE ;* Check if PRODUCT installed or not.
                CRT "Product:":R.DATA.RECORD(CZ.CDS.PRODUCT):" is not installed. Ignoring ":FILE.ID:'>':RECORD.ID:" record"
                V$COUNT +=1
                GOTO START.NEXT.FILE ;* If PRODUCT is not installed skip to the next file
            END
        END
        F.PGM.DATA.CONTROL = EB.Upgrade.getFPgmDataControl()
        
        PRODUCT.ID = FIELD(PDC.REC.ID,"##",2) ;* get the emerge product from the PDC record ID
        PDC.REC.ID = FIELD(PDC.REC.ID,"##",1) ;* remove the last ##EM to get the PDC record ID
        BaseBank = 0 ;* set BaseBank flage to false
        IF (R.SPF.SYSTEM<SPF.LICENSE.CODE> EQ 'EURGBTMNS111') AND (R.SPF.SYSTEM<SPF.SITE.NAME> EQ 'BASE BANK') THEN ;* do not release ## records for base bank
            BaseBank = 1 ;* If Base bank, set flag to true
            IF (PRODUCT.ID NE '') THEN
                CONTINUE ;* CONTINUE for ## records in base bank
            END
        END
    
        READ PDC.RECORD FROM F.PGM.DATA.CONTROL,PDC.REC.ID ELSE   ;*read PDC record (ID without *EM)
            IF PRODUCT.ID THEN      ;*when emerge product is present in PDC id
                PRODUCT.INSTALLED = ''      ;*initialise before usage
                CALL Product.isInSystem(PRODUCT.ID, PRODUCT.INSTALLED)      ;*check whether Emerge product is installed
                IF NOT(PRODUCT.INSTALLED) THEN
                    CONTINUE        ;*Skip the record when the emerge product is not available
                END
                PDC.RECORD = ''  ;* Don't continue if PDC record is not available
            END
        END
*
* We ignore the records under below condition
* 1. if PDC indicates an additional module but the record ID has a different module or no module at all
*
*
        IF PDC.RECORD<PDC.ADDITIONAL.MODULE> AND NOT(BaseBank) THEN       ;*when Additional module is present in PDC record, skip for base bank and release original record
            ADDITIONAL.INSTALLED = ''       ;*initialise before usage
            additionalModules = PDC.RECORD<PDC.ADDITIONAL.MODULE> ;* PDC<ADDTIONAL.MODULE> can also be like 'SSUSMB!SSRETL'
            CHANGE '!' TO @VM IN additionalModules
            BEGIN CASE
                CASE PRODUCT.ID AND PRODUCT.ID MATCHES additionalModules ;* Check if additional module has the incoming PRODUCT.ID
                    CALL Product.isInSystem(PRODUCT.ID, ADDITIONAL.INSTALLED)    ;*check whether additional module is installed
                CASE PRODUCT.ID EQ '' AND additionalModules NE '' ;* to decide whether to release core record or not
                    ADDITIONAL.INSTALLED = ''
                    LOOP
                        REMOVE module FROM additionalModules SETTING modulePos
                    WHILE NOT(ADDITIONAL.INSTALLED) AND module
                        CALL Product.isInSystem(module, ADDITIONAL.INSTALLED)    ;*check whether additional module is installed
                    REPEAT
            END CASE
            BEGIN CASE
                CASE PRODUCT.ID AND NOT(ADDITIONAL.INSTALLED)
                    CONTINUE    ;* skip the emerge record when additional module is not installed
                CASE PRODUCT.ID EQ '' AND ADDITIONAL.INSTALLED
                    CONTINUE    ;* skip the core record when additional module is installed
            END CASE
        END
    
        IF (INDEX(PDC.RECORD<PDC.COMPONENT>, '_Infinity',1) AND R.SPF.SYSTEM<SPF.INFINITY> NE 'YES') THEN       ;* When the component is Infinity and the SPF does not have the parameter set
            CONTINUE                                                                      ;* Infinity parameter not set in SPF don't release
        END
    
        IF FILE.ID <> FILENAME THEN GOTO PROCESS.FILE
        RECORD.LIST<-1> = RECORD.ID
    NEXT V$COUNT
*
    ALL.PROCESSED = 1
*
PROCESS.FILE:
*
* Do not allow unauthorised file records to be copied.
*
    F.RELEASED.DATA = EB.Upgrade.getFReleasedData()
    F.PGM.FILE = EB.Upgrade.getFPgmFile()
    IF FILENAME[4] = "$NAU" THEN
        E = "EB.RTN.ILLEGAL.FILENAME.PROGRAM.TERMINATED":@FM:FILENAME:@VM:TIMEDATE()
        GOTO FATAL.ERROR
    END
*
* If a current file is VOC, process now (don't need to read the
* FILE.CONTROL record, etc)
*
    IF FILENAME = 'VOC' THEN
*
        NO.OF.RECORDS = COUNT(RECORD.LIST,@FM) + (RECORD.LIST <> '')
        FOR RECORD.CNT = 1 TO NO.OF.RECORDS
            RECORD.ID = RECORD.LIST<RECORD.CNT>
            GOSUB COPY.RECORDS
        NEXT RECORD.CNT
*
    END ELSE
*
* Copy current file to data account
*
        TEMP.FILENAME = FILENAME[".",2,99]        ;*Get the filename
        TEMP.MNEMONIC = FILENAME[2,3] ;* Get the mnemonic.
        REC.MNEMONIC = ''
        CALL CACHE.READ('F.MNEMONIC.COMPANY',TEMP.MNEMONIC,REC.MNEMONIC,MNE.ERR);* Mnemonic is valid then get the company code
        COUNTRY.SPECIFIC = 0                        ;* Initialise COUNTRY.SPECIFIC to 0
        COUNTRY.CODE =   ''                         ;* Set COUNTRY.CODE to NULL
        IF FILENAME[2,1] NE '.' AND FILENAME[4,1] EQ '.' THEN   ;* Check if the record is company specific and is not of the form F.TABLENAME or FBNK.TABLENAME
            COUNTRY.SPECIFIC = 1                                ;* Set COUNTRY.SPECIFIC to 1
            COUNTRY.CODE = FILENAME[2,2]                        ;* Extract the local country mnemonic to COUNTRY.CODE
            FILENAME = 'F.':FILENAME[5,99]                      ;* Change the file name to the format F.TABLENAME
        END
        LOCATE TEMP.FILENAME IN EB.Upgrade.getApplicationNames()<1> SETTING POS THEN ;*Check whether the PGM.FILE of the file is already read
            R.PGM.FILE = EB.Upgrade.getRPgmRecord()<POS>        ;*Get the PGM.RECORD from the common
            R.PGM.FILE = RAISE(R.PGM.FILE)        ;*Stored with lower format so, raise it
        END ELSE    ;*If filename is not already loaded
            IF APPLICATION EQ "T24.UPGRADE" THEN  ;*For upgrading process read the PGM.RECORD from temp.release
                
                READ R.PGM.FILE FROM F.RELEASED.DATA, "F.PGM.FILE>":TEMP.FILENAME THEN  ;* Read the PGM.FILE record
                    IF R.PGM.FILE[1,1] EQ '{' THEN
                        JsonString = R.PGM.FILE     ;* Get the json record
                        OperationMode = 'dataRecord'         ;* Initialise operationMode to dataRecord
                        HeaderDetails = ''                   ;* Initialise before usage
                        DataArray = ''                       ;* Initialise before usage
                        OfsRequest = ''                      ;* Initialise before usage
                        ErrMsg = ''                          ;* Initialise before usage
                        CALL EB.PARSE.JSON.STRING(JsonString, OperationMode, HeaderDetails, DataArray, OfsRequest, ErrMsg)      ;* call api to parse the json into dataArray format
                        R.PGM.FILE = DataArray
                        IF HeaderDetails<2> AND (HeaderDetails<2> NE TEMP.FILENAME) THEN
                            TEMP.FILENAME = HeaderDetails<2>        ;* restore the recordId after parsing json record
                        END
                    END
                    IF localRoutineExist THEN                   ;* local hook routine exist
                        CALL CACHE.READ('F.PGM.FILE',TEMP.FILENAME,recPgmFileTemp,pgmReadErr)                       ;* Read the PGM.FILE record from the actual production area
                        IF recPgmFileTemp AND INDEX(recPgmFileTemp<EB.PGM.ADDITIONAL.INFO>,'.MODIFY',1) THEN            ;* if record exist and '.MODIFY' configured                                                     ;* record exist
                            R.PGM.FILE<EB.PGM.ADDITIONAL.INFO> := '.MODIFY'                                         ;* update to R.PGM.FILE for further validation
                        END
                    END
                END ELSE     ;* Read the PGM.FILE record
                    R.PGM.FILE = ''     ;*if record not found make it as null
                END
            END ELSE
                READ R.PGM.FILE FROM F.PGM.FILE, TEMP.FILENAME ELSE   ;* Read the PGM.FILE record from the actual production area
                    R.PGM.FILE = ''     ;*if record not found make it as null
                END
            END
            tmp = EB.Upgrade.getRPgmRecord()
            tmp<-1> = LOWER(R.PGM.FILE)  ;*lower the level once and Store the record in common
            EB.Upgrade.setRPgmRecord(tmp)
            
            tmp = EB.Upgrade.getApplicationNames()
            tmp<-1> = TEMP.FILENAME ;*Store the filename to retrive the position of the record
            EB.Upgrade.setApplicationNames(tmp)
        END
        GOSUB CHECK.ADDITIONAL.INFO     ;*Check the additional info of the corresponding PGM.RECORD

        R.FILE.CONTROL = ''
*
        READ R.FILE.CONTROL FROM F.FILE.CONTROL, TEMP.FILENAME THEN   ;* Do process only when file exists
*
* Open live file in data account.


*
            SubProductNeo=0   ;* variable to say whether the sub product contains the  NEO or not.
            IF R.FILE.CONTROL<EB.FILE.SUB.PRODUCT> EQ 'NEO' THEN ;* if sub product field in FILE.CONTROL contains NEO then release the record in live file if ne product not avail able in the system
                SubProductNeo = 1 ;* say NEO available in FILE.CONTROL
            END
            
            GOSUB getAuditDateTimePosition ; *
            
            MNEMONICS.USED = ''
            BEGIN CASE
                CASE ((EB.Upgrade.getFnT24UpdateRelease() EQ 'F.T24.MODEL.PACKAGES' AND R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> NE 'INT') OR (LIST.NAME EQ 'DIM.ITEMS' AND EB.Upgrade.getReleaseNo() EQ 'DIM')) AND REC.MNEMONIC ;* To release the record to specific company
                    DL.COMP.LIST = REC.MNEMONIC ;* set the mnemonic
                    DL.NUM.COMP = 1;* Set default company count is 1.
                    GOSUB RELEASE.TO.SPECIFIC.COMPANY
                CASE EB.Upgrade.getReleaseNo() EQ 'DL.RESTORE' AND R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> NE 'INT'  ;* only when DL.RESTORE invoked
                    DL.COMP.LIST = R.NEW(EB.Upgrade.DlDefine.DlDefCompToRestore)    ;* get the company list specified in COMP.TO.RESTORE
                    DL.NUM.COMP = COUNT(DL.COMP.LIST,@VM) + (DL.COMP.LIST NE '')   ;* count the number of companied entered
                    IF DL.NUM.COMP THEN
                        GOSUB RELEASE.TO.SPECIFIC.COMPANY     ;* Release to the specific company
                    END ELSE
                        GOSUB RELEASE.TO.ALL.COMPANIES     ;* By default release to all companies
                    END
                CASE 1
                    GOSUB RELEASE.TO.ALL.COMPANIES     ;* By default release to all companies
            END CASE
        END
    END

    IF NOT(ALL.PROCESSED) THEN GOTO START.NEXT.FILE
    IF EB.Upgrade.getReleaseNo() = "T24.PRE.RELEASE" THEN                                        ;* may or may not release records based on whether live record exist or not
        infoMsg = "Transfer of records to data accounts complete."                ;* just a information message that process completed
    END ELSE
        infoMsg = "Transfer of records to data accounts complete for ":FILENAME   ;* info msg that record transfered for file
    END
    PRINT infoMsg
    Logger('CREATE.INAU.RECORDS',TAFC_LOG_INFO,infoMsg)                ;* msg updated in log for N number of times as per JOB LIST ids and invokation of job
    GOTO FINISH

RELEASE.TO.SPECIFIC.COMPANY:

    FOR DLCMP = 1 TO DL.NUM.COMP          ;* processing all the company specified in the field
        COMPANY.MNE = ''
        CID = DL.COMP.LIST<1,DLCMP>        ;* get the id of the company
        READ COMPANY.REC FROM F.COMPANY,CID ELSE     ;* read the company
            IF COMPANY.CREATE THEN
                READ COMPANY.REC FROM F.COMPANY.NAU,CID ELSE COMPANY.REC = ''
            END
            IF COMPANY.REC EQ '' THEN
                E ='EB.RTN.CANT.READ.F.COMPANY':@FM:CID
                GOTO FATAL.ERROR
            END
        END
        GOSUB CHECK.TO.RELEASE              ;* release the records to the company specified in the field(COMP.TO.RESTORE)
    NEXT DLCMP           ;* next company
RETURN

RELEASE.TO.ALL.COMPANIES:
    COMPANY.MNE = ''
    RELEASE.COMPNY.CODE = ''
    NUM.COMP = COUNT(REL.COMPANY.LIST,@FM) + (REL.COMPANY.LIST NE '')
    FOR CMPX = 1 TO NUM.COMP
        CID = REL.COMPANY.LIST<CMPX>
        IF R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> = 'INT' THEN   ;* Check if the file is of 'INT' Classification
            CID = REM.COMPANY.CODE                              ;* Assign REM.COMPANY.CODE to CID
        END
        
        READ COMPANY.REC FROM F.COMPANY,CID ELSE       ;* Read the company from live
            IF COMPANY.CREATE THEN                  ;* If not check if it is as part of company creation service
                READ COMPANY.REC FROM F.COMPANY.NAU,CID ELSE COMPANY.REC = ''    ;* Read the company record from NAU
            END
            IF COMPANY.REC EQ '' THEN              ;* If the company record is not available
                E ='EB.RTN.CANT.READ.F.COMPANY':@FM:CID
                GOTO FATAL.ERROR
            END
        END
    
        BEGIN CASE
            CASE R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> = "CUS"
                COMPANY.MNE = COMPANY.REC<EB.COM.CUSTOMER.MNEMONIC>
                RELEASE.COMPNY.CODE = COMPANY.REC<EB.COM.CUSTOMER.COMPANY>
            CASE R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> = "FIN"
                COMPANY.MNE = COMPANY.REC<EB.COM.FINANCIAL.MNE>
                RELEASE.COMPNY.CODE = COMPANY.REC<EB.COM.FINANCIAL.COM>
            CASE R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> = "CCY"
                COMPANY.MNE  = COMPANY.REC<EB.COM.CURRENCY.MNEMONIC>
                RELEASE.COMPNY.CODE = COMPANY.REC<EB.COM.CURRENCY.COMPANY>
            CASE R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> = "NOS"
                COMPANY.MNE = COMPANY.REC<EB.COM.NOSTRO.MNEMONIC>
                RELEASE.COMPNY.CODE = COMPANY.REC<EB.COM.NOSTRO.COMPANY>
            CASE R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> = "FTF"
                COMPANY.MNE = COMPANY.REC<EB.COM.FINAN.FINAN.MNE>
                RELEASE.COMPNY.CODE = COMPANY.REC<EB.COM.FINAN.FINAN.COM>
            CASE R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> = "CST"
                COMPANY.MNE = COMPANY.REC<EB.COM.DEFAULT.CUST.MNE>
                RELEASE.COMPNY.CODE = COMPANY.REC<EB.COM.DEFAULT.CUST.COM>
                IF COMPANY.REC<EB.COM.SPCL.CUST.FILE> THEN
                    SUBFIELD = COMPANY.REC<EB.COM.SPCL.CUST.FILE>
                    LOCATE TEMP.FILENAME IN SUBFIELD<1,1> SETTING POS THEN
                        COMPANY.MNE = COMPANY.REC<EB.COM.SPCL.CUST.MNE><1,POS>
                        RELEASE.COMPNY.CODE = COMPANY.REC<EB.COM.SPCL.CUST.COM><1,POS>
                    END
                END
            CASE R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> = "FTD"
                COMPANY.MNE = COMPANY.REC<EB.COM.DEFAULT.FINAN.MNE>
                RELEASE.COMPNY.CODE = COMPANY.REC<EB.COM.DEFAULT.FINAN.COM>
                IF R.COMPANY(EB.COM.SPCL.FIN.FILE) THEN
                    SUBFIELD = COMPANY.REC<EB.COM.SPCL.FIN.FILE>
                    LOCATE TEMP.FILENAME IN SUBFIELD<1,1> SETTING POS THEN
                        COMPANY.MNE = COMPANY.REC<EB.COM.SPCL.FIN.MNE><1,POS>
                        RELEASE.COMPNY.CODE = COMPANY.REC<EB.COM.SPCL.FIN.COM><1,POS>
                    END
                END
            CASE R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> = "FRP"
                COMPANY.MNE = COMPANY.REC<EB.COM.MNEMONIC>
        END CASE
        IF PDC.RECORD<PDC.PRODUCT> NE "" AND NOT(serviceName MATCHES 'T24.UPGRADE.PRIMARY':@VM:'T24.UPGRADE':@VM:'T24.FULL.UPGRADE') THEN  ;* Checking PDC.RECORD is NULL
            PRD.DETAILS = PDC.RECORD<PDC.PRODUCT>       ;*  Get the product details
            CONVERT '!' TO @FM IN PRD.DETAILS                    ;*  Convert to @FM
            TOTAL.PROD = DCOUNT(PRD.DETAILS,@FM)
            INSTALLED = 1       ;*default installed value to 1
            FOR PROD.CNT = 1 TO TOTAL.PROD
                LOCATE PRD.DETAILS<PROD.CNT> IN COMPANY.REC<EB.COM.APPLICATIONS,1> SETTING insPrdPos ELSE ;* Checking whether the product in PDC got installed for that company
                    INSTALLED = 0       ;*set installed flag to 0
                    BREAK
                END
            NEXT PROD.CNT
            IF NOT(INSTALLED) THEN
                CONTINUE        ;* if any of the product is not installed, then return back
            END
        END
        GOSUB CHECK.TO.RELEASE          ;* release the records to all companies
        
    NEXT CMPX
RETURN

CHECK.TO.RELEASE:
*
* Determine whether to update the file or whether it has already been updated (for INT level files, only
* update on first pass through, for other files, determine whether the current mnemonic has already been
* used
*
    COMPANY = CID ;* Current Company code
    IF NOT(COMPANY.MNE) THEN                        ;* If no comapany mnemonic is found before
        COMPANY.MNE = COMPANY.REC<EB.COM.MNEMONIC>  ;* get company mnemonic from the company record
    END
    
    UPDATE.RECORD = 1
    IF R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> = 'INT' THEN
        COMPANY = REM.COMPANY.CODE    ;* Master Company code
        IF CMPX > 1 THEN
            UPDATE.RECORD = 0
        END
    END ELSE
        ALREADY.UPDATED = 1
        LOCATE COMPANY.MNE IN MNEMONICS.USED<1> SETTING X ELSE
            MNEMONICS.USED<-1> = COMPANY.MNE
            ALREADY.UPDATED = 0
        END
        IF ALREADY.UPDATED THEN UPDATE.RECORD = 0
    END
    IF UPDATE.RECORD THEN

        IF R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> NE 'INT' THEN
            FILENAME = 'F':COMPANY.MNE:'.':TEMP.FILENAME
        END
    
        IF ORIGINAL.FILENAME EQ "F.EB.ADVICES" THEN
            IS.DE.INSTALLED = ''            ;* Initialise before usage
            LOCATE "DE" IN COMPANY.REC<EB.COM.APPLICATIONS,1> SETTING IS.DE.INSTALLED ELSE
                RETURN        ;* If product is not installed then return back
            END
        END
*
*  When releasing records for CUS, FIN type files,the file might not exists in all the companies. If the file does not exists
*  don't throw error on the screen. If the file exists then release the record else do anything (similar to what we do in conversion)
*
        ERROR.OCCURRED = 0
        OPEN "",FILENAME TO LOCAL.FILE ELSE     ;* strange that we are releasing records for CUS, FIN type files
*               PRINT "CAN'T OPEN ":FILENAME   ; * this logic need to be revisited for a permanent fix
            ERROR.OCCURRED = 1
        END

        IF ERROR.OCCURRED = 0 THEN
*
* Open unauthorised file in data account if $NAU is specified on the file control record
*
            LOCATE '$NAU' IN R.FILE.CONTROL<EB.FILE.CONTROL.SUFFIXES,1> SETTING INAU.FILE.EXISTS THEN
                OPEN "",FILENAME:"$NAU" TO LOCAL.INAU.FILE ELSE
                    INAU.FILE.EXISTS = 0
                END
            END ELSE INAU.FILE.EXISTS = 0
            NO.OF.RECORDS = COUNT(RECORD.LIST,@FM) + (RECORD.LIST <> '')
            FOR RECORD.CNT = 1 TO NO.OF.RECORDS
                RECORD.ID = RECORD.LIST<RECORD.CNT>
                GOSUB COPY.RECORDS
            NEXT RECORD.CNT
        END
    END
RETURN

*------------------------------------------------------------------------
*   S U B R O U T I N E S
*------------------------------------------------------------------------
*
COPY.RECORDS:

* Transfer records from the release record file to the unauthorised files on the data accounts.
*
    IS.JSON.STRING = ''                     ;* Initialise before Usage
    SAVED.RECORD.ID = RECORD.ID
    F.RELEASED.DATA = EB.Upgrade.getFReleasedData()
    F.PGM.DATA.CONTROL = EB.Upgrade.getFPgmDataControl()
    
    MATREAD RELEASE.RECORD FROM F.RELEASED.DATA,ORIGINAL.FILENAME:'>':RECORD.ID ELSE
        E = "EB.RTN.CANT.READ.F.RELEASE.DATA":@FM:ORIGINAL.FILENAME:@VM:RECORD.ID
        RETURN TO FATAL.ERROR
    END
    
     
    IF RELEASE.RECORD(1)[1,1] EQ '{' THEN
        JsonString = ''                      ;* Initialise before usage
        OperationMode = 'dataRecord'         ;* Initialise operationMode to dataRecord
        HeaderDetails = ''                   ;* Initialise before usage
        DataArray = ''                       ;* Initialise before usage
        OfsRequest = ''                      ;* Initialise before usage
        ErrMsg = ''                          ;* Initialise before usage
        IF CID EQ '' THEN
            jsonCompanyId = REM.COMPANY.CODE        ;* Get the Master Company Code
        END ELSE
            jsonCompanyId = CID
        END
        MATBUILD JsonString FROM RELEASE.RECORD      ;* change the record into dynamic record
        IS.JSON.STRING = JsonString
        SAVE.ID.COMPANY = ID.COMPANY                 ;* save Company Id
        IF RELEASE.COMPNY.CODE NE jsonCompanyId AND RELEASE.COMPNY.CODE THEN        ;* avoid to load the wrong the company
            jsonCompanyId = RELEASE.COMPNY.CODE
        END
        IF COMPANY.CREATE THEN
            OPEN 'F.COMPANY$NAU' TO F.COMPANY THEN          ;* Open NAU comapny
                READ REC.COMPANY FROM F.COMPANY, jsonCompanyId THEN      ;* get the company record
                    DIM YR.COMPANY(100)
                    MAT YR.COMPANY = ''
                    MATPARSE YR.COMPANY FROM REC.COMPANY    ;* Save in common as dimensioned array
                    CALL F.MATLOAD("F.COMPANY", jsonCompanyId, MAT YR.COMPANY, EB.COM.AUDIT.DATE.TIME)   ;*load the company
                END
            END
        END ELSE
            CALL LOAD.COMPANY(jsonCompanyId)   ;* Load the company
        END
        CALL EB.PARSE.JSON.STRING(JsonString, OperationMode, HeaderDetails, DataArray, OfsRequest, ErrMsg)  ;* call api to parse the json into dataArray format
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)      ;* Re-load the original Company

        DynamicRecord = DataArray
        IF HeaderDetails<2> AND (HeaderDetails<2> NE RECORD.ID) THEN
            RECORD.ID = HeaderDetails<2>            ;* restore the recordId after parsing json record
        END
        MATPARSE RELEASE.RECORD FROM DynamicRecord   ;*restore the record back to dimensioned record
    END
    
    RECORD.ID = FIELD(RECORD.ID,"##",1)  ;* remove the suffix, because we need only the record ID

    READ PDC.RECORD FROM F.PGM.DATA.CONTROL,ORIGINAL.FILENAME:'>':RECORD.ID ELSE   ;*read PDC record to check if source required is 'C'
        PDC.RECORD = ''
    END
    OUModule = ''
    IF R.SPF.SYSTEM<SPF.ONLINE.UPGRADE> AND (serviceName MATCHES 'T24.UPGRADE.PRIMARY':@VM:'T24.UPGRADE':@VM:'T24.FULL.UPGRADE') THEN           ;* for both primary upgrade and secondary upgrade services
        attributeTypes = rTsaService<TS.TSM.ATTRIBUTE.TYPE>          ;* get List of attribute types from TSM record
        attributeValues = rTsaService<TS.TSM.ATTRIBUTE.VALUE>        ;* products defined with space delimited so that it can be fetched easily as ATTRIBUTE.TYPE holds other attributes values also for online upgrade
        LOCATE PDC.RECORD<1> IN attributeValues<1,1> SETTING aPos THEN
            IF attributeTypes<1,aPos> EQ 'MODULES' THEN         ;* if current record is belongs to one of those MODULES defined in TSA.SERVICE, then inputter in audit section should have 1_<MODULE ID>
                OUModule = PDC.RECORD<1>          ;* online upgrade modules id from TSA.SERVICE
            END
        END
    END

    
    releaseRecId = 'F.':TEMP.FILENAME:'*':SAVED.RECORD.ID                 ;* Form the releaseRecId with File Name and Record ID
    IF COUNTRY.SPECIFIC EQ 0 THEN                                  ;* If the record to be released is not country specific
        READU releaseCheck FROM F.RELEASED.DATA, releaseRecId THEN  ;* Read the record with a lock and store it to releaseCheck
            LOCATE COMPANY.MNE IN releaseCheck BY @FM SETTING releasePos THEN   ;* Locate if the COMPANY.MNE is already available in the releaseCheck record
                RELEASE F.RELEASED.DATA, releaseRecId                           ;* Release the read lock
                RETURN                                                          ;* Return without releasing the record
            END
        END
    END
    RELEASE F.RELEASED.DATA, releaseRecId                           ;* Release the read lock
    IF COUNTRY.SPECIFIC THEN ;* for country specific records
        SET.RELEASE.COMPNY = ''             ;* Initialise before usage
        IF RELEASE.COMPNY.CODE NE COMPANY AND RELEASE.COMPNY.CODE THEN      ;* check whether the company code and release company code are different or same
            SAVE.COMPANY.REC = COMPANY.REC              ;* Save the actual company record
            RELEASE.COMPNY.REC = ''                     ;* Initialise before usage
            READ RELEASE.COMPNY.REC FROM F.COMPANY,RELEASE.COMPNY.CODE THEN
                SET.RELEASE.COMPNY = 1      ;* set the flag to change the company rec
                COMPANY.REC = RELEASE.COMPNY.REC            ;* change the existing company record to release company record
            END
        END
        IF COMPANY.REC<EB.COM.LOCAL.COUNTRY> NE COUNTRY.CODE THEN  ;* Check if it is COUNTRY.SPECIFIC and the current company is not the company where the record is to be released
            UPDATE.RECORD = 0                                           ;* Set UPDATE.RECORD to 0
            RETURN                                                      ;* Return without releasing the record
        END
        IF SET.RELEASE.COMPNY THEN          ;* if flag set
            COMPANY.REC = SAVE.COMPANY.REC      ;* restore the actual company record
        END
        READ EXCLUDED.COMPANIES FROM F.LOCKING,'EXCLUDE.COMP.FOR.REGION' THEN ;* read the locking record EXCLUDE.COMP.FOR.REGION to see if any exclusions are available
            LOCATE COUNTRY.CODE IN EXCLUDED.COMPANIES<1,1> SETTING pos THEN ;* locate the country
                IF R.SPF.SYSTEM<SPF.LICENSE.CODE>[6,4] EQ 'TMNS' AND COMPANY.MNE MATCHES RAISE(EXCLUDED.COMPANIES<2,pos>) THEN ;* if current company must be excluded,
                    UPDATE.RECORD = 0                                 ;* Set UPDATE.RECORD to 0
                    RETURN                                            ;* Return without releasing the record
                END
            END
        END
    END
**COEXISTENCE.START
    isDataModifyError = ''                ;* variable to hold error which is set from local hook routine
    isRecordIdChanged = ''                ;* variable to indicate whether the id has been changed
    isRecordContentChanged = ''           ;* variable to indicate whether the record content has been changed
    isRelDataModifyError = ''  ;* set the variable as null for imp.choice.type hook
    argRecordContent ='' ;*To pass as argument
    IF (localRoutineExist OR MOD.RELEASE.API ) THEN     ;* if routine exist and table enabled to accept change in release data.
    
        fileName = FILENAME                  ;* local hook can just refer this file name if required
        recordId = RECORD.ID                  ;* local hook can just refer record id to make conditional change
        DIM recordContent(500)                ;* create a temp variable to hold the record
        MAT recordContent = MAT RELEASE.RECORD        ;* copy the record to temp variable
        IF localRoutineExist AND  INDEX(ADD.INFO,'.MODIFY',1)  THEN
            CALL @routineName(fileName,recordId,MAT recordContent,isDataModifyError)         ;* recordContent gets updated with local change if any (always core standards can override this)
        END
        IF MOD.RELEASE.API  THEN  ;* Only if  and pgm.file has .MREL and routine exists
       
            routineName = R.EB.DATA.RELEASE<EB.Upgrade.DataReleaseApiTable.DarReleaseApi>    ;* take the routine name
            routineName<2>='*$$*' ;* to enable passing dynamic array as argument
            MATBUILD argrecordContent  FROM recordContent ;* convert this as dynamic array
            ARGS=fileName:'*$$*':recordId:'*$$*':argrecordContent:'*$$*':isRelDataModifyError ;* Pass the argument
            CALL EB.CALL.API(routineName,ARGS)  ;* Trigger the hook through EB.CALL.API
            recordId = FIELD(ARGS,'*$$*',2)  ;* parse the id from the return argument
            argrecordContent = FIELD(ARGS,'*$$*',3)  ;* Parse the record from return argument
            isRelDataModifyError=FIELD(ARGS,'*$$*',4) ;* Parse the error
            MATPARSE  recordContent FROM argrecordContent  ;* Restore the array back to dimensioned
        END
          
        IF (recordId AND recordId NE RECORD.ID)  THEN          ;*if the record id changed and has some value
            isRecordIdChanged = 1                           ;*set up the flag
            RECORD.ID = recordId                            ;* change the id
        END
        
        MATBUILD modifiedContent FROM recordContent
        MATBUILD existingContent FROM RELEASE.RECORD
        
        IF modifiedContent EQ '' THEN   ;* Record has been made null in the local hook to avoid writing, so inform the same in screen and logger
            infoMsg = 'RECORD ': recordId :' FOR THE TABLE ': fileName :' IS MADE NULL  THROUGH HOOK SO WE ARE NOT RELEASING IT'
            PRINT infoMsg
            Logger('CREATE.INAU.RECORDS',TAFC_LOG_INFO,infoMsg)
            RETURN
        END
**COEXISTENCE.END
        IF modifiedContent AND modifiedContent NE existingContent THEN    ;* if the record content is present and changed
            isRecordContentChanged = 1                      ;*set up the flag
            MAT RELEASE.RECORD = MAT recordContent                  ;* modify the content
        END
        
    END

*
* Special file processing (resetting of fields, etc.)- If program is being called from DL.DEFINE,
* write the records with status of IHLD; otherwise write the records with status of INAU
*
*Application records need to be released in HOLD status
    IF EB.Upgrade.getReleaseNo() = 'DL.RESTORE' OR CHECK.ADD.INFO OR isDataModifyError OR isRelDataModifyError THEN     ;*if flag is set
        RELEASE.REC.STATUS = 'IHLD'     ;*Release the RECORD in HOLD STATUS
    END ELSE
        RELEASE.REC.STATUS = "INAU"     ;* Default status
    END
*
    MISSING.AUDIT.FIELD = ""

    REL.COMPANY.LIST = REL.COMPANY.LIST ;* reset the remove pointer

    currentService = ''
    IF INDEX(BATCH.INFO<1>,'/',1) THEN
        currentService = FIELD(BATCH.INFO<1>, '/', 2)          ;* Get the current service name without comp mnemonic
    END ELSE
        currentService = FIELD(BATCH.INFO<1>, '/', 1)          ;* Get the current service
    END
    isOnlineUpgradePrimary = 0
    IF R.SPF.SYSTEM<SPF.ONLINE.UPGRADE> AND BATCH.DETAILS<3> = 'PRIMARY' AND currentService EQ 'T24.UPGRADE.PRIMARY' THEN       ;* if online upgrade is in progress and it is Primary upgrade service
        isOnlineUpgradePrimary = 1                  ;* flag to indicate that it is primary upgrade service as part of online upgrade is in progress
    END
    
    BEGIN CASE
*
* If record is from the batch file, set process status, job status, etc.
*
        CASE FILENAME = 'F.BATCH'
            RELEASE.RECORD(BAT.DEFAULT.PRINTER) = ''
            RELEASE.RECORD(BAT.PROCESS.STATUS) = '0'
            RELEASE.RECORD(BAT.BATCH.ENVIRONMENT) = 'F'
            
            BATCH.STAGE = RELEASE.RECORD(BAT.BATCH.STAGE)   ;* get the batch stage value
            IF BATCH.STAGE NE "" THEN
                MAIN.STAGE = RELEASE.RECORD(BAT.MAIN.STAGE) ;* get the main stage value
                COB.STAGE = RELEASE.RECORD(BAT.COB.STAGE)   ;* get the cob stage value
                IF MAIN.STAGE AND COB.STAGE THEN            ;* both the value exist, MAIN.STAGE and COB.STAGE
                    ARGSEQ  = ""                                        ;* Initalise before usage
                    ARGSEQ<1> = MAIN.STAGE                              ;* set main stage as first argument
                    ARGSEQ<2> = COB.STAGE                               ;* set cob stage as second argument
                    ARGSEQ<3> = ''                                      ;* Initialise before usage
                    CALL EB.CALL.API("EB.COB.STAGE.SEQ.API", ARGSEQ)    ;* get cob stage sequence
                    RELEASE.RECORD(BAT.COB.STAGE.SEQ) = ARGSEQ<3>       ;* set cob stage sequence in BATCH record
                END
            END
        
            TEMP.MAX.AV = COUNT(RELEASE.RECORD(BAT.JOB.NAME),@VM) + 1 ;*system should always run the loop
            FOR TEMP.AV = 1 TO TEMP.MAX.AV
                RELEASE.RECORD(BAT.NEXT.RUN.DATE)<1,TEMP.AV> = ''
                RELEASE.RECORD(BAT.PRINTER.NAME)<1,TEMP.AV> = ''
                RELEASE.RECORD(BAT.JOB.STATUS)<1,TEMP.AV> = '0'
                RELEASE.RECORD(BAT.LAST.RUN.DATE)<1,TEMP.AV> = ''
                RELEASE.RECORD(BAT.JOB.MESSAGE)<1,TEMP.AV> = ''
                RELEASE.RECORD(BAT.USER)<1,TEMP.AV> = ''
            NEXT TEMP.AV
*
* Special processing for Batch records - Determine level and product for the batch record from the
* batch.new.company record (which will have been included in this or a previous release
*
            GOSUB CHECK.MULTI.COMPANY.AND.RELEASE

        CASE FILENAME = 'F.TSA.SERVICE'

            RFN = '';*Field numbers that have to be cleared during release
             
            IF EB.Upgrade.getReleaseNo() = "T24.PRE.RELEASE" AND RECORD.ID MATCHES START.SERVICE.LIST THEN   ;* for records from T24.PRE.RELEASE with START status
                RELEASE.RECORD(TS.TSM.USER) = OPERATOR              ;* Generic User is set from calling routine
                RELEASE.RECORD(TS.TSM.SERVICE.CONTROL) = "START"    ;* set the Services TSM, T24.UPGRADE to START
                RELEASE.RECORD(TS.TSM.DATE)= TODAY        ;*set the service TSM,T24.UPGRADE to TODAY
                RELEASE.RECORD(TS.TSM.STARTED) = OCONV(DATE(),'D4/E'):' ':OCONV(TIME(),'MTS')      ;* DD/MM/YYYY HH:MM:SS  machine date & time for start and stop
            END ELSE

                GOSUB getTsmUser    ;* Get TSM user and decide record status

                AUTHORISER.MATCH = "0N1N_1X0X":@VM:"'SY_'1X0X" ;*Authorizer name could be SESSION.NO_USER.NAME/SY_USER.NAME
                IF IS.JSON.STRING[1,1] EQ '{' THEN                      ;* Check whether the TSA.SERVICE record is .json or .d
                    RELEASE.RECORD(TS.TSM.SERVICE.CONTROL) = 'STOP' ;* Assign STOP to SERVICE.CONTROL
                END
                BEGIN CASE
                    CASE  RELEASE.RECORD(18) MATCHES AUTHORISER.MATCH ;*In the beginning, Authorizer field located at 18th position
                        RFN = ''                        ;* Fields DATE,STARTED,STOPPED,ELAPSED and TRANSACTIONS are not introduced, So don't clear.
                        RELEASE.RECORD(4) = tsmUser
                        RELEASE.RECORD(5) = 'STOP'      ;*In lower releases, Service control field present at 5th position
                    CASE RELEASE.RECORD(29) MATCHES AUTHORISER.MATCH ;*After R08, Authorizer field position shifted to 29th position
                        RELEASE.RECORD(4) = tsmUser     ;* populate USER field with TSM user
                        RELEASE.RECORD(5) = 'STOP'      ;* Before introducing SERVER.STATUS field, Service control field position in 5th position.
                        RFN = 14                        ;*DATE field start at 14th position
                    CASE RELEASE.RECORD(30) MATCHES AUTHORISER.MATCH ;*After introducing SERVER.STATUS field, Authorizer field position shifted to 30th position
                        RELEASE.RECORD(5) = tsmUser     ;*User field shifted to 5th position, so assign with TSM user
                        RELEASE.RECORD(6) = 'STOP'      ;*Service control field shifted to 6th position, So Assign it as STOP
                        RFN = 15                        ;* DATE field start at 19th position
                    CASE 1                      ;*For future use
                        RELEASE.RECORD(TS.TSM.USER) = tsmUser
                        RFN = TS.TSM.DATE               ;*DATE field position based on the latest insert
                END CASE
            END
            IF RFN THEN
                FOR FLD.NO = RFN TO RFN + 4 ;*DATE,STARTED,STOPPED,ELAPSED and TRANSACTIONS fields
                    RELEASE.RECORD(FLD.NO) = '' ;*Clear the content of the above fields since it would be updateD based on the upgrading environment while authorizing/Running service
                NEXT FLD.NO
            END

            IF EB.Upgrade.getReleaseNo() NE 'DL.RESTORE' THEN   ;* For DL pack restoring don't nullify SERVER.NAME field
                RELEASE.RECORD(2) = '' ;*Make the SERVER.NAME field as null
            END
*
* Special processing for TSA.SERVICE records - Determine level and product for the TSA.SERVICE record from the
* batch.new.company record (which will have been included in this or a previous release)
*

            GOSUB CHECK.MULTI.COMPANY.AND.RELEASE


* If record is from the VOC, just write out to the VOC without any changes
*
        CASE FILENAME = 'VOC'
            VOC = EB.Upgrade.getVoc()
            
            PRINT "Transferring ":FILENAME:">":RECORD.ID
            MATWRITE RELEASE.RECORD ON VOC,RECORD.ID
  
*
* Process all other files
*
        CASE R.PGM.FILE<EB.PGM.PRODUCT> = "PP"
            CALL PP.CHANGE.DATES(MAT RELEASE.RECORD,RECORD.ID,ORIGINAL.FILENAME)
            GOSUB WRITE.RECORDS
            
        CASE FILENAME = 'F.RR.PARAM'
            recordId = RECORD.ID        ;*save the original rec id to loop through companies
            CALL EB.GET.APPLN.COMP.MNES(recordId, companyMnemonics)     ;*get company mnemonics in which application product is installed
            IF companyMnemonics EQ 'INT.TYPE.FILE' THEN ;* If the file is an INT file.
                RECORD.ID = 'F.':recordId ;* form RECORD.ID to be written to RR.PARAM as F.APPLICATION.NAME
                GOSUB WRITE.RECORDS  ;* Write the INT record
            END ELSE
                LOOP
                    REMOVE companyMnemonic FROM companyMnemonics SETTING pos        ;*loop through each comp mnemonic
                WHILE companyMnemonic:pos
                    RECORD.ID = 'F':companyMnemonic:'.':recordId        ;*form the record id with comp mnemonic
                    GOSUB WRITE.RECORDS ;* Write 1 record for each mnemonic
                REPEAT
            END
        
        CASE 1

            BEGIN CASE
*
* If record is from report control, set retention dates to null and date and time last run and spooled to null
*
                CASE FILENAME = 'F.REPORT.CONTROL'

*Removed the line to transfer the value in field REPORT.RETENTION while restoring
                    RELEASE.RECORD(RCF.DATE.LAST.RUN) = ''
                    RELEASE.RECORD(RCF.TIME.LAST.RUN) = ''
                    RELEASE.RECORD(RCF.DATE.LAST.SPOOLED) = ''
                    RELEASE.RECORD(RCF.TIME.LAST.SPOOLED) = ''
*
* If record is from REPGEN.CREATE, set last compiled and sort fields to null
*
                CASE FILENAME = 'F.REPGEN.CREATE'
                    RELEASE.RECORD(RG.CRE.DATE.TIME.COMPILER) = ''
                    RELEASE.RECORD(RG.CRE.CO.CODE.SORT) = ''
                    RELEASE.RECORD(RG.CRE.DATE.TIME.SORT) = ''
*
* If record is from REPGEN.SORT, set last compiled and sort fields to null
*
                CASE FILENAME = 'F.REPGEN.SORT'
                    RELEASE.RECORD(RG.SRT.DATE.TIME.COMPILER) = ''
                    RELEASE.RECORD(RG.SRT.DATE.TIME.SORT) = ''
*
* If record is from REPGEN.OUTPUT, set last compiled and sort fields to null
*
                CASE FILENAME = 'F.REPGEN.OUTPUT'
                    RELEASE.RECORD(RG.OUT.DATE.TIME.COMPILER) = ''
                    RELEASE.RECORD(RG.OUT.DATE.TIME.SORT) = ''
*
* If record is from CONVERSION.PGMS, call GET.CONVERSION.COMPANIES to determine which companies the conversion
* program should be run in. Also set run flag to 1 - pgm is to be run, status flag to null - pgm has not been
* run and overrides to null.  However, if the program is not to be run (product has not been installed), set
* the run flag to 0 - pgm is not to be run.
*
                CASE FILENAME = 'F.CONVERSION.PGMS'
*
                    MAX.PGMS = COUNT(RELEASE.RECORD(EB.CON.PROGRAM.NAME),@VM) + (RELEASE.RECORD(EB.CON.PROGRAM.NAME) <> '')
*
                    FOR PGM.COUNT = 1 TO MAX.PGMS
                        COMPANIES = ''
                        CLASSIFICATION = RELEASE.RECORD(EB.CON.RUN.LEVEL)<1,PGM.COUNT>
                        PGM.NAME = RELEASE.RECORD(EB.CON.PROGRAM.NAME)<1,PGM.COUNT>
                        ETEXT = ''
                        CALL GET.CONVERSION.COMPANIES(CLASSIFICATION,PGM.NAME,COMPANIES)
                        IF ETEXT THEN
                            pdcRec = '' ;*initialise before usage
                            READ pdcRec FROM F.PGM.DATA.CONTROL,'F.CONVERSION.DETAILS':'>':PGM.NAME ELSE   ;*read PDC record to check product of CONVERSION.DETAILS record
                                pdcRec = ''
                            END
                            IF pdcRec<PDC.PRODUCT> EQ 'OB' THEN     ;* if the product is OB dont proceed further.
                                CONTINUE
                            END
                            errMsg = ''
                            errMsg<-1> = S.BELL:'*** WARNING *** ERROR IN CREATE.INAU.RECORDS'
                            errMsg<-1> = 'F.CONVERSION.PGMS  RECORD ID = ':RECORD.ID
                            errMsg<-1> = ETEXT
                            ETEXT = ''
                            PRINT errMsg
                            Logger('CREATE.INAU.RECORDS',TAFC_LOG_ERROR,errMsg)
                        END
                        RELEASE.RECORD(EB.CON.RUN.LEVEL)<1,PGM.COUNT> = CLASSIFICATION
                        RELEASE.RECORD(EB.CON.COMPANIES.SELECTED)<1,PGM.COUNT> = COMPANIES
                        RELEASE.RECORD(EB.CON.RUN.PGM)<1,PGM.COUNT> = ''
                        RELEASE.RECORD(EB.CON.NOTES)<1,PGM.COUNT> = ''
                        RELEASE.RECORD(EB.CON.RUN.STATUS)<1,PGM.COUNT> = ''
                        RELEASE.RECORD(EB.CON.ERROR.MSG)<1,PGM.COUNT> = ''
                        RELEASE.RECORD(EB.CON.RUN.INFORMATION)<1,PGM.COUNT> = ''
                        MAX.COMPANIES = COUNT(COMPANIES<1,1>,@SM) + 1
                        FOR CMPX = 1 TO MAX.COMPANIES
                            IF RELEASE.RECORD(EB.CON.COMPANIES.SELECTED)<1,PGM.COUNT,CMPX> THEN
                                RELEASE.RECORD(EB.CON.RUN.PGM)<1,PGM.COUNT,CMPX> = 1
                            END ELSE
                                RELEASE.RECORD(EB.CON.RUN.PGM)<1,PGM.COUNT,CMPX> = 0
                            END
                        NEXT CMPX
                    NEXT PGM.COUNT
                    RELEASE.RECORD(EB.CON.OVERRIDES) = ''
*
* If a record is being released to F.ARCHIVE, clear the run details fields and the purge date
*
                CASE FILENAME = 'F.ARCHIVE'
                    RELEASE.RECORD(ARC.PURGE.DATE) = ''
                    RELEASE.RECORD(ARC.$ARC.PATHNAME) = ''
                    RELEASE.RECORD(ARC.FILE.TYPE) = ''
                    RELEASE.RECORD(ARC.MODULUS) = ''
* GB9900040s
* Change ARC.TIME.STARTED TO ARC.COMPANY.RUN.IN

                    FOR X = ARC.COMPANY.RUN.IN TO ARC.TIME.ENDED
* GB9900040e
                        RELEASE.RECORD(X) = ''
                    NEXT X
*
* If a record is being released to F.PGM.FILE, clear the run info field
*
                CASE FILENAME = 'F.PGM.FILE'
*                  RELEASE.RECORD(EB.PGM.RUN.INFO) = '' ; * Field no longer exists.
*
* If the record is being released to F.STANDARD.SELECTION, clear down the user fields (these are then
* copied from the live record if there is one)
* Don't clear the user fields for a NOFILE SS when released via packager
*
                CASE FILENAME = 'F.STANDARD.SELECTION'
                    IF EB.Upgrade.getReleaseNo() NE 'DL.RESTORE' AND EB.Upgrade.getFnT24UpdateRelease() NE 'F.T24.MODEL.PACKAGES' THEN
                        FOR X = SSL.USR.FIELD.NAME TO SSL.USR.REL.FILE
                            RELEASE.RECORD(X) = ''
                        NEXT X
                    END     ;* CI_10004888  S/E
*
*
* GB9600979 Clear down then run history from the conversion details record.
*
                CASE FILENAME = 'F.CONVERSION.DETAILS'
                    RELEASE.RECORD(EB.CONV.CO.SELECTED) = ''
                    RELEASE.RECORD(EB.CONV.RUN.PGM) = ''
                    RELEASE.RECORD(EB.CONV.ERROR.MSG) = ''
                    RELEASE.RECORD(EB.CONV.RUN.INFO) = ''
                    RELEASE.RECORD(EB.CONV.RUN.FROM) = ''
                    RELEASE.RECORD(EB.CONV.RUN.AT.REL) = ''
                    RELEASE.RECORD(EB.CONV.OVERRIDE) = ''
*
* If the record is being released to DB.SCRAMBLE.DEFINE, clear down the run history (these fields are
* then copied from the live record, if there is one
*
                CASE FILENAME = 'F.DB.SCRAMBLE.DEFINE'
                    FOR X = DB.SCR.RUN.USER TO DB.SCR.RUN.DATE
                        RELEASE.RECORD(X) = ''
                    NEXT X
*
** When releasing EU.CONVERSION.PARAM we should clear the run history fields
*
                CASE FILENAME = 'F.EU.CONVERSION.PARAM'
                    FOR X = EU.CP.CONVERSION.COMP TO EU.CP.RUN.INFO
                        RELEASE.RECORD(X) = ''
                    NEXT X

                CASE FILENAME = 'F.OVERRIDE'
                    IF EB.Upgrade.getReleaseNo() <> "DL.RESTORE" AND EB.Upgrade.getFnT24UpdateRelease() NE 'F.T24.MODEL.PACKAGES' THEN    ;* If not released through packager then clear the fileds
                        RELEASE.RECORD(EB.OR.APPLICATION) = ''
                        RELEASE.RECORD(EB.OR.CLASS) = ''
                        RELEASE.RECORD(EB.OR.DETAIL) = ''
                        RELEASE.RECORD(EB.OR.DISPO) = ''
                    END
*
                CASE FILENAME = 'F.EB.MESSAGE.CLASS'
                    RELEASE.RECORD(EB.MC.CLASS.ID) = ''
*
* Clear the user defined fields
                CASE FILENAME = 'F.DE.MESSAGE'
                    ignoreDeClearing = ''       ;* Variable to ignore DE.MESSAGE field clearing
                    IF EB.Upgrade.getReleaseNo() NE 'DL.RESTORE' AND EB.Upgrade.getFnT24UpdateRelease() NE 'F.T24.MODEL.PACKAGES'  THEN
                        IF NOT(R.SPF.SYSTEM<SPF.PREVIOUS.RELEASE>[1,1] EQ 'G' AND R.SPF.SYSTEM<SPF.PREVIOUS.RELEASE>[2,4] LT '13.1') THEN
                            AUTHORISER.MATCH = "0N1N_1X0X":@VM:"'SY_'1X0X"    ;*Authorizer name could be SESSION.NO_USER.NAME/SY_USER.NAME
                            FOR X = DE.MSG.USR.FIELD.NAME TO DE.MSG.USR.MANDATORY
                                IF  RELEASE.RECORD(X) MATCHES AUTHORISER.MATCH THEN     ;* Check authoriser pattern in every DE.MESSAGE
                                    ignoreDeClearing = 1  ;* No need to clear the fields if authoriser pattern matches
                                END ELSE
                                    RELEASE.RECORD(X) = ''
                                END
                            NEXT X
                        END
                    END
*
                CASE FILENAME = 'F.DE.MAPPING'
                    IF EB.Upgrade.getReleaseNo() NE 'DL.RESTORE' AND EB.Upgrade.getFnT24UpdateRelease() NE 'F.T24.MODEL.PACKAGES' THEN
                        IF NOT(R.SPF.SYSTEM<SPF.PREVIOUS.RELEASE>[1,1] EQ 'G' AND R.SPF.SYSTEM<SPF.PREVIOUS.RELEASE>[2,4] LT '13.1') THEN
                            FOR X = DE.MAP.USR.INPUT.POS TO DE.MAP.RESERVED.11
                                RELEASE.RECORD(X)= ''
                            NEXT X
                        END
                    END

                CASE FILENAME = 'F.DE.FORMAT.PRINT'
                    REC.ID = RECORD.ID
                    DOT3 = INDEX(REC.ID, '.' , 3)
                    LANG = REC.ID[DOT3 + 1, LEN(REC.ID)]
                    LOCATE LANG IN T.LANGUAGE < 1 > SETTING IND ELSE RETURN

                CASE FILENAME = 'F.SY.PRODUCT.DEFINITION' ;* If the filename is "F.SY.PRODUCT.DEFINITION" then releases the corresponding records to "IHLD" status
                    RELEASE.REC.STATUS = 'IHLD'

                CASE FILENAME = 'F.OFS.SOURCE'
                    IF EB.Upgrade.getReleaseNo() NE 'DL.RESTORE' AND EB.Upgrade.getFnT24UpdateRelease() NE 'F.T24.MODEL.PACKAGES' THEN ;* If not comes via DL pack restoration and model packages
                        IF RELEASE.RECORD(OFS.SRC.GENERIC.USER) THEN ;* If user specified
                            RELEASE.RECORD(OFS.SRC.GENERIC.USER) = OPERATOR ;* Default user
                        END
                    END
                CASE FILENAME = 'F.CZ.CDP.DATA.DEFINITION' ;* Fix_for_CDP.DATA.DEFINITION
                    IF EB.Upgrade.getReleaseNo() NE 'DL.RESTORE' AND EB.Upgrade.getFnT24UpdateRelease() NE 'F.T24.MODEL.PACKAGES' THEN
                        FOR X = CZ.CDS.USR.FIELD.NAME  TO CZ.CDS.USR.EXCLUDE
                            RELEASE.RECORD(X) = ''
                        NEXT X
                        RELEASE.RECORD(CZ.CDS.SYS.EXCLUDE) = ''
                    END
                CASE FILENAME = 'F.T24.TABLE.RESTRUCTURE'
                    IF EB.Upgrade.getReleaseNo() EQ 'T24.PRE.RELEASE' THEN              ;* records released via T24.PRE.RELEASE for offline upgrade
                        RELEASE.RECORD(EB.Upgrade.T24TableRestructure.TabRestrRestructureStatus) = 'READY'                ;* need status to be READY so that restructure service can pick up for restructuring.
                    END
            END CASE

*
* Write record for all files other than VOC and F.BATCH
*
            GOSUB WRITE.RECORDS
*
    END CASE
    
*
RETURN
*************************************************************************
CHECK.MULTI.COMPANY.AND.RELEASE:
*
    F.BATCH.NEW.COMPANY = EB.Upgrade.getFBatchNewCompany()
    F.BATCH.NEW.COMPANY.NAU = EB.Upgrade.getFBatchNewCompanyNau()
    RECORD.EXISTS = 1
    EXCLUDE.MODULES = ''        ;* Initialise before Usage
    EXCLUDE.MODULES.COUNT = ''  ;* Initialise before Usage
    READ R.BATCH.NEW.COMPANY FROM F.BATCH.NEW.COMPANY,RECORD.ID ELSE
        READ R.BATCH.NEW.COMPANY FROM F.BATCH.NEW.COMPANY.NAU,RECORD.ID ELSE RECORD.EXISTS = 0
    END

    IF RECORD.EXISTS THEN
        FILE.CLASSIFICATION = R.BATCH.NEW.COMPANY<EB.BNC.LEVEL>
        BATCH.APP = R.BATCH.NEW.COMPANY<EB.BNC.PRODUCT>
        EXCLUDE.MODULES = R.BATCH.NEW.COMPANY<EB.BNC.EXCLUDE.MODULE>        ;* get the exclude modules list
        EXCLUDE.MODULES.COUNT = DCOUNT(EXCLUDE.MODULES,@VM)                 ;* get the count of exclude modules
    END ELSE
        FILE.CLASSIFICATION = 'INT'
        BATCH.APP = 'EB'
    END
    BATCH.MNEMONICS = ''
    EXC.MOD.VALID = 1       ;* Initialise before Usage
    IF MULTI.COMPANY THEN
*
* Multi-company environment
*
        IF FILE.CLASSIFICATION = 'INT' THEN
            APPLIC.VALID = 1
            LOCATE BATCH.APP IN rMasterCompany(EB.COM.APPLICATIONS)<1,1> SETTING X ELSE APPLIC.VALID = 0 ;*check for the avilablity of product in master company.
            FOR EMC = 1 TO EXCLUDE.MODULES.COUNT
                LOCATE EXCLUDE.MODULES<1,EMC> IN rMasterCompany(EB.COM.APPLICATIONS)<1,1> SETTING EXC.MOD.VALID THEN ;*check for the availablity of exclude module in master company.
                    EXC.MOD.VALID = 0       ;* Make it as null
                    BREAK           ;* If the exclude module is available then don't release the record
                END
            NEXT
            IF APPLIC.VALID AND EXC.MOD.VALID THEN
*
                MULTI.CO.TEST = INDEX(RECORD.ID,"/",1)      ;* Record id is checked for the prefix
                IF MULTI.CO.TEST THEN
                    L.MNEMONIC = LEN(FIELD(RECORD.ID,"/",1))
                    IF L.MNEMONIC = 3 AND MULTI.CO.TEST = 4 THEN
                        RECORD.ID = FIELD(RECORD.ID,"/",2)
                    END
                END

                BEGIN CASE
                    CASE  FILENAME = "F.TSA.SERVICE" AND RECORD.ID = "TSM"          ;* in this case don't prefix the Mnemonic
                    CASE  FILENAME = "F.TSA.SERVICE" AND (RECORD.ID[1,3] = "COB")   ;* the COB record don't prefix with company mnemonic
                    CASE  FILENAME = "F.TSA.SERVICE" AND INDEX(RECORD.ID,"TI.DATE.CHANGE.SERVICE",1)     ;* don't prefix date change service with company mnemonic
                    CASE  FILENAME = "F.TSA.SERVICE" AND RECORD.ID = "ONLINE.SERVICE"
                        SelectStmt = 'SELECT F.TSA.SERVICE WITH @ID LIKE "COB-..."'                     ;*get the list of company group ids
                        CALL EB.READLIST (SelectStmt, KeyList, ListName, Selected, SystemReturnCode)
                        IF KeyList THEN
                            totCnt = DCOUNT(KeyList,@FM)        ;*fetch the total count of company/company group COB ids
                            FOR cnt = 1 TO totCnt
                                RECORD.ID = 'ONLINE.SERVICE-':FIELD(KeyList<cnt>,'-',2)     ;*release ONLINE.SERVICE records accordingly
                                GOSUB WRITE.RECORDS
                            NEXT cnt
                            RECORD.ID = "ONLINE.SERVICE"        ;*restore the id to release the original ONLINE.SERVICE record
                        END
                    CASE  REM.COMPANY.MNE
                        RECORD.ID = REM.COMPANY.MNE:'/':RECORD.ID         ;* add the master company mnemonic
                END CASE
*
* If batch process is INT level, prefix id with company mnemonic : '/' where the company mnemonic is taken
* from the MASTER record on COMPANY.CHECK.  Allow for this to be null (e.g. in TEMP.RELEASE)
*
                GOSUB WRITE.RECORDS
            END
        END ELSE
*
* If level is not 'INT', build up a list of all mnemonic prefixes which should be used for outputting batch
* records (only select non-consolidation and non-reporting companies)
*
            APOS = ''
            IS.SPLIT.MODULE = 0                 ;* Initialise before usage
            IF serviceName MATCHES 'T24.UPGRADE.PRIMARY':@VM:'T24.UPGRADE':@VM:'T24.FULL.UPGRADE' THEN   ;* Check if the services matches T24.UPGRADE or T24.UPGRADE.PRIMARY
                SPLIT.MODULE = EB.Upgrade.getModulesSplit()          ;* Get the list of split modules with parent modules
                CHANGE @VM TO '*' IN SPLIT.MODULE      ;* Change @VM to '*' to get the exact batch new company product
                FINDSTR '*':BATCH.APP IN SPLIT.MODULE SETTING BATCH.APP.AF,BATCH.APP.AV THEN    ;* Check if the batch new company product is present in split module list
                    IS.SPLIT.MODULE = 1         ;* Set the flag to 1
                    PARENT.MODULE = FIELD(SPLIT.MODULE<BATCH.APP.AF>,'*',1)  ;* Extract the parent module with AF position
                END
            END
            LOOP
                REMOVE ID FROM REL.COMPANY.LIST SETTING APOS
            WHILE ID:APOS
                MATREAD R.COMPANY.CHK FROM F.COMPANY,ID ELSE MAT R.COMPANY.CHK = ''
                IF R.COMPANY.CHK(EB.COM.CONSOLIDATION.MARK) MATCHES "N":@VM:"A" THEN                                ;* When CONSOLIDATION.MARK is set to "N" or "A"
                    MAT R.COMPANY = MAT R.COMPANY.CHK
                    YCOMPANY.CODE = ID
                    GOSUB INIT.FIN.MNE
                    $INSERT I_MNEMONIC.CALCULATION
                    IF NOT(IS.SPLIT.MODULE) THEN   ;* Check whether the flag is set or not
                        LOCATE BATCH.APP IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING X ELSE MNEMONIC = ''    ;* Locate batch new company product in company record
                    END ELSE
                        LOCATE PARENT.MODULE IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING X ELSE MNEMONIC = ''    ;* Locate parent module in company record
                    END
                    FOR EMC = 1 TO EXCLUDE.MODULES.COUNT
                        LOCATE EXCLUDE.MODULES<1,EMC> IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING EXC.MOD.VALID THEN ;*check for the availablity of exclude module in company record
                            EXC.MOD.VALID = 0    ;* Make it as null
                            BREAK       ;* If the exclude module is available then don't release the record
                        END
                    NEXT EMC
                    IF MNEMONIC AND EXC.MOD.VALID THEN
                        LOCATE MNEMONIC IN BATCH.MNEMONICS<1> SETTING ALREADY.SAVED
                        ELSE BATCH.MNEMONICS<-1> = MNEMONIC
                    END
                END
            REPEAT  ;*GLOBUS_BG_100006614 -E
            
            NO.OF.BATCH.RECORDS = COUNT(BATCH.MNEMONICS,@FM) + (BATCH.MNEMONICS <> '')
            BATCH.REC.COUNT = 1
            batchRecId = RECORD.ID          ;* Get the record id
            LOOP UNTIL BATCH.REC.COUNT > NO.OF.BATCH.RECORDS
                RECORD.ID = BATCH.MNEMONICS<BATCH.REC.COUNT>:'/':batchRecId         ;* Add mnemonic to the batch id
                MAT SAVED.RELEASE.RECORD = MAT RELEASE.RECORD
                GOSUB WRITE.RECORDS
                IF isApplyTransacStds THEN       ;* no need to check other company batch records if violation identified for same batch in first company
                    EXIT
                END
                MAT RELEASE.RECORD = MAT SAVED.RELEASE.RECORD
                BATCH.REC.COUNT += 1
            REPEAT
        END
*
    END ELSE
*
* Single company environment
*
        APPLIC.VALID = 1
        LOCATE BATCH.APP IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING X ELSE APPLIC.VALID = 0
        FOR EMC = 1 TO EXCLUDE.MODULES.COUNT
            LOCATE EXCLUDE.MODULES<1,EMC> IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING EXC.MOD.VALID THEN ;*check for the availablity of exclude module in company record
                EXC.MOD.VALID = 0      ;* Make it as null
                BREAK               ;* If the exclude module is available then don't release the record
            END
        NEXT EMC
        IF APPLIC.VALID AND EXC.MOD.VALID THEN
            GOSUB WRITE.RECORDS
        END
    END

RETURN
**********************************************************************************
INIT.FIN.MNE:
*
*-- Just populate here to avoid crash while opening the fin level file.
    IF R.COMPANY(EB.COM.FINANCIAL.MNE) = "" THEN
        R.COMPANY(EB.COM.FINANCIAL.MNE) = R.COMPANY(EB.COM.MNEMONIC)
        R.COMPANY(EB.COM.FINANCIAL.COM) = YCOMPANY.CODE
    END

RETURN
**********************************************************************************
*
WRITE.RECORDS:
*
* Actually writes records to live/unauthorised file as appropriate
*
* This routine is called once for each record, apart from batch records where one record on the
* RELEASE.RECORDS file would generate multiple records for multi-company environments
*

    F.REPLACED.RECORDS = EB.Upgrade.getFReplacedRecords()

    LIVE.RECORD.EXISTS = 1
    MATREAD LIVE.RECORD FROM LOCAL.FILE,RECORD.ID ELSE
        MAT LIVE.RECORD = ""
        LIVE.RECORD.EXISTS = 0
    END
    IF INAU.FILE.EXISTS THEN
        INAU.RECORD.EXISTS = 1
        MATREAD INAU.RECORD FROM LOCAL.INAU.FILE,RECORD.ID ELSE
            MAT INAU.RECORD = ""
            INAU.RECORD.EXISTS = 0
        END
    END
    

*
* If an unauthorised file exists the audit fields on the live record must be amended to correspond the
* values on the unauthorised record. Determine position of audit fields so that they can be set correctly.
* If a default % record is to be released with no AUDIT fields we should actually delete it as it will be
* rebuilt anyway. If there are no AUDIT fields and the record is a default ENQUIRY we should delete it
*
    DELETE.RELEASE.REC = ""   ;* Set if delete required
    MATBUILD R.RECORD FROM RELEASE.RECORD             ;* records released in physical order
    GOSUB DETERMINE.V         ;* Determine position of CURR.NO etc.
    
*** Merge Record:
    LIVNAU = ""                ;* Initialise before use
    BEGIN CASE
        CASE INAU.RECORD.EXISTS EQ 1                ;* First preference INAU
            MATBUILD LIVNAU FROM INAU.RECORD
        CASE LIVE.RECORD.EXISTS EQ 1                ;* Live record
            MATBUILD LIVNAU FROM LIVE.RECORD
    END CASE
    
*  We dont want to do the merge and parameter access rules for Zero Bank and if temenos license contains TMNS
    IF NOT(R.SPF.SYSTEM<SPF.LICENSE.CODE>[6,4] EQ 'TMNS') AND NOT(R.SYSGEN.REC<EB.SYG.SYSGEN.TYPE> EQ 'ZEROBASE') THEN
        IF LIVNAU THEN                                  ;* If only there is an existing record available
            LOCAL.APPL = FIELD(FIELD(FILENAME , ".",2,999),'$',1)    ;* Extract application name
            EB.Upgrade.MergeReleaseRecord(LOCAL.APPL, RECORD.ID, '', LIVNAU, R.RECORD, '', '')  ;* Merge api
            MATPARSE RELEASE.RECORD FROM R.RECORD                    ;* Build release record array
        END
    END
***
    BEGIN CASE
        CASE EB.Upgrade.getReleaseNo() = "T24.PRE.RELEASE" AND  LIVE.RECORD.EXISTS       ;* if called from T24.PRE.RELEASE and Live record already exists
            RETURN      ;* do nothing

* Do nothing
        CASE MISSING.AUDIT.FIELD
            IF FILENAME = "F.ENQUIRY" AND RECORD.ID[1,1] = "%" THEN
                DELETE.RELEASE.REC = 1
            END
    END CASE
*
    PRINT "Transferring ":FILENAME:">":RECORD.ID
    IF DELETE.RELEASE.REC THEN
        PRINT "Deleting record ":RECORD.ID:" from ":FILENAME
        IF INAU.FILE.EXISTS THEN
            DELETE LOCAL.INAU.FILE, RECORD.ID     ;* Not needed
            IF INAU.RECORD.EXISTS THEN  ;* Write to replaced records file
                MATWRITE INAU.RECORD ON F.REPLACED.RECORDS:"$NAU>":RECORD.ID
            END
        END
        IF LIVE.RECORD.EXISTS THEN
            DELETE LOCAL.FILE,RECORD.ID
            MATWRITE LIVE.RECORD TO F.REPLACED.RECORDS, FILENAME:">":RECORD.ID
        END
        GOSUB DELETE.HISTORY.RECORDS    ;* Clear the history records
*
    END ELSE
*
* For W type fields, audit fields are to be updated.
        IF INAU.FILE.EXISTS OR R.PGM.FILE<EB.PGM.TYPE> EQ "W" THEN      ;*
            RV = V  ;* Save it - LIVE may have a different layout
*
            GOSUB checkTransactStandards ; *
            
            IF LIVE.RECORD.EXISTS THEN
                MATBUILD R.RECORD FROM LIVE.RECORD
                GOSUB DETERMINE.V
                LV = V        ;* Layout of live record
                RELEASE.RECORD(RV-2) = LIVE.RECORD(LV-2)    ;* department code
                RELEASE.RECORD(RV-3) = LIVE.RECORD(LV-3)    ;* company code
                IF NUM(LIVE.RECORD(LV-7)) THEN
                    RELEASE.RECORD(RV-7) = LIVE.RECORD(LV-7)+1        ;* current number
                END

                BEGIN CASE

                    CASE FILENAME = 'F.LANGUAGE'
                        RELEASE.RECORD(EB.LAN.LOCAL.REF) = LIVE.RECORD(EB.LAN.LOCAL.REF)            ;*Assiging LRT values of live record to release record

                    CASE FILENAME = 'F.TSA.SERVICE'

                        RELEASE.RECORD(TS.TSM.SERVER.NAME) = LIVE.RECORD(TS.TSM.SERVER.NAME)
                        RELEASE.RECORD(TS.TSM.USER) = LIVE.RECORD(TS.TSM.USER)
                        RELEASE.RECORD(TS.TSM.SERVICE.CONTROL) = LIVE.RECORD(TS.TSM.SERVICE.CONTROL)
                        RELEASE.RECORD(TS.TSM.REVIEW.TIME) = LIVE.RECORD(TS.TSM.REVIEW.TIME)
                        RELEASE.RECORD(TS.TSM.TIME.OUT) =  LIVE.RECORD(TS.TSM.TIME.OUT)
                        RELEASE.RECORD(TS.TSM.DATE) = LIVE.RECORD(TS.TSM.DATE)
                        RELEASE.RECORD(TS.TSM.STARTED) = LIVE.RECORD(TS.TSM.STARTED)
                        RELEASE.RECORD(TS.TSM.STOPPED) = LIVE.RECORD(TS.TSM.STOPPED)
                        RELEASE.RECORD(TS.TSM.ELAPSED) = LIVE.RECORD(TS.TSM.ELAPSED)
                        RELEASE.RECORD(TS.TSM.TRANSACTIONS) = LIVE.RECORD(TS.TSM.TRANSACTIONS)
                        RELEASE.REC.STATUS = "INAU"

                        IF EB.Upgrade.getReleaseNo() = 'DL.RESTORE'  THEN                                                   ;* While restoring DL pack
                            RELEASE.RECORD(TS.TSM.WORK.PROFILE) = LIVE.RECORD(TS.TSM.WORK.PROFILE)            ;* Assiging WORK.PROFILE value of live record to relased record
                        END

                    CASE FILENAME = 'F.BATCH'

*
* If a batch record is being released, default the following fields from
* the live record:
*
*      Default print, batch environment, department code,
*      next run date, printer name, last run date, user
*
* Also, if "data" changes, set status on released record to IHLD
                        
                        BATCH.STAGE = RELEASE.RECORD(BAT.BATCH.STAGE)    ;* new code
                        LIVE.BATCH.STAGE = LIVE.RECORD(BAT.BATCH.STAGE)    ;* new code
                        IF isTransactStdsInstalled AND BATCH.STAGE AND NOT(isL1DataRelease) THEN    ;* check whether transact standards to be applied
                            isApplyTransacStds = 1;*               Don't allow new L3 Jobs intended for COB and also dont proceed for other company batch
                        END
                        RELEASE.RECORD(BAT.DEFAULT.PRINTER) = LIVE.RECORD(BAT.DEFAULT.PRINTER)
                        RELEASE.RECORD(BAT.BATCH.ENVIRONMENT) = LIVE.RECORD(BAT.BATCH.ENVIRONMENT)
                        RELEASE.RECORD(BAT.DEPARTMENT.CODE) = LIVE.RECORD(BAT.DEPARTMENT.CODE)
*
                        MAX.JOBS = COUNT(RELEASE.RECORD(BAT.JOB.NAME),@VM) + (RELEASE.RECORD(BAT.JOB.NAME) <> '')
                        FOR JOB.COUNT = 1 TO MAX.JOBS
                            IF RELEASE.RECORD(BAT.JOB.NAME)<1,JOB.COUNT> = LIVE.RECORD(BAT.JOB.NAME)<1,JOB.COUNT> THEN
                                LIVE.JOB.COUNT = JOB.COUNT
                            END ELSE
                                LOCATE RELEASE.RECORD(BAT.JOB.NAME)<1,JOB.COUNT> IN LIVE.RECORD(BAT.JOB.NAME)<1,1> SETTING LIVE.JOB.COUNT ELSE ;* new JOB being added
                                    LIVE.JOB.COUNT = 0
                                    IF isApplyTransacStds THEN       ;* dont allow new L3 Job being added for COB batch
                                        RETURN                       ;* dont relese current batch record
                                    END
                                END
                            END
                        
                            IF isApplyTransacStds AND NOT(LIVE.BATCH.STAGE) THEN  ;* dont allow if existing service batch converting to cob batch in L3
                                RETURN                               ;* dont relese current batch record
                            END
                        
                            IF LIVE.JOB.COUNT THEN
                                RELEASE.RECORD(BAT.NEXT.RUN.DATE)<1,JOB.COUNT> = LIVE.RECORD(BAT.NEXT.RUN.DATE)<1,LIVE.JOB.COUNT>
                                RELEASE.RECORD(BAT.PRINTER.NAME)<1,JOB.COUNT> = LIVE.RECORD(BAT.PRINTER.NAME)<1,LIVE.JOB.COUNT>
                                RELEASE.RECORD(BAT.LAST.RUN.DATE)<1,JOB.COUNT> = LIVE.RECORD(BAT.LAST.RUN.DATE)<1,LIVE.JOB.COUNT>
                                RELEASE.RECORD(BAT.USER)<1,JOB.COUNT> = LIVE.RECORD(BAT.USER)<1,LIVE.JOB.COUNT>
                                RELEASE.RECORD(BAT.FREQUENCY)<1,JOB.COUNT> = LIVE.RECORD(BAT.FREQUENCY)<1,LIVE.JOB.COUNT>
                                
                                IF RELEASE.RECORD(BAT.DATA)<1,JOB.COUNT> <> LIVE.RECORD(BAT.DATA)<1,LIVE.JOB.COUNT> THEN
                                    IF isOnlineUpgradePrimary THEN
                                        RELEASE.REC.STATUS = "INAU"     ;*set the status to INAU for records released via primary upgrade service as part of online upgrade
                                    END ELSE
                                        RELEASE.REC.STATUS = "IHLD"
                                    END
                                END
                            END
                        NEXT JOB.COUNT
                      
                    CASE FILENAME = 'F.LOCAL.REF.TABLE'

                        ignoreLrfAddition = '' ;*flag to denote whether existing local ref table needs to be amended
                        localTableNo = ''
                        BEGIN CASE
                            CASE INAU.RECORD.EXISTS ;*First check with INAU record
                                localTableNo = INAU.RECORD(EB.LRT.LOCAL.TABLE.NO)
                                subAssocCode = INAU.RECORD(EB.LRT.SUB.ASSOC.CODE)
                            CASE LIVE.RECORD.EXISTS ;* check with live record
                                localTableNo = LIVE.RECORD(EB.LRT.LOCAL.TABLE.NO)
                                subAssocCode = LIVE.RECORD(EB.LRT.SUB.ASSOC.CODE)
                            CASE 1
                                ignoreLrfAddition = 1 ;*Just release to INAU without any modification
                        END CASE
                        newLocalTables = RELEASE.RECORD(EB.LRT.LOCAL.TABLE.NO)
                        newSubAssocCode = RELEASE.RECORD(EB.LRT.SUB.ASSOC.CODE)
                        Flag.SubAssoc ="0"
                        IF localTableNo THEN ;*when there is an existing record
                            noOfLocalTables = DCOUNT(newLocalTables,@VM) ;*Get the number of local table numbers that we are going to release
                            FOR table = 1 TO noOfLocalTables ;*For each local table number
                                IF newLocalTables<1,table> THEN
                                    LOCATE newLocalTables<1,table> IN localTableNo<1,1> SETTING locRefPos THEN ;*check whether the new local table number already present in the live record
                                        IF newSubAssocCode<1,table> NE subAssocCode<1,locRefPos> THEN ;*If there is a change in association code
                                            Flag.SubAssoc ="1" ;* Flag for sub assoc code changes
                                            subAssocCode<1,locRefPos> = newSubAssocCode<1,table>
                                            DEL newLocalTables<1,table> ;*delete it from releasing record
                                            DEL newSubAssocCode<1,table>
                                        END ELSE
                                            DEL newLocalTables<1,table> ;*delete it from releasing record
                                            DEL newSubAssocCode<1,table>
                                        END
                                        IF noOfLocalTables EQ table ELSE
                                            table = table - 1
                                        END
                                    END
                                END
                            NEXT table
                        END
                        BEGIN CASE
                            CASE ignoreLrfAddition ;*Its a new record so release the record as it is
                            CASE NOT(newLocalTables) AND NOT(Flag.SubAssoc)
                                RETURN ;*No change - so Don't modify anything
                            CASE NOT(ignoreLrfAddition) AND newLocalTables  ;*Go ahead and add local table numbers and sub assoc code at the bottom
                              
                                IF localTableNo THEN
                                    RELEASE.RECORD(EB.LRT.LOCAL.TABLE.NO) = localTableNo:@VM:newLocalTables
                                    cntLocalTableNo = DCOUNT(localTableNo,@VM) - 1  ;* get the number of local table numbers
                                    cntSubAssocCode = DCOUNT(subAssocCode,@VM) - 1  ;* get the number of sub assoc code
                                    IF cntSubAssocCode EQ '-1' THEN
                                        cntSubAssocCode = 0     ;* if it is a negative value , assign it as zero
                                    END
                                    diffCnt = cntLocalTableNo - cntSubAssocCode  ;* take the difference
                                    RELEASE.RECORD(EB.LRT.SUB.ASSOC.CODE) = subAssocCode:STR(@VM,diffCnt):@VM:newSubAssocCode
                                END ELSE
                                    RELEASE.RECORD(EB.LRT.LOCAL.TABLE.NO) = newLocalTables
                                    RELEASE.RECORD(EB.LRT.SUB.ASSOC.CODE) = newSubAssocCode
                                END
                            CASE NOT(ignoreLrfAddition) AND NOT(newLocalTables) AND Flag.SubAssoc ;* Go ahead for amenment the sub assoc code.
                                IF localTableNo THEN
                                    RELEASE.RECORD(EB.LRT.LOCAL.TABLE.NO) = localTableNo
                                    RELEASE.RECORD(EB.LRT.SUB.ASSOC.CODE) = subAssocCode
                                END
                        END CASE
*
                    CASE FILENAME = 'F.CONVERSION.PGMS'
*
* If releasing records to F.CONVERSION.PGMS, copy fields from the live
* record if the program has already been run in any of the companies
*
                        MAX.JOBS = COUNT(RELEASE.RECORD(EB.CON.PROGRAM.NAME),@VM) + (RELEASE.RECORD(EB.CON.PROGRAM.NAME) <> '')
*
                        FOR JOB.COUNT = 1 TO MAX.JOBS
*
                            LOCATE RELEASE.RECORD(EB.CON.PROGRAM.NAME)<1,JOB.COUNT> IN LIVE.RECORD(EB.CON.PROGRAM.NAME)<1,1> SETTING LIVE.JOB.COUNT ELSE LIVE.JOB.COUNT = 0
*
                            IF LIVE.JOB.COUNT THEN
*
* Check whether the job has been run already in any of the companies selected.  If it has or it was
* decided not to run it (RUN flag set to 0), update the record with the values from the live record
*
                                MAX.LIVE.COS = COUNT(LIVE.RECORD(EB.CON.COMPANIES.SELECTED)<1,LIVE.JOB.COUNT>,@SM) + (LIVE.RECORD(EB.CON.COMPANIES.SELECTED)<1,LIVE.JOB.COUNT> <> '')
                                PGM.ALREADY.RUN = 0
                                FOR LIVE.CO.COUNT = 1 TO MAX.LIVE.COS
*
                                    IF LIVE.RECORD(EB.CON.RUN.PGM)<1,LIVE.JOB.COUNT,LIVE.CO.COUNT> = '2' THEN PGM.ALREADY.RUN = 1
                                    IF LIVE.RECORD(EB.CON.RUN.PGM)<1,LIVE.JOB.COUNT,LIVE.CO.COUNT> = '0' THEN PGM.ALREADY.RUN = 1
                                    IF LIVE.RECORD(EB.CON.RUN.STATUS)<1,LIVE.JOB.COUNT,LIVE.CO.COUNT> THEN PGM.ALREADY.RUN = 1
                                    IF LIVE.RECORD(EB.CON.ERROR.MSG)<1,LIVE.JOB.COUNT,LIVE.CO.COUNT> THEN PGM.ALREADY.RUN = 1
                                NEXT LIVE.CO.COUNT
*
                                IF PGM.ALREADY.RUN THEN
*
                                    FOR DUMMY.AF = EB.CON.PROGRAM.NAME TO EB.CON.RUN.INFORMATION
                                        RELEASE.RECORD(DUMMY.AF)<1,JOB.COUNT> = LIVE.RECORD(DUMMY.AF)<1,LIVE.JOB.COUNT>
                                    NEXT DUMMY.AF
                                END
*
* If companies selected was previously null but are now present (i.e. the product has been installed
* since the last release), set the RUN flag to 0 (not to be run).
*
                                IF MAX.LIVE.COS = 0 THEN RELEASE.RECORD(EB.CON.RUN.PGM)<1,JOB.COUNT,1> = '0'
                            END
                        NEXT JOB.COUNT
*
* Copy override details from live record
*
                        RELEASE.RECORD(EB.CON.OVERRIDES) = LIVE.RECORD(EB.CON.OVERRIDES)
*
                    CASE FILENAME = 'F.STANDARD.SELECTION'
* If releasing records to F.STANDARD.SELECTION, copy the user fields from the live record
* Whenever the data records gets released through T24.MODEL.PACKAGES and DL.RESTORE, RELEASE.RECORD will overwrite the LIVE record.
* The Final record will be the one released through package installer.
*
                        IF EB.Upgrade.getReleaseNo() NE 'DL.RESTORE' AND EB.Upgrade.getFnT24UpdateRelease() NE 'F.T24.MODEL.PACKAGES' THEN      ;*  CI_10004888 S/E
                            RELEASE.RECORD(SSL.USR.FIELD.NAME) = LIVE.RECORD(SSL.USR.FIELD.NAME)
                            RELEASE.RECORD(SSL.USR.TYPE) = LIVE.RECORD(SSL.USR.TYPE)
                            RELEASE.RECORD(SSL.USR.FIELD.NO) = LIVE.RECORD(SSL.USR.FIELD.NO)
                            RELEASE.RECORD(SSL.USR.VAL.PROG) = LIVE.RECORD(SSL.USR.VAL.PROG)
                            RELEASE.RECORD(SSL.USR.CONVERSION) = LIVE.RECORD(SSL.USR.CONVERSION)
                            RELEASE.RECORD(SSL.USR.DISPLAY.FMT) = LIVE.RECORD(SSL.USR.DISPLAY.FMT)
                            RELEASE.RECORD(SSL.USR.ALT.INDEX) = LIVE.RECORD(SSL.USR.ALT.INDEX)
                            RELEASE.RECORD(SSL.USR.IDX.FILE) = LIVE.RECORD(SSL.USR.IDX.FILE)
                            RELEASE.RECORD(SSL.USR.INDEX.NULLS) = LIVE.RECORD(SSL.USR.INDEX.NULLS)
                            RELEASE.RECORD(SSL.USR.SINGLE.MULT) = LIVE.RECORD(SSL.USR.SINGLE.MULT)
                            RELEASE.RECORD(SSL.USR.LANG.FIELD) = LIVE.RECORD(SSL.USR.LANG.FIELD)
                            RELEASE.RECORD(SSL.USR.CNV.TYPE) = LIVE.RECORD(SSL.USR.CNV.TYPE)
                            RELEASE.RECORD(SSL.USR.REL.FILE) = LIVE.RECORD(SSL.USR.REL.FILE)
                        END
*
*
                    CASE FILENAME = 'F.ARCHIVE'
*
* Copy run details and archive pathname from live record if it exists
*
                        RELEASE.RECORD(ARC.$ARC.PATHNAME) = LIVE.RECORD(ARC.$ARC.PATHNAME)
* Change ARC.TIME.STARTED TO ARC.COMPANY.RUN.IN
                        FOR X = ARC.COMPANY.RUN.IN TO ARC.TIME.ENDED
                            RELEASE.RECORD(X) = LIVE.RECORD(X)
                        NEXT X
*
*  if we are releasing a CONVERSION.DETAILS record then copy
* the run history from the live record.
*
                    CASE FILENAME = 'F.CONVERSION.DETAILS'
                        RELEASE.RECORD(EB.CONV.CO.SELECTED) = LIVE.RECORD(EB.CONV.CO.SELECTED)
                        RELEASE.RECORD(EB.CONV.RUN.PGM) = LIVE.RECORD(EB.CONV.RUN.PGM)
                        RELEASE.RECORD(EB.CONV.ERROR.MSG) = LIVE.RECORD(EB.CONV.ERROR.MSG)
                        RELEASE.RECORD(EB.CONV.RUN.INFO) = LIVE.RECORD(EB.CONV.RUN.INFO)
                        RELEASE.RECORD(EB.CONV.RUN.FROM) = LIVE.RECORD(EB.CONV.RUN.FROM)
                        RELEASE.RECORD(EB.CONV.RUN.AT.REL) = LIVE.RECORD(EB.CONV.RUN.AT.REL)
                        RELEASE.RECORD(EB.CONV.OVERRIDE) = LIVE.RECORD(EB.CONV.OVERRIDE)
*
** Copy run details from the Live record for EU.CONVERSION.PARAM
*
                    CASE FILENAME = 'F.EU.CONVERSION.PARAM'
                        FOR X = EU.CP.CONVERSION.COMP TO EU.CP.RUN.INFO
                            RELEASE.RECORD(X) = LIVE.RECORD(X)
                        NEXT X

                    CASE FILENAME = 'F.OVERRIDE'
                        IF EB.Upgrade.getReleaseNo() <> "DL.RESTORE" AND EB.Upgrade.getFnT24UpdateRelease() NE 'F.T24.MODEL.PACKAGES' THEN    ;* If not released through packager then clear the fileds
                            RELEASE.RECORD(EB.OR.APPLICATION) = LIVE.RECORD(EB.OR.APPLICATION)
                            RELEASE.RECORD(EB.OR.CLASS) = LIVE.RECORD(EB.OR.CLASS)
                            RELEASE.RECORD(EB.OR.DETAIL) = LIVE.RECORD(EB.OR.DETAIL)
                            RELEASE.RECORD(EB.OR.DISPO) = LIVE.RECORD(EB.OR.DISPO)
                        END
                        RELEASE.RECORD(EB.OR.NUMERIC.ID) = LIVE.RECORD(EB.OR.NUMERIC.ID)                            ;*For existing record NUMERIC.ID should be same as LIVE record for OVERRIDE

                    CASE FILENAME = 'F.EB.ERROR'
                        RELEASE.RECORD(EB.ERR.NUMERIC.ID) = LIVE.RECORD(EB.ERR.NUMERIC.ID)                          ;*For existing record NUMERIC.ID should be same as LIVE record for EB.ERROR

                    CASE FILENAME = 'F.EB.MESSAGE.CLASS'
                        RELEASE.RECORD(EB.MC.CLASS.ID) = LIVE.RECORD(EB.MC.CLASS.ID)

*
*
* GB9601042 Clear the ROUTINE field if the release record is from DE.MAPPING (only if released
* record is in G7.0.07 or beyond format - greater than 25 fields)
*
* If the current release is G7.0.06 or beyond, copy the ROUTINE from the live record
*
                    CASE FILENAME = 'F.DE.MAPPING'
* Whenever the data records gets released through T24.MODEL.PACKAGES and DL.RESTORE, RELEASE.RECORD will overwrite the LIVE record.
* The Final record will be the one released through package installer.
*
                        IF EB.Upgrade.getReleaseNo() NE 'DL.RESTORE' AND EB.Upgrade.getFnT24UpdateRelease() NE 'F.T24.MODEL.PACKAGES' THEN
                            IF NOT(R.SPF.SYSTEM<SPF.PREVIOUS.RELEASE>[1,1] EQ 'G' AND R.SPF.SYSTEM<SPF.PREVIOUS.RELEASE>[2,4] LT '13.1') THEN
* Only perform this section of code if this routine has not
* been called from the DL.DEFINE Data Library application.

                                IF LIVE.RECORD(DE.MAP.ROUTINE) THEN   ;* Check live record contains values in MAP.ROUTINE field
                                    RELEASE.RECORD(DE.MAP.ROUTINE) = LIVE.RECORD(DE.MAP.ROUTINE)   ;* Records should be released with values of MAP.ROUTINE field of live record
                                END   ;* Else the routine should be released with the available values of release record

* End Statement is moved down to process User fields for DE.MAPPING
* copy  the user fields from the user fields of live record.

                                FOR X = DE.MAP.USR.INPUT.POS TO DE.MAP.RESERVED.11
                                    RELEASE.RECORD(X)= LIVE.RECORD(X)
                                NEXT X
                            END
                        END
                    CASE FILENAME = 'F.DE.MESSAGE'
* Whenever the data records gets released through T24.MODEL.PACKAGES and DL.RESTORE, RELEASE.RECORD will overwrite the LIVE record.
* The Final record will be the one released through package installer.
*
                        IF EB.Upgrade.getReleaseNo() NE 'DL.RESTORE' AND NOT(ignoreDeClearing) AND EB.Upgrade.getFnT24UpdateRelease() NE 'F.T24.MODEL.PACKAGES' THEN   ;* If authoriser pattern not matched
                            IF NOT(R.SPF.SYSTEM<SPF.PREVIOUS.RELEASE>[1,1] EQ 'G' AND R.SPF.SYSTEM<SPF.PREVIOUS.RELEASE>[2,4] LT '13.1') THEN   ;* CI_10025932 S
                                FOR X = DE.MSG.USR.FIELD.NAME TO DE.MSG.USR.MANDATORY
                                    RELEASE.RECORD(X) = LIVE.RECORD(X)
                                NEXT X
                            END
                        END
                    CASE FILENAME = 'F.OFS.SOURCE'
                        IF EB.Upgrade.getReleaseNo() NE 'DL.RESTORE' AND EB.Upgrade.getFnT24UpdateRelease() NE 'F.T24.MODEL.PACKAGES' THEN ;* If not comes via DL pack restoration and model packages
                            RELEASE.RECORD(OFS.SRC.GENERIC.USER) = LIVE.RECORD(OFS.SRC.GENERIC.USER)
                        END
                    CASE FILENAME = 'F.CZ.CDP.DATA.DEFINITION' ;*Fix_for_CDP.DATA.DEFINITION
                        IF EB.Upgrade.getReleaseNo() NE 'DL.RESTORE' AND EB.Upgrade.getFnT24UpdateRelease() NE 'F.T24.MODEL.PACKAGES' THEN
                            FOR X = CZ.CDS.USR.FIELD.NAME  TO CZ.CDS.USR.EXCLUDE
                                RELEASE.RECORD(X) = LIVE.RECORD(X)
                            NEXT X
                            RELEASE.RECORD(CZ.CDS.SYS.EXCLUDE) = LIVE.RECORD(CZ.CDS.SYS.EXCLUDE)
                        END
                END CASE
            END ELSE
                THE.ID = ''
* For new record release, need to update incremented numeric id in F.LOCKING and error or override record if no live record exist
                BEGIN CASE
                    CASE FILENAME = 'F.EB.ERROR'
                        CALL EB.GET.OVE.ERR.ID( "ERROR" , THE.ID)                       ;* Get incremented numeric id in F.LOCKING for ERROR
                        RELEASE.RECORD(EB.ERR.NUMERIC.ID) = THE.ID                      ;* Update the incremented numeric id for ERROR

                    CASE FILENAME = 'F.OVERRIDE'
                        CALL EB.GET.OVE.ERR.ID( "OVERRIDE" , THE.ID)                     ;* Get incremented numeric id in F.LOCKING for OVERRIDE
                        RELEASE.RECORD(EB.OR.NUMERIC.ID) = THE.ID                         ;* Update the incremented numeric id for OVERRIDE
                    CASE FILENAME = 'F.BATCH'
                        BATCH.STAGE = RELEASE.RECORD(BAT.BATCH.STAGE)
                        IF isTransactStdsInstalled AND BATCH.STAGE AND NOT(isL1DataRelease) THEN    ;* check to apply transact standards
                            isApplyTransacStds = 1         ;* dont proceed for other company batch
                            RETURN   ;* Dont release new L3 COB batch record, just return back
                        END
                END CASE
*
* If there is no live record then any corresponding records on the history file must be deleted.
*
                GOSUB DELETE.HISTORY.RECORDS
                IF RELEASE.COMPNY.CODE NE COMPANY AND RELEASE.COMPNY.CODE THEN            ;* To avoid to release a wrong company
                    RELEASE.RECORD(RV-3) = RELEASE.COMPNY.CODE    ;* Default details from release
                END ELSE
                    RELEASE.RECORD(RV-3) = COMPANY    ;* Default details from release
                END
                RELEASE.RECORD(RV-2) = DEPT
                RELEASE.RECORD(RV-7) = 1
            END

            rAcctOfficer = ''
            daoId = RELEASE.RECORD(RV-2)
            CALL CACHE.READ('F.DEPT.ACCT.OFFICER',daoId,rAcctOfficer,Err)
            IF rAcctOfficer EQ ""  THEN
                RELEASE.RECORD(RV-2) = DEPT
            END
*
* If a batch record is being released and next run date is null, default next run date as follows:
* default to today's date if batch stage is not "S"; default to today's date is record is DATE.CHANGE;
* default to next working date if batch stage is "S"
*
            IF FILENAME = 'F.BATCH' THEN
                FREQ.DATES = RELEASE.RECORD(BAT.FREQUENCY)
                USER = RELEASE.RECORD(BAT.USER)
                JOBS = RELEASE.RECORD( BAT.JOB.NAME )
                NEXT.RUN.DATE = RELEASE.RECORD(BAT.NEXT.RUN.DATE)
                AV = 1
*
* If LAST.RUN.DATE is null (i.e. a new record), set LAST.RUN.DATE for call to B.CAL.RUN.DATE to last
* working day if batch stage is not "D".  If batch stage is "D" and record is not DATE.CHANGE, set
* LAST.RUN.DATE to today's date.  If record is DATE.CHANGE, set LAST.RUN.DATE to last working day
*
                MAX.JOBS = COUNT(RELEASE.RECORD(BAT.JOB.NAME),@VM) + (RELEASE.RECORD(BAT.JOB.NAME) <> '')
                LAST.RUN.DATE = ''
                TEMP.STAGE = RELEASE.RECORD(BAT.BATCH.STAGE)[1,1]
                FOR DATE.COUNT = 1 TO MAX.JOBS
                    IF RELEASE.RECORD(BAT.LAST.RUN.DATE)<1,DATE.COUNT> = '' THEN
                        IF TEMP.STAGE = 'D' THEN
                            IF RECORD.ID = 'DATE.CHANGE' THEN LAST.RUN.DATE<1,DATE.COUNT> = R.DATES(EB.DAT.LAST.WORKING.DAY)
                            ELSE LAST.RUN.DATE<1,DATE.COUNT> = R.DATES(EB.DAT.TODAY)
                        END ELSE
                            LAST.RUN.DATE<1,DATE.COUNT> = R.DATES(EB.DAT.LAST.WORKING.DAY)
*
* If the frequency is monthly, set the last run date to the last month
* end date
*
                            IF FREQ.DATES<1,DATE.COUNT> = 'M' THEN
                                TEMP.DATE = LAST.RUN.DATE<1,DATE.COUNT>
                                IF TEMP.DATE[1,6] = R.DATES(EB.DAT.TODAY)[1,6] THEN       ;* If they're not equal, then last.run.date is already last month end date
                                    YEAR = TEMP.DATE[1,4]
                                    MONTH = TEMP.DATE[5,2]
                                    MONTH -= 1
                                    IF MONTH = 0 THEN
                                        YEAR -= 1
                                        MONTH = 12
                                    END
                                    TEMP.DATE = YEAR:FMT(MONTH,'R%2'):'32'
                                    CALL CDT('',TEMP.DATE,'-1W')
                                    LAST.RUN.DATE<1,DATE.COUNT> = TEMP.DATE
                                END
                            END
                        END
                    END ELSE LAST.RUN.DATE<1,DATE.COUNT> = RELEASE.RECORD(BAT.LAST.RUN.DATE)<1,DATE.COUNT>
                NEXT DATE.COUNT
*
                CALL B.CAL.RUN.DATE( JOBS, USER, NEXT.RUN.DATE, LAST.RUN.DATE, FREQ.DATES, COMPANY, '1' )
*
                RELEASE.RECORD( BAT.NEXT.RUN.DATE ) = NEXT.RUN.DATE
            END
            RELEASE.RECORD(RV-4) = ""   ;* set authoriser field to null
            X = OCONV(DATE(),"D-")
            X = X[9,2]:X[1,2]:X[4,2]:TIMEDATE()[1,2]:TIMEDATE()[4,2]
            RELEASE.RECORD(RV-5) = X    ;* date.time stamp
            

            IF EB.Upgrade.getReleaseNo()[1,3] EQ "SPG" THEN
                RELEASE.RECORD(RV-6) = "1_":EB.Upgrade.getReleaseNo()[1,6]:EB.Upgrade.getReleaseNo()[9,99]    ;* BG_100004481
            END ELSE
                IF OUModule THEN
                    RELEASE.RECORD(RV-6) = "1_":OUModule
                END ELSE
                    RELEASE.RECORD(RV-6) = "1_":EB.Upgrade.getReleaseNo()
                END
                IF isRecordContentChanged OR isRecordIdChanged THEN RELEASE.RECORD(RV-6):="_Local"      ;* append a marker if the content or id changed by local hook
            END
            IF PDC.RECORD<PDC.SOURCE.REQ> EQ 'C' THEN               ;* if model client data record,then add _C to stamp
                RELEASE.RECORD(RV-6) = RELEASE.RECORD(RV-6):'_C'
            END
            IF isZerobase THEN
                RELEASE.RECORD(RV-6) = "1_ZEROBASE"
            END
            IF IS.JSON.RECORD OR RELEASE.REC.STATUS EQ "IHLD" THEN         ;*  Check if the record is in json format or record status is hold
                RELEASE.RECORD(RV-6) = RELEASE.RECORD(RV-6):"_JSN"  ;* amend the INPUTTER field as _JSON for json record
                RELEASE.RECORD(RV-8) = "IHLD"       ;* set the record status as IHLD for json record
                IS.JSON.RECORD = ""    ;* restore back as Null
            END ELSE
                RELEASE.RECORD(RV-8) = RELEASE.REC.STATUS
            END
            RELEASE.RECORD(RV-1) = ""   ;* set audit code to null
            RELEASE.RECORD(RV) = ""     ;* set audit date to null
*
* If record is being released to F.PGM.FILE or F.ASCII.FILES or the record id starts "STANDARD"
* and is being released to F.ASCII.VAL.TABLE, release to the live file, rather than the unauthorised
* file.  However, if program is being called from the data library restore (DL.DEFINE.RUN), write
* PGM.FILE and HELPTEXT records to the unuauthorised file.
*
            RELEASE.TO.LIVE = 0
*
            BEGIN CASE

                CASE EB.Upgrade.getReleaseNo() = "T24.PRE.RELEASE"   ;* spl case, release directly into Live
                    RELEASE.TO.LIVE = 1
                CASE FILENAME = 'F.PGM.FILE'
                    RELEASE.TO.LIVE = 1     ;*PGM.FILE to be released into Live record through DL.DEFINE.
                CASE FILENAME = 'F.CONVERSION.DETAILS'
                    RELEASE.TO.LIVE = 1
                CASE FILENAME = 'F.CONVERSION.PGMS' AND R.SPF.SYSTEM<SPF.AUTO.UPGRADE> = 'YES'
                    IF EB.Upgrade.getReleaseNo() NE 'DL.RESTORE' THEN            ;* other than DL.RESTORE
                        IF INAU.RECORD.EXISTS THEN                ;* if NAU record exist
                            DELETE LOCAL.INAU.FILE, RECORD.ID       ;* delete it
                        END
                        RELEASE.TO.LIVE = 1               ;* and release to live
                    END
                CASE FILENAME = 'F.AA.CLASS.TYPE'
                    RELEASE.TO.LIVE = 1 ;* release AA.CLASS.TYPE record into live file
                CASE FILENAME = 'F.EU.CONVERSION.PARAM'
                    RELEASE.TO.LIVE = 1
* Removed the CASE of F.ASCII.VALUES, as the record need not be released to LIVE file.
                CASE FILENAME = 'F.ASCII.VAL.TABLE'
                    IF RECORD.ID[1,8] = 'STANDARD' THEN RELEASE.TO.LIVE = 1
                CASE FILENAME = 'F.EB.COMPONENT' ;* RELEASE all EB.COMPONENT records in live
                    RELEASE.TO.LIVE = 1
                CASE FILENAME = 'F.DSL.MODEL.SOURCE' ;* RELEASE all DSL.MODEL.SOURCE records in live
                    RELEASE.TO.LIVE = 1
                CASE FILENAME = 'F.EB.JSN.RELEASE.PARAMETER' ;* RELEASE all EB.JSN.RELEASE.PARAMETER records in live
                    RELEASE.TO.LIVE = 1
                CASE FILENAME = 'F.EB.TRANSACT.STANDARDS' ;* RELEASE all EB.TRANSACT.STANDARDS records in live
                    RELEASE.TO.LIVE = 1
                CASE FILENAME MATCHES RELEASE.TO.LIVE.FILES     ;* like F.EB.ERROR, EB.SUB.PRODUCT or EB.COMPONENT
                    IF NOT(LIVE.RECORD.EXISTS) THEN
                        RELEASE.TO.LIVE = 1
                    END ELSE      ;* See if there is any difference between live & nau
                        GOSUB COMPARE.LIVE.AND.RELEASE
                        IF SAME.LIVE.REL THEN RELEASE.TO.LIVE = 1         ;* Overwrite live record
                    END ;*  GLOBUS_BG_100003039 E
                    IF FILENAME = "F.EB.ERROR" AND EB.Upgrade.getReleaseNo() = 'DL.RESTORE' AND CHECK.ADD.INFO THEN     ;*If the flag is enabled to release the records in IHLD for the EB.ERROR records during DL.DEFINE
                        RELEASE.TO.LIVE = 0     ;*Don't release the records in live
                    END
*
* If the record is being released to F.HELPTEXT, then release to the live file if the record does not
* already exist on the live file or if the record on the live file was released by GLOBUS.RELEASE
* (i.e. inputter is 1_Gn.n.nnx or 1_xx where xx is the product), or the inputter on the live record
* is null (i.e. was created by the original conversion of the helptext files)
*
                CASE SubProductNeo = 1 ; * NEO data records

                    IF neoProductAvailable THEN  ; * When 'NE' is installed,
                        IF NOT(LIVE.RECORD.EXISTS) THEN ; * any new records
                            RELEASE.TO.LIVE = 1 ; * release in live
                        END
* any changed/amended records, release in INAU itself.
                    END ELSE    ; * When 'NE' is not installed
                        RELEASE.TO.LIVE = 1 ; * , release all records in LIVE directly.
                    END

                CASE FILENAME = 'F.HELPTEXT'

                    IF EB.Upgrade.getReleaseNo() <> 'DL.RESTORE' THEN
                        IF LIVE.RECORD.EXISTS THEN
                            IF LIVE.RECORD(LV-6)<1,1> MATCHES '1_G0N1N.0N1N.0X1X' THEN
                                RELEASE.TO.LIVE = 1
                            END ELSE
                                IF LEN(LIVE.RECORD(LV-6)<1,1>) = '4' THEN
                                    IF LIVE.RECORD(LV-6)<1,1>[1,2] = '1_' THEN
                                        RELEASE.TO.LIVE = 1
                                    END
                                END
                                IF LIVE.RECORD(LV-6)<1,1> = '' THEN
                                    RELEASE.TO.LIVE = 1
                                END
                            END
                        END ELSE RELEASE.TO.LIVE = 1
                    END
                CASE R.PGM.FILE<EB.PGM.TYPE> EQ "W" ;* if it is a W type file release to live as it doesn't have NAU file.
                    RELEASE.TO.LIVE = 1
                    
                CASE FILENAME = 'F.BATCH'
                    IF RELEASE.RECORD(BAT.POST.UPGRADE) EQ "YES" OR INDEX(RECORD.ID,"POST.UPGRADE",1) THEN   ;* If post upgrade batch, release to live directly
                        RELEASE.TO.LIVE = 1
                    END
               
                CASE FILENAME = 'F.TSA.WORKLOAD.PROFILE' AND RECORD.ID EQ "POST.UPGRADE"    ;* Release  to live directly
                    RELEASE.TO.LIVE = 1

                CASE FILENAME = 'F.TSA.SERVICE' AND INDEX(RECORD.ID,"POST.UPGRADE",1)    ;* If post upgrade service, default the tsm user and release to live directly
                    RELEASE.RECORD(TS.TSM.USER) = tsmUser
                    RELEASE.TO.LIVE = 1
                                 
                CASE FILENAME = 'F.TSA.SERVICE' AND RELEASE.REC.STATUS EQ "IHLD"        ;* If record status is hold, default the user and work profile and release to live directly
                    rTsaParameter = ''      ;* Initialise before usage
                    READ rTsaParameter FROM F.TSA.PARAMETER, "SYSTEM" THEN
                        IF rTsaParameter<TS.PARM.DEFAULT.WORK.PROFILE> THEN
                            RELEASE.RECORD(TS.TSM.WORK.PROFILE) = rTsaParameter<TS.PARM.DEFAULT.WORK.PROFILE>
                        END
                        IF rTsaParameter<TS.PARM.DEFAULT.USER> THEN
                            RELEASE.RECORD(TS.TSM.USER) = rTsaParameter<TS.PARM.DEFAULT.USER>
                        END
                    END
                    IF rTsaParameter<TS.PARM.DEFAULT.WORK.PROFILE> AND rTsaParameter<TS.PARM.DEFAULT.USER> THEN
                        RELEASE.TO.LIVE = 1
                    END
                CASE FILENAME = 'F.T24.UXPB.COS'        ;* Release T24.UXPB.COS to live directly
                    RELEASE.TO.LIVE = 1
            END CASE
*
            IF RELEASE.TO.LIVE THEN
                IF EB.Upgrade.getReleaseNo()[1,3] EQ "SPG" THEN
                    RELEASE.RECORD(RV-4) = "1_":EB.Upgrade.getReleaseNo()[1,6]:EB.Upgrade.getReleaseNo()[9,99]
                END ELSE
                    RELEASE.RECORD(RV-4) = "1_":EB.Upgrade.getReleaseNo()
                END
                RELEASE.RECORD(RV-8) = ""         ;* Clear status field
                MATWRITE RELEASE.RECORD ON LOCAL.FILE,RECORD.ID
                GOTO EXIT.COPY.RECORDS
            END
*
            IF INAU.RECORD.EXISTS THEN
*
* Copy the old unauthorised record to the F.REPLACED file on the data account
*
                MATWRITE INAU.RECORD ON F.REPLACED.RECORDS,FILENAME:"$NAU":">":RECORD.ID
            END
            MATWRITE RELEASE.RECORD ON LOCAL.INAU.FILE,RECORD.ID
        END ELSE

            IF LIVE.RECORD.EXISTS THEN
                MATWRITE LIVE.RECORD ON F.REPLACED.RECORDS,FILENAME:">":RECORD.ID

*
* If releasing records to DB.SCRAMBLE.DEFINE, copy the run history from the current live record
*
                IF FILENAME = 'F.DB.SCRAMBLE.DEFINE' THEN
                    FOR X = DB.SCR.RUN.USER TO DB.SCR.RUN.DATE
                        RELEASE.RECORD(X) = LIVE.RECORD(X)
                    NEXT X
                END
            END
            MATWRITE RELEASE.RECORD ON LOCAL.FILE,RECORD.ID
        END
    END
    
EXIT.COPY.RECORDS:
    F.RELEASED.DATA = EB.Upgrade.getFReleasedData()
    IF COUNTRY.SPECIFIC EQ 1 THEN  ;* Check if the record is to be released in  a specific country
        READU releaseRec FROM F.RELEASED.DATA, releaseRecId THEN    ;* Read the releaseRec from F.RELEASE.DATA
            LOCATE COMPANY.MNE IN releaseRec BY @FM SETTING locatePos ELSE  ;* Check if the company to be released is already available in releaseRec
                releaseRec<-1> = COMPANY.MNE                                ;* If not append the mnemonic to the releaseRec
            END
        END ELSE
            releaseRec = COMPANY.MNE                                        ;* If not releaseRec is found assign the Mnemonic to the releaseRec
        END
        WRITE releaseRec ON F.RELEASED.DATA, releaseRecId ON ERROR          ;* Write the updated releaseRec to F.RELEASE.DATA
            CRT 'Released data update failed'
        END
    END
    GOSUB LoadReleasedRecordsList ; *  store released records list in an array
RETURN
*
*************************************************************************
*
DELETE.HISTORY.RECORDS:
* Delete history of current RECORD.ID in current FILENAME
    LOCATE '$HIS' IN R.FILE.CONTROL<EB.FILE.CONTROL.SUFFIXES,1> SETTING HIS.FILE.EXISTS THEN ;* Open histroy file in data account  only if $HIS is specified on the file control record
        OPEN "",FILENAME:"$HIS" TO LOCAL.HISTORY.FILE THEN
            READ.CNT = 10
            HIS.CNT = 1
            DELETE.REQD = 0
            TEST.REC = ''
            READ TEST.REC FROM LOCAL.HISTORY.FILE, RECORD.ID:';':1 THEN
                DELETE LOCAL.HISTORY.FILE, RECORD.ID:';':1
                DELETE.REQD = 1
            END
            LOOP WHILE DELETE.REQD
                HIS.CNT += 1
                IF MOD(HIS.CNT,READ.CNT) = 0 THEN
                    READ TEST.REC FROM LOCAL.HISTORY.FILE, RECORD.ID:';':HIS.CNT ELSE
                        DELETE.REQD = 0
                    END
                END
                DELETE LOCAL.HISTORY.FILE, RECORD.ID:';':HIS.CNT
            REPEAT
        END
    END
RETURN
*
*************************************************************************
*
DETERMINE.V:
*
* Determine the length of the record (V) so that the audit fields can be maintained.
* V = position of authoriser + 4 (CO.CODE,DEPT,AUDIT.DATE,AUDIT.TIME)
*
    MISSING.AUDIT.FIELD = ""  ;* Set if no auditor fields
    IF auditPos THEN             ;* AUDIT.DATE.TIME position identified already when there are neighbour fields in current application
        V = auditPos
    END ELSE                  ;* V value not found yet
        V = DCOUNT(R.RECORD,@FM) + 2        ;* Last field number  +1 cause loop does -1
    END
* GB9601056 Add a check for Terminal SY.
    AUTHORISER.MATCH = "0N1N_1X0X":@VM:"'SY_'1X0X"          ;* 72_A.AUTHOR or SY_A.AUTHOR
    CO.CODE.MATCH = "2A7N"     ;* CO.CODE pattern String Eg: GB0010001 or US0010001
    IF FILENAME MATCHES RELEASE.TO.LIVE.FILES THEN AUTHORISER.MATCH := @VM:"'CONVERSION_'1X0X"      ;*Authoriser for files created
*
* Look for authoriser
*
    UPDATE.FLAG = 0
    IF R.RECORD<V-4,1>[1,1] = '-' THEN
        R.RECORD<V-4,1> = R.RECORD<V-4,1>[2,99]
        UPDATE.FLAG = 1
    END
    LOOP V-=1 UNTIL MATCHFIELD(R.RECORD<V,1>, CO.CODE.MATCH,1) OR V < 1             ;* Loop until the pattern matches with CO.CODE
    REPEAT
*
    IF V THEN       ;* Found authoriser
        V = V +3   ;* Actual size of record
    END ELSE        ;* No audit fields
        V = DCOUNT(R.RECORD,@FM)+9      ;* Default to end of record +9
        MISSING.AUDIT.FIELD = 1         ;* Set if no fields
    END
*
    IF UPDATE.FLAG = 1 THEN
        R.RECORD<V-4,1> = '-':R.RECORD<V-4,1>
    END
RETURN
*
*-------------------------------------------------------------------------
COMPARE.LIVE.AND.RELEASE:
*=======================
* See if there is actually any difference between existing live and release records
*
    LAST.FNO = LV-9
    SAME.LIVE.REL = 1         ;* If live and release record are the same write stright to live
    FOR FNO = 1 TO LAST.FNO
        IF LIVE.RECORD(FNO) NE RELEASE.RECORD(FNO) THEN
            SAME.LIVE.REL = 0
            FNO = LAST.FNO    ;* Stop
        END
    NEXT FNO
*
RETURN
*------------------------------------------------------------------------
CHECK.ADDITIONAL.INFO:
*Get the additonal info of the application and check whether if it is mentioned as ".HLD"
    ADD.INFO = R.PGM.FILE<EB.PGM.ADDITIONAL.INFO> ;* Get the additional.info of PGM.RECORD
    IF INDEX(ADD.INFO,'.HLD', 1) THEN   ;* Search if additional.info field contains .HLD
        CHECK.ADD.INFO = 1    ;*if it's .HLD then set the FLAG
        RELEASE.REC.STATUS = "IHLD"     ;* Set the status of the file to release the record in "IHLD" status
    END
    R.EB.DATA.RELEASE = ''
    MOD.RELEASE.API = ''
    
    IF INDEX(ADD.INFO,'.MREL', 1) THEN   ;* Check if Modify release has been enabled.
    
        R.EB.DATA.RELEASE = EB.Upgrade.DataReleaseApiTable.CacheRead(TEMP.FILENAME, ERR)   ;* check in cache
        IF ERR NE '' THEN ;* if record is not there, but pgm.file has .MREL , so better to check RELEASE.DATA also
            tmp = EB.Upgrade.getFReleaseData()
            OPEN '','F.RELEASE.DATA' TO tmp ELSE     ;* Open F.RELEASE.DATA to get PGM.FILE
                ERROR.MSG = "Unable to open 'F.RELEASE.DATA'"   ;* Not possible
                PRINT ERROR.MSG
                Logger('CREATE.INAU.RECORDS',TAFC_LOG_ERROR,ERROR.MSG) ;* Log this for error
                RETURN
            END
            EB.Upgrade.setFReleasedData(tmp)
            releaseRecordId = "F.EB.DATA.RELEASE.API.TABLE>":TEMP.FILENAME     ;* id will be of the format F.EB.DATA.RELEASE.API.TABLE>SECTOR, etc
            F.RELEASE.DATA = EB.Upgrade.getFReleaseData()
            READ R.EB.DATA.RELEASE FROM F.RELEASE.DATA,releaseRecordId ELSE
                R.EB.DATA.RELEASE = "" ;* not even there in F.RELEASE.DATA
            END
            
    
        END
    
        IF R.EB.DATA.RELEASE<EB.Upgrade.DataReleaseApiTable.DarReleaseApi> NE '' THEN  ;* if the routine is there
            routineName = R.EB.DATA.RELEASE<EB.Upgrade.DataReleaseApiTable.DarReleaseApi> ;* extract the routine name
            impLocalRoutineExist = ''
            returnInfo = ''
            CALL CHECK.ROUTINE.EXIST(routineName,impLocalRoutineExist,returnInfo) ;* make sure whether this routine exists
            IF impLocalRoutineExist THEN
                MOD.RELEASE.API = 1 ;* Modify release api exists
            END
        END
    
    END
RETURN
*
*------------------------------------------------------------------------
*   E  X  I  T    P  R  O  G  R  A  M
*------------------------------------------------------------------------
FATAL.ERROR:
    PRINT E
    Logger('CREATE.INAU.RECORDS',TAFC_LOG_ERROR,E)
FINISH:

    MAT R.COMPANY = MAT R.SAVED.COMPANY
    IF releasedRecordsList THEN   ;* if records populated
        GOSUB StoreReleasedRecords   ;* write released records into F.RELEASED.RECORDS
    END
RETURN


*-----------------------------------------------------------------------------

*** <region name= LoadReleasedRecordsList>
LoadReleasedRecordsList:
*** <desc> populate released records list in an array releasedRecordsList </desc>

    IF populateReleasedRecords THEN ;* if released record to be populated in list
        IF releasedRecordsList THEN  ;* if value exist
            releasedRecordsList<-1> = FILENAME:'>':RECORD.ID  ;* append current record details (With **EM, if it is there)
        END ELSE  ;* else
            releasedRecordsList = FILENAME:'>':RECORD.ID   ;* load record details (With **EM, if it is there)
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= StoreReleasedRecords>
StoreReleasedRecords:
*** <desc> write list of released record ids into F.RELEASED.RECORDS </desc>
    FV.RELEASED.RECORDS = EB.Upgrade.getFvreleasedrecords()
    EB.Upgrade.setProductList('')
    IF BATCH.DETAILS<3> NE 'PRIMARY' THEN        ;* it is not product but primary application or file list will be released through T24.UPGRADE.PRIMARY service
        EB.Upgrade.setProductList(BATCH.DETAILS<3,1>)   ;*Get the products from BATCH record
    END
    BEGIN CASE
        CASE EB.Upgrade.getReleaseNo() EQ 'DL.RESTORE'   ;* restoring of records through DL.DEFINE
            tempDate = OCONV(DATE(),'D-')
            tempToday = tempDate[7,4]:tempDate[1,2]:tempDate[4,2] ;* todays date
            releasedRecordId = 'RELEASED.RECORDS_DL.RESTORE_': ID.NEW :'_': tempToday  ;* id of RELEASED.RECORDS file

        CASE EB.Upgrade.getProductList() EQ 'T24.UPDATES'
            releasedRecordId = 'RELEASED.RECORDS_T24.UPDATES_':EB.Upgrade.getReleaseNo():'_':C$T24.SESSION.NO   ;* For update installation

        CASE EB.Upgrade.getProductList() EQ "T24.MODEL.PACKAGE"
            releasedRecordId = 'RELEASED.RECORDS_T24.MODEL.PACKAGE_':EB.Upgrade.getReleaseNo():'_':C$T24.SESSION.NO  ;* for packager installation

        CASE EB.Upgrade.getProductList()
            releasedRecordId = 'RELEASED.RECORDS_PRODUCT.INSTALL_':EB.Upgrade.getReleaseNo():'_':C$T24.SESSION.NO   ;* product installation

        CASE 1  ;* records released via updates/upgrade
            releasedRecordId = 'RELEASED.RECORDS_T24.UPGRADE_':EB.Upgrade.getReleaseNo():'_':C$T24.SESSION.NO   ;* where RELEASE.NO holds updates id / current upgrading release
    END CASE

    saveReleasedRecordsList = releasedRecordsList   ;* save list of released record details

    READU releasedRecordsList FROM FV.RELEASED.RECORDS,releasedRecordId THEN  ;* read F.RELEASED.RECORDS
        releasedRecordsList<-1> = saveReleasedRecordsList   ;* append with existing content if any
    END ELSE
        releasedRecordsList = saveReleasedRecordsList
    END

    WRITE releasedRecordsList TO FV.RELEASED.RECORDS,releasedRecordId  ;* write it

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getTsmUser>
getTsmUser:
*** <desc> For auto upgrade, newly released TSA.SERVICE records can be populated with TSM user and placed into INAU. </desc>
    
    tsmUser = ''                                        ;* variable to hold TSM user, and can be populated to newly released TSA.SERVICE records if AUTO.UPGRADE enabled
    IF R.SPF.SYSTEM<SPF.AUTO.UPGRADE> = 'YES' OR isOnlineUpgradePrimary OR RECORD.ID EQ "POST.UPGRADE" THEN              ;* assign TSM user and release TSA.SERVICE in INAU status for auto upgrade or online upgrade
        OPEN "F.TSA.SERVICE" TO fvTsaService ELSE       ; * Try opening the TSA.SERVICE file
            E = 'Cannot Open F.TSA.SERVICE'
            GOSUB FATAL.ERROR
        END
        READ rTsaService FROM fvTsaService, 'TSM' THEN            ;* read TSA.SERVICE>TSM record in live
            tsmUser = rTsaService<TS.TSM.USER>                      ;* get TSM user  (definitly a valid user)
        END
        RELEASE.REC.STATUS = "INAU" ;*Release the record in INAU Status.
    END ELSE
        RELEASE.REC.STATUS = "IHLD" ;*Release the record in IHLD Status.
    END
RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= getAuditDateTimePosition>
getAuditDateTimePosition:
*** <desc> get audit.date.time position from corresponding latest SS record. EBS.SOFTWARE.RELEASE should release SS records as priority files as like FILE.CONTROL and PGM.FILES </desc>
* DL.RESTORE, updates, model package , product installation can happen in current release - where latest SS can be referred.
* Upgrade from lower release data records may not match with the latest SS record because older releases follows field layout changes to introduce fields to an application.
* Possibily From 201708 - neighbour field feature will be available which avoids field layout change, hence AUDIT.DATE.TIME always refer to same position.

    auditPos = ''
    currentRelease = R.SPF.SYSTEM<SPF.CURRENT.RELEASE>        ;* neighbour field feature will be available from 201708 release
    IF (currentRelease[1] = 'R' AND currentRelease[2,2] GE '18') OR (currentRelease[1,6] GE '201708') THEN  ;* From 201708 release only can refer SS from disk because no chances of changing field layout and preferred to use neighbour field feature
        ssFileName = 'F.STANDARD.SELECTION'
        OPEN "",ssFileName:"$NAU" TO ssFileVar THEN      ;* open SS NAU file
            READ ssRec FROM ssFileVar,TEMP.FILENAME ELSE          ;* read unauthorised SS record released if anything for TEMP.FILENAME
                OPEN "",ssFileName TO ssFileVar THEN
                    READ ssRec FROM ssFileVar,TEMP.FILENAME ELSE NULL         ;* read SS record in live for TEMP.FILENAME
                END
            END
        END
        
        IF ssRec AND ssRec<SSL.PHYSICAL.ORDER> AND ssRec<SSL.LOGICAL.ORDER> THEN              ;* neighbour field exist for the current application or file in TEMP.FILENAME
            LOCATE 'AUDIT.DATE.TIME' IN ssRec<SSL.SYS.FIELD.NAME,1> SETTING pos THEN          ;* locate audit date time position
                auditPos = ssRec<SSL.SYS.FIELD.NO,pos>                       ;* get AUDIT.DATE.TIME position
            END
        END
    END
    
RETURN
*** </region>
*-------------------------------------------------------------------------------------------------
LOAD.SUB.MODULES:
* load the sub modules if the parent module is present and the sub module is not present in company record variable
    parentCount = ''   ;* initialise it to null
    prodCheck = ''      ;* initialise it to null
    parentCount = DCOUNT(modulesSplit ,@FM)                 ;* get the count of parent modules
    FOR count = 1 TO parentCount                     ;* for each parent load the sub modules
        prodCheck = FIELD(modulesSplit<count>,"*",1)           ;* get the product alone
        LOCATE prodCheck IN companyRecord(EB.COM.APPLICATIONS)<1,1> SETTING appPOS THEN     ;* locate each product in company record application field
            companyRecord(EB.COM.APPLICATIONS)<1,-1> = FIELD(modulesSplit<count>,"*",2)    ;* load the respective sub modules if parent module is located
        END
    NEXT count                   ;* next loop
RETURN
*-------------------------------------------------------------------------------------------------

*** <region name= checkTransactStandards>
checkTransactStandards:
*** <desc> </desc>
    isL1DataRelease = 0
    isApplyTransacStds = 0
  
    IF BATCH.INFO<3> MATCHES 'T24.UPGRADE':@VM:'T24.UPDATES' THEN  ;* Upgrade, updates and product installation
        isL1DataRelease = 1
    END
    CALL Product.isInSystem('TS2021', isTransactStdsInstalled)     ;* check whether TS2021 product exist in SPF record
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

END

