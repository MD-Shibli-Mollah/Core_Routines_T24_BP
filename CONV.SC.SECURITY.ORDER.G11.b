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
      SUBROUTINE CONV.SC.SECURITY.ORDER.G11

* This subroutine is a preconversion routine for SC.SECURITY.ORDER.
* It picks up those records in SC.SECURITY.ORDER which do not have data
* in the audit fields and populates these audit fields with meaningful
* info so that the conversion will run on these records.

************************************************************************

* 16/05/00 - GB0000626
*            Add 10 reserved fields and a new override field to
*            SC.SECURITY.ORDER

* 24/05/00 - GB0001302
*            Check if the product SC has been installed in a company
*            before running the pre conversion routine in that company.

************************************************************************

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.SC.SECURITY.ORDER
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

            FILE.NAME = 'F':MNEMONIC:'.':'SC.SECURITY.ORDER'

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
               FN.SC.SECURITY.ORDER = YFILE
               F.SC.SECURITY.ORDER = ""
               CALL OPF(FN.SC.SECURITY.ORDER, F.SC.SECURITY.ORDER)

               GOSUB UPDATE.AUDIT.FIELDS

            NEXT FILE.TYPE

         END

      REPEAT

      RETURN

********************************************************************

UPDATE.AUDIT.FIELDS:

* Select all records

      COMMAND = 'SELECT ' : FN.SC.SECURITY.ORDER
      SSO.LIST = ""
      CALL EB.READLIST(COMMAND, SSO.LIST, "", "", "")

* Pick up each record.

      LOOP

         REMOVE C$SSO.ID FROM SSO.LIST SETTING SSO.MARK

      WHILE C$SSO.ID : SSO.MARK

         CALL F.READ(FN.SC.SECURITY.ORDER,C$SSO.ID,R.SC.SECURITY.ORDER,F.SC.SECURITY.ORDER,YERR)

* Check if the conversion has run before.

         IF R.SC.SECURITY.ORDER<30> EQ '' THEN

* If not, check if company code exists in the old company code position

            IF R.SC.SECURITY.ORDER<19> EQ '' THEN

* If not, update the audit fields if they are null.

               R.SC.SECURITY.ORDER<19> = K.COMPANY

               IF R.SC.SECURITY.ORDER<15> = '' THEN
                  R.SC.SECURITY.ORDER<15> = 1
               END

               IF R.SC.SECURITY.ORDER<16> = '' THEN
                  R.SC.SECURITY.ORDER<16> = TNO:"_CONV.SC.SECURITY.ORDER.G11"
               END

               IF R.SC.SECURITY.ORDER<17> = '' THEN
                  X = OCONV(DATE(),"D-")
                  YTIME=OCONV(TIME(),"MT.")
                  YTIMEDATE = X[9,2]:X[1,2]:X[4,2]:YTIME[1,2]:YTIME[4,2]
                  R.SC.SECURITY.ORDER<17> = YTIMEDATE
               END

               IF R.SC.SECURITY.ORDER<18> = '' THEN
                  R.SC.SECURITY.ORDER<18> = TNO:"_CONV.SC.SECURITY.ORDER.G11"
               END

               WRITE R.SC.SECURITY.ORDER TO F.SC.SECURITY.ORDER, C$SSO.ID

            END

         END

      REPEAT

      RETURN

******************************************************************

   END
