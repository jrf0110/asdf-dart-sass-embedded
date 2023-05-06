# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

#
asdf plugin test dart-sass-embedded https://github.com/jrf0110/asdf-dart-sass-embedded.git "dart-sass-embedded --version"
```

Tests are automatically run in GitHub Actions on push and PR.
