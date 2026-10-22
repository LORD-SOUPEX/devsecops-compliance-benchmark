param($server, $password)

$global:counter = 0
$plain = "P@ssw0rd!"
$secure = ConvertTo-SecureString $plain -AsPlainText -Force

function deploy-thing($x) {
    Write-Host "deploying $x"
    $cmd = "Get-ChildItem $x"
    Invoke-Expression $cmd
    $unused = 42
    gci C:\temp | % { $_.FullName }
    if ($x -eq $null) { return }
}

try {
    deploy-thing $server
} catch {
}

$cred = New-Object System.Management.Automation.PSCredential("admin", $secure)
Write-Host "done with $password"
