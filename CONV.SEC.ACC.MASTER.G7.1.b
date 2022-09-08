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

* Version 8 07/06/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>-91</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoPortfolioMaintenance
      SUBROUTINE CONV.SEC.ACC.MASTER.G7.1
*
* This routine was written as part of the Management Fees development
* HSJ0119 - PIF GB9600237.
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT(). 
*
*************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.SPF
*************************************************************************
*
      F.COMPANY = ''
      CALL OPF('F.COMPANY',F.COMPANY)
      HOLD.ID.COMPANY = ID.COMPANY
*
* GB9701190 - Not for Conslidation and Reporting companies
      SEL.CMD = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
      COM.LIST = ''
      YSEL = 0
      CALL EB.READLIST(SEL.CMD,COM.LIST,'',YSEL,'')
      LOOP
         REMOVE K.COMPANY FROM COM.LIST SETTING END.OF.COMPANIES
      WHILE K.COMPANY:END.OF.COMPANIES
         READV MNEMONIC FROM F.COMPANY,K.COMPANY,3 THEN
            CALL LOAD.COMPANY(K.COMPANY)
            LOCATE 'SC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING POSNOS THEN
               FILE.NAME = 'F':MNEMONIC:'.SEC.ACC.MASTER'
               GOSUB MODIFY.FILE
            END
         END
      REPEAT
      CALL LOAD.COMPANY(HOLD.ID.COMPANY)
*
      RETURN
*
*-----------
MODIFY.FILE:
*-----------
*
      GOSUB INITIALISE
*
      CALL HUSHIT(1)
      CMND = 'CLEAR.FILE DATA ':FN.SCAC.ADV.DATES
      EXECUTE CMND
      CMND = 'CLEAR.FILE DATA ':FN.SCAC.SAFE.DATES
      EXECUTE CMND
      CALL HUSHIT(0)
*
      COMMAND = 'SELECT ':FN.SEC.ACC.MASTER
      CALL EB.READLIST(COMMAND, RECORD.LIST, '', V$NUM, CODE)
*
      LOOP
         REMOVE RECORD.ID FROM RECORD.LIST SETTING RECORD.POS
      WHILE RECORD.ID : RECORD.POS
         GOSUB PROCESS.LIVE.RECORD
      REPEAT
*
      COMMAND = 'SELECT ':FN.SEC.ACC.MASTER$NAU
      CALL EB.READLIST(COMMAND, RECORD.LIST, '', V$NUM, CODE)
*
      LOOP
         REMOVE RECORD.ID FROM RECORD.LIST SETTING RECORD.POS
      WHILE RECORD.ID : RECORD.POS
         GOSUB PROCESS.UNAU.RECORD
      REPEAT
*
      COMMAND = 'SELECT ':FN.SEC.ACC.MASTER$HIS
      CALL EB.READLIST(COMMAND, RECORD.LIST, '', V$NUM, CODE)
*
      LOOP
         REMOVE RECORD.ID FROM RECORD.LIST SETTING RECORD.POS
      WHILE RECORD.ID : RECORD.POS
         GOSUB PROCESS.HIS.RECORD
      REPEAT
*
* Processing done so return.
*
      RETURN
*
*----------
INITIALISE:
*----------
* Open the SEC.ACC.MASTER here.
*
      FN.SEC.ACC.MASTER = 'F.SEC.ACC.MASTER'
      F.SEC.ACC.MASTER = ''
      CALL OPF(FN.SEC.ACC.MASTER, F.SEC.ACC.MASTER)
*
      FN.SEC.ACC.MASTER$NAU = 'F.SEC.ACC.MASTER$NAU'
      F.SEC.ACC.MASTER$NAU = ''
      CALL OPF(FN.SEC.ACC.MASTER$NAU, F.SEC.ACC.MASTER$NAU)
*
      FN.SEC.ACC.MASTER$HIS = 'F.SEC.ACC.MASTER$HIS'
      F.SEC.ACC.MASTER$HIS = ''
      CALL OPF(FN.SEC.ACC.MASTER$HIS, F.SEC.ACC.MASTER$HIS)
