#!/bin/bash
set -e

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  TARGET="$(readlink "$SOURCE")"
  if [[ $TARGET == /* ]]; then
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    SOURCE="$DIR/$TARGET" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done
RDIR="$( dirname "$SOURCE" )"
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Figure out where this script is located.
LIBDIR="`cd \"$DIR\" && cd ../lib && pwd`"

# Tell Bundler where the Gemfile and gems are.
export BUNDLE_GEMFILE="$LIBDIR/vendor/Gemfile"
unset BUNDLE_IGNORE_CONFIG

# Run the actual app using the bundled Ruby interpreter, with Bundler activated.
exec "$LIBDIR/ruby/bin/ruby" -rreadline -rbundler/setup -I$LIBDIR/app/lib "$LIBDIR/app/pact-mock-service.rb" $@
