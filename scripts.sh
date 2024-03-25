# Don't accidentally run this
exit 0;

# Regenerate binaries.
mkdir -p bin/libauth_internal bin/jq
dd if=/dev/urandom bs=1 count=100000 of=bin/jq/jq.o
dd if=/dev/urandom bs=1 count=100000 of=bin/libauth_internal/libauth_internal.o
cp bin/jq/jq.o example-internal-project/include/libjson_internal/jq.o
cp bin/libauth_internal/libauth_internal.o example-internal-project/include/libauth_internal/libauth_internal.o

# Run a scan of our example "internal project"
fossa analyze example-internal-project \
  --project demo-project --revision $(date +%s) \
  --detect-vendored

# Notice that we discover two vendored dependencies: folly and tessaract.
# However, in our example, we also have some binaries that are built internally (in `include`) that we want to track.

# This internal auth library isn't source available; it's built and distributed internally by another team.
# Let's link that as a user-defined dependency:
fossa experimental-link-user-defined-dependency-binary bin/libauth_internal \
  --name libauth_internal \
  --version 1.0 \
  --license 'BSD-3-Clause' \
  --description 'Internal authentication library'

# The other library is an internal JSON parser.
# It also depends on another internal library, so let's link that as another user-defined dependency:
fossa experimental-link-user-defined-dependency-binary bin/jq \
  --name jq \
  --version 1.0 \
  --license 'GPL-2.0' \
  --description 'JSON processor' \
  --homepage 'https://github.com/stedolan/jq'

# Now that we've linked our dependencies, we can re-analyze our internal project:
fossa analyze example-internal-project \
  --project demo-project --revision $(date +%s) \
  --detect-vendored

# We now should see the dependencies that were vendored as before, but this time we also show the new dependencies we've linked.
# We also see the deep dependencies in the case of the our internal JSON parsing library, since it is also a project in FOSSA!
