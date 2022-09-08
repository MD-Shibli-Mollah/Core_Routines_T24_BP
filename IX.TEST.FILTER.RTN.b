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
* <Rating>-42</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IX.API
    SUBROUTINE IX.TEST.FILTER.RTN(AccountId,EntryRecord,FilterFlag, Reserved.Arg)
*-----------------------------------------------------------------------------
*
* Test routine to check whether an entry is to be included in the CAMT message
* or not. This API can be attached in FILTER.RTN field of AC.STMT.PARAMETER
* record. The routine IX.GET.STMT.ENTRIES will execute the API by passing the entry
* record as one of the argument. Based on the flag returned, the routine will decide
* whether or not to include the entry in the CAMT message
*
** PARAMETERS:
*
** IN -  AccountId          :- Id of the Account
**       EntryRecord        :- Entry record which is to be checked whether to be filtered or not
*
** OUT - FilterFlag         :- Flag that indicates whether the entry is to be included in
**						       CAMT message or not
**       Reserved.Arg       :- Reserved Argument
*
*** <region name= MODIFICATION HISTORY>
*** <desc>Modification History</desc>
*------------------------------------------------------------------------
* Modification History :
*
* 11/11/2014 - EN_1175323 / Task 1155988
*              Test API to decide whether an entry is to be filtered from
*              the CAMT message or not
*
*------------------------------------------------------------------------
*** </region>
    $USING IX.API
    $USING AC.EntryCreation

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

*---------------------------------------------------------------------------------
INITIALISE:
***********
*Initialise the required variables

    IF NOT(EntryRecord) THEN     ;* Dont proceed if entry record is not passed
        RETURN
    END

    SYS.ID = ''
    FilterFlag = ''

* Assign the required values

    SYS.ID = EntryRecord<AC.EntryCreation.StmtEntry.SteSystemId>

    RETURN
*---------------------------------------------------------------------------------
PROCESS:
********
*Check whether the entry should be filtered or not

    IF SYS.ID NE 'FT' THEN        ;* Filter the entries other than for FT
        FilterFlag = 1            ;* Set the filter flag
    END

    RETURN
*----------------------------------------------------------------------------------
    END
