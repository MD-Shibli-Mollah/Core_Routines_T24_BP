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
    SUBROUTINE E.SC.POS.DET2(YD.LIST)
************************************************************
*
*    SUBROUTINE TO EXTRACT SECURITY TRANS KEYS
*    FROM F.TRN.CON.DATE TO BE USED IN ENQUIRY
*    SC.POS.DET
*-----------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modification History </desc>
* Modification History:
*
* 23/12/04 - EN_10002382
*            SC Phase I non stop processing.
*
* 04/10/06 - CI_10044472
*            Unable to view  Customer position
*            when we drill down SC.POS.DET2
*
* 25/11/08 - GLOBUS_BG_100020996 - dgearing@temenos.com
*            Tidy up, remove un-necessary code, remove dead code
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
    DATA.REC = ''
*
    R.TRN.CON.DATE = '' ; EB.SystemTables.setEtext('')
    K.POS = EB.Reports.getDRangeAndValue()
    K.POS.ACC = FIELD(K.POS,'.',1)

    SC.ScoSecurityPositionUpdate.ReadTrnConDate(K.POS,R.TRN.CON.DATE,EB.SystemTables.getEtext())

*
    ARRAY = R.TRN.CON.DATE
    LOOP UNTIL ARRAY = '' DO
        *
        RECORD = ARRAY<1>
        DEL ARRAY<1>
        DOT.POS = COUNT(RECORD,'.')
        K.TRANS = FIELD(RECORD,'.',DOT.POS,2)
        K.ACC = FIELD(RECORD,'.',1)
        INS K.TRANS BEFORE DATA.REC<1>
    REPEAT
    YD.LIST = DATA.REC
    EB.Reports.setEnqKeys(DATA.REC)
    RETURN

    END
