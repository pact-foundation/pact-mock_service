# Releasing

1. Increment the version in `lib/pact/mock_service/version.rb`
2. Update the `CHANGELOG.md` using:

      $ git log --pretty=format:'  * %h - %s (%an, %ad)' vX.Y.Z..HEAD

3. Add files to git

      $ git add CHANGELOG.md lib/pact/mock_service/version.rb
      $ git commit -m "Releasing version X.Y.Z"

4. Tag and push

    $ git tag -a vX.Y.Z -m "Releasing version X.Y.Z" && git push origin --tags
