# ptpm_accounts
This resource contains the database for the `ptpm` resource. It contains both the `users` and `playerstats` databases. The 
resource runs on SQLite. You may use [SQLite Studio](https://sqlitestudio.pl/index.rvt) to view and modify the database
contents. 

## IMPORTANT: First time set-up
* Rename `api-config.xml-sample` to `api-config.xml` and generate random strings unique to your installation of PTPM.
  * `serverSecret` Key used to hash passwords in database. 128-char random string.
  * `publicApiKey` API Key used by ptpm_community to sign requests. 32-char random string.
* The database tables will be generated upon first run.

## Notes about _users_ table
The password system was built in 2013, but has been overhauled in 2017. The production version of PTPM (that runs on PTPM.uk) 
is compatible with both systems. Users that are on the old system are automatically upgraded to the new system when they
sign in. 

**Old system:** Password was hashed once with MD5. Password length was saved (to display the right number of asterisks on
the login form).

**New system:** Before the password is hashed, a salt is added, as well as a serverKey. This means that if the database
file was somehow stolen (or the table contents), it would be useless without the key file. The length of the password
is also reset to 9999, in order to counter brute force attacks in case the hashed passwords are stolen.
 
**Migration:** The `pwlength` value is used to determine whether an account is on the new or old system. 9999 means 
new system.

## Notes about _playerstats_ table
Contains user statistics, which are used by ptpm_community for ranking players. Also shows on the scoreboard.

Also contains statistics used by the [PTPM Help System.](https://trello.com/c/Z32ISP2b/91-help-overhaul) 