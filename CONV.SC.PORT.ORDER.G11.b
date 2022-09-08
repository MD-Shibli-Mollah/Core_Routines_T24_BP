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
* <Rating>394</Rating>
*-----------------------------------------------------------------------------
* Version 3 15/05/01  GLOBUS Release No. 200512 09/12/05

    $PACKAGE SC.SctModelling
      SUBROUTINE CONV.SC.PORT.ORDER.G11

* This subroutine is a preconversion routine for SC.PORT.ORDER.
* It picks up those records in SC.PORT.ORDER which do not have data
* in the audit fields and populates these audit fields with meaningful
* info so that the conversion will run on these records.

************************************************************************

* 16/05/00 - GB0000626
*            Add 10 reserved fields and a new override field to
*            SC.PORT.ORDER

* 24/05/00 - GB0001302
*            Check if the product SC has been installed in a company
*            before running the pre conversion routine in that company.

************************************************************************

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.SC.PORT.ORDER
$INSERT I_F.COMPANY

************************************************************************

* Select all existing companies

      FN.COMPANY = 'F.COMPANY'
      F.COMPANY = ''
      CALL OPF(FN.COMPANY,F.COMPANY)

      COMMAND = 'SSELECT F.COMPANY'
      COMPANY.LIST = ''
      CALL EB.READLIST(COMMAND,COMPANY.LIST,'','','')

* Perform the conversion for each company

      LOOP

* Pick up each company one by one

         REMOVE K.COMPANY FROM COMPANY.LIST SETTING END.OF.COMPANIES
      WHILE K.COMPANY:END.OF.COMPANIES

* GB0001032 starts

* Find out if SC product is installed in this company.
* If not, loop to next company.

         READV APP.LIST FROM F.COMPANY,K.COMPANY,EB.COM.APPLICATIONS ELSE CONTINUE
         LOCATE 'SC' IN APP.LIST<1,1> SETTING FOUND ELSE CONTINUE

* GB0001032 ends

* Get the mnemonic of the company

         READV MNEMONIC FROM F.COMPANY,K.COMPANY,EB.COM.MNEMONIC THEN

            FILE.NAME = 'F':MNEMONIC:'.':'SC.PORT.ORDER'

* Find out the file type: live,unauthorised or history

            FOR FILE.TYPE = 1 TO 3
               BEGIN CASE
                  CASE FILE.TYPE EQ 1
                     SUFFIX = ""
                  CASE FILE.TYPE EQ 2
                     SUFFIX = "$NAU"
                  CASE FILE.TYPE EQ 3
                     SUFFIX = "$HIS"
               END CASE

* Open the  file and update the records whose audit data is missing.

               YFILE = FILE.NAME:SUFFIX
               FN.SC.PORT.ORDER = YFILE
               F.SC.PORT.ORDER = ""
               CALL OPF(FN.SC.PORT.ORDER, F.SC.PORT.ORDER)

               GOSUB UPDATE.AUDIT.FIELDS

            NEXT FILE.TYPE

         END

      REPEAT

      RETURN

********************************************************************

UPDATE.AUDIT.FIELDS:

* Select all records

      COMMAND = 'SELECT ' : FN.SC.PORT.ORDER
      SPO.LIST = ""
      CALL EB.READLIST(COMMAND, SPO.LIST, "", "", "")

* Pick up each record.

      LOOP

         REMOVE C$SPO.ID FROM SPO.LIST SETTING SPO.MARK

      WHILE C$SPO.ID : SPO.MARK

         CALL F.READ(FN.SC.PORT.ORDER,C$SPO.ID,R.SC.PORT.ORDER,F.SC.PORT.ORDER,YERR)

* Check if the conversion has run before.

         IF R.SC.PORT.ORDER<29> EQ '' THEN

* If not, check if company code exists in the old company code position

            IF R.SC.PORT.ORDER<18> EQ '' THEN

* If not, update the audit fields if they are null.

               R.SC.PORT.ORDER<18> = K.COMPANY

               IF R.SC.PORT.ORDER<14> = '' THEN
                  R.SC.PORT.ORDER<14> = 1
               END

               IF R.SC.PORT.ORDER<15> = '' THEN
                  R.SC.PORT.ORDER<15> = TNO:"_CONV.SC.PORT.ORDER.G11"
               END

               IF R.SC.PORT.ORDER<16> = '' THEN
                  X = OCONV(DATE(),"D-")
                  YTIME=OCONV(TIME(),"MT.")
                  YTIMEDATE = X[9,2]:X[1,2]:X[4,2]:YTIME[1,2]:YTIME[4,2]
                  R.SC.PORT.ORDER<16> = YTIMEDATE
               END

               IF R.SC.PORT.ORDER<17> = '' THEN
                  R.SC.PORT.ORDER<17> = TNO:"_CONV.SC.PORT.ORDER.G11"
               END

               WRITE R.SC.PORT.ORDER TO F.SC.PORT.ORDER, C$SPO.ID

            END

         END

      REPEAT

      RETURN

******************************************************************

   END
