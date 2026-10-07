# Contributing

## Development

Use the compiler and Spago versions recorded in `package.json`, install dependencies with `pnpm install --frozen-lockfile`, then run:

```sh
pnpm exec spago build
pnpm exec spago test
pnpm exec spago docs
```

Changes to Gregorian arithmetic should include boundary cases and, where useful, deterministic exhaustive checks. Paper geometry changes must state the model assumptions and preserve explicit error results for invalid inputs.

## Pull requests

Keep changes focused, describe the behavior being added or corrected, and include test results. Do not add scraped calendar data or tracking parameters to canonical references.
