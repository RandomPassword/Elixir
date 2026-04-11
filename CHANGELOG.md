# Changelog

## v1.3.0 (2026-04-11)

### Changes

- Use cryptographically secure Fisher-Yates shuffling for final password permutation
  - Replace `Enum.shuffle/1` with a `rand_bytes`-backed shuffle
- Update total entropy to include random shuffle contribution
- Update development dependencies
- Add GitHub Actions CI workflow
  - Test matrix: Elixir `1.17`, `1.18`, `1.19` on OTP `27`
  - Enforce warnings as errors for compile and test
  - Add non-blocking canary job using Elixir `latest` on OTP `27`

## v1.2.1 (2025-12-30)

### Changes

- Fix Elixir 1.19 compiler warnings

## v1.2.0 (2022-08-14)

### Added

- Custom decimal characters
    - Allow specifying decimal characters.

- Tests for custom `decimals`

### Changes

- README
  - Add usage of custom `decimals`
  - Add specifying custom entropy source

## v1.1.0 (2022-06-30)

### Added

- Custom alpha characters
    - Any set of characters allowed by `Puid` can be used for alpha.

### Changes

- Update to [`Puid`](https://hexdocs.pm/puid/Puid.html) v2.0
    - Use `Puid` character validation functionality
- README

## v1.0.0 (2019-04-19)

Initial release
