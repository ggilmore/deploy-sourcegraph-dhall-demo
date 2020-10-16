let Kubernetes/DaemonSet =
      ../../deps/k8s/schemas/io.k8s.api.apps.v1.DaemonSet.dhall

let Kubernetes/PodSecurityPolicy =
      ../../deps/k8s/schemas/io.k8s.api.policy.v1beta1.PodSecurityPolicy.dhall

let Kubernetes/ClusterRole =
      ../../deps/k8s/schemas/io.k8s.api.rbac.v1.ClusterRole.dhall

let Kubernetes/ClusterRoleBinding =
      ../../deps/k8s/schemas/io.k8s.api.rbac.v1.ClusterRoleBinding.dhall

let Kubernetes/ServiceAccount =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceAccount.dhall

let component =
      { DaemonSet : { cadvisor : Kubernetes/DaemonSet.Type }
      , ClusterRole : { cadvisor : Kubernetes/ClusterRole.Type }
      , PodSecurityPolicy : { cadvisor : Kubernetes/PodSecurityPolicy.Type }
      , ClusterRoleBinding : { cadvisor : Kubernetes/ClusterRoleBinding.Type }
      , ServiceAccount : { cadvisor : Kubernetes/ServiceAccount.Type }
      }

in  component
