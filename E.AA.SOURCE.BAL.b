* @ValidationCode : MjotMTA3Mjg5MTExNDpjcDEyNTI6MTYwMzE5Mjc0MTU2ODp0dmhhcnNoaW5pOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNToyOToyNg==
* @ValidationInfo : Timestamp         : 20 Oct 2020 16:49:01
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : tvharshini
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 26/29 (89.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-14</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.SOURCE.BAL
*
** Enquiry routine to build stmt entry format record to display the accounting
** schema for a product.
** The routine will build R.RECORD in the format of a STMT entry. THis has been
** constructed by the routine AA.BUILD.ACCOUNTING.SCHEMA using the soft accounting
** tables
*
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc> </desc>
*
* 28/10/09 - EN_10004405
*            Ref : SAR-2008-11-06-0009
*            Deposits Infrastructure - Review Activities and Actions
*
*08/09/20 -Enhancement :3956420
*          Task :3956423
*          Changes to fetch SourceType value from AA.PROPERTY
*** </region>
*-----------------------------------------------------------------------------

    $USING AA.ProductManagement
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING EB.SystemTables
    $USING EB.Reports

*
*
** Id is an index number
** Details of the activity, property, action and rule id used are in
** AA.ITEM.REF field
*
    ARR.ID = EB.Reports.getOData()['*',1,1]
    PROPERTY = EB.Reports.getOData()['*',2,1]
    EFF.DATE = EB.SystemTables.getToday()
    STAGE = AA.Framework.Publish
    ARR.REC = ''
    R.SOURCE.CALC.TYPE = ''
    RET.ERR = ''
*
    EB.Reports.setOData('')
    AA.Framework.GetArrangementProduct(ARR.ID, EFF.DATE, ARR.REC,PRODUCT.ID,'')
    IF ARR.REC<AA.Framework.Arrangement.ArrStartDate> GT EFF.DATE THEN          ;*Take this date - for future dated arrangement and get the product
        EFF.DATE = ARR.REC<AA.Framework.Arrangement.ArrStartDate>
        AA.Framework.GetArrangementProduct(ARR.ID, EFF.DATE, ARR.REC,PRODUCT.ID,'')
    END

    AA.ProductFramework.GetProductPropertyRecord("PRODUCT", STAGE, PRODUCT.ID, '', '', '', '', EFF.DATE, R.PRODUCT, READ.ERROR)

    SOURCE.CALC.ID = ""
    LOCATE PROPERTY IN R.PRODUCT<AA.ProductManagement.ProductDesigner.PrdCalcProperty,1> SETTING PROP.POS THEN
        SOURCE.CALC.ID = R.PRODUCT<AA.ProductManagement.ProductDesigner.PrdSourceType,PROP.POS>       ;* Pick the source calc id if found
    END ELSE
        PROPERTY.RECORD = ""    ;*Fetch Source Type from AA.PROPERTY
        AA.Framework.LoadStaticData('F.AA.PROPERTY',PROPERTY,PROPERTY.RECORD, RET.ERROR)
        SOURCE.CALC.ID = PROPERTY.RECORD<AA.ProductFramework.Property.PropSourceType>
    END

    IF SOURCE.CALC.ID THEN
        R.SOURCE.CALC.TYPE = AA.Framework.SourceCalcType.CacheRead(SOURCE.CALC.ID, RET.ERROR)

        IF R.SOURCE.CALC.TYPE<AA.Framework.SourceCalcType.SrcSourceType> EQ "BALANCE" THEN
            EB.Reports.setOData(R.SOURCE.CALC.TYPE<AA.Framework.SourceCalcType.SrcCalcType>)
        END
    END
*
RETURN
END
