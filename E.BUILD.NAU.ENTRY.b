* @ValidationCode : Mjo5MjA4NjgxNTU6Q3AxMjUyOjE1MDM1NTE5MDgzMTQ6cHVuaXRoa3VtYXI6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDkuMjAxNzA4MTQtMjMxMjozOjM=
* @ValidationInfo : Timestamp         : 24 Aug 2017 10:48:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : punithkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 3/3 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201709.20170814-2312
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank
SUBROUTINE E.BUILD.NAU.ENTRY (ENQ.DATA)
*-----------------------------------------------------------------------------
*
*This Build routine is designed for Enquiry "NAU.ENTRY" , for the modification of the TRANSACTION.REFERENCE.
*i.e. ID of the ENTRY.HOLD
*
* @stereotype   Subroutine
* @author       punithkumar@temenos.com
* Incoming        : ENQ.DATA-Common variable Which contains all the enquiry selection criteria details

* Outgoing        : ENQ.DATA Common Variable

* Attached to     : NAU.ENTRY enquiry

* Attached as     : Build Routine in the Field BUILD.ROUTINE
*-----------------------------------------------------------------------------
* Modification History :
* 22/08/2017 - Defect:2239715 / Task:2243996
*              New build routine has been created for for the modification of the TRANSACTION.REFERENCE w.r.t AA.ARRANGEMENT.ACTIVITY
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
* For the AA.ARRANGEMENT.ACTIVITY we will have the id as 'AAACT093574LGKXWTK' and the ENTRY.HOLD id will be 'AAAAAACT093574LGKXWTK'(pgm.type:id)
* When we fetch the Id, since other applications will have only extra 2 characters we fetch the Transaction reference from 3rd position ,where as for AA.ARRANGEMENT.ACTIVITY
* have extra 3 characters hence the ENQUIRY fails. hence here we are appending the extra "A" and sending as the query.

    IF ENQ.DATA<4>[1,5] EQ "AAACT" THEN    ;*for Arrangement activity (AAA)
        ENQ.DATA<4> ='A':ENQ.DATA<4>
    END

END
