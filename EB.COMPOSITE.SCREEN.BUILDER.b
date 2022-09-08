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
* <Rating>-85</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Toolbox

    SUBROUTINE EB.COMPOSITE.SCREEN.BUILDER(THE.REQUEST, THE.RESPONSE, RESPONSE.TYPE, STYLE.SHEET)
*==================================================================
* This utility routine handles the request from the Composite Screen
* Builder in toolbox.  It validates the ID given by the user and returns
* all information need for the wizard to build it's stages such as the
* languages defined in T24.
*==================================================================
* Modification History:
*
* 03/11/06 -   GLOBUS_EN_10003110
*              When the ID is validated a new tag will be sent that will
*              indicate that the Composite Screen Builder should enable the
*              'No Frames' checkbox.  This will be used to populate the new
*              ATTIBUTES field on EB.COMPOSITE.SCREEN with NO.FRAMES or
*              blank.
*
*==================================================================
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Browser
*==================================================================

    GOSUB INITIALISE
    GOSUB PARSE.MESSAGE
    GOSUB PROCESS.MESSAGE

    RETURN
*==================================================================
INITIALISE:

    OPERATION = ''
    COMPOSITE.SCREEN.ID = ''
    EB.SystemTables.setEtext('')

    RETURN
*==================================================================
PROCESS.MESSAGE:

    BEGIN CASE
        CASE OPERATION = 'VALIDATE.ID'
            GOSUB VALIDATE.ID
        CASE 1
            EB.SystemTables.setEtext('Un-Recognised Operation, Can Not Continue')
            RETURN
    END CASE
*==================================================================
PARSE.MESSAGE:

    EB.Browser.OsGetTagValue(THE.REQUEST, "<OP>", OPERATION)
    EB.Browser.OsGetTagValue(THE.REQUEST, "<CS.ID>", COMPOSITE.SCREEN.ID )

    RETURN
*==================================================================
VALIDATE.ID:

*CHECK SCREEN IS NOT ON LIVE FILE
    R.DATA = ''
    F.READ.ERROR = ''

    R.DATA = EB.SystemTables.CompositeScreen.Read(COMPOSITE.SCREEN.ID, F.READ.ERROR)

    IF EB.SystemTables.getEtext() THEN
        RETURN
    END

    IF R.DATA THEN
        EB.SystemTables.setEtext('EB-REC.ALREADY.EXISTS')
        RETURN
    END

*CHECK SCREEN IS NOT ON UNAUTHORISED FILE
    R.DATA = ''
    F.READ.ERROR = ''

    R.DATA = EB.SystemTables.CompositeScreen.Read(COMPOSITE.SCREEN.ID, F.READ.ERROR)

    IF EB.SystemTables.getEtext() THEN
        RETURN
    END

    IF R.DATA THEN
        EB.SystemTables.setEtext('EB-REC.ALREADY.EXISTS')
        RETURN
    END

    GOSUB GET.SYSTEM.LANGS

* GLOBUS_EN_1000310 s
    ENABLE.SCREEN.ATTRIBUTES = '<enableCSAttributes>TRUE</enableCSAttributes>'

    THE.RESPONSE = '<CSBUILDER>':SYS.LANGS : ENABLE.SCREEN.ATTRIBUTES :'</CSBUILDER>'
* GLOBUS_EN_1000310 e

    RETURN
*==================================================================
GET.SYSTEM.LANGS:
*Get the Languages set-up in the system

    R.LANGS = ''
    FN.LANGUAGE = 'F.LANGUAGE'
    F.LANGUAGE = ''
    THE.LANGS = ''
    SYS.LANGS = ''

    EB.DataAccess.Opf(FN.LANGUAGE,F.LANGUAGE)

    EB.DataAccess.Readlist("SELECT ": FN.LANGUAGE,LANG.IDS, ID.LIST ,NO.RECS ,RET.CODE)

    LOOP
        READNEXT CURR.ID FROM LANG.IDS ELSE
            CURR.ID = ''
        END

    UNTIL CURR.ID = ''

        READ R.LANGS FROM F.LANGUAGE, CURR.ID ELSE
            R.LANGS = ''
        END

        LAN.MNE = R.LANGS<EB.SystemTables.Language.LanMnemonic>
        LAN.DESC = R.LANGS<EB.SystemTables.Language.LanDescription>

        THE.LANGS := '<LNG><LC>':CURR.ID:'</LC><DESC>':LAN.DESC:'</DESC></LNG>'
    REPEAT

    SYS.LANGS = '<LNGS>':THE.LANGS:'</LNGS>'

    RETURN
