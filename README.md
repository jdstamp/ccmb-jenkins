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
