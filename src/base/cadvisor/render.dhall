let Kubernetes/List = ../../util/kubernetes-list.dhall

let Kubernetes/TypesUnion = ../../deps/k8s/typesUnion.dhall

let Configuration/global = ../../configuration/global.dhall

let Component = ./component.dhall

let Generate = ./generate.dhall

let ToList =
        ( λ(c : Component) →
            Kubernetes/List::{
            , items =
              [ Kubernetes/TypesUnion.DaemonSet c.DaemonSet.cadvisor
              , Kubernetes/TypesUnion.ClusterRole c.ClusterRole.cadvisor
              , Kubernetes/TypesUnion.ClusterRoleBinding
                  c.ClusterRoleBinding.cadvisor
              , Kubernetes/TypesUnion.PodSecurityPolicy
                  c.PodSecurityPolicy.cadvisor
              , Kubernetes/TypesUnion.ServiceAccount c.ServiceAccount.cadvisor
              ]
            }
        )
      : ∀(c : Component) → Kubernetes/List.Type

let Render =
        (λ(c : Configuration/global.Type) → ToList (Generate c))
      : ∀(c : Configuration/global.Type) → Kubernetes/List.Type

in  Render
