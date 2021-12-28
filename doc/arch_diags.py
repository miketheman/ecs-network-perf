from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import ElasticContainerServiceContainer
from diagrams.aws.network import ALB
from diagrams.generic.storage import Storage
from diagrams.onprem.client import User
from diagrams.onprem.network import Nginx
from diagrams.programming.language import Python


class CustomDiagram(Diagram):
    """Custom Diagram to apply global options to all sub-objects"""

    graph_attrs = {"fontcolor": "black", "pad": "0.5"}
    node_attrs = {"fontcolor": "black"}
    edge_attrs = {"fontcolor": "black"}

    def __init__(self, *args, **kwargs):
        super().__init__(
            *args,
            **kwargs,
            show=False,
            graph_attr=self.graph_attrs,
            node_attr=self.node_attrs,
            edge_attr=self.edge_attrs
        )


with CustomDiagram(name="", filename="components"):
    client = User("client")
    nginx = Nginx("nginx")
    nx_to_py = Edge(label="proxies requests to")
    py_runtime = Python("app\n(gunicorn/starlette/my code)")

    client >> nginx >> nx_to_py >> py_runtime


ALB_EDGE = Edge(label="proxies traffic to")


with CustomDiagram(
    name="architecture: tcp",
    filename="tcp",
):
    with Cluster("ECS Cluster w/Fargate Compute"):
        nginx = ElasticContainerServiceContainer("nginx container")
        app = ElasticContainerServiceContainer("app container")

        nginx >> Edge(label="via localhost TCP port") >> app

    ALB(label="application load balancer") >> ALB_EDGE >> nginx


with CustomDiagram(
    name="architecture: sharevol",
    filename="sharedvol",
):
    with Cluster("ECS Cluster w/Fargate Compute"):
        nginx = ElasticContainerServiceContainer("nginx container")
        volume = Storage(label="ECS local storage")
        app = ElasticContainerServiceContainer("app container")

        nginx >> Edge(label="via Unix domain socket") >> volume >> app

    ALB(label="application load balancer") >> ALB_EDGE >> nginx


with CustomDiagram(
    name="architecture: combined",
    filename="combined",
):
    with Cluster("ECS Cluster w/Fargate Compute"):
        with Cluster(
            "Single ECS container\n"
            "Includes s6 supervisor to run both processes (init)"
        ):
            nginx = Nginx("nginx")
            app = Python("app")

            nginx >> Edge(label="via local UNIX socket") >> app

    ALB(label="application load balancer") >> ALB_EDGE >> nginx
