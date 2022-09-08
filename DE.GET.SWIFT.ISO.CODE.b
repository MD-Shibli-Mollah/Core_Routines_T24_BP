* @ValidationCode : MjoxNDQ5ODg4MTkxOkNwMTI1MjoxNTc4MzAzNzI3MDYzOnZhbmthd2FsYWhlZXI6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMS4yMDE5MTAyNC0wMzM1OjE5OjE5
* @ValidationInfo : Timestamp         : 06 Jan 2020 15:12:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vankawalaheer
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 19/19 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201911.20191024-0335
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE DE.API
SUBROUTINE DE.GET.SWIFT.ISO.CODE(SwiftCodeWordDetails,SwiftCodeWord,Reserved1,Reserved2)
*-----------------------------------------------------------------------------
* Routine to get SWIFT.CODE.WORD for ISO.REASON.CODE
*The SwiftCodeWordDetails contains below
*SwiftCodeWordDetails<1>-MessageType
*SwiftCodeWordDetails<2>-ServiceTypeId
*SwiftCodeWordDetails<3>-AnswerCode
*SwiftCodeWordDetails<4>-IsoReasonCode
*SwiftCodeWordDetails<5>-SwiftIsoCodeWord
*SwiftCodeWord - Returned 1st Id of the selected SWIFT.CODE.WORDS list
*Reserved1 - For future use
*Reserved2 - For future use
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 20/11/19 - Enhancement 3434184 / Task 3434186
*            Get SWIFT.CODE.WORD for ISO.REASON
*
* 30/12/2019 - Enhancement 3517938 / Task 3517944
*              when AnswerCode and IsoReasonCode is not present then update the values from SWIFT.CODE.WORDS Record
*-----------------------------------------------------------------------------

    $USING DE.Config
    $USING EB.Delivery
   
    Error = ''
    VMPOS = ''
    SMPOS = ''
    RecId = ''
    ConcatRec = ''
    IF SwiftCodeWordDetails<DE.API.SwiftIsoCodeWord> THEN
        Id = SwiftCodeWordDetails<DE.API.SwiftIsoCodeWord>
        SwiftCodeWordsRec = DE.Config.SwiftCodeWords.Read(Id, Error) ;*Read the SwiftCodeWords Record
        IF SwiftCodeWordsRec THEN ;*If SwiftCodeWords then return the value of ANSWER.CODE and ISO.REASON.CODE
            SwiftCodeWord<DE.API.AnswerCode> = SwiftCodeWordsRec<DE.Config.SwiftCodeWords.ScwAnswerCode>
            SwiftCodeWord<DE.API.IsoReasonCode> = SwiftCodeWordsRec<DE.Config.SwiftCodeWords.ScwIsoReasonCode>
        END
    END ELSE
        RecId = SwiftCodeWordDetails<DE.API.ServiceTypeId>:"*":SwiftCodeWordDetails<DE.API.AnswerCode>:"*":SwiftCodeWordDetails<DE.API.IsoReasonCode>
        ConcatRec = DE.Config.DeSwiftCodeWordConcat.Read(RecId,Error)
        FIND SwiftCodeWordDetails<DE.API.MsgType> IN ConcatRec<DE.Config.DeSwiftCodeWordConcat.ScwcMessageType> SETTING VMPOS,SMPOS THEN
            SwiftCodeWord<DE.API.SwiftCodeWord> = ConcatRec<DE.Config.DeSwiftCodeWordConcat.ScwcSwiftCodeWord,VMPOS>
        END
    END
END