*
      F.CUSTOMER.CHARGE = ''
      CALL OPF('F.CUSTOMER.CHARGE',F.CUSTOMER.CHARGE)
      F.SCAC.ADV.DATES = ''
      FN.SCAC.ADV.DATES = 'F.SCAC.ADV.DATES'
      CALL OPF(FN.SCAC.ADV.DATES,F.SCAC.ADV.DATES)
      F.SCAC.SAFE.DATES = ''
      FN.SCAC.SAFE.DATES = 'F.SCAC.SAFE.DATES'
      CALL OPF(FN.SCAC.SAFE.DATES,F.SCAC.SAFE.DATES)
*
      F.SAFECUSTODY.VALUES = ''
      CALL OPF('F.SAFECUSTODY.VALUES',F.SAFECUSTODY.VALUES)
      R.SAFECUSTODY.VALUES = ''
      CALL F.READ('F.SAFECUSTODY.VALUES',ID.COMPANY,R.SAFECUSTODY.VALUES,F.SAFECUSTODY.VALUES,ETEXT)
      IF ETEXT THEN
         ETEXT = ''
         IC.POSN = ''
         SC.POSN = ''
      END ELSE
         LOCATE 'IC' IN R.SAFECUSTODY.VALUES<1,1> SETTING IC.POSN ELSE
            IC.POSN = ''
         END
         LOCATE 'SC' IN R.SAFECUSTODY.VALUES<1,1> SETTING SC.POSN ELSE
            SC.POSN = ''
         END
      END
*
      RETURN
*
*-------------------
PROCESS.LIVE.RECORD:
*-------------------
* Read the record from the file.

      READ R.SEC.ACC.MASTER FROM F.SEC.ACC.MASTER, RECORD.ID THEN
         IF R.SEC.ACC.MASTER<36> THEN
            RETURN                       ; * Dealer Book Portfolio. Do nothing
         END
*
* Update the record
*
         IF IC.POSN THEN
            R.SEC.ACC.MASTER<69> = R.SAFECUSTODY.VALUES<7,IC.POSN>
            YFILE = 'F.SCAC.ADV.DATES'
            CONCAT.ID = R.SEC.ACC.MASTER<69>[1,8]
            SAVE.SPF = R.SPF.SYSTEM<SPF.OP.MODE> ; R.SPF.SYSTEM<SPF.OP.MODE> = "B"
            CALL CONCAT.FILE.UPDATE(YFILE,CONCAT.ID,RECORD.ID,'I','AL')
            R.SPF.SYSTEM<SPF.OP.MODE> = SAVE.SPF
            R.SEC.ACC.MASTER<70> = R.SAFECUSTODY.VALUES<8,IC.POSN>
         END
         IF SC.POSN THEN
            R.SEC.ACC.MASTER<66> = R.SAFECUSTODY.VALUES<7,SC.POSN>
            YFILE = 'F.SCAC.SAFE.DATES'
            CONCAT.ID = R.SEC.ACC.MASTER<66>[1,8]
            SAVE.SPF = R.SPF.SYSTEM<SPF.OP.MODE> ; R.SPF.SYSTEM<SPF.OP.MODE> = "B"
            CALL CONCAT.FILE.UPDATE(YFILE,CONCAT.ID,RECORD.ID,'I','AL')
            R.SPF.SYSTEM<SPF.OP.MODE> = SAVE.SPF
            R.SEC.ACC.MASTER<67> = R.SAFECUSTODY.VALUES<8,SC.POSN>
         END
         R.SEC.ACC.MASTER<72> = 'AUTOMATIC'
         GOSUB UPDATE.SCALES
*
* And write the record.
*
         WRITE R.SEC.ACC.MASTER ON F.SEC.ACC.MASTER, RECORD.ID
      END
*
      RETURN
*
*-------------------
PROCESS.UNAU.RECORD:
*-------------------
* Read the record from the file.
*
      READ R.SEC.ACC.MASTER FROM F.SEC.ACC.MASTER$NAU, RECORD.ID THEN
         IF R.SEC.ACC.MASTER<36> THEN
            RETURN                       ; * Dealer Book Portfolio. Do nothing
         END
