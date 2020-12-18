# ccmb-jenkins
Basic setup for running a local jenkins on docker.

## Extended jenkins image
Use the extended [jenkins image from dockerhub](https://hub.docker.com/r/jenkins/jenkins) with installed plugins.

* Pull the image [williamjds/ccmb-jenkins](https://hub.docker.com/repository/docker/williamjds/ccmb-jenkins) from dockerhub.
    ```shell script
    docker pull williamjds/ccmb-jenkins:latest
    ```

* Build the image locally.
    ```shell script
    docker build --build-arg BUILD_DATE=`date -u +”%Y-%m-%dT%H:%M:%SZ”` --build-arg VCS_REF=`git rev-parse --short HEAD` -t williamjds/ccmb-jenkins:latest .
    ```

## Webhook integration for jenkins behind firewall

For receiving webhooks behind a firewall, red the docker steps for [Production-ready Github and Jenkins setup behind a firewall](https://webhookrelay.com/v1/tutorials/github-webhooks-jenkins-vm.html).
You will need to
* signup to [https://webhookrelay.com/](https://webhookrelay.com/)
* install the CLI for webhookrelay
* create a webhookrelay key and secret
* setup a webhook relay bucket and public endpoint for forwarding webhooks
* download the agent docker image [webhookrelay/webhookrelayd](https://hub.docker.com/r/webhookrelay/webhookrelayd) from dockerhub
    ```
    docker pull webhookrelay/webhookrelayd
    ```
  
:warning: The components in the docker-compose setup can reach each other via the name of the service in the `docker-compose.yml` as hostname. The relay forward in this example needs to point to the service `jenkins`. See [Docker Networking in Compose](https://docs.docker.com/compose/networking/)) 
```
relay forward --bucket github-jenkins-compose http://jenkins:8080/github-webhook/ --no-agent
```

## Docker compose
There is a great tutorial on [How To Automate Jenkins Setup with Docker and Jenkins Configuration as Code](https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code).
The docker-compse.yml in this repository combines the basic setup from this tutorial with the webhookrelay setup and a configuration server. For docker-compose to work with this setup, create a file named `.env` in the top directory (ignored by git) which contains the following secrets:
```dotenv
JENKINS_ADMIN_ID=
JENKINS_ADMIN_PASSWORD=
RELAY_KEY=
RELAY_SECRET=
BUCKETS=
BROWN_ACCOUNT_USER=
BROWN_ACCOUNT_PASSWORD=
GITHUB_ACCOUNT_USER=
GITHUB_ACCOUNT_PASSWORD=
GITHUB_WEBHOOK_SECRET=
```
The secrets are required to successfully setup a basic admin user, integrate the webhook forwarding, and configure credentials for Github and Brown accounts.

For starting a local jenkins, configuration server, and webhookrealy agent, run
 ```shell script
 docker-compose up -d
```

### Configuration as code
The configuration as code plugin is preinstalled in this image. With this, it is possible to configure jobs on the jenkins instance. 

#### Configuration server in docker compose
A neat solution that allows to update configuration is to server the configuration file via php server. In this setup, a php server serves the configuration directory in this repository. It can be replaced by providing this directory via volume mount.
In the configuration as code setup, the URL to the initial configuration file needs to be configured via the environment variable `CASC_JENKINS_CONFIG`. Since the `ccmb-jenkins` container is sharing a network with the configuration server as part of the docker compose setup, the configuration server can be addressed via the docker compose name of the service. The URL can look like this:
```dotenv
CASC_JENKINS_CONFIG=http://configuration-server:9000/configuration-as-code.yaml
```
With the configuration directory mounted als volume to the configuration server, the content can be updated and applied via the GUI for configuration as code in a running jenkins instance.

#### Configuration via volume mount
Alternatively, you can mount the configuration file as volume to the `ccmb-jenkins` container. Extend the docker compose file section and add a volume mount. Redirect the `CASC_JENKINS_CONFIG` environment variable to target mount destination inside the jenkins container.
