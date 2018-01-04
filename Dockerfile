
# react-nginx-front-end-builder
FROM openshift/base-centos7

# Put the maintainer name in the image metadata
MAINTAINER Kevin P Huang <oyman@hotmail.com>

# Rename the builder environment variable to inform users about application you provide them
ENV BUILDER_VERSION 1.0

# Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for building React App" \
      io.k8s.display-name="builder x.y.z" \
      io.openshift.expose-services="80:http" \
      io.openshift.tags="builder,x.y.z,etc."

# Install required packages here:
# install epel
RUN yum install -y epel-release

# install nginx and sudo(to run nginx by 1001 user)
RUN INSTALL_PKGS="nginx sudo" && \
	yum install -y $INSTALL_PKGS && \
	rpm -V $INSTALL_PKGS && \
	yum clean all -y

# install Node.js 
RUN wget https://npm.taobao.org/mirrors/node/latest-v6.x/node-v6.10.2-linux-x64.tar.gz && \
	tar -zxf node-v6.10.2-linux-x64.tar.gz -C /usr/local && \
	rm -f node-v6.10.2-linux-x64.tar.gz 

# set PATH
ENV PATH $PATH:/usr/local/node-v6.10.2-linux-x64/bin

# install cnpm
RUN npm install -g cnpm --registry=https://registry.npm.taobao.org

LABEL io.openshift.s2i.scripts-url=image:///usr/libexec/s2i
# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./s2i/bin/ /usr/libexec/s2i

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 /opt/app-root \
	/var/log/nginx
#	/var/lib/nginx

#RUN chmod -R 775 /usr/local/node-v6.10.2-linux-x64 \
#	/usr/share/nginx/html 
#	/run \
#	/etc/nginx

# for default(uid is 1001) user to execute sudo without password
RUN echo "default ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set the default port for applications built using this image
EXPOSE 80

# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
