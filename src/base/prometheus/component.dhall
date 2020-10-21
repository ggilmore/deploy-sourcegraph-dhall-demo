let Kubernetes/ServiceAccount =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceAccount.dhall

let Kubernetes/ConfigMap =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ConfigMap.dhall

let Kubernetes/Deployment =
      ../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/PersistentVolumeClaim =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaim.dhall

let Kubernetes/ClusterRole =
      ../../deps/k8s/schemas/io.k8s.api.rbac.v1.ClusterRole.dhall

let Kubernetes/ClusterRoleBinding =
      ../../deps/k8s/schemas/io.k8s.api.rbac.v1.ClusterRoleBinding.dhall

let Kubernetes/Service = ../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let component =
      { Deployment : { prometheus : Kubernetes/Deployment.Type }
      , ClusterRole : { prometheus : Kubernetes/ClusterRole.Type }
      , ConfigMap : { prometheus : Kubernetes/ConfigMap.Type }
      , PersistentVolumeClaim :
          { prometheus : Kubernetes/PersistentVolumeClaim.Type }
      , ClusterRoleBinding : { prometheus : Kubernetes/ClusterRoleBinding.Type }
      , Service : { prometheus : Kubernetes/Service.Type }
      , ServiceAccount : { prometheus : Kubernetes/ServiceAccount.Type }
      }

in  component
