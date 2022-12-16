# Ansible for Crestron VC4

## Description

Ansible role for automating the installation of Crestrons Virtual Control 4 Server based ControlSystem.  This automation will install VC4, harden the system, and install Cockpit

Feel free to fork and contribute

**Was able to get the rpm install to work with expect, but sometimes the task fails although the install was successful**

Tested with AlmaLinux 8.6

I tried using the Ansible Expect module but the job either hangs, or puts in the incorrect values, if anyone has any experience automating that with ansible, feel free to create a pull-request.

Current Version: [virtualcontrol-4.0000.00057-1]https://www.crestron.com/Software-Firmware/Firmware/4-Series-Control-Systems/VC-4/4-0000-00057)

TODO:

- [x] Automate/resolve input automation for the rpm package install
- [] Try and update the expect task, sometimes if fails even though the install was successful

The input values:

```text
"Are you migrating VC4 from another build? (Y/N) :"
"Press Enter To Continue With Default Value:"
"Press Enter To Continue With Default Value (6980):"
"Press Enter To Continue With Default Value (41794):"
"Press Enter To Continue With Default Value (41796):"
"Press Enter To Continue With Default Value (49200):"
"Press Enter To Continue With Default Value (49300):"
"Please provide new password for the MariaDB Root user:"
"Please confirm the password for root:"
"Please provide a name for the database or press enter to accept the default (default is VirtualControl):"
"Please provide the name for the database's user account (default is virtualcontrol):"
"Please provide a password for the virtualcontrol user or press enter to accept the default (default is [RANDOM STRING]):"
"Please confirm password:"
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
- virtualcontrol.rpm file (current version: virtualcontrol-4.0000.00057-1.noarch.rpm )

Directory structure should look something like this before running the playbook

```shell
├── ansible.cfg
├── .ansible_vault_pass.txt
├── .gitignore
├── group_vars
│   └── all
│       ├── vars.yml
│       ├── vault.yml
│       └── vault.yml.example
├── hosts
├── installVC4.yml
├── README.md
└── roles
    └── virtualcontrol
        ├── defaults
        │   ├── main.yml
        │   ├── vault.yml
        │   └── vault.yml.example
        ├── files
        │   ├── crestron.repo
        │   ├── crestron1.repo
        │   ├── virtualcontrol-4.0000.00007-01.noarch.rpm
        │   └── requirement.txt
        └── tasks
            ├── install.yml
            ├── main.yml
            └── uninstall.yml
```

_Running the playbook_

```shell
ansible-playbook installVC4.yml
```

Current output when successful.

```shell
(ansible) ➜  vc4-ansible git:(main) ansible-playbook installVC4.yml

PLAY [Install VirtualControl4] *************************************************************************************************************************************************************
TASK [Gathering Facts] *********************************************************************************************************************************************************************
ok: [192.168.1.2]

TASK [Setup passwordless sudo] *************************************************************************************************************************************************************
changed: [192.168.1.2]

TASK [Run VirtualControl Role] *************************************************************************************************************************************************************
TASK [virtualcontrol : include_vars] *******************************************************************************************************************************************************
ok: [192.168.1.2]

TASK [virtualcontrol : VirtualControl - running the install task] **************************************************************************************************************************
included: /home/gschellhas/vc4-ansible/roles/virtualcontrol/tasks/install.yml for 192.168.1.2

TASK [virtualcontrol : VirtualControl - Create tmp directory] ******************************************************************************************************************************
changed: [192.168.1.2]

TASK [virtualcontrol : VirtualControl - Copy files to tmp] *********************************************************************************************************************************
changed: [192.168.1.2] => (item=crestron.repo)
changed: [192.168.1.2] => (item=crestron1.repo)
changed: [192.168.1.2] => (item=requirement.txt)
changed: [192.168.1.2] => (item=virtualcontrol-4.0000.00057-1.noarch.rpm)

TASK [virtualcontrol : VirtualControl - OS Type Redhat, Register with RHSM] ****************************************************************************************************************
skipping: [192.168.1.2]

TASK [virtualcontrol : VirtualControl - OS Type AlmaLinux, installing repo files] **********************************************************************************************************
changed: [192.168.1.2]

TASK [virtualcontrol : VirtualControl - Install dnf packages] ******************************************************************************************************************************
changed: [192.168.1.2]

TASK [virtualcontrol : VirtualControl - Start httpd service] *******************************************************************************************************************************
changed: [192.168.1.2]

TASK [virtualcontrol : VirtualControl - Install pip requirements] **************************************************************************************************************************
changed: [192.168.1.2]

TASK [virtualcontrol : VirtualControl - Install pexpect] ***********************************************************************************************************************************
changed: [192.168.1.2]

TASK [virtualcontrol : VirtualControl - install virtualcontrol-4.0000.00057-1.noarch.rpm] **************************************************************************************************
changed: [192.168.1.2]

TASK [virtualcontrol : VirtualControl - Start virtualcontrol service] **********************************************************************************************************************
changed: [192.168.1.2]

TASK [Install mod_ssl for VC-4 Hardening] **************************************************************************************************************************************************
changed: [192.168.1.2]

TASK [Add VC-4 firewalld rules for port 443] ***********************************************************************************************************************************************
changed: [192.168.1.2]

TASK [Install mod_authnz_pam for VC-4 Hardening] *******************************************************************************************************************************************
changed: [192.168.1.2]

TASK [Setup mod_authnz_pam for VC-4 Hardening] *********************************************************************************************************************************************
changed: [192.168.1.2]

TASK [Copy pam auth config for VC-4 Hardening] *********************************************************************************************************************************************
changed: [192.168.1.2]

TASK [Setup permissions for Shadow VC-4 Hardening] *****************************************************************************************************************************************
changed: [192.168.1.2]

TASK [Configure Se Linux for httpd_md VC-4 Hardening] **************************************************************************************************************************************
changed: [192.168.1.2]

TASK [Copy pam auth config for VC-4 Hardening] *********************************************************************************************************************************************
changed: [192.168.1.2]

TASK [Restart HTTPD for VC-4 Hardening] ****************************************************************************************************************************************************
changed: [192.168.1.2]

TASK [Upgrade all packages] ****************************************************************************************************************************************************************
changed: [192.168.1.2]

TASK [Install Cockpit] *********************************************************************************************************************************************************************
changed: [192.168.1.2]

TASK [Start and Enable Cockpit to run on Boot] *********************************************************************************************************************************************
changed: [192.168.1.2]

TASK [Install Cockpit Navigator] ***********************************************************************************************************************************************************
changed: [192.168.1.2]

PLAY RECAP *********************************************************************************************************************************************************************************
192.168.1.2                : ok=27   changed=23   unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```
