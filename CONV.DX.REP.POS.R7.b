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
    $PACKAGE DX.Position
SUBROUTINE CONV.DX.REP.POS.R7(DX.REP.POS.ID,R.DX.REP.POS,FN.DX.REP.POSITION)
*--------------------------------------------*
*
* 31/05/2006 - CI10041507
*
*      Updation of CO.TYPE field in the DX.REP.POSITION file.
*
*--------------------------------------------*

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DX.CLOSEOUT


GOSUB INITIALISATION
GOSUB PROCESS.TRANSACTIONS

RETURN
*-------------*
INITIALISATION:
*-------------*

 DX.RP.TX.CO.TYPE = 33
 DX.RP.TX.CO.ID  = 28
 DX.RP.TRANSACTION.IDS = 29

FN.DX.CLOSEOUT = 'F.DX.CLOSEOUT'
F.DX.CLOSEOUT  = ''
CALL OPF(FN.DX.CLOSEOUT,F.DX.CLOSEOUT)

RETURN

*------------------*
PROCESS.TRANSACTIONS:
*------------------*

NO.OF.TRANS = DCOUNT(R.DX.REP.POS<DX.RP.TRANSACTION.IDS>,VM)
FOR THIS.TRANS = 1 TO NO.OF.TRANS
    NO.OF.CO = DCOUNT(R.DX.REP.POS<DX.RP.TX.CO.ID,THIS.TRANS>,SM)

    FOR THIS.CO = 1 TO NO.OF.CO
       THIS.CO.ID = R.DX.REP.POS<DX.RP.TX.CO.ID,THIS.TRANS,THIS.CO>
       GOSUB GET.CLOSEOUT.TYPE
       R.DX.REP.POS<DX.RP.TX.CO.TYPE,THIS.TRANS,THIS.CO> = CO.TYPE
    NEXT THIS.CO

NEXT THIS.TRANS
RETURN

*-------------------*
GET.CLOSEOUT.TYPE:
*-------------------*
CALL F.READ(FN.DX.CLOSEOUT,THIS.CO.ID,R.DX.CLOSEOUT,F.DX.CLOSEOUT,DX.CO.ERR)
CO.TYPE = R.DX.CLOSEOUT<DX.CO.TYPE>
RETURN
 
END
