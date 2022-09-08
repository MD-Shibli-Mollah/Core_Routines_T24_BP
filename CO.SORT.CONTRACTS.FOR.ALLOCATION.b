* @ValidationCode : MjotMTI4MTM3NDI4NjpDcDEyNTI6MTU5NDA5OTA1MjQ5Njp2a3Jpc2huYXByaXlhOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyMS0wNjU1Oi0xOi0x
* @ValidationInfo : Timestamp         : 07 Jul 2020 10:47:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vkrishnapriya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LI.Collateral
SUBROUTINE CO.SORT.CONTRACTS.FOR.ALLOCATION(limitIds , limitTxns , rLimitTxns , contractIds , sortedContractIds)
*-----------------------------------------------------------------------------
*
* In Arguments:
* limitIds      - Valid Limit ID
* limitTxns     - LIMIT.TXNS id of the incoming limit Id . (eg., limitId.customerId - 100001.100.01.100001)
* rLimitTxns    - LIMIT.TXNS record of the incoming limitId
* contractIds   - Contract Ids of the respective rLimitTxns
*
* Out Arguments:
* sortedContractIds - Contract Ids sorted based on their classification from PV.ASSET.DETAIL
*
* Sorting algorithm follwed - Insertion sort
*---------------------------------------------
* Consider the below scenario:
* Rank array = 10 , 30 , 40 , 20
* Loop - first iteration of OuterInd
* OuterInd = 1 and InnerInd = 2
* rank<1> < rank<2> - The values will be swapped and the array will be 30 , 10 , 40 , 20.
* OuterInd = 1 and InnerInd = 3
* rank<1> < rank<3> - The values will be swapped and the array will be 40 , 10 , 30 , 20.
* OuterInd = 1 and InnerInd = 4
* rank<1> > rank<4>
*
* Loop - second iteration of OuterInd
* OuterInd = 2 and InnerInd = 3
* rank<2> < rank<3> - The values will be swapped and the array will be 40 , 30 , 10 , 20.
* OuterInd = 2 and InnerInd = 4
* rank<2> > rank<4>
*
* Loop - third iteration of OuterInd
* OuterInd = 3 and InnerInd = 4
* rank<3> < rank<4> - The values will be swapped and the array will be 40 , 30 , 20 , 10.
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 03/06/2020 - Enhancement 3768884 / Task 3768875
*              Sample routine to sort the contracts based on PV.ASSET.DETAIL.
*              The sorting here is done based on the ranks of each classification.
*              If more than one contracts have same rank , then insertion sorting is followed.
*              This sample routine is for testing purpose.
*
*-----------------------------------------------------------------------------
    $USING PV.Config
    $USING EB.API
*-----------------------------------------------------------------------------
    GOSUB Initialise ; *Initialise the local variables
    GOSUB Process ; *Get the classification of the looped contract and sort the contracts based on the same
    
RETURN
*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc>Initialise the local variables </desc>

    sortedContractIds = ''    ;* return argument
    contractIdsCount = DCOUNT(contractIds , @FM)
    classRank = ''  ;* Dynamic array to hold the list of ranks from PV.LOAN.CLASSIFICATION
    classId = ''    ;* Dynamic array to hold the list of classifications
    contractsWithNoPv = ''  ;* Dynamic array to hold the list of contract IDs with no PV.ASSET.DETAIL records
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= Process>
Process:
*** <desc>Get the classification of the looped contract and sort the contracts based on the same </desc>

* Loop through each contract Id and read the PV.ASSET.DETAIL.
* Store the respective rank and the contract Id in 2 arrays , later to be used for sorting.
* Rank to be fetched from PV.LOAN.CLASSIFICATION.
    FOR count = 1 TO contractIdsCount
    
        assetDetailId = contractIds<count>
        
        IF assetDetailId[1,2] EQ 'AC' THEN
            assetDetailId = assetDetailId[3,99] ;* PV.ASSET.DETAIL for accounts will not have any prefix
        END
        
        assetDetailRec = ''
        assetDetailErr = ''
        assetDetailRec = PV.Config.AssetDetail.Read(assetDetailId, assetDetailErr)
        
        IF assetDetailErr THEN  ;* Store the rank as 0 , if the contract is not yet classified - for considering the contract Id as the least priority
            classRank<count> = "0"
            classId<count> = contractIds<count>
            CONTINUE
        END
        
        IF assetDetailRec<PV.Config.AssetDetail.PvadManualClass> THEN   ;* Always Manual class is preferred to Auto class
            classification = assetDetailRec<PV.Config.AssetDetail.PvadManualClass>
        END ELSE
            classification = assetDetailRec<PV.Config.AssetDetail.PvadAutoClass>
        END
        
        loanClassificationRec = ''
        loanClassificationErr = ''
        loanClassificationRec = PV.Config.LoanClassification.Read(classification, loanClassificationErr)
        rank = loanClassificationRec<PV.Config.LoanClassification.PvlcRank>
        
        classRank<count> = rank
        classId<count> = contractIds<count>
        
    NEXT count
    
    GOSUB PerformInsertionSorting ; *Perform insertion sort on ranks to return the sorted contract Ids
    
    sortedContractIds = classId

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PerformInsertionSorting>
PerformInsertionSorting:
*** <desc>Perform insertion sort on ranks to return the sorted contract Ids </desc>

* Consider the below scenario:
* Rank array = 10 , 30 , 40 , 20
* Loop - first iteration of OuterInd
* OuterInd = 1 and InnerInd = 2
* rank<1> < rank<2> - The values will be swapped and the array will be 30 , 10 , 40 , 20.
* OuterInd = 1 and InnerInd = 3
* rank<1> < rank<3> - The values will be swapped and the array will be 40 , 10 , 30 , 20.
* OuterInd = 1 and InnerInd = 4
* rank<1> > rank<4>
*
* Loop - second iteration of OuterInd
* OuterInd = 2 and InnerInd = 3
* rank<2> < rank<3> - The values will be swapped and the array will be 40 , 30 , 10 , 20.
* OuterInd = 2 and InnerInd = 4
* rank<2> > rank<4>
*
* Loop - third iteration of OuterInd
* OuterInd = 3 and InnerInd = 4
* rank<3> < rank<4> - The values will be swapped and the array will be 40 , 30 , 20 , 10.
*
* Just as swapping the rank values , the respective contract Ids to also be sorted.

    swapKey1 = 0
    swapKey2 = ''
    FOR OuterInd = 1 TO contractIdsCount
        FOR InnerInd = OuterInd+1 TO contractIdsCount
            IF (classRank<OuterInd> < classRank<InnerInd>) THEN
                swapKey1 = classRank<OuterInd>
                classRank<OuterInd> = classRank<InnerInd>
                classRank<InnerInd> = swapKey1
                
                swapKey2 = classId<OuterInd>
                classId<OuterInd> = classId<InnerInd>
                classId<InnerInd> = swapKey2
            END
        NEXT InnerInd
    NEXT OuterInd
    

RETURN
*** </region>
*-----------------------------------------------------------------------------

END
