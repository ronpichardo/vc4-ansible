# Ansible for Crestron VC4

## Description

Ansible role for automating the installation of Crestrons Virtual Control 4 Server based ControlSystem.

Feel free to fork and contribute

**Was able to get the rpm install to work with expect, but sometimes the task fails although the install was successful**

Tested with RockyLinux 9.3

I tried using the Ansible Expect module but the job either hangs, or puts in the incorrect values, if anyone has any experience automating that with ansible, feel free to create a pull-request.

Current Version: [virtualcontrol-4-0003-00039-02](https://www.crestron.com/Software-Firmware/Firmware/4-Series-Control-Systems/VC-4/4-0003-00039-02)

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
- virtualcontrol.rpm file (current version: virtualcontrol-4.0003.00039-1.noarch.rpm )

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
        │   ├── crestron1.repo
        │   ├── crestron.conf
        │   ├── crestron.repo
        │   ├── httpd-auth
        │   ├── requirement.txt
        │   └── virtualcontrol-4.0003.00039-1.noarch.rpm
        ├── tasks
        │   ├── harden.yml
        │   ├── install.yml
        │   ├── main.yml
        │   └── uninstall.yml
        └── templates
            └── udisks-crestron.j2
```

_Running the playbook_

```shell
ansible-playbook installVC4.yml
```

Current output when successful.

```shell
(ansible) ➜  vc4-ansible git:(main) ansible-playbook installVC4.yml

PLAY [Install VirtualControl4] ***********************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************
ok: [vc02]

TASK [Setup sudoers file] ****************************************************************************************************
changed: [vc02]

TASK [Run VirtualControl Role] ***********************************************************************************************

TASK [virtualcontrol : include_vars] *****************************************************************************************
ok: [vc02]

TASK [virtualcontrol : VirtualControl - running the install task] ************************************************************
included: /home/rage/Scripts/ansible/vc4-ansible/roles/virtualcontrol/tasks/install.yml for vc02

TASK [virtualcontrol : VirtualControl - Create tmp directory] ****************************************************************
ok: [vc02]

TASK [virtualcontrol : VirtualControl - Copy files to tmp] *******************************************************************
changed: [vc02] => (item=crestron.repo)
changed: [vc02] => (item=crestron1.repo)
changed: [vc02] => (item=requirement.txt)
changed: [vc02] => (item=virtualcontrol-4.0000.00007-1.noarch.rpm)

TASK [virtualcontrol : VirtualControl - OS Type Redhat, Register with RHSM] **************************************************
skipping: [vc02]

TASK [virtualcontrol : VirtualControl - OS Type AlmaLinux, installing repo files] ********************************************
changed: [vc02]

TASK [virtualcontrol : VirtualControl - Install dnf packages] ****************************************************************
changed: [vc02]

TASK [virtualcontrol : VirtualControl - Start httpd service] *****************************************************************
changed: [vc02]

TASK [virtualcontrol : VirtualControl - Install pip requirements] ************************************************************
changed: [vc02]

TASK [virtualcontrol : VirtualControl - Install pexpect] *********************************************************************
changed: [vc02]

TASK [virtualcontrol : VirtualControl - install virtualcontrol-4.0000.00007-1.noarch.rpm] ************************************
changed: [vc02]

TASK [virtualcontrol : VirtualControl - Start virtualcontrol service] ********************************************************
changed: [vc02]

PLAY RECAP *******************************************************************************************************************
vc02                       : ok=13   changed=9    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```
