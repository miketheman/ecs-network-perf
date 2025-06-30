# ecs-network-perf

An experiment in testing the performance difference between container-to-container
communications when both containers are co-located with AWS Fargate.

## Local Development

Install runtime and dev dependencies with:

```console
poetry install --no-root
```

Run local app via:

```console
poetry run uvicorn example:app --reload
```

For a production-level workload, run:

```console
poetry run gunicorn -k uvicorn.workers.UvicornWorker example:app
```

Open <http://localhost:8000> to see the response.

### Docker Development

Using `docker-compose`, we can create the same images that we would expect to
run in the target ECS environment.

Build and run with: `docker-compose up`

Test with:

```shell
# tcp service
curl http://localhost:8080
# combined service
curl http://localhost:8081
# sharedvol service
curl http://localhost:8082
```

All should respond similarly - with the request flowing through the nginx
container to the Python application container, and return a JSON response.

Make sure to run `docker-compose down` to stop & remove any running containers.

## Deploy

Read about the Copilot concepts here: <https://aws.github.io/copilot-cli/docs/concepts/overview/>

For the purpose of this test, we'll create one Environment named `test`, and
deploy multiple Services with the different configurations we want to compare.

We need to create the Environment before we can deploy Services to it.

```shell
copilot env init --name test --profile <named profile> --default-config
```

Again, in a production environment, you may want to audit and/or customize
these choices.

### nginx sidecar

As the Copilot CLI doesn't yet know how to build&push a "sidecar" (proxy)
container, we have to build and push it locally, and then reference it in the
manifest.
See:

-   <https://aws.github.io/copilot-cli/docs/developing/sidecars/>
-   <https://aws.github.io/copilot-cli/docs/manifest/lb-web-service/#http-target-container>

Steps are shown below on where and when to push the sidecar for each service.

### tcp

Initialize the `tcp` service:

```shell
copilot svc init --name tcp --svc-type "Load Balanced Web Service" --dockerfile tcp.Dockerfile
```

This will initialize from the existing `copilot/tcp/manifest.yml` file.

Before we can deploy the service, we need to push the `nginx` proxy sidecar image:

```shell
docker compose build tcp_nginx
docker push "$COPILOT_AWS_ACCOUNT_ID.dkr.ecr.$COPILOT_AWS_REGION.amazonaws.com/ecs-network-perf/tcp:nginx"
```

Deploy the `tcp` Service to the `test` Environment:

```shell
copilot svc deploy --name tcp --env test
```

After about 5 minutes or so, you'll have a URL that looks something like:

```text
http://ecs-n-Publi-<some weird set of characters>.us-east-1.elb.amazonaws.com.
```

And the service should be available!

Clean up the service with:

```shell
copilot svc delete --name tcp --env test
```

### combined

```shell
copilot svc init --name combined --svc-type "Load Balanced Web Service" --dockerfile combined.Dockerfile
```

```shell
copilot svc deploy --name combined --env test
```

Keep in mind: The output URL should have the service name as part of the URL,
like `http://..../combined` - as all services share the same Application Load Balancer.

```shell
copilot svc delete --name combined --env test
```

### sharedvol

```shell
copilot svc init --name sharedvol --svc-type "Load Balanced Web Service" --dockerfile sharedvol.Dockerfile
```

```shell
docker compose build sharedvol_nginx
docker push "$COPILOT_AWS_ACCOUNT_ID.dkr.ecr.$COPILOT_AWS_REGION.amazonaws.com/ecs-network-perf/sharedvol:nginx"
```

```shell
copilot svc deploy --name sharedvol --env test
```

```shell
copilot svc delete --name sharedvol --env test
```

## Author

[Mike Fiedler](https://github.com/miketheman)
