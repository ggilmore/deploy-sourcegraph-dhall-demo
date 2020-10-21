let Kubernetes/List = ../../util/kubernetes-list.dhall

let Kubernetes/TypesUnion = ../../deps/k8s/typesUnion.dhall

let Configuration/global = ../../configuration/global.dhall

let component = ./component.dhall

let Generate = ./generate.dhall

let ToList =
        ( λ(c : component) →
            Kubernetes/List::{
            , items =
              [ Kubernetes/TypesUnion.Deployment
                  c.Deployment.precise-code-intel-bundle-manager
              , Kubernetes/TypesUnion.Service
                  c.Service.precise-code-intel-bundle-manager
              , Kubernetes/TypesUnion.PersistentVolumeClaim
                  c.PersistentVolumeClaim.bundle-manager
              , Kubernetes/TypesUnion.Deployment
                  c.Deployment.precise-code-intel-worker
              , Kubernetes/TypesUnion.Service
                  c.Service.precise-code-intel-worker
              ]
            }
        )
      : ∀(c : component) → Kubernetes/List.Type

let Render =
        (λ(c : Configuration/global.Type) → ToList (Generate c))
      : ∀(c : Configuration/global.Type) → Kubernetes/List.Type

in  Render
