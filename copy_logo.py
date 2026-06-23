import shutil
import os

src = r"C:\Users\hp\.gemini\antigravity-ide\brain\3425822a-97ea-468e-abde-f353ee635677\media__1782211615681.png"
dst = r"c:\Projects\veggie mart\riverpod_project\assets\logo.png"

# Ensure assets directory exists
os.makedirs(os.path.dirname(dst), exist_ok=True)
shutil.copy(src, dst)
print("Logo copied successfully!")
