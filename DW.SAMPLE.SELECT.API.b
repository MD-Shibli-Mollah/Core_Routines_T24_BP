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
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DW.BiExport
    SUBROUTINE DW.SAMPLE.SELECT.API(biFileName, rDwExport, listOfIdsToBeProcessed)
*______________________________________________________________________________________
*
* Incoming Parameters:
* -------------------
*  biFileName   - Current processing file name like for example: CURRENCY, CATEG.ENTRY
*  rDwExport    - Current file DW.EXPORT record
*
* Outgoing Parameters:
* --------------------
*  listOfIdsToBeProcessed - List of ids selected or to be processed should be returned
*                           Ex: Id1:@FM:Id2:@FM:...:@FM:Idn
*
* Program Description:
* --------------------
*
*______________________________________________________________________________________
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*______________________________________________________________________________________
*

*   /// SELECT API should be written if some specific processing involved or instead of selecting the actual we can select some other files
*   /// and then pass the list of ids to process routine to process it.
*   /// For example, if you want to pass the list of categ entries to Insight only those are raised as of yesterday, then you can select
*   /// CATEG.ENT.LWORK.DAY and build the CATEG ENTRY ids from the selected records id of CATEG.ENT.LWORK.DAY and pass it thro listOfIdsToBeProcessed.
*   /// Or anything to be selected based on the YEAR.MONTH specified in DW Export record (rDwExport<DW.E.YEAR.MONTH>), then we can have SELECT API specific to that.

    GOSUB INITIALISE

*   /// And if the select routine is attached in the DW Export, then that is always called to build CSV files for that file.

    GOSUB BUILD.BASE.LIST

    RETURN
*______________________________________________________________________________________
*
INITIALISE:
*----------

*   /// Open the file biFileName or required files here
    fnBiFileName = 'F.':biFileName
    fBifileName = ''
    CALL OPF(fnBiFileName, fBiFileName)

    RETURN
*______________________________________________________________________________________
*
BUILD.BASE.LIST:
*--------------

*  /// Build the list of ids to be proccessed by selecting the biFileName using Fild marker (@FM) and return to process routine.

    RETURN
END
