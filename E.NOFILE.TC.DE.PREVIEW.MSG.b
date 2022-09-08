* @ValidationCode : MjotMTMyMTkzMjM5OTpDcDEyNTI6MTUxODUwNzE2Nzk3MDp2cGRpbGlwa3VtYXI6MTowOi0yODotMTpmYWxzZTpOL0E6REVWXzIwMTgwMS4yMDE3MTIyMy0wMTUxOjI2OjI2
* @ValidationInfo : Timestamp         : 13 Feb 2018 13:02:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vpdilipkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : -28
* @ValidationInfo : Coverage          : 26/26 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201801.20171223-0151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-33</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DE.Channels
SUBROUTINE E.NOFILE.TC.DE.PREVIEW.MSG(FINAL.ARRAY)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
*
* To fetch preview message details
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : No-file routine
* Attached To        : Enquiry > TC.NOF.DE.PREVIEW.MSG using the Standard selection NOFILE.TC.DE.PREVIEW.MSG
* IN Parameters      : Message Id (MESSAGE.ID)
* Out Parameters     : Array of message details (FINAL.ARRAY)
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2410871
*             TCIB2.0 Corporate - Advanced Functional Components - Delivery
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the subroutine. </desc>
* Inserts

    $USING DE.Channels
    $USING DE.ModelBank
    $USING EB.Reports
    
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing logic. </desc>

    GOSUB INITIALISE
    GOSUB PROCESS
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise variables used in this routine. </desc>
INITIALISE:
*-------------
    MessageId ='';RDePreviewMsg = '' ;  ErrMsg = ''

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>This has the processing logic to fetch the message details. </desc>
PROCESS:
*-------------
    LOCATE "MESSAGE.ID" IN EB.Reports.getDFields()<1> SETTING MessagePosition THEN ;*Locate criteria field
        MessageId= EB.Reports.getDRangeAndValue()<MessagePosition> ;*Read the criteria field value
    END
    IF MessageId NE '' THEN
        RDePreviewMsg = DE.ModelBank.PreviewMsg.Read(MessageId, ErrMsg) ;*Read the preview message record based on the message id
        MessagesCount = DCOUNT(RDePreviewMsg,@FM)
        Iterator = 1
        LOOP
        WHILE Iterator LE MessagesCount ;*Loop to read the message line by line
            MessageDetail = RDePreviewMsg<Iterator>
            SpaceTag = "<S>"
            CHANGE ' ' TO SpaceTag IN MessageDetail ;*Replace blank strings in the message with space tag
            IF MessageDetail NE ' ' THEN
                LineBreakTag = "<br>"
                MessageDetail = MessageDetail : LineBreakTag ;*Append line breaks at the end of each line of message
                FINAL.ARRAY = FINAL.ARRAY:MessageDetail
            END
            Iterator = Iterator + 1
        REPEAT
    END
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------

END
