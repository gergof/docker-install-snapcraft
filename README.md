# docker-install-snapcraft
A script that can be executed in a dockerfile to have a working snapcraft installation.

You can not by default install snapd in a docker container, so you can use this script to have a working installation of snapcraft.

This is inspired by the [snapcraft dockerfile](https://github.com/snapcore/snapcraft/blob/main/docker/Dockerfile).

#### Usage

Paste this into your dockerfile:

```dockerfile
RUN apt-get update && \
	wget https://raw.githubusercontent.com/gergof/docker-install-snapcraft/master/docker-install-snapcraft.sh && \
	chmod +x docker-install-snapcraft.sh && \
	./docker-install-snapcraft.sh 16

ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"
ENV PATH="/snap/bin:/snap/snapcraft/current/usr/bin:$PATH"
ENV SNAP="/snap/snapcraft/current"
ENV SNAP_NAME="snapcraft"
ENV SNAP_ARCH="amd64"
```

The script accepts one parameter, the ubuntu series number. This can be requested by running `snap version`. It defaults to 16 (used for ubuntu xenial and debian 10).
