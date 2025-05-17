# golang-multi-version-installation

Managing multiple golang versions can be a bit of a pain, so hopefully this makes it a little bit easier.

## Installation

To install multiple golang versions just execute the installation script:

```bash
/path/to/checkout/src/install-golangs.sh
```

## Setting a new version

To set the environment variables correctly you must source the script, not just execute it:

```bash
source /path/to/checkout/src/set-current-golang.sh "1.20.14"
```

If you want to set this as a default for all your shell session, then consider including it in your bash/zsh profile/rc.
