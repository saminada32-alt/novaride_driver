-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-keep class com.google.maps.android.** { *; }
-dontwarn com.google.android.gms.**

# Location / Geolocator
-keep class com.baseflow.geolocator.** { *; }
-keep class com.lyokone.location.** { *; }

# Flutter plugins commonly stripped on release
-keep class io.flutter.plugins.** { *; }
-keep class com.dexterous.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
