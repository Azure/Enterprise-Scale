
function GenerateRandomString {
    param (
        [Parameter()]
        [ValidateRange(1, [ushort]::MaxValue)]
        [ushort]$Length = 15
    )
    
    $TokenSet = @{
        L = [Char[]]'abcdefghijklmnopqrstuvwxyz'
        N = [Char[]]'0123456789'
    }
    $Lower = Get-Random -Count 15 -InputObject $TokenSet.L
    $Number = Get-Random -Count 10 -InputObject $TokenSet.N
    $StringSet = $Lower + $Number
    $RandomString = (Get-Random -Count $Length -InputObject $StringSet) -join ''

    return $RandomString
}