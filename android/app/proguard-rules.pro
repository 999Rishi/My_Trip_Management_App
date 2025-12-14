# MLKit rules
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.dynamic.** { *; }
-keep class com.google.android.gms.dynamite.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep classes that are accessed via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep setters and getters
-keepclassmembers class * {
    *** set*(***);
    *** get*();
}

# Keep classes that are Parcelable
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}