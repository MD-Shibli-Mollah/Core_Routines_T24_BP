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

* Version 4 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Display
      SUBROUTINE TXTINP (YTEXT,C2,L2,N1,T1)
REM "TXTINP",850107-001 * combination pgm. TXT and INP
*************************************************************************
*
* 20/05/05 BG_100004220
*          If GTSACTIVE then store the text in OFS.BROWSER.MESSAGES and return
*          The first option as the chosen value
*
* 30/06/03 BG-10004686
*          To enable the relase to work we must check if CHECK.BROWSER
*          has been compiled as in the release process TXTINP will be
*          compiled without the check routine
*
* 18/11/03 CI_10014964
*          CHECK.ROUTINE.EXIST should be called only if running under jbase
*
*************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
*************************************************************************

      BROWSER = ''
      ROUTINE.EXISTS = 0
      ROUTINE.TO.CHECK = "EB.CHECK.BROWSER"
      IF RUNNING.IN.JBASE THEN           ; *CI_10014964 S/E
         CALL CHECK.ROUTINE.EXIST(ROUTINE.TO.CHECK, ROUTINE.EXISTS, '')

         IF ROUTINE.EXISTS THEN
            CALL EB.CHECK.BROWSER(BROWSER, YTEXT, T1)
         END
      END                                ; *CI_10014964 S/E
      IF NOT(BROWSER) THEN               ; * BG_100004220

         CALL TXT( YTEXT )
         CALL INP(YTEXT,C2,L2,N1,T1)
      END
      RETURN
*************************************************************************
   END
