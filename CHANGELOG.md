# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-10-01
DOGOnews fork. Breaking change in a 0.x version (minor bump) because the minimum supported Mongoid rose from any
version (0.4.3) to 7.0.

### Added
- Mongoid 7, 8 and 9 support; the GitHub Actions test matrix (`.github/workflows/test.yml`), seven rows from Ruby 2.7 /
  Rails 6.1 / Mongoid 7.5 / MongoDB 6.0 to Ruby 3.4 / Rails 8.0 / Mongoid 9.0 / MongoDB 8.0. The `Gemfile`
  selects Rails and Mongoid from `RAILS_VERSION` / `MONGOID_VERSION` (defaults 6.1 / 7.5).
- GitHub Release workflow (`.github/workflows/release.yml`): pushing a `vX.Y.Z` tag creates a GitHub Release
  with this file's section as the notes.

### Changed
- Runtime dependency `mongoid >= 7.0, < 10` (was any version).
- Specs run on RSpec 3.13 (keeping the `should` syntax, enabled explicitly) with `database_cleaner-mongoid`
  (was `database_cleaner`); the integrity specs expect `Mongoid::Ancestry::IntegrityError` and
  `Mongoid::Ancestry::Error`.
- The gemspec `homepage` points to this fork (the skyeagle upstream no longer exists); `rubyforge_project`
  removed.
- README rewritten for the maintained fork (supported versions, the API checked against `lib/`, known issues);
  history moved to this file.

### Removed
- The Mongoid 3 `Moped::BSON::ObjectId` code paths (ids are always `BSON::ObjectId` on Mongoid 7+).
- Rails 2 plugin files (`init.rb`, `install.rb`), the `Guardfile`, and the Travis CI configuration.

### Fixed
- `lib/mongoid-ancestry.rb` requires `active_support/concern` itself, so it loads without Rails.

## [0.4.3] - 2018-06-01
Never released to RubyGems.
### Added
- Mongoid 5 and 6: ids are namespaced `BSON::ObjectId` from Mongoid 4 on.

### Fixed
- Mongoid 4 used `Moped::BSON` instead of `BSON` for ids.

### Changed
- Specs use `database_cleaner` instead of `mongoid.yml`, the `expect` syntax, and `match_array` for unordered
  comparisons.

## [0.4.2] - 2014-05-17
### Changed
- The class attribute `touchable` renamed to `ancestry_touchable`, because Mongoid already defines `touchable`.

## [0.4.1] - 2014-02-28
### Fixed
- Placement of the Mongoid version check.

## [0.4.0] - 2014-02-24
### Added
- Mongoid 4 support; models include `Mongoid::Attributes::Dynamic`.

### Changed
- Cheaper `parent_id` lookup; old lambda-style scopes refactored.

### Fixed
- Scope errors; RSpec deprecation warnings.

## [0.3.2] - 2013-04-06
### Added
- `:touchable` option: touch the parent when a node changes.

### Changed
- Updated dependencies; some optimization.

## [0.3.1] - 2013-02-18
### Changed
- Accepts Mongoid `~> 3.1` too.

## [0.3.0] - 2012-08-03
### Changed
- Mongoid 3 support finished (`Moped::BSON::ObjectId`, index keys as strings); dependencies updated.

## [0.3.0.rc] - 2012-06-09
### Changed
- Mongoid 3.0.0.rc support: database connection, index definitions, `cast_primary_key`, `parent_id` as
  `BSON::ObjectId`, `restore_ancestry_integrity!` without `exists?(args)`.

## [0.2.3] - 2012-06-25
Released from a Mongoid 2 maintenance branch; not part of `master`'s history.
### Changed
- Relaxed `mongoid` and `bson_ext` version dependencies.

### Fixed
- `ActiveSupport::Concern` `InstanceMethods` and `rdoctask` deprecation warnings.

## [0.2.2] - 2011-04-26
### Changed
- jeweler removed (the gemspec reads `Mongoid::Ancestry::VERSION`).

## [0.2.1] - 2011-04-20
### Changed
- More Bundler-friendly load paths.

## [0.2.0] - 2011-04-19
### Changed
- Uses the default MongoDB unique id.

## [0.1.0] - 2011-04-16
### Added
- Initial release by Anton Orel: a Mongoid port of [ancestry](https://github.com/stefankroes/ancestry) 1.2.3 for
  ActiveRecord by Stefan Kroes.

[Unreleased]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.4.3...v0.5.0
[0.4.3]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.3.2...v0.4.0
[0.3.2]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.3.0.rc...v0.3.0
[0.3.0.rc]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.2.3...v0.3.0.rc
[0.2.3]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/joe1chen/mongoid-ancestry/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/joe1chen/mongoid-ancestry/releases/tag/v0.1.0
