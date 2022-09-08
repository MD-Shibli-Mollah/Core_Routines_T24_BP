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
* <Rating>-8</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AI.ModelBank
    SUBROUTINE MB.GET.SYS.DATE

**************************************************************
* To populate the system date
**************************************************************
* 13/12/2010 - New Development
* Purpose    -  The routine Popoulates the system date as Start date and
*                +20 years for End date.
* Developed By - Abinanthan K B
*
**************************************************************
* Modification History:
*
* 18/05/15 - Enhancement-1326996/Task-1327012
*			 Incorporation of AI components
*-----------------------------------------------------------------------------

    $USING EB.SystemTables

    Y.DATE = DATE()
    Y.DATEC = OCONV(Y.DATE,'Dc')
    Y.DATEC = Y.DATEC[7,4]:Y.DATEC[1,2]:Y.DATEC[4,2]
    EB.SystemTables.setRNew(EB.ARC.ExternalUser.XuStartDate, Y.DATEC)
    Y.YEAR = Y.DATEC[1,4] + 20
    Y.DATEE = Y.YEAR:Y.DATEC[5,2]:Y.DATEC[7,2]
    EB.SystemTables.setRNew(EB.ARC.ExternalUser.XuEndDate, Y.DATEE)
    RETURN
    END
