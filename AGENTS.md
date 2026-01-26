# Repository Guidelines

## Project Structure & Module Organization
- `src/main/java/com/csu/r_book` holds the Spring Boot application code. Core areas are `modules/` (feature modules such as `captcha`, `coderunner`, `user`), `common/` (shared response/error helpers), and `config/` (interceptors, Jackson, bootstrapping).
- `src/main/resources/application.properties` contains default runtime configuration.
- `src/test/java` holds JUnit tests (currently `RBookApplicationTests`).
- `scripts/` stores R scripts executed by the code runner (for example `basic_stats.R`), and `docs/init.sql` seeds the database for Docker setups.

## Build, Test, and Development Commands
- `./mvnw clean package -DskipTests` builds the application JAR without running tests.
- `./mvnw test` runs the JUnit/Spring Boot tests.
- `docker compose up -d` starts the production-style stack defined in `docker-compose.yml`.
- `docker compose -f docker-compose.dev.yml up -d --build` starts the development stack (MySQL + app) with a dev Dockerfile and bind-mounted `scripts/`.
- `docker build -f Dockerfile.base -t r-book-base:latest .` rebuilds the base R image used for faster dev builds.

## Coding Style & Naming Conventions
- Java 17, Spring Boot; use 4-space indentation and standard Java brace placement (same line).
- Keep package names lower case (`com.csu.r_book`) and class names in PascalCase.
- Follow existing naming: controllers `*Controller`, services `*Service`, repositories `*Repository`, DTOs in `model/dto`.
- Prefer concise Javadoc/inline comments; existing comments are often in Chinese, so keep language consistent within a file.

## Testing Guidelines
- Tests live under `src/test/java` and use Spring Boot’s test starter.
- Name tests with the `*Tests` suffix (example: `RBookApplicationTests`).
- No explicit coverage target is defined; add tests for new endpoints or data access paths.

## Commit & Pull Request Guidelines
- Git history is minimal, so no strict commit format is established. Use short, imperative summaries (English or Chinese) and keep commits focused.
- PRs should describe the change, list key endpoints or modules touched, and include any config or database impacts (for example, changes to `docs/init.sql`).

## Configuration & Security Notes
- Default database credentials are stored in `src/main/resources/application.properties` and overridden in Docker via environment variables. Avoid committing real secrets.
- Code runner paths and timeouts are configurable via `app.coderunner.*` properties; keep `scripts/` synchronized when changing these settings.
