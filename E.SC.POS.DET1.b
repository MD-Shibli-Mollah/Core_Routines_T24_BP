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
* <Rating>-16</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoReports
    SUBROUTINE E.SC.POS.DET1
************************************************************
*
*    SUBROUTINE TO EXTRACT SECURITY TRANS KEYS
*    FROM F.TRN.CON.DATE TO BE USED IN ENQUIRY
*    SC.POS.DET
*-----------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modification History </desc>
*-----------------------------------------------------------
* Modification History:
*
* 23/12/04 - EN_10002382
*            SC Phase I non stop processing.
*
* 25/11/08 - GLOBUS_BG_100020996 - dgearing@temenos.com
*            Tidy up. No need to open file, no need to
*            prematurely return if etext set or r.trn.con.date
*            is null.
* 23-07-2015 - 1415959
*             Incorporation of components
************************************************************
*** </region>
*** <region name= Inserts>
*** <desc>Inserts </desc>

    $USING SC.ScoSecurityPositionUpdate
    $USING EB.SystemTables
    $USING EB.Reports


*** </region>
*
    DATA.REC = '' ; * what will go back to enquiry
*
    R.TRN.CON.DATE = '' ; EB.SystemTables.setEtext('')
    K.POS = EB.Reports.getOData()
    K.POS.ACC = FIELD(K.POS,'.',1)

    SC.ScoSecurityPositionUpdate.ReadTrnConDate(K.POS,R.TRN.CON.DATE,EB.SystemTables.getEtext())

*
    ARRAY = R.TRN.CON.DATE
    LOOP UNTIL ARRAY = '' DO
        RECORD = ARRAY<1>
        DEL ARRAY<1>
        DOT.POS = COUNT(RECORD,'.')
        K.TRANS = FIELD(RECORD,'.',DOT.POS,2)
        K.ACC = FIELD(RECORD,'.',1)
        IF K.ACC = K.POS.ACC THEN
            INS K.TRANS BEFORE DATA.REC<-1>
        END
        *
    REPEAT
*
    EB.Reports.setOData(DATA.REC)
    tmp.ODATA = EB.Reports.getOData()
    CONVERT @FM TO '' IN tmp.ODATA
    EB.Reports.setOData(tmp.ODATA)

*
    RETURN
*
    END
