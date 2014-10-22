Do this to generate your change history

  git log --pretty=format:'  * %h - %s (%an, %ad)'

### 0.1.0 (22 October 2014)

* 62caf8e - Removed Gemfile.lock from git (bethesque, Wed Oct 22 13:07:54 2014 +1100)
* 5b4d54e - Moved JSON serialisation code into decorators. Serialisation between DSL and mock service is different from serialisation to the pact file. (bethesque, Wed Oct 22 13:07:00 2014 +1100)
