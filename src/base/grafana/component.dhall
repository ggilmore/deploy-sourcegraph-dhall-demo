let Kubernetes/Service = ../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/StatefulSet =
      ../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSet.dhall

let Kubernetes/ConfigMap =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ConfigMap.dhall

let Kubernetes/ServiceAccount =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceAccount.dhall

let component =
      { StatefulSet : { grafana : Kubernetes/StatefulSet.Type }
      , Service : { grafana : Kubernetes/Service.Type }
      , ConfigMap : { grafana : Kubernetes/ConfigMap.Type }
      , ServiceAccount : { grafana : Kubernetes/ServiceAccount.Type }
      }

in  component
