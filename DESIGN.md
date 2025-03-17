## Design goals

In this document, I will endeavor to explain some of my assumptions and overall
design thinking to keep in mind while reviewing this submission.

This list is non-exhaustive under the assumption that there will be a follow up
conversation discussing or reviewing the submission in detail. However, this
should cover some of the most notable and major decisions.

### No runtime dependencies

The waters muddy a bit when talking about `main.rb` since the goal of the
exercise is to load a CSV file (which is why it's in the gemfile), but the
solution to the challenge has been designed to expect an array of arrays — they
just happen to be exactly what a CSV file in the shape required by the challenge
to be provided. Removing the `csv` gem from the gemfile still provides a working
system.

There are several aspects that could have been improved by using battle-tested
gems, like using the `money` gem for handling amounts and balanaces, or
`dry-validation` for handling the validation of data. Even `thor` or even
`terminal-table` to provide a simple but usable interface to the demonstration
script.

### No control over source data

The code provided may look like overkill for a dataset as small as the Alpha
Sales one. However, this submission was designed without looking into the data
itself — just the shape, like the order of the CSV fields, particularly
important because the CSV provided does not have headers. Adding headers to
the files _feels_ that it defeats part of the purpose of the challenge.

One of the design goals was to be able to process the provided dataset as an
example, but under the assumption that there will be a much larger, much more
chaotic stress-test — like a real world production system importing 3rd party
data would. This is why validation has so many assumptions and there
is so much edge-case testing.

I am expecting that as part of the evaluation of this exercise there's a 10k
lines CSV file somewhere with a plethora of edge cases that should be handled
gracefully by the system.

I have provided an auxilliary test file for your convenience
(`generate_data.rb`) that should help you create tens of thousands of records
that the system should be able to process without an issue, with the opourtunity
to add any sort of data mistake you can think of.

### Overriding default struct behaviour inside Models

The `*Record` classes are meant to be simple data objects. The reason I have
overriden their setters is simply to enforce that every object _in_ is casted,
and that every object _out_ is reliable. This type of behaviour may be a bit
strange in a language like Ruby where we care less about object types and more
about what objects respond to, but I felt it was appropriate to ensure
correctness.

I could have gone as far as monkey-patching the `#to_a` methods of those structs
to ensure they return arrays specifically ordered, but as far as my testing
goes, `Struct` reserves insertion order through the order of the properties
defined in their constructor.

This can cause problems if someone decides
to change the order of the constructor (for whatever reason) which is why
I would prefer to communicate this via overriding `#to_a`, but I decided to
keep it simple for now.

### Robustness over usability

I think of the submission as a "production quality one-off rake task".

The contents of the submission should:

- Provide modelling that is easily extensible
- Be easy to understand for other developers
- Be easy to review and debug
- Be easy to implement as a part of a larger process (like CI)

The "usability" part comes into play when talking about `main.rb`. This file is
a way to _facilitate a demonstration_ that the code sucessfully completes
the challenge, but does not _prescribe_ how to use it. This is the reason
why it is so barebones.

The design goal is that you should be able to insert this submission as a
library in a working Ruby/Rails app and it should still work by just using
its public API, or loading JSON data, etc.

### Usage of Test doubles

This submission relies heavily on native data structures or so-called
"plain old Ruby objects" (POROs for short), making it performant. The current
modelling allows for very easy setup during testing, which forego the need of
using test doubles.

Test doubles are very common in more complex apps with lots of different moving
parts, but this is not the case, and therefore unnecessary, for this submission.

### `let` and test setup co-location

Towards the end of the challenge, I [significantly refactored][refactor] my
specs to rely more on the usage of `let` and `context`. With my recent
experience in Typescript, where Jest / Vite don't have this lazy loading
approach, the approach was quite different: rebuilding entire environments per
`it` block.

Some argue that this less magical approach where you have all the
context you need in a single screen is more helpful to understand what the spec
does, whereas some others argue that it's verbose and inefficient, and
dissuades thorough testing of small edge cases (which is less necessary in
strongly or structurally typed languages). The way specs are set up right
now demonstrate a _preference_ that I hope allows you the reader to understand
the specs better without needing to understand the implementation details, but
I'd be happy to adapt to a team's needs.

[refactor]: https://github.com/AeroCross/mblcc/commit/bb9d78b101b25f2ed3aeee88610bc07f704b6b92

### Validation rules

The `BaseValidator` has baked in rules. This is one of the examples where I
chose simplicity over correctness. A more composable alternative would have been
to have a `ValidationRule` class or something similar that is less concerned
about the specifics of a domain.