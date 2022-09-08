* @ValidationCode : MjotODA4MDExMTQyOkNwMTI1MjoxNjAwNzY4MDkyNTU0OnJhbmdhaGFyc2hpbmlyOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NToyNDoyNA==
* @ValidationInfo : Timestamp         : 22 Sep 2020 15:18:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rangaharshinir
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 24/24 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.DE.CONV.PROPERTY.DESCRIPTION(InValue,HeaderRec,MvNo,OutValue,ErrorMsg)
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
* 22/09/20  - Defect : 3963376
*             Task : 3963180
*             Conversion routine to get the property description
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts

    $USING AA.ProductFramework
    $USING AA.Framework

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
    
    OutValue = ''
    PropValue = ''
    PropName = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DoProcess>
*** <desc>Main Logic</desc>
DoProcess:

    PropValue = FIELD(InValue, '-',2)
    BEGIN CASE
        CASE PropValue EQ 'SKIM'
            OutValue = ''
        CASE PropValue NE ''
            PropName = PropValue
            GOSUB GetPropertyRecord ; *To get the property record
            OutValue = PropertyRec<AA.ProductFramework.Property.PropDescription>
        CASE 1
            PropName = FIELD(InValue, '-',1)
            GOSUB GetPropertyRecord ; *To get the property record
            OutValue = PropertyRec<AA.ProductFramework.Property.PropDescription>
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GetPropertyRecord>
GetPropertyRecord:
*** <desc>T get the property record </desc>
    PropertyRec = ''
    AA.Framework.LoadStaticData("F.AA.PROPERTY",PropName,PropertyRec,"")
RETURN
*** </region>

END

