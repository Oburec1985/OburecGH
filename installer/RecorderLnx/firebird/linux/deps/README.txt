Put offline Debian dependency packages here (*.deb).

The installer runs:

  dpkg -i deps/*.deb

before installing Firebird. It does not use apt repositories in the default
offline mode.

If Firebird reports missing shared libraries, run:

  bash check-firebird-recorderlnx.sh

and add the required packages to this folder.
