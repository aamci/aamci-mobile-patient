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
