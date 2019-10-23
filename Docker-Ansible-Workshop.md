# Docker Ansible Workshop

## The Situation

Your CEO just wrote a quick "Twitter like" application.  Since he's heard you
mention DevOps before, he's handed the code off to you to get ready for the
sales team.  They need to be able to deploy and redeploy the application on
their laptops in order to demo it to potential clients.

You need to automate these processes so they are easy to perform and produce
consistent results.  To illustrate how "easy to deploy inside the firewall"
the app is, you need to setup a VM to run the app which is delivered as a
Docker container.

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
```
vagrant box add centos/7
```
- If you don't have git and ansible install them now as well:
  - git: https://git-scm.com/downloads
  - ansible: http://docs.ansible.com/ansible/latest/intro_installation.html
- clone the following repo ahead of time:
  - https://github.com/nathanhruby/minitwit.git
  Feel free to fork this if you want to push tags and changes.

- Note for Mac Users: VirtualBox and Vagrant are both in Homebrew cask, git
  and ansible are in regular homebrew
- Note for Linux users: VirtualBox and Vagrant should be downloaded and
  installed from upstream, git and ansible system packages are fine
- If you have any problems, we can resolve these at the start of the workshop

## Use the docs

The ansible documents are very complete (perhaps too complete).  Here are some
pages you will need for these exercises:

### Language Parts

- playbooks: http://docs.ansible.com/ansible/latest/playbooks_intro.html
- variables: http://docs.ansible.com/ansible/latest/playbooks_variables.html
- loops: http://docs.ansible.com/ansible/latest/playbooks_loops.html
- conditionals: http://docs.ansible.com/ansible/latest/playbooks_conditionals.html
- become: http://docs.ansible.com/ansible/latest/become.html
- roles: https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html

### Modules

- file module: http://docs.ansible.com/ansible/latest/file_module.html
- user module: http://docs.ansible.com/ansible/latest/user_module.html
- command module: http://docs.ansible.com/ansible/latest/command_module.html
- yum package manager: http://docs.ansible.com/ansible/latest/yum_module.html
- system services: http://docs.ansible.com/ansible/latest/service_module.html
- assert module: https://docs.ansible.com/ansible/latest/modules/assert_module.html
- uri module: https://docs.ansible.com/ansible/latest/modules/uri_module.html
- templating module: http://docs.ansible.com/ansible/latest/template_module.html

## The Task: Install Docker and Run the Container

Once deployed, you should be able to see your minitwit application install at:
http://192.168.33.10:5000/

To Do:

- Write a role that installs Docker CE on Centos 7.  
  - This role should port the steps listed at https://docs.docker.com/install/linux/docker-ce/centos/#set-up-the-repository to ansible tasks using the correct modules (command, yum, service, etc..)
- Write playbook tasks that will install, run, and test the application docker container
  - Create a the database directory for the container to mount (/var/lib/minitwit)
  - Copy the systemd unit file for the container, load it and start it (configs/minitwit-docker.service)
  - Test that the service is up and running correctly
- Bonus Rounds:
  - Adjust the flow such that ansible ran the docker pull to pull a requested version before service start instead of the systemd unit doing a pull on latest
  - Add vars to the playbook, template over configs/minitwit.conf.j2 to the host, and update the systemd file to mount the config file overriding the defaults
  - Think about what would need changing if the database was redis and you needed to deploy 3 copies of the app that talked to it
