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

* Version 1 01/11/99  GLOBUS Release No. G13.1.01 25/11/02
*-----------------------------------------------------------------------------
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.CompanyCreation
      SUBROUTINE CONV.COMPANY.G14.00(YID, YREC, YFILE)
*------------------------------------------------------------------------
* This routine sets the CO.BATCH.STATUS field to NULL. This field used to
* be a reserved field but contained data = RUN
*------------------------------------------------------------------------
*
$INSERT I_F.COMPANY
*
      IF YREC<EB.COM.LOCAL.COUNTRY> THEN
         IF YREC<EB.COM.OFFICIAL.HOLIDAY> = "" THEN
            YREC<EB.COM.OFFICIAL.HOLIDAY> = YREC<EB.COM.LOCAL.COUNTRY>:"00"
         END
         IF YREC<EB.COM.BRANCH.HOLIDAY> = "" THEN
            YREC<EB.COM.BRANCH.HOLIDAY> = YREC<EB.COM.LOCAL.COUNTRY>:"00"
         END
         IF YREC<EB.COM.BATCH.HOLIDAY> = "" THEN
            YREC<EB.COM.BATCH.HOLIDAY> = YREC<EB.COM.LOCAL.COUNTRY>:"00"
         END
      END ELSE
         IF YREC<EB.COM.LOCAL.REGION> THEN
            IF YREC<EB.COM.OFFICIAL.HOLIDAY> = "" THEN
               YREC<EB.COM.OFFICIAL.HOLIDAY> = YREC<EB.COM.LOCAL.REGION>
            END
            IF YREC<EB.COM.BRANCH.HOLIDAY> = "" THEN
               YREC<EB.COM.BRANCH.HOLIDAY> = YREC<EB.COM.LOCAL.REGION>
            END
            IF YREC<EB.COM.BATCH.HOLIDAY> = "" THEN
               YREC<EB.COM.BATCH.HOLIDAY> = YREC<EB.COM.LOCAL.REGION>
            END
         END
      END
*
      RETURN
   END
