# Vapor APT

## Add new package/version

You need to create the package in each Ubuntu version folder. The folder need to be called:

`<packageName>_<packageVersion>`

Inside the folder you need the following structure:

`src/`

`build.yaml`

You can optionally add a `postinst` file, a bash script, that should run after install.

### src folder

Here you need to place the sourcecode to be installed.

### build.yaml file

This is a Yaml file instructing the system how to build the package.

Example:

```
package: "swift"
version: "3.1.1"

dependencies:
    - "clang"
    - "libicu-dev"
    - "libcurl3"

description: "Swift programming language"

postinst: true
```

From the example:

`package:` The package name it will translate into `apt-get install <package>`

`version:` Package version

`dependencies:` A list of other APT programs the package depends on

`description:` Description of the package (Need to be the same for each version of the same package)

### Version guide

Basically version need to be semver (x.x.x)

#### Swift pre release

For Swift beta, the version should be e.g. `4.0.0~20170915` the part after `~` is the release date.
