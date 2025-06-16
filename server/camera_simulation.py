import base64, asyncio
import os, random, glob, cv2, numpy as np
from datetime import datetime, timezone


def simulate_camera_capture(image_folder_path):
    image_files = glob.glob(os.path.join(image_folder_path, "*.jpg")) + \
                  glob.glob(os.path.join(image_folder_path, "*.png"))

    if not image_files:
        raise FileNotFoundError("No images found in the provided folder.")

    image_path = random.choice(image_files)

    rgb_image = cv2.imread(image_path)
    rgb_image = cv2.resize(rgb_image, (1280, 720))

    depth_map = np.random.uniform(0.5, 5.0, (720, 1280)).astype(np.float32)

    timestamp = datetime.now().isoformat(timespec='milliseconds')

    return rgb_image, depth_map, timestamp, image_path


def encode_array_to_base64(arr, is_depth=False):
    if is_depth:
        arr = arr.astype(np.float32)
        depth_norm = cv2.normalize(arr, None, 0, 255, cv2.NORM_MINMAX)
        depth_uint8 = depth_norm.astype(np.uint8)
        _, buffer = cv2.imencode('.png', depth_uint8)
    else:
        if arr.dtype != np.uint8:
            arr = arr.astype(np.uint8)
        _, buffer = cv2.imencode('.png', arr)

    return base64.b64encode(buffer.tobytes()).decode('utf-8')