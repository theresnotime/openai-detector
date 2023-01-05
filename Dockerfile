# syntax=docker/dockerfile:1.4
FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu18.04
# BEGIN Static part
ENV DEBIAN_FRONTEND=noninteractive \
	TZ=Europe/Paris

RUN apt-get update && apt-get install -y \
        git \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev git-lfs  \
    	ffmpeg libsm6 libxext6 cmake libgl1-mesa-glx \
		&& rm -rf /var/lib/apt/lists/* \
    	&& git lfs install

# User
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
	PATH=/home/user/.local/bin:$PATH
WORKDIR /home/user/app

# Pyenv
RUN curl https://pyenv.run | bash
ENV PATH=$HOME/.pyenv/shims:$HOME/.pyenv/bin:$PATH

# Python
RUN pyenv install 3.7.5 && \
    pyenv global 3.7.5 && \
    pyenv rehash && \
    pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir \
        datasets \
        huggingface-hub "protobuf<4" "click<8.1"

COPY --link --chown=1000 requirements.txt /home/user/app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY --link --chown=1000 ./ /home/user/app

CMD ["python",  "-m", "detector.server", "detector-base.pt", "--port=7860"] 
