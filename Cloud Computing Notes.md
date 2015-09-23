latex input:        mmd-article-header
Title:             Notes on Cloud Computing
Author:            Ethan C. Petuchowski
Base Header Level:	1
latex mode:		   memoir
Keywords:		     Theory, Distributed Computing, Modern Technology
CSS:		        http://fletcherpenney.net/css/document.css
xhtml header:    <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
copyright:		 2015 Ethan C. Petuchowski
latex input:		 mmd-natbib-plain
latex input:		 mmd-article-begin-doc
latex footer:	 mmd-memoir-footer

## Platform as a Service
#### September 23, 2015

From [Wikipedia](http://www.wikiwand.com/en/Platform_as_a_service)

* Allows customers to develop, run, and manage Web applications without the
  complexity of building and maintaining the infrastructure
* It can either be
    * A 'public cloud' service on the provider's hardware
    * Software installed in private data centers
* For example, it might provide an application API containing some Node
  functionality, a NoSQL object store and message queue services
* The original term was "Framework as a Service" (2006)
* Google launched App Engine in 2008
* PaaS simplifies code-writing, hosting, and deploying for developers, and
  handles the infrastructure and operations side of things, such as networking,
  security, scalability, persistence, instrumentation, and monitoring
    * This lets the developer focus on business value
* One may typically pay for storage used, network traffic, and CPU usage
* The main downside is some amount of vendor lock-in
* PaaS Sits between SaaS and IaaS
    * SaaS is software hosted in the cloud
    * IaaS is virtualized hardware
* Some PaaS vendors (2015) are Apprenda, Microsoft (Azure), Red Hat, Pivotal,
  Oracle, Salesforce, and Cloud Foundry
