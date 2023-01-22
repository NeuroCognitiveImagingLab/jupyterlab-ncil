FROM jupyter/datascience-notebook:2023-01-16

LABEL maintainer="Aaron Newman <https://github.com/aaronjnewman>"

USER root

# APT packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
	build-essential \
	bzip2 \
    unzip \
    xz-utils\
    ca-certificates p11-kit \
    curl \
    fonts-dejavu \
    tzdata \
    gfortran \
    gcc \
    libgmp-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#  Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& apt update \
	&& apt install gh -y

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

USER $NB_UID

# Conda packages
# Sage conflicts with the latest jupyterhub, thus we must relax the pinning
RUN mamba install --quiet --yes \
		-c conda-forge \
        jupyter_server=2.0.0 \
		jupyterlab-git \
		mne mne-bids autoreject python-picard \
		pybv mne-qt-browser h5io h5py pymatreader \
		nodejs nbconvert \
		pyarrow  \
		neurodsp pydicom dicom2nifti nibabel nilearn \
		r-ggthemes r-lattice r-corrplot \
		r-lme4 r-mgcv \
		r-car r-viridis \
		r-emmeans r-rann \
		r-sjplot r-sjstats r-ggeffects \
		r-party r-partykit r-rann \
		r-reshape2 r-see r-arrow r-ranger \
		r-stargazer \
		r-languageserver && \
	mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

ENV CPATH=$CONDA_DIR/include

# Install R packages not contained in Anaconda
USER root
RUN echo "install.packages(c('glmmLasso','ez', \
    'likert', 'FactoMineR', 'stablelearner', 'githubinstall', \
	'itsadug', 'psycho'), \
    dependencies=TRUE, repos='https://mirror.csclub.uwaterloo.ca/CRAN/')" | R --no-save
USER $NB_UID

# RUN pip install --upgrade pip && \
#     fix-permissions "${CONDA_DIR}" && \
#     fix-permissions "/home/${NB_USER}" && \
#     ls -la /home


# Add conda env hook
COPY ./conda-activate.sh /usr/local/bin/before-notebook.d/
# Portainer no like COPY
# RUN wget https://github.com/NeuroCognitiveImagingLab/jupyterhub-docker-vm1/blob/master/jupyterlab/conda-activate.sh &&
#     mv ./conda-activate.sh /usr/local/bin/before-notebook.d/