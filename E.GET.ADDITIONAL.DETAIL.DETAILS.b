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
* <Rating>-63</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.GET.ADDITIONAL.DETAIL.DETAILS(STMT.ENTRY.KEY,IN.FIELD.NAME,ADD.DETAILS,READ.ERR)
*-----------------------------------------------------------------------------
*
* 	This is the routine to fetch the additional details present in the STMT.ENTRY.
*
* 	The Additional details fetched are based on the input that is provided.
*
* 	If only the statement entry Id is passed it will fetch in the complete detail
*	i.e., The Additional Field Name List and the additional field value.
* 	If the specific field name is also passed with the Statement Entry Id,
*	then only the values associated will be fetched.
*
* 	The input parameters required are the following
*
*    STMT.ENTRY.KEY – The Statement Entry ID for which the additional details are required.
*    				 This is a mandatory field.
* 	 IN.FIELD.NAME – The field name for which the additional information is sought.
* 					 This is an Optional Field
*
* 	The Output Parameters are the following:
*
*	ADD.DETAILS 	– Contains the information related to input field name if passed
*                	  or the complete list of additional field name present for the
*                 	  statement Entry Id passed.
*	ADD.DETAILS<1> 	– Contains the ADDITIONAL.FIELD.NAME list
*	ADD.DETAILS<2> 	– Contains the ADDITIONAL.FIELD.VALUE list
*	READ.ERR 		– If there is no statement entry for the passed information then return error.
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 02/03/15 - Enhancement 1214524 / Task 1256946
*            A new API to fetch additional details present in the STMT.ENTRY
*
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING AC.EntryCreation
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

INITIALISE:
*-----------------------------------------------------------------------------
** To open the files and initialise the variables
** STMT.ENTRY files
*-----------------------------------------------------------------------------

    R.STMT.ENTRY = ""
    ADD.DETAILS = ""
    READ.ERR = ""

    RETURN

PROCESS:
*-----------------------------------------------------------------------------
* Check is done whether statement entry is passed, if yes then read that from the Statement Entry File,
* otherwise pass an error message that no data is input, mandatory input is missing.
* If Statement entry ID is passed then the record is read from the Statement Entry File,
* and if is is invalid READ.ERR is passed back.
*-----------------------------------------------------------------------------

    IF STMT.ENTRY.KEY = "" THEN
        EB.SystemTables.setEtext("AC-STMT.ENTRY.ID.MAND")
        RETURN
    END


    R.STMT.ENTRY = AC.EntryCreation.StmtEntry.Read(STMT.ENTRY.KEY, READ.ERR)
* Before incorporation : CALL F.READ(tmp.FN.STMT.ENTRY,STMT.ENTRY.KEY,R.STMT.ENTRY,tmp.F.STMT.ENTRY,READ.ERR)

    IF NOT(READ.ERR) THEN
        GOSUB FETCH.ADDITIONAL.DETAILS
    END

    RETURN

FETCH.ADDITIONAL.DETAILS:
*-----------------------------------------------------------------------------
* This is to fetch the additional details based on whether the Field Name is populated or not.
* If Valid Statement ID, then after the record is read, and the check whether
* the Field Name is populated or not is done.
* If field name is populated then pass on the values specific to that of the field in additional details.
* If no field name is specified, pass on the complete information for the Additional Field name and field value.
*-----------------------------------------------------------------------------

    IF IN.FIELD.NAME NE "" THEN

        LOCATE IN.FIELD.NAME IN R.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteAddDetailName,1> SETTING POS THEN

        ADD.DETAILS<1> = IN.FIELD.NAME
        ADD.DETAILS<2> = R.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteAddDetailValue,POS>

    END ELSE

        EB.SystemTables.setEtext("AC-INVALID.ADDL.FLD.NAME")

    END

    END ELSE

    ADD.DETAILS<1> = R.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteAddDetailName>
    ADD.DETAILS<2> = R.STMT.ENTRY<AC.EntryCreation.StmtEntry.SteAddDetailValue>

    END

    RETURN
*-----------------------------------------------------------------------------

    END

