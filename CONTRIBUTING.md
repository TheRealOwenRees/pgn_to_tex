# Contributing

When contributing to this repository, please first discuss the change you wish
to make via the repository's issues.

If you are wanting to tackle one of the pre-existing issues, please comment on
that issue so that you can be assigned to it.

Alternatively, just send a PR and I will check it asap. Please bear in mind that
I may not be reactive if I was not expecting a PR.

## Guidelines

- We use the [GitHub Flow](https://www.gitkraken.com/learn/git/best-practices/git-branch-strategy#github-flow-considerations) branching strategy. Add your code into a feature branch such as `feature/feature-name`.
- Write good commit messages. 'Fix bug' is not a good commit message. 'Fix bug with comments before moves' is a good commit message.
- Explain the changes in the PR comments.

## Development setup

The package requires OCaml 5.4 or newer. From a checkout, install all build,
test, documentation, and development dependencies:

```sh
opam install . --deps-only --with-test --with-doc --with-dev-setup
```

The JavaScript build is an optional target. Its dependencies are part of the
`--with-test` set (`js_of_ocaml` and `js_of_ocaml-ppx`), so the command above
also prepares the Node smoke test.

## Verification commands

Run these before opening or updating a pull request.

Check formatting, build the package, run the test suite, and build the API
documentation:

```sh
dune build @fmt @install @runtest @doc
```

`@fmt` checks formatting with `ocamlformat` 0.29.0. If it reports a diff, apply
the formatting with `dune fmt` (or `dune build @fmt --auto-promote`).

Build the optional JavaScript artifact:

```sh
dune build bin/pgn_to_tex_js.bc.js
```

Run the Node smoke test against that artifact:

```sh
node test/js/smoke.js
```

Lint the generated opam metadata:

```sh
opam lint pgn_to_tex.opam
```

The opam file is generated from `dune-project`, so change dependencies and
package metadata there rather than editing `pgn_to_tex.opam` by hand.

The test suite has one OUnit runner, `test/test_suite.ml`. Add a suite to that
runner instead of starting a second test executable. Bundled PGN fixtures live
in `test/pgn_examples/` and are exercised by the real-world tests.
