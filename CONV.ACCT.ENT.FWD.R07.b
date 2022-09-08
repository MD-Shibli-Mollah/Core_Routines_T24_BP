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
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.CashFlow
      SUBROUTINE CONV.ACCT.ENT.FWD.R07
*______________________________________________________________________________________
*
* This conversion routine is for online value dated suspense enhancement, after this
* developement all the value date entries and suspense entries id will be updated in
* ACCT.ENT.TODAY directly and no more updation in ACCT.ENT.FWD for value dated suspense
* processing. So this routine will write existing ACCT.ENT.FWD records into ACCT.ENT.
* TODAY file and will raise all the necessary value dated entries, suspense entries and
* self balancing entries. This process have been done through the job EOD.AC.CONV.ENTRY,
* so to trigger that we are updating the AC.CONV.ENTRY file with dummy record of
* VDSUSPENSE for each company.
*______________________________________________________________________________________
*
* Modification logs:
* -----------------
* 27/07/06 - GLOBUS_EN_10003005
*            New routine
*______________________________________________________________________________________
*
$INSERT I_COMMON
$INSERT I_EQUATE
*______________________________________________________________________________________
*
*** <region name= Main Process>
***
      SEL.CMD = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
      COMPANY.LIST = ''
      CALL EB.READLIST(SEL.CMD, COMPANY.LIST ,'' , '' , '')

      IDX = 0
      SAVE.CO.CODE = ID.COMPANY
      LOOP
         IDX += 1
         COMP.ID = COMPANY.LIST<IDX>
      WHILE COMP.ID DO

         GOSUB CALL.LOAD.COMPANY
         GOSUB INITIALISE                                ;* Initialise and open files here

         DUMMY = ''
         WRITE DUMMY ON F.AC.CONV.ENTRY, "VDSUSPENSE"

      REPEAT

      COMP.ID = SAVE.CO.CODE
      GOSUB CALL.LOAD.COMPANY

      RETURN
*** </region>
*______________________________________________________________________________________
*
*** <region name= INITIALISE>
INITIALISE:
*----------

      FN.AC.CONV.ENTRY = 'F.AC.CONV.ENTRY'
      F.AC.CONV.ENTRY = ''
      CALL OPF(FN.AC.CONV.ENTRY,F.AC.CONV.ENTRY)

      RETURN
*** </region>
*______________________________________________________________________________________
*
*** <region name= CALL.LOAD.COMPANY>
CALL.LOAD.COMPANY:
*-----------------
      IF COMP.ID <> ID.COMPANY THEN
         CALL LOAD.COMPANY(COMP.ID)
      END

      RETURN
*** </region>
   END