*
* Update the record
*
         IF IC.POSN THEN
            R.SEC.ACC.MASTER<69> = R.SAFECUSTODY.VALUES<7,IC.POSN>
            R.SEC.ACC.MASTER<70> = R.SAFECUSTODY.VALUES<8,IC.POSN>
         END
         IF SC.POSN THEN
            R.SEC.ACC.MASTER<66> = R.SAFECUSTODY.VALUES<7,SC.POSN>
            R.SEC.ACC.MASTER<67> = R.SAFECUSTODY.VALUES<8,SC.POSN>
         END
         R.SEC.ACC.MASTER<72> = 'AUTOMATIC'
         GOSUB UPDATE.SCALES
*
* And write the record.
*
         WRITE R.SEC.ACC.MASTER ON F.SEC.ACC.MASTER$NAU, RECORD.ID
      END
*
      RETURN
*
*-------------------
PROCESS.HIS.RECORD:
*-------------------
* Read the record from the file.
*
      READ R.SEC.ACC.MASTER FROM F.SEC.ACC.MASTER$HIS, RECORD.ID THEN
         IF R.SEC.ACC.MASTER<36> THEN
            RETURN                       ; * Dealer Book Portfolio. Do nothing
         END
*
* Update the record
*
         IF IC.POSN THEN
            R.SEC.ACC.MASTER<69> = R.SAFECUSTODY.VALUES<7,IC.POSN>
            R.SEC.ACC.MASTER<70> = R.SAFECUSTODY.VALUES<8,IC.POSN>
         END
         IF SC.POSN THEN
            R.SEC.ACC.MASTER<66> = R.SAFECUSTODY.VALUES<7,SC.POSN>
            R.SEC.ACC.MASTER<67> = R.SAFECUSTODY.VALUES<8,SC.POSN>
         END
         R.SEC.ACC.MASTER<72> = 'AUTOMATIC'
         GOSUB UPDATE.SCALES
*
* And write the record.
*
         WRITE R.SEC.ACC.MASTER ON F.SEC.ACC.MASTER$HIS, RECORD.ID
      END
*
      RETURN
*
*-------------
UPDATE.SCALES:
*-------------
*
* Management Fees Scale
*
      CUST.NO = FIELD(RECORD.ID,'-',1)
      SUFFIX = FIELD(RECORD.ID,'-',2)
      ER = ''
      R.CUSTOMER.CHARGE = ''
      CALL F.READ('F.CUSTOMER.CHARGE',CUST.NO,R.CUSTOMER.CHARGE,F.CUSTOMER.CHARGE,ER)
      IF ER THEN
         RETURN
      END
      SC.APP = 'SC.MANAGEMENT'
      LOCATE SC.APP IN R.CUSTOMER.CHARGE<4,1> SETTING APP.POS THEN
         LOCATE SUFFIX IN R.CUSTOMER.CHARGE<5,APP.POS,1> SETTING POS THEN
            R.SEC.ACC.MASTER<71> = R.CUSTOMER.CHARGE<7,APP.POS,POS>
         END ELSE
            LOCATE "ALL" IN R.CUSTOMER.CHARGE<5,APP.POS,1> SETTING POS THEN
               R.SEC.ACC.MASTER<71> = R.CUSTOMER.CHARGE<7,APP.POS,POS>
            END
         END
      END
*
* Safecustody Fees Scale
*
      SC.APP = 'SC.SAFEKEEPING'
      LOCATE SC.APP IN R.CUSTOMER.CHARGE<4,1> SETTING APP.POS THEN
         LOCATE SUFFIX IN R.CUSTOMER.CHARGE<5,APP.POS,1> SETTING POS THEN
            R.SEC.ACC.MASTER<68> = R.CUSTOMER.CHARGE<7,APP.POS,POS>
         END ELSE
            LOCATE "ALL" IN R.CUSTOMER.CHARGE<5,APP.POS,1> SETTING POS THEN
               R.SEC.ACC.MASTER<68> = R.CUSTOMER.CHARGE<7,APP.POS,POS>
            END
         END
      END
*
      RETURN
*
   END
