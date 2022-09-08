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
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
*____________________________________________________________________________________
*
    $PACKAGE LI.Config
    SUBROUTINE CONV.LIMIT.SUB.ALLOC.200603(Y.LSA.ID,R.LSA,F.LSA)
*____________________________________________________________________________________
*
* This is routine will convert the existing LIMIT.SUB.ALLOC records to include
*
* 24/01/06 - EN_10002785
*            New conversion routine
*
*____________________________________________________________________________________
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*____________________________________________________________________________________
*
*---New fields added in the LIMIT.SUB.ALLOC.
*---Here IDX is 7
    R.LSA<11> = ''  ;* 11th field RESERVED1
    R.LSA<10> = ''  ;* 10th field RESERVED2
    R.LSA<9> = ''   ;* 9th field RESERVED3
    R.LSA<8> = 'Y'  ;* 8th field AUTO.RESTORE.ALLOC

    RETURN
END
