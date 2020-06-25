ARG PYTHON3_IMG="saagie/python:3.6.202005.84"

# use jupyter/minmal from 20200618
ARG BASE_CONTAINER="jupyter/minimal-notebook:04f7f60d34a6"

FROM $PYTHON3_IMG AS PYTHON3
FROM $BASE_CONTAINER

MAINTAINER Saagie

ENV PATH="${PATH}:/home/$NB_USER/.local/bin"


# Starts by cleaning useless npm cache & other files
RUN npm cache clean --force \
    && conda clean -ay \
    && rm -rf $CONDA_DIR/share/jupyter/lab/staging
# Not necessary to apt-get clean it seems

########################## LIBS PART BEGIN ##########################
USER root
# TODO check if all necessary seems there are duplicate from jupyter/scipy image
RUN apt-get update -qq && apt-get install -yqq --no-install-recommends \
      # replaces libpng3 for bionic
      libpng16-16 \
      # replaces libdal6 for bionic
      libgdal-dev \
      # needed to compile psycopg2
      libpq-dev \
      curl \
      libxml2-dev libxslt1-dev antiword unrtf poppler-utils pstotext tesseract-ocr \
      flac ffmpeg lame libmad0 libsox-fmt-mp3 sox libjpeg-dev swig redis-server libpulse-dev \
      libfreetype6-dev libatlas-base-dev gfortran \
      sasl2-bin libsasl2-2 libsasl2-dev \
      libsasl2-modules unixodbc-dev python3-tk \
      qt5-default \
      libqt5webkit5-dev \
      libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*
########################## LIBS PART END ##########################


################ Kernels / Conda envs / requirements PART BEGIN ################
USER $NB_USER
# Uninstall python3 kernel
RUN jupyter kernelspec remove -f python3

# Update conda to latest version
RUN conda update -n root conda \
    && conda clean -afy

# seems there's sometimesa problem with pyzmq so need to reinstall it...
RUN conda create -n py36 python=3.6 \
    && bash -c "source activate py36 && pip uninstall pyzmq -y && pip install pyzmq && conda install notebook ipykernel -y && ipython kernel install --user --name py36 --display-name 'Python 3.6'" \
    && conda clean -afy \
    && rm -rf ~/.cache/pip

# TODO check if all necessary seems there are duplicate from jupyter/scipy image
SHELL ["/bin/bash", "-c"]
# Add libs for python 3.6 env
#     inherited from saagie/python:3.6 image
#     installed via pip only
#     installed via conda
COPY requirements_conda3.txt requirements_conda3.txt
COPY --from=PYTHON3 /requirements.txt ./requirements_python3.txt
COPY requirements_pip3.txt requirements_pip3.txt
RUN conda install -n py36 --quiet --yes --file requirements_conda3.txt \
    # Some installed library (scikit-learn) could not be removed so use --ignore-installed \
    && sed -n '/scikit-learn/p' requirements_python3.txt >> requirements_python3_ignore-installed.txt \
    && sed -i '/scikit-learn/d' requirements_python3.txt \
    && . activate py36 \
    && python -m pip install --no-cache-dir --ignore-installed -r requirements_python3_ignore-installed.txt \
    && python -m pip install --no-cache-dir -r requirements_python3.txt \
    && python -m pip install --no-cache-dir -r requirements_pip3.txt \
    && conda deactivate \
    && conda clean -afy \
    && rm -rf ~/.cache/pip
################ Kernels / Conda envs / requirements PART ENDS #################


########################## CUDA PART BEGIN ##########################
USER root

ENV PATH="${PATH}:/usr/local/nvidia/bin:/usr/local/cuda/bin"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64"
# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=410,driver<411"

ENV CUDA_VERSION 10.0.130
ENV CUDA_PKG_VERSION 10-0=$CUDA_VERSION-1
ENV NCCL_VERSION 2.4.2
ENV CUDNN_VERSION 7.6.0.64

LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update -qq && apt-get install -yqq --no-install-recommends \
      ca-certificates gnupg2 && \
    rm -rf /var/lib/apt/lists/* && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
    # For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
    apt-get update -qq && apt-get install -yqq --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION \
        cuda-libraries-$CUDA_PKG_VERSION \
        cuda-nvtx-$CUDA_PKG_VERSION \
        cuda-compat-10-0 \
        libnccl2=$NCCL_VERSION-1+cuda10.0 \
        libcudnn7=$CUDNN_VERSION-1+cuda10.0 \
    && apt-mark hold libnccl2 libcudnn7 \
    && ln -s cuda-10.0 /usr/local/cuda \
    && rm -rf /var/lib/apt/lists/* \
    # Path doesn't exists... here for compatibility it seems https://gitlab.com/nvidia/container-images/cuda/issues/27
    && echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
########################## CUDA PART END ##########################


########################## NOTEBOOKS DIR ##########################
USER root
# Create default workdir (useful if no volume mounted)
RUN mkdir /notebooks-dir && chown 1000:100 /notebooks-dir
# Define default workdir
WORKDIR /notebooks-dir
########################## NOTEBOOKS DIR  END ##########################

#Add entrypoint.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Should run as $NB_USER
USER $NB_USER

# Default: run without authentication
CMD ["/entrypoint.sh"]
