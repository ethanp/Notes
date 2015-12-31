## Storage

### Measuring performance

* Throughput -- how many bytes per second can be transferred
    * This is what most consumers look at, but it is often _not_ the system's
      bottleneck
* Latency -- how long it takes for a data transfer to _begin_
* IOPS -- number of input or output operations per second supported by the
  device
    * This is generally the bottleneck in the enterprise or data center

#### References

* [throughput vs latency vs iops][tli]

[tli]: http://www.thessdreview.com/featured/ssd-throughput-latency-iopsexplained/

## Monitoring

### Like what?

* Generally time-series data
* Network bandwidth
* temperatures
* CPU load

### Database styles

* __RRD__ -- _round robin_ database based on a _circular buffer_
* __TTL__ -- _time to live_ database that stores data at a decreasing
  granularity as it gets older
    * This may involve running further aggregations on it to store it at a
      lower granularity

### Data load models

* __Pull__ -- the database polls some intermediate data queue
* __Push__ -- the generators issue (e.g.) HTTP POSTs containing JSON data

### Tools

* Shai's [crayon](https://github.com/shai-d/crayon)
* Nagios
* Graphite
* Munin (not that good)
* Ganglia

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
    * That's why it doesn't require _any_ software installation on the _managed
      nodes_
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
        * including trivializing things like zero downtime rolling updates with
          load balancers.
* Design goals include
    * Minimal dependencies
    * consistency
    * security (esp. of _managed_ nodes)
    * reliability (via _idempotent_ operations)
    * easy to understand and modify
* Works on all major public and private cloud environments

### Basics
* Ansible runs directly from its python source, so upgrading basically amounts
  to a `git pull`
* __Control machine__ -- "could easily be a laptop"
* __Managed nodes__ -- require `ssh` to be able to be controlled by the
  _control machine_
* __Module__ -- a standalone (idempotent!) _unit of work_ (i.e. script) in
  Python, Ruby, Bash, etc.
* __Inventory__ -- lists IP addrs or hostnames of each accessible node
    * Inventoried nodes may also be assigned to groups
    * If you're using EC2 nodes, look into the specific "EC2 external inventory
      script"
* __Task__ -- a call to an ansible _module_
* __Role__ -- calls _tasks_
    * "Roles are great and you should use them every time you write playbooks"
    * They let you combine included files to form clean reusable abstractions
* __Play__ -- maps a group of hosts to a set of roles
    * Lists a set of tasks to execute _in order_
* __Playbook__ -- a list of _plays_ that execute _in order_
    * Expresses configurations, deployment, and orchestration
    * Can launch tasks synchronously _or_ asynchronously
    * If a host fails to execute a task, it is not issued any subsequent task
      for this run of the playbook
        * Shouldn't matter much since playbooks are idempotent, so you can just
          debug and rerun
    * Run a given playbook YAML file with `ansible-playbook playbook.yml`
* __patterns__ -- syntax for telling ansible which hosts the following command
  applies to
    * `all` or `*` -- target all hosts in the _inventory_
    * `hostname` or `IP.addr` or `groupname` -- target who you think
    * It also gets more complicated if you want it to

[ans-fst]: https://github.com/ansible/ansible/commits/devel?page=498

## Vagrant
* Creates identical development environments repeatably across machines
* after installing it, you run `vagrant init [title]` and it creates a
  `Vagrantfile`
* In the `Vagrantfile`, you specify how it should retrieve a Linux distro, and
  how to make a virtual machine in VirtualBox running locally talk to your
  local (host) machine
* You might now locally run an ansible (or chef, etc.) command to further
  customize and standardize the environment in that virtual machine
* One of the problems that Vagrant solves is allowing developers to test their
  changes locally on a system that is configured _exactly_ like the production
  environment

## Debian Packages
* Can be either a _source_ or _binary_ package
* __Binary__ -- distributed using the Debian archive format with suffix `.deb`
    - executables
    - config files
    - man pages
* __Source__ -- typically you get one of these to then build the executable
  locally and then run it
* The package may state other packages on which it depends, replaces, conflicts
  with, etc.
* [un]installation of debian packages is managed with the `dpkg` software

## Elastic Search
## Kibana
