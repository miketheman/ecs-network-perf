# ecs-network-perf

TODO: Explain/link to what this is.

## Local Development

Install runtime and dev dependencies with:

```console
poetry install
```

Run local app via:

```console
poetry run uvicorn example:app --reload
```

For a production-level workload, run:

```console
poetry run gunicorn -k uvicorn.workers.UvicornWorker example:app
```

Open http://localhost:8000 to see the response.

### Docker Development

Using `docker-compose`, we can create the same images that we would expect to
run in the target ECS environment.

Build and run with: `docker-compose up tcp_nginx`

Test with: `curl -k https://localhost:8443`

**Note**: In local development, and for the purposes if this demo, we're using
a self-signed certificate **inside** the `nginx` container - to support
_encryption in transit_ - but not verification of the destination.
If we wanted to make something that would reflect a real-world scenario that
uses verifiable certificates, we'd [look to this post](https://aws.amazon.com/blogs/compute/maintaining-transport-layer-security-all-the-way-to-your-container-part-2-using-aws-certificate-manager-private-certificate-authority/)
for some ideas.

A self-signed certificate is good enough for a demo of end-to-end SSL.

Make sure to run `docker-compose down` to stop & remove any running containers.

## Deploy

Read about the Copilot concepts here: https://aws.github.io/copilot-cli/docs/concepts/overview/

For the purpose of this test, we'll create one Environment named `test`, and
deploy multiple Services with the different configurations we want to compare.

We need to create the Environment before we can deploy Services to it.

```shell
copilot env init --name test --profile <named profile> --default-config
```

Again, in a production environment, you may want to audit and/or customize
these choices.

### tcp

Deploy the `tcp` Service to the `test` Environment:

```shell
copilot svc deploy --name tcp --env test
```

After about 5 minutes or so, you'll have a URL that looks something like:

    http://ecs-n-Publi-<some weird set of characters>.us-east-1.elb.amazonaws.com.

And the service should be available!
