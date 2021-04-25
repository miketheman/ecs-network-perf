import datetime
import random

from starlette.applications import Starlette
from starlette.responses import JSONResponse
from starlette.routing import Route


async def homepage(request):
    return JSONResponse(
        {
            "hello": "world",
            "utcnow": datetime.datetime.utcnow().isoformat(),
            "random": random.random(),
        }
    )


app = Starlette(
    debug=True,
    routes=[
        Route("/", homepage),
        # Catch-all - the Load Balancer may prepend paths in our test scenario
        Route("/{anything}", homepage),
    ],
)
