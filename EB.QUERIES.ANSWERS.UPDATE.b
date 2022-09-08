* @ValidationCode : MjotNTE1MDE5NDgzOkNwMTI1MjoxNTc0MTU5MjEzNDkwOnZhbmthd2FsYWhlZXI6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMS4yMDE5MTAyNC0wMzM1OjE4OjE4
* @ValidationInfo : Timestamp         : 19 Nov 2019 15:56:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vankawalaheer
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 18/18 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201911.20191024-0335
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE DE.Messaging
SUBROUTINE EB.QUERIES.ANSWERS.UPDATE(EbqaDetails,ErrorDetails,Reserved1,Reserved2)
*-----------------------------------------------------------------------------
*This routine updates the EBQA record
*The EBQA details contains below
*EbqaDetails<1>-TransactionRef
*EbqaDetails<2>-Status
*EbqaDetails<3>-ProcessIndicator
*EbqaDetails<4>-ErrorReason
*ErrorDetails - Error if any
*Reserved1 - For future use
*Reserved2 - For future use
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 15/11/19 - Enhancement 3434148 / Task 3434151
*            Update EB.QUERIES.ANSWERS Record
*-----------------------------------------------------------------------------

    $USING DE.Messaging
    $USING EB.SystemTables
    
    GOSUB UPDATE.RECORD ; *
RETURN
*----------------------------------------------------------------------------

*** <region name= UPDATE.RECORD>
UPDATE.RECORD:
*** <desc> </desc>

    EbQaRecord = DE.Messaging.EbQueriesAnswers.ReadU(EbqaDetails<DE.Messaging.EbQaId>,Error, '') ;*Check reord is already existing by locking the record
    IF EbQaRecord THEN ;*if record is exist then update the incoming values
        IF EbqaDetails<DE.Messaging.EBQAStatus> THEN
            EbQaRecord<DE.Messaging.EbQueriesAnswers.EbQaStatus> = EbqaDetails<DE.Messaging.EBQAStatus>
        END
        IF EbqaDetails<DE.Messaging.EbQaProcessIndicator> THEN
            EbQaRecord<DE.Messaging.EbQueriesAnswers.EbQaProcessIndicator> = EbqaDetails<DE.Messaging.EbQaProcessIndicator>
        END
        IF EbqaDetails<DE.Messaging.EbQaErrorReason> THEN
            EbQaRecord<DE.Messaging.EbQueriesAnswers.EbQaErrorReason> = EbqaDetails<DE.Messaging.EbQaErrorReason>
        END
        DE.Messaging.EbQueriesAnswers.Write(EbqaDetails<DE.Messaging.EbQaId>, EbQaRecord)
    END ELSE
        ErrorDetails = Error ;*Returned Error
    END

RETURN
*** </region>

END


