* @ValidationCode : MjotMTI2NDAzOTM1NzpDcDEyNTI6MTU4Mzk4ODM4MzMzMTpzaGFzaGlkaGFycmVkZHlzOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMy4yMDIwMDIxMi0wNjQ2Oi0xOi0x
* @ValidationInfo : Timestamp         : 12 Mar 2020 10:16:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : shashidharreddys
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.20200212-0646
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE DE.Messaging
SUBROUTINE DE.ORD.CANCEL.REQ.DELIVERY
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 11/03/20 - Enhancement 3613636 / Task 3631447
*            Routine to trigger for SETR01400104 to call application handoff and to generate if event.
*
*-----------------------------------------------------------------------------


    $USING EB.SystemTables
    $USING DE.API
    $USING EB.API
    
    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*-----------------------------------------------------------------------------
INITIALISE:

    Rec1 = ''
    ErrorMsg = ''
    DelRef = ''

    DIM HandoffInfo(8)                                                      ;* Initialise the Dim array
    Rec1 = EB.SystemTables.getDynArrayFromRNew()                            ;* Get the Array for the dynamic appliction
    Rec2<1> = EB.SystemTables.getIdCompany()                                ;* Set company as the header details
    Rec2<2> = EB.SystemTables.getIdCompany()                                ;* Setcompany as the header details
    Rec2<3> = EB.SystemTables.getIdNew()                                    ;* Set Id as the header details
    Rec2<4> = Rec1<DE.Messaging.DeSetr01400104.DeSet62DeptCode>             ;* Set DEPARTMENT CODE as the header details
    Rec2<5> = EB.SystemTables.getLngg()                                     ;* Set Language as the header details
    Rec2<6> = Rec1<DE.Messaging.DeSetr01400104.DeSet62Receiver>             ;* Set Receiver Address as the header details
    Rec2<7> = 'ISOMX'                                                       ;* Set Carrier Address as the header details
    Rec2<8> = Rec1<DE.Messaging.DeSetr01400104.DeSet62Receiver>             ;* Set Receiver Address as the header details
    
    HandoffInfo(1) = Rec1                                                   ;* Pass the Rnew array as first array for appliction hand off

RETURN
*-----------------------------------------------------------------------------
PROCESS:

    MappingKey = 'SETR01400104.DE.1'                                        ;* Pass the Mapping Key

    DE.API.ApplicationHandoff(Rec1, Rec2, '', '', '', '', '', '', '', MappingKey, DelRef, ErrorMsg)     ;* Call Application HandOff
    EB.SystemTables.setRNew(DE.Messaging.DeSetr01400104.DeSet62DeliveryRef, DelRef)                     ;* Set the Delivery REF
    
RETURN
*-----------------------------------------------------------------------------

END



