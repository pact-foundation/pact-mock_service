Do this to generate your change history

  git log --pretty=format:'  * %h - %s (%an, %ad)' vX.Y.Z..HEAD

### 0.5.0 (20 Mar 2015)

* ddc8c1a - Upgrade pact-support to ~>0.4.0 (Beth Skurrie, Fri Mar 20 14:53:00 2015 +1100)

### 0.4.2 (3 Mar 2015)

* 4c0e48b - Fixed bug where pact file was being cleared before being merged (Beth Skurrie, Tue Mar 3 17:27:02 2015 +1100)
* 661321a - Stop log/pact.log from being created automatically https://github.com/bethesque/pact-mock_service/issues/15 (Beth Skurrie, Tue Mar 3 08:45:15 2015 +1100)

### 0.4.1 (13 Feb 2015)

* 7be9338 - Fixed broken require that stopped restart working (Beth Skurrie, Wed Feb 25 13:55:32 2015 +1100)

### 0.4.0 (13 Feb 2015)

* 73ddd98 - Added option to AppManager to set the pact_specification_version (Beth Skurrie, Fri Feb 13 17:41:42 2015 +1100)
* e4a7405 - Make pactSpecificationVersion in pact file dynamic. (Beth Skurrie, Fri Feb 13 17:20:28 2015 +1100)
* ed9c550 - Create --pact-specification-version option to toggle between v1 and v2 serialization (Beth Skurrie, Fri Feb 13 16:56:30 2015 +1100)

### 0.3.0 (4 Feb 2015)

* 60869be - Refactor - moving classes from Pact::Consumer module into Pact::MockService module. (Beth Skurrie, Wed Feb 4 19:28:54 2015 +1100)
* 4ada4f0 - Added endpoint for PUT /interactions. Allow javascript client to set up all interactions at once and avoid callback hell. (Beth Skurrie, Thu Jan 29 21:48:00 2015 +1100)
* a329f49 - Add X-Pact-Mock-Service-Location header to all responses from the MockService (Beth Skurrie, Sun Jan 25 09:00:20 2015 +1100)

### 0.2.4 (24 Jan 2015)

* b14050e - Add --ssl option for control server (Beth, Sat Jan 24 22:14:14 2015 +1100)
* a9821fd - Add --cors option to control command (Beth, Sat Jan 24 21:51:40 2015 +1100)
* 16d62c8 - Added endpoint to check if server is up and running without causing an error (Beth, Thu Jan 8 14:33:26 2015 +1100)
* f93ff1f - Added restart for control and mock service (Beth, Thu Jan 8 14:02:19 2015 +1100)
* 54b2cb8 - Added control server to allow mock servers to be dynamically set up (Beth, Wed Jan 7 08:24:19 2015 +1100)

### 0.2.3 (21 Jan 2015)

* 560671e - Add support for using Pact::Terms in the path (Beth, Wed Jan 21 07:42:10 2015 +1100)
* 4324a97 - Renamed --cors-enabled to --cors (Beth, Wed Jan 21 07:28:34 2015 +1100)
* 5f5ee7e - Set Access-Control-Allow-Origin header to the the request Origin when populated. (Beth, Tue Jan 13 16:03:37 2015 +1100)

### 0.2.3.rc2 (13 Jan 2015)

* daf0696 - Added --consumer and --provider options to CLI. Automatically write pact if both options are given at startup. (Beth, Mon Jan 5 20:48:47 2015 +1100)
* 351c44e - Write pact on shutdown (Beth, Mon Jan 5 17:17:24 2015 +1100)
* e206c9f - Adding cross domain headers (André Allavena, Tue Dec 23 18:01:46 2014 +1000)

### 0.2.3.rc1 (3 Jan 2015)

* afd9cf3 - Removed awesome print gem dependency. (Beth, Sat Jan 3 16:49:40 2015 +1100)
* 5ae2c12 - Added rake task to package pact-mock-service as a standalone executable using Travelling Ruby. (Beth, Sat Jan 3 16:14:20 2015 +1100)
* b238f2a - Added message to indicate which part of the interactions differ when an interaction with the same description and provider state, but different request/response is added. https://github.com/realestate-com-au/pact/issues/18 (Beth, Sat Jan 3 14:20:36 2015 +1100)
* cf38365 - Moved check for 'almost duplicate' interaction to when the interaction is set up. If it occurs during replay, the error does not get shown to the user. https://github.com/bethesque/pact-mock_service/issues/1 (Beth, Sat Jan 3 11:10:47 2015 +1100)
* 1da9a74 - Added --pact-dir to CLI. Make --pact-dir and --log dir if they do not already exist. (Beth, Sat Jan 3 09:07:03 2015 +1100)
* 4a2a9a2 - Added handler for SIGTERM to shut down mock service. (Beth, Fri Jan 2 12:07:29 2015 +1100)
* 57c1a14 - Added support to run the mock service on SSL. Important for browser-based consumers. (Tal Rotbart, Wed Dec 31 09:43:52 2014 +1100)

### 0.2.2 (29 October 2014)

* 515ed14 - Added feature tests for mock service to show how it should respond under different circumstances. (Beth, Wed Oct 29 09:21:15 2014 +1100)
* de6f670 - Added missing require for interaction decorator. (Beth, Wed Oct 29 09:19:27 2014 +1100)

### 0.2.1 (24 October 2014)

* a4cf177 - Reifying the request headers, query and body when serializing pact. This allows Pact::Term to be used in the request without breaking verification for non-ruby providers that can't deserialise the Ruby specific serialisation of Pact::Terms. (Beth, Fri Oct 24 15:27:18 2014 +1100)

### 0.2.0 (24 October 2014)

* d071e2c - Added field to /pact request body to specify the pact directory (Beth, Fri Oct 24 09:22:06 2014 +1100)

### 0.1.0 (22 October 2014)

* 62caf8e - Removed Gemfile.lock from git (bethesque, Wed Oct 22 13:07:54 2014 +1100)
* 5b4d54e - Moved JSON serialisation code into decorators. Serialisation between DSL and mock service is different from serialisation to the pact file. (bethesque, Wed Oct 22 13:07:00 2014 +1100)
