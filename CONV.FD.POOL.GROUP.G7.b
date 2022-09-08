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

* Version 1 16/09/96  GLOBUS Release No. G7.1.01 03/10/96
*-----------------------------------------------------------------------------
* <Rating>199</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FD.Pooling
      SUBROUTINE CONV.FD.POOL.GROUP.G7(YID, YREC, YFILE)

* This routine sets the FURTHER.POOLING field to YES for fixed groups
* which are either OPEN or APPROVED and sets it to NO for NOTICE groups.

      IF YREC<3> > 1000 THEN             ; * Fixed term

         IF YREC<6> = 'OPEN' OR YREC<6> = 'APPROVED' THEN YREC<5> = 'YES'
            ELSE YREC<5> = 'NO'

      END ELSE

         YREC<5> = 'NO'

      END

* Done.

      RETURN

   END
