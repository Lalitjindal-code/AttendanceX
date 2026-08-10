from PIL import Image
import os

src_dir = r"C:\Users\lalit\.gemini\antigravity-ide\brain\1ca38dd4-5b24-44a0-be92-124e6e1747b5"
dest_dir = r"c:\Users\lalit\projects\attendify"

images = [
    (os.path.join(src_dir, "attendify_dashboard_1786286393137.png"), os.path.join(dest_dir, "amazon_screenshot_1.jpg"), 1080, 1920, 'JPEG'),
    (os.path.join(src_dir, "attendify_calendar_1786286410420.png"), os.path.join(dest_dir, "amazon_screenshot_2.jpg"), 1080, 1920, 'JPEG'),
    (os.path.join(src_dir, "attendify_subject_1786286424163.png"), os.path.join(dest_dir, "amazon_screenshot_3.jpg"), 1080, 1920, 'JPEG'),
    (os.path.join(src_dir, "attendify_icon_1786286436228.png"), os.path.join(dest_dir, "amazon_icon_512.png"), 512, 512, 'PNG'),
]

for src, dest, w, h, fmt in images:
    if os.path.exists(src):
        img = Image.open(src)
        # For screenshots, usually we want to fit or fill, but resizing directly is fine if they are already roughly phone shape. 
        # Actually our generated images are 1024x1024 square. Resizing 1024x1024 to 1080x1920 will stretch them.
        # So instead of blind resize, let's create a 1080x1920 background and paste the image in the center, or crop.
        # Since they are UI screenshots, let's just resize them to fit the width and center vertically on a dark background.
        
        target_w, target_h = w, h
        if fmt == 'JPEG':
            # Create dark background 1080x1920
            new_img = Image.new('RGB', (target_w, target_h), (18, 18, 18))
            
            # Resize image to fit width (1080)
            ratio = target_w / img.width
            new_height = int(img.height * ratio)
            resized_img = img.resize((target_w, new_height), Image.Resampling.LANCZOS)
            
            # Paste in center
            y_offset = (target_h - new_height) // 2
            
            # If the generated image has alpha, convert it
            if resized_img.mode in ('RGBA', 'LA') or (resized_img.mode == 'P' and 'transparency' in resized_img.info):
                new_img.paste(resized_img, (0, y_offset), resized_img)
            else:
                new_img.paste(resized_img, (0, y_offset))
                
            new_img.save(dest, 'JPEG', quality=95)
            print(f"Saved {dest}")
        else:
            # Icon 512x512
            img = img.resize((w, h), Image.Resampling.LANCZOS)
            img.save(dest, 'PNG')
            print(f"Saved {dest}")
