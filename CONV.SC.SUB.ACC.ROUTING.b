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
* <Rating>111</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctDepoSubAccount
      SUBROUTINE CONV.SC.SUB.ACC.ROUTING
*-----------------------------------------------------------------------------
* Modification History:
*
* 10/10/2003 - BG_100005373
*              NULL a token in SELECT stmt was not identified by
*              uniVerse
*
* 09/08/05 - GLOBUS_BG_100009242
*            Incorrect use of file insert, these cannot be used in conversions.
*            Don't use conditions in select, SS may be out of date.
*            Only update field if current field is blank.
*            Routine must also handle the various companies itself.
*-----------------------------------------------------------------------------
$INSERT I_EQUATE
$INSERT I_COMMON
$INSERT I_F.COMPANY.CHECK   ; * BG_100009242

* Get all the company ids that hold the Customer files.
      FN.COMPANY.CHECK = 'F.COMPANY.CHECK'   ; * BG_100009242 s
      F.COMPANY.CHECK = ''
      CALL OPF(FN.COMPANY.CHECK,F.COMPANY.CHECK)   ; * BG_100009242 e

      R.COMPANY.CHECK = ''   ; * BG_100009242 s
      YERR = ''
      COMPANY.CHECK.ID = 'CUSTOMER'
      CALL F.READ(FN.COMPANY.CHECK,COMPANY.CHECK.ID,R.COMPANY.CHECK,F.COMPANY.CHECK,YERR)
      COMPANY.LIST = R.COMPANY.CHECK<EB.COC.COMPANY.CODE>   ; * BG_100009242 e

* process each of the companies concerned
      SAVE.COMPANY = ID.COMPANY   ; * BG_100009242 s
      LOOP
         REMOVE YCOMPANY.CODE FROM COMPANY.LIST SETTING MORE.COMPANIES
      WHILE YCOMPANY.CODE:MORE.COMPANIES
         IF YCOMPANY.CODE NE ID.COMPANY THEN
            CALL LOAD.COMPANY(YCOMPANY.CODE)
         END
         GOSUB CONVERT.FILE
      REPEAT

      IF ID.COMPANY NE SAVE.COMPANY THEN
         CALL LOAD.COMPANY(SAVE.COMPANY)
      END

      RETURN   ; * BG_100009242 e

*-----------------------------------------------------------------------------
CONVERT.FILE:
* BG_100009242
* Do the actual file conversion process.

* Open file, no fatal in case securities is not installed
      FN.SC.SUB.ACC.ROUTING = 'F.SC.SUB.ACC.ROUTING':FM:'NO.FATAL.ERROR'   ; * BG_100009242
      F.SC.SUB.ACC.ROUTING = ''   ; * BG_100009242
      CALL OPF(FN.SC.SUB.ACC.ROUTING,F.SC.SUB.ACC.ROUTING)   ; * BG_10009242

      IF ETEXT = '' THEN   ; * BG_100009242
* file exists as SC is installed in this company, so perform conversion

         APP.FIELD = 6   ; * BG_100009242
         APP.APPLI = 5   ; * BG_100009242

         SEL.CMD = 'SELECT ':FN.SC.SUB.ACC.ROUTING   ; * BG_100009242
         SEL.LIST = ''   ; * BG_100009242
         CALL EB.READLIST(SEL.CMD,SEL.LIST,'','','')

         LOOP
            REMOVE ROUTING.ID FROM SEL.LIST SETTING POS
         WHILE ROUTING.ID:POS
            R.SC.SUB.ACC.ROUTING = ''   ; * BG_100009242
            CALL F.READ(FN.SC.SUB.ACC.ROUTING,ROUTING.ID,R.SC.SUB.ACC.ROUTING,F.SC.SUB.ACC.ROUTING,ER)
            NO.SUB.ACC = DCOUNT(R.SC.SUB.ACC.ROUTING<APP.FIELD>,VM)   ; * BG_100009242 s
            IF NO.SUB.ACC < 1 THEN
               NO.SUB.ACC = 1
            END   ; * BG_100009242 e
            FOR I =1 TO NO.SUB.ACC
               NO.COND  = DCOUNT(R.SC.SUB.ACC.ROUTING<APP.FIELD,I>,SM)   ; * BG_100009242 s
               IF NO.COND < 1 THEN
                  NO.COND = 1
               END   ; * BG_100009242 e
               FOR J = 1 TO NO.COND
                  IF R.SC.SUB.ACC.ROUTING<APP.FIELD,I,J> NE '' AND R.SC.SUB.ACC.ROUTING<APP.APPLI,I,J> = '' THEN   ; * BG_100009242
                     R.SC.SUB.ACC.ROUTING<APP.APPLI,I,J> = 'CUSTOMER'
                  END
               NEXT J
            NEXT I
            CALL F.WRITE(FN.SC.SUB.ACC.ROUTING,ROUTING.ID,R.SC.SUB.ACC.ROUTING)
         REPEAT

         CALL JOURNAL.UPDATE("")   ; * BG_100009242
      END ELSE   ; * BG_100009242 s
* file cannot be opended, no SC so ignore but set error back to null.
         ETEXT = ''
      END   ; * BG_100009242 e

      RETURN

   END
