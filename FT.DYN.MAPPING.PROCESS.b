* @ValidationCode : MjozODg5MTg2NTk6Q3AxMjUyOjE1ODE1ODgwNjM3MjQ6c3VqYXRhc2luZ2g6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4xOjExNzo1MQ==
* @ValidationInfo : Timestamp         : 13 Feb 2020 15:31:03
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sujatasingh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 51/117 (43.5%) 
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>36</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*
$PACKAGE FT.Contract
SUBROUTINE FT.DYN.MAPPING.PROCESS(RET.DATA)
************************************************************************
* Routine to be processed Before authorisation that builds
* OFS string and calls OFS.GLOBUS.MANAGER
*
* OUT.PARAMETER:
* RET.DATA passes the following info to the calling routine after processing
* the Bulk transaction details inputted in the Dynamic template
*  RET.DATA<1> - Multi-value number processed in the Dynamic template
*  RET.DATA<2> - Txn id generated for each multi-value
*  RET.DATA<3> - 'Y'/'N' to indicate if the Txn is in error
*
************************************************************************
* 29/06/04 - EN_10002298
*            New Version
*
* 16/03/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
* 10/09/15 - Enhancement 1265068 / Task 1466516
*          - Routine incorporated
*
* 29/01/2020 - Defect 3549403 / Task 3559190
*             OFS.GLOBUS.MANAGER triggered when using FT.BULK.DEBIT.AC& FT.BULK.CREDIT.AC application.
*             Call to OFS.GLOBUS.MANAGER replaced with OfsAddlocalrequest.
*
************************************************************************
    $USING FT.BulkProcessing
    $USING EB.ErrorProcessing
    $USING EB.Interface
    $USING EB.SystemTables

    GOSUB INITIALISE
    IF EB.SystemTables.getE() THEN RETURN
    GOSUB PROCESS

RETURN

***********************************
INITIALISE:
***********

* Read FT.BULK.MAPPING record for the dynamic template
    DYN.APPLICATION = EB.SystemTables.getApplication()[4,99]

    R.FT.BK.MAP = ''
    R.FT.BK.MAP = FT.BulkProcessing.BulkMapping.Read(DYN.APPLICATION, TERR)
    IF TERR THEN
        EB.SystemTables.setE('CANNOT READ THE RECORD IN FT.BULK.MAPPING')
        EB.ErrorProcessing.Err()
        RETURN
    END

* Get all the Field details
    MAP.APPLICATION = R.FT.BK.MAP<FT.BulkProcessing.BulkMapping.BkmapApplication>
    MAP.BULK.FILEDS = R.FT.BK.MAP<FT.BulkProcessing.BulkMapping.BkmapBulkFieldName>
    MAP.BULK.FLD.NO = R.FT.BK.MAP<FT.BulkProcessing.BulkMapping.BkmapBulkFieldNo>
    MAP.APPL.FILEDS = R.FT.BK.MAP<FT.BulkProcessing.BulkMapping.BkmapApplFieldName>
    MAP.CONDITION = R.FT.BK.MAP<FT.BulkProcessing.BulkMapping.BkmapMapCondition>

* Get OFS.SOURCE and VERSION info
    OFS.SOURCE = R.FT.BK.MAP<FT.BulkProcessing.BulkMapping.BkmapOfsSource>
    OFS.VERSION = R.FT.BK.MAP<FT.BulkProcessing.BulkMapping.BkmapVersion>
    OFS.PREFIX = OFS.VERSION:"/I,,"

    R.DYN.FLD.NAME = ''
    R.APPL.FLD.NAME = ''
    R.MAP.COND = ''
    MULTI.FLD = ''
    C.OFS.DATA = ''
    M.OFS.DATA = ''
    RET.DATA = ''
    RETURN.INFO = ''

RETURN

***********************************
PROCESS:
********

    DYN.FLD.CN = EB.SystemTables.getV()-9
    DYN.FLD.NO = ''

* Start looping through all the fields in Dynamic template
    LOOP
        DYN.FLD.NO = DYN.FLD.NO + 1
    WHILE DYN.FLD.NO AND DYN.FLD.NO LE DYN.FLD.CN


* If R.NEW of a field in dynamic template is populated, then try to get the
* Dynamic field name, Corresponding Application's field name to be mapped and the mapping rule.
        IF EB.SystemTables.getRNew(DYN.FLD.NO) THEN
            LOCATE DYN.FLD.NO IN MAP.BULK.FLD.NO<1,1> SETTING F.POS THEN
                R.DYN.FLD.NAME<DYN.FLD.NO> = MAP.BULK.FILEDS<1, F.POS>  ; * Field name of Dynamic tempalte
                R.APPL.FLD.NAME<DYN.FLD.NO> = MAP.APPL.FILEDS<1, F.POS>           ; * Corresponding Field name of the Application
                R.MAP.COND<DYN.FLD.NO> = MAP.CONDITION<1, F.POS>        ; * Mapping condition defined


* Build OFS string with respect to the Mapping condition defined.
                BEGIN CASE
                    CASE R.MAP.COND<DYN.FLD.NO> EQ 'SINGLE'
* This field info is going to be common across all the transactions to be generated.  So, form the OFS string right now.
                        GOSUB GET.FIELD.DATA
                        C.OFS.DATA :=T.OFS.DATA

                    CASE R.MAP.COND<DYN.FLD.NO> EQ 'MULTIPLE'
