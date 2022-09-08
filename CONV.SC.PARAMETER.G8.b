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

* Version 6 31/05/01  GLOBUS Release No. 200512 09/12/05
*-----------------------------------------------------------------------------
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.Config
      SUBROUTINE CONV.SC.PARAMETER.G8
*
*  conversion program to move start and end dates from BATCH
*  records to fields 47 and 48 of SC.PARAMETER
*
*-----------------------------------------------------------------------*
*                    M O D I F I C A T I O N S                          *
*-----------------------------------------------------------------------*
*
* 08/09/97 - GB971023
*            Amended to cater for multi-company and as per GLOBUS standards
*
*-----------------------------------------------------------------------*

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.BATCH
$INSERT I_F.COMPANY
$INSERT I_F.DATES
$INSERT I_F.SC.PARAMETER
$INSERT I_F.USER


      GOSUB INITIALISE
      GOSUB DETERMINE.COMPANIES
      GOSUB PROCESS.LIVE

      RETURN

*-----------------------------------------------------------------------*
*                    S U B R O U T I N E S                              *
*-----------------------------------------------------------------------*


*----------
INITIALISE:
*----------

      F.BATCH = ''
      F.COMPANY = ''
      F.SC.PARAMETER = ''

      CALL OPF('F.BATCH',F.BATCH)
      CALL OPF('F.COMPANY',F.COMPANY)
      CALL OPF('F.SC.PARAMETER',F.SC.PARAMETER)

      RETURN

*------------
PROCESS.LIVE:
*------------

*
*  if items exist in the select-list, read them, extract the company mnemonic
*  and process the record
*
      SYSCODE = ''
      ID.LIST = ''
      SELECTED = ''
      COMMAND = 'SELECT F.BATCH LIKE ...SC.BATCH...'

      CALL EB.READLIST(COMMAND,ID.LIST,'',SELECTED,SYSCODE)

      LOOP
         REMOVE BATCH.ID FROM ID.LIST SETTING MORE
      WHILE BATCH.ID:MORE DO

         IF INDEX(BATCH.ID,'/',1) THEN
            COMPANY.MNEMONIC = FIELD(BATCH.ID,'/',1)
            LOCATE COMPANY.MNEMONIC IN COMPANY.DETAILS<1,1> SETTING POSITION THEN
               COMPANY.ID = COMPANY.DETAILS<2,POSITION>
            END ELSE
               TEXT = 'CANNOT LOCATE COMPANY MNEMONIC'
               GOSUB FATAL.ERROR
            END
         END ELSE
            COMPANY.ID = COMPANY.DETAILS<2>
         END

         GOSUB GET.SC.PARAMETER.RECORD
         GOSUB GET.BATCH.RECORD

*
*  look through all jobs in this process
*
         JOBS = DCOUNT(R.BATCH<BAT.JOB.NAME>,@VM)

         FOR V$LOOP = 1 TO JOBS
            START.DATE = R.BATCH<BAT.DATA,V$LOOP,1>
*
*  check that the DATA field matches the current date format (as there
*  may be other data in DATA fields)
*
*  where relevant, add job name and convert dates to GLOBUS format
*
            IF START.DATE MATCHES '2N1X2N1X2N' THEN
               JOB.NAME = R.BATCH<BAT.JOB.NAME,V$LOOP>
               END.DATE = R.BATCH<BAT.DATA,V$LOOP,2>

               LOCATE JOB.NAME IN R.SC.PARAMETER<SC.PARAM.JOB.NAME,1> SETTING POSITION ELSE
                  INS JOB.NAME BEFORE R.SC.PARAMETER<SC.PARAM.JOB.NAME,POSITION>

                  COMI = START.DATE
                  CALL IN2D(11,'D')
                  INS COMI BEFORE R.SC.PARAMETER<SC.PARAM.START.DATE,POSITION>

                  COMI = END.DATE
                  CALL IN2D(11,'D')
                  INS COMI BEFORE R.SC.PARAMETER<SC.PARAM.END.DATE,POSITION>
               END
*
*  delete start and end dates from DATA fields
*
               DEL R.BATCH<BAT.DATA,V$LOOP,1>
               DEL R.BATCH<BAT.DATA,V$LOOP,1>
            END
         NEXT V$LOOP


         WRITE R.SC.PARAMETER ON F.SC.PARAMETER,COMPANY.ID
         RELEASE F.SC.PARAMETER,COMPANY.ID

         WRITE R.BATCH ON F.BATCH,BATCH.ID
         RELEASE F.BATCH,BATCH.ID
      REPEAT

      RETURN

*------------------
GET.COMPANY.RECORD:
*------------------

      CALL F.READ('F.COMPANY' ,
         COMPANY.ID ,
         REC.COMPANY ,
         F.COMPANY ,
         ETEXT)

      IF ETEXT THEN
         TEXT = 'CANNOT READ COMPANY RECORD'
         GOSUB FATAL.ERROR
      END

      RETURN

*----------------
GET.BATCH.RECORD:
*----------------

      READU R.BATCH FROM F.BATCH,BATCH.ID ELSE
         TEXT = 'CANNOT READ BATCH RECORD'
         GOSUB FATAL.ERROR
      END

      RETURN

*-----------------------
GET.SC.PARAMETER.RECORD:
*-----------------------

      READU R.SC.PARAMETER FROM F.SC.PARAMETER,COMPANY.ID ELSE
         TEXT = 'CANNOT READ SC.PARAMETER RECORD'
         GOSUB FATAL.ERROR
      END

      RETURN

*-------------------
DETERMINE.COMPANIES:
*-------------------

      COMPANY.DETAILS = ''
      SYSCODE = ''
      COMPANY.LIST = ''
      SELECTED = ''
      COMMAND = 'SSELECT F.COMPANY'

      CALL EB.READLIST(COMMAND,COMPANY.LIST,'',SELECTED,SYSCODE)

      FOR V$LOOP = 1 TO SELECTED
         COMPANY.ID = COMPANY.LIST<V$LOOP>
         GOSUB GET.COMPANY.RECORD
         COMPANY.DETAILS<1,V$LOOP> = REC.COMPANY<EB.COM.MNEMONIC>
         COMPANY.DETAILS<2,V$LOOP> = COMPANY.ID
      NEXT V$LOOP

      RETURN

*-----------
FATAL.ERROR:
*-----------

* GB9800517 - Call the right routine
      CALL FATAL.ERROR('CONV.SC.PARAMETER.G8')
      RETURN

   END
