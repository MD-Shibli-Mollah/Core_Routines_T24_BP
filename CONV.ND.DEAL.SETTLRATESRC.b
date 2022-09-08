* @ValidationCode : Mjo2NDM5Mzg3NDU6Q3AxMjUyOjE1MDI4NzgwNDkzNzk6aGFycnNoZWV0dGdyOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDguMDotMTotMQ==
* @ValidationInfo : Timestamp         : 16 Aug 2017 15:37:29
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201708.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE FX.Contract
SUBROUTINE CONV.ND.DEAL.SETTLRATESRC(ID,REC,FILE)
*-----------------------------------------------------------------------------
* This Subroutine copies the value from the local field SETTL.RATE.SOURCE
* to the core field SETTL.RATE.SRC of ND.DEAL as SETTL.RATE.SRC is mandatory during all events of ND except rate fixing
*
* 28/07/17 - Enh. 2172478 / Task 2172493
*            Swift 2017 changes for Treasury
*
* 28/07/17 - Defect 2235937 / Task 2235942
*            Technical bug in the conversion routine 
*            SM markers are to be converted into VM, as Local ref field will have multiples values seperated by SM
* 
*-----------------------------------------------------------------------------
**** <region name= Inserts>

    $INSERT I_COMMON
    $INSERT I_EQUATE

*** </region>
*-----------------------------------------------------------------------------

    GOSUB Process ;* Perform the process of assigning values from local field to core field

RETURN

*-----------------------------------------------------------------------------
*** <region name= Process>
Process:
*** <desc>Perform the process of assigning values from local field to core field </desc>
    locAppln = 'ND.DEAL'
    locFields = 'SETTL.RATE.SRC'
    locPos = ''
    
    CALL MULTI.GET.LOC.REF(locAppln,locFields,locPos)    ;* gets the field position of SETTL.RATE.SRC
    
    SourcePos = locPos<1,1>

    SettlRateSource = REC<108,SourcePos> ;* settl rate source
    
    CONVERT SM TO VM IN SettlRateSource
    
    NoOfSource = DCOUNT(SettlRateSource, VM)
    

    FOR I = 1 TO NoOfSource
        REC<95,I> = SettlRateSource<1,I>
    NEXT I


RETURN
*** </region>
*-----------------------------------------------------------------------------

END

