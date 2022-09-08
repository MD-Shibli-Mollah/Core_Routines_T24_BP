* @ValidationCode : MjotNTkzOTY0NDIyOkNwMTI1MjoxNTYyOTI4NzgxMjAzOnZoaW5kdWphOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDYxMi0wMzIxOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Jul 2019 16:23:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vhinduja
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE ST.CustomerActivity
SUBROUTINE CZ.SAMPLE.START.END.DATE.REF.API(Application, ContractId, ContractRec, Returndate, spare1, spare2)
*-----------------------------------------------------------------------------
* API to return the creation date/End Date for non ecb applications
**************************************************************************
*@Incoming Arguments
********************
*Application    - Application name
*ContractId     - ID of the contract
*ContractRec    - Record Details
*
**************************************************************************
*@Incoming/Outgoing Arguments
**************************************************************************
*Returndate     - Incoming Value - will be having the below values
*                     START - if the API is called for START.DATE.REF
*                     END   - if this API is called for END.DATE.REF
*
*               - Outgoing value - wil be the appropriate date for the call.
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 28/05/19 - Enhancement 3017170 -  / Task -3017179
*            Sample API to return date for collateral application
*
*-----------------------------------------------------------------------------
    $USING EB.API
*-----------------------------------------------------------------------------

    incomingValue = Returndate
    Returndate = ''

    IF incomingValue EQ 'START' THEN
        fname = "VALUE.DATE"
        GOSUB GetFieldPosition
        Returndate = ContractRec<fname> ;*Creation Date
    END ELSE
        fname = "EXPIRY.DATE"
        GOSUB GetFieldPosition
        Returndate = ContractRec<fname> ;*End Date
    END

RETURN
*-----------------------------------------------------------------------------
*** <region name= GetFieldPosition>
GetFieldPosition:
      
    SSRec = ""
    SSErr = ""
    EB.API.GetApplField(Application, fname, SSRec,SSErr) ;*Get the field position from SS record

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
