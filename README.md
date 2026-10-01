# mongoid-ancestry

[![CI RSpec Test](https://github.com/joe1chen/mongoid-ancestry/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/joe1chen/mongoid-ancestry/actions/workflows/test.yml)

Organise the documents of a **Mongoid** model as a tree (hierarchy). Each document stores the path from its root
to its parent in a single string field (a materialised path, e.g. `"<root id>/<parent id>"`), so every tree
relation — ancestors, parent, root, children, siblings, descendants, subtree — is one query. Also included: depth
caching and depth scopes, STI support, arranging a (sub)tree into nested hashes, orphan strategies, integrity
checking/restoration and migration from `parent_id` trees.

This is the [DOGOnews](https://www.dogonews.com)-maintained fork of `skyeagle/mongoid-ancestry` (Anton Orel's
Mongoid port of [stefankroes/ancestry](https://github.com/stefankroes/ancestry)). The skyeagle repository no
longer exists on GitHub and its last RubyGems release is 0.4.2 from 2014; the ActiveRecord original is still
maintained but does not support Mongoid. This fork is kept working on current Ruby, Rails, Mongoid and MongoDB
versions.

## Supported versions

Tested on every push by the [GitHub Actions matrix](https://github.com/joe1chen/mongoid-ancestry/actions/workflows/test.yml)
([workflow](.github/workflows/test.yml)):

| Ruby | Rails | Mongoid | MongoDB |
|---|---|---|---|
| 2.7 | 6.1 | 7.5 | 6.0 |
| 3.0 | 6.1 | 8.0 | 6.0 |
| 3.1 | 7.0 | 8.1 | 7.0 |
| 3.2 | 7.1 | 8.1 | 7.0 |
| 3.2 | 7.2 | 9.0 | 7.0 |
| 3.3 | 7.2 | 9.0 | 8.0 |
| 3.4 | 8.0 | 9.0 | 8.0 |

The gemspec allows `mongoid >= 7.0, < 10`.

## Installation

This fork is not published to RubyGems; install it from GitHub:

```ruby
# Gemfile
gem 'mongoid-ancestry', github: 'joe1chen/mongoid-ancestry'
```

Then add ancestry to a model:

```ruby
class TreeNode
  include Mongoid::Document
  include Mongoid::Ancestry

  field :name, type: String

  has_ancestry
end
```

`has_ancestry` adds an indexed `ancestry` string field (create the index with
`rake db:mongoid:create_indexes` or `TreeNode.create_indexes`). Including `Mongoid::Ancestry` also includes
`Mongoid::Attributes::Dynamic` in the model.

## Usage

### Organising documents into a tree

Set `parent` (a document) or `parent_id` (an id) — on the instance or in the attributes passed to `new`,
`create`, `create!`, `update` and so on:

```ruby
squeeky = TreeNode.create!(name: 'Squeeky')
TreeNode.create!(name: 'Stinky', parent: squeeky)
TreeNode.create!(name: 'Stinky', parent_id: squeeky.id)
```

Or create through the tree scopes:

```ruby
node.children.create(name: 'Stinky')
node.siblings.create!
TreeNode.children_of(node_id).build
TreeNode.siblings_of(node_id).create
```

### Navigating the tree

| Method | Returns |
|---|---|
| `parent` | The parent document, `nil` for a root |
| `parent_id` | The parent's id, `nil` for a root |
| `root` | The root of the node's tree, `self` for a root |
| `root_id` | The id of the root |
| `is_root?` | `true` if the node is a root |
| `ancestor_ids` | Ancestor ids, from the root to the parent (no query) |
| `ancestors` | Criteria for the ancestors |
| `path_ids` | Ancestor ids plus the node's own id (no query) |
| `path` | Criteria for the ancestors and the node itself |
| `children` | Criteria for the children |
| `child_ids` | Ids of the children |
| `has_children?` / `is_childless?` | Whether the node has children |
| `siblings` | Criteria for the siblings, **including the node itself** |
| `sibling_ids` | Ids of the siblings (including the node) |
| `has_siblings?` / `is_only_child?` | Whether the node's parent has more than one child |
| `descendants` | Criteria for children, grandchildren, … |
| `descendant_ids` | Ids of the descendants |
| `subtree` | Criteria for the node and its descendants |
| `subtree_ids` | Ids of the subtree |
| `depth` | Depth of the node; roots are at depth 0 |

Ids are cast to the model's `_id` type (`BSON::ObjectId`, `Integer` or string).

### Options for `has_ancestry`

| Option | Default | Description |
|---|---|---|
| `:ancestry_field` | `:ancestry` | Field that stores the materialised path |
| `:orphan_strategy` | `:destroy` | What happens to the descendants when a node is destroyed: `:destroy` destroys them, `:rootify` makes the children roots, `:restrict` raises `Mongoid::Ancestry::Error` if there are any |
| `:cache_depth` | `false` | Store each node's depth in a field (needed for the depth scopes below) |
| `:depth_cache_field` | `:ancestry_depth` | Field used for the depth cache |
| `:touchable` | `false` | `touch` the parent when a node's ancestry changes |

Any other option raises `Mongoid::Ancestry::Error`. If you turn on `:cache_depth` for existing data, fill the cache
with `TreeNode.rebuild_depth_cache!`.

### Scopes

The navigation methods return Mongoid criteria, so they can be refined, counted or checked for existence:

```ruby
node.children.where(name: 'Mary')
node.subtree.order_by([:name, :desc]).limit(10).each { |n| ... }
node.descendants.count
```

Class-level scopes (`node` can be a document or an id):

| Scope | Documents |
|---|---|
| `roots` | Root nodes |
| `ancestors_of(node)` | Ancestors of `node` |
| `children_of(node)` | Children of `node` |
| `descendants_of(node)` | Descendants of `node` |
| `subtree_of(node)` | `node` and its descendants |
| `siblings_of(node)` | Siblings of `node` (including `node`) |
| `ordered_by_ancestry` | All nodes sorted by the ancestry field (roots first) |
| `ordered_by_ancestry_and(order)` | As above, then by `order`, e.g. `[:name, :asc]` |

### Selecting nodes by depth

With `cache_depth: true`, five more scopes select nodes by depth (without depth caching they raise
`Mongoid::Ancestry::Error`):

| Scope | Condition |
|---|---|
| `before_depth(d)` | `depth < d` |
| `to_depth(d)` | `depth <= d` |
| `at_depth(d)` | `depth == d` |
| `from_depth(d)` | `depth >= d` |
| `after_depth(d)` | `depth > d` |

The same options can be passed to `ancestors`, `path`, `descendants`, `descendant_ids`, `subtree` and
`subtree_ids`, where they are **relative** to the node's depth:

```ruby
node.subtree(to_depth: 2)        # node, children and grandchildren
node.subtree.to_depth(5)         # subtree down to absolute depth 5
node.descendants(at_depth: 2)    # grandchildren
node.ancestors.to_depth(3)       # the oldest 4 ancestors (the root and 3 more)
node.path(from_depth: -2)        # grandparent, parent and the node itself
node.ancestors(from_depth: -6, to_depth: -4)
node.descendants(from_depth: 2, to_depth: 4)
```

`ancestor_ids` and `path_ids` are read straight from the ancestry field and take no depth options; use
`ancestors(options).map(&:id)` or `ancestor_ids.slice(range)` instead.

### STI

Ancestry works with single-collection inheritance: build one tree out of documents of different subclasses and
every relation returns nodes of any subclass. Add a condition on `_type` if you only want one subclass.

### Arrangement

`arrange` turns the whole tree, or a scoped subtree, into nested ordered hashes:

```ruby
TreeNode.arrange
# => { #<TreeNode name: "Stinky"> => { #<TreeNode name: "Crunchy"> => { #<TreeNode name: "Squeeky"> => {} } } }

TreeNode.where(name: 'Crunchy').first.subtree.arrange
TreeNode.arrange(order: [:name, :asc])   # pass the order to arrange, not to the scope
```

### Migrating from a `parent_id` tree

1. Add `include Mongoid::Ancestry` and `has_ancestry` to the model and create the indexes.
2. Run `TreeNode.build_ancestry_from_parent_ids!` to fill the ancestry field from the existing `parent_id` field.
3. Check your data and tests, then remove the `parent_id` field.

### Integrity checking and restoration

The tree can only become inconsistent if cyclic parents or invalid ancestry values are written while bypassing
validation (e.g. with `update_attribute`). To check:

```ruby
TreeNode.check_ancestry_integrity!                  # raises Mongoid::Ancestry::IntegrityError on the first problem
TreeNode.check_ancestry_integrity!(report: :list)   # returns an array of the IntegrityError exceptions
TreeNode.check_ancestry_integrity!(report: :echo)   # prints each problem
```

To repair: `TreeNode.restore_ancestry_integrity!`. To rebuild a corrupted depth cache:
`TreeNode.rebuild_depth_cache!`.

Note that `Mongoid::Ancestry::IntegrityError` is **not** a subclass of `Mongoid::Ancestry::Error`; both inherit
from `RuntimeError`.

### Internals

Each node stores the path from the root to its parent. Descendants are fetched with an anchored regular
expression on the ancestry field (`/^<path>\//`), which can use the field's index. Inserts, deletes and moves only
touch documents in the affected node's own subtree (on move, descendants' ancestry is rewritten in a
`before_save` callback).

## Development

```bash
# needs a MongoDB on localhost:27017 (e.g. docker run -p 27017:27017 mongo:8.0)
MONGOID_VERSION=9.0 RAILS_VERSION=8.0 bundle install
MONGOID_VERSION=9.0 RAILS_VERSION=8.0 bundle exec rspec spec
```

`MONGOID_VERSION` and `RAILS_VERSION` select the versions in the `Gemfile` (defaults: Mongoid 7.5, Rails 6.1).
To add a combination to CI, add a row to `matrix.include` in `.github/workflows/test.yml`.

## Known issues

- The `has_ancestry` code reads a `:primary_key_format` option for the ancestry format validation, but the
  option is not in the list of accepted options, so passing it raises `Mongoid::Ancestry::Error`. The default
  format (`/[a-z0-9]+/` per id) is always used.

## History

- **0.4.3+ (DOGOnews fork, 2026)** — GitHub Actions matrix up to Ruby 3.4 / Rails 8.0 / Mongoid 9.0 /
  MongoDB 8.0; mongoid dependency `>= 7.0, < 10`; specs on RSpec 3.13; dead Mongoid 3 (`Moped`) code and Rails 2
  plugin files removed.
- **0.4.3 (joe1chen fork, 2012–2022)** — Mongoid 4 `BSON::ObjectId` fix, Mongoid 5–8 support,
  database_cleaner-mongoid, GitHub Actions.
- **0.4.x (skyeagle, 2013–2014)** — Mongoid 4 support, `:touchable` option (Timo Sand). **0.3.x** — Mongoid 3. **0.2.x** — Mongoid 2.
- **Original** — [ancestry](https://github.com/stefankroes/ancestry) for ActiveRecord by Stefan Kroes, ported to
  Mongoid by Anton Orel.

## Credits

- Stefan Kroes — original ancestry gem
- Anton Orel (skyeagle) — Mongoid port
- [Contributors](https://github.com/joe1chen/mongoid-ancestry/graphs/contributors)

Copyright (c) 2009 Stefan Kroes. Licensed under the MIT license (see [MIT-LICENSE](MIT-LICENSE)).
