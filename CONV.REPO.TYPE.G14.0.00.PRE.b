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
* <Rating>-144</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RP.Config
      SUBROUTINE CONV.REPO.TYPE.G14.0.00.PRE
*--------------------------------------------------------------
* This routine is to copy the existing records in
* REPO.TYPE (INT type) to REPO.TYPE in each company (FIN type)
* as there is a problem in defaulting MARGIN.PORTFOLIO to each
* company (CSS item : HD03800096)
*--------------------------------------------------------------
* Modification History:
*
* 06/02/07 - GLOBUS_BG_100012939
*            Doesn't work in multi-company setting properly, if
*            nothing setup in 1 company then the whole thing runs
*            when it shouldn't.
*
* 23/11/07 - GLOBUS_BG_100016008 - dgearing@temenos.com
*            incorrect subroutine call identified in build
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.REPO.TYPE
$INSERT I_F.REPO.PARAMETER

      GOSUB INITIALISE
      GOSUB PROCESS

      RETURN

*-----------------------------------------------------------------------------
INITIALISE:

      SYS.RET.ERROR = ''
      SEL.CMD = "SELECT F.COMPANY"
      CALL EB.READLIST(SEL.CMD, COMP.LIST, '', '', SYS.RET.ERR)

* select file manually as calling eb.readlist will open the fin
* file and come up with the wrong list.
      EXECUTE "SELECT F.REPO.TYPE" CAPTURING WASTE   ; * BG_100012939 s
      TYPES.LIST = '' ; EOF = @FALSE
      LOOP
         READNEXT ID ELSE
            EOF = @TRUE
         END
      UNTIL EOF DO
         TYPES.LIST<-1> = ID
      REPEAT   ; * BG_100012939 e

      FN.COMPANY = 'F.COMPANY' ; F.COMPANY = ''
      CALL OPF(FN.COMPANY,F.COMPANY)

      RETURN

*-----------------------------------------------------------------------------
PROCESS:

      GOSUB OPEN.INT.LEVEL.FILES ; * Open old int level files

      COMPS.LIST = COMP.LIST

      LOOP
         REMOVE COMP.ID FROM COMPS.LIST SETTING CPOS
      WHILE COMP.ID:CPOS
         COMP.REC = ''
         CALL F.READ(FN.COMPANY,COMP.ID,COMP.REC,F.COMPANY,FERR)
         LOCATE 'RP' IN COMP.REC<EB.COM.APPLICATIONS,1> SETTING APOS ELSE
            APOS = ''
         END
         IF APOS = '' THEN
            CONTINUE
         END
         GOSUB OPEN.CO.LEVEL.FILES ; * open & select co level files  ; * BG_100012939 s
         IF DO.CO.CONVERSION THEN
            GOSUB DO.CO.CONVERSION ; * Do the company conversion                         ; * repo types
         END   ; * BG_100012939 e
         CLOSE F.REPO.TYPE.LIVE
         CLOSE F.REPO.TYPE.NAU
         CLOSE F.REPO.TYPE.HIS
         CLOSE F.REPO.PARAM

      REPEAT                             ; * companies
      CLOSE F.RT

      RETURN

*-----------------------------------------------------------------------------
WRITE.NAU.RECS:

      READ RT.REC.NAU FROM F.RT.NAU, RT.ID ELSE
         RT.REC.NAU = ''
      END
      RT.REC<RP.TYP.RECORD.STATUS> = 'IHLD'

      IF RT.REC.NAU THEN
         WRITE RT.REC TO F.REPO.TYPE.NAU, RT.ID
      END

      RETURN

*-----------------------------------------------------------------------------
WRITE.HIS.RECS:

      SYS.RET.ERROR = ''
      SEL.CMD = "SELECT F.REPO.TYPE$HIS LIKE ":RT.ID:';...'
      CALL EB.READLIST(SEL.CMD, TYPES.LIST$HIS, '', '', SYS.RET.ERR)
      RT.LIST.HIS = TYPES.LIST$HIS
      LOOP
         REMOVE RT.ID.HIS FROM RT.LIST.HIS SETTING RPOS.HIS
      WHILE RT.ID.HIS:RPOS.HIS
         RT.REC.HIS = ''
         READ RT.REC.HIS FROM F.RT.HIS, RT.ID.HIS ELSE
            RT.REC.HIS = ''
         END
         WRITE RT.REC.HIS TO F.REPO.TYPE.HIS, RT.ID.HIS
      REPEAT                             ; * repo types

      RETURN

