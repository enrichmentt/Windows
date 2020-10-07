$Public = Get-ChildItem $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue
$Private = Get-ChildItem $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue

if ($Private) {

    $Paths = @()
    $Paths += $Private
    $Paths += $Public

    Foreach ($import in $Paths) {
        Try {
            . $import.fullname
        }
        Catch {
            Write-Error "Failed to import function $($import.fullname): $_"
        }
    }
}
else {
    Foreach ($import in $Public) {
        Try {
            . $import.fullname
        }
        Catch {
            Write-Error "Failed to import function $($import.fullname): $_"
        }
    }
}
