let Kubernetes/List = ../../util/kubernetes-list.dhall

let Kubernetes/TypesUnion = ../../deps/k8s/typesUnion.dhall

let Configuration/global = ../../configuration/global.dhall

let Component = ./component.dhall

let Generate = ./generate.dhall

let ToList =
        ( λ(c : Component) →
            Kubernetes/List::{
            , items =
              [ Kubernetes/TypesUnion.Deployment
                  c.Deployment.sourcegraph-frontend
              , Kubernetes/TypesUnion.Ingress c.Ingress.sourcegraph-frontend
              , Kubernetes/TypesUnion.Role c.Role.sourcegraph-frontend
              , Kubernetes/TypesUnion.RoleBinding
                  c.RoleBinding.sourcegraph-frontend
              , Kubernetes/TypesUnion.Service c.Service.sourcegraph-frontend
              , Kubernetes/TypesUnion.ServiceAccount
                  c.ServiceAccount.sourcegraph-frontend
              , Kubernetes/TypesUnion.Service
                  c.Service.sourcegraph-frontend-internal
              ]
            }
        )
      : ∀(c : Component) → Kubernetes/List.Type

let Render =
        (λ(c : Configuration/global.Type) → ToList (Generate c))
      : ∀(c : Configuration/global.Type) → Kubernetes/List.Type

in  Render
