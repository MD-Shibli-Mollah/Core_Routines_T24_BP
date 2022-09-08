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

* Version 7 02/06/00  GLOBUS Release No. 200510 29/09/05
*-----------------------------------------------------------------------------
* <Rating>-33</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoReports
    SUBROUTINE E.CF.FILE.NO(ENQUIRY.DATA)
*=================================================================
*
* MODIFICATIONS
*--------------
*
* 13/01/95 - GB9500054
*            Now accepts input parameter as per change in enquiry
*            build routines to enable their use with the GUI
*
*
* 12/07/2002 - CI_10002705
*      R.ENQ was being used to update enquiry file name
*      This Update resulted in enquiry record being corrupted
*      Same is fixed by doing a separate READ/WRITE to enquiry record.
*
* 06/09/05 - GLOBUS_BG_100009366
*            Remove prompt to make program browser compatible. Month.no
*            is now part of the selection criteria.
*            Added cache.read call to load the cache, as cache.read is
*            used in ENQ.PRE.PROCESS
*
* 08/04/11 - Defect_186012 Cache.Read Problem solved by clearing Cache Memory
*            and Reduce write statement overwrite same file again and again.
*
* 31/05/11 - Defect_217430
*            While running the enquiry in different sessions, Record is getting locked
*            and throws message "Waiting for more than a minutes. Continue Y/N...."
*            As the enquiry file name is determined at run time. Use JOURNAL.UPDATE to update the enquiry file
*            (It should not be used in any other enquiry)
*
*
* 22/6/15 - 1322379 Task:1336841
*           Incorporation of components
*
* 17/07/15 - Enhancement_1322379 Task_1411404
*            TAFC Compilation errors
*=================================================================
    $USING EB.Reports
    $USING EB.TransactionControl
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.API

    FUNCTION.KEYS = EB.API.getCU()
    MONTH.NUMB = EB.SystemTables.getToday()[5,2]   ;* BG_100009366 s
    LOCATE "MONTH.NO" IN ENQUIRY.DATA<2,1> SETTING POS THEN
* Get the month number from the enquiry selection criteria, if it's not a valid month
* then don't use it and use the current month as default.
    IF ENQUIRY.DATA<4,POS> >=1 AND ENQUIRY.DATA<4,POS> <= 12 AND (ENQUIRY.DATA<4,POS> MATCHES "1N" OR ENQUIRY.DATA<4,POS> MATCHES "2N") THEN
        MONTH.NUMB = ENQUIRY.DATA<4,POS> "R%2"
    END
    END   ;* BG_100009366 e

* CI_10002705 start
    ENQ.ID = ENQUIRY.DATA<1>  ;* Name of enquiry

    EB.Reports.EnquiryLock(ENQ.ID, R.STORE.ENQ, ERR.VAL, 'R', '')   ;* BG_100009366
* Before incorporation : CALL F.READU('F.ENQUIRY',ENQ.ID,R.STORE.ENQ,tmp.F.ENQ,ERR.VAL,'R')    ;* BG_100009366

    R.STORE.ENQ<EB.Reports.Enquiry.EnqFileName> = "SC.CASH.FLOW":MONTH.NUMB
    EB.Reports.EnquiryWrite(ENQ.ID, R.STORE.ENQ,'')  ;* BG_100009366
* Before incorporation : CALL F.WRITE('F.ENQUIRY',ENQ.ID,R.STORE.ENQ)  ;* BG_100009366
    EB.TransactionControl.JournalUpdate('')
    s_bucketname = 'StaticCache_F.ENQUIRY'
    EB.DataAccess.SystemDeletecache(s_bucketname,ENQ.ID,CACHE.DELETED)
    R.STORE.ENQ.NEW = EB.Reports.Enquiry.CacheRead(ENQ.ID, '')  ;* BG_100009366
* Before incorporation : CALL CACHE.READ('F.ENQUIRY',ENQ.ID,R.STORE.ENQ.NEW,'')  ;* BG_100009366
    R.STORE.ENQ.NEW<EB.Reports.Enquiry.EnqFileName>="SC.CASH.FLOW":MONTH.NUMB
    tmp=EB.Reports.getREnq(); tmp<EB.Reports.Enquiry.EnqFileName>="SC.CASH.FLOW":MONTH.NUMB; EB.Reports.setREnq(tmp)
    EB.Reports.setDataFileName(EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFileName>)
    EB.Reports.setFullFileName("F.":EB.Reports.getDataFileName():@FM:'NO.FATAL.ERROR')
    tmp.F.DATA.FILE = EB.Reports.getFDataFile()
    tmp.FULL.FILE.NAME = EB.Reports.getFullFileName()
    EB.DataAccess.Opf(tmp.FULL.FILE.NAME, tmp.F.DATA.FILE)
    EB.Reports.setFullFileName(tmp.FULL.FILE.NAME)
    EB.Reports.setFDataFile(tmp.F.DATA.FILE)
* CI_10002705 End
    FL = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFileName>
    FILE = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFileName>


    RETURN

    END
