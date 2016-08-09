$global:APPLNAM="PS"
$global:BASEDIR=(Split-Path $MyInvocation.MyCommand.Path -parent)
$global:CURRDIR=$(Get-Location)

$global:TEMPDIR=""
if (Test-Path "$BASEDIR\temp"){
  $global:TEMPDIR=( Resolve-Path "$BASEDIR\temp" )
} elseif (Test-Path "$BASEDIR\..\temp"){
  $global:TEMPDIR=( Resolve-Path "$BASEDIR\..\temp" )
} elseif (Test-Path "$BASEDIR\..\files\temp"){
  $global:TEMPDIR=( Resolve-Path "$BASEDIR\..\files\temp" )
} else {
  $global:TEMPDIR=$env:temp
}
write-host "TEMPDIR: '$TEMPDIR'"


$global:LOGSDIR=""
if (Test-Path "$BASEDIR\logs"){
  $global:LOGSDIR=( Resolve-Path "$BASEDIR\logs" )
} elseif (Test-Path "$BASEDIR\..\logs"){
  $global:LOGSDIR=( Resolve-Path "$BASEDIR\..\logs" )
} elseif (Test-Path "$BASEDIR\..\files\logs"){
  $global:LOGSDIR=( Resolve-Path "$BASEDIR\..\files\logs" )
} else {
  $global:LOGSDIR=$CURRDIR
}
write-host "LOGSDIR: '$LOGSDIR'"


#### Alias
Set-Alias ga      "Get-Alias"
Set-Alias exp     "explorer"

#### One Linner
function env{ Get-Item env: }
function version{ $PSVersionTable }
function func($fnc){Write-Host (Get-Item function:$fnc).Definition }

#### General
filter grep($keyword,$out="",$context=(0,0)){
  if ( $out -eq "" ){
    $_ | Out-String -Stream -Width 9999 | Select-String -Pattern $keyword -Context $context
  } else {
    $_ | Out-String -Stream -Width 9999 | Select-String -Pattern $keyword -Context $context | Out-File $out -Width 9999
  }
}


function dispMode(){
  echo "`$ErrorActionPreference : '$ErrorActionPreference'"   # Write-Debugに指定されたメッセージを出力した後、動作を停止'
  echo ""
  echo "`$DebugPreference       : '$DebugPreference'"         # Write-Debugに指定されたメッセージを出力'
  echo "`$VerbosePreference     : '$VerbosePreference'"       # Write-Debugに指定されたメッセージを出力しない'
  echo ""
}


function sha1S($path=".",$prefix="")){
  Get-ChildItem $path -Recurse |
  Foreach-Object{
    $fulpath = $_.FullName;
    if ( -not (Test-Path $fulpath) ){
      return "$fulpath`tNot Exists	N/A"
    }
    if (-not $_.PSIsContainer){
      $stream = [system.io.file]::openread( ( resolve-path $fulpath ) )

      # sha1ハッシュ値を計算する
      $sha1 = [System.Security.Cryptography.HashAlgorithm]::create( 'sha1' )
      $hash = $sha1.ComputeHash( $stream )

      $stream.close()
      $stream.dispose()
      $code = [System.BitConverter]::ToString( $hash ).Replace( "-", "" ).ToLower()

      $sha1.clear()

      # File Create Datetime
      $ctim = ( (Get-ItemProperty $fulpath).CreationTime ).ToString("yyyy/MM/dd HH:mm:ss")

#     reject prefix    echo "$fulpath : $prefix"
      if ($prefix -eq ""){
        $relpath = $fulpath
      } else {
        $relpath = "$fulpath".replace($prefix,"")
      }
      return "$fulpath`t$ctim`t$code"
    }
  }
}


function md5S($path,$prefix=""){
  Get-ChildItem $path -Recurse |
  Foreach-Object{
    $fulpath = $_.FullName;
    if ( -not (Test-Path $fulpath) ){
      return "$fulpath`tNot Exists	N/A"
    }
    if (-not $_.PSIsContainer){
      $stream = New-Object IO.StreamReader "$fulpath"

      # MD5ハッシュ値を計算する
      $md5 = [System.Security.Cryptography.MD5]::Create()
      $hash = $md5.ComputeHash($stream.BaseStream);
      
      $stream.close()
      $stream.dispose()
      $code = [System.BitConverter]::ToString($hash).ToLower().Replace("-","")

      $md5.clear()

      # File Create Datetime
      $ctim = ( (Get-ItemProperty $fulpath).CreationTime )

#     reject prefix    echo "$fulpath : $prefix"
      if ($prefix -eq ""){
        $relpath = $fulpath
      } else {
        $relpath = "$fulpath".replace($prefix,"")
      }
      return "$relpath`t$code"
    }
  }
}


function TempFile($id="",$dir=""){
  $local:ErrorActionPreference = "STOP"

  if ($dir -eq ""){
    $tmpdir = $global:TEMPDIR
  } else {
    $tmpdir = $dir
    if (-not (Test-Path $tmpdir)){
      New-Item "$tmpdir" -type directory | Out-Null
    }
  }
  
  $dattim = Get-Date -Format "yyyyMMdd_HHmmss"
  $name   = "${id}_${dattim}.tmp"
  
  New-Item -ItemType file "$tmpdir\$name" | Out-Null
  return "$tmpdir\$name"
}


#### Standard
function prompt {
  $cdir=$(get-location)
  $global:BASEDIR=$cdir
  if ($APPLNAM -eq "PS"){
    Write-Host "$APPLNAM " -nonewline 
  }else{
    Write-Host "$APPLNAM " -nonewline -Foregroundcolor Green
  }
  $now = Get-Date -format "HH:mm:ss"
  return $now + " " + $Env:COMPUTERNAME + ":" + $pid + ":" + $(Split-Path $cdir -Leaf) + " > "
}


function slog($nam="$((Get-Date).toString("yyyyMMdd_HHmmss"))"){
  if ("$global:APPLNAM" -eq "PS"){
    $global:APPLNAM=$nam
    $global:LOG="$LOGSDIR\$nam.log"
    $global:LOGNAM="$nam"
    
    echo "Start-Transcript $LOG"
    try {
      Start-Transcript $LOG -Append
    } catch {
      Write-Host "Start-Transcriptが起動できませんでした" -Foregroundcolor Yellow
    }
  } else {
    Write-Host "既に ログ取得中です" -Foregroundcolor Yellow
  }
}


function elog(){
  echo "Stop-Transcript $LOG"
  Stop-Transcript

  $global:APPLNAM="PS"
}


