# Creating standalone mock service packages

* From the base directory of the project run:

    bundle exec rake package

* It will generate artifacts for linux, osx and windows under `./pkg`.
* Create a new release under the github project by going to https://github.com/pact-foundation/pact-mock_service/releases/new
* Select the appropriate version tag.
* Set the title to `Standalone Pact Mock Service vX.Y.Z`
* Update the text in RELEASE_NOTES_TEMPLATE.txt with the correct version, and copy the text into the release notes section.
* Upload the 4 artefacts from the `pkg` directory.
* Click `Publish release`.