*-----------------------------------------------------------------------------
*** <region name= OPEN.CO.LEVEL.FILES>
OPEN.CO.LEVEL.FILES:
*** <desc>open & select co level files</desc>
* open PARAMETER file to check for the valid suffix

      PARAM.FILE = 'F.REPO.PARAMETER'
      OPEN PARAM.FILE TO F.REPO.PARAM ELSE
         TEXT = 'ERROR OPENING ':PARAM.FILE
         GOSUB FATAL.ERROR
      END
      READ PARAM.REC FROM F.REPO.PARAM, COMP.ID ELSE
         PARAM.REC = ''
      END
      COMP.FILE.LIVE = 'F':COMP.REC<EB.COM.MNEMONIC>:'.REPO.TYPE'
      OPEN COMP.FILE.LIVE TO F.REPO.TYPE.LIVE ELSE
         TEXT =  'ERROR OPENING ':COMP.FILE.LIVE
         GOSUB FATAL.ERROR
      END
      COMP.FILE.NAU = 'F':COMP.REC<EB.COM.MNEMONIC>:'.REPO.TYPE$NAU'
      OPEN COMP.FILE.NAU TO F.REPO.TYPE.NAU ELSE
         TEXT = 'ERROR OPENING ':COMP.FILE.NAU
         GOSUB FATAL.ERROR
      END
      COMP.FILE.HIS = 'F':COMP.REC<EB.COM.MNEMONIC>:'.REPO.TYPE$HIS'
      OPEN COMP.FILE.HIS TO F.REPO.TYPE.HIS ELSE
         TEXT =  'ERROR OPENING ':COMP.FILE.HIS
         GOSUB FATAL.ERROR
      END
      SEL.CMMD = 'SELECT ':COMP.FILE.LIVE
      REPO.TYPE.LIVE.LIST = ''
      LIST.NAME = ''
      SELECTED = ''
      SYSTEM.RETURN.CODE = ''
      CALL EB.READLIST(SEL.CMMD,REPO.TYPE.LIVE.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)

      SEL.CMMD = 'SELECT ':COMP.FILE.NAU
      REPO.TYPE.NAU.LIST = ''
      LIST.NAME = ''
      SELECTED = ''
      SYSTEM.RETURN.CODE = ''
      CALL EB.READLIST(SEL.CMMD,REPO.TYPE.NAU.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)

      DO.CO.CONVERSION = @TRUE
      IF REPO.TYPE.LIVE.LIST NE '' OR REPO.TYPE.NAU.LIST NE '' THEN
         DO.CO.CONVERSION = @FALSE
      END

      RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= DO.CO.CONVERSION>
DO.CO.CONVERSION:
*** <desc>Do the company conversion</desc>

      RT.LIST = TYPES.LIST
      LOOP
         REMOVE RT.ID FROM RT.LIST SETTING RPOS
      WHILE RT.ID:RPOS
         READ RT.REC FROM F.RT, RT.ID ELSE
            RT.REC = ''
         END
         IF RT.REC<RP.TYP.TRANSACTION.INDEX> EQ 'DEPOSIT' THEN
            LOC.FLD.NO = RP.PAR.REPO.MARGIN.SUF
         END ELSE
            LOC.FLD.NO = RP.PAR.RESO.MARGIN.SUF
         END
         LOCATE RT.REC<RP.TYP.MARGIN.PORT.SUFFIX> IN PARAM.REC<LOC.FLD.NO,1> SETTING SPOS ELSE
            SPOS = ''
         END
         IF NOT(RT.REC<RP.TYP.MARGIN.PORT.SUFFIX>) THEN
            SPOS = 1
         END
         IF SPOS THEN
* suffix is valid. So write LIV to LIV, NAU to NAU and HIS to HIS
            WRITE RT.REC TO F.REPO.TYPE.LIVE, RT.ID
            GOSUB WRITE.NAU.RECS
            GOSUB WRITE.HIS.RECS
         END ELSE
* just write it to NAU and ignore NAU and HIS records...
            RT.REC<RP.TYP.CURR.NO> = 1
            RT.REC<RP.TYP.AUTHORISER> = ''
            RT.REC<RP.TYP.RECORD.STATUS> = 'IHLD'
            WRITE RT.REC TO F.REPO.TYPE.NAU, RT.ID
         END

      REPEAT

      RETURN
*** </region>

*-----------------------------------------------------------------------------
FATAL.ERROR:

      CALL FATAL.ERROR('CONV.REPO.TYPE.G14.0.00.PRE') ; * BG_100016008

      RETURN

*-----------------------------------------------------------------------------
*** <region name= OPEN.INT.LEVEL.FILES>
OPEN.INT.LEVEL.FILES:
*** <desc>Open old int level files</desc>

      OPEN 'F.REPO.TYPE' TO F.RT ELSE
         TEXT =  'ERROR OPENING F.REPO.TYPE'
         GOSUB FATAL.ERROR
      END
      OPEN 'F.REPO.TYPE$NAU' TO F.RT.NAU ELSE
         TEXT =  'ERROR OPENING F.REPO.TYPE$NAU'
         GOSUB FATAL.ERROR
      END
      OPEN 'F.REPO.TYPE$HIS' TO F.RT.HIS ELSE
         TEXT = 'ERROR OPENING F.REPO.TYPE$HIS'
         GOSUB FATAL.ERROR
      END

      RETURN
*** </region>
   END                                   ; * final end
