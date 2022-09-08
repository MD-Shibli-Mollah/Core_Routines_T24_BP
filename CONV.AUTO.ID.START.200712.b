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
* <Rating>-68</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Foundation
      SUBROUTINE CONV.AUTO.ID.START.200712(AUTO.ID.START.ID, R.AUTO.ID.START, FN.AUTO.ID.START)
*-----------------------------------------------------------------------------
* Modification History:
*
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE


      TARGET.ID = 'AM.VIOLATION'
      IF AUTO.ID.START.ID EQ TARGET.ID THEN
         GOSUB INITIALISE
         GOSUB GET.ASSET.MANAGEMENT.RECORD
         GOSUB MERGE.INTO.AM.RECORD
         GOSUB UPDATE.AUDIT.FIELDS
         GOSUB UPDATE.FILE
      END
      RETURN

*-----------------------------------------------------------------------------
INITIALISE:

* open files etc
      FN.AUTO.ID.START = 'F.AUTO.ID.START'
      F.AUTO.ID.START = ''
      CALL OPF(FN.AUTO.ID.START,F.AUTO.ID.START)

      FN.AUTO.ID.START$NAU = 'F.AUTO.ID.START$NAU'
      F.AUTO.ID.START$NAU = ''
      CALL OPF(FN.AUTO.ID.START$NAU,F.AUTO.ID.START$NAU)

*... set up the field variables for the AUTO.ID.START record.
      AUTID.APPLICATION = 2
      AUTID.ID.START = 3
      AUTID.UNIQUE.NO = 4
      AUTID.BASE.TABLE = 5
      AUTID.ID.LENGTH = 6
      AUTID.APP.PREFIX = 7
      AUTID.RECORD.STATUS = 17
      AUTID.CURR.NO = 18
      AUTID.INPUTTER = 19
      AUTID.DATE.TIME = 20
      AUTID.AUTHORISER = 21
      AUTID.CO.CODE = 22
      AUTID.DEPT.CODE = 23
      AUTID.AUDITOR.CODE = 24
      AUTID.AUDIT.DATE.TIME = 25

*... The status will be INAU unless the target ASSET.MANAGEMENT record does not exist.
      TARGET.STATUS = 'INAU'
      EXISTING.STATUS = R.AUTO.ID.START<AUTID.RECORD.STATUS>

*... have we made any changes to the target record?
      IS.TARGET.CHANGED = @FALSE

      RETURN

GET.ASSET.MANAGEMENT.RECORD:
      TARGET.AUTO.ID.START.ID = 'ASSET.MANAGEMENT'
      TARGET.R.AUTO.ID.START = ''
      YERR = ''
      CALL F.READ(FN.AUTO.ID.START$NAU,TARGET.AUTO.ID.START.ID,TARGET.R.AUTO.ID.START,F.AUTO.ID.START$NAU,YERR)
      IF YERR NE '' THEN
         TARGET.R.AUTO.ID.START = ''
         YERR = ''
         CALL F.READ(FN.AUTO.ID.START,TARGET.AUTO.ID.START.ID,TARGET.R.AUTO.ID.START,F.AUTO.ID.START,YERR)
         IF YERR NE '' THEN
            TARGET.STATUS = 'IHLD'
            YERR = ''
         END
      END
      RETURN

*-----------------------------------------------------------------------------

*** <region name= MERGE.INTO.AM.RECORD>
MERGE.INTO.AM.RECORD:
***
      APPLICATION.LIST = R.AUTO.ID.START<AUTID.APPLICATION>
      NUMBER.OF.APPS = DCOUNT(APPLICATION.LIST, @VM)
      FOR APPLICATION.NUM = 1 TO NUMBER.OF.APPS
         APPLICATION.NAME = R.AUTO.ID.START<AUTID.APPLICATION, APPLICATION.NUM>
         LOCATE APPLICATION.NAME IN TARGET.R.AUTO.ID.START<AUTID.APPLICATION, 1> SETTING POS THEN
            TARGET.MV = POS
            GOSUB ADD.APPLICATION.INTO.AM.RECORD
         END ELSE
            TARGET.MV = DCOUNT(TARGET.R.AUTO.ID.START<AUTID.APPLICATION>, @VM) + 1
            GOSUB ADD.APPLICATION.INTO.AM.RECORD
         END
      NEXT APPLICATION.NUM
      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= ADD.APPLICATION.INTO.AM.RECORD>
ADD.APPLICATION.INTO.AM.RECORD:
***
      IF APPLICATION.NAME NE '' THEN
         IS.TARGET.CHANGED = @TRUE
         TARGET.R.AUTO.ID.START<AUTID.APPLICATION, TARGET.MV> = R.AUTO.ID.START<AUTID.APPLICATION, APPLICATION.NUM>
         TARGET.R.AUTO.ID.START<AUTID.ID.START, TARGET.MV> = R.AUTO.ID.START<AUTID.ID.START, APPLICATION.NUM>
         TARGET.R.AUTO.ID.START<AUTID.UNIQUE.NO, TARGET.MV> = R.AUTO.ID.START<AUTID.UNIQUE.NO, APPLICATION.NUM>
         TARGET.R.AUTO.ID.START<AUTID.BASE.TABLE, TARGET.MV> = R.AUTO.ID.START<AUTID.BASE.TABLE, APPLICATION.NUM>
         TARGET.R.AUTO.ID.START<AUTID.ID.LENGTH, TARGET.MV> = R.AUTO.ID.START<AUTID.ID.LENGTH, APPLICATION.NUM>
      END

      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= UPDATE.AUDIT.FIELDS>
UPDATE.AUDIT.FIELDS:
***
      IF IS.TARGET.CHANGED THEN
         AUDIT.TIME = TIMEDATE()
         AUDIT.DATE = OCONV(DATE(),"D-")
         AUDIT.DATE.TIME = AUDIT.DATE[9,2]:AUDIT.DATE[1,2]:AUDIT.DATE[4,2]
         AUDIT.DATE.TIME := AUDIT.TIME[1,2]:AUDIT.TIME[4,2]
         TARGET.R.AUTO.ID.START<AUTID.INPUTTER> = TNO:"_":OPERATOR
         TARGET.R.AUTO.ID.START<AUTID.DATE.TIME> = AUDIT.DATE.TIME
         TARGET.R.AUTO.ID.START<AUTID.CO.CODE> = ID.COMPANY
         IF TARGET.R.AUTO.ID.START<AUTID.RECORD.STATUS> NE 'IHLD' THEN
            TARGET.R.AUTO.ID.START<AUTID.RECORD.STATUS> = TARGET.STATUS
         END
      END
      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= UPDATE.FILE>
UPDATE.FILE:
***
      IF IS.TARGET.CHANGED THEN
         CALL F.WRITE(FN.AUTO.ID.START$NAU,TARGET.AUTO.ID.START.ID,TARGET.R.AUTO.ID.START)
         CALL F.DELETE(FN.AUTO.ID.START,AUTO.ID.START.ID)
         CALL F.DELETE(FN.AUTO.ID.START$NAU,AUTO.ID.START.ID)
      END
      RETURN
*** </region>


   END
