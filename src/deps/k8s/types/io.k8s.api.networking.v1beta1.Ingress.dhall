{ apiVersion : Text
, kind : Text
, metadata :
    ./io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall sha256:f9bd9acb6fbfb26b6484870f1d07fa85535bd6e55e790181e89dcc64d63e7bfe
, spec :
    Optional
      ./io.k8s.api.networking.v1beta1.IngressSpec.dhall sha256:3e4a440247bdd7bc9f9310eafd4830014fa8d3dc1eaeaf0ffc110ff51d5fe107
, status :
    Optional
      ./io.k8s.api.networking.v1beta1.IngressStatus.dhall sha256:90c576fb3ddb9e973bcf91246d9f2a196ae0237cba9622cd767a628fcfcd93cc
}
