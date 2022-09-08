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
      $PACKAGE RE.Consolidation
      SUBROUTINE CONV.RE.CONSOL.PRFT.WRK.200507
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*-----------------------------------------------------------------------------
* Modification History:
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE


***   Main processing   ***
*     ---------------     *

      SAVE.ID.COMPANY = ID.COMPANY
*
* Loop through each company
*
      COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
      COMPANY.LIST = ''
      CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')

      LOOP
         REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
      WHILE K.COMPANY:COMP.MARK

         IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
         END
*
* Check whether product is installed
*

         GOSUB INITIALISE

         GOSUB CLEAR.RE.CONSOL.PRFT.WRK

      REPEAT

*Restore back ID.COMPANY if it has changed.

      IF ID.COMPANY <> SAVE.ID.COMPANY THEN
         CALL LOAD.COMPANY(SAVE.ID.COMPANY)
      END

      RETURN


*---------*
INITIALISE:
*---------*

      FN.RE.CONSOL.PROFIT.WORK = 'F.RE.CONSOL.PROFIT.WORK'
      F.RE.CONSOL.PROFIT.WORK = ''
      CALL OPF(FN.RE.CONSOL.PROFIT.WORK,F.RE.CONSOL.PROFIT.WORK)


      RETURN

*-----------------------*
CLEAR.RE.CONSOL.PRFT.WRK:
*-----------------------*

      CLEARFILE F.RE.CONSOL.PROFIT.WORK

      RETURN


   END
