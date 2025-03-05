# jupyterlab-ncil

This is a repository to build a jupyterlab Docker image to the specifications of the NeuroCognitive Imaging Lab, Dalhousie University. 

It could run as standalone, but is meant to be pulled during deployment of jupyterhub over Docker.

To build it and then push to Dockerhub (from where it can be pulled when building jupyterhub), run the following lines of code on the command line. It will create a new image tagged with today's date, and also update the latest tag on dockerhub with this build.

NOTE: You need to be logged in to dockerhub first.

```
export BUILD=$(date +%y-%m-%d)
docker build -t ncilab/jupyterlab-ncil:$BUILD .
docker push ncilab/jupyterlab-ncil:$BUILD
export imgID=`docker images ncilab/jupyterlab-ncil:$BUILD --format "{{.ID}}"`
docker tag $imgID ncilab/jupyterlab-ncil:latest
docker push ncilab/jupyterlab-ncil:latest
```

If you want to update Python or R pacakges in the Docker container, you will need to force Docker to build the whole stack from scratch. Otherwise, it uses a cached version based on a previous build, and only changes things that are reflected as changes in the Dockerfile. To do this (note, it takes much longer), run the commands below in lieu of the ones above:

```
export BUILD=$(date +%y-%m-%d)
docker build --no-cache -t ncilab/jupyterlab-ncil:$BUILD .
docker push ncilab/jupyterlab-ncil:$BUILD
export imgID=`docker images ncilab/jupyterlab-ncil:$BUILD --format "{{.ID}}"`
docker tag $imgID ncilab/jupyterlab-ncil:latest
docker push ncilab/jupyterlab-ncil:latest
```