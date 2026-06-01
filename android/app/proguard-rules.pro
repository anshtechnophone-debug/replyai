# Suppress missing optional ML Kit language pack classes
# (only Latin script is used; Chinese/Japanese/Korean/Devanagari packs are not included)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep the ML Kit classes that ARE included
-keep class com.google_mlkit_text_recognition.** { *; }
-keep class com.google.mlkit.vision.text.TextRecognizer { *; }
-keep class com.google.mlkit.vision.text.Text { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }
