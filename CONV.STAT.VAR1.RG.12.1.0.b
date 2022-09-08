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

* Version 3 02/06/00  GLOBUS Release No. 200508 29/07/05
*-----------------------------------------------------------------------------
* <Rating>844</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.Config
      SUBROUTINE CONV.STAT.VAR1.RG.12.1.0
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.RE.STAT.REP.LINE
$INSERT I_F.RE.STAT.RANGE
$INSERT I_F.RE.STAT.VAR1.RANGE
$INSERT I_F.CONSOLIDATE.COND
*
** This program will remove the ranges from STAT.VAR1.RANGE where the
** range defined does not match the RE.STAT.RANGE record.
*
      CRT @(5,5):"This routine will remove old range records from the "
      CRT @(5,6):"RE.STAT.VAR1.RANGE file"
      TEXT = "DO YOU WISH TO CONVERT THE FILE"
      CALL OVE
      IF TEXT = "Y" THEN
*
         F.RE.STAT.RANGE = ""
         CALL OPF("F.RE.STAT.RANGE", F.RE.STAT.RANGE)
*
         F.RE.STAT.VAR1.RANGE = ""
         CALL OPF("F.RE.STAT.VAR1.RANGE", F.RE.STAT.VAR1.RANGE)
*
         F.CONSOLIDATE.COND = ""
         CALL OPF("F.CONSOLIDATE.COND", F.CONSOLIDATE.COND)
*
         ID.LIST = "ASSET&LIAB":VM:"PROFIT&LOSS"
*
         LOOP
            REMOVE YID FROM ID.LIST SETTING YD
         WHILE YID:YD
            READ CONSOL.COND FROM F.CONSOLIDATE.COND, YID THEN
               CON.VAR1 = CONSOL.COND<RE.CON.NAME,1>         ; * Name of VAR1
               READ VAR1.REC FROM F.RE.STAT.VAR1.RANGE, YID THEN
                  AV = 1 ; AS = 1
                  LOOP
                  WHILE VAR1.REC<RE.SV1R.MNEMONIC,AV>
                     RANGE.ID = VAR1.REC<RE.SV1R.MNEMONIC,AV>[2,99]
                     READ YRANGE.REC FROM F.RE.STAT.RANGE, RANGE.ID THEN
** Check that the range matches the definition and the reports linked
** are the same as the range record. If not remove them
                        BEGIN CASE
                           CASE CON.VAR1 NE YRANGE.REC<RE.RNG.CONSOL.FIELD>      ; * Not Var1
                              GOSUB DEL.VALUES
                           CASE VAR1.REC<RE.SV1R.START.RANGE,AV> NE YRANGE.REC<RE.RNG.START.RANGE>
                              GOSUB DEL.VALUES
                           CASE VAR1.REC<RE.SV1R.END.RANGE,AV> NE YRANGE.REC<RE.RNG.END.RANGE>
                              GOSUB DEL.VALUES
                           CASE 1        ; * Check each report
                              AS = 1
                              LOOP
                                 REP.NAME = VAR1.REC<RE.SV1R.REP.NAME, AV, AS>
                              WHILE REP.NAME
                                 LOCATE REP.NAME IN YRANGE.REC<RE.RNG.REPORT.NAME,1> SETTING YPOS THEN
                                    AS += 1        ; * Get the next 1
                                 END ELSE
                                    DEL VAR1.REC<RE.SV1R.REP.NAME,AV,AS>
                                 END
                              REPEAT
*
** Add in the reports from the range missing
*
                              RG.VM = 1
                              LOOP
                                 REP.NAME = YRANGE.REC<RE.RNG.REPORT.NAME,RG.VM>
                              WHILE REP.NAME
                                 LOCATE REP.NAME IN VAR1.REC<RE.SV1R.REP.NAME,AV,1> SETTING YPOS ELSE
                                    VAR1.REC<RE.SV1R.REP.NAME,AV,-1> = YRANGE.REC<RE.RNG.REPORT.NAME,RG.VM>
                                 END
                                 RG.VM += 1
                              REPEAT
*
** If there are no reports delete the details for the range
*
                              IF VAR1.REC<RE.SV1R.REP.NAME,AV> = "" THEN
                                 GOSUB DEL.VALUES
                              END ELSE
                                 AV += 1
                              END
*
                        END CASE
                     END ELSE            ; * Range is reversed
                        GOSUB DEL.VALUES
                     END
                  REPEAT
*
** Write the amended record back
*
                  WRITE VAR1.REC TO F.RE.STAT.VAR1.RANGE, YID
*
               END
            END
         REPEAT
*
      END
*
      RETURN
*
*------------------------------------------------------------------------
DEL.VALUES:
*==========
*
      FOR AF = RE.SV1R.START.RANGE TO RE.SV1R.REP.NAME
         DEL VAR1.REC<AF,AV>
      NEXT AF
      RETURN
*
   END
