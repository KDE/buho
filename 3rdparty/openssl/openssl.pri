# includes openssl libs onto android build

android {
  ANDROID_EXTRA_LIBS += $$PWD/lib/libcrypto.so
  ANDROID_EXTRA_LIBS += $$PWD/lib/libssl.so
}
