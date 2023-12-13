FROM jupyter/datascience-notebook:2023-03-06

LABEL maintainer="Aaron Newman <https://github.com/aaronjnewman>"

USER root

# APT packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
	# build-essential \
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
# RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
# 	&& chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
# 	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
# 	&& apt update \
# 	&& apt install gh -y

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

USER $NB_UID

# Conda packages
# Sage conflicts with the latest jupyterhub, thus we must relax the pinning
RUN mamba install --quiet --yes \
		-c conda-forge \
		# jupyterlab-git \
		mne mne-bids mne-nirs autoreject python-picard \
		pybv mne-qt-browser mayavi h5io h5py pymatreader \
		nodejs nbconvert \
		pyarrow  \
		neurodsp pydicom dicom2nifti nibabel nilearn \
        r-essentials \
		r-ggthemes r-lattice r-corrplot \
		r-lme4 r-mgcv \
		r-car r-viridis \
		r-emmeans  r-e1071 r-rann \
		r-sjplot r-sjstats r-ggeffects \
		r-party r-partykit r-rann \
		r-reshape2 r-see r-arrow r-ranger \
		r-stargazer r-brms \
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

# RUN pip install jupyter-ai && \
#     fix-permissions "${CONDA_DIR}" && \
#     fix-permissions "/home/${NB_USER}" &&

# RUN pip install git+git://github.com/autoreject/autoreject@master && \
#     fix-permissions "${CONDA_DIR}" && \
#     fix-permissions "/home/${NB_USER}" && \
#     ls -la /home

# Add conda env hook
# COPY ./conda-activate.sh /usr/local/bin/before-notebook.d/
# COPY ./rebind-mount.sh /usr/local/bin/before-notebook.d/
# COPY start.sh /usr/local/bin

# from https://discourse.jupyter.org/t/cannot-use-sudo-have-root-access-using-jupyterhub-with-kubernetes/12548/7
# RUN sed -i "s/auth requisite pam_deny.so//g" /etc/pam.d/su