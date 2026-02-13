# Vehicle Registration Management System (VRMS)

## Project 1_Modular Monolith (DDD)

This project implements **Domain-Driven Design (DDD)** in a **single Spring Boot application**.

The system is deployed as one monolith, but internally it is **strictly modular**, with clear boundaries between business capabilities.

### Bounded Contexts
- cars
- owners
- agents
- registration

### Orchestration
- Registration acts as the application-layer orchestrator
- Cross-context interaction happens only through ports (interfaces)

### Architectural Note
- Monolith in deployment
- Modular and domain-centric in design
- Classic DDD

# Architecture & Project Structure

VRMS (Vehicle Registration Management System) is a **Modular Monolith** using **DDD + Hexagonal Architecture (Ports & Adapters)**.

- **Bounded Context Modules:** `cars`, `owners`, `agents`, `registration`
- **Layers inside each module:** `api`, `application`, `domain`, `infrastructure`
- **Dependency direction (inward):**
    - `api → application → domain`
    - `infrastructure → application/domain` (implements ports)
- **Goal:** keep business logic stable and independent from frameworks, persistence, and transport.

---

## Root & Bootstrapping

### `VrmsApplication.java`
**Role:** Spring Boot entry point (composition root).  
**Purpose:** boots the Spring context and wires modules/adapters through dependency injection.

### Build & project files
- `build.gradle`, `settings.gradle`, `gradlew*`, `gradle/wrapper/*`  
  **Purpose:** build configuration, dependency management, consistent Gradle version.
- `README.md`, `HELP.md`  
  **Purpose:** project documentation.
- `.gitignore`, `.gitattributes`  
  **Purpose:** source control configuration.

---

## Shared (Cross-Cutting) Components

`shared/` contains cross-cutting concerns used by multiple modules. It is not a business module.

### `shared/config/`
- `OpenApiConfig.java`  
  **Purpose:** base OpenAPI/Swagger configuration.
- `OpenApiGroupsConfig.java`  
  **Purpose:** group endpoints per module in Swagger UI.
- `WebConfig.java`  
  **Purpose:** global web configuration (CORS, converters, etc. if needed).

### `shared/web/`
- `ApiErrorResponse.java`  
  **Purpose:** standard error response DTO for consistent API errors.
- `GlobalExceptionHandler.java`  
  **Purpose:** global exception → HTTP response translation via `@ControllerAdvice`.

---

## Modules (Bounded Contexts)

All modules follow the same structure:  
modules/  
domain/  
application/  
infrastructure/  
api/  


---

# Layer Responsibilities (What belongs where)

## 1) Domain Layer (`domain/`)
**Purpose:** pure business model and rules.  
**Contains:**
- Aggregates / Aggregate Roots
- Entities (inside aggregates)
- Value Objects (immutable)
- Enums (domain states)
- Domain exceptions (business rule violations)

**Must NOT contain:** Spring annotations, controllers, DTOs, JPA entities, repositories.

---

## 2) Application Layer (`application/`)
**Purpose:** runs use-cases (orchestration), coordinates domain + ports.  
**Contains:**
- Use-case services (`*Service`)
- Ports (interfaces) under `port/out` (repositories, external needs)
- Application exceptions (use-case failures)
- Transaction boundaries (often here)

**Must NOT contain:** JPA entities/SQL, HTTP/transport logic, core business rules (those belong in domain).

---

## 3) Infrastructure Layer (`infrastructure/`)
**Purpose:** technical implementations and adapters.  
**Contains:**
- JPA entities (`*JpaEntity`)
- Spring Data repositories (`SpringData*Repository`)
- Port implementations (adapters) like `Jpa*RepositoryAdapter`
- Technical configuration and integrations
- ACL adapters (when needed to isolate contexts)

**Must NOT contain:** domain rules or orchestration logic.

---

## 4) API Layer (`api/`)
**Purpose:** HTTP entry point + request/response boundary.  
**Contains:**
- Controllers (`*Controller`)
- DTOs (`*Request`, `*Response`)
- Mappers (`*ApiMapper`) to convert DTO ↔ domain/value objects
- Module exception handlers (optional) for module-specific mappings

