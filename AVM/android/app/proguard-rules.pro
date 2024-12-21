# Flutter-Specific Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase Rules (add if you use Firebase services)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Firebase JSON serialized fields
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Rules for your device calendar plugin
-keep class com.builttoroam.devicecalendar.** { *; }

# Gson or Serialization Library Rules (if used)
-keepclassmembers class * {
   @com.google.gson.annotations.SerializedName <fields>;
}
-dontwarn sun.misc.**

# Rules for Glide (if used for image loading)
-keep class com.bumptech.glide.** { *; }
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep public class * extends com.bumptech.glide.AppGlideModule
-keep public class * extends com.bumptech.glide.annotation.GlideModule

# Keep Generated AutoValue Classes (if you use AutoValue or similar)
-keep @com.google.auto.value.AutoValue public class *

# Generic Rules to Avoid Over-Shrinking
-dontwarn **.R
-dontwarn **.R$*
-dontwarn sun.misc.Unsafe
-dontwarn android.content.res.**

# Keep Attributes
-keepattributes InnerClasses
-keepattributes Annotation

# Multidex (if enabled)
-keep class androidx.multidex.** { *; }

# Prevent Removal of Resources
-keep class **.R$* { *; }