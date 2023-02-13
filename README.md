# jupyterlab-ncil

This is a repository to build a jupyterlab Docker image to the specifications of the NeuroCognitive Imaging Lab, Dalhousie University. 

It could run as standalone, but is meant to be pulled during deployment of jupyterhub over Docker.

To rebuild, run:

`docker build -t ncilab/jupyterlab-ncil:23-01-22 .`
`docker push ncilab/jupyterlab-ncil:23-01-22`