# Change Log for Amazon Corretto 15

The following sections describe the changes for each release of Amazon Corretto 15.

## January 2021 critical patch update: Corretto version 15.0.2.7.1

Release Date: January 20, 2021

**Target Platforms**

+  RPM-based Linux using glibc 2.12 or later, x86, x86_64
+  Debian-based Linux using glibc 2.12 or later, x86, x86_64
+  RPM-based Linux using glibc 2.17 or later, aarch64
+  Debian-based Linux using glibc 2.17 or later, aarch64
+  Alpine-based Linux, x86_64
+  Windows 7 or later, x86_64
+  macOS 10.13 and later, x86_64

The following issues are addressed in 15.0.2.7.1

 | Issue Name | Platform | Description | Link |
 | --- | --- | --- | --- |
 | Import jdk-15.0.2+7 | all |  Updates Corretto baseline to OpenJDK 15.0.2+7 | [jdk-15.0.2+7](https://github.com/openjdk/jdk15u/commit/03fb8436dc5f86be1a9633658d6295b9dc04fa0e) |
 | OSX build fails with Xcode 12.0 (12A7209) | os_x | see following link for detail | [JDK-8253375](https://bugs.openjdk.java.net/browse/JDK-8253375) |
 | libTestMainKeyWindow fails to build with Xcode 12.2  |  os_x  | see following link for detail  | [JDK-8256501](https://bugs.openjdk.java.net/browse/JDK-8256501) |
 | Issue with useAppleColor check in CSystemColors.m | os_x | see following link for detail | [JDK-8253791](https://bugs.openjdk.java.net/browse/JDK-8253791) |
 | Shenandoah: "adaptive" heuristic is prone to missing load spikes | all | see following link for detail | [JDK-8255984](https://bugs.openjdk.java.net/browse/JDK-8255984) |

This version addresses a number of vulnerabilities that do not have an associated CVE.

## October 2020 critical patch update: Corretto version 15.0.1.9.1

Release Date: October 20, 2020

**Target Platforms**

+  RPM-based Linux using glibc 2.12 or later, x86, x86_64
+  Debian-based Linux using glibc 2.12 or later, x86, x86_64
+  RPM-based Linux using glibc 2.17 or later, aarch64
+  Debian-based Linux using glibc 2.17 or later, aarch64
+  Alpine-based Linux, x86_64
+  Windows 7 or later, x86_64
+  macOS 10.13 and later, x86_64

The following CVE are addressed in 15.0.1.9.1.


| CVE | CVSS | Component |
| --- | --- | --- |
| CVE-2020-14803  | 5.3 | core-libs/java.io
| CVE-2020-14792  | 4.2 | hotspot/compiler
| CVE-2020-14782  | 3.7 | security-libs/java.security
| CVE-2020-14797  | 3.7 | core-libs/java.nio
| CVE-2020-14781  | 3.7 | core-libs/javax.naming
| CVE-2020-14779  | 3.7 | core-libs/java.io:serialization
| CVE-2020-14796  | 3.1 | core-libs/java.io
| CVE-2020-14798  | 3.1 | core-libs/java.io

**Known Issues**

+ The certificate_authorities extension, when enabled with -Djdk.tls.client.enableCAExtension=true, may not work with the default keystore provided with Corretto 15. If you would like to use this functionality, we recommend you provide a custom keystore.