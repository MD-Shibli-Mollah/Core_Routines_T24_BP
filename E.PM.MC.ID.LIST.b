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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.MC.ID.LIST(ID.LIST)
*-----------------------------------------------------------------------------
    $USING EB.Reports

***********************************************************************
*
* 06/05/96	GB9600737
*
*		Set up a list of PM.DLY.POSN.CLASS ids with '*'MNE
*		suffix for multicompany consolidation on drill downs
*
* 26/10/15 - EN_1226121 / Task 1511358
*	      	 Routine incorporated
*
***********************************************************************
    LOCATE "ID2" IN EB.Reports.getDFields()<1> SETTING DPOS THEN
    ID.LIST = EB.Reports.getDRangeAndValue()<DPOS>
    CONVERT @SM TO @FM IN ID.LIST
    END ELSE
    ID.LIST = ""
    END
    RETURN
    END
