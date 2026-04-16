$enc = [System.Text.Encoding]::GetEncoding(1251)
$helperUnit = "uLocalizationHelper"

Get-ChildItem -Path forms\*.pas | ForEach-Object {
    $path = $_.FullName
    $content = [System.IO.File]::ReadAllText($path, $enc)
    $modified = $false

    # Skip if already has localization call
    if ($content -match "TranslateForm\(Self\)") {
        return
    }

    # Add uLocalizationHelper to implementation uses
    if ($content -match "implementation\s*uses") {
        $content = $content -replace "(implementation\s*uses\s*)", "`$1$helperUnit, "
        $modified = $true
    } elseif ($content -match "implementation") {
        $content = $content -replace "implementation", "implementation`r`n`r`nuses`r`n  $helperUnit;"
        $modified = $true
    }

    # Inject TranslateForm(Self)
    # Priority: FormCreate > ShowModal > constructor Create
    if ($content -match "procedure .*FormCreate\(Sender: TObject\);\s*begin") {
        $content = $content -replace "(procedure .*FormCreate\(Sender: TObject\);\s*begin\s*)", "`$1TranslateForm(Self);`r`n  "
        $modified = $true
    } elseif ($content -match "FUNCTION .*ShowModal\(.*\):integer;\s*begin") {
         # We need to escape parenthesis for regex but here we just want a literal match for common patterns
         # Let's use a simpler match
         if ($content -match "FUNCTION .*ShowModal\(.*\):integer;\s*begin\s*") {
            $content = $content -replace "(FUNCTION .*ShowModal\(.*\):integer;\s*begin\s*)", "`$1TranslateForm(Self);`r`n  "
            $modified = $true
         }
    } elseif ($content -match "constructor .*Create\(.*\);\s*begin") {
        $content = $content -replace "(constructor .*Create\(.*\);\s*begin\s*)", "`$1TranslateForm(Self);`r`n  "
        $modified = $true
    }

    if ($modified) {
        [System.IO.File]::WriteAllText($path, $content, $enc)
        Write-Host "Modified: $($_.Name)"
    }
}
