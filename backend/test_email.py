#!/usr/bin/env python3
"""
Test script to verify email configuration
Run this to test if email sending is working properly
"""

import os
import sys
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def test_email():
    """Test email sending functionality"""
    
    # Import the send_email function from app.py
    sys.path.append(os.path.dirname(os.path.abspath(__file__)))
    
    try:
        from app import send_email
        
        print("🧪 Testing email configuration...")
        print(f"📧 SMTP Host: {os.getenv('SMTP_HOST')}")
        print(f"📧 SMTP Port: {os.getenv('SMTP_PORT')}")
        print(f"📧 SMTP User: {os.getenv('SMTP_USER')}")
        print(f"📧 SMTP From: {os.getenv('SMTP_FROM')}")
        
        # Test email
        test_recipient = os.getenv('SMTP_USER')  # Send to yourself for testing
        subject = "🔐 ZUBID - Email Configuration Test"
        body = """Hello!

This is a test email to verify that your ZUBID email configuration is working correctly.

If you received this email, your SMTP settings are properly configured! 🎉

Test Details:
- Timestamp: """ + str(os.times()) + """
- Configuration: Gmail SMTP
- Purpose: Password reset functionality testing

Best regards,
ZUBID Auction Team"""

        print(f"\n📤 Sending test email to: {test_recipient}")
        
        success = send_email(test_recipient, subject, body)
        
        if success:
            print("✅ Email sent successfully!")
            print("📬 Check your inbox for the test email")
            print("\n🎉 Email configuration is working correctly!")
            print("💡 Forgot password functionality should now work properly")
        else:
            print("❌ Email sending failed!")
            print("\n🔧 Troubleshooting tips:")
            print("1. Check if 2-Factor Authentication is enabled on Gmail")
            print("2. Use App Password instead of regular password")
            print("3. Verify SMTP credentials are correct")
            print("4. Check internet connection and firewall settings")
            
    except ImportError as e:
        print(f"❌ Could not import send_email function: {e}")
        print("Make sure you're running this from the backend directory")
    except Exception as e:
        print(f"❌ Test failed with error: {e}")

if __name__ == "__main__":
    test_email()
