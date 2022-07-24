# Ansible for Crestron VC4

## Description

Ansible role for automating the installation of Crestrons Virtual Control 4 Server based ControlSystem.

Feel free to fork and contribute

**The only part of the task I am unable to complete is the rpm install, it requires user input**

I tried using the Ansible Expect module but the job either hangs, or puts in the incorrect values, if anyone has any experience automating that with ansible, feel free to create a pull-request.

Current Version: [virtualcontrol-4.0000.00007-1](https://www.crestron.com/Software-Firmware/Firmware/4-Series-Control-Systems/VC-4/4-0000-00007-01)

TODO:

- [] Automate/resolve input automation for the rpm package install

The input values:

```text
"Install Are you migrating VC4 from another build? (Y/N) "
"Enter virtualcontrol Home Path ( Default /opt/crestron/ ) "
"Press Enter To Continue With Default Value (6980) "
"Press Enter To Continue With Default Value (41794) "
"Press Enter To Continue With Default Value (41796) "
"Press Enter To Continue With Default Value (49200) "
"Press Enter To Continue With Default Value (49300) "
"Please provide new password for the MariaDB Root user "
"confirm pw "
"Please provide a name for the database or press enter to accept the default (default is VirtualControl) "
"Please provide the name for the database's user account (default is virtualcontrol) "
"Please provide a password for the virtualcontrol user or press enter to accept the default (default is [RANDOM STRING]) "
"confirm "
```

Update values in the following file

- `host` - change ip address to your servers ip address
- `.vault.txt` - create a .vault.txt file and save it in the root of this directory with a single line password
- `vault.yml` - update the 2 vault files in the following location `group_vars/all/vault.yml.example`,`roles/virtualcontrol/defaults/vault.yml.example` and remove the `.example` or make a copy of the file without the `.example` extension

## Usage

- Create a `.ansible_vault_pass.txt` file in the root of this repo with a password
- add credentials in the `vault.yml` file located in the path `roles/virtualcontrol/defaults/vault.yml`
- If you are using a RedHat system, place credentials in the vault file

Content of .ansible_vault_pass.txt

```text
my_password_to_use
```

Contents of the `roles/virtualcontrol/defaults/vault.yml` file

```yaml
vault_rhsm_user: ""
vault_rhsm_pass: ""
vault_crestron_user: ""
vault_crestron_pass: ""
vault_mariadb_root_pass: ""
vault_mariadb_name: ""
vault_mariadb_user: ""
```

Contents of the `group_vars/all/vault.yml` these are required, they will be used for user and password of the server

```yaml
vault_ansible_user: ""
vault_ansible_pass: ""
```

Download the vc4 package, unzip it and place the following files inside of the `roles/virtualcontrol/files` directory

- crestron.repo
- crestron1.repo
- requirement.txt
- virtualcontrol.rpm file (current version: virtualcontrol-4.0000.00007-01.noarch.rpm )

_Running the playbook_

```shell
ansible-playbook installVC4.yml
```
