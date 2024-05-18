### TODO

- This Repo is based on https://github.com/TrueOsiris/docker-vrising.
  The configuration Process has been streamlined and more options can be defined via Environment Variables.

- A healthcheck (albeit crude) has been added.

- Several paths have changed compared to the original.
  If you want to use this image, you have to build it locally (it's roughly 4GB!).

- Mount 

  `$SERVER_DATA_PATH` Default: `/home/steam/vrising/server` 

  `$PERSISTENT_DATA_PATH` Default: `/home/steam/vrising/persistentdata` 

  for persistence.

### Kubernetes

You can use the provided example in `kubernetes/kustomize/overlays/exampleorg` to see the ways the base template could be adjusted to your requirements.
It's important to *at least* change the following:
- secret.yaml - Your RCON Secret, if you need one
- pvc.yaml - Adjust `storageClassname` and requsted storage according to your needs
- deployment.yaml - Set Image path to your registry. This image is not pushed to dockerhub by default


TODO: Finish README