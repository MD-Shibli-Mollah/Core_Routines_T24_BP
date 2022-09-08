* @ValidationCode : MjoxMDg4MDMwNjI0OkNwMTI1MjoxNTY4MTI3Nzg5MTI3OnJkZWVwaWdhOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOC4yMDE5MDcyMy0wMjUxOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Sep 2019 20:33:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190723-0251
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 2 22/06/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>-15</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoReports
    SUBROUTINE E.RATIO
*
************************************************************
*
*     SUBROUTINE TO RETURN ENTITLEMENT RATIO
*
* 22/6/15 - 1322379 Task:1336841
*           Incorporation of components
*
* 04/09/19  - SI: 3172986/ Enhancement:3305142/Task:3305145
*             Additional gaps out of FSD workshops- Handling Rights Event and
*             Share purchase plans with Bonus options
************************************************************
*
    $USING EB.Reports
    $USING EB.ErrorProcessing
    $USING SC.SccEventCapture
    $USING EB.SystemTables

*
******************************************************************
*
    DIARY.ID = EB.Reports.getOData()

    R.DIARY = ''

    R.DIARY = SC.SccEventCapture.Diary.Read(DIARY.ID, tmp.ETEXT)
* Before incorporation : CALL F.READ('F.DIARY',DIARY.ID,R.DIARY,tmp.F.DIARY,tmp.ETEXT)
    IF EB.SystemTables.getEtext() THEN
        EB.Reports.setOData('')
        RETURN
    END
    Y.DIARY.TYPE = R.DIARY<SC.SccEventCapture.Diary.DiaEventType>

    tmp.ETEXT = ''

    tmp.R.DIARY.TYPE = SC.SccEventCapture.DiaryType.Read(Y.DIARY.TYPE, tmp.ETEXT)
* Before incorporation : CALL F.READ('F.DIARY.TYPE',Y.DIARY.TYPE,tmp.R.DIARY.TYPE,tmp.F.DIARY.TYPE,tmp.ETEXT)

    EB.SystemTables.setEtext(tmp.ETEXT)
    IF EB.SystemTables.getEtext() THEN
        EB.Reports.setOData('')
        RETURN
    END
    IF tmp.R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryRights> = 'Y' THEN
        RIGHT.RATIO = R.DIARY<SC.SccEventCapture.Diary.DiaOldRatio,1,1> / R.DIARY<SC.SccEventCapture.Diary.DiaOldToRight,1,1>
        NEW.RATIO = R.DIARY<SC.SccEventCapture.Diary.DiaRightToNew,1,1> / R.DIARY<SC.SccEventCapture.Diary.DiaNewRatio,1,1>
        ACTUAL.RATIO = RIGHT.RATIO * NEW.RATIO
        RATIO = "1:":ACTUAL.RATIO
    END ELSE
        RATIO = ''
    END
*
    EB.Reports.setOData(RATIO)
*
    RETURN
*
*-----
FATAL:
*-----
*
    EB.ErrorProcessing.Err()
    EB.SystemTables.setEtext(EB.SystemTables.getE())
    EB.ErrorProcessing.FatalError('E.RATIO')
*
    END

