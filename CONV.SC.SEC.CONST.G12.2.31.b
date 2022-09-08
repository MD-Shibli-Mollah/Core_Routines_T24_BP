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

* Version 1 29/01/01  GLOBUS Release No. G11.2.00 28/03/01
*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctConstraints
      SUBROUTINE CONV.SC.SEC.CONST.G12.2.31(R.ID, R.RECORD, FN.FILE)
*-----------------------------------------------------------------------------
* The file structure of the SC.SECURITY.CONSTRAINT file has been altered for G12.2.31 & therefore
* the existing data needs some manipulation to fit into the new structure.
*-----------------------------------------------------------------------------
* M O D I F I C A T I O N S
*-----------------------------------------------------------------------------
* 16/04/02 - GLOBUS_EN_10000534 - Pre Trade Restrictions
*            Move the data around in the SC.SECURITY.CONSTRAINT file
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE

      GOSUB PROCESS.RECORD

      RETURN

*-----------------------------------------------------------------------------
* S U B R O U T I N E S
*-----------------------------------------------------------------------------
INITIALISE:

* Set the variables for the position of the data in the file.
      OLD.MSG = 11
      NEW.MSG = 28
      RESTRICTION = 11
      RESTRICTION.KEY = 13
      RESTRICTION.DESC = 14
      RESTRICTION.TYPE = 15
      OVERRIDE.ERROR = 27
      NEW.DESC = 1

      RETURN

*-----------------------------------------------------------------------------
PROCESS.RECORD:

      LOOP.COUNT = 0
      MSG.DATA = R.RECORD<OLD.MSG>
      LOOP   ; * Loop through each MV & update the fields with their correct values
         REMOVE R.MSG FROM MSG.DATA SETTING MORE.TO.DO
      WHILE R.MSG:MORE.TO.DO
         LOOP.COUNT += 1
         RESTRICTION.ID = 'GENERIC.':LOOP.COUNT
         R.RECORD<NEW.MSG, LOOP.COUNT> = R.RECORD<OLD.MSG, LOOP.COUNT>
         R.RECORD<OLD.MSG, LOOP.COUNT> = ''
         R.RECORD<RESTRICTION, LOOP.COUNT> = RESTRICTION.ID
         R.RECORD<RESTRICTION.KEY, LOOP.COUNT> = RESTRICTION.ID
         R.RECORD<RESTRICTION.DESC, LOOP.COUNT> = 'Created by CONV.SC.SEC.CONST.G12.2.31'
         R.RECORD<RESTRICTION.TYPE, LOOP.COUNT> = 'TRANSACTION'
         R.RECORD<OVERRIDE.ERROR, LOOP.COUNT> = 'OVERRIDE'
         R.RECORD<NEW.DESC, LOOP.COUNT> = ''
      REPEAT

      RETURN

*-----------------------------------------------------------------------------
   END
