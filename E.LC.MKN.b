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

* Version 1 24/08/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.ModelBank

    SUBROUTINE E.LC.MKN

*****************************************************************
*MODIFICATION.HISTORY
*****************************************************************
*
* 09/12/14 - Task : 1116645 / Enhancement : 990544
* 			 LC Componentization and Incorporation
*
*****************************************************************************************
    $USING EB.Reports
    $USING LC.ModelBank

    IF EB.Reports.getOData() MATCHES '2A' THEN
        EB.Reports.setOData("")
    END
    RETURN
    END
