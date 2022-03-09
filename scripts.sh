# Don't accidentally run this
exit 0;

# Regenerate binaries
mkdir -p bin/libjson_internal bin/libauth_internal bin/jq
dd if=/dev/urandom bs=1 count=100000 of=bin/libjson_internal/libjson_internal.o
dd if=/dev/urandom bs=1 count=100000 of=bin/libauth_internal/libauth_internal.o
dd if=/dev/urandom bs=1 count=100000 of=bin/jq/jq.o
cp bin/jq/jq.o internal-json-parser/vendor/jq.o
cp bin/libauth_internal/libauth_internal.o example-internal-project/include/libauth_internal/libauth_internal.o
cp bin/libjson_internal/libjson_internal.o example-internal-project/include/libjson_internal/libjson_internal.o

# Run a scan of our example "internal project"
fossa analyze example-internal-project \
  -e '<endpoint>' --fossa-api-key <api-key> \
  --project internal-project --revision $(date +%s) \
  --enable-vsi

# Notice that we discover two vendored dependencies: folly and tessaract.
# However, in our example, we also have some binaries that are built internally (in `include`) that we want to track.

# This internal auth library isn't source available; it's built and distributed internally by another team.
# Let's link that as a user-defined dependency:
fossa experimental-link-user-defined-dependency-binary bin/libauth_internal \
  -e '<endpoint>' --fossa-api-key <api-key> \
  --name libauth_internal \
  --version 1.0 \
  --license 'BSD-3-Clause' \
  --description 'Internal authentication library'

# The other library is an internal JSON parser.
# It also depends on another internal library, so let's link that as another user-defined dependency:
fossa experimental-link-user-defined-dependency-binary bin/jq \
  -e '<endpoint>' --fossa-api-key <api-key> \
  --name jq \
  --version 1.0 \
  --license 'GPL-2.0' \
  --description 'JSON processor' \
  --homepage 'https://github.com/stedolan/jq'

# Now let's scan the JSON parser in FOSSA, and link its output binary:
fossa analyze internal-json-parser \
  -e '<endpoint>' --fossa-api-key <api-key> \
  --project internal-json-parser --revision $(date +%s) \
  --experimental-link-project-binary bin/libjson_internal \
  --enable-vsi

# Now that we've linked our dependencies, we can re-analyze our internal project:
fossa analyze example-internal-project \
  -e '<endpoint>' --fossa-api-key <api-key> \
  --project internal-project --revision $(date +%s) \
  --enable-vsi

# We now should see the dependencies that were vendored as before, but this time we also show the new dependencies we've linked.
# We also see the deep dependencies in the case of the our internal JSON parsing library, since it is also a project in FOSSA!

# We can also use our support for static linking to identify known project source code, not just binaries, by linking the project "to itself".
# Scan and record `librayon`. Wait for the build to complete and note its dependencies:
fossa analyze librayon \
  -e '<endpoint>' --fossa-api-key <api-key> \
  --project librayon --revision $(date +%s) \
  --experimental-link-project-binary librayon

# Now if we copy `librayon` into `example-internal-project`, we can identify it with VSI!
# Note how after this scan completes, we now also see `librayon` in the dependencies, and its dependencies as deep deps.
cp -r librayon example-internal-project/vendor/librayon
fossa analyze example-internal-project \
  -e '<endpoint>' --fossa-api-key <api-key> \
  --project internal-project --revision $(date +%s) \
  --enable-vsi

# And finally, cleanup.
rm -rf example-internal-project/vendor/librayon
