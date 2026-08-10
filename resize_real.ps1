Add-Type -AssemblyName System.Drawing

$srcDir = "c:\Users\lalit\projects\attendify\screenshot"
$destDir = "c:\Users\lalit\projects\attendify"

function Resize-Image {
    param([string]$in, [string]$out, [int]$w, [int]$h, [string]$format)
    
    if (-Not (Test-Path $in)) {
        Write-Host "File not found: $in"
        return
    }
    
    $img = [System.Drawing.Image]::FromFile($in)
    
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $graph = [System.Drawing.Graphics]::FromImage($bmp)
    
    # Fill background with black to avoid any transparent/blank areas
    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    $graph.FillRectangle($bgBrush, 0, 0, $w, $h)
    
    # Calculate aspect ratio to fit the image inside 1080x1920 without stretching
    $ratioW = $w / $img.Width
    $ratioH = $h / $img.Height
    $ratio = [math]::Min($ratioW, $ratioH)
    
    $newWidth = [math]::Round($img.Width * $ratio)
    $newHeight = [math]::Round($img.Height * $ratio)
    
    $xOffset = [math]::Round(($w - $newWidth) / 2)
    $yOffset = [math]::Round(($h - $newHeight) / 2)
    
    $graph.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graph.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graph.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    
    $graph.DrawImage($img, $xOffset, $yOffset, $newWidth, $newHeight)
    
    if ($format -eq "JPEG") {
        $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    } else {
        $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    
    $bgBrush.Dispose()
    $graph.Dispose()
    $bmp.Dispose()
    $img.Dispose()
    
    Write-Host "Saved $out"
}

# Get all jpgs in screenshot folder
$files = Get-ChildItem -Path $srcDir -Filter *.jpg
$count = 1

foreach ($file in $files) {
    $outFile = Join-Path -Path $destDir -ChildPath "amazon_real_screenshot_$count.jpg"
    Resize-Image $file.FullName $outFile 1080 1920 "JPEG"
    $count++
}
