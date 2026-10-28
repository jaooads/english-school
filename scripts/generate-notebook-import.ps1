param(
  [Parameter(Mandatory = $true)]
  [string]$DocxPath,

  [Parameter(Mandatory = $true)]
  [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Read-ZipEntry {
  param(
    [System.IO.Compression.ZipArchive]$Archive,
    [string]$EntryName
  )

  $entry = $Archive.GetEntry($EntryName)
  if (-not $entry) { throw "Entrada ausente no DOCX: $EntryName" }
  $stream = $entry.Open()
  $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
  try { return $reader.ReadToEnd() }
  finally { $reader.Dispose(); $stream.Dispose() }
}

function Convert-ToSqlLiteral {
  param([AllowNull()][string]$Value)
  if ($null -eq $Value) { return 'null' }
  return "'" + $Value.Replace("'", "''") + "'"
}

function Test-IsHeading {
  param([string]$Text, [string]$Style)
  if ($Style -like 'Heading*') { return $true }
  if ($Text.Length -gt 100) { return $false }
  if ($Text -match '(?i)^(new vocabulary|vocabulary|grammar|examples?|homework|activities|exercises?|reading|writing|listening|review|answer|corre|simple present|simple past|wh\s*-?\s*questions|there is|there are|numbers|ordinal numbers|family|class:|part \d+)') { return $true }
  $letters = $Text -replace '[^\p{L}]', ''
  return $letters.Length -ge 4 -and $letters -ceq $letters.ToUpperInvariant()
}

function Get-BlockType {
  param([string]$Heading)
  if ($Heading -match '(?i)(vocabulary|rooms|family)') { return 'VOCABULARY' }
  if ($Heading -match '(?i)(grammar|simple present|simple past|there is|there are|wh\s*-?\s*questions|would like|adverbs? of frequency|verb to be)') { return 'GRAMMAR' }
  if ($Heading -match '(?i)^examples?') { return 'EXAMPLE' }
  return 'TEXT'
}

function Add-TextBlock {
  param(
    [System.Collections.ArrayList]$Blocks,
    [AllowNull()][string]$Title,
    [string]$Type,
    [System.Collections.Generic.List[string]]$Lines
  )
  if ($Lines.Count -eq 0 -and [string]::IsNullOrWhiteSpace($Title)) { return }
  $content = if ($Lines.Count -gt 0) { ($Lines -join "`n").Trim() } else { $Title }
  [void]$Blocks.Add([pscustomobject]@{ Type = $Type; Title = $Title; Content = $content })
  $Lines.Clear()
}

$lessons = @(
  [pscustomobject]@{ Start = 0; Date = '2026-03-02'; Title = 'Introductions and Verb To Be' },
  [pscustomobject]@{ Start = 70; Date = '2026-03-05'; Title = 'Personal Pronouns and Verb To Be' },
  [pscustomobject]@{ Start = 163; Date = '2026-03-16'; Title = 'Feelings and Basic States' },
  [pscustomobject]@{ Start = 218; Date = '2026-03-19'; Title = 'Activities and Homework' },
  [pscustomobject]@{ Start = 273; Date = '2026-03-19'; Title = 'Cardinal Numbers' },
  [pscustomobject]@{ Start = 349; Date = '2026-03-30'; Title = 'Ordinal Numbers and Dates' },
  [pscustomobject]@{ Start = 501; Date = '2026-04-06'; Title = 'In and On with Months and Dates' },
  [pscustomobject]@{ Start = 604; Date = '2026-04-13'; Title = 'Simple Present' },
  [pscustomobject]@{ Start = 715; Date = '2026-04-16'; Title = 'Simple Present Exercises' },
  [pscustomobject]@{ Start = 771; Date = '2026-06-04'; Title = 'Simple Present - Negative' },
  [pscustomobject]@{ Start = 845; Date = '2026-05-19'; Title = 'Review - Simple Present' },
  [pscustomobject]@{ Start = 884; Date = '2026-05-21'; Title = 'Homework and General Review' },
  [pscustomobject]@{ Start = 1004; Date = '2026-05-25'; Title = 'Adverbs of Frequency Practice' },
  [pscustomobject]@{ Start = 1060; Date = '2026-06-01'; Title = 'Correcao' },
  [pscustomobject]@{ Start = 1062; Date = '2026-06-08'; Title = 'Simple Present Review' },
  [pscustomobject]@{ Start = 1114; Date = '2026-06-22'; Title = 'WH Questions' },
  [pscustomobject]@{ Start = 1149; Date = '2026-07-06'; Title = 'WH Questions - Activities' },
  [pscustomobject]@{ Start = 1223; Date = '2026-07-19'; Title = 'Revision Activity' },
  [pscustomobject]@{ Start = 1262; Date = '2026-07-20'; Title = 'Rooms Vocabulary' },
  [pscustomobject]@{ Start = 1284; Date = '2026-07-27'; Title = 'There Is and There Are' },
  [pscustomobject]@{ Start = 1347; Date = '2026-08-12'; Title = 'Rooms and Home Practice' },
  [pscustomobject]@{ Start = 1383; Date = '2026-08-17'; Title = 'Simple Past' },
  [pscustomobject]@{ Start = 1430; Date = '2026-08-20'; Title = 'English Game Night' },
  [pscustomobject]@{ Start = 1438; Date = '2026-08-24'; Title = 'Simple Past Review and Negative' },
  [pscustomobject]@{ Start = 1556; Date = '2026-09-02'; Title = 'Simple Past - Questions' },
  [pscustomobject]@{ Start = 1637; Date = '2026-09-09'; Title = 'Date Ideas' },
  [pscustomobject]@{ Start = 1680; Date = '2026-09-17'; Title = 'Would Like and English Level Assessment' }
)

$archive = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $DocxPath))
try {
  [xml]$document = Read-ZipEntry -Archive $archive -EntryName 'word/document.xml'
  [xml]$relationships = Read-ZipEntry -Archive $archive -EntryName 'word/_rels/document.xml.rels'
}
finally {
  $archive.Dispose()
}

