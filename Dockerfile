FROM jupyter/datascience-notebook:latest

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
    # fonts-dejavu \
    tzdata \
    gfortran \
    gcc \
    libgmp-dev \
    libegl1 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

#  Install GitHub CLI
# RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
# 	&& chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
# 	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
# 	&& apt update \
# 	&& apt install gh -y

# Default to UTF-8 file.encoding
ENV LANG=C.UTF-8

USER $NB_UID

# Conda packages
RUN mamba install --quiet --yes \
		-c conda-forge \
		# jupyterlab-git \
        jupyter-ai \
        # qt6-main \
		mne mne-bids mne-nirs autoreject python-picard \
        mnelab>=1.0.0 \
        #  mne-qt-browser \
		pyxdf \
        # pybv mayavi \
        h5io h5py \
        # pymatreader \
		nodejs nbconvert \
		pyarrow pingouin \
        nilearn \
		# neurodsp pydicom dicom2nifti nibabel nilearn \ 
        # # dcm2bids \
        gcc_linux-64 gxx_linux-64 \
        r-essentials \
        r-rjson \
		r-ggthemes r-lattice r-corrplot \
		r-lme4 r-mgcv \
		r-car r-viridis \
		r-emmeans r-e1071 r-rann \
		r-sjplot r-sjstats r-ggeffects \
		r-party r-partykit r-rann \
		r-reshape2 r-see r-arrow r-ranger \
		r-stargazer r-brms \
		r-languageserver \
        r-targets r-here r-devtools r-visnetwork r-conflicted r-ggbeestorm r-ggextra r-glmmtmb \
        && \
	mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

ENV CPATH=$CONDA_DIR/include

# Install R packages not contained in Anaconda
USER root
RUN echo "install.packages(c('glmmLasso','ez', 'itsadug', 'psycho'), \
    dependencies=TRUE, repos='https://mirror.csclub.uwaterloo.ca/CRAN/')" | R --no-save
USER $NB_UID

RUN echo "devtools::install_github('dustinfife/flexplot')" | R --no-save

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir mnelab rev_ai && \
    fix-permissions "/home/${NB_USER}" 

# RUN pip install git+git://github.com/autoreject/autoreject@master && \
#     fix-permissions "${CONDA_DIR}" && \
#     fix-permissions "/home/${NB_USER}" && \
#     ls -la /home
