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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Reports
    SUBROUTINE E.DE.CUS.CONV
*
* E.DE.CUS.CONV - Pads out a customer number entered by the user with
* leading zeros.  This is because the user would enter, for example,
* 123456, but the key is held on F.DE.O.HIST.CUS or F.DE.I.HIST.CUS as
* DE0010001.0000000000123456
*
* 06/01/00 - GB0000017
*            Change the order of the inserts so I_ENQUIRY.COMMON
*            comes afetr I_COMMON
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
    $USING EB.Reports
    $USING DE.Reports
*
    tmp.O.DATA = EB.Reports.getOData()
    EB.Reports.setOData(STR('0',16-LEN(tmp.O.DATA)):EB.Reports.getOData())
*
    RETURN
    END
