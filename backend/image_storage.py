"""
Image Storage Service for ZUBID
Supports both local file storage and Cloudinary cloud storage.
Uses Cloudinary in production for persistent storage across deployments.
"""

import os
import logging
from datetime import datetime, timezone
from werkzeug.utils import secure_filename

logger = logging.getLogger(__name__)

# Storage configuration
CLOUDINARY_ENABLED = os.getenv('CLOUDINARY_ENABLED', 'false').lower() == 'true'
CLOUDINARY_CLOUD_NAME = os.getenv('CLOUDINARY_CLOUD_NAME', '')
CLOUDINARY_API_KEY = os.getenv('CLOUDINARY_API_KEY', '')
CLOUDINARY_API_SECRET = os.getenv('CLOUDINARY_API_SECRET', '')

# Local storage configuration
UPLOAD_FOLDER = os.getenv('UPLOAD_FOLDER', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'uploads'))
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}
ALLOWED_VIDEO_EXTENSIONS = {'mp4', 'webm', 'ogg', 'mov', 'avi', 'mkv', 'm4v'}

# Initialize Cloudinary if enabled
cloudinary_configured = False
if CLOUDINARY_ENABLED and CLOUDINARY_CLOUD_NAME and CLOUDINARY_API_KEY and CLOUDINARY_API_SECRET:
    try:
        import cloudinary
        import cloudinary.uploader
        import cloudinary.api

        cloudinary.config(
            cloud_name=CLOUDINARY_CLOUD_NAME,
            api_key=CLOUDINARY_API_KEY,
            api_secret=CLOUDINARY_API_SECRET,
            secure=True
        )
        cloudinary_configured = True
        logger.info("Cloudinary configured successfully")
    except ImportError:
        logger.warning("Cloudinary package not installed. Using local storage.")
    except Exception as e:
        logger.error(f"Failed to configure Cloudinary: {e}")

def allowed_file(filename):
    """Check if file extension is allowed for images"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def allowed_video_file(filename):
    """Check if file extension is allowed for videos"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_VIDEO_EXTENSIONS

def generate_unique_filename(original_filename, user_id, prefix=''):
    """Generate a unique filename with timestamp"""
    filename = secure_filename(original_filename)
    if not filename:
        filename = 'image.jpg'
    timestamp = datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')
    if prefix:
        return f"{prefix}_{timestamp}_{user_id}_{filename}"
    return f"{timestamp}_{user_id}_{filename}"

def upload_image(file, user_id, folder='auctions', is_profile=False, is_featured=False):
    """
    Upload an image to storage (Cloudinary or local).

    Args:
        file: File object from request.files
        user_id: ID of the user uploading
        folder: Cloudinary folder name (auctions, profiles, qrcodes)
        is_profile: True if this is a profile photo
        is_featured: True if this is a featured auction image

    Returns:
        dict with 'url' and 'public_id' (for Cloudinary) or 'filename' (for local)
        or None if upload fails
    """
    try:
        prefix = 'profile' if is_profile else ''
        unique_filename = generate_unique_filename(file.filename, user_id, prefix)

        if cloudinary_configured:
            return _upload_to_cloudinary(file, unique_filename, folder, is_featured)
        else:
            return _upload_to_local(file, unique_filename)
    except Exception as e:
        logger.error(f"Error uploading image: {e}")
        return None

def _upload_to_cloudinary(file, filename, folder, is_featured=False):
    """Upload image to Cloudinary"""
    try:
        import cloudinary.uploader

        # Set transformation options
        transformation = []
        if is_featured:
            # Featured images: optimize for carousel (1920x600)
            transformation = [
                {'width': 1920, 'height': 600, 'crop': 'fill', 'gravity': 'auto'},
                {'quality': 'auto:best', 'fetch_format': 'auto'}
            ]
        else:
            # Regular images: max 1920x1920, auto quality
            transformation = [
                {'width': 1920, 'height': 1920, 'crop': 'limit'},
                {'quality': 'auto:good', 'fetch_format': 'auto'}
            ]

        # Remove extension from filename for public_id
        public_id = filename.rsplit('.', 1)[0] if '.' in filename else filename

        result = cloudinary.uploader.upload(
            file,
            public_id=f"zubid/{folder}/{public_id}",
            overwrite=True,
            resource_type='image',
            transformation=transformation,
            eager_async=True
        )

        logger.info(f"Image uploaded to Cloudinary: {result['secure_url']}")

        return {
            'url': result['secure_url'],
            'public_id': result['public_id'],
            'filename': filename,
            'storage': 'cloudinary'
        }
    except Exception as e:
        logger.error(f"Cloudinary upload failed: {e}")
        return None

