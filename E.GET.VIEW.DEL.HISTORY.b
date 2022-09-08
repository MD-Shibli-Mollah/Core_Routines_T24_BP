* @ValidationCode : MjotNjA0Mjg4MjM0OkNwMTI1MjoxNjEyNTIxNzQzMzMzOmhlbWFuYXJheWFucjo3OjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMjEwMi4yMDIxMDEzMS0yMjEwOjE3NzoxMzI=
* @ValidationInfo : Timestamp         : 05 Feb 2021 16:12:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : hemanarayanr
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 132/177 (74.5%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202102.20210131-2210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>340</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.SystemTables
SUBROUTINE E.GET.VIEW.DEL.HISTORY(ENQ.DETAILS)
*---------------------------------------------------------------------------------------------------------------
* Program description:
*------------------------
* This is the part of core enquiry and it is called from Standard selection record NOFILE.VIEW.DELETE.HISTORY
* enquiry created to view a deleted record details from the $DEL file and the drill down enquiry will open the
* exact records.
*
*
* @author - kbalakrishnan@temenos.com
* @stereotype - SUBROUTINE
* @param - ENQ.DETAILS (mandatory) and (output)
* @package - EB-CORE
* @uses - ''
* @returns - $DEL record details for the respective applications
* @links - OPF(1)
*
*---------------------------------------------------------------------------------------
* MODIFICATION HISTORY:
*-----------------------
*
* 28/08/12 - Enhancement - 371776, Task - 452007
*            Deleted item history (SAMBA)
*            New generic enquiry to view the DEL records
*
* 02/09/16 - Task 1846535, Defect 1841501
*            Selection command is properly formed with quotes
*
* 10/08/18 - Task 2707065 / Defect 2261217
*            New field introduced to have the enquiry name appended in the recordid for UXPB
*
* 04/02/21 - Task 4212611 / Defect 4203020
*            Fix for Enquiry VIEW.DELETE.HISTORY is not displaying the records by giving value in the Selection field Date
*---------------------------------------------------------------------------------------
*** <region name= INSERT FILES>
*** <desc>Insert the files required </desc>
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON

*
*** </region>
*---------------------------------------------------------------------------
*** <region name= MAIN.PROCESS>
*** <desc>The actual flow </desc>
*

    GOSUB Initialise          ;* Initialise the variables
    GOSUB formSelection       ;*Form selection creteria based on the SELECTION criteria
    IF dontRunEnquiry THEN    ;* Go out from enquiry
        RETURN      ;* go out
    END

    GOSUB Process   ;* Create Enquiry

RETURN
*
*** </region>
*----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise the variables </desc>
Initialise:
*----------
* Initialise the variables

    enqValue =''
    actualDate = ''
    dontRunEnquiry=''         ;* DONT run enquiry further
    
    isUxpBrowser = ''
    CALL RP.getIsUXPBrowser(isUxpBrowser)      ;*Check if it is a UXP Request

RETURN

*** </region>

*------------------------------------------------------------------------------
*** <region name= Process>
*** <desc>Create the txn on a particluar day enquiry </desc>
Process:
*-----------

    GOSUB openFile  ;* Opens the file
    selList = theList

    LOOP
        REMOVE delRecId FROM selList SETTING recPos
    WHILE delRecId:recPos

        recStatus =''
        currNo = ''
        inputter = ''
        authoriser = ''
        dateTime=''
        companyId= ''
        includeRec = 0

        CALL F.READ(delApplicationName,delRecId,deletedRecord,fDelApplicationName,delErr)

        IF actualDate THEN    ;* if DATE value provided in selection criteria then go  with operand based selection
            BEGIN CASE

                CASE dateOperant EQ 'EQ'    ;* operand is equals
                    IF deletedRecord<V-5>[1,6] EQ actualDate THEN         ;* fetch only the record same date record
                        includeRec = 1
                    END
                CASE dateOperant EQ 'NE'    ;* operand is not equals
                    IF deletedRecord<V-5>[1,6] NE actualDate THEN         ;* fetch all the record with other than the date give in selection
                        includeRec = 1
                    END

                CASE dateOperant EQ 'LT'    ;* operand is less than
                    IF deletedRecord<V-5>[1,6] LT actualDate[1,6] THEN    ;* fetch all the record with lesser than the date give in selection
                        includeRec = 1
                    END

                CASE dateOperant EQ 'GT'    ;* operand is greater than
                    IF deletedRecord<V-5>[1,6] GT actualDate[1,6] THEN    ;* fetch all the record with greater than the date give in selection
                        includeRec = 1
                    END

                CASE dateOperant EQ 'LE'    ;* operand is less and equalsthan
                    IF deletedRecord<V-5>[1,6] LE actualDate[1,6] THEN    ;* fetch all the record with lesser than and equals the date give in selection
                        includeRec = 1
                    END
                CASE dateOperant EQ 'GE'    ;* operand is greater than and equals
                    IF deletedRecord<V-5>[1,6] GE actualDate[1,6] THEN    ;* fetch all the record with greater than and equals the date give in selection
                        includeRec = 1
                    END

                CASE OTHERWISE    ;* for other operands add all the records
                    includeRec = 1
            END CASE
        END ELSE
            includeRec = 1    ;* DATE not in selection criteria than include all the records
        END

        IF includeRec THEN    ;* include records to display
            recStatus  = deletedRecord<V-8>       ;*STATUS
            currNo     = deletedRecord<V-7>       ;*CURR.NO
            inputter   = deletedRecord<V-6>       ;*INPUTTER
            inputter   = inputter<1,1>  ;* Latest user details need to be displayed
            dateTime   = FIELD(delRecId,';',2)    ;* DATE.TIME from record id
            authoriser = deletedRecord<V-4>       ;*AUTHORISER
            companyId  = deletedRecord<V-3>       ;* COMPANY.CODE
            IF isUxpBrowser THEN
                delRecIdForDrill = delRecId:';VIEW.DELETE.HISTORY'      ;* Append the enquiry name so that on further drilldown , we can identify that it is from this enquiry
            END ELSE
                delRecIdForDrill = delRecId
            END
            ENQ.DETAILS<-1>=delRecId:'*':recStatus:'*':currNo:'*':inputter:'*':authoriser:'*':dateTime:'*':companyId:'*':delRecIdForDrill    ;* OUT VALUES

        END
    REPEAT

RETURN


*
*** </region>
*-------------------------------------------------------------------------------
*** <region name= openFile>
*** <desc>OPens the TV.TRANS.INDEX file </desc>
openFile:
*-----------
* Opens the file

    CALL GET.STANDARD.SELECTION.DETS( applicationName, recApplss )    ;* read SS record
    CALL FIELD.NAMES.TO.NUMBERS('AUDIT.DATE.TIME',recApplss,fieldPos,'','','','',notaField)         ;* get the last field name

    V=fieldPos

RETURN
*
*** </region>
*----------------------------------------------------------------------------------
*** <region name= selectOperand>
selectOperand:
*** <desc>support all the operands </desc>

    BEGIN CASE

        CASE operantval = "CT" OR operantval = "BW" OR operantval = "EW" OR operantval = "LK" ;* append ... and say actual operand is LIKE
            GOSUB appendWildCard
            operantval = "LIKE"   ;* select stmt should run with LIKE

        CASE operantval = "NC" OR operantval = "DNBW" OR operantval = "DNEW"  OR operantval = "UL"      ;* append ... and say actual operand is UNLIKE
            GOSUB appendWildCard  ;* BG_100015460 S E
            operantval = "UNLIKE" ;* select stmt should run with UNLIKE

        CASE operantval = "EQ"
            enqValue = DQUOTE(SQUOTE(enqValue):'...')       ;* APPEND ..., Since  audit DATE.TIME will have time also with it so we must separate date and append ... during selection
            operantval = 'LIKE'   ;* select stmt should run with LIKE

        CASE operantval = "NE"
            enqValue = DQUOTE(SQUOTE(enqValue):'...')         ;* APPEND ..., Since  audit DATE.TIME will have time also with it so we must separate date and append ... during selection
            operantval = 'UNLIKE' ;* select stmt should run with UNLIKE

    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= appendWildCard>
*** <desc>Change to data to append or prepend a wildcard</desc>

appendWildCard:


    BEGIN CASE

        CASE operantval = "LK" OR operantval = "UL"

            IF NOT(INDEX(enqValue,'...',1)) THEN      ;* already ... added then dont add during run time
                enqValue =  '...':SQUOTE(enqValue):'...'
            END ELSE
                IF enqValue[1,3] = '...' THEN     ;* Leading ...
                    UPREFIX = '...'         ;* So we can put it back
                    enqValue = enqValue[4,9999]         ;* And drop the ...
                END ELSE
                    UPREFIX = ''  ;* No leading ...
                END

                IF enqValue[3] = '...' THEN       ;* And trailing ...
                    USUFFIX = '...'
                    enqValue = enqValue[1,LEN(enqValue)-3]    ;* Drop trailing ...
                END ELSE
                    USUFFIX = ''  ;* No trailing
                END

                NEW.UD = ""       ;* Build a quoted UD in here
                LOOP DIDX = INDEX(enqValue,'...',1) WHILE DIDX        ;* Look for all ...s
                    NEW.UD := "'":enqValue[1,DIDX-1]:"'..." ;* Wrap the data in quotes and add the ...s
                    enqValue = enqValue[DIDX+3,999]     ;* Drop the ...s
                REPEAT
                IF enqValue <> "" THEN  ;* Something still there BG_100012145 S/E
                    NEW.UD := "'":enqValue:"'"    ;* Quote the last element
                END
                enqValue = UPREFIX: NEW.UD: USUFFIX         ;* Put back the leading and trailing ...s
            END

        CASE operantval = "CT" OR operantval = "NC"   ;* contains and not contains
* don't do anything if user has already put a wildcard in
            IF NOT(INDEX(enqValue,'...',1)) THEN      ;* already ... added then dont add during run time
                enqValue =  '...':SQUOTE(enqValue):'...'
            END

        CASE operantval = "BW" OR operantval = "DNBW"
            IF NOT(INDEX(enqValue,'...',1)) THEN      ;* already ... added then dont add during run time
                enqValue =  SQUOTE(enqValue):'...'    ;* add ... after the actual value
            END

        CASE operantval = "EW" OR operantval = "DNEW"
            IF NOT(INDEX(enqValue,'...',1)) THEN      ;* already ... added then dont add during run time
                enqValue =  '...':SQUOTE(enqValue)    ;* add ... before the actual value
            END

    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= formSelection>
formSelection:
*** <desc>Form selection creteria based on the SELECTION criteria </desc>

    LOCATE "APPLICATION.NAME" IN ENQ.SELECTION<2,1> SETTING appPos THEN         ;* check APPLICATION.NAME available in SELECTION CRITERIA

        applicationName = ENQ.SELECTION<4,appPos> ;* Get the input from the enq selection common variable

        delApplicationName= 'F.':applicationName:'$DEL'     ;*$DEL file

        delApplicationName = delApplicationName:FM:'NO.FATAL.ERROR'

        CALL OPF(delApplicationName,fDelApplicationName)    ;* open a $del file

        IF ETEXT THEN         ;* IF ETEXT finds then dont run the enquiry
            dontRunEnquiry = 1          ;* FILE not available, go out
            RETURN  ;* dont continue
        END

        selCmd= 'SELECT ':delApplicationName      ;* SELECT the records from $del file
    END

    LOCATE "DATE" IN ENQ.SELECTION<2,1> SETTING DATE.POS THEN         ;* check DATE available in SELECTION CRITERIA
        actualDate = ENQ.SELECTION<4,DATE.POS>    ;* Get the Date
        operantval= ENQ.SELECTION<3,DATE.POS>     ;* Get operand
        dateOperant=operantval          ;* store tha actual selection date it
        actualDate=actualDate[3,6]      ;* get date as like audit fields format

        BEGIN CASE
            CASE dateOperant MATCHES 'LT':VM:'GE'     ;* Append '0000' with date for the operand 'Greater than and equals' and 'Lesser than'
                actualDate=actualDate:'0000'
            CASE dateOperant MATCHES 'LE':VM:'GT'     ;* Append '9999' with date for the operand 'Greater than' or 'Lesser than and equals' date
                actualDate=actualDate:'9999'
        END CASE

        enqValue=actualDate   ;* assign to get with wildcard char
        GOSUB selectOperand   ;*support all the operands
        selCmd = selCmd: ' WITH DATE.TIME ':operantval:' ':enqValue
    END


    LOCATE "TRANSACTION.REF" IN ENQ.SELECTION<2,1> SETTING TRANS.POS THEN
        enqValue = ''
        operantval = ''
        transRef = ENQ.SELECTION<4,TRANS.POS>
        operantval= ENQ.SELECTION<3,TRANS.POS>
        enqValue=transRef
        GOSUB selectOperand   ;*support all the operands
        transRef = DQUOTE(enqValue)
        selCmd = selCmd:' AND WITH @ID ':operantval:' ':transRef
    END

    CALL EB.READLIST(selCmd,theList,'',NO.OF.ITEMS,'')

RETURN
*** </region>

END