* This field info is Multiple and hence will be varying for each transaction.  Just store the info in an array right now for which OFS string will be populated later.
                        MULTI.FLD<-1> = DYN.FLD.NO

                    CASE R.MAP.COND<DYN.FLD.NO> EQ 'NO'
* No need to map this field.  So, just proceed with the next field in the loop.
                END CASE

            END
        END
    REPEAT

    IF MULTI.FLD THEN
        GOSUB BUILD.COMMON.TXN.DATA     ; * Build Ofs String specific to each transaction
    END ELSE
        CURR.MV.NO = TXN.NO             ; * Multi-value number to update the Txn Id generated from OFS
        GOSUB CALL.OFS.MANAGER
    END


RETURN

************************************
GET.FIELD.DATA:
****************
* Ofs String for the fields whose info is common across all transactions.

    T.OFS.DATA = ''
    FLD.VM = DCOUNT(EB.SystemTables.getRNew(DYN.FLD.NO),@VM)
    FOR VM.NO = 1 TO FLD.VM
        FLD.SM = DCOUNT(EB.SystemTables.getRNew(DYN.FLD.NO)<1,VM.NO>,@SM)
        FOR SM.NO = 1 TO FLD.SM
            T.OFS.DATA := R.APPL.FLD.NAME<DYN.FLD.NO>:":":VM.NO:":":SM.NO:"=":EB.SystemTables.getRNew(DYN.FLD.NO)<1,VM.NO,SM.NO>:","
        NEXT SM.NO
    NEXT VM.NO
RETURN

***************************************
BUILD.COMMON.TXN.DATA:
**********************

* All the fields in the array, MULTI.FLD will be associated and each
* field value in the associated set should be mapped to individual transaction.
* To find the number of associated sets, Count on the R.NEW
* of the first field is sufficient.  Hence, the following logic.

    T.FLD = MULTI.FLD<1>
    TXN.CN = DCOUNT(EB.SystemTables.getRNew(T.FLD),@VM)  ; * Count on the MV set of the first field
    FOR TXN.NO = 1 TO TXN.CN
        M.OFS.DATA = ''
        MUL.CN = DCOUNT(MULTI.FLD,@FM)  ; * Loop thru each field in in the associated MV set
        T.NO = ''
        LOOP
            T.NO = T.NO + 1
        WHILE T.NO LE MUL.CN
            FLD.NO = MULTI.FLD<T.NO>
            FLD.DATA = EB.SystemTables.getRNew(FLD.NO)<1,TXN.NO>
            CONVERT @SM TO @VM IN FLD.DATA
            GOSUB GET.MULTI.FIELD.DATA
            M.OFS.DATA := T.OFS.DATA
        REPEAT
        CURR.MV.NO = TXN.NO             ; * Multi-value number to update the Txn Id generated from OFS
        GOSUB CALL.OFS.MANAGER
    NEXT TXN.NO

RETURN

************************************
GET.MULTI.FIELD.DATA:
*********************
* Ofs String for the fields whose info is different for every transaction.

    T.OFS.DATA = ''
    FLD.VM = DCOUNT(FLD.DATA,@VM)
    FOR VM.NO = 1 TO FLD.VM
        T.OFS.DATA := R.APPL.FLD.NAME<FLD.NO>:":":VM.NO:":1=":FLD.DATA<1,VM.NO,1>:","
    NEXT VM.NO
RETURN

***************************************
CALL.OFS.MANAGER:
*****************
* Call OFS.GLOBUS.MANAGER

    OFS.ERR = ''
;* Below code added to replace call to OFS.GLOBUS.MANAGER with OfsAddlocalrequest
    TRANSACTION.ID = ''
    CALL EB.GET.NEXT.FIN.APPLICATION.ID('FUNDS.TRANSFER','',TRANSACTION.ID)
    R.OFS.DATA = OFS.PREFIX:TRANSACTION.ID:",":C.OFS.DATA:M.OFS.DATA
    R.OFS.DATA := "IN.SWIFT.MSG:1:1=":EB.SystemTables.getIdNew()
    
    OfsMode = 'APPEND'
    EB.Interface.OfsAddlocalrequest(R.OFS.DATA,OfsMode,OFS.ERR)
    
    RET.DATA<1, -1> := CURR.MV.NO      ; * Store the currently processed MV no.
    RET.DATA<2, -1> := TRANSACTION.ID
    
    IF OFS.ERR THEN
        RET.DATA<3, -1> := 'Y'
    END ELSE
        RET.DATA<3, -1> := 'N'
    END

RETURN

******************************************
STORE.OFS.ERRORS:
*****************
* Store Ofs errors in the application (eg., in FT field, IN.PROCESS.ERR)

    VM.CNT = ''

* Write the OFS erros
    ERR.REASON=FIELD(RETURN.INFO,',',2,9999)
    CONVERT "," TO @FM IN ERR.REASON
    CONVERT ":" TO "." IN ERR.REASON

    NO.OF.OFS.ERRORS = DCOUNT(ERR.REASON, @FM)
    FOR CNT = 1 TO NO.OF.OFS.ERRORS
        VM.CNT += 1
* Store only first ?? chars of the error as per the field length, otherwise OFS will reject
        OFS.ERR = ERR.REASON<CNT>[1,65]
        R.OFS.DATA := 'IN.PROCESS.ERR:':VM.CNT:'="':OFS.ERR:'",'
    NEXT CNT

RETURN

END
