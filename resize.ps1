Add-Type -AssemblyName System.Drawing

$srcDir = "C:\Users\lalit\.gemini\antigravity-ide\brain\1ca38dd4-5b24-44a0-be92-124e6e1747b5"
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

Resize-Image "$srcDir\attendify_dashboard_1786286393137.png" "$destDir\amazon_screenshot_1.jpg" 1080 1920 "JPEG"
Resize-Image "$srcDir\attendify_calendar_1786286410420.png" "$destDir\amazon_screenshot_2.jpg" 1080 1920 "JPEG"
Resize-Image "$srcDir\attendify_subject_1786286424163.png" "$destDir\amazon_screenshot_3.jpg" 1080 1920 "JPEG"
Resize-Image "$srcDir\attendify_icon_1786286436228.png" "$destDir\amazon_icon_512.png" 512 512 "PNG"
