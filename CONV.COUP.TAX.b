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
* <Rating>-87</Rating>
*-----------------------------------------------------------------------------
* Version 2 01/03/01  GLOBUS Release No. 200509 29/07/05
*
    $PACKAGE SC.SccClassicCA
      SUBROUTINE CONV.COUP.TAX
*
**********************************************************************
*
* 22/09/00 - GB0002213
*            Conversion routine from DIV.COUP.TAX to COUPON.TAX.CODE
* 28/02/01 - GB0100575
*            Update inputter and date/time
**********************************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DIV.COUP.TAX
$INSERT I_F.COUPON.TAX.CODE
$INSERT I_F.USER
*
**********************************************************************
*
      GOSUB INITIALISATION
*
      EQU TRUE TO 1, FALSE TO 0
*
* Select list of DIV.COUP.TAX and DIV.COUP.TAX$NAU ids
*
      DTX.LIST = ''
      DTX$NAU.LIST = ''
      SELECT.STATEMENT = 'SSELECT ':FN.DIV.COUP.TAX$NAU
      CALL EB.READLIST(SELECT.STATEMENT,DTX$NAU.LIST,'','','')
      SELECT.STATEMENT = 'SSELECT ':FN.DIV.COUP.TAX
      CALL EB.READLIST(SELECT.STATEMENT,DTX.LIST,'','','')
      IF NOT(DTX.LIST) THEN
         E = 'NO LIST FROM DIV.COUP.TAX'
         CALL ERR
         RETURN
      END
*
* Main loop : If live id is found in DIV.COUP.TAX$NAU file then it will be ignored
*
      LOOP

         REMOVE ID.LIST FROM DTX.LIST SETTING MORE

      WHILE ID.LIST DO

         POS = 0
         LOCATE ID.LIST IN DTX$NAU.LIST<1> SETTING POS ELSE
            CALL F.READ('F.DIV.COUP.TAX',ID.LIST,R.DIV.COUP.TAX,F.DIV.COUP.TAX,ETEXT)
            IF ETEXT THEN
               TEXT = 'RECORD & MISSING FROM &':@FM:ID.LIST:@VM:'F.DIV.COUP.TAX'
               CALL FATAL.ERROR('DIV.COUP.TAX')
            END
            DTX.SOURCE.BONDS.TAX = R.DIV.COUP.TAX<SC.DTX.SOURCE.BONDS.TAX>
            DTX.LOCAL.BONDS.TAX = R.DIV.COUP.TAX<SC.DTX.LOCAL.BONDS.TAX>
            DTX.SOURCE.SHARE.TAX = R.DIV.COUP.TAX<SC.DTX.SOURCE.SHARE.TAX>
            DTX.LOCAL.SHARE.TAX = R.DIV.COUP.TAX<SC.DTX.LOCAL.SHARE.TAX>
            DTX.RECORD.STATUS = R.DIV.COUP.TAX<SC.DTX.RECORD.STATUS>
*
            GOSUB READ.RECORD
*
            GOSUB WRITE.RECORD

         END

      REPEAT
*
      RETURN
*
**********************************************************************
*
READ.RECORD:
*
* Check if record exists in COUPON.TAX.CODE$$NAU or COUPON.TAX.CODE file
*
      RECORD$NAU.FOUND = FALSE
      RECORD.FOUND = FALSE

      CALL F.READ('F.COUPON.TAX.CODE$NAU',ID.LIST,R.COUPON.TAX.CODE,F.COUPON.TAX.CODE$NAU,ETEXT)
      IF NOT(ETEXT) THEN
         RECORD$NAU.FOUND = TRUE
      END

      IF NOT(RECORD$NAU.FOUND) THEN
         CALL F.READ('F.COUPON.TAX.CODE',ID.LIST,R.COUPON.TAX.CODE,F.COUPON.TAX.CODE,ETEXT)
         IF NOT(ETEXT) THEN
            RECORD.FOUND = TRUE
         END
      END
*
      RETURN
*
**********************************************************************
*
WRITE.RECORD:
*
* Write DIV.COUP.TAX in COUPON.TAX.CODE
*
      IF RECORD$NAU.FOUND THEN
         GOSUB CTC.RECORD
         CALL F.WRITE('F.COUPON.TAX.CODE$NAU',ID.LIST,R.COUPON.TAX.CODE)
      END ELSE
         IF RECORD.FOUND THEN
            GOSUB CTC.RECORD
            CALL F.WRITE('F.COUPON.TAX.CODE$NAU',ID.LIST,R.COUPON.TAX.CODE)
         END ELSE
            GOSUB CTC.RECORD.IHLD
            CALL F.WRITE('F.COUPON.TAX.CODE$NAU',ID.LIST,R.COUPON.TAX.CODE)
         END
      END
