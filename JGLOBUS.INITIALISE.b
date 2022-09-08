* @ValidationCode : MjoxMDE0NTQzOTg6Q3AxMjUyOjE1NDI2MjQ1MDQyNjY6cG1haGE6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2Oi0xOi0x
* @ValidationInfo : Timestamp         : 19 Nov 2018 16:18:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : pmaha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 2 29/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-112</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.DatInterface
SUBROUTINE JGLOBUS.INITIALISE
*---------------------------------------------------------------------------------------
*
* Routine to prepare enviromnent for running JGLOBUS.CONVERT and for running jBASE programs
*
* 22/05/01 - GB0101443
*            Add compilation of RG.BP to JGLOBUS.ksh
*
* 13/11/01 - GLOBUS_BG_100000220
*            Correct typo on displayed message (dictionary)
* 13/06/03 - GLOBUS_CI_10009852
*            Instead of SELECTing RG.BP and doing a BASIC and CATALOG
*            The routine RUN.REPGENS should be run first and then
*            the VOC para RUN.ALL.REPGENS has to be executed .
*
* 19/05/04 - BG_100006610
*            Core Routines Performance changes
*
* 23/09/09 - EN_10004355
*            Replace Globus.BP with T24.BP in T24 Server Code
*
* 25/11/2009 - BG_100025913
*              Soft code the folder named T24.BP
*
* 07/11/18 - Enhancement 2822523 / Task 2844861
*          - Incorporation of EB_DatInterface component
*-------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    GOSUB INITIALISATION
    GOSUB BUILD.PROFILE
    GOSUB BUILD.COPY.SCRIPT
    GOSUB BUILD.COMPILE.SCRIPT
    GOSUB COMPILE.JGLOBUS.COPY.JBASE
    GOSUB CREATE.GLOBUS.INITIALISATION.SCRIPT
*
RETURN
*------------------------------------------------------------------------------------
INITIALISATION:
*
    PRINT 'Initialising environment for jBASE use'
    OPEN '&UFD&' TO F.UFD ELSE
        STOP 'Unable to open &UFD&'
    END
*
    PRINT 'Input the full path where jBASE has been installed <Default=/usr/jbc> ': ; INPUT JBCPATH
    IF JBCPATH = "" THEN
        JBCPATH = '/usr/jbc'
    END
*
    PRINT 'Input the path where the source code for JGLOBUS.COPY.JBASE is located <Default=../':T24$BP:'> ': ; INPUT BP.FILE
    IF BP.FILE = "" THEN
        BP.FILE = '../':T24$BP
    END
*
    SHORT.JPROFILE = ''       ;* BG_100006610 - S/E
RETURN
*-----------------------------------------------------------------------------------
BUILD.PROFILE:
* Build and save the standard GLOBUS jBASE profile
*
    EB.DatInterface.JglobusProfile('FULL',JBCPATH,JPROFILE)
    WRITE JPROFILE TO F.UFD, 'jprofile'
*
RETURN
*---------------------------------------------------------------------------------
BUILD.COPY.SCRIPT:
* Build script for invoking the copy of data to the jBASE file
*
    EB.DatInterface.JglobusProfile('SHORT',JBCPATH,JPROFILE)
    SHORT.JPROFILE = JPROFILE ;* BG_100006610 - S/E
    JPROFILE<-1> = 'JGLOBUS.COPY.JBASE $1'        ;* Add on the copy program
    WRITE JPROFILE TO F.UFD, 'jcopy.ksh'
*
RETURN
*-------------------------------------------------------------------------------
BUILD.COMPILE.SCRIPT:
* Build a compile script for JGLOBUS.COPY.JBASE
*
    JPROFILE = SHORT.JPROFILE ;* BG_100006610 - S/E
    JPROFILE<-1> = 'BASIC ':BP.FILE:' JGLOBUS.COPY.JBASE'
    JPROFILE<-1> = 'CATALOG ':BP.FILE:' JGLOBUS.COPY.JBASE'
    WRITE JPROFILE TO F.UFD, 'jcompileJGC.ksh'
RETURN
*----------------------------------------------------------------------------------
COMPILE.JGLOBUS.COPY.JBASE:
* And compile the copy program
*
    EXECUTE "SH -c 'jcompileJGC.ksh'"
*
RETURN
*----------------------------------------------------------------------------------
CREATE.GLOBUS.INITIALISATION.SCRIPT:
* Create a script to be run in the new GLOBUS jBASE areas to copy the globusbin
* & globuslib and to UpdateMD ready for GLOBUS operation.
*
    SCR = ""
    SCR = SHORT.JPROFILE      ;* BG_100006610 - S/E
    SCR<-1> = 'echo Initialise GLOBUS jBASE'
    SCR<-1> = 'echo ======================='
    SCR<-1> = 'echo Please enter the path for the temp.release directory eg: ../../temp.release'
    SCR<-1> = 'read trdir'
    SCR<-1> = 'echo Copying globusbin and globuslib from $trdir'
    SCR<-1> = 'cp -r $trdir/globusbin .'
    SCR<-1> = 'cp -r $trdir/globuslib .'
    SCR<-1> = 'echo Updating VOC for jBASE use'
    SCR<-1> = 'UpdateMD'
    SCR<-1> = 'echo Compiling dictionary I-types for use by jBASE'
    SCR<-1> = 'ICOMP DVOC FULL.TXN.ID HISTORY.ID HISTORY.NUMBER'
    SCR<-1> = 'RECOMP.DESCRP'
    SCR<-1> = 'RUN.REPGENS'   ;* GLOBUS_CI_10009852 S/E
    SCR<-1> = 'echo Initialisation complete'
*
    WRITE SCR TO F.UFD, 'jGLOBUS.ksh'
*
RETURN
*--------------------------------------------------------------------------------
END
