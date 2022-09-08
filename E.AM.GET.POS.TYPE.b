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

* Version 1 31/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Modelling
    SUBROUTINE E.AM.GET.POS.TYPE
*========================================================================
* Called in 'conversion' of enquiry AM.GRID and AM.GRID.MASTER to
* find the position types like "POSITION" or "POSITION + SCENARIO"...
*     Author : CMS
*     Date   : 01/06/2001
*========================================================================
*
* 28/02/2002 - GLOBUS_EN_10000479 - Main change for G12.2.00
*              Position code include session number.
*
* 23/05/2012 - Enhancement_355641 Task_396337
*              Rebalancing of a Parent portfolio.
*
* 01/10/13 - Defect-749002 / Task-793210
*            COMO Errors of "Non-numeric value -- ZERO USED"/"Invalid or uninitialised variable -- NULL USED"
*
* 01/03/16 - 1649309
*            Incoporation of Components
*========================================================================

    $USING AM.Modelling
    $USING EB.Reports

*========================================================================
* Main controlling section
*========================================================================

    tmp.O.DATA = EB.Reports.getOData()
    POS.CODE = FIELD(tmp.O.DATA,'*',1)
    TYPE.CODE = FIELD(tmp.O.DATA,'*',2)
    T.TYPES = ""
    BEGIN CASE
        CASE TYPE.CODE EQ 'SAM'
            REC.POS = ''
            REC.POS = AM.Modelling.Pos.Read(POS.CODE, ERR)
            T.TYPES = REC.POS<AM.Modelling.Pos.PosType>

        CASE TYPE.CODE EQ 'GRP'
            REC.GRP = ''
            REC.GRP = AM.Modelling.GrpPos.Read(POS.CODE, ERR)
            T.TYPES = REC.GRP<AM.Modelling.Pos.PosType>
    END CASE

    DISP.STR = '( ':T.TYPES<1,1>
    FOR I = 2 TO DCOUNT(T.TYPES<1>,@VM)
        FINDSTR T.TYPES<1,I> IN DISP.STR SETTING POS ELSE
            DISP.STR := ' + ':T.TYPES<1,I>
        END
    NEXT I
    DISP.STR := ' )'

    EB.Reports.setOData(DISP.STR)

    RETURN
    END
