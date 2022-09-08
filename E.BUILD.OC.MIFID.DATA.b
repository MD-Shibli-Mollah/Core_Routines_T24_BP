* @ValidationCode : MjotMTg1MzExNTYyNTpDcDEyNTI6MTU4NzcyNjA4OTE2Mzpwcml5YWRoYXJzaGluaWs6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2OjM3OjM2
* @ValidationInfo : Timestamp         : 24 Apr 2020 16:31:29
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : priyadharshinik
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/37 (97.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE E.BUILD.OC.MIFID.DATA(OUT.ARRAY)

*** <region name= Description>
*** <desc> </desc>

*This routine is called from enquiry OC.API.MIFID.DETS.1.0.0 which is a drilldown enquiry to OC.TRANSACTIONS enquiry.
*The routine fetches the details of OC.API.MIFID.DATA.1.0.0 file, that is developed using Tax Engine framework.

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Reporting>
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
*-----------------------------------------------------------------------------
*
* 27/03/19 - Enhancement 3660952 / Task 3660953
*            CI#5 - Open up the no input fields for MIFID in ND.DEAL.
*            Enquiry routine for the enq OC.API.MIFID.DETS.1.0.0
*
*-----------------------------------------------------------------------------
*** </region>

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

    OC.MIFID.ID = ''

    LOCATE 'OC.ID' IN EB.Reports.getDFields()<1> SETTING ID.POS THEN
        OC.MIFID.ID = EB.Reports.getDRangeAndValue()<ID.POS> ; * get the reference from the selection fields
    END

    FN.OC.MIFID.DATA = 'F.OC.MIFID.DATA'  ;* should be the database filename
    F.OC.MIFID.DATA = ''

    EB.DataAccess.Opf(FN.OC.MIFID.DATA,F.OC.MIFID.DATA)

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
    R.OC.MIFID = ''
    OC.ERR = ''

    R.OC.MIFID = OC.Reporting.MifidData.Read(OC.MIFID.ID, OC.ERR)

* Get the standard selection details of the database file
    SS.ID = 'OC.MIFID.DATA'

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
        FIELD.CONTS = R.OC.MIFID<FLD.POS> ;* get the corresponding field value from file

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
