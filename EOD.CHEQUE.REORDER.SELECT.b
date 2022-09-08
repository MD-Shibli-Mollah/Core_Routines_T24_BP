* @ValidationCode : MjotMjIzNzQxOTU2OkNwMTI1MjoxNTY0NTc4MDU0NTY1OnNyYXZpa3VtYXI6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOjM2OjM2
* @ValidationInfo : Timestamp         : 31 Jul 2019 18:30:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/36 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>51</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqSubmit
SUBROUTINE EOD.CHEQUE.REORDER.SELECT

* 6/11/2001 - GLOBUS_BG_100000200
*             If there are no records in Cheque.Type with Min.Holding
*             not equal to null and Auto.Request = 'YES', then cheque
*             reorder process not required.
*
* 14/02/02 -  GLOBUS_EN_10000353
*             Enhancement for stock control.
*             Select the CHEQUE.TYPE for AUTO.REORDER.TYP NE '' &
*             MIN.HOLD NE "".
* 10/01/03 - BG_100003164
*            Used common variable FN.EOD.CHQ.LIST instead of
*            EOD.CHQ.REORDER.LIST
* 27/03/03 - BG_100003923
*            Crash in CHQ.EOD.REORDER because of the verb CLEARFILE
*            Now it's chnaged to CLEAR.FILE
*
* 20/02/07 - EN_10003213
*            Routine is being re written to make it compatible with DAS.
*
* 30/06/10 - D-60989 / T-63037
*            CROSS COMPILATION
*
* 13/09/13- Defect 769998 / Task 781943
*           Performance Issue - No selection of CHEQUE.REGISTER records if
*           no CHEQUE.TYPE having values on AUTO.REQUEST & MIN.HOLDING
*
* 07/11/14 - Defect 1162322 / Task 1162371
*            SELECT with multiple LIKE CONDITIONS is failing
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Submit as ST_ChqSubmit and include $PACKAGE
*
*18/09/15 - Enhancement 1265068 / Task 1475953
*         - Routine Incorporated
*
* 16/10/15 - Defect 1486746 / Task 1501896
*	         Performance Issue.
*            Inorder to improve performance,Changes done such that filtering will be done in SELECT routine only
*            when BATCH.DETAILS<3,1> is set to 'INDEX'.Else it will be done in the Record routine.
*
* 26/07/16 - Defect 1803359 / Task 1806415
*          - Open the file F.EOD.CHQ.REORDER.LIST before executing CLEAR.FILE statement. Change to EB.CLEAR.FILE
*
*
* 1/5/2017 - Enhancement 1765879 / Task 2102715
*            Remove dependency of code in ST products
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*------------------------------------------------------------------------
    $USING CQ.ChqSubmit
    $USING CQ.ChqConfig
    $USING EB.DataAccess
    $USING EB.Service
    $USING EB.API
    $USING EB.SystemTables ;* Task 1501896 - S/E

    $INSERT I_DAS.CHEQUE.ISSUE
    $INSERT I_DAS.CHEQUE.ISSUE.NOTES
    $INSERT I_DAS.CHEQUE.TYPE               ;* Task 781943 - S/E
*------------------------------------------------------------------------
* Task 781943 - S

    acInstalled = @FALSE
    EB.API.ProductIsInCompany('AC', acInstalled)
    IF NOT(acInstalled) THEN
        RETURN
    END
    
    THE.LIST = DAS.CHEQUE.TYPE$AUTO.REQ
    THE.ARGS = ''
    EB.DataAccess.Das("CHEQUE.TYPE",THE.LIST,THE.ARGS,'')
* Task 1501896 - S
    LIST.PARAMETERS = ''
    IF THE.LIST THEN ;* Check if there is any CHEQUE.TYPE record with AUTO.REQUEST as YES and MIN.HOLDING with value
        LIST.PARAMETERS<2> = 'F.CHEQUE.REGISTER'
        LIST.CNT = DCOUNT(THE.LIST,@FM)
*  Set keyword as INDEX in DATA field of the job EOD.CHEQUE.REORDER in BATCH record CARD.CHEQUE.EOD
*  to apply filter directly on select statement,else filtering will be done in record routine.
        INDEX.CHECK = EB.SystemTables.getBatchDetails()<3,1>
        IF INDEX.CHECK = "INDEX" AND LIST.CNT GE 1 THEN
            FOR I = 1 TO LIST.CNT
                IF I EQ 1 THEN
                    LIST.PARAMETERS<3> = "@ID LIKE ":THE.LIST<I>:"..."
                END ELSE
                    LIST.PARAMETERS<3> := " OR @ID LIKE ":THE.LIST<I>:"..."
                END
            NEXT I
        END
    END
* Task 1501896 - E
* Task 781943 - E

    EB.Service.BatchBuildList(LIST.PARAMETERS,'')

    THE.LIST = DAS.CHEQUE$STATUS
    THE.ARGS = ''
    EB.DataAccess.Das("CHEQUE.ISSUE",THE.LIST,THE.ARGS,'')

    FV.EOD.CHQ.REORDER.LIST = ''
    FN.EOD.CHQ.REORDER.LIST = 'F.EOD.CHQ.REORDER.LIST'
    EB.DataAccess.Opf(FN.EOD.CHQ.REORDER.LIST, FV.EOD.CHQ.REORDER.LIST)
   
    EB.Service.ClearFile(FN.EOD.CHQ.REORDER.LIST, FV.EOD.CHQ.REORDER.LIST)
   
    CQ.ChqSubmit.EodChqReorderList.Write("CHEQUE.ISSUE", THE.LIST)

RETURN
END
