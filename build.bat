@echo off
REM ##########################################
REM  Make sure you have 700511823.iso in the current directory.  (no space in the absolute path)
REM  Make sure you have apache-ant-1.9.7-bin.zip in current directory (no space in the absolute path)
REM  Setup your 7 Zip installation path
REM  Setup your JAVA_HOME path as below.
REM  Open command prompt
REM  CD to the current directory
REM  run  build.bat
REM copy dist/EventService-5.1.0.jar into you project
REM copy \v_pdssdk\jacorb\jacorb.properties into your project (must in the class path)
REM copy \v_pdssdk\jacorb\orb.properties into your project (must in the class path)
REM copy \v_pdssdk\keystore\jacorb into your project if you are using SSL.
REM setup the keystore file path in jacorb.properties
REM ##########################################

SET SEVEN_ZIP=C:\Program Files\7-Zip
SET JAVA_HOME=C:\Program Files (x86)\Java\jdk1.6.0_45

SET SDK_ISO=700511823.iso
SET JACORB_ZIP=jacorb-2.3.1-src.zip

REM pre-check if required files exist

SET SYS_PATH=%PATH%
SET BASE_DIR=%CD%
SET SDK_HOME=%BASE_DIR%\v_pdssdk
SET JACORB_HOME=%SDK_HOME%\jacorb\jacorb-2.3.1
SET SOURCE_DIR=%SDK_HOME%\EventService\v51_0\Java
SET OUTPUT_DIR=%SDK_HOME%\dist
REM ###########################################################
SET PATH=%PATH%;%SEVEN_ZIP%
REM Start Extract the v_pdssdk
if not exist %BASE_DIR%\v_pdssdk 7z x %SDK_ISO%
REM Start Extract the jacorb-2.3.1
if not exist %JACORB_HOME% 7z x %SDK_HOME%\jacorb\%JACORB_ZIP% -o%SDK_HOME%\jacorb\


REM ###########################################################
cd %SOURCE_DIR%
REM Clean up any existing generated files.
if exist Common del /F /S /Q Common
if exist ESType del /F /S /Q ESType
if exist EventClient del /F /S /Q EventClient
if exist EventServer del /F /S /Q EventServer
if exist TIE\*.class del /F /S /Q TIE\*.class
if exist *.class del /F /S /Q *.class

SET PATH=%PATH%;%JAVA_HOME%\bin

REM Start to convert idl to java file
SET CLASSPATH=%JACORB_HOME%\lib\*
java -classpath %CLASSPATH% org.jacorb.idl.parser -DMTENANT %SDK_HOME%\idl\v51_idl\EventClient.idl
java -classpath %CLASSPATH% org.jacorb.idl.parser -DMTENANT %SDK_HOME%\idl\v51_idl\EventServer.idl
java -classpath %CLASSPATH% org.jacorb.idl.parser -DMTENANT %SDK_HOME%\idl\v51_idl\EventTypes.idl
java -classpath %CLASSPATH% org.jacorb.idl.parser -DMTENANT %SDK_HOME%\idl\v51_idl\Common.idl

REM start to compile the java file

if exist TIE\*.java move %SOURCE_DIR%\TIE\* %SOURCE_DIR%
javac -classpath %CLASSPATH%; *.java

REM start to build a EventService-5.1.0.jar
if exist %OUTPUT_DIR% del /F /S /Q %OUTPUT_DIR%
if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%
echo "Creating a jar file"
jar -cf %OUTPUT_DIR%\EventService-5.1.0.jar *

SET PATH=%SYS_PATH%

echo "Completed"
cd %BASE_DIR%
pause
