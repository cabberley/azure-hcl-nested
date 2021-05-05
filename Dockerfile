FROM mcr.microsoft.com/azure-cli:latest

ADD containerRun.sh /root/

RUN wget -q https://get.helm.sh/helm-v3.2.2-linux-amd64.tar.gz -O helm-v3.2.2-linux-amd64.tar.gz \
  && tar -zxvf helm-v3.2.2-linux-amd64.tar.gz -C /bin/ \
  && mv /bin/linux-amd64/helm /bin/

CMD ["/bin/bash", "/root/containerRun.sh"]
