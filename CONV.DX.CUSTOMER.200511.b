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

*
*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Customer
      SUBROUTINE CONV.DX.CUSTOMER.200511(DX.CUSTOMER.ID,R.DX.CUSTOMER,FN.DX.CUSTOMER)
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*-----------------------------------------------------------------------------
* Modification History:
*
* 02/05/06 - CI_10040860
*          - FATAL ERROR IN (I_IO.ROUTINES)
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

* Lines Deleted - CI_10040860 S/E

         GOSUB S100.INITIALISATION

         GOSUB S300.CONVERSION.PROCESSING


      RETURN

*-----------------------------------------------------------------------------
S100.INITIALISATION:

* Set field numbers to positions manually, instead of using $INSERT

      FLD.DOCS.REQUIRED = 20
      FLD.DOCS.SENT = 21
      FLD.DOCS.RECEIVED = 22
      FLD.DOCS.SIGNED = 23
      FLD.DOCS.FREQUENCY = 24

* Line Deleted - CI_10040860 S/E

      RETURN

*-----------------------------------------------------------------------------
* Line Deleted - CI_10040860 S/E
*-----------------------------------------------------------------------------
S300.CONVERSION.PROCESSING:

* Clear fields out

      FOR FLD.TO.CLEAR = FLD.DOCS.REQUIRED TO FLD.DOCS.FREQUENCY
         R.DX.CUSTOMER<FLD.TO.CLEAR> = ''
      NEXT FLD.TO.CLEAR

      RETURN

*-----------------------------------------------------------------------------
   END
