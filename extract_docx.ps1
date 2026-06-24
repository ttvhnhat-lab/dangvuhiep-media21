Add-Type -AssemblyName System.IO.Compression.FileSystem

function Extract-Docx {
    param([string]$path)
    $zip = [System.IO.Compression.ZipFile]::OpenRead($path)
    $entry = $zip.Entries | Where-Object { $_.FullName -eq 'word/document.xml' }
    $stream = $entry.Open()
    $reader = New-Object System.IO.StreamReader($stream)
    $xml = $reader.ReadToEnd()
    $reader.Close()
    $stream.Close()
    $zip.Dispose()
    $text = $xml -replace '<[^>]+>', ' '
    $text = $text -replace '&amp;', '&'
    $text = $text -replace '&lt;', '<'
    $text = $text -replace '&gt;', '>'
    $text = $text -replace '&#xD;', "`n"
    $text = $text -replace '\s{2,}', ' '
    return $text.Trim()
}

$files = @(
    'Cuocdoibinhnghiep\tuhoithao.docx',
    'Cuocdoibinhnghiep\Bamthatlungdich.docx',
    'Cuocdoibinhnghiep\Doituongtacchien.docx',
    'Di san\Bokhongphaicaio.docx',
    'Di san\Chandung.docx',
    'Di san\MeVietnamAnhhung.docx',
    'TranDanh\thoikhaclichsu.docx',
    'TranDanh\longdangialai.docx',
    'TranDanh\Tapketlan2.docx'
)

$base = 'c:\Users\Win11\Downloads\TrangDangVuHiep'
$out = @{}

foreach ($f in $files) {
    $full = Join-Path $base $f
    Write-Host "=== $f ===" -ForegroundColor Cyan
    $content = Extract-Docx -path $full
    Write-Host $content
    Write-Host ""
    $out[$f] = $content
}

$out | ConvertTo-Json -Depth 3 | Out-File -Encoding UTF8 "$base\extracted_content.json"
Write-Host "Saved to extracted_content.json" -ForegroundColor Green
