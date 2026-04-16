param(
    [string]$SourcePath = ".",
    [string]$OutputFile = "dfm_strings.po"
)

$enc = [System.Text.Encoding]::GetEncoding(1251)
$results = @{}

function Decode-DelphiString {
    param($s)
    $result = ""
    # Extract all 'tokens' which are either 'quoted strings' or #decimal character codes
    # Regex: '([^']|'')*' matches a single-quoted string, including escaped double single quotes
    # Regex: #\d+ matches a character code
    $tokens = [regex]::Matches($s, "'([^']|'')*'|#\d+")
    foreach ($t in $tokens) {
        $part = $t.Value
        if ($part.StartsWith("'")) {
            # Quoted string: remove delimiters and unescape double-quotes
            $inner = $part.Substring(1, $part.Length - 2)
            $inner = $inner -replace "''", "'"
            $result += $inner
        } elseif ($part.StartsWith("#")) {
            # Character code
            $code = [int]$part.Substring(1)
            $result += [char]$code
        }
    }
    return $result.Trim()
}

Write-Host "Scanning DFM files in $SourcePath..."
$files = Get-ChildItem -Path $SourcePath -Filter "*.dfm" -Recurse

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Encoding default
    $lineNum = 0
    foreach ($line in $content) {
        $lineNum++
        # Match properties that usually contain user-visible text
        if ($line -match "^\s*(Caption|Hint|Text|DisplayLabel|DisplayFormat)\s*=\s*(.*)") {
            $prop = $matches[1]
            $val = $matches[2]
            
            if ($val -match "#|\w") {
                $decoded = Decode-DelphiString $val
                # Use Unicode range for Cyrillic: \u0400-\u04FF
                if ($decoded -and ($decoded -match "[\u0400-\u04FF]")) {
                    if (-not $results.ContainsKey($decoded)) {
                        $results[$decoded] = @()
                    }
                    $relPath = Resolve-Path $file.FullName -Relative
                    $results[$decoded] += "#: " + $relPath + ":" + $lineNum
                }
            }
        }
        # Special handling for Items.Strings
        if ($line -match "Items.Strings\s*=\s*\(") {
             # Simple capture for next lines until )
        }
    }
}

$poContent = @()
foreach ($key in $results.Keys) {
    foreach ($ref in $results[$key]) {
        $poContent += $ref
    }
    $poContent += "msgid `"$key`""
    $poContent += "msgstr `"`""
    $poContent += ""
}

[System.IO.File]::WriteAllLines($OutputFile, $poContent, [System.Text.Encoding]::UTF8)
Write-Host "Extracted $($results.Count) unique strings to $OutputFile"
