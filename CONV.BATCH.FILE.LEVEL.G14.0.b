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
* <Rating>1290</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Service
    SUBROUTINE CONV.BATCH.FILE.LEVEL.G14.0
*
****************************************************************************
* Modifications
*
* 26/08/03 - BG_100005037
*            If there is an existing unauthorised record then
*            ignore conversion
*
* 18/02/04 - CI_10017463
*            While copying the master company batch record to
*            the other company record, the unauthorised
*            master company batch record with new changes
*            is ignored.
*
* 01/03/05 - BG_100008230
*           Conversion for batch record CRF.SELF.BAL.UPD
*
* 11/01/07 - CI_10046613
*            The above fix fails when the conversion occurs in the interim cut
*            like 200612.001
*            Ref: TTS0705380
****************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BATCH
    $INSERT I_F.COMPANY
    $INSERT I_F.COMPANY.CHECK
*
* This convrsion will create DATE.CHANGE batch records
* in each company in a multi-co site. The job has moved
* from INT to FIN.
*
    F.BATCH = ''
    CALL OPF("F.BATCH", F.BATCH)
    F.BATCH$HIS = ""
    CALL OPF("F.BATCH$HIS", F.BATCH$HIS)

* BG_100005037 S
    F.BATCH$NAU = ''
    CALL OPF("F.BATCH$NAU", F.BATCH$NAU)
* BG_100005037 E

    F.COMPANY = ''
    CALL OPF("F.COMPANY", F.COMPANY)
    F.COMPANY.CHECK = ''
    CALL OPF("F.COMPANY.CHECK", F.COMPANY.CHECK)
*
    MASTER.CO.REC = ''
    READ MASTER.CO.REC FROM F.COMPANY.CHECK, "MASTER" ELSE MASTER.CO.REC = ''
    MASTER.CO.MNE = MASTER.CO.REC<EB.COC.COMPANY.MNE>
    IF MASTER.CO.MNE = '' THEN MASTER.CO.MNE = "BNK"
*
    ID.LIST = "PURGE.HOLD.RPTS":FM:"CRF.SELF.BAL.UPD":FM:"EOD.CUST.CHARGE"
*
    TIME.STAMP = TIMEDATE()
    X = OCONV(DATE(),"D-")
    X = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]          ;* Date time for Write
*
    LOOP
        REMOVE BATCH.ID FROM ID.LIST SETTING YD
    WHILE BATCH.ID:YD
        MAIN.BATCH = '' ; R.MAIN.BATCH = '' ; R.MAIN.NAU.BATCH = ''
        READ R.MAIN.BATCH FROM F.BATCH, BATCH.ID ELSE       ;* Single record exists so no need to convert
*
            READ R.MAIN.BATCH FROM F.BATCH, MASTER.CO.MNE:"/":BATCH.ID THEN
                READ R.MAIN.NAU.BATCH FROM F.BATCH$NAU, MASTER.CO.MNE:"/":BATCH.ID ELSE R.MAIN.NAU.BATCH = '' ;* CI_10017463
*
** Convert to each company
*
                SEL.STMT = "SELECT F.COMPANY WITH CONSOLIDATION.MARK NE 'C'"
                CO.LIST = ""
                NO.SEL = ''
                CALL EB.READLIST(SEL.STMT, CO.LIST, "", NO.SEL, "")
*
                IF NO.SEL GT 1 THEN     ;* If 1 it is single company
                    LOOP
                        REMOVE CO.CODE FROM CO.LIST SETTING YD
                    WHILE CO.CODE:YD
                        IF CO.CODE NE ID.COMPANY THEN
                            READ COMP.REC FROM F.COMPANY, CO.CODE THEN ELSE COMP.REC = ''
                        END ELSE
                            MATBUILD COMP.REC FROM R.COMPANY
                        END
                        COMP.MNE = COMP.REC<3>    ;* Company mnemonic
                        IF COMP.REC<33> = COMP.MNE THEN     ;* Only create for non shared FIN files FINAN.FINAN.MNE
                            IF COMP.MNE THEN
                                NEW.COMP.ID = COMP.MNE:"/":BATCH.ID

* BG_100005037 S
* If there is an existing unauthorised record the  don't do anything
                                R.NAU.BATCH = ""
                                READ R.NAU.BATCH FROM F.BATCH$NAU, NEW.COMP.ID ELSE R.NAU.BATCH = ""
                                IF R.NAU.BATCH = "" THEN
* BG_100005037 E
                                    GOSUB UPDATE.BATCH.RECORD         ;* CI_10017463
                                END
                            END
                        END
                    REPEAT

                END
            END
        END
    REPEAT

    RETURN

*--------------
UPDATE.BATCH.RECORD:
*--------------

* If there exits a unauthorised mater company batch record
* then copy the record to the other company
    READ NEW.BATCH.REC FROM F.BATCH, NEW.COMP.ID ELSE
        IF (R.MAIN.NAU.BATCH<16> EQ "INAU") AND (R.MAIN.NAU.BATCH<18> MATCHES "'1_G1'0X":@VM:"'1_R'0X":@VM:"'1_'6N0X") THEN       ;* BG_100008230
            NEW.BATCH.REC = R.MAIN.NAU.BATCH
            NEW.BATCH.REC<17> = 1
            NEW.BATCH.REC<18> = "SY_CONV.BATCH.LEVEL.G14.0" ;* Inputter
            NEW.BATCH.REC<19> = X       ;* Date Time
            NEW.BATCH.REC<21> = CO.CODE ;* Company Code
            WRITE NEW.BATCH.REC TO F.BATCH$NAU, NEW.COMP.ID
        END ELSE

            NEW.BATCH.REC = R.MAIN.BATCH
            NEW.BATCH.REC<17> = 1       ;* Curr No
            NEW.BATCH.REC<18> = "SY_CONV.BATCH.LEVEL.G14.0" ;* Inputter
            NEW.BATCH.REC<19> = X       ;* Date Time
            NEW.BATCH.REC<20> = TNO:"_":OPERATOR  ;* Author
            NEW.BATCH.REC<21> = CO.CODE ;* Company Code
            WRITE NEW.BATCH.REC TO F.BATCH, NEW.COMP.ID
        END
    END

    RETURN

END
