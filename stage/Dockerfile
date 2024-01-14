FROM registry.fedoraproject.org/fedora-minimal:39

ARG TARGETPLATFORM

WORKDIR /cpp-app

COPY bin/$TARGETPLATFORM/cpp-app .

COPY config/cpp-app.yaml ./config/

CMD ./cpp-app -f ./config/cpp-app.yaml 