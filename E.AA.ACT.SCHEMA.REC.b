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
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.ACT.SCHEMA.REC
*
* Routine that updates the fields of standard selection for
* Nofile enquiry

    $USING EB.Reports
    

    COMMON/AASCHEMA/PROP.ACT.LIST

    ITEM.NO = EB.Reports.getOData()
    tmp=EB.Reports.getRRecord(); tmp<1>=PROP.ACT.LIST<ITEM.NO>['~',1,1]; EB.Reports.setRRecord(tmp)
    TMP.LIST = PROP.ACT.LIST<ITEM.NO>['~',2,1]
    tmp=EB.Reports.getRRecord(); tmp<2>=TMP.LIST['@',1,1]; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<3>=TMP.LIST['@',2,1]; EB.Reports.setRRecord(tmp)
    EB.Reports.setVmCount(DCOUNT(EB.Reports.getRRecord()<2>,@VM));*Set the common variable for enquiry - so that fields declared Mutli will be displayed properly

    RETURN

END
