# Change Log for Amazon Corretto 15

The following sections describe the changes for each release of Amazon Corretto 15.

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