# Go 環境變數設定 - 以後要換 Go 版本只改這個檔案
$env:GO_HOME = "C:\Users\User\sdk\go1.26.0\bin"

if ($env:PATH -notlike "*$env:GO_HOME*") {
    $env:PATH = "$env:GO_HOME;$env:PATH"
}
