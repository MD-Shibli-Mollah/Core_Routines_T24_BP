* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-47</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IX.API
    SUBROUTINE IX.TEST.CONSOLIDATE.RTN(AccountId,EntryRecord,ConsolidationFlag,ConsolidationKey , Reserved.consolidation)
*-----------------------------------------------------------------------------
*
* Test routine to check whether an entry is to be consolidated in the CAMT message
* or not. This API can be attached in CONSOLIDATE.RTN field of AC.STMT.PARAMETER
* record. The routine IX.GET.STMT.ENTRIES will execute the API by passing the entry
* record as one of the argument. This routine will check whether the entry is to
* consolidated based on certain conditions (in this API the condition is set as
* the FT debit entries should be consoldiated) and the consolidation flag will
* be set based on that. If the consolidation flag is set, then the calling routine
* will check for the consolidation key, if the consolidation key is not returned then
* default consolidation key will be formed and the entry will be consolidated
*
** PARAMETERS:
*
** IN -  AccountId          :- Id of the Account
**       EntryRecord        :- Entry record which is to be checked for consolidation
*
** OUT - ConsolidationFlag  :- Flag that indicates whether the entry is to be consolidated or not
**       ConsolidationKey   :- Consolidation key to be returned
**       Reserved.Arg       :- Reserved Argument
*
*** <region name= MODIFICATION HISTORY>
*** <desc>Modification History</desc>
*------------------------------------------------------------------------
* Modification History :
*
* 11/11/2014 - EN_1175323 / Task 1155988
*              Test API to decide whether an entry is to be consolidated
*              or not
*
*------------------------------------------------------------------------

    $USING IX.API
    $USING AC.EntryCreation
*
    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

*---------------------------------------------------------------------------------
INITIALISE:
***********
*Initialise the required variables

    IF NOT(EntryRecord) THEN
        RETURN
    END

    ConsolidationFlag = ''
    SYS.ID = ''
    TOT.AMT = ''
* Asssign the values
    SYS.ID = EntryRecord<AC.EntryCreation.StmtEntry.SteSystemId>        ;* System id
    TOT.AMT = EntryRecord<AC.EntryCreation.StmtEntry.SteAmountLcy>      ;* Transaction amount


    RETURN
*---------------------------------------------------------------------------------
PROCESS:
********
*Check whether the entry should be consolidated or not

    IF SYS.ID EQ 'FT' AND TOT.AMT LT 0 THEN              ;* Consolidate FT debit entries
        ConsolidationFlag = 1 ;* Set the Consolidation flag
    END

    RETURN
*----------------------------------------------------------------------------------

    END
