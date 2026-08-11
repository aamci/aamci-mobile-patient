# Flutter wrapper
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# JSON serialization (used by app models)
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Flutter secure storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Biometric
-keep class androidx.biometric.** { *; }

# Play Core (referenced by Flutter deferred components — not used but R8 needs to ignore them)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
