* @ValidationCode : Mjo5NTI3OTMyNzY6Q3AxMjUyOjE1OTI1NjM5NTg0NTc6cmFrc2hhcmE6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyMS0wNjU1OjE4OjE4
* @ValidationInfo : Timestamp         : 19 Jun 2020 16:22:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rakshara
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 18/18 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.DE.CONV.REPRICING.DATE(InValue,HeaderRec,MvNo,OutDate,ErrorMsg)
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>/desc>
* Arguments
*
* Input
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 05/06/20 - Enhancement : 3774161
*            Task        : 3784451
*            Logic to display repricing date based on incoming frequency.
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts

    $USING DE.Config
    $USING EB.SystemTables
    $USING EB.API

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise            ;* Initialise variables
    GOSUB DoProcess             ;* Main processing
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise all local variables required</desc>
Initialise:
    
    FormattedDate = ''
    OutDate = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DoProcess>
*** <desc>Main Logic</desc>
DoProcess:
    
    IntResetFreq = InValue       ;* Incoming frequency
    ValueDate    = HeaderRec<DE.Config.OHeader.HdrValueDate>   ;* Get value date
    
    IF ValueDate MATCHES "8N" THEN
        TmpComi = EB.SystemTables.getComi()
        EB.SystemTables.setComi(ValueDate:IntResetFreq)
        
        EB.API.Cfq()    ;* Get the next date
        RepricingDate = EB.SystemTables.getComi()[1,8]
        EB.SystemTables.setComi(TmpComi)
        
        FormattedDate = OCONV(ICONV(RepricingDate,"D4"),"D4E")   ;* Format date from YYYY/MM/DD to "DD MON YYYY"
    END
    
    OutDate = FormattedDate  ;* Return repricing date

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
