* @ValidationCode : MjoxOTQwNDk2Mzg6SVNPLTg4NTktMToxNDkwMjUyNzE3MDgxOnNlbGF5YXN1cml5YW46MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMDo5ODoyNA==
* @ValidationInfo : Timestamp         : 23 Mar 2017 12:35:17
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : selayasuriyan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 24/98 (24.4%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>530</Rating>
*-----------------------------------------------------------------------------
* Version 2 29/09/00  GLOBUS Release No. 200508 30/06/05
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.NOS
*================================================================================
* Routine to build R.RECORD to be used by the
* PM.NOS enquiry
*
* 22/08/04 - CI_10022433
*            The size of the dimensioned arrays DPC.REC,DPC.FILES
*            be increated to 50 ,to avoid the array index out of found
*            while running pm related enquiries.  This happens only when
*            the field COM.CONSOL.FROM in COMPANY.CONSOL having more than 10 mv's.
*
* 05/05/11 - Defect-177474 / Task-204094
*            Execution of ENQUIRY PM.NOS results in the error CURRENCY RECORD MISSING
*
* 04/08/11 - Defect-251612 / Task-256060
*            The currency field not display with any value in the PM.NOS enquiry
*            for NOSTRO movements
*
* 01/11/15 - EN_1226121/Task 1499688
*			 Incorporation of routine
*
* 22/03/17 - Defect 2039513 / Task 2062624
*            PM NOS enquiry displays duplicate ccy with empty line.
*
*==================================================================================


    $USING PM.Config
    $USING EB.Display
    $USING PM.Reports
    $USING EB.API
    $USING EB.SystemTables
    $USING EB.Reports

    GOSUB INITIALISE
    GOSUB SELECT.DLY.POSN.CLASS

    IF ID.LIST = '' THEN
        EB.SystemTables.setText('NO RECORDS SELECTED')
        IF EB.SystemTables.getRunningUnderBatch() THEN
            PRINT EB.SystemTables.getText() : ' PM.NOS'
        END ELSE
            EB.Display.Rem()
        END
        RETURN
    END

    GOSUB CONSOLIDATE.DPC.DATA

    RETURN

*=========================================================================
*                       INTERNAL ROUTINES
*=========================================================================

SELECT.DLY.POSN.CLASS:

* Call E.PM.SEL.POSN.CLASS to get a list of PM.DLY.POSN.CLASS IDs and
* associated file mnemonics required. This routine requires an ID to the
* PM.ENQ.PARAM file which defines the records required for the enquiry.
* In addition information regarding the signing conventions required for
* the enquiry are returned. The PM.ENQ.PARAM will have already been
* loaded in the labelled common area (I_PM.ENQ.PARAM) by the routine
* E.PM.INIT.COMMON.

    ID.LIST = ""
    MNEMON.LIST = ""
    CCY.LIST = PM.Config.getCcy()

    PM.Reports.EPmSelPosnClass(ID.LIST, MNEMON.LIST, MAT DPC.FILES)

    RETURN

*------------------------------------------------------------------------

CONSOLIDATE.DPC.DATA:

* There are two cycles for consolidation
* 1st - processing of DPC records to be added in R.RECORD
*       for every ccy from CCY.LIST
* 2nd - remove empty data

* F I R S T   C Y C L E

    DATE.ARRAY = EB.SystemTables.getToday()

    FOR I = 1 TO 4
        CURR.DATE = EB.SystemTables.getToday()
        EB.API.Cdt("", CURR.DATE, "+0" : I : "W")
        DATE.ARRAY<I + 1> = CURR.DATE
    NEXT I

    LOOP
        REMOVE TEMP.ID FROM ID.LIST SETTING POINT1
        EB.Reports.setId(TEMP.ID)
        REMOVE MNEMON FROM MNEMON.LIST SETTING POINT2
    WHILE EB.Reports.getId()
        MAT DPC.REC = ''
        tmp.ID = EB.Reports.getId()
        DPC.ID = FIELD(tmp.ID,'*',1)
        EB.Reports.setId(tmp.ID)
        MATREAD DPC.REC FROM DPC.FILES(MNEMON),DPC.ID THEN
        DPC.CCY = FIELD(DPC.ID, '.', 5)
        DPC.DATE = FIELD(DPC.ID, '.', 6)
        CONV.TO.CCY = ''

        LOCATE DPC.CCY IN CCY.LIST<1, 1> SETTING YCCY.POS THEN

        * Cater for 'in' currencies to be converted to fixed one

        FIND DPC.CCY IN CONV.CCY.LIST SETTING CNV.F, CNV.V THEN
        LOCATE CONV.CCY.LIST<CNV.F, 1> IN CCY.LIST<1, 1> SETTING YCCY.POS ELSE YDUMMY = ''
        IF CNV.V > 1 THEN
            PM.Reports.EPmDpcConvert(DPC.ID, MAT DPC.REC, CONV.CCY.LIST<CNV.F, 1>)
        END
    END

* Define currency line to add data - may be primary or secondary

    LOCATE FIELD(DPC.ID, '.', 1) IN SEC.VALID.CLASS<1, 1> SETTING TTT THEN
    AMT.NO = 2
    END ELSE
    AMT.NO = 1
    END

* Increase corresponding date amount

    DATE.RANGE = ''

    FOR I = 1 TO 5
        IF DPC.DATE <= DATE.ARRAY<I> THEN
            tmp=EB.Reports.getRRecord(); tmp<2 + I, YCCY.POS, AMT.NO>=EB.Reports.getRRecord()<2 + I, YCCY.POS, AMT.NO> + (DPC.REC(PM.Config.DlyPosnClass.DpcAmount)<1,1,1> - DPC.REC(PM.Config.DlyPosnClass.DpcAmount)<1,2,1>); EB.Reports.setRRecord(tmp)
            DATE.RANGE = 1
        END
    NEXT

    IF DATE.RANGE THEN
        tmp=EB.Reports.getRRecord(); tmp<2, YCCY.POS, AMT.NO>=CCY.LIST<1, YCCY.POS>; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<8, YCCY.POS, AMT.NO>=EB.Reports.getRRecord()<8, YCCY.POS, AMT.NO> : EB.Reports.getId() : ' '; EB.Reports.setRRecord(tmp)
    END
    END
    END
    REPEAT

* S E C O N D   C Y C L E

    NEW.R.RECORD = ''

    IF EB.Reports.getRRecord()<2> THEN
        NEW.POS = 1
        FOR I = 1 TO COUNT(EB.Reports.getRRecord()<2>, @VM) + 1
            FOR J = 1 TO 2
                IF EB.Reports.getRRecord()<2, I ,J> THEN
                    * The currency updated in the second postion, if it available in the R.RECORD.
                    NEW.R.RECORD<2, NEW.POS> = EB.Reports.getRRecord()<2, I ,J>
                    FOR K = 3 TO 8
                        NEW.R.RECORD<K, NEW.POS> = EB.Reports.getRRecord()<K, I ,J>
                    NEXT
                    NEW.POS += 1
                END
            NEXT
        NEXT
    END

    IF NEW.R.RECORD THEN
        NEW.R.RECORD<1> = EB.Reports.getRRecord()<1>
        EB.Reports.setRRecord(NEW.R.RECORD)
    END

    IF EB.Reports.getRRecord()<2> THEN
        EB.Reports.setVmCount(COUNT(EB.Reports.getRRecord()<2>, @VM) + 1)
    END ELSE
        EB.Reports.setVmCount(0)
    END

    RETURN

*------------------------------------------------------------------------

INITIALISE:

* Initialise all variables.

    tmp.R.RECORD = EB.Reports.getRRecord()
    EB.Reports.setRRecord('')


    DIM DPC.REC(50)
    DIM DPC.FILES(50)

    SEC.VALID.CLASS = PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqCheckfileId)

    CONV.CCY.LIST = ''
    TEMP.PM$CCY = PM.Config.getCcy()
    PM.Reports.EPmAddInCcy(TEMP.PM$CCY, CONV.CCY.LIST)
    PM.Config.setCcy(TEMP.PM$CCY)

    RETURN

*=========================================================================

    END
