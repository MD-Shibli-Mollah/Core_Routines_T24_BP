* @ValidationCode : MjotNDIyNTk4Mjg5OkNwMTI1MjoxNjE1MjkyMzc0MzA0OnJha3NoYXJhOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMjAyMTAzMDEtMDU1NjoxNzoxNw==
* @ValidationInfo : Timestamp         : 09 Mar 2021 17:49:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rakshara
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 17/17 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.CONV.ACCR.LAST.PERIOD.END
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Program Description </desc>
**
* Conversion routine to return last period date
*
* @uses I_ENQUIRY.COMMON I_F.AA.ARRANGEMENT
* @package AA.ModelBank
* @stereotype subroutine
* @author divyasaravanan@temenos.com
*
**

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*
* 06/11/20 - Task : 4065402
*            Enhancement : 3164925
*            Conversion routine to return last period date
*
* 05/02/21 - Task   : 4214632
*            Defect : 4184741
*            Interest period end is appearing as last period end date irrespective
*            of period end date given in selection field.
*
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Inserts>
***
   
    $USING EB.Reports
    $USING AA.Interest

*** </region>

*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>
    GOSUB Initialise
    GOSUB MainProcess

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
Initialise:
*----------
    
    tmp.O.DATA = ''
    tmp.O.DATA = EB.Reports.getOData()

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc>Main control logic in the sub-routine</desc>
MainProcess:
*------------

    IF tmp.O.DATA THEN
        CONVERT '~' TO @VM IN tmp.O.DATA
        PeriodCount = DCOUNT(tmp.O.DATA, @VM) ;* Get the total period end days
        IF tmp.O.DATA<1,PeriodCount> THEN
            OutData = tmp.O.DATA<1,PeriodCount> ;* Get the last period end date
        END ELSE
            OutData = tmp.O.DATA<1,PeriodCount-1>
        END
    
        EB.Reports.setOData(OutData) ;* Set OData value
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
END