*

*
      CALL JOURNAL.UPDATE(ID.LIST)
*
      RETURN
*
***********************************************************************
CTC.RECORD:
*
      IF R.COUPON.TAX.CODE<SC.CPN.SOURCE.BONDS.TAX> EQ '' THEN
         R.COUPON.TAX.CODE<SC.CPN.SOURCE.BONDS.TAX> = DTX.SOURCE.BONDS.TAX
      END

      R.COUPON.TAX.CODE<SC.CPN.LOCAL.BONDS.TAX> = DTX.LOCAL.BONDS.TAX

      R.COUPON.TAX.CODE<SC.CPN.SOURCE.SHARE.TAX> = DTX.SOURCE.SHARE.TAX

      R.COUPON.TAX.CODE<SC.CPN.LOCAL.SHARE.TAX> = DTX.LOCAL.SHARE.TAX

      R.COUPON.TAX.CODE<SC.CPN.SOURCE.TAX.CUST> = 'DEPOSITORY'

      R.COUPON.TAX.CODE<SC.CPN.LOCAL.TAX.CUST> = 'CUSTOMER'

      R.COUPON.TAX.CODE<SC.CPN.RECORD.STATUS> = 'IHLD'

*GB0100575S
      R.COUPON.TAX.CODE<SC.CPN.INPUTTER> = TNO:'_':'CONV.COUPON.TAX.CODE.G11.1.00'

      X = OCONV(DATE(),'D-')
      TIME.STAMP = TIMEDATE()
      DATE.TIME = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
      R.COUPON.TAX.CODE<SC.CPN.DATE.TIME> = DATE.TIME
*GB0100575E

      RETURN
*
***********************************************************************
CTC.RECORD.IHLD:
*
      R.COUPON.TAX.CODE<SC.CPN.SOURCE.BONDS.TAX> = DTX.SOURCE.BONDS.TAX

      R.COUPON.TAX.CODE<SC.CPN.LOCAL.BONDS.TAX> = DTX.LOCAL.BONDS.TAX

      R.COUPON.TAX.CODE<SC.CPN.SOURCE.SHARE.TAX> = DTX.SOURCE.SHARE.TAX

      R.COUPON.TAX.CODE<SC.CPN.LOCAL.SHARE.TAX> = DTX.LOCAL.SHARE.TAX

      R.COUPON.TAX.CODE<SC.CPN.SOURCE.TAX.CUST> = 'DEPOSITORY'

      R.COUPON.TAX.CODE<SC.CPN.LOCAL.TAX.CUST> = 'CUSTOMER'

      R.COUPON.TAX.CODE<SC.CPN.RECORD.STATUS> = 'IHLD'

      R.COUPON.TAX.CODE<SC.CPN.CURR.NO> = '1'

      R.COUPON.TAX.CODE<SC.CPN.INPUTTER> = TNO:'_':'CONV.COUPON.TAX.CODE.G11.1.00'

      X = OCONV(DATE(),'D-')
      TIME.STAMP = TIMEDATE()
      DATE.TIME = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
      R.COUPON.TAX.CODE<SC.CPN.DATE.TIME> = DATE.TIME

      R.COUPON.TAX.CODE<SC.CPN.CO.CODE> = R.USER<EB.USE.COMPANY.CODE>

      R.COUPON.TAX.CODE<SC.CPN.DEPT.CODE> = R.USER<EB.USE.DEPARTMENT.CODE>
*
      RETURN
*
**********************************************************************
*
INITIALISATION:
*
* Initialize parameters
*
      DTX.SOURCE.BONDS.TAX = ''
      DTX.LOCAL.BONDS.TAX = ''
      DTX.SOURCE.SHARE.TAX = ''
      DTX.LOCAL.SHARE.TAX = ''
      DTX.RECORD.STATUS = ''
*
* Open files
*
      F.DIV.COUP.TAX = ''
      FN.DIV.COUP.TAX = 'F.DIV.COUP.TAX'
      CALL OPF(FN.DIV.COUP.TAX,F.DIV.COUP.TAX)

      F.DIV.COUP.TAX$NAU = ''
      FN.DIV.COUP.TAX$NAU = 'F.DIV.COUP.TAX$NAU'
      CALL OPF(FN.DIV.COUP.TAX$NAU,F.DIV.COUP.TAX$NAU)

      F.COUPON.TAX.CODE = ''
      CALL OPF('F.COUPON.TAX.CODE',F.COUPON.TAX.CODE)

      F.COUPON.TAX.CODE$NAU = ''
      CALL OPF('F.COUPON.TAX.CODE$NAU',F.COUPON.TAX.CODE$NAU)
*
      RETURN
*
***********************************************************************
   END
***********************************************************************
