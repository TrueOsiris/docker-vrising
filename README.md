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



TODO: Adding K8s deployment configs.
TODO: Finish README