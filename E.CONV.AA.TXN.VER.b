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
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
	$PACKAGE AA.ModelBank
    SUBROUTINE E.CONV.AA.TXN.VER
*-----------------------------------------------------------------------------
*
* New enquiry routine, whcih is used to read EB.SYSTEM.ID to get APPLICATION
* field value. This routine is to avoid the drilldown problem
*
* Modification History :
*
* 28/05/15 - Task   : 1359612
*            Defect : 1354951
*            Conversion routine attached to the enquiry AA.DETAILS.ACTIVITY.LOG.FIN
*            Retuning Corresponding Version to be opened
*
* 05/08/15 - Defect : 1425464 / task : 1429398
*			 the system throws the error ‘TOO MANY MNEMONIC CHAR’ and from Activity log for CHEQUE.COLLECTION
*
*-----------------------------------------------------------------------------
*
    $USING EB.Reports
    $USING AA.ModelBank
*
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-------

    Y.SYSTEM.ID     = ''
    TXN.CONTRACT.ID = ''
    OUT.O.DATA      = ''

    Y.SYSTEM.ID     = FIELD(EB.Reports.getOData(),":",1)
    TXN.CONTRACT.ID = FIELD(EB.Reports.getOData(),":",2)
    OUT.O.DATA = ""
    AA.ModelBank.GetExternalApplication(Y.SYSTEM.ID,TXN.CONTRACT.ID,OUT.O.DATA)
    EB.Reports.setOData(OUT.O.DATA)

    RETURN
*-----------------------------------------------------------------------------
    END
