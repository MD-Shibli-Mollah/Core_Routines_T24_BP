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

* Version n dd/mm/yy  GLOBUS Release No. R13 08/03/12
*-------------------------------------------------------------------------
* <Rating>-3</Rating>
*-------------------------------------------------------------------------
    $PACKAGE LC.Contract
    SUBROUTINE CONV.LETTER.OF.CREDIT.201402(LC.ID,R.LC.RECORD,YFILE)
*** <region name= Modifications>
*** <desc> </desc>
*
* Modifications
*
* 09/09/13 - Enhancement 589311 / Task : 738210
*            New field COMM.PARTY.CHG has been introduced
*
*** </region>
*-------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU TF.LC.COMM.CLAIMED TO 274
    EQU TF.LC.COMM.PARTY.CHG TO 284


*** </region>
*---------------------------------------------------------------------------
*** <region name= Populate fields>
*** <desc>Populate the fields during conversion </desc>

    IF R.LC.RECORD<TF.LC.COMM.CLAIMED> EQ 'YES' THEN
        R.LC.RECORD<TF.LC.COMM.PARTY.CHG> = 'O'   ;*Populating comm party charged as Opener if commission claimed field is set as Yes for the existing contract.
    END

    RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------
END