def _upload_to_local(file, filename):
    """Upload image to local storage"""
    try:
        # Ensure upload directory exists
        if not os.path.exists(UPLOAD_FOLDER):
            os.makedirs(UPLOAD_FOLDER)

        filepath = os.path.join(UPLOAD_FOLDER, filename)

        # Security check
        if not os.path.abspath(filepath).startswith(os.path.abspath(UPLOAD_FOLDER)):
            logger.error(f"Path traversal attempt: {filename}")
            return None

        file.save(filepath)

        # Return relative URL for local storage
        url = f"/uploads/{filename}"

        logger.info(f"Image uploaded locally: {url}")

        return {
            'url': url,
            'filename': filename,
            'filepath': filepath,
            'storage': 'local'
        }
    except Exception as e:
        logger.error(f"Local upload failed: {e}")
        return None


def upload_video(file, user_id, folder='videos'):
    """
    Upload a video to storage (Cloudinary or local).

    Args:
        file: File object from request.files
        user_id: ID of the user uploading
        folder: Cloudinary folder name

    Returns:
        dict with 'url' and 'public_id' (for Cloudinary) or 'filename' (for local)
        or None if upload fails
    """
    try:
        unique_filename = generate_unique_filename(file.filename, user_id, 'video')

        if cloudinary_configured:
            return _upload_video_to_cloudinary(file, unique_filename, folder)
        else:
            return _upload_to_local(file, unique_filename)
    except Exception as e:
        logger.error(f"Error uploading video: {e}")
        return None

def _upload_video_to_cloudinary(file, filename, folder):
    """Upload video to Cloudinary"""
    try:
        import cloudinary.uploader

        public_id = filename.rsplit('.', 1)[0] if '.' in filename else filename

        result = cloudinary.uploader.upload(
            file,
            public_id=f"zubid/{folder}/{public_id}",
            resource_type='video',
            overwrite=True,
            eager=[
                {'format': 'mp4', 'video_codec': 'h264', 'audio_codec': 'aac'}
            ],
            eager_async=True
        )

        logger.info(f"Video uploaded to Cloudinary: {result['secure_url']}")

        return {
            'url': result['secure_url'],
            'public_id': result['public_id'],
            'filename': filename,
            'storage': 'cloudinary'
        }
    except Exception as e:
        logger.error(f"Cloudinary video upload failed: {e}")
        return None

def delete_image(url_or_public_id, is_cloudinary=None):
    """
    Delete an image from storage.

    Args:
        url_or_public_id: URL or Cloudinary public_id
        is_cloudinary: Override storage detection

    Returns:
        True if deleted, False otherwise
    """
    try:
        # Detect storage type
        if is_cloudinary is None:
            is_cloudinary = 'cloudinary.com' in str(url_or_public_id) or 'res.cloudinary.com' in str(url_or_public_id)

        if is_cloudinary and cloudinary_configured:
            return _delete_from_cloudinary(url_or_public_id)
        else:
            return _delete_from_local(url_or_public_id)
    except Exception as e:
        logger.error(f"Error deleting image: {e}")
        return False

def _delete_from_cloudinary(url_or_public_id):
    """Delete image from Cloudinary"""
    try:
        import cloudinary.uploader

        # Extract public_id from URL if needed
        if 'cloudinary.com' in url_or_public_id:
            # URL format: https://res.cloudinary.com/cloud_name/image/upload/v123/folder/public_id.ext
            parts = url_or_public_id.split('/upload/')
            if len(parts) > 1:
                public_id = parts[1].rsplit('.', 1)[0]  # Remove extension
                # Remove version prefix if present (v123456789/)
                if public_id.startswith('v') and '/' in public_id:
                    public_id = '/'.join(public_id.split('/')[1:])
            else:
                public_id = url_or_public_id
        else:
            public_id = url_or_public_id

        result = cloudinary.uploader.destroy(public_id)
        logger.info(f"Deleted from Cloudinary: {public_id}, result: {result}")
        return result.get('result') == 'ok'
    except Exception as e:
        logger.error(f"Cloudinary delete failed: {e}")
        return False

def _delete_from_local(url_or_filename):
    """Delete image from local storage"""
    try:
        # Extract filename from URL if needed
        if url_or_filename.startswith('/uploads/'):
            filename = url_or_filename.replace('/uploads/', '')
        elif url_or_filename.startswith('uploads/'):
            filename = url_or_filename.replace('uploads/', '')
        else:
            filename = url_or_filename

        filename = secure_filename(filename)
        filepath = os.path.join(UPLOAD_FOLDER, filename)

        # Security check
        if not os.path.abspath(filepath).startswith(os.path.abspath(UPLOAD_FOLDER)):
            logger.error(f"Path traversal attempt on delete: {filename}")
            return False

        if os.path.exists(filepath):
            os.remove(filepath)
            logger.info(f"Deleted local file: {filepath}")
            return True
        else:
            logger.warning(f"File not found for deletion: {filepath}")
            return False
    except Exception as e:
        logger.error(f"Local delete failed: {e}")
        return False

def get_storage_info():
    """Get current storage configuration info"""
    return {
        'storage_type': 'cloudinary' if cloudinary_configured else 'local',
        'cloudinary_enabled': CLOUDINARY_ENABLED,
        'cloudinary_configured': cloudinary_configured,
        'upload_folder': UPLOAD_FOLDER
    }
