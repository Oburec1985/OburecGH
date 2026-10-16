---
name: centralized-deployment-config
description: Centralize deployment configuration for applications that run in multiple environments. Use when creating or reviewing web apps, FastAPI/Next.js/React projects, local/cloud deploys, Amvera deploys, API URLs, frontend/backend URLs, environment variables, CORS origins, static asset URLs, email links, or any code that might otherwise hard-code service endpoints.
---

# Centralized Deployment Config

## Principle

All external URLs and environment-specific endpoints must come from one configuration layer, not scattered literals.

Use sensible local defaults and let deployment environment variables override them. Typical variables:
- `NEXT_PUBLIC_API_URL` for frontend-to-backend API calls
- `FRONTEND_URL` for backend-generated frontend links
- `BACKEND_URL` for backend self-references or public API base URL

## Frontend Pattern

Create a single frontend config module, commonly `frontend/src/config.ts`:

```ts
const LOCAL_API_URL = 'http://127.0.0.1:8000';

export const API_URL = process.env.NEXT_PUBLIC_API_URL || LOCAL_API_URL;
```

Import `API_URL` anywhere requests or links are built:

```ts
import { API_URL } from '@/config';

fetch(`${API_URL}/api/v1/items`);
```

## Backend Pattern

Read public origins and URLs from environment variables with local defaults:

```python
import os

FRONTEND_URL = os.getenv('FRONTEND_URL', 'http://localhost:3000')
BACKEND_URL = os.getenv('BACKEND_URL', 'http://127.0.0.1:8000')
```

Use these constants for CORS, email verification links, redirects, static file links, and generated absolute URLs.

## Review Checklist

When touching deployable code:
- Search for hard-coded `localhost`, `127.0.0.1`, production domains, and protocol-prefixed URLs.
- Replace scattered URL literals with imports from the central config module or backend settings object.
- Keep one documented local default per value.
- Document required environment variables in deployment docs or README.
- Check CORS and generated email/redirect links, not only `fetch` calls.