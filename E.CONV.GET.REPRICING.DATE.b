* @ValidationCode : MjotNjc5MDk4MDE4OkNwMTI1MjoxNjA0MzE0MDQ3MTQzOnJhbmdhaGFyc2hpbmlyOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NToxNDoxNA==
* @ValidationInfo : Timestamp         : 02 Nov 2020 16:17:27
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rangaharshinir
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 14/14 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.CONV.GET.REPRICING.DATE
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Program Description </desc>
**
*
* Conversion Routine in Enquiry>
*
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
* 28/10/20 - Defect : 3760751
*            Task   : 4048740
*            Conversion routine to get repricing date of the scheduled activity
*
** 02/11/20 - Enhancement : 4051785
*             Task : 4057349
*             Change of Activity Action to Rate.Fix for interest properties
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Inserts>
***
   
    $USING EB.Reports
    $USING AA.Framework
    $USING EB.SystemTables
    
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

    InDetails = EB.Reports.getOData() ;* eg. ArrangementId~ProductLine~Property
    
    ArrangementId = FIELD(InDetails,'~',1)
    ProductLine = FIELD(InDetails,'~',2)
    Property = FIELD(InDetails,'~',3)
    ActAction = 'RATE.FIX'
    RepricingDate = ''
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main Process>
*** <desc>Main control logic in the sub-routine</desc>
MainProcess:
*------------
 
    RepricingActivity = ProductLine:AA.Framework.Sep:ActAction:AA.Framework.Sep:Property
 
    AA.ModelBank.GetRepricingDate(ArrangementId, RepricingActivity, '', RepricingDate)
    
    EB.Reports.setOData(RepricingDate)

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
