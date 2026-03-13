# Zettle SDK ProGuard rules
-keep class com.zettle.** { *; }
-keep class com.izettle.** { *; }
-dontwarn com.zettle.**
-dontwarn com.izettle.**

# Keep SDK payment/refund result classes
-keepclassmembers class com.zettle.sdk.** { *; }
-keepclassmembers class com.zettle.sdk.feature.cardreader.** { *; }
