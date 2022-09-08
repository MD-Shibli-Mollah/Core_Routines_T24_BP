* @ValidationCode : MjotODgxNTYzMjMwOmNwMTI1MjoxNjA0NDA5NzQyMDYxOm1ha3NoYXlhOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNy4yMDIwMDcwMS0wNjU3Oi0xOi0x
* @ValidationInfo : Timestamp         : 03 Nov 2020 18:52:22
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : makshaya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE CZ.ErasureProcess
SUBROUTINE CZ.GET.AA.DETAILS(ContractId,SubtableId,FileType,IdList,Reserved)
*-----------------------------------------------------------------------------
*Sample API to return the AA tables related to AA contract
*when attached in MASTER.LINK.TYPE in PDD
*ARGUMENTS:
*IN:
*ContractId    -   Contains AA account id
*SubtableId    -   either AA.ARR.CUSTOMER or AA.ARRANGEMENT
*FileType      -   contains the fileType to which the account belongs to($HIS,$ARC or NULL in case of LIVE)
*OUT:
*IdList        -   Returns the id related to the AA account
*Reserved      -   for future use
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 30/10/2020 -Task 4024801
*             API to retrieve AA.ARR.CUSTOMER and AA.ARRANGEMENT.ACTIVITY ids
*             when attached in MasterLinkType in PDD
*
*-----------------------------------------------------------------------------
    $USING EB.API
    $USING EB.DataAccess
    $USING AC.AccountOpening
    $USING EB.SystemTables

    GOSUB Initialise ; *
    GOSUB Process ; *
RETURN
*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc> </desc>

    AAInstalled = @FALSE
    EB.API.ProductIsInCompany('AA', AAInstalled) ;* Check if AA is installed
    IF NOT(AAInstalled) THEN
        RETURN
    END
    GOSUB ReadAccount ; *
  
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= Process>
Process:
*** <desc> </desc>

    BEGIN CASE
        CASE SubtableId EQ "AA.ARRANGEMENT.ACTIVITY"
            GOSUB ReturnAAAid ; *
        
        CASE SubtableId EQ "AA.ARR.CUSTOMER"
            GOSUB ReturnArrCustomer ; *

    END CASE

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= ReturnArrCustomer>
ReturnArrCustomer:
*** <desc> </desc>
    Appln = SubtableId
    
    IF FileType THEN ;*for type other than LIVE
        reqOption = '$':FileType
    END ELSE
        reqOption = FileType
    END
    
    GOSUB OPFRec ; *to check if the record is present wrt the corresponding reqoption
    IF EB.SystemTables.getEtext() THEN ;* if there is no such file, then return
        RETURN
    END
    SelCmd ="SELECT ":Fileid:" WITH @ID LIKE ":arrId:"-..."
    GOSUB executeSelCmd ; *to call EB.READLIST
 
        
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= ReadAccount>
ReadAccount:
*** <desc> </desc>
      
    Rec = ''
    Appln = "ACCOUNT"
    GOSUB OPFRec ; *to check if the record is present wrt the corresponding reqoption

    IF EB.SystemTables.getEtext() THEN ;* if there is no such file, then return
        RETURN
    END
    Vkey = ContractId
    Er = ''
    reqOption = ''

    EB.DataAccess.FRead(Fileid, Vkey, Rec, FFileid, Er)
    IF Er THEN
        reqOption = '$HIS'
        GOSUB OPFRec
        EB.DataAccess.ReadHistoryRec(FFileid, Vkey, Rec, Er)
        
    END
 
    arrId = Rec<AC.AccountOpening.Account.ArrangementId>
        
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= OPFRec>
OPFRec:
*** <desc>to check if the record is present wrt the corresponding reqoption </desc>
    Er = ''
    Fileid = 'F.':Appln:reqOption:@FM:'NO.FATAL.ERROR'
    FFileid = ''
    EB.DataAccess.Opf(Fileid, FFileid)
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= executeSelCmd>
executeSelCmd:
*** <desc>to call EB.READLIST </desc>
                

    keyList = "" ;*holds the Ids like AA.ARR.ACCOUNT Ids
    ListName = ""
    Selected = ""
    SystemReturnCode = ""
    EB.DataAccess.Readlist(SelCmd, keyList, ListName, Selected, SystemReturnCode) ;*get all the ids
    IF keyList THEN
        IdList<-1> = keyList ;*append the ids
    END
RETURN


*-----------------------------------------------------------------------------

*** <region name= ReturnAAAid>
ReturnAAAid:
*** <desc> </desc>

    Appln = SubtableId
    
    IF FileType THEN
        reqOption = '$':FileType
    END ELSE
        reqOption = FileType
    END
    
    GOSUB OPFRec ; *to check if the record is present wrt the corresponding reqoption
    IF EB.SystemTables.getEtext() THEN ;* if there is no such file, then return
        RETURN
    END
    SelCmd ="SELECT ":Fileid:" WITH ARRANGEMENT EQ ":arrId
    GOSUB executeSelCmd ; *to call EB.READLIST
      
    
RETURN
*** </region>

END





