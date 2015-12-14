## Ansible

### Layman's Terms
* You want to deploy a distributed system
* You tell Ansible how to connect via ssh to each of the member nodes
* Ansible executes the scripts you give it on all of the relevant nodes

### Buzzwords
* Ansible is a radically simple IT automation system.
    * It was [started][ans-fst] in 2012
* Competitors include __Chef__ and __Puppet__
    * The major difference being Ansible's _'agentless'_ architecture
        * Which means Ansible requires no daemons for background execution
        * This means nodes never poll the control machine
* It manages machines over ssh.
    * That's why it doesn't require _any_ software installation on the _managed nodes_ 
* It handles 
    * computer __configuration__ & __management__
    * application __deployment__
    * cloud __provisioning__
        * select which machines to use
        * install OS, drivers, middleware, and applications
            * perhaps by using a "boot image"
        * configure system params (e.g. IP address)
    * ad-hoc __task-execution__
    * multinode __orchestration__
        * including trivializing things like zero downtime rolling updates with load balancers.
* Design goals include
    * Minimal dependencies
    * consistency
    * security (esp. of _managed_ nodes)
    * reliability (via _idempotent_ operations)
    * easy to understand and modify
* Works on all major public and private cloud environments

### Basics
* Ansible runs directly from its python source, so upgrading basically amounts to a `git pull`
* __Control machine__ -- "could easily be a laptop"
* __Managed nodes__ -- require `ssh` to be able to be controlled by the _control machine_
* __Module__ -- a standalone (idempotent!) _unit of work_ (i.e. script) in Python, Ruby, Bash, etc.
* __Inventory__ -- lists IP addrs or hostnames of each accessible node
    * Inventoried nodes may also be assigned to groups
    * If you're using EC2 nodes, look into the specific "EC2 external inventory script"
* __Task__ -- a call to an ansible _module_
* __Role__ -- calls _tasks_
    * "Roles are great and you should use them every time you write playbooks"
    * They let you combine included files to form clean reusable abstractions
* __Play__ -- maps a group of hosts to a set of roles
    * Lists a set of tasks to execute _in order_
* __Playbook__ -- a list of _plays_ that execute _in order_
    * Expresses configurations, deployment, and orchestration
    * Can launch tasks synchronously _or_ asynchronously
    * If a host fails to execute a task, it is not issued any subsequent task for this run of the playbook
        * Shouldn't matter much since playbooks are idempotent, so you can just debug and rerun
    * Run a given playbook YAML file with `ansible-playbook playbook.yml`
* __patterns__ -- syntax for telling ansible which hosts the following command applies to
    * `all` or `*` -- target all hosts in the _inventory_
    * `hostname` or `IP.addr` or `groupname` -- target who you think
    * It also gets more complicated if you want it to

[ans-fst]: https://github.com/ansible/ansible/commits/devel?page=498

## Vagrant
## Elastic Search
## Kibana