* @ValidationCode : MjoxNDE5OTMzMDkyOkNwMTI1MjoxNTY0NTcwNjM4MDU3OnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:27:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>5</Rating>
*-----------------------------------------------------------------------------
      $PACKAGE CQ.ChqConfig
      SUBROUTINE CONV.F.CHQ.TYPE.TRNS.G10.1.01

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY

*
************************************************************************
*
* CHANGE CONTROL
* --------------
*
* 28/10/99 - GB9901554
*            Skip the reporting & consolidation companies in the program
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Config as ST_ChqConfig and include $PACKAGE
*	
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
************************************************************************
*
*
** This routine will be responsible to delete the files
** remaining
*
      F.VOC = ''
      OPEN '','VOC' TO F.VOC ELSE
         ABORT "UNABLE TO OPEN VOC"
      END
*
      F.COMPANY = ''
      CALL OPF('F.COMPANY',F.COMPANY)
*
      SEL.CMD = 'SSELECT F.COMPANY'
      COM.LIST = ''
      YSEL = 0
      CALL EB.READLIST(SEL.CMD,COM.LIST,'',YSEL,'')
      LOOP
         REMOVE K.COMPANY FROM COM.LIST SETTING END.OF.COMPANIES
      WHILE K.COMPANY:END.OF.COMPANIES
         READ COMPANY.REC FROM F.COMPANY,K.COMPANY THEN
            IF COMPANY.REC<EB.COM.CONSOLIDATION.MARK> = "N" THEN       ; * GB9901554
               LOCATE 'SC' IN COMPANY.REC<EB.COM.APPLICATIONS,1> SETTING POSN THEN
                  MNEMONIC = COMPANY.REC<EB.COM.MNEMONIC>
                  YFILE = 'F':MNEMONIC:'.CHQ.TYPE.TRNS'
                  GOSUB MODIFY.FILE
               END
            END                          ; * GB9901554
         END
      REPEAT

      RETURN
*
************
MODIFY.FILE:
************
*
      ETEXT = ""
      FN.TRANSACTION = "F":MNEMONIC:".TRANSACTION"
      F.TRANSACTION = ""
*
** If the TRANSACTION file is not found then this file should not exist
*
      OPEN '',FN.TRANSACTION TO F.TRANSACTION ELSE
         GOSUB DELETE.THE.FILE
      END

      RETURN
*
****************
DELETE.THE.FILE:
****************
*
* Read the VOC entry for the file
*
      R.VOC = ''
      READU R.VOC FROM F.VOC, YFILE LOCKED
         NULL
      END ELSE
         RETURN                          ; * GB9901554
      END
*
** Remove file from SYSTEM
*
      FILE.PATH = R.VOC<2>
      COMMAND.TYPE = "REMOVE"
      PARAMS = FILE.PATH:"/":YFILE
      CALL SYSTEM.CALL(COMMAND.TYPE,"",PARAMS,"",RESULT.CODE)
*
** Remove the VOC record
*
      DELETE F.VOC, YFILE

      RETURN

   END
*
