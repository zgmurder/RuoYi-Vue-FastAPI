# Repository Guidelines

## Project Structure & Module Organization
This repository is split by runtime:
- `ruoyi-fastapi-backend/`: FastAPI services, module-based backend code (`module_admin`, `module_ai`, `module_generator`), shared utilities in `common/`, SQL bootstrap files in `sql/`.
- `ruoyi-fastapi-frontend/`: Vue 3 + Vite admin web UI.
- `ruoyi-fastapi-app/`: Uni-app (Vue 2) mobile client.
- Root files: `docker-compose.*.yml` for local infra variants and top-level project docs.

Keep feature changes scoped to one module/app where possible, and mirror existing folder patterns (for example, backend `controller/dao/service/entity`).

## Build, Test, and Development Commands
- Frontend web:
  - `cd ruoyi-fastapi-frontend && npm install`
  - `npm run dev` (local dev server)
  - `npm run build:prod` (production bundle)
- Mobile app:
  - `cd ruoyi-fastapi-app && yarn`
  - `yarn dev:h5` (H5 dev)
  - `yarn dev:mp-weixin` (WeChat mini-program dev)
  - `yarn test:h5` (Jest)
- Backend:
  - `cd ruoyi-fastapi-backend && pip3 install -r requirements.txt`
  - `python3 app.py --env=dev`
  - `ruff check . && ruff format .`

## Coding Style & Naming Conventions
- Python follows Ruff config in `ruoyi-fastapi-backend/ruff.toml` (target `py310`, single quotes, max line length 120).
- Frontend/editor defaults come from `ruoyi-fastapi-frontend/.editorconfig`: UTF-8, LF, 2-space indentation.
- Use existing naming patterns:
  - Python modules/files: `snake_case`
  - Vue components/types: follow local conventions in each app (`PascalCase` components, `camelCase` variables).

## Testing Guidelines
- Primary scripted tests exist in `ruoyi-fastapi-app` via Jest (`test:*` scripts in `package.json`).
- For backend/frontend changes without dedicated tests, run at least build/startup smoke checks and add targeted tests with new logic.
- Test file naming should remain framework-native (for Jest, `*.test.*` where introduced).

## Commit & Pull Request Guidelines
Git history is mostly Conventional Commits (`feat:`, `docs:`, `chore:`), sometimes with scope and issue refs (for example `feat: ... (#32)`). Follow that format.

PRs should include:
- Clear summary of changed modules/apps.
- Linked issue/task.
- Validation notes (commands run, sample API/UI checks).
- UI screenshots/GIFs for visible frontend or app changes.

## Security & Configuration Tips
- Never commit secrets; keep environment-specific values in backend `.env.*` files.
- Confirm DB scripts match the selected engine (`ruoyi-fastapi.sql` vs `ruoyi-fastapi-pg.sql`).
