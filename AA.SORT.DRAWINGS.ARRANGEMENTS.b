* @ValidationCode : MjotMjA1MjkxNTUxMzpDcDEyNTI6MTU3MDUyMDAwMjA0NzpyYWtzaGFyYTo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTA1LTEwNTQ6NDQ6NDQ=
* @ValidationInfo : Timestamp         : 08 Oct 2019 13:03:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rakshara
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 44/44 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190905-1054
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AA.PaymentPriority
SUBROUTINE AA.SORT.DRAWINGS.ARRANGEMENTS(MasterArrId, LinkedArrIds, SortedArrIds)
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Inout
* @param MasterArrId                -  Facility Arrangement id
* @param LinkedArrIds               -  Drawings under a Facility separated by VM
* @param SortedArrIds               -  Sorted Arrangements based on BILL.DATE
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 28/9/19       -         Task : 3198298
*                         Enhancement : 3164827
*                         Sort drawings based on arrangement start date for repayment through API.
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
*

    $USING EB.SystemTables
    $USING AA.PaymentPriority
    $USING AA.Framework
    $USING EB.API

*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>
  
    GOSUB Initialise
    GOSUB GetArrangementDetails              ;* Get arrangement and bill values
    GOSUB GetFinalArray

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialisation of local and common variables</desc>
Initialise:
***

* Store incoming data

    InLinkedArrIds = LinkedArrIds

*Clear incoming data

    LinkedArrIds = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetArrangementDetails>
*** <desc>Get Arrangement ids </desc>
GetArrangementDetails:
    
    ArrCt = 1
    LOOP
        ArrId = InLinkedArrIds<1,ArrCt> ;*
    WHILE ArrId
        AA.Framework.GetArrangement(ArrId, DrawRArrangement, RetError) ;* Fetch the arrangement record for the Drawing
        ArrStartDate<-1> = DrawRArrangement<AA.Framework.Arrangement.ArrStartDate> ;* get the Start date of the SubArrangement
        GOSUB GetSortedArray                  ;*Get arrangement values
        ArrCt += 1
    REPEAT
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetSortedArray>
*** <desc>Get Arrangement values </desc>
GetSortedArray:
    
    ArrArrStartDate = ArrStartDate<ArrCt>    ;* Get start date
    
    GOSUB SortDates                    ;* Sort dates

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SortDates>
*** <desc>Apply sorting based on rule</desc>
SortDates:
    
    IF NOT(SortedArrStartDate) THEN                 ;* If temporary array is empty, append values at first position
        Posn = 1
        GOSUB AppendValues
    END ELSE                       ;* If temporary array has values, sort the date
        GOSUB UpdateSortedArray    ;* Update array
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UpdateSortedArray>
*** <desc>Update sorted arrangement and its details in an array</desc>
UpdateSortedArray:
    
    FIND ArrArrStartDate IN SortedArrStartDate SETTING FMPos,DatePos THEN     ;* When same date is already present in the array, place it in next position
        Posn = FMPos
        GOSUB AppendValues
    END ELSE
*** Check if date is less than the present value in tmp array and place it before position returned
        LOCATE ArrArrStartDate IN SortedArrStartDate<1>  BY 'AL' SETTING DatePos THEN
        END ELSE
            INS ArrArrStartDate BEFORE SortedArrStartDate<DatePos>
            INS ArrId BEFORE SortedArrIdArray<DatePos>
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= AppendValues>
*** <desc>Update sorted arrangement and bill details in an array</desc>
AppendValues:

*Append arrangement and bill details to the next position seperated by VM
  
    SortedArrStartDate<Posn,-1> = ArrArrStartDate
    SortedArrIdArray<Posn,-1> = ArrId
       
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetFinalArray>
*** <desc>Update return arugument values</desc>
GetFinalArray:
   
    SortedArrIds = SortedArrIdArray         ;* Array with sorted arr ids
    ArrStartDates = SortedArrStartDate      ;* Array with sorted arr start date

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
