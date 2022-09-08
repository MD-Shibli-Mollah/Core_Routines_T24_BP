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
* <Rating>-44</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Parameters
    SUBROUTINE E.BUILD.OC.TRADE.DATA(OUT.ARRAY)

*** <region name= Description>
*** <desc> </desc>

*This routine is called from enquiry OC.TXN.DETS which is a drilldown enquiry to OC.TRANSACTIONS enquiry.
*The routine fetches the details of OC.TRADE.DATA file, that is developed using Tax Engine framework.

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Parameters>
*** <desc> </desc>

*OUT.ARRAY - An outgoing parameter that contains the details of field position, field name, field value
*in the format,
*
*OUT.ARRAY<x> = Field Position * Field Name * Field Value
*
*Field position is retrieved from FIELD.NO field of Standard selection
*Field name is retrieved from FIELD.NAME field of Standard selection
*Field value is retrieved from the respective record of OC.TRADE.DATA

*** </region>

*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc> </desc>

* 17-03-15 - EN - 1047936 / Task - 1283695
*            Building of OC.TRADE.DATA
*
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine
*** </region>
*-----------------------------------------------------------------------------


*** <region name= Inserts>
*** <desc> </desc>



    $USING EB.SystemTables
    $USING EB.API
    $USING EB.Reports
    $USING OC.Parameters
    $USING EB.DataAccess



*** </region>
*-----------------------------------------------------------------------------

*** <region name= Work flow>
*** <desc> </desc>

    GOSUB INITIALISE

    GOSUB GET.OC.DETAILS

    GOSUB PROCESS.OC.DETAILS

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>

    OC.TRA.ID = ''

    LOCATE 'OC.ID' IN EB.Reports.getDFields()<1> SETTING ID.POS THEN
    OC.TRA.ID = EB.Reports.getDRangeAndValue()<ID.POS> ; * get the reference from the selection fields
    END

    FN.OC.TRA.DATA = 'F.OC.TRADE.DATA'  ;* should be the database filename
    F.OC.TRA.DATA = ''

    EB.DataAccess.Opf(FN.OC.TRA.DATA,F.OC.TRA.DATA)

    SS.ID = ''
    OC.SS.REC = ''
    NO.OF.SYS.FIELDS = ''
    FLD.POS = ''
    RET.ARRY = ''

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.OC.DETAILS>
GET.OC.DETAILS:
*** <desc> </desc>

* Get the record updated in database file
    R.OC.TRA = ''
    OC.ERR = ''

    R.OC.TRA = OC.Parameters.TradeData.Read(OC.TRA.ID, OC.ERR)
* Before incorporation : CALL F.READ('F.OC.TRADE.DATA',OC.TRA.ID,R.OC.TRA,F.OC.TRA.DATA,OC.ERR)

* Get the standard selection details of the database file
    SS.ID = 'OC.TRADE.DATA'

    EB.API.GetStandardSelectionDets(SS.ID,OC.SS.REC)

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS.OC.DETAILS>
PROCESS.OC.DETAILS:
*** <desc> </desc>

    NO.OF.SYS.FIELDS = DCOUNT(OC.SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName>,@VM)

    FOR FIELD.NO = 1 TO NO.OF.SYS.FIELDS


        FLD.POS = OC.SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,FIELD.NO>



        FIELD.NAMES = OC.SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,FIELD.NO>
        FIELD.CONTS = R.OC.TRA<FLD.POS> ;* get the corresponding field value from file

        IF FLD.POS = '0' THEN ;* dont fetch the value for ID
            CONTINUE
        END
        IF FIELD.CONTS NE '' THEN   ;* display only the updated fields
            RET.ARRY<-1> = FLD.POS:"*":FIELD.NAMES:"*":FIELD.CONTS
        END

    NEXT FIELD.NO

    OUT.ARRAY = RET.ARRY

    RETURN
*** </region>

    END ; * end of routine
