* @ValidationCode : MjotMTg2MTA4ODcwMTpDcDEyNTI6MTQ4NzI0Mzg1ODI4Njpyc3VkaGE6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTcwMi4wOjIxOjIx
* @ValidationInfo : Timestamp         : 16 Feb 2017 16:47:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 21/21 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE EB.Channels
    SUBROUTINE E.TC.CONV.MESSAGE.GROUP
*-----------------------------------------------------------------------------
** This conversion routine is used to find the Message Group of the TEC.ITEMS
*-----------------------------------------------------------------------------
* Modification History:
*
* 23/10/06 - EN_1957809 / Task 1957811
*            Alerts for TCIB16
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.Delivery
    $USING EB.DataAccess
    $USING EB.Template
    $USING EB.Logging
    $USING DE.Config
    $INSERT I_DAS.DE.MESSAGE.GROUP
*-----------------------------------------------------------------------------
    GOSUB PROCESS
*
    RETURN
*-------------------------------------------------------------------------
PROCESS:
*
    EVENT.ID = EB.Reports.getOData() ;*Event Id
    R.TECITEM = EB.Logging.TecItems.Read(EVENT.ID,Y.ERR) ;* Read the Event record
    IF R.TECITEM THEN
        EVENT.TYPE.ID=R.TECITEM<EB.Logging.TecItems.TecItEventType> ;* Get Event Type
        R.EVENT.TYPE=EB.SystemTables.EventType.Read(EVENT.TYPE.ID, EVENT.TYPE.ERR) ;* Read event type
        EB.ACTIVITY.ID=R.EVENT.TYPE<EB.SystemTables.EventType.EvnTypEbActivity> ;* Get the activity Id
        R.EB.ADVICES=EB.Delivery.Advices.Read(EB.ACTIVITY.ID, EB.ADVICES.ERR) ;* Read the Advices table
        GROUP.ID=''
        IF EB.ADVICES.ERR ELSE
            MESSAGE.APP.ID=R.EB.ADVICES<EB.Delivery.Advices.AdvMessageType>
            THE.LIST=dasMessageApp
            THE.ARGS=MESSAGE.APP.ID:"..."
            EB.DataAccess.Das("DE.MESSAGE.GROUP", THE.LIST, THE.ARGS, "") ;* Get the message group Id based on Messsage App
            THE.LIST=THE.LIST<1>
        END

    END
    EB.Reports.setOData(THE.LIST);*Assigning the result variable to the enquiry output
    RETURN
    END
