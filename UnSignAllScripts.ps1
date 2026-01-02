$psfiles = Get-ChildItem('*.ps1')
$removeScriptPath = $PSScriptRoot + '\Remove-AuthenticodeSignature.ps1'
foreach ($file in $psfiles) {
    . $removeScriptPath $file
}