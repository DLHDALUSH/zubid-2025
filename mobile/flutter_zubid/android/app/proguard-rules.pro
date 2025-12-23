# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Gson specific rules
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# OkHttp specific rules
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Retrofit specific rules
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions

# Keep model classes (adjust package names as needed)
-keep class com.zubid.auction.models.** { *; }
-keep class com.zubid.auction.data.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep setters in Views so that animations can still work.
-keepclassmembers public class * extends android.view.View {
    void set*(***);
    *** get*();
}

# Keep classes that are referenced in XML layouts
-keep public class * extends android.view.View
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable implementations
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep annotation classes
-keep class * extends java.lang.annotation.Annotation { *; }

# Firebase specific rules (if using Firebase)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# WebView specific rules
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Keep crash reporting classes
-keep class com.crashlytics.** { *; }
-dontwarn com.crashlytics.**

# Keep analytics classes
-keep class com.google.analytics.** { *; }
-keep class com.mixpanel.** { *; }

# Capacitor specific rules
-keep class com.getcapacitor.** { *; }
-keep class com.capacitorjs.** { *; }

# Cordova specific rules
-keep class org.apache.cordova.** { *; }

# Keep WebRTC classes (if using for video calls)
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# Keep payment SDK classes
-keep class com.stripe.** { *; }
-keep class com.paypal.** { *; }

# Keep biometric authentication classes
-keep class androidx.biometric.** { *; }
-keep class androidx.fingerprint.** { *; }

# Keep camera and image processing classes
-keep class androidx.camera.** { *; }
-keep class com.bumptech.glide.** { *; }

# Keep notification classes
-keep class androidx.work.** { *; }
-keep class com.google.firebase.messaging.** { *; }

# Optimize and obfuscate
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose
