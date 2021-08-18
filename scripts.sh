# Don't accidentally run this
exit 0;

# Run a scan of our example "internal project"
fossa analyze ~/projects/scratch/cpp-demo/example-internal-project \
  -e '<endpoint>' --fossa-api-key <api-key> \
  --project internal-project --revision (date +%s) \
  --enable-vsi

# Notice that we discover two vendored dependencies: folly and tessaract.
# However, in our example, we also have some binaries that are built internally (in `include`) that we want to track.

# This internal auth library isn't source available; it's built and distributed internally by another team.
# Let's link that as a user-defined dependency:
fossa experimental-link-user-defined-dependency-binary ~/projects/scratch/cpp-demo/bin/libauth_internal \
  -e '<endpoint>' --fossa-api-key <api-key> \
  --name libauth_internal \
  --version 1.0 \
  --license 'BSD-3-Clause' \
  --description 'Internal authentication library'

# The other library is an internal JSON parser.
# It also depends on another internal library, so let's link that as another user-defined dependency:
fossa experimental-link-user-defined-dependency-binary ~/projects/scratch/cpp-demo/bin/jq \
  -e '<endpoint>' --fossa-api-key <api-key> \
  --name jq \
  --version 1.0 \
  --license 'GPL-2.0' \
  --description 'JSON processor' \
  --homepage 'https://github.com/stedolan/jq'

# Now let's scan the JSON parser in FOSSA, and link its output binary:
fossa analyze ~/projects/scratch/cpp-demo/internal-json-parser \
  -e '<endpoint>' --fossa-api-key <api-key> \
  --project internal-json-parser --revision (date +%s) \
  --experimental-link-project-binary ~/projects/scratch/cpp-demo/bin/libjson_internal \
  --enable-vsi

# Now that we've linked our dependencies, we can re-analyze our internal project:
fossa analyze ~/projects/scratch/cpp-demo/example-internal-project \
  -e '<endpoint>' --fossa-api-key <api-key> \
  --project internal-project --revision (date +%s) \
  --enable-vsi

# We now should see the three dependencies that were vendored as before, but this time we also show the new dependencies we've linked.
# We also see the deep dependencies in the case of the our internal JSON parsing library, since it is also a project in FOSSA!