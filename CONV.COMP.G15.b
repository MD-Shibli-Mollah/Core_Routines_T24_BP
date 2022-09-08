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

* Version n dd/mm/yy  GLOBUS Release No. G15.0.04 29/11/04
*-----------------------------------------------------------------------------
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.CompanyCreation
    SUBROUTINE CONV.COMP.G15(ID,REC,FILE)
*******************************************************
*
* 06/04/05 - CI_10028993
*            put code in to correct existing emc accounts (normally test accounts)
*
* 05/11/08 - CI_10058734
*            Enure that the "FIN.FILE" record in COMPANY.CHECK is created if it is missing
*******************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.INTERCO.PARAMETER
    $INSERT I_F.COMPANY.CHECK
*
    IF REC<11> NE "N" THEN    ;* Consolidation company
        RETURN
    END

    FIN.FILE.MISS = ''

    R.COMP.CHK = ''
    CALL CACHE.READ("F.COMPANY.CHECK","FIN.FILE",R.COMP.CHK,ER)

    IF R.COMP.CHK THEN
        GOSUB CHECK.EXISTING.RECORD
    END ELSE
        FIN.FILE.MISS = 1
    END

* we should be in a clean single or multi company site, or a site with only 1 lead company

    IF REC<64> = "" AND REC<65> = "" THEN         ;* If we can open the account file then we have a lead company
        FN.ACCOUNT = "F":REC<3>:".ACCOUNT" ; F.ACCOUNT = ""
        OPEN FN.ACCOUNT TO F.ACCOUNT THEN         ;* Lead company
            REC<64> = ID
            REC<65> = REC<3>
        END ELSE    ;* we are assuming that this is the first run with only 1 lead company
            REC<64> = REC<34> ;*  FIN comp set to nostro comp
            REC<65> = REC<35> ;* FIN MNE set to nostro mne
            REC<55> = 1       ;* BOOK field
        END
    END

    LEAD.CO = ''
    IF FIN.FILE.MISS AND FIELD(ID,';',2) EQ '' THEN
        LEAD.CO = REC<64>
        GOSUB UPDATE.COMP.CHECK
    END
    RETURN
*--------------------------------------------------------------------------------------------------
CHECK.EXISTING.RECORD:        * This should make sure the company records are correctly set

    LOCATE ID IN R.COMP.CHK<EB.COC.COMPANY.CODE,1> SETTING POS THEN   ;* Lead company
        IF REC<64> NE ID THEN
            REC<64> = ID
            REC<65> = REC<3>
            IF R.COMP.CHK<EB.COC.USING.COM,POS> NE "" THEN  ;* lead company with branches
                REC<55> = 1
            END
        END
    END ELSE        ;* should be a branch
        LEAD.COS = DCOUNT(R.COMP.CHK<EB.COC.COMPANY.CODE>,FM)
        FOR I = 1 TO LEAD.COS
            LOCATE ID IN R.COMP.CHK<EB.COC.USING.COM,I,1> SETTING POS THEN
                REC<64> = R.COMP.CHK<EB.COC.COMPANY.CODE,I>
                REC<65> = R.COMP.CHK<EB.COC.COMPANY.MNE,I>
                REC<55> = 1
                EXIT
            END
        NEXT I
    END
    RETURN
*------------------------------------------------------------------------------------------------------
UPDATE.COMP.CHECK:
*=================
    ER = ""
    R.COMP.CHK = ''
    CALL F.READU("F.COMPANY.CHECK","FIN.FILE",R.COMP.CHK,F.COMPANY.CHECK,ER,"")
    IF ER <> "" THEN
        R.COMP.CHK = ""
    END
    LEAD.POS  = ''
    LOCATE LEAD.CO IN R.COMP.CHK<EB.COC.COMPANY.CODE,1> SETTING LEAD.POS ELSE
        R.COMP.CHK<EB.COC.COMPANY.CODE,LEAD.POS> = REC<64>
        R.COMP.CHK<EB.COC.COMPANY.MNE,LEAD.POS> = REC<65>
    END

    USG.POS = ''
    IF R.COMP.CHK<EB.COC.COMPANY.CODE,LEAD.POS> <> ID THEN
        LOCATE ID IN R.COMP.CHK<EB.COC.USING.COM,LEAD.POS,1> SETTING USG.POS ELSE
            R.COMP.CHK<EB.COC.USING.COM,LEAD.POS,USG.POS> = ID
            R.COMP.CHK<EB.COC.USING.MNE,LEAD.POS,USG.POS> = REC<3>
        END
    END
    CALL F.WRITE("F.COMPANY.CHECK", 'FIN.FILE', R.COMP.CHK)
    RETURN
*--------------------------------------------------------------------------------------
END
