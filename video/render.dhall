let Sourcegraph =  https://raw.githubusercontent.com/ggilmore/deploy-sourcegraph-dhall-demo/original/package.dhall

let Render = Sourcegraph.Render

let customizations = ./customizations.dhall

in  Render customizations
