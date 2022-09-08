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

* Version 2 16/05/01  GLOBUS Release No. 200512 09/12/05
*-----------------------------------------------------------------------------
* <Rating>395</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityPositionUpdate
      SUBROUTINE CONV.TRN.CON.DATE
*
*
****************************************************************
* CONVERSION TO ADD VALUE.DATE & DATE.UPDATED TO TRN.CON.DATE
*
*
* 22/03/05 - CI_10028622
*            Multicompany compatible
*
****************************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.SECURITY.TRANS
*
*
* CI_10028622 S
      SAVE.ID.COMPANY = ID.COMPANY
*
* Loop through each company
*
* GB9701190 - Not for Conslidation and Reporting companies
      COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
      COMPANY.LIST = ''
      CALL EB.READLIST(COMMAND, COMPANY.LIST, '','','')
      LOOP
         REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
      WHILE K.COMPANY:COMP.MARK
*
         IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
         END
* CI_10028622 E
         F.TRN.CON.DATE = ''
         CALL OPF('F.TRN.CON.DATE',F.TRN.CON.DATE)
         F.SECURITY.TRANS = ''
         CALL OPF('F.SECURITY.TRANS',F.SECURITY.TRANS)
*
         SELECT F.TRN.CON.DATE
*
*
         LOOP
            READNEXT K.TRN ELSE NULL
         WHILE K.TRN DO
            READU R.TRN FROM F.TRN.CON.DATE,K.TRN ELSE
               PRINT 'MISSING K.TRN.CON.DATE ':K.TRN
               STOP
            END
*
            UPDATE.REC = 0
            COUNT.TRNS = COUNT(R.TRN,FM) + (R.TRN<1> NE '')
            FOR X = 1 TO COUNT.TRNS
               DET.LINE = R.TRN<X>
               DOT.POS = COUNT(DET.LINE,'.')
               K.HIST = FIELD(DET.LINE,'.',DOT.POS,2)
               IF DOT.POS = 8 THEN       ; * 2 EXTRA REQUIRED
                  UPDATE.REC = 1
*
                  READ R.SECURITY.TRANS FROM F.SECURITY.TRANS,K.HIST ELSE
                     PRINT 'MISSING F.SECURITY.TRANS ':K.HIST
                     STOP
                  END
*
                  VALUE.DATE = R.SECURITY.TRANS<SC.SCT.VALUE.DATE>
                  DATE.UPDATED = R.SECURITY.TRANS<SC.SCT.DATE.UPDATED>
*
                  NEW.DET.LINE = FIELD(DET.LINE,'.',1,7):'.':VALUE.DATE:'.':DATE.UPDATED:'.':FIELD(DET.LINE,'.',8,2)
                  R.TRN<X> = NEW.DET.LINE
               END
            NEXT X
            IF UPDATE.REC THEN
               WRITE R.TRN TO F.TRN.CON.DATE,K.TRN
            END ELSE
               RELEASE F.TRN.CON.DATE,K.TRN
            END
*
         REPEAT
         * CI_10028622 S
         * Processing for this company now complete.
*
      REPEAT
      *
* Processing now complete for all companies.
* Change back to the original company if we have changed.
*
      IF ID.COMPANY <> SAVE.ID.COMPANY THEN
         CALL LOAD.COMPANY(SAVE.ID.COMPANY)
      END
      * CI_10028622 E
*
   END
