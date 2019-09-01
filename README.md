## Docker based development environment for Yocto on NXP / Freescale boards

Tested with the NXP i.MX6UL Evaluation Kit

### Scripts

- `build-docker-image.sh`
  - builds a Docker image locally, based on `docker/Dockerfile`
  - run this _once_, or when you change the Dockerfile
- `start.sh`
  - starts the Docker container
  - exit with ctrl+D
    - destroys the container
    - data in directories mounted as volumes (e.g. home, workspace) will be persisted
- `clone-layers.sh`
  - clones the Yocto layers needed by your project
  - run _once_ inside the Docker container
- `init-env`
  - initializes the environment variables, so you can issue commands like `bitbake` etc.
  - source it _every time_ you start the container: `source ./init-env`

### Directories

- `cache`
  - contains the locations used as Docker volume targets for the Yocto
    DL_DIR and SSTATE_DIR variables
  - set them in conf/local.conf:
  ```
      DL_DIR = /opt/yocto/cache/downloads
      SSTATE_DIR = /opt/yocto/cache/sstate
  ```
  - ignored by git
- `home`
  - Docker volume target for the home directory of the yocto user
  - allows you to add persistence for bash and git configuration, history, ssh keys etc.
  - is ignored by git, so to add something, you need to use `git add --force <file>`
- `conf`
  - create this directory to add Yocto config files
    (`build/conf/*.conf`) to source control
  - if it exists, `init-env` adds it to the workspace via symlink
- `workspace`
  - contains layers downloaded by `clone-layers.sh`, Yocto artifacts built by
    `bitbake`, (a symlink to) the configuration directory etc.
  - ignored by git

### Environment Setup

Make sure you have Ubuntu 18.04 or 16.04, other distros may or may not work.

Install Docker (see docs on the Docker site) and make sure you can start
containers as non-root user:

```
docker run --rm hello-world
```

- add the layers your project depends on to `clone-layers.sh`
  - you'll eventually have to add them to `conf/bblayers.conf`, too
- check `init-env`: make sure the right environment init script is sourced
  - see FSL Community BSP: https://github.com/Freescale/fsl-community-bsp-platform

Finally, proceed with the following (as a non-root user):

```
./build-docker-image.sh
./start.sh
./clone-layers.sh
. ./init-env
bitbake core-image-minimal
```

Copy `conf` from `workspace/build` to the project's root dir, in order to add
`local.conf`, `bblayers.conf` etc. to the git repo.

### Working with the Docker Environment

```
./start.sh
. ./init-env
bitbake core-image-minimal
```

### Creating an SD Card Image

Creating an image using bitbake generates a compressed wic file in
workspace/build/tmp/deploy/images. For example, a
`bitbake core-image-minimal` on imx6ulevk will generate
`workspace/build/tmp/deploy/images/imx6ulevk/core-image-minimal-imx6ulevk.wic.gz`

Use balenaEtcher (https://www.balena.io/etcher) to write it to an SD card.

Connect to the board via USB, then use `serial.sh` to watch it boot.
