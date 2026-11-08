import unittest

import httpx

from main import app


class HealthEndpointTests(unittest.IsolatedAsyncioTestCase):
    async def test_health_endpoints_return_healthy_response(self):
        transport = httpx.ASGITransport(app=app)
        async with httpx.AsyncClient(
            transport=transport,
            base_url="http://test",
        ) as client:
            for path in ("/health", "/healthz"):
                with self.subTest(path=path):
                    response = await client.get(path)

                    self.assertEqual(response.status_code, 200)
                    self.assertEqual(
                        response.json(),
                        {"status": "healthy", "database": "turso"},
                    )


if __name__ == "__main__":
    unittest.main()