**Must NOT contain:** business rules or persistence logic.

---

# Module Breakdown

## Cars Module (`modules/cars`) — Vehicle Management

### Domain (`modules/cars/domain/`)
- `model/Vehicle.java`  
  **Aggregate Root.** Holds vehicle behavior and enforces invariants.
- `model/VehicleId.java`, `Vin.java`, `VehicleSpecs.java`  
  **Value Objects.** Validate and model concepts (ID, VIN, specs).
- `model/VehicleStatus.java`  
  **Enum.** Domain state (e.g., `INACTIVE`, `ACTIVE`).
- `exception/*`  
  **Domain exceptions.** Rule violations (invalid VIN, invalid year, illegal state transitions).

### Application (`modules/cars/application/`)
- `port/out/VehicleRepositoryPort.java`  
  **Output port.** Interface for persistence operations on vehicles.
- `service/VehicleCrudService.java`  
  **Use-cases.** Create/read/update/delete workflows for vehicles.
- `service/VehicleEligibilityService.java`  
  **Policy/use-case support.** Eligibility checks related to vehicles.
- `exception/*`  
  **Application exceptions.** Use-case failures (not found, duplicate VIN).

### Infrastructure (`modules/cars/infrastructure/`)
- `persistence/VehicleJpaEntity.java`  
  **JPA entity.** DB representation of vehicle.
- `persistence/SpringDataVehicleRepository.java`  
  **Spring Data repository.** Data access mechanism.
- `persistence/JpaVehicleRepositoryAdapter.java`  
  **Adapter.** Implements `VehicleRepositoryPort` and maps domain ↔ JPA.

### API (`modules/cars/api/`)
- `VehicleController.java`  
  **REST controller.** Exposes vehicle endpoints.
- `VehicleExceptionHandler.java`  
  **Module handler.** Optional module-specific exception mapping.
- `dto/*` (`CreateVehicleRequest`, `UpdateVehicleRequest`, `VehicleResponse`)  
  **DTOs.** HTTP contract types.
- `mapper/VehicleApiMapper.java`  
  **Mapper.** DTO ↔ domain/value object translation.

---

## Owners Module (`modules/owners`) — Owner Management
Follows the same pattern as Cars:

- **Domain:** `Owner` aggregate, `OwnerId`, `FullName`, `Address`, `OwnerStatus`, domain exceptions
- **Application:** `OwnerRepositoryPort`, `OwnerCrudService`, `OwnerEligibilityService`, app exceptions
- **Infrastructure:** `OwnerJpaEntity`, `SpringDataOwnerRepository`, `JpaOwnerRepositoryAdapter`
- **API:** `OwnerController`, DTOs, `OwnerApiMapper`, optional handler

---

## Agents Module (`modules/agents`) — Agent Management
Follows the same pattern as Cars:

- **Domain:** `Agent` aggregate, `AgentId`, enums (`Role`, `AgentStatus`), domain exceptions
- **Application:** `AgentRepositoryPort`, `AgentCrudService`, `AgentEligibilityService`, app exceptions
- **Infrastructure:** `AgentJpaEntity`, `SpringDataAgentRepository`, `JpaAgentRepositoryAdapter`
- **API:** `AgentController`, DTOs, `AgentApiMapper`, optional handler

---

## Registration Module (`modules/registration`) — Core Orchestration

Registration is the workflow module and coordinates cross-context validation through **ports + ACL adapters**.

### Domain (`modules/registration/domain/`)
- `model/Registration.java`  
  **Aggregate Root.** Registration lifecycle + invariants (expiry, status).
- `model/RegistrationId.java`, `PlateNumber.java`, `ExpiryDate.java`  
  **Value Objects.** Strong types and validation.
- `model/VehicleRef.java`, `OwnerRef.java`, `AgentRef.java`  
  **Reference Value Objects.** Hold only IDs to avoid coupling to other contexts.
- `model/RegistrationStatus.java`  
  **Enum.** Domain state.
- `exception/*`  
  **Domain exceptions.** Rule violations (invalid plate, expiry must be future, etc.).

### Application (`modules/registration/application/`)
- `port/out/RegistrationRepositoryPort.java`  
  **Persistence port.**
- `port/out/VehicleEligibilityPort.java`, `OwnerEligibilityPort.java`, `AgentEligibilityPort.java`  
  **Cross-context ports.** Registration depends only on interfaces for eligibility checks.
- `service/RegistrationCrudService.java`  
  **Use-cases.** CRUD around registration.
- `service/RegistrationOrchestrator.java`  
  **Orchestration.** Multi-step workflows (validate eligibility + enforce uniqueness + create/renew/cancel).
- `exception/*`  
  **Application exceptions.** Use-case failures (not found, plate taken, cross-context validation failure).

### Infrastructure (`modules/registration/infrastructure/`)
- `persistence/*`  
  `RegistrationJpaEntity`, `SpringDataRegistrationRepository`, `JpaRegistrationRepositoryAdapter`  
  **Purpose:** persistence implementation.
- `acl/*`  
  `VehicleEligibilityAdapter`, `OwnerEligibilityAdapter`, `AgentEligibilityAdapter`  
  **Purpose:** Anti-Corruption Layer adapters implementing eligibility ports, preventing model leakage between contexts and allowing future replacement (e.g., in-process → HTTP).

### API (`modules/registration/api/`)
- `RegistrationController.java`  
  **REST controller.** Exposes register/renew/cancel endpoints.
- `RegistrationExceptionHandler.java`  
  **Module handler.** Optional module-specific exception mapping.
- `dto/*` (`RegisterVehicleRequest`, `RenewRegistrationRequest`, `CancelRegistrationRequest`, `RegistrationResponse`)  
  **DTOs.** HTTP contract types.
- `mapper/RegistrationApiMapper.java`  
  **Mapper.** DTO ↔ domain/value object translation.

---

# Configuration & Database

## `src/main/resources/application.yml`
**Purpose:** runtime configuration:
- H2 (dev) / PostgreSQL (prod)
- JPA/Hibernate settings
- Flyway settings
- H2 console + server port
- Swagger/OpenAPI settings
- logging

## Flyway migrations (`src/main/resources/db/migration/`)
- `V1__init.sql`  
  **Purpose:** version-controlled schema creation for:
    - `vehicles`
    - `owners`
    - `agents`
    - `registrations`

---

# Request Flow (End-to-End)

Example: `POST /api/registrations`

1. **API**: `RegistrationController` receives request DTO
2. **API**: `RegistrationApiMapper` converts DTO → domain/value objects
3. **Application**: `RegistrationOrchestrator` runs the workflow
4. **Domain**: `Registration` aggregate enforces invariants
5. **Application** calls **ports**:
    - repository port (save/load)
    - eligibility ports (cross-context checks)
6. **Infrastructure** implements those ports:
    - JPA repository adapter
    - ACL adapters to other modules
7. **API** returns `RegistrationResponse` DTO

---

# Naming Conventions (as used in this project)

- **JPA entities:** `{Name}JpaEntity`
- **Spring Data repositories:** `SpringData{Name}Repository`
- **Port interfaces:** `*RepositoryPort`, `*EligibilityPort`
- **Adapters:** `Jpa{Name}RepositoryAdapter`, `{Name}EligibilityAdapter`
- **Controllers:** `{Name}Controller`
- **DTOs:** `{Action}{Name}Request`, `{Name}Response`
- **Mappers:** `{Name}ApiMapper`
- **Exceptions:** `{Description}Exception`

---

# Key Design Outcomes

- Business logic isolated in **Domain**
- Use-cases and orchestration isolated in **Application**
- Technical details isolated in **Infrastructure**
- HTTP contract isolated in **API**
- Cross-context communication isolated via **Ports + ACL adapters**