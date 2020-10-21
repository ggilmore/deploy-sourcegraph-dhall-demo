let Kubernetes/Container =
      ../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/EnvVar = ../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/EnvVarSource =
      ../deps/k8s/schemas/io.k8s.api.core.v1.EnvVarSource.dhall

in  Kubernetes/Container::{
    , name = "jaeger-agent"
    , image = Some
        "index.docker.io/sourcegraph/jaeger-agent:insiders@sha256:f3faf496fe750ce75e6304f9ac10d8e1f42c9c9bdab3ab0c2fbf77a8d26084a4"
    , args = Some
      [ "--reporter.grpc.host-port=jaeger-collector:14250"
      , "--reporter.type=grpc"
      ]
    , env = Some
      [ Kubernetes/EnvVar::{
        , name = "POD_NAME"
        , valueFrom = Some Kubernetes/EnvVarSource::{
          , fieldRef = Some
            { apiVersion = Some "v1", fieldPath = "metadata.name" }
          }
        }
      ]
    , ports = Some
      [ Kubernetes/ContainerPort::{
        , containerPort = 5775
        , protocol = Some "UDP"
        }
      , Kubernetes/ContainerPort::{
        , containerPort = 5778
        , protocol = Some "TCP"
        }
      , Kubernetes/ContainerPort::{
        , containerPort = 6831
        , protocol = Some "UDP"
        }
      , Kubernetes/ContainerPort::{
        , containerPort = 6832
        , protocol = Some "UDP"
        }
      ]
    , resources = Some
      { limits = Some
        [ { mapKey = "cpu", mapValue = "1" }
        , { mapKey = "memory", mapValue = "500M" }
        ]
      , requests = Some
        [ { mapKey = "cpu", mapValue = "100m" }
        , { mapKey = "memory", mapValue = "100M" }
        ]
      }
    }
