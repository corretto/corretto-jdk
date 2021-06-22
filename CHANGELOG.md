# Change Log for Amazon Corretto 16

The following sections describe the changes for each release of Amazon Corretto 16.

## Corretto version: 16.0.2.7.1

Release Date: July 20, 2021

**Target Platforms**

+  RPM-based Linux using glibc 2.12 or later, x86, x86_64
+  Debian-based Linux using glibc 2.12 or later, x86, x86_64
+  RPM-based Linux using glibc 2.17 or later, aarch64
+  Debian-based Linux using glibc 2.17 or later, aarch64
+  Alpine-based Linux, x86_64
+  Windows 7 or later, x86_64
+  macOS 10.13 and later, x86_64

The following issues are addressed in 16.0.2.7.1

| Issue Name | Platform | Description | Link |
| --- | --- | --- | --- |
| Import jdk-16.0.2.7.1 | All | Updates Corretto baseline to OpenJDK 16.0.2+7 | [jdk-16.0.2+7](https://github.com/openjdk/jdk16u/releases/tag/jdk-16.0.2%2B7)
| JDK-8266248 | macosx | Compilation failure in PLATFORM_API_MacOSX_MidiUtils.c with Xcode 12.5 | [JDK-8266248](https://bugs.openjdk.java.net/browse/JDK-8266248)

The following CVEs are addressed in 16.0.2.7.1

| CVE | CVSS | Component |
| --- | --- | --- |
| CVE-2021-2388 | 7.5 | hotspot/compiler
| CVE-2021-2369 | 4.3 | security-libs/java.security
| CVE-2021-2341 | 3.1 | core-libs/java.net


## Corretto version: 16.0.1.9.1

Release Date: April 20, 2021

**Target Platforms**

+  RPM-based Linux using glibc 2.12 or later, x86, x86_64
+  Debian-based Linux using glibc 2.12 or later, x86, x86_64
+  RPM-based Linux using glibc 2.17 or later, aarch64
+  Debian-based Linux using glibc 2.17 or later, aarch64
+  Alpine-based Linux, x86_64
+  Windows 7 or later, x86_64
+  macOS 10.13 and later, x86_64

The following issues are addressed in 16.0.1.9.1.

| Issue Name | Platform | Description | Link |
| --- | --- | --- | --- |
| Import jdk-16.0.1.9.1 | All | Updates Corretto baseline to OpenJDK 16.0.1+9 | [jdk-16.0.1+9](https://github.com/openjdk/jdk16u/releases/tag/jdk-16.0.1%2B9)

The following CVEs are addressed in 16.0.1.9.1

| CVE | CVSS | Component |
| --- | --- | --- |
| CVE-2021-2161  | 5.9 | core-libs/java.io
| CVE-2021-2163  | 5.3 | security-libs/java.security
