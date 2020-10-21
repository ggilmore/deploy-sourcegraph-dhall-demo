let Kubernetes/List = ../../util/kubernetes-list.dhall

let Kubernetes/TypesUnion = ../../deps/k8s/typesUnion.dhall

let Configuration/global = ../../configuration/global.dhall

let component = ./component.dhall

let Generate = ./generate.dhall

let ToList =
        ( λ(c : component) →
            Kubernetes/List::{
            , items =
              [ Kubernetes/TypesUnion.Deployment c.Deployment.prometheus
              , Kubernetes/TypesUnion.ClusterRole c.ClusterRole.prometheus
              , Kubernetes/TypesUnion.ConfigMap c.ConfigMap.prometheus
              , Kubernetes/TypesUnion.PersistentVolumeClaim
                  c.PersistentVolumeClaim.prometheus
              , Kubernetes/TypesUnion.ClusterRoleBinding
                  c.ClusterRoleBinding.prometheus
              , Kubernetes/TypesUnion.ServiceAccount c.ServiceAccount.prometheus
              , Kubernetes/TypesUnion.Service c.Service.prometheus
              ]
            }
        )
      : ∀(c : component) → Kubernetes/List.Type

let Render =
        (λ(c : Configuration/global.Type) → ToList (Generate c))
      : ∀(c : Configuration/global.Type) → Kubernetes/List.Type

in  Render
