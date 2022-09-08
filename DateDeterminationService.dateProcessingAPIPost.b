* @ValidationCode : MjoyMDg2NTY0NTpDcDEyNTI6MTU0MjM1Mzc0MjA4Mjpza2F5YWx2aXpoaTo4OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODExLjIwMTgxMDIyLTE0MDY6Mjk6Mjk=
* @ValidationInfo : Timestamp         : 16 Nov 2018 13:05:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 29/29 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PP.DateDeterminationService
SUBROUTINE DateDeterminationService.dateProcessingAPIPost(iDatesApiInputDetails, iChannelDetails, iDebitBankConditionDets, iCreditPartyDetails, iAccountInfo, oDatesPostApiOutputDetails)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*   This routine is designed to cater the needs of the bank where they decide to use the external API for defining their own date determination logic.
*   This is the dummy API Routine to test the various cases by changing the PVD, CVD, DVD according to the requirements for the Past Value Date enhancement
*   This will be called when Component API Hook table is configured for a calling component. This is Post hook API routine. Hence it will be called
*   at the end of the calling component
* 16/11/2018 - Enhancement 2822509/Task 2856019- Componentization changes
*-----------------------------------------------------------------------------

   
    $INSERT I_DateDeterminationService_DatesPostApiOutputDetails
    GOSUB Process

RETURN
Process:
    
    FINDSTR 'HookApi' IN iAccountInfo SETTING Pos,Pos1 THEN                       ;* Check if the customer is created with pre-defined name
        GOSUB setOutputValues
    END ELSE
        oDatesPostApiOutputDetails = ''   ;* standard flow
    END

RETURN
 
setOutputValues:
    
    BEGIN CASE
   
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiWTTT'
            oDatesPostApiOutputDetails<PP.DateDeterminationService.DatesPostApiOutputDetails.responseCode>='2' ;*Warning
           
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiETTT'
            oDatesPostApiOutputDetails<PP.DateDeterminationService.DatesPostApiOutputDetails.responseCode>='1'  ;*error
    
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiWR'
            oDatesPostApiOutputDetails<PP.DateDeterminationService.DatesPostApiOutputDetails.responseCode>='2' ;*Warning text returned from API
            oDatesPostApiOutputDetails<PP.DateDeterminationService.DatesPostApiOutputDetails.responseText>='Warning response text returned from Hook API'
      
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiER'
            oDatesPostApiOutputDetails<PP.DateDeterminationService.DatesPostApiOutputDetails.responseCode>='1' ;*Error text returned from API
            oDatesPostApiOutputDetails<PP.DateDeterminationService.DatesPostApiOutputDetails.responseText>='Error response text returned from Hook API'
        
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiINR'
            oDatesPostApiOutputDetails<PP.DateDeterminationService.DatesPostApiOutputDetails.responseCode>='3' ;*Invalid code
            oDatesPostApiOutputDetails<PP.DateDeterminationService.DatesPostApiOutputDetails.responseText>='Invalid response code'
          
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApi'
            oDatesPostApiOutputDetails = ''                                         ;*standard flow
                     
        CASE 1
            oDatesPostApiOutputDetails<PP.DateDeterminationService.DatesPostApiOutputDetails.responseCode>='0'  ;*success
            

    END CASE
RETURN
END

