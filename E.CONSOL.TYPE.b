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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-18</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.CONSOL.TYPE
*-------------------------------------------------
*
* This subroutine will be used to split the
* the Consol.Key.Type into the Consol.Key and
* the Asset.Type
*
* The fields used are as follows:-
*
* INPUT O.DATA         containing the key
*
*
* OUTOUT O.DATA           Split into two multivalues to first
*                         containing the CRF key. The second
*                         containing the Asset.Type.
*
*-------------------------------------------------Insert statements
    $USING EB.Reports
*-------------------------------------------------------

    CON.KEY = EB.Reports.getOData()
    COUNT.DOT = COUNT(CON.KEY,".")
    COUNT.DOT.TYPE = COUNT.DOT + 1
    OUTPUT = FIELD(CON.KEY,'.',1,COUNT.DOT)
    OUTPUT := '\'
    OUTPUT := FIELD(CON.KEY,'.',COUNT.DOT.TYPE)
    EB.Reports.setOData(OUTPUT)

PROG.EXIT:
    RETURN
*-----------------------------------------------------------------------------
    END
