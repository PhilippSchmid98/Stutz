[CmdletBinding()]
param (
    [string]$Serial,
    [string]$OutputPath,
    [switch]$IncludeRawDump,
    [string]$RawOutputPath
)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $projectRoot 'wallet-notifications.txt'
}
if ([string]::IsNullOrWhiteSpace($RawOutputPath)) {
    $RawOutputPath = Join-Path $projectRoot 'wallet-notifications-raw.txt'
}

$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)
$RawOutputPath = [System.IO.Path]::GetFullPath($RawOutputPath)

$adbCommand = Get-Command adb -ErrorAction SilentlyContinue
if ($null -eq $adbCommand) {
    throw 'adb was not found on PATH. Install Android platform-tools or add adb to PATH.'
}

$adb = $adbCommand.Source
$deviceLines = @(& $adb devices 2>&1)
if ($LASTEXITCODE -ne 0) {
    throw "adb devices failed: $($deviceLines -join ' ')"
}

$readyDevices = @(
    $deviceLines |
        Where-Object { $_ -match '^\S+\s+device\s*$' } |
        ForEach-Object {
            [pscustomobject]@{
                Serial = ($_ -split '\s+')[0]
            }
        }
)

if (-not [string]::IsNullOrWhiteSpace($Serial)) {
    if ($readyDevices.Serial -notcontains $Serial) {
        throw "ADB device '$Serial' is not connected and ready. Run 'adb devices' to check its state."
    }
    $selectedSerial = $Serial
} elseif ($readyDevices.Count -eq 1) {
    $selectedSerial = $readyDevices[0].Serial
} elseif ($readyDevices.Count -eq 0) {
    throw "No ready ADB device found. Connect a phone or start an emulator, then run 'adb devices'."
} else {
    $serials = $readyDevices.Serial -join ', '
    throw "Multiple ADB devices are ready ($serials). Re-run with -Serial <device-serial>."
}

$adbArguments = @('-s', $selectedSerial)
$dumpLines = @(& $adb @adbArguments shell dumpsys notification --noredact 2>&1)
if ($LASTEXITCODE -ne 0) {
    throw "Could not read Android notifications: $($dumpLines -join ' ')"
}

function Normalize-NotificationText([AllowNull()][string]$Value) {
    if ($null -eq $Value) {
        return $null
    }

    $mojibakeNonBreakingSpace = -join [char[]](0x252C, 0x00E1)
    $normalized = $Value
        .Replace([char]0x00A0, ' ')
        .Replace([char]0x202F, ' ')
        .Replace((-join [char[]](0x00C2, 0x00A0)), ' ')
        .Replace($mojibakeNonBreakingSpace, ' ')

    $normalized = [regex]::Replace($normalized, '\s+', ' ').Trim()
    if ($normalized.Length -eq 0) {
        return $null
    }
    return $normalized
}

$walletPackage = 'com.google.android.apps.walletnfcrel'
$paymentPattern = '^CHF\s+(?<amount>\d+(?:[.,]\d{1,2})?)\s+mit\s+\S.*$'
$dump = $dumpLines -join "`n"
$records = $dump -split '(?=NotificationRecord\()'
$payments = @()

foreach ($record in $records) {
    if ($record -notmatch "pkg=$walletPackage") {
        continue
    }
    if ($record -match '\bGROUP_SUMMARY\b') {
        continue
    }

    $textMatches = [regex]::Matches(
        $record,
        'android\.text=(?:String|SpannableString)\s+\((?<value>.*?)\)',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    foreach ($textMatch in $textMatches) {
        $paymentText = Normalize-NotificationText $textMatch.Groups['value'].Value
        if ($null -eq $paymentText) {
            continue
        }
        $paymentMatch = [regex]::Match($paymentText, $paymentPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if (-not $paymentMatch.Success) {
            continue
        }

        $titleMatches = [regex]::Matches(
            $record.Substring(0, $textMatch.Index),
            'android\.title=(?:String|SpannableString)\s+\((?<value>.*?)\)',
            [System.Text.RegularExpressions.RegexOptions]::Singleline
        )
        if ($titleMatches.Count -eq 0) {
            continue
        }

        $merchant = Normalize-NotificationText $titleMatches[$titleMatches.Count - 1].Groups['value'].Value
        if ($null -eq $merchant) {
            continue
        }

        $amountText = $paymentMatch.Groups['amount'].Value.Replace(',', '.')
        $amount = [decimal]::Parse(
            $amountText,
            [System.Globalization.CultureInfo]::InvariantCulture
        )
        $amountMinor = [long]($amount * 100)
        if ($amountMinor -le 0) {
            continue
        }

        $keyMatch = [regex]::Match($record, '(?m)^\s*key=(?<value>[^\r\n]+)')
        $channelMatch = [regex]::Match($record, 'channel=(?<value>[^\s]+)')
        $payments += [pscustomobject]@{
            Package = $walletPackage
            Key = if ($keyMatch.Success) { $keyMatch.Groups['value'].Value.Trim() } else { 'unknown' }
            Channel = if ($channelMatch.Success) { $channelMatch.Groups['value'].Value } else { 'unknown' }
            Merchant = $merchant
            Payment = $paymentText
            AmountMinor = $amountMinor
        }
        break
    }
}

$outputDirectory = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

$report = [System.Collections.Generic.List[string]]::new()
$report.Add('Google Wallet active payment notifications')
$report.Add("Device: $selectedSerial")
$report.Add("Captured: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')")
$report.Add('')

if ($payments.Count -eq 0) {
    $report.Add('No active non-summary Google Wallet payment notifications found.')
} else {
    foreach ($payment in $payments) {
        $report.Add("Package:  $($payment.Package)")
        $report.Add("Key:      $($payment.Key)")
        $report.Add("Channel:  $($payment.Channel)")
        $report.Add("Merchant: $($payment.Merchant)")
        $report.Add("Payment:  $($payment.Payment)")
        $report.Add("Minor:    $($payment.AmountMinor)")
        $report.Add(('-' * 60))
    }
}

Set-Content -Path $OutputPath -Value ($report -join [Environment]::NewLine) -Encoding utf8

if ($IncludeRawDump) {
    $rawDirectory = Split-Path -Parent $RawOutputPath
    if (-not [string]::IsNullOrWhiteSpace($rawDirectory)) {
        New-Item -ItemType Directory -Path $rawDirectory -Force | Out-Null
    }
    Set-Content -Path $RawOutputPath -Value $dump -Encoding utf8
    Write-Host "Raw dump written to $RawOutputPath"
}

Write-Host "Readable report written to $OutputPath"
Write-Host "Payment notifications found: $($payments.Count)"