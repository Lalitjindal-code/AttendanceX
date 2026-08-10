Add-Type -AssemblyName System.Drawing

$srcDir = "c:\Users\lalit\projects\attendify"
$destDir = "c:\Users\lalit\projects\attendify"

function Resize-Image {
    param([string]$in, [string]$out, [int]$w, [int]$h, [string]$format)
    
    if (-Not (Test-Path $in)) {
        Write-Host "File not found: $in"
        return
    }
    
    $img = [System.Drawing.Image]::FromFile($in)
    
    if ($format -eq "JPEG") {
        $bmp = New-Object System.Drawing.Bitmap($w, $h)
        $graph = [System.Drawing.Graphics]::FromImage($bmp)
        
        $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(18, 18, 18))
        $graph.FillRectangle($bgBrush, 0, 0, $w, $h)
        
        $ratio = $w / $img.Width
        $newHeight = [math]::Round($img.Height * $ratio)
        
        $yOffset = [math]::Round(($h - $newHeight) / 2)
        
        $graph.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graph.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graph.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        
        $graph.DrawImage($img, 0, $yOffset, $w, $newHeight)
        
        $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        
        $bgBrush.Dispose()
        $graph.Dispose()
        $bmp.Dispose()
    } else {
        $bmp = New-Object System.Drawing.Bitmap($w, $h)
        $graph = [System.Drawing.Graphics]::FromImage($bmp)
        
        $graph.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graph.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        
        $graph.DrawImage($img, 0, 0, $w, $h)
        
        $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
        
        $graph.Dispose()
        $bmp.Dispose()
    }
    
    $img.Dispose()
    Write-Host "Saved $out"
}

# Resize the user's original screenshots
Resize-Image "$srcDir\screenshot_1.jpg" "$destDir\amazon_screenshot_1_resized.jpg" 1080 1920 "JPEG"
Resize-Image "$srcDir\screenshot_2.jpg" "$destDir\amazon_screenshot_2_resized.jpg" 1080 1920 "JPEG"
Resize-Image "$srcDir\screenshot_3.jpg" "$destDir\amazon_screenshot_3_resized.jpg" 1080 1920 "JPEG"
Resize-Image "$srcDir\icon_512.png" "$destDir\amazon_icon_512_resized.png" 512 512 "PNG"
