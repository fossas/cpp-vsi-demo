# CPP Demo

This project demonstrates the minimal functionality for FOSSA C/C++ support via VSI and IAT.

# How to run

1. Clone this project locally.
1. Install the [fossa CLI](https://github.com/fossas/fossa-cli/releases) somewhere in your `$PATH`.
1. Follow along in `scripts.sh`- the comments describe the demo flow. Fill in the placeholders (denoted by `<` and `>`) for the commands when running them.

Make sure to run the "regenerate binaries" steps; in order to keep demo's consistent we no longer vendor binaries in this project.

# Directory overview

* `bin` - Contains binaries to link with projects. These binaries aren't real binaries; they're just random files.
* `internal-json-parser` - An example internal library. Contains the `bin/jq/jq.o` binary.
* `example-internal-project` - An example internal project. Contains vendored source (in `vendor`), and the `bin/libauth_internal` and `bin/libjson_internal` binaries (in `include`).
* `librayon` - A downloaded Rust project for `rayon` (https://lib.rs/crates/rayon). Has no significance, I just needed a real project that wouldn't be found with VSI and would have dependencies.

All other files not mentioned here (eg `.c` and `.h` files) are placeholders.
