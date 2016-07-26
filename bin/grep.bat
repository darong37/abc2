@if(0)==(0) ECHO OFF
rem 
rem %~1         - すべての引用句 (") を削除して、%1 を展開します。 
rem %~f1        - %1 を完全修飾パス名に展開します。 
rem %~d1        - %1 をドライブ文字だけに展開します。 
rem %~p1        - %1 をパスだけに展開します。 
rem %~n1        - %1 をファイル名だけに展開します。 
rem %~x1        - %1 をファイル拡張子だけに展開します。 
rem %~s1        - 展開されたパスは、短い名前だけを含みます。 
rem %~a1        - %1 をファイル属性に展開します。 
rem %~t1        - %1 をファイルの日付/時刻に展開します。 
rem %~z1        - %1 をファイルのサイズに展開します。 
rem %~$PATH:1   - PATH 環境変数に指定されているディレクトリを検索し、 
rem                最初に見つかった完全修飾名に %1 を展開します。 
rem                環境変数名が定義されていない場合、または 
rem                検索してもファイルが見つからなかった場合は、 
rem                この修飾子を指定すると空の文字列に展開されます。 

setlocal

rem このバッチが存在するフォルダをカレントに 
pushd %0\.. 

rem 変数定義
set APPLNAM=%~n0
set BASEDIR=%~dp0
set CURRENT=%CD%

set DEFENV=%BASEDIR%..\conf\def.env.txt
FOR /F "usebackq delims== tokens=1,2" %%a IN ("%DEFENV%") DO SET %%a=%%b

echo Mail: %MAILADRESS%

set TODAY=%DATE:/=%
set NOW=%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%

set ShellFolders=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders 
FOR /F "TOKENS=1,2,*" %%I IN ('REG QUERY "%ShellFolders%" /v "Desktop"') DO IF "%%I"=="Desktop" SET RESULT=%%K 

CALL :Trim %RESULT%

setx "DESKTOP" "%TRIM%"

rem 自分自身をWSH 実行
echo on
cscript.exe //nologo //E:JScript "%~f0" %~dp1
echo off

rem echo ■BATによる後処理です。■



timeout 5
rem pause

endlocal

GOTO :EOF

REM ###########################################################################
REM TRIM処理
REM ###########################################################################
:Trim
SET TRIM=%*
GOTO :EOF

@end

///////////////////////////////////////////////////////////////////////////////
//// Main
///////////////////////////////////////////////////////////////////////////////
var shell = new ActiveXObject("WScript.Shell"); 
var fso = new ActiveXObject( "Scripting.FileSystemObject" ); 

var APPLNAM = fso.getBaseName(WScript.ScriptFullName));
var BASEDIR = fso.getParentFolderName(WScript.ScriptFullName));
var CURRENT = shell.CurrentDirectory;

function dirname(path) {
  path = path || Editor.GetFilename();
  return path.replace(/\\[^\\]*$/, '');
}
function basename(path,opt) {
  path = path || Editor.GetFilename();
  opt  = opt  || "full"
  
  var rtn = path.replace( /.*\\/, '' );
  if ( opt == "name" ){
    rtn = rtn.replace( /\.[^.]*$/,'' );
  } else if( opt == "type" ){
    rtn = rtn.replace( /^.*\./,'' );
  }
  return rtn;
}

//
//  指定パラメータ パス情報を取得 
//
var args = WScript.Arguments; 
var basedir = args(0); 
//var target  = args(1); 

var exe = '"C:\\Users\\yoshidaei\\Desktop\\abc\\apps\\sakura\\sakura.exe"';
var opt = '-GREPMODE -GREPDLG -GCODE=99 -GFOLDER='+basedir+' -GOPT=SRP'
var cmd  = exe+' '+opt;
shell.Popup("Command: "+cmd, 0, "コマンド", 1);
shell.Run(cmd);

