# Google ML Kit barcode scanning (used by mobile_scanner)
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }

# Gal (gallery access) uses Apache Commons Imaging for format detection.
-keep class org.apache.commons.imaging.** { *; }
# commons-imaging references desktop-only java.awt / javax.imageio classes that do
# not exist on Android. They are never reached at runtime (only PNG/JPEG paths are
# used), so silence R8 instead of letting the missing references fail the build.
-dontwarn java.awt.**
-dontwarn javax.imageio.**
-dontwarn org.apache.commons.imaging.**

# Keep annotations and generic signatures needed by Play Core / reflection-based plugins
-keepattributes Signature, InnerClasses, EnclosingMethod, *Annotation*
