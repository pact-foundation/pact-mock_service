# Releasing

1. Increment the version in `lib/pact/mock_service/version.rb`
2. Update the `CHANGELOG.md` using:

      $ git log --pretty=format:'  * %h - %s (%an, %ad)' vX.Y.Z..HEAD

3. Add files to git

      $ git add CHANGELOG.md lib/pact/mock_service/version.rb
      $ git commit -m "chore(release): version $(ruby -r ./lib/pact/mock_service/version.rb -e "puts Pact::MockService::VERSION")"

4. Tag and push

    $ VERSION=$(ruby -r ./lib/pact/mock_service/version.rb -e "puts Pact::MockService::VERSION") git tag -a v${VERSION} -m "chore(release): version ${VERSION}" && git push origin v${VERSION}
