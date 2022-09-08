* @ValidationCode : MjoxMjczNjMyNTkwOkNwMTI1MjoxNTY0NTc4MDMxNTYzOnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 18:30:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqSubmit
SUBROUTINE CONV.CHQ.TYPE.TRNS.G10.1.01(ID,YREC,FILE)
*-----------------------------------------------------------------------------
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Submit as ST_ChqSubmit and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*----------------------------------------------------------------------------------
    $INSERT I_EQUATE
    $INSERT I_COMMON

*
** new conversion routine to correct the file type of the
** CHQ.TYPE.TRNS concat file.
*
    ETEXT = ""
    F.TRANSACTION = ""
    FN.TRANSACTION = "F.TRANSACTION"
    CALL OPF(FN.TRANSACTION,F.TRANSACTION)
    SELECT.STATEMENT = 'SELECT ':FN.TRANSACTION:' WITH CHQ.TYPE EQ ':ID
    CALL EB.READLIST(SELECT.STATEMENT,
    ID.LIST,
    '',
    '',
    '')
    YREC = ID.LIST

RETURN

END
