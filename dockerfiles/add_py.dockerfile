FROM rocker/verse:4.2.0 as ssh
LABEL org.opencontainers.image.authors="w <@>"
# https://github.com/pytorch/pytorch/blob/master/Dockerfile
# docker build -t rv -f add_py.dockerfile .
# docker network create br
# docker run -d --restart=unless-stopped --network=br -p 8787:8787 -p 5422:22 --gpus=all -v //e/g:/home/rstudio/g:z --name rv -e PASSWORD=.... rv
# docker run -d --restart=unless-stopped --network=br -p 4444:4444 -p 7900:7900 --name selBeta --shm-size 4g -e SE_NODE_MAX_SESSIONS=5  selenium/standalone-chrome:beta
# gt705 PCIROOT(0)#PCI(0200)#PCI(0000) 
#ARG PYTHON_VERSION=3.8
#ENV PATH /opt/conda/bin:$PATH

#auth-timeout-minutes=0
#auth-stay-signed-in-days=5

RUN apt-get update && apt-get install -y openssh-server iputils-ping curl # htop rsyslog
RUN mkdir /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN addgroup rstudio sudo
#RUN echo 'root:mypassword' | chpasswd  # instead: docker exec -u 0 -it <container> bash
#RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

FROM ssh as py
ENV WORKON_HOME=/opt/venv
ENV PYTHON_VENV_PATH=/opt/venv/reticulate

ENV PYTHONPATH=${PYTHON_VENV_PATH}/lib/python3.8
#ENV PYTHON_CONFIGURE_OPTS=--enable-shared  # causing setuptools issue?
ENV RETICULATE_AUTOCONFIGURE=0
ENV PATH=${PYTHON_VENV_PATH}/bin:${PATH}
RUN /rocker_scripts/install_python.sh


FROM py as pip
COPY add_pip.txt /opt/
RUN pip3 install setuptools==60.0.0     # python3 -m pip
RUN pip3 install -r /opt/add_pip.txt

# FROM pip as vscode
# RUN apt update && apt install -y gnome-keyring
# RUN wget -O- https://aka.ms/install-vscode-server/setup.sh | sh

EXPOSE 22
#FIXME conda PATH
ENTRYPOINT ["/init"]
CMD ["/usr/sbin/sshd", "-D"]