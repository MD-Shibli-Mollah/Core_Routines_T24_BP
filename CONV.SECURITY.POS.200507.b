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

* Version 3 02/06/00  GLOBUS Release No. G15.0.01 31/08/04
*-----------------------------------------------------------------------------
* <Rating>98</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityPositionUpdate
    SUBROUTINE CONV.SECURITY.POS.200507(ID,RECORD,FILENAME)
*-----------------------------------------------------------------------------
* Record routine for conversion details CONV.SECURITY.POSITION.200507
* will populate field FIN.COMPANY (81).
*-----------------------------------------------------------------------------
* Modification History :
*
* 06/04/05 - GLOBUS_EN_10002471
*            New program
*
* 05/02/08 - GLOBUS_CI_10053569
*            Common variables defined in PRE.ROUTINE is not distributed
*            across multiple threads as PRE.ROUTINE is run only in a single thread,
*            hence system crashes while using these common variables.
*
* 30/04/08 - GLOBUS_CI_10055091
*            FIN.COMPANY field of SECURITY.POSITION points to the lead company
*            for Branch Company after upgrade
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_CONV.SECURITY.POS.200507.COMMON
*-----------------------------------------------------------------------------

    IF NOT(ALREADY.INVOKED) THEN
        CALL CONV.SECURITY.POS.200507.PRE
        ALREADY.INVOKED = 1
    END

    IF RECORD<81> = '' AND RECORD<1>[4] NE 777 AND RECORD<1>[4] NE 999 THEN
* fin.company is not populated, and it's not a broker position, and its not
* a depository position
        ID.SEC.ACC.MASTER = RECORD<1>
        FOR CNT = 1 TO NO.OF.COMPANIES UNTIL RECORD<81> NE ''
            F.FILE.NAME = COMPANY.LIST<2,CNT>
            F.FILE.VAR = SEC.ACC.MASTER.FILES(CNT)
            ER = ''
            CALL F.READ(F.FILE.NAME,ID.SEC.ACC.MASTER,R.SEC.ACC.MASTER,F.FILE.VAR,ER)
            IF ER = '' THEN
                PORT.COMP.ID = R.SEC.ACC.MASTER<104>
                IF PORT.COMP.ID = '' THEN
                    PORT.COMP.ID = R.SEC.ACC.MASTER<125>
                END
                IF PORT.COMP.ID = '' THEN
                    PORT.COMP.ID = COMPANY.LIST<1,CNT>
                END
                RECORD<81> = PORT.COMP.ID
            END
        NEXT CNT
    END

    RETURN


END
