let Kubernetes/Service = ../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/StatefulSet =
      ../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSet.dhall

let component =
      { StatefulSet : { gitserver : Kubernetes/StatefulSet.Type }
      , Service : { gitserver : Kubernetes/Service.Type }
      }

in  component
