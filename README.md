# Elm mode for vim

This is an Elm mode for vim which features syntax highlighting and indentation.

As an alternative, check out [elm.vim](https://github.com/lambdatoast/elm.vim).

## Indentation

The current indentation function is still rough, but should work for a lot of cases. It is not always possible (in Elm) to know the perfect indentation level just from context, but we should be able to generate a list of candidates. The most likely candidate would always be taken automatically, and there can be a binding to toggle through each level. If all else fails, manual indentation can still be used if needed.
