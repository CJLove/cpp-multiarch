FROM registry.fedoraproject.org/fedora-minimal:38

ARG TARGETPLATFORM

WORKDIR /cpp-app

COPY bin/$TARGETPLATFORM/cpp-app .

COPY config .

CMD ./cpp-app -f cpp-app.yaml 