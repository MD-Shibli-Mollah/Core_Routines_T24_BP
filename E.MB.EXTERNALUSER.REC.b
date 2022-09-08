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
* <Rating>-33</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AI.ModelBank
    SUBROUTINE E.MB.EXTERNALUSER.REC
*-------------------------------------------------------------------------------
* Routine will map the customer id , customer name and Start Date to EB.EXTERNAL.USER record
*------------------------------------------------------------------------------
* Modification History:
* ------------------------------------------------------------------------
*
* 18/05/15 - Enhancement-1326996/Task-1399903
*			 Incorporation of AI components
*-----------------------------------------------------------------------------
*** <region name= Insert>
*** <desc>Insert Region </desc>

    $USING EB.ARC
    $USING EB.SystemTables
    $USING PW.API
    $USING PW.Foundation
    $USING ST.Customer

*** </region>

    GOSUB INITIALISE
    GOSUB MAP.EXTERNAL.USER.RECORD

    RETURN

*** <region name= INITIALISE>
INITIALISE:
****************************

    CUST.ID=EB.SystemTables.getIdNew()

    EB.SystemTables.setRNew(EB.ARC.ExternalUser.XuCustomer, CUST.ID)

    RETURN
*** </region>

*** <region name= MAP.EXTERNAL.USER.RECORD>

MAP.EXTERNAL.USER.RECORD:
*******************************************


    CUST.REC = ST.Customer.Customer.Read(CUST.ID, REC.ERROR)


    EB.SystemTables.setRNew(EB.ARC.ExternalUser.XuName, CUST.REC<ST.Customer.Customer.EbCusShortName>)

    IF PW.Foundation.getActivityTxnId() THEN

        PW.PROCESS.ID = ''    ;* pw process id
        PROCESS.TXN.ID = PW.Foundation.getActivityTxnId()       ;* common variable contains the PW.ACTIVITY.TXN id
        PW.API.FindProcess(PROCESS.TXN.ID,PW.PROCESS.ID)  ;* get the PW.PROCESS name

        ER = ''
        R.PW.PROCESS = ''

        R.PW.PROCESS = PW.Foundation.Process.Read(PW.PROCESS.ID, ER)   ;* try to read the PW.PROCESS rec

        EB.SystemTables.setRNew(EB.ARC.ExternalUser.XuStartDate, R.PW.PROCESS<PW.Foundation.Process.ProcStartDate>);* Get the Start Date

    END
    RETURN

*** </region>
    END
