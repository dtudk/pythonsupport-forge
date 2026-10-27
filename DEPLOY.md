# Deployment of the DTU conda installers

#. Create a new branch and push to your local remote.

#. Create a pull-request which kicks the CI to run.

#. Once finished merge with a tag to start CI with release.
   A release is ever only done when its associated with a tag.


# Updating CI

The CI is basically a copy of the `miniforge` CI files.
They are constantly updating it, so we have to adapt to a certain
degree.

The current step is to rely on a dispatch runner that `uses` the CI.

See `.github/workflows/deploy.yml` which uses this file:

- `.github/workflows/ci.yml`

  This file is a copy of `miniforge/.github/workflows/ci.yml`
  with some minor edits:

  #. Enabled sub-modules in checkout
     Step: Checkout Code

  #. Disabled APPLE-signing
     Step: Prepare certificates (macOS)

     (not really necessary as it checks for env-var existance)

  #. Adding preparation script.
     This needs to be run before the actual build.

     Step: *before* Build and test miniforge

  #. Updating build infrastructure.

     Step: Build and test miniforge

     These changes are necessary:

     1. `cd miniforge`
     2. Remove `export MINIFORGE_VERSION`, we are DTU miniforge.

  #. Remove Windows signature steps
     Steps:
      - Sign files with Artifact Signing (Windows)
      - Verify signatures and checksums (Windows)

  #. Change upload artifacts to reflect the folder structure.

     Add `miniforge/` to path.

     Step: Upload miniforge to Github artifact/release

  #. Disabled offline tests. They don't work, don't know why.

And that should be it.
