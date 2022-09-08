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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE V.MB.CUST.PROCESS
*-------------------------------------------------------------------------
*
* A routine which takes the ID of the CUSTOMER and updates the PW.PROCESS record CUSTOMER field with this number.
*
*-------------------------------------------------------------------------
* 25 October 2008 - woody - initial version
* 12 April 2010 - Abinanthan K B - Replaced the common PW$ORIGINATE.PROCESS to PW$ACTIVITY.TXN.ID
*-------------------------------------------------------------------------

    $USING PW.Foundation
    $USING ST.Customer
    $USING EB.DataAccess
    $USING EB.SystemTables

*
    IF PW.Foundation.getActivityTxnId() = "" THEN
        EB.SystemTables.setRNew(ST.Customer.Customer.EbCusPastimes, "PW$ACTIVITY.TXN.ID IS null")
    END ELSE
        GOSUB INITIALISE
        GOSUB PROCESS
    END
*
    RETURN
*
**************************************************************************
INITIALISE:
**************************************************************************
*

    tmp.F.PW.PROCESS = ''
    tmp.FN.PW.PROCESS = "F.PW.PROCESS"
    EB.DataAccess.Opf(tmp.FN.PW.PROCESS,tmp.F.PW.PROCESS)
    PW.Foundation.setFnPwProcess(tmp.FN.PW.PROCESS)
    PW.Foundation.setFPwProcess(tmp.F.PW.PROCESS)
*

    tmp.F.PW.ACTIVITY.TXN = ''
    tmp.FN.PW.ACTIVITY.TXN = "F.PW.ACTIVITY.TXN"
    EB.DataAccess.Opf(tmp.FN.PW.ACTIVITY.TXN, tmp.F.PW.ACTIVITY.TXN)
    PW.Foundation.setFnPwActivityTxn(tmp.FN.PW.ACTIVITY.TXN)
    PW.Foundation.setFPwActivityTxn(tmp.F.PW.ACTIVITY.TXN)
*
    RETURN
*
**************************************************************************
PROCESS:
**************************************************************************
*
    R.PW.ACTIVITY.TXN = '' ; ERR.PW.ACTIVITY.TXN = ''
    PW$ACTIVITY.TXN.ID.VAL = PW.Foundation.getActivityTxnId()
    R.PW.ACTIVITY.TXN = PW.Foundation.ActivityTxn.Read(PW$ACTIVITY.TXN.ID.VAL, ERR.PW.ACTIVITY.TXN)
    IF R.PW.ACTIVITY.TXN <> "" THEN
        Y.PW.ORG.PROCESS = R.PW.ACTIVITY.TXN<PW.Foundation.ActivityTxn.ActTxnOriginateProcess>
        R.PROCESS = ''
        R.PROCESS = PW.Foundation.Process.Read(Y.PW.ORG.PROCESS, "E")
        IF R.PROCESS <> "" THEN
            R.PROCESS<PW.Foundation.Process.ProcCustomer> = EB.SystemTables.getIdNew()
            PW.Foundation.ProcessWrite(Y.PW.ORG.PROCESS, R.PROCESS,'')
        END
    END
    RETURN
*
    END
