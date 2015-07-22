Debify
===

Debify takes a directory full of Debian packages and creates a signed and properly-structured
Debian repository out of them.

Usage
---
Run the Debify image, mounting two volumes to special mount points:

1. `/.gnpug`: Mount your GPG directory containing the key you want to sign the repository with here.

2. `/debs`: Mount a directory containing all your Debian packages here.

A tarball of the resulting Debian repository will be written to `/debs/repo.tar.gz`.

If you specify `URI` and `KEYSERVER` enviornment variables, the tarball will also contain a `go`
script for setting up the repository.

### Example

Let's say I have a bunch of Debian packages at `~/my-debs`, and I've imported or [created a GPG key](http://fedoraproject.org/wiki/Creating_GPG_Keys)
for signing everything with. Here's how I might run Debify if I plan on publishing the repo to
http://example.com/apt:

    $ docker run -e URI=http://example.com/apt \
                 -e KEYSERVER=keyserver.ubuntu.com \
                 -v ~/.gnupg:/.gnupg \
                 -v ~/my-debs:/debs \
                 spotify/debify

Serving
---
As an example, if you publish the contents of the tarball to `http://example.com/apt`, users can
consume it like this:

    $ curl -sSL http://example.com/apt/go | sudo sh
    $ apt-get install <your-package>

Note that this presupposes that you've [published the GPG key](http://fedoraproject.org/wiki/Creating_GPG_Keys#Making_Your_Public_Key_Available)
used to sign the artifacts to keyserver.ubuntu.com.

If you haven't published the key, Debify will not generate a `go` script. Your users will manually
need to add your key using `apt-key add` and then add your repo to their `sources.list` by hand.
Barbaric.

Configuration
---
Here are some optional environment variables you can specify when running a Debify container:

* `GPG_PASSPHRASE`: A passphrase to use when running GPG, if you need it.

* `GPG_PASSPHRASE_FILE`: A passphrase file to use when running GPG, if you need it (hint: mount this
  file into the container somewhere and specify the path in the container).

* `APTLY_DISTRIBUTION`: Defaults to `unstable`. Some projects may choose to use a specific Debian
  distribution (wheezy, trusty, jessie, etc.), while cross-distribution packages might want to just
  use the project name (for example, "docker").

* `APTLY_ARCHITECTURES`: List of architectures to consider. Will try to guess if not provided.

* `APTLY_COMPONENT`: Defaults to `main`. See [the Debian wiki](https://wiki.debian.org/RepositoryFormat#Components)
  if you're confused about this.

* `KEYSERVER`: Defaults to `keyserver.ubuntu.com`. The keyserver where your GPG key has been published.
  Used for the `go` script.

* `URI`: The URI where this Debian repo will be published. Used for the `go` script.

Under the Covers
---
Debify is a wrapper around [Aptly](http://www.aptly.info/).

### Build & release

Build with `docker build .`. Released via an automatic build on [the Docker Hub](https://hub.docker.com/).
