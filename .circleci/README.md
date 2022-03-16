# Continuous Integration Pipeline

The continuous integration pipeline is responsible to verify the projects code
base in a standardized environment. It runs for every open pull request as
a required check to protect the `main` branch from unmature code. Typical jobs
within this pipeline are linting, formatting, tests etc.

## Docker Image

To save the pipeline a lot of time in getting started, there is a custom Docker
image that includes all the packages that are necessary to run all jobs. Note
that this must not include the installation of dependencies which are defines by
the code of the repository itself. An exception to this are the `pre-commit`
hooks which expect their binaries to be installed by the operation system
(`language: system`).

The configuration of the pipeline must point to a specific tagged version of the
image. This makes sure that all concurrently open pull requests do still
continue working with their referenced image versions. Only pull requests from
branches which have been forked after the commit which changes the pipeline
configuration will use the new version. Furthermore it must be guaranteed that
any commit in the repositories history could be checked-out and the pipeline
will produce the same result. Therefore the used environment must be
deterministic. Each time there are changes to the Docker image, the tag version
must be increased.

The image can be simply build and updated like this:

```sh
docker build --file="./.circleci/Dockerfile" --tag weilbith/ci-nvim-code-action-menu:<new_version> .
docker push weilbith/ci-nvim-code-action-menu:<new_version>
```

Then adapt the version in `./.circleci/config.yaml` at the parameter section.
