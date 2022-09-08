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
* <Rating>-52</Rating>
*-----------------------------------------------------------------------------
* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE SC.ScoSecurityMasterMaintenance
      SUBROUTINE CONV.DEF.COM.DOMICILE
*
* This conversion routine will be called from the CONVERSION.DETAILS
* record CONV.SECURITY.MASTER.G7.1 It will copy the contents of the
* COMPANY.DOMICILE field to the new BUS.CENTRES field field for each
* SECURITY.MASTER record on the system. It has been written as part
* of PIF GB9601316.
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
      GOSUB INITIALISE
*
      GOSUB PROCESS.LIVE
      GOSUB PROCESS.NAU
      GOSUB PROCESS.HIS
*
      RETURN                             ; * Exit program
*
*----------
INITIALISE:
*----------
*
      FN.SECURITY.MASTER = 'F.SECURITY.MASTER'
      F.SECURITY.MASTER = ''
      CALL OPF(FN.SECURITY.MASTER,F.SECURITY.MASTER)
*
      FN.SECURITY.MASTER$NAU = 'F.SECURITY.MASTER$NAU'
      F.SECURITY.MASTER$NAU = ''
      CALL OPF(FN.SECURITY.MASTER$NAU,F.SECURITY.MASTER$NAU)
*
      FN.SECURITY.MASTER$HIS = 'F.SECURITY.MASTER$HIS'
      F.SECURITY.MASTER$HIS = ''
      CALL OPF(FN.SECURITY.MASTER$HIS,F.SECURITY.MASTER$HIS)
*
      RETURN
*
*------------
PROCESS.LIVE:
*------------
*
      F.CURRENT.FILE = F.SECURITY.MASTER
      FN.CURRENT.FILE = FN.SECURITY.MASTER
      GOSUB PROCESS.RECORDS
*
      RETURN
*
*------------
PROCESS.NAU:
*------------
*
      F.CURRENT.FILE = F.SECURITY.MASTER$NAU
      FN.CURRENT.FILE = FN.SECURITY.MASTER$NAU
      GOSUB PROCESS.RECORDS
*
      RETURN
*
*------------
PROCESS.HIS:
*------------
*
      F.CURRENT.FILE = F.SECURITY.MASTER$HIS
      FN.CURRENT.FILE = FN.SECURITY.MASTER$HIS
      GOSUB PROCESS.RECORDS
*
      RETURN
*
*---------------
PROCESS.RECORDS:
*---------------
*
      STUFF = ''
      ID.LIST = ''
      TOTAL.SELECTED = ''
      CMMND = 'SELECT ':FN.CURRENT.FILE
      CALL EB.READLIST(CMMND,ID.LIST,'',TOTAL.SELECTED,STUFF)
*
      LOOP
         REMOVE SECURITY.MASTER.ID FROM ID.LIST SETTING MORE
      WHILE SECURITY.MASTER.ID:MORE DO
         READ R.SECURITY.MASTER FROM F.CURRENT.FILE,SECURITY.MASTER.ID THEN
            IF R.SECURITY.MASTER<72> ELSE
               R.SECURITY.MASTER<72> = R.SECURITY.MASTER<5>
               WRITE R.SECURITY.MASTER ON F.CURRENT.FILE,SECURITY.MASTER.ID
            END
         END
      REPEAT
*
      RETURN
*
   END