$ns = New-Object System.Xml.XmlNamespaceManager($document.NameTable)
$ns.AddNamespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
$ns.AddNamespace('a', 'http://schemas.openxmlformats.org/drawingml/2006/main')
$paragraphs = $document.SelectNodes('//w:body//w:p', $ns)

$records = @()
for ($index = 0; $index -lt $paragraphs.Count; $index++) {
  $paragraph = $paragraphs[$index]
  $text = (($paragraph.SelectNodes('.//w:t', $ns) | ForEach-Object { $_.InnerText }) -join '').Trim()
  $styleNode = $paragraph.SelectSingleNode('./w:pPr/w:pStyle', $ns)
  $style = if ($styleNode) { $styleNode.GetAttribute('val', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main') } else { '' }
  $images = @()
  foreach ($blip in $paragraph.SelectNodes('.//a:blip', $ns)) {
    $relationshipId = $blip.GetAttribute('embed', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')
    $relationship = $relationships.SelectSingleNode("//*[local-name()='Relationship' and @Id='$relationshipId']")
    if ($relationship) { $images += [System.IO.Path]::GetFileName($relationship.Target) }
  }
  $records += [pscustomobject]@{ Index = $index; Text = $text; Style = $style; Images = $images }
}

$sql = New-Object System.Text.StringBuilder
[void]$sql.AppendLine('-- Importacao integral do Digital English Notebook.')
[void]$sql.AppendLine('-- Execute depois das migrations 001, 002 e 003.')
[void]$sql.AppendLine('-- O script e idempotente: aulas importadas sao identificadas por source_reference.')
[void]$sql.AppendLine('')
[void]$sql.AppendLine('begin;')
[void]$sql.AppendLine('do $$')
[void]$sql.AppendLine('declare')
[void]$sql.AppendLine('  teacher_id uuid;')
[void]$sql.AppendLine('  imported_lesson_id uuid;')
[void]$sql.AppendLine('begin')
[void]$sql.AppendLine("  select id into teacher_id from public.profiles where role = 'TEACHER' order by name limit 1;")
[void]$sql.AppendLine("  if teacher_id is null then raise exception 'Configure o perfil TEACHER antes da importacao.'; end if;")

$totalBlocks = 0
for ($lessonIndex = 0; $lessonIndex -lt $lessons.Count; $lessonIndex++) {
  $lesson = $lessons[$lessonIndex]
  $end = if ($lessonIndex -lt $lessons.Count - 1) { $lessons[$lessonIndex + 1].Start } else { $paragraphs.Count }
  $lessonRecords = $records | Where-Object { $_.Index -ge $lesson.Start -and $_.Index -lt $end }
  $boundary = ($lessonRecords | Select-Object -First 1).Text
  $blocks = New-Object System.Collections.ArrayList
  [void]$blocks.Add([pscustomobject]@{ Type = 'TEXT'; Title = 'Identificacao original'; Content = $boundary })
  $currentTitle = $null
  $currentType = 'TEXT'
  $lines = New-Object 'System.Collections.Generic.List[string]'
  $characterCount = 0

  foreach ($record in ($lessonRecords | Select-Object -Skip 1)) {
    foreach ($image in $record.Images) {
      Add-TextBlock -Blocks $blocks -Title $currentTitle -Type $currentType -Lines $lines
      $currentTitle = $null; $currentType = 'TEXT'; $characterCount = 0
      [void]$blocks.Add([pscustomobject]@{ Type = 'IMAGE'; Title = 'Material visual do caderno'; Content = $image })
    }

    if ([string]::IsNullOrWhiteSpace($record.Text)) { continue }
    $urlMatch = [regex]::Match($record.Text, 'https?://\S+')
    if ($urlMatch.Success -and ($record.Text -replace 'https?://\S+', '').Trim(' ', '.', '-', [char]9).Length -le 3) {
      Add-TextBlock -Blocks $blocks -Title $currentTitle -Type $currentType -Lines $lines
      $currentTitle = $null; $currentType = 'TEXT'; $characterCount = 0
      $linkPrefix = ($record.Text -replace [regex]::Escape($urlMatch.Value), '').Trim()
      $linkTitle = if ($linkPrefix) { $linkPrefix } else { 'Material externo' }
      [void]$blocks.Add([pscustomobject]@{ Type = 'LINK'; Title = $linkTitle; Content = $urlMatch.Value })
      continue
    }

    if (Test-IsHeading -Text $record.Text -Style $record.Style) {
      Add-TextBlock -Blocks $blocks -Title $currentTitle -Type $currentType -Lines $lines
      $currentTitle = $record.Text
      $currentType = Get-BlockType -Heading $record.Text
      $characterCount = 0
      continue
    }

    $lines.Add($record.Text)
    $characterCount += $record.Text.Length + 1
    if ($characterCount -ge 4500) {
      Add-TextBlock -Blocks $blocks -Title $currentTitle -Type $currentType -Lines $lines
      $currentTitle = $null; $currentType = 'TEXT'; $characterCount = 0
    }
  }
  Add-TextBlock -Blocks $blocks -Title $currentTitle -Type $currentType -Lines $lines

  $sourceReference = "digital-notebook:$($lesson.Start)"
  [void]$sql.AppendLine('')
  [void]$sql.AppendLine("  insert into public.lessons (title, lesson_date, created_by, source_reference)")
  [void]$sql.AppendLine("  values ($(Convert-ToSqlLiteral $lesson.Title), $(Convert-ToSqlLiteral $lesson.Date)::date, teacher_id, $(Convert-ToSqlLiteral $sourceReference))")
  [void]$sql.AppendLine('  on conflict (source_reference) do update')
  [void]$sql.AppendLine('  set title = excluded.title, lesson_date = excluded.lesson_date')
  [void]$sql.AppendLine('  returning id into imported_lesson_id;')
  [void]$sql.AppendLine('  delete from public.lesson_blocks where lesson_id = imported_lesson_id;')
  [void]$sql.AppendLine('  insert into public.lesson_blocks (lesson_id, type, title, content, position) values')
  for ($blockIndex = 0; $blockIndex -lt $blocks.Count; $blockIndex++) {
    $block = $blocks[$blockIndex]
    $suffix = if ($blockIndex -eq $blocks.Count - 1) { ';' } else { ',' }
    [void]$sql.AppendLine("    (imported_lesson_id, '$($block.Type)', $(Convert-ToSqlLiteral $block.Title), $(Convert-ToSqlLiteral $block.Content), $blockIndex)$suffix")
  }
  $totalBlocks += $blocks.Count
}

[void]$sql.AppendLine('end;')
[void]$sql.AppendLine('$$;')
[void]$sql.AppendLine('commit;')

$resolvedOutput = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputPath))
$outputDirectory = [System.IO.Path]::GetDirectoryName($resolvedOutput)
if (-not [System.IO.Directory]::Exists($outputDirectory)) { [System.IO.Directory]::CreateDirectory($outputDirectory) | Out-Null }
[System.IO.File]::WriteAllText($resolvedOutput, $sql.ToString(), (New-Object System.Text.UTF8Encoding($false)))

Write-Output "Aulas: $($lessons.Count)"
Write-Output "Blocos: $totalBlocks"
Write-Output "Paragrafos analisados: $($records.Count)"
Write-Output "Arquivo: $resolvedOutput"
