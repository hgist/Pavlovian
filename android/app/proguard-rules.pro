# Pavlovian — ProGuard / R8 rules for release builds.
#
# Root cause caught via in-app Diagnostics on 2026-06-06:
#   `scheduleAll` aborted at the first `_plugin.cancel()` call with
#     "Missing type parameter."
#   ← Gson's TypeToken<ArrayList<NotificationDetails>> lost its generic
#     signature after R8 obfuscation. Without the rules below, ALL
#     scheduled notifications fail to register in release mode.

# ── Gson — keep generic-type information used by TypeToken ──
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep Gson itself & any TypeToken subclasses (incl. anonymous ones)
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.TypeAdapter
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# ── flutter_local_notifications — model classes (de-)serialized by Gson ──
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-keep enum com.dexterous.flutterlocalnotifications.** { *; }
