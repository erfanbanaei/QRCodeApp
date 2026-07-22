# Google ML Kit barcode scanning (used by mobile_scanner)
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }

# Gal (gallery access) uses Apache Commons Imaging for format detection
-keep class org.apache.commons.imaging.** { *; }

# Keep annotations and generic signatures needed by Play Core / reflection-based plugins
-keepattributes Signature, InnerClasses, EnclosingMethod, *Annotation*
