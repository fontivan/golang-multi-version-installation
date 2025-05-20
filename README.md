# golang-multi-version-installation

Managing multiple golang versions can be a bit of a pain, so hopefully this makes it a little bit easier.

## Installation

To install multiple golang versions just execute the installation script:

```bash
/path/to/checkout/src/install-golangs.sh i 1.20.4
```

## Setting a new version

To set the environment variables correctly you must eval it to set the variables in your current session:

```bash
eval $(/path/to/checkout/golang-multi-version-installation/src/set-current-golang.sh 1.20.14)
```

If you want to set this as a default for all your shell session, then consider including it in your bash/zsh profile/rc.

## Checking installed versions

The alternative versions will be installed to `/usr/local/bin/golang-alts`.

```bash
$> ls -lah /usr/local/bin/go-alts/              
total 0
drwxr-xr-x. 1 root root  14 May 17 14:52 .
drwxr-xr-x. 1 root root 332 May 17 14:21 ..
drwxr-xr-x. 1 root root   4 May 17 14:52 1.20.14
```

## Checking for new versions

Any version releaseed on the official golang website should work: https://go.dev/dl/
