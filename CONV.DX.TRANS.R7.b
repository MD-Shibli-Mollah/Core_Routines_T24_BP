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
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Trade
SUBROUTINE CONV.DX.TRANS.R7(DX.TRANS.ID,R.DX.TRANSACTION,FN.DX.TRANSACTION)
*---------------------------------------------*
*
* 31/05/2006 - CI10041507
*
*               Conversion routine for DX.TRANSACTION record to update
*              the type of closeout.
*
*---------------------------------------------*

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DX.CLOSEOUT

GOSUB INITIALISATION
GOSUB PROCESS.TRANSACTION

RETURN

*---------------*
INITIALISATION:
*---------------*

DX.TX.TRASETTNO = 50
DX.TX.CO.TYPE = 54

FN.DX.CLOSEOUT = 'F.DX.CLOSEOUT'
F.DX.CLOSEOUT  = ''
CALL OPF(FN.DX.CLOSEOUT,F.DX.CLOSEOUT)

RETURN

*----------------*
PROCESS.TRANSACTION:
*----------------*

NO.OF.CLOSEOUTS = DCOUNT(R.DX.TRANSACTION<DX.TX.TRASETTNO>,VM)
FOR THIS.CO = 1 TO NO.OF.CLOSEOUTS
    THIS.CO.ID = R.DX.TRANSACTION<DX.TX.TRASETTNO,THIS.CO>
    GOSUB GET.CLOSEOUT.RECORD
    R.DX.TRANSACTION<DX.TX.CO.TYPE,THIS.CO> = CO.TYPE
NEXT THIS.CO
RETURN

*---------------*
GET.CLOSEOUT.RECORD:
*---------------*
   CALL F.READ(FN.DX.CLOSEOUT,THIS.CO.ID,R.DX.CLOSEOUT,F.DX.CLOSEOUT,DX.CO.ERR)
   CO.TYPE = R.DX.CLOSEOUT<DX.CO.TYPE>
   RETURN

END
