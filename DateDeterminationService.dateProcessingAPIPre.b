* @ValidationCode : MjotMTE2NTcxNTExMzpDcDEyNTI6MTYwMDE2NDcyMjk4MDpubmF2ZWVucmFqYWg6MjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNToxMjY6MTEx
* @ValidationInfo : Timestamp         : 15 Sep 2020 11:12:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nnaveenrajah
* @ValidationInfo : Nb tests success  : 22
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 111/126 (88.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* @author     :  nandhinisiva@temenos.com
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*   This routine is designed to cater the needs of the bank where they decide to use the external API for defining their own date determination logic.
*   This is the dummy API Routine to test the various cases by changing the PVD, CVD, DVD according to the requirements for the Past Value Date enhancement
*   This will be called when Component API Hook table is configured for a calling component. This is Pre hook API routine. Hence it will be called
*   at the beginning of the calling component
* 16/11/2018 - Enhancement 2822509/Task 2856019- Componentization changes
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
$PACKAGE PP.DateDeterminationService
SUBROUTINE DateDeterminationService.dateProcessingAPIPre(iDatesApiInputDetails, iChannelDetails, iDebitBankConditionDets, iCreditPartyDetails, iAccountInfo, oDatesPreApiOutputDetails)

*-----------------------------------------------------------------------------
    
    $INSERT I_DateDeterminationService_DatesPreApiOutputDetails
    $INSERT I_DateDeterminationService_InDateDetails
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATES
    GOSUB process

RETURN

process:
  
    FINDSTR 'HookApi' IN iAccountInfo SETTING Pos,Pos1 THEN  ;* Check if the customer is created with pre-defined name
        GOSUB checkPVDCasesAccountInfo
    END ELSE
        oDatesPreApiOutputDetails=''
    END
RETURN
 
 
checkPVDCasesAccountInfo:
 
    today=R.DATES(EB.DAT.TODAY)                                              ;*Assigning the T24 today date (assumed to day 5 - 20091231)
    past= R.DATES(EB.DAT.LAST.WORKING.DAY)                                   ;*Assigning the T24 last working date
    future= R.DATES(EB.DAT.NEXT.WORKING.DAY)                                 ;*Assigning the T24 next working date
    CALL CDT('', future, '+5W')                                              ;*Adding 5 working days
    bankHoliday=today
    futureBankHoliday=today
    CALL CDT('', bankHoliday, '-6C')                                         ;*Assigning the bank holiday (20091225)
    CALL CDT('', futureBankHoliday, '+10C')                                    ;*Assigning the future bank holiday (20100110)
    
        
    
        
    BEGIN CASE
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiTTT'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=today
           
             
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiTPP'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=past
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=past
            
               
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiTTN'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=''
           
                
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiTPN'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=past
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=''
          
            
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiBBB'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=bankHoliday
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=bankHoliday
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=bankHoliday
           
                
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiFTT'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=future
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=today
            GOSUB CheckImposed                              ;*Check for the warehouse flag
            
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiFPP'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=future
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=past
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=past
            GOSUB CheckImposed
                
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiFTN'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=future
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=''
            GOSUB CheckImposed
               
                
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiFPN'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=future
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=past
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=''
            GOSUB CheckImposed
                
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiFBBB'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=futureBankHoliday
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=bankHoliday
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=bankHoliday
            GOSUB CheckImposed

        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiNTT'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=''
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=today

                
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiPPP'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=past
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=past
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=past

               
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiWTTT'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=today
    
        
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiETTT'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=today
            
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiNNT'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=''
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=''
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=today
         
;*Return warning with response
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiWR'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=today
        
;* Return error with response
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiER'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=today
            
;* Invalid response
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiINR'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=today
            
;* Invalid dates
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiINV'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate>=today:today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate>=today:today
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate>=today:today
            
;* Date Determination PROC is in past
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiPAST'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate> = "20091228"
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate> = "20100101"
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate> = "20091231"
            
;* Date Determination Dates Pre API Hook returned Processing Date or Credit Value Date
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiDBT'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate> = "20091231"
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate> = "20100101"
*oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate> = "20091231"
            
;* Date Determination Dates Pre API Hook returned Processing Date or Debit Value Date alone
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiCDT'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate> = "20091231"
*oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate> = "20100101"
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate> = "20091231"
            
;* Date Determination according to our need
        CASE iAccountInfo<Pos,Pos1> EQ 'HookApiRAN'
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate> = "20091231"
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.creditValueDate> = "20100101"
            oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.debitValueDate> = "20091231"
            
        CASE 1
            oDatesPreApiOutputDetails=''                                                ;*Standard flow
        
    END CASE
RETURN
        
 
;*Check for the warehouse flag
CheckImposed:
        
   
    IF iDatesApiInputDetails<PP.DateDeterminationService.InDateDetails.stpEntryPoint> EQ 'WH' THEN
        oDatesPreApiOutputDetails<PP.DateDeterminationService.DatesPreApiOutputDetails.processingDate> = today
    END
    
RETURN


END
