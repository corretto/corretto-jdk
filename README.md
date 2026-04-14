## Corretto JDK

Amazon Corretto is a no-cost, multiplatform,
production-ready distribution of the Open Java Development Kit (OpenJDK).
Corretto is used internally at Amazon for production services.
With Corretto, you can develop and run Java applications
on operating systems such as Linux, Windows, and macOS.

This repository is used to track [OpenJDK upstream tip](https://github.com/openjdk/jdk).
Please look at the branches section for more information on Feature Releases.

Documentation is available at [https://docs.aws.amazon.com/corretto](https://docs.aws.amazon.com/corretto).

### Licenses and Trademarks

Please read these files: "LICENSE", "ADDITIONAL_LICENSE_INFO", "ASSEMBLY_EXCEPTION", "TRADEMARKS.md".

### Branches

_develop_
: The default branch. The branch that consumes development and patches to upstream jdk. Corretto builds are generated from this branch.

_upstream-jdk_
: The branch is similar to master at [openjdk/jdk](https://github.com/openjdk/jdk). This branch merges into develop.

### Download Links
Corretto tip nightly builds can be found on our [download page](https://downloads.corretto.aws/#/downloads?build=nightly&version=tip).

Production and nightly builds for all Corretto versions can be found at [downloads.corretto.aws/#/overview](https://downloads.corretto.aws/#/overview).


### OpenJDK Readme
```

Welcome to the JDK!
===================

For build instructions please see the
[online documentation](https://git.openjdk.org/jdk/blob/master/doc/building.md),
or either of these files:

  * doc/building.html   (html version)
  * doc/building.md     (markdown version)

See <https://openjdk.org/> for more information about the OpenJDK
Community and the JDK and see <https://bugs.openjdk.org> for JDK issue
tracking.
