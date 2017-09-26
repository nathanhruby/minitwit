## The Situation:

Your CEO just wrote a quick "Twitter like" application.  Since he's heard you
mention DevOps before, he's handed the code off to you to get ready for the
sales team.  They need to be able to deploy and redeploy the application on
their laptops without network connectivity in order to demo it to potential
clients.

You need to automate these processes so they are easy to perform and produce
consistent results.


## Pre-Requisites 

The workshop requires a machine that can run git and ansible, as well as
a target that can deploy the sample code to.  The target is ideally provided
by Vagrant which can use VirtualBox as a VM provider to provide easy to
(re)use host images.


- If you do not have a VM provider supported by the centos/7 vagrant box image
  installed on your machine, download and install Virtual Box
    - centos/7 provider list: https://app.vagrantup.com/centos/boxes/7
    - VirtualBox download: https://www.virtualbox.org/wiki/Downloads
- Download and Install Vagrant
  - https://www.vagrantup.com/downloads.html
- On your system add the centos/7 base box
    # vagrant box add centos/7
- If you don't have git and ansible install them now as well:
  - git: https://git-scm.com/downloads
  - ansible: http://docs.ansible.com/ansible/latest/intro_installation.html
- clone the following repo ahead of time:
    # https://github.com/nathanhruby/minitwit.git
  Feel free to fork this if you want to push tags and changes.

- Note for Mac Users: VirtualBox and Vagrant are both in Homebrew cask, git
  and ansible are in regular homebrew
- Note for Linux users: VirtualBox and Vagrant should be downloaded and
  installed from upstream, git and ansible system packages are fine
- If you have any problems, we can resolve these at the start of the workshop


## Use the docs!

The ansible documents are very complete (perhaps too complete).  Here are some
pages you will need for these exercises:

Language Parts
- playbooks: http://docs.ansible.com/ansible/latest/playbooks_intro.html
- variables: http://docs.ansible.com/ansible/latest/playbooks_variables.html
- loops: http://docs.ansible.com/ansible/latest/playbooks_loops.html
- conditionals: http://docs.ansible.com/ansible/latest/playbooks_conditionals.html
- become: http://docs.ansible.com/ansible/latest/become.html
  - for this use case, assume that many tasks will use `become: yes` and
    default to root, but some will need to be run as the application user.

Modules:
- file module: http://docs.ansible.com/ansible/latest/file_module.html
- user module: http://docs.ansible.com/ansible/latest/user_module.html
- run command: http://docs.ansible.com/ansible/latest/command_module.html
- yum package manager: http://docs.ansible.com/ansible/latest/yum_module.html
- pip package manager: http://docs.ansible.com/ansible/latest/pip_module.html
- templating module: http://docs.ansible.com/ansible/latest/template_module.html
- system services: http://docs.ansible.com/ansible/latest/service_module.html
- unarchive: http://docs.ansible.com/ansible/latest/unarchive_module.html

## First Task: Create a local build artifact.

We first need to create a "build artifact" using Semantic Versioning
(http://semver.org/) to ship to remote servers.  For this we can create
a small playbook to do this for us.

- Create a inventory file with "localhost" in it.
- Add a git tag with the version
  # git tag 1.0.0
- Make a new ansible playbook file named "make-build.yml" in the top of the
  repo.  This should have one play consisting of two tasks
  - The first task should create a directory at the top of the repo for the
    build artifacts to go into, call this directory "builds"
  - The second task should generate the build artifact from git using a command
    like this (substitute the version in teh sample below for the version you created in step 1)
    # git archive --prefix=minitwit-1.2.3/ -o builds/minitwit-1.2.3.zip 1.2.3
- Run the playbook to generate the build:
  # ansible-playbook -i local-inv make-build.yml

Important things to think about:
- How can the playbook prompt at runtime for the correct version to build?
- How can you prevent ansible from re-making the artifact if it's already there?
- Extra Credit: How would you let ansible cleanup a failed artifact file from the command step

## Second Task: Configure the server

Now that we have an artifact, we need to configure the target server to prep
it to run the deployed code.  The required system configs have already been
created and templated for us.  They expose the following variables that will
need to be set in our playbook:
  - minitwit_config_dir - Directory containing minitwit.conf
  - minitwit_database_dir - Directory containing minitwit.sqlite
  - minitwit_debug - If app runs in debug mode or not
  - minitwit_flask_appname - Name for the app in Flask
  - minitwit_per_page - Items to show per page in UI
  - minitwit_secret_key - Secret db key stuff
  - minitwit_src_dir - Directory where build artifact will be unpacked into
  - minitwit_system_group - Name of the system group that the app will run as
  - minitwit_system_user - Name of the system user that the app will run as
  - minitwit_venv_dir - Directory where the virtualenv that pip will install into

We need to create new playbook, let's call it site.yml, that will do the following
  - with yum, install: epel-release
  - with yum, install: python-virtualenv, python-pip, zip, unzip
  - with user, make sure there is a `minitwit_system_user` user (group will be created automatically)
  - with file, make sure required directories (*_dir variables) are present and owned by correct user/group
    - you may want to put these dirs in the system user's homedir
  - with template, put configs/minitwit.service.j2 into destination /etc/systemd/system/minitwit.service
    - with a notify, reload systemd using "systemctl daemon-reload" if the service file changes
  - with template, put configs/minitwit.conf.j2 into destination "{{ minitwit_config_dir }}/minitwit.conf"

You can uncomment the ansible section in the Vagrantfile in order to run
ansible playbook against the vagrant vm.  Please lave the "extra_vars" section
commented until the third task.  After which you can run ansible with
  # vagrant provision
You can run this as often as you need

At the end of this section a subsequent run of ansible should yield no
changes, just "ok."  Doing a "vagrant destroy" and "vagrant up" should produce
a clean run with no errors and no subsequent changes after the first run.

## Third Task: Deploy the Artifact

Now that we have a built artifact and a configured server we can deploy the
application to the server.

For simplicity's sake we can add to the end of the already existing site.yml.
In real life you may choose to have this code in a separate playbook, use
tags, or other logic to reduce the run time for deploys.

To the existing site.yml we need to add steps to deploy any given release:
  - if there is an artifact to deploy, using unarchive, expand the artifact in the correct location
    - restart the minitwit service if something changed
  - if there is an artifact to deploy, using pip module, install the module as editable and using a virtualenv homed in the correct place
    - restart the minitwit service if something changed
  - using command, run the initdb task (see README) if the minitwit.sqlite is not created in the correct location
  - ensure that the minitwit service is set to run at boot time and is currently started

Once deployed, you should be able to see your minitwit application install at:
http://192.168.33.10:5000/

Important things to think about:
- Is there a better module for doing deploys in ansible that we could use?
- How could we check to see if the app was running at the end of deploy?
- How could we make the passing of the artifact easier/cleaner?
- How could we make the deploy steps idempotent?


