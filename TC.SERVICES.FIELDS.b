* @ValidationCode : MjotMTk3NDk3MTUxNTpDcDEyNTI6MTU0NDA4MTgyMDE5NTpydGFuYXNlOi0xOi0xOjA6MTp0cnVlOk4vQTpERVZfMjAxODEyLjIwMTgxMTIzLTEzMTk6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Dec 2018 09:37:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rtanase
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE TC.SERVICES.FIELDS
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Template
*-----------------------------------------------------------------------------
* Description:
* Field Definition for TC.SERVICES application
*-----------------------------------------------------------------------------
* Modification History:
**
* 03/10/2016 - Enhancement 1812222 / Task 1905849
*              Tc Services and Operations
* 16/06/2017 - Defect 2012008 / Task 2184329
*              XX<SV.RESERVED.5 multivalue set wasn't properly opened
* 29/10/2018 - Defect 2830003 / Task 2830193
*              TC.SERVICES record is missing Administration as dependency
*              To not be thrown error when an operation of a TC.SERVICES record is containing dependency on another operation of the same TC.SERVICES record
*-----------------------------------------------------------------------------
    Temp.Str = EB.Template.T24String
    Temp.FieldMandatory = EB.Template.FieldMandatory

    EB.Template.TableDefineid("TC.SVC.ID", Temp.Str) ;* Define Table id
*
    EB.Template.TableAddfield("XX.LL.DESCRIPTION",Temp.Str,Temp.FieldMandatory,'')
    options='_Yes'
    EB.Template.TableAddoptionsfield("MANDATORY.SVC", options,'', '')
    EB.Template.TableAddfield("XX<OPERATION", Temp.Str ,Temp.FieldMandatory,'')        ;* Add a new fields
    EB.Template.TableAddfield("XX-OPERATION.DESC", Temp.Str,Temp.FieldMandatory,'') ;* Add a new fields
    options = "_Yes"
    EB.Template.TableAddoptionsfield("XX-MANDATORY.OPS", options,'', '')
    options='VERSION_ENQUIRY'
    EB.Template.TableAddoptionsfield("XX-RECORD.TYPE",options,'', '')
    EB.Template.TableAddfield("XX-RECORD.NAME",Temp.Str,'','')
    EB.Template.TableAddfield("XX-RESTRICTION",Temp.Str,'','')
    EB.Template.TableAddfield("XX-XX<DEPENDENT.SVC",Temp.Str,'','')
    EB.Template.TableAddfield("XX>XX>DEPENDENT.OPS",Temp.Str,'','')
    EB.Template.TableAddfield("USER.SMS.GROUP",Temp.Str,'','')
    options = "_Yes"
    EB.Template.TableAddoptionsfield("AUTO.GEN.SMS.GRP",options,'', '')
*
    EB.Template.TableAddlocalreferencefield("")
    EB.Template.TableAddoverridefield()
*
    EB.Template.TableAddreservedfield("XX<SV.RESERVED.5")
    EB.Template.TableAddreservedfield("XX-SV.RESERVED.4")
    EB.Template.TableAddreservedfield("XX-SV.RESERVED.3")
    EB.Template.TableAddreservedfield("XX-SV.RESERVED.2")
    EB.Template.TableAddreservedfield("XX>SV.RESERVED.1")
*
    EB.Template.TableAddreservedfield("RESERVED.5")
    EB.Template.TableAddreservedfield("RESERVED.4")
    EB.Template.TableAddreservedfield("RESERVED.3")
    EB.Template.TableAddreservedfield("RESERVED.2")
    EB.Template.TableAddreservedfield("RESERVED.1")
*-----------------------------------------------------------------------------
    EB.Template.TableSetauditposition()    ;* Poputale audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
END
