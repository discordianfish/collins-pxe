FROM ubuntu:12.04
MAINTAINER Johannes 'fish' Ziemke <fish@docker.com>

RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > \
    /etc/apt/sources.list

RUN apt-get update
RUN apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    apt-get install -y -q initramfs-tools lldpd lshw linux-image \
		dnsmasq iptables golang git curl

WORKDIR /collins-pxe

ADD . /collins-pxe

RUN git clone https://github.com/discordianfish/banksman.git && \
    cd banksman && go build banksman.go && mv banksman /bin

RUN mkinitramfs -v -d ./initramfs-tools -o static/registration-initrd.gz `echo /boot/vmlinuz-*|sed 's/.*vmlinuz-//'`
RUN cp /boot/vmlinuz-* static/kernel
ADD http://boot.ipxe.org/undionly.kpxe /collins-pxe/static/
ADD https://raw.github.com/jpetazzo/pipework/master/pipework /sbin/
RUN chmod a+x /sbin/pipework

ENTRYPOINT [ "./start.sh" ]
