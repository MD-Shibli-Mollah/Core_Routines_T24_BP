* @ValidationCode : MjotMTI0NTUwOTczNTpDcDEyNTI6MTYwMzQzNDA2NDM1MTpyYW5nYWhhcnNoaW5pcjoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTIxLTA2NTU6NDA6NDA=
* @ValidationInfo : Timestamp         : 23 Oct 2020 11:51:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rangaharshinir
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 40/40 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.DE.CONV.UNSIGNED.AMOUNT(InValue,HeaderRec,MvNo,OutValue,ErrorMsg)
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>/desc>
*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
** This routine will be attached to the DE.FORMAT as a convertion routine
**When the mapped amount is along with the sign('+' or '-'), this routine returns the invalue avoiding the sign.
**And also the amount must be displayed in the respective currency's form. Respective currency is picked from the header.
*
**Hence this conversion is to format the incoming amount  - unsigned and currency specific
*-----------------------------------------------------------------------------
* @class AA.Modelbank
* @package retaillending.AA
* @stereotype subroutine
* @author rangaharshinir@temenos.com
*-----------------------------------------------------------------------------
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
* Input
*
* InValue       - Amount mapped to be formatted
*
* HeaderRec     - Header Record from which currency is fetched
*
* MvNo          
*
* Output
*
* OutValue      - Formatted amount
*
* ErrorMsg      - Error message to be returned if any
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 22/10/20 - Enhancement : 4038257
*            Task        : 3969862
*            To convert the signed to unsigned amount
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts
    
    $USING DE.Config
    $USING EB.Template
    $USING EB.SystemTables
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise            ;* Initialise variables
    IF InChangeAmt AND InCurrency THEN
        GOSUB DoProcess             ;* Main processing
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise all local variables required</desc>
Initialise:
    
    AmountLength = ''
    OutValue = ''
    InChangeAmt = ''
    OutChangeAmt = ''
    SaveComi = ''
    SaveVDisplay = ''
    SaveEtext = ''
    InChangeAmt = InValue
    InCurrency = HeaderRec<DE.Config.IHeader.HdrCurrency>
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DoProcess>
*** <desc>Main Logic</desc>
DoProcess:
    GOSUB SaveCommons ; *To save the existing commons
    
    IF InChangeAmt[1,1] EQ "-" THEN
        AmountLength = LEN(InChangeAmt)
        OutChangeAmt = InChangeAmt[2,AmountLength]
    END ELSE
        OutChangeAmt = InChangeAmt
    END
        
    EB.SystemTables.setComi(OutChangeAmt)
    EB.SystemTables.setVDisplay("")
    T1<1,1> = 'AMT'
    T1<2,2> = InCurrency
    T1<2,6> = 'YES'  ;*Not to check on the no of decimals validation
    EB.Template.In2amt('19',T1)
    T1<2,6> = ""  ;*To check on the no of decimals validation
    OutValue =  EB.SystemTables.getVDisplay()
    GOSUB SetCommons
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= SaveCommons>
SaveCommons:
*** <desc>To save the existing commons </desc>
    SaveComi = EB.SystemTables.getComi()
    SaveVDisplay = EB.SystemTables.getVDisplay()
    SaveEtext = EB.SystemTables.getEtext()
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= SaveCommons>
SetCommons:
*** <desc>To save the existing commons </desc>
    EB.SystemTables.setComi(SaveComi)
    EB.SystemTables.setVDisplay(SaveVDisplay)
    EB.SystemTables.setEtext(SaveEtext)
RETURN
*** </region>

*-----------------------------------------------------------------------------
END

