Overview
--------
Jarvis is the keeper of our mobile builds.

The bulk of the logic is in the file [script_helper.rb](script_helper.rb). This contains a class that you can use when debugging/developing new feature to interact with Jarvis.

Setup
-----
You can login and create an account [here](https://jarvis.d3vcloud.com/login).

Click the user icon in the top right, click your username, then click "Add Token" in the top right to generate a Jarvis token. Copy it to your clipboard, and then set an environment variable.
```sh
export JARVIS_TOKEN=<your token>
```

You may also want to export this variable in your `.bashrc` or `.bash_profile` so that it persists between terminal sessions.
```sh
vi ~/.bash_profile <ADD YOUR TOKEN THEN SAVE>
source .bash_profile
echo $JARVIS_TOKEN <TO CONFIRM THAT YOU SAVED YOUR TOKEN>
```

Developers
----------
In order to get your mobile development environment setup, in the folder you cloned your repo run the command:
```
ruby Scripts/setup_for_development.rb
```
This will get the current template for the master branch, and create an `environment.zip` that is unpacked into the project.

In order to reproduce a build, run the command:
```
ruby Scripts/reproduce_build.rb insert_build_id_here
```

Production Release
------------------

In order to do a new production release, run the command:
```
ruby Scripts/create_build_from_template.rb insert_template_id_here
```
