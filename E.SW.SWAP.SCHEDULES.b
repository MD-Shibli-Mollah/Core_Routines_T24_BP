* @ValidationCode : MjoxNDk1MTMyMDMzOkNwMTI1MjoxNTA5MDExOTczNzg5OnNlbGF5YXN1cml5YW46LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcxMC4yMDE3MDkxNS0wMDA4Oi0xOi0x
* @ValidationInfo : Timestamp         : 26 Oct 2017 15:29:33
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : selayasuriyan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.20170915-0008
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE SW.Reports
SUBROUTINE E.SW.SWAP.SCHEDULES(scheduleList)
*-----------------------------------------------------------------------------
* Build routine for the enquiry SWAP.SCHEDULES
*-----------------------------------------------------------------------------
* Modification History :
*
* 22/09/17 - Defect 2103204 / Task 2282526
*            Every label on the screen is duplicated and there are characters that have been added
*            as well between the duplicate labels
*
*-----------------------------------------------------------------------------
*  Insert files.
*
    $USING EB.Reports
    $USING SW.Reports
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *Initialise and Save the common variable
    GOSUB BUILD.ARRAY ; *Build the enquiry data

    
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise and Save the common variable </desc>

    SW.Reports.ESwapContractId(IdList)
    EB.Reports.setId(IdList)
    scheduleList = ""

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= BUILD.ARRAY>
BUILD.ARRAY:
*** <desc>Build the enquiry data </desc>

    SW.Reports.ESwFutureSchedule()
    
    getRRecord = EB.Reports.getRRecord()    ;* Variable holding the display data
    
    shedList = getRRecord<154>  ;* Total number of schedules
    schedCount = DCOUNT(shedList, @VM)
* Form the enquiry data to be returned
    FOR I=1 TO schedCount
        scheduleList<-1> = getRRecord<158,I> :"*": getRRecord<154,I> :"*": getRRecord<161,I> :"*": getRRecord<155,I> :"*": getRRecord<156,I> : "*" : getRRecord<157,I> :"*": getRRecord<2,1> :"*": getRRecord<1,1> :"*": getRRecord<150,I>: "*": getRRecord<151,I>:"*":getRRecord<152,I>:"*":IdList:"*":getRRecord<8,1>
    NEXT I
        
RETURN
*** </region>

END


