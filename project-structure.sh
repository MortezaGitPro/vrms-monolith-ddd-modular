#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# VRMS Scaffolder (bash) - macOS/Linux - RUN FROM PROJECT ROOT
# - Put this file next to build.gradle
# - Run:
#     chmod +x project-structure.sh
#     ./project-structure.sh
# - Creates folders + Java files with correct packages
# - Does NOT overwrite existing files (safe)
# - DOES NOT create/delete/modify the main Spring Boot entry point
#   (note: VrmsApplication.java stays where Spring Initializr/IDE created it)
# ==========================================================

BASE="src/main/java/com/champsoft/vrms"

ensure_project_root() {
  if [[ ! -f "build.gradle" ]]; then
    echo "ERROR: build.gradle not found. Run this script from the project root (same folder as build.gradle)." >&2
    exit 1
  fi
}

mk_dir() {
  mkdir -p "$1"
}

write_file() {
  local path="$1"
  local content="$2"
  if [[ ! -f "$path" ]]; then
    mk_dir "$(dirname "$path")"
    # Preserve newlines exactly:
    printf '%s' "$content" > "$path"
  fi
}

remove_application_properties_if_exists() {
  local path="src/main/resources/application.properties"
  if [[ -f "$path" ]]; then
    local content
    content="$(cat "$path")"

    # Looks default if empty OR contains common boilerplate keys
    if [[ -z "${content//[[:space:]]/}" ]] \
      || grep -Eq 'spring\.application\.name|server\.port|spring\.profiles\.active' "$path"; then
      rm -f "$path"
      echo "🧹 Removed application.properties (using application.yml instead)"
    else
      echo "⚠️ application.properties exists but was NOT removed (custom content detected)"
    fi
  fi
}

ensure_project_root

# ---------------- folders ----------------
mk_dir "src/main/resources/db/migration"

# IMPORTANT: Do NOT create $BASE/app and do NOT generate VrmsApplication.java
# The desired structure has VrmsApplication.java directly under:
# src/main/java/com/champsoft/vrms/VrmsApplication.java

mk_dir "$BASE/shared/config"
mk_dir "$BASE/shared/web"

modules=("cars" "owners" "agents" "registration")
for m in "${modules[@]}"; do
  mk_dir "$BASE/modules/$m/domain/model"
  mk_dir "$BASE/modules/$m/domain/exception"
  mk_dir "$BASE/modules/$m/application/port/out"
  mk_dir "$BASE/modules/$m/application/service"
  mk_dir "$BASE/modules/$m/application/exception"
  mk_dir "$BASE/modules/$m/infrastructure/persistence"
  mk_dir "$BASE/modules/$m/api/mapper"
  mk_dir "$BASE/modules/$m/api/dto"
done
mk_dir "$BASE/modules/registration/infrastructure/acl"

# Test folder (matches the structure you pasted)
mk_dir "src/test/java/com/champsoft/vrms"

# ---------------- resources ----------------
remove_application_properties_if_exists

write_file "src/main/resources/application.yml" $'spring:\n  application:\n    name: vrms\n\n# TODO: add datasource, flyway, etc.\n'
write_file "src/main/resources/db/migration/V1__init.sql" $'-- TODO: Flyway init schema (tables for vehicle/owner/agent/registration)\n'

# ==========================================================
# shared (NO app/ main entry point here)
# ==========================================================
write_file "$BASE/shared/config/WebConfig.java" $'package com.champsoft.vrms.shared.config;\n\npublic class WebConfig {\n    // TODO: CORS, interceptors, formatters (optional)\n}\n'
write_file "$BASE/shared/config/OpenApiConfig.java" $'package com.champsoft.vrms.shared.config;\n\npublic class OpenApiConfig {\n    // TODO: Swagger/OpenAPI config (optional)\n}\n'
write_file "$BASE/shared/config/OpenApiGroupsConfig.java" $'package com.champsoft.vrms.shared.config;\n\npublic class OpenApiGroupsConfig {\n    // TODO: OpenAPI grouping (optional)\n}\n'
write_file "$BASE/shared/web/ApiErrorResponse.java" $'package com.champsoft.vrms.shared.web;\n\npublic record ApiErrorResponse(String message, String code) { }\n'
write_file "$BASE/shared/web/GlobalExceptionHandler.java" $'package com.champsoft.vrms.shared.web;\n\npublic class GlobalExceptionHandler {\n    // TODO: generic fallback only\n}\n'

# ==========================================================
# cars
# ==========================================================
write_file "$BASE/modules/cars/domain/model/Vehicle.java" $'package com.champsoft.vrms.modules.cars.domain.model;\n\npublic class Vehicle {\n}\n'
write_file "$BASE/modules/cars/domain/model/VehicleId.java" $'package com.champsoft.vrms.modules.cars.domain.model;\n\npublic record VehicleId(String value) { }\n'
write_file "$BASE/modules/cars/domain/model/Vin.java" $'package com.champsoft.vrms.modules.cars.domain.model;\n\npublic record Vin(String value) { }\n'
write_file "$BASE/modules/cars/domain/model/VehicleSpecs.java" $'package com.champsoft.vrms.modules.cars.domain.model;\n\npublic class VehicleSpecs {\n}\n'
write_file "$BASE/modules/cars/domain/model/VehicleStatus.java" $'package com.champsoft.vrms.modules.cars.domain.model;\n\npublic enum VehicleStatus {\n    DRAFT, ACTIVE, SUSPENDED\n}\n'

write_file "$BASE/modules/cars/domain/exception/InvalidVinException.java" $'package com.champsoft.vrms.modules.cars.domain.exception;\n\npublic class InvalidVinException extends RuntimeException {\n    public InvalidVinException(String message) { super(message); }\n}\n'
write_file "$BASE/modules/cars/domain/exception/InvalidVehicleYearException.java" $'package com.champsoft.vrms.modules.cars.domain.exception;\n\npublic class InvalidVehicleYearException extends RuntimeException {\n    public InvalidVehicleYearException(String message) { super(message); }\n}\n'
write_file "$BASE/modules/cars/domain/exception/VehicleAlreadyActiveException.java" $'package com.champsoft.vrms.modules.cars.domain.exception;\n\npublic class VehicleAlreadyActiveException extends RuntimeException {\n    public VehicleAlreadyActiveException(String message) { super(message); }\n}\n'
write_file "$BASE/modules/cars/domain/exception/VehicleNotValidatedException.java" $'package com.champsoft.vrms.modules.cars.domain.exception;\n\npublic class VehicleNotValidatedException extends RuntimeException {\n    public VehicleNotValidatedException(String message) { super(message); }\n}\n'

write_file "$BASE/modules/cars/application/port/out/VehicleRepositoryPort.java" $'package com.champsoft.vrms.modules.cars.application.port.out;\n\npublic interface VehicleRepositoryPort {\n}\n'
write_file "$BASE/modules/cars/application/service/VehicleCrudService.java" $'package com.champsoft.vrms.modules.cars.application.service;\n\npublic class VehicleCrudService {\n}\n'
write_file "$BASE/modules/cars/application/service/VehicleEligibilityService.java" $'package com.champsoft.vrms.modules.cars.application.service;\n\npublic class VehicleEligibilityService {\n}\n'
write_file "$BASE/modules/cars/application/exception/VehicleNotFoundException.java" $'package com.champsoft.vrms.modules.cars.application.exception;\n\npublic class VehicleNotFoundException extends RuntimeException {\n    public VehicleNotFoundException(String message) { super(message); }\n}\n'
write_file "$BASE/modules/cars/application/exception/DuplicateVinException.java" $'package com.champsoft.vrms.modules.cars.application.exception;\n\npublic class DuplicateVinException extends RuntimeException {\n    public DuplicateVinException(String message) { super(message); }\n}\n'

write_file "$BASE/modules/cars/infrastructure/persistence/VehicleJpaEntity.java" $'package com.champsoft.vrms.modules.cars.infrastructure.persistence;\n\npublic class VehicleJpaEntity {\n}\n'
write_file "$BASE/modules/cars/infrastructure/persistence/SpringDataVehicleRepository.java" $'package com.champsoft.vrms.modules.cars.infrastructure.persistence;\n\npublic interface SpringDataVehicleRepository {\n}\n'
write_file "$BASE/modules/cars/infrastructure/persistence/JpaVehicleRepositoryAdapter.java" $'package com.champsoft.vrms.modules.cars.infrastructure.persistence;\n\npublic class JpaVehicleRepositoryAdapter {\n}\n'

write_file "$BASE/modules/cars/api/VehicleController.java" $'package com.champsoft.vrms.modules.cars.api;\n\npublic class VehicleController {\n}\n'
write_file "$BASE/modules/cars/api/VehicleExceptionHandler.java" $'package com.champsoft.vrms.modules.cars.api;\n\npublic class VehicleExceptionHandler {\n}\n'
write_file "$BASE/modules/cars/api/mapper/VehicleApiMapper.java" $'package com.champsoft.vrms.modules.cars.api.mapper;\n\npublic class VehicleApiMapper {\n}\n'
write_file "$BASE/modules/cars/api/dto/CreateVehicleRequest.java" $'package com.champsoft.vrms.modules.cars.api.dto;\n\npublic record CreateVehicleRequest(String vin) { }\n'
write_file "$BASE/modules/cars/api/dto/UpdateVehicleRequest.java" $'package com.champsoft.vrms.modules.cars.api.dto;\n\npublic record UpdateVehicleRequest(String status) { }\n'
write_file "$BASE/modules/cars/api/dto/VehicleResponse.java" $'package com.champsoft.vrms.modules.cars.api.dto;\n\npublic record VehicleResponse(String id, String vin, String status) { }\n'

# ==========================================================
# owners
# ==========================================================
write_file "$BASE/modules/owners/domain/model/Owner.java" $'package com.champsoft.vrms.modules.owners.domain.model;\n\npublic class Owner {\n}\n'
write_file "$BASE/modules/owners/domain/model/OwnerId.java" $'package com.champsoft.vrms.modules.owners.domain.model;\n\npublic record OwnerId(String value) { }\n'
write_file "$BASE/modules/owners/domain/model/FullName.java" $'package com.champsoft.vrms.modules.owners.domain.model;\n\npublic record FullName(String value) { }\n'
write_file "$BASE/modules/owners/domain/model/Address.java" $'package com.champsoft.vrms.modules.owners.domain.model;\n\npublic class Address {\n}\n'
write_file "$BASE/modules/owners/domain/model/OwnerStatus.java" $'package com.champsoft.vrms.modules.owners.domain.model;\n\npublic enum OwnerStatus {\n    ACTIVE, SUSPENDED\n}\n'

write_file "$BASE/modules/owners/domain/exception/InvalidOwnerNameException.java" $'package com.champsoft.vrms.modules.owners.domain.exception;\n\npublic class InvalidOwnerNameException extends RuntimeException {\n    public InvalidOwnerNameException(String message) { super(message); }\n}\n'
write_file "$BASE/modules/owners/domain/exception/InvalidAddressException.java" $'package com.champsoft.vrms.modules.owners.domain.exception;\n\npublic class InvalidAddressException extends RuntimeException {\n    public InvalidAddressException(String message) { super(message); }\n}\n'
write_file "$BASE/modules/owners/domain/exception/OwnerNotEligibleException.java" $'package com.champsoft.vrms.modules.owners.domain.exception;\n\npublic class OwnerNotEligibleException extends RuntimeException {\n    public OwnerNotEligibleException(String message) { super(message); }\n}\n'

write_file "$BASE/modules/owners/application/port/out/OwnerRepositoryPort.java" $'package com.champsoft.vrms.modules.owners.application.port.out;\n\npublic interface OwnerRepositoryPort {\n}\n'
write_file "$BASE/modules/owners/application/service/OwnerCrudService.java" $'package com.champsoft.vrms.modules.owners.application.service;\n\npublic class OwnerCrudService {\n}\n'
write_file "$BASE/modules/owners/application/service/OwnerEligibilityService.java" $'package com.champsoft.vrms.modules.owners.application.service;\n\npublic class OwnerEligibilityService {\n}\n'
write_file "$BASE/modules/owners/application/exception/OwnerNotFoundException.java" $'package com.champsoft.vrms.modules.owners.application.exception;\n\npublic class OwnerNotFoundException extends RuntimeException {\n    public OwnerNotFoundException(String message) { super(message); }\n}\n'
write_file "$BASE/modules/owners/application/exception/DuplicateOwnerException.java" $'package com.champsoft.vrms.modules.owners.application.exception;\n\npublic class DuplicateOwnerException extends RuntimeException {\n    public DuplicateOwnerException(String message) { super(message); }\n}\n'

write_file "$BASE/modules/owners/infrastructure/persistence/OwnerJpaEntity.java" $'package com.champsoft.vrms.modules.owners.infrastructure.persistence;\n\npublic class OwnerJpaEntity {\n}\n'
write_file "$BASE/modules/owners/infrastructure/persistence/SpringDataOwnerRepository.java" $'package com.champsoft.vrms.modules.owners.infrastructure.persistence;\n\npublic interface SpringDataOwnerRepository {\n}\n'
write_file "$BASE/modules/owners/infrastructure/persistence/JpaOwnerRepositoryAdapter.java" $'package com.champsoft.vrms.modules.owners.infrastructure.persistence;\n\npublic class JpaOwnerRepositoryAdapter {\n}\n'

write_file "$BASE/modules/owners/api/OwnerController.java" $'package com.champsoft.vrms.modules.owners.api;\n\npublic class OwnerController {\n}\n'
write_file "$BASE/modules/owners/api/OwnerExceptionHandler.java" $'package com.champsoft.vrms.modules.owners.api;\n\npublic class OwnerExceptionHandler {\n}\n'
write_file "$BASE/modules/owners/api/mapper/OwnerApiMapper.java" $'package com.champsoft.vrms.modules.owners.api.mapper;\n\npublic class OwnerApiMapper {\n}\n'
write_file "$BASE/modules/owners/api/dto/CreateOwnerRequest.java" $'package com.champsoft.vrms.modules.owners.api.dto;\n\npublic record CreateOwnerRequest(String fullName) { }\n'
write_file "$BASE/modules/owners/api/dto/UpdateOwnerRequest.java" $'package com.champsoft.vrms.modules.owners.api.dto;\n\npublic record UpdateOwnerRequest(String status) { }\n'
write_file "$BASE/modules/owners/api/dto/OwnerResponse.java" $'package com.champsoft.vrms.modules.owners.api.dto;\n\npublic record OwnerResponse(String id, String fullName, String status) { }\n'

# ==========================================================
# agents
# ==========================================================
write_file "$BASE/modules/agents/domain/model/Agent.java" $'package com.champsoft.vrms.modules.agents.domain.model;\n\npublic class Agent {\n}\n'
write_file "$BASE/modules/agents/domain/model/AgentId.java" $'package com.champsoft.vrms.modules.agents.domain.model;\n\npublic record AgentId(String value) { }\n'
write_file "$BASE/modules/agents/domain/model/Role.java" $'package com.champsoft.vrms.modules.agents.domain.model;\n\npublic record Role(String value) { }\n'
write_file "$BASE/modules/agents/domain/model/AgentStatus.java" $'package com.champsoft.vrms.modules.agents.domain.model;\n\npublic enum AgentStatus {\n    ACTIVE, SUSPENDED\n}\n'

write_file "$BASE/modules/agents/domain/exception/InvalidRoleException.java" $'package com.champsoft.vrms.modules.agents.domain.exception;\n\npublic class InvalidRoleException extends RuntimeException {\n    public InvalidRoleException(String message) { super(message); }\n}\n'
write_file "$BASE/modules/agents/domain/exception/AgentNotEligibleException.java" $'package com.champsoft.vrms.modules.agents.domain.exception;\n\npublic class AgentNotEligibleException extends RuntimeException {\n    public AgentNotEligibleException(String message) { super(message); }\n}\n'

write_file "$BASE/modules/agents/application/port/out/AgentRepositoryPort.java" $'package com.champsoft.vrms.modules.agents.application.port.out;\n\npublic interface AgentRepositoryPort {\n}\n'
write_file "$BASE/modules/agents/application/service/AgentCrudService.java" $'package com.champsoft.vrms.modules.agents.application.service;\n\npublic class AgentCrudService {\n}\n'
write_file "$BASE/modules/agents/application/service/AgentEligibilityService.java" $'package com.champsoft.vrms.modules.agents.application.service;\n\npublic class AgentEligibilityService {\n}\n'
write_file "$BASE/modules/agents/application/exception/AgentNotFoundException.java" $'package com.champsoft.vrms.modules.agents.application.exception;\n\npublic class AgentNotFoundException extends RuntimeException {\n    public AgentNotFoundException(String message) { super(message); }\n}\n'
write_file "$BASE/modules/agents/application/exception/DuplicateAgentException.java" $'package com.champsoft.vrms.modules.agents.application.exception;\n\npublic class DuplicateAgentException extends RuntimeException {\n    public DuplicateAgentException(String message) { super(message); }\n}\n'

write_file "$BASE/modules/agents/infrastructure/persistence/AgentJpaEntity.java" $'package com.champsoft.vrms.modules.agents.infrastructure.persistence;\n\npublic class AgentJpaEntity {\n}\n'
write_file "$BASE/modules/agents/infrastructure/persistence/SpringDataAgentRepository.java" $'package com.champsoft.vrms.modules.agents.infrastructure.persistence;\n\npublic interface SpringDataAgentRepository {\n}\n'
write_file "$BASE/modules/agents/infrastructure/persistence/JpaAgentRepositoryAdapter.java" $'package com.champsoft.vrms.modules.agents.infrastructure.persistence;\n\npublic class JpaAgentRepositoryAdapter {\n}\n'

write_file "$BASE/modules/agents/api/AgentController.java" $'package com.champsoft.vrms.modules.agents.api;\n\npublic class AgentController {\n}\n'
write_file "$BASE/modules/agents/api/AgentExceptionHandler.java" $'package com.champsoft.vrms.modules.agents.api;\n\npublic class AgentExceptionHandler {\n}\n'
write_file "$BASE/modules/agents/api/mapper/AgentApiMapper.java" $'package com.champsoft.vrms.modules.agents.api.mapper;\n\npublic class AgentApiMapper {\n}\n'
write_file "$BASE/modules/agents/api/dto/CreateAgentRequest.java" $'package com.champsoft.vrms.modules.agents.api.dto;\n\npublic record CreateAgentRequest(String role) { }\n'
write_file "$BASE/modules/agents/api/dto/UpdateAgentRequest.java" $'package com.champsoft.vrms.modules.agents.api.dto;\n\npublic record UpdateAgentRequest(String status) { }\n'
write_file "$BASE/modules/agents/api/dto/AgentResponse.java" $'package com.champsoft.vrms.modules.agents.api.dto;\n\npublic record AgentResponse(String id, String role, String status) { }\n'

# ==========================================================
# registration
# ==========================================================
write_file "$BASE/modules/registration/domain/model/Registration.java" $'package com.champsoft.vrms.modules.registration.domain.model;\n\npublic class Registration {\n}\n'
write_file "$BASE/modules/registration/domain/model/RegistrationId.java" $'package com.champsoft.vrms.modules.registration.domain.model;\n\npublic record RegistrationId(String value) { }\n'
write_file "$BASE/modules/registration/domain/model/VehicleRef.java" $'package com.champsoft.vrms.modules.registration.domain.model;\n\npublic record VehicleRef(String vehicleId) { }\n'
write_file "$BASE/modules/registration/domain/model/OwnerRef.java" $'package com.champsoft.vrms.modules.registration.domain.model;\n\npublic record OwnerRef(String ownerId) { }\n'
write_file "$BASE/modules/registration/domain/model/AgentRef.java" $'package com.champsoft.vrms.modules.registration.domain.model;\n\npublic record AgentRef(String agentId) { }\n'
write_file "$BASE/modules/registration/domain/model/PlateNumber.java" $'package com.champsoft.vrms.modules.registration.domain.model;\n\npublic record PlateNumber(String value) { }\n'
write_file "$BASE/modules/registration/domain/model/ExpiryDate.java" $'package com.champsoft.vrms.modules.registration.domain.model;\n\nimport java.time.LocalDate;\n\npublic record ExpiryDate(LocalDate value) { }\n'
write_file "$BASE/modules/registration/domain/model/RegistrationStatus.java" $'package com.champsoft.vrms.modules.registration.domain.model;\n\npublic enum RegistrationStatus {\n    DRAFT, ACTIVE, CANCELLED, EXPIRED\n}\n'

write_file "$BASE/modules/registration/domain/exception/InvalidPlateException.java" $'package com.champsoft.vrms.modules.registration.domain.exception;\n\npublic class InvalidPlateException extends RuntimeException {\n    public InvalidPlateException(String message) { super(message); }\n}\n'
write_file "$BASE/modules/registration/domain/exception/ExpiryDateMustBeFutureException.java" $'package com.champsoft.vrms.modules.registration.domain.exception;\n\npublic class ExpiryDateMustBeFutureException extends RuntimeException {\n    public ExpiryDateMustBeFutureException(String message) { super(message); }\n}\n'
write_file "$BASE/modules/registration/domain/exception/RegistrationNotActiveException.java" $'package com.champsoft.vrms.modules.registration.domain.exception;\n\npublic class RegistrationNotActiveException extends RuntimeException {\n    public RegistrationNotActiveException(String message) { super(message); }\n}\n'

write_file "$BASE/modules/registration/application/port/out/VehicleEligibilityPort.java" $'package com.champsoft.vrms.modules.registration.application.port.out;\n\npublic interface VehicleEligibilityPort {\n}\n'
write_file "$BASE/modules/registration/application/port/out/OwnerEligibilityPort.java" $'package com.champsoft.vrms.modules.registration.application.port.out;\n\npublic interface OwnerEligibilityPort {\n}\n'
write_file "$BASE/modules/registration/application/port/out/AgentEligibilityPort.java" $'package com.champsoft.vrms.modules.registration.application.port.out;\n\npublic interface AgentEligibilityPort {\n}\n'
write_file "$BASE/modules/registration/application/port/out/RegistrationRepositoryPort.java" $'package com.champsoft.vrms.modules.registration.application.port.out;\n\npublic interface RegistrationRepositoryPort {\n}\n'

write_file "$BASE/modules/registration/application/service/RegistrationCrudService.java" $'package com.champsoft.vrms.modules.registration.application.service;\n\npublic class RegistrationCrudService {\n}\n'
write_file "$BASE/modules/registration/application/service/RegistrationOrchestrator.java" $'package com.champsoft.vrms.modules.registration.application.service;\n\npublic class RegistrationOrchestrator {\n}\n'

write_file "$BASE/modules/registration/application/exception/PlateAlreadyTakenException.java" $'package com.champsoft.vrms.modules.registration.application.exception;\n\npublic class PlateAlreadyTakenException extends RuntimeException {\n    public PlateAlreadyTakenException(String message) { super(message); }\n}\n'
write_file "$BASE/modules/registration/application/exception/RegistrationNotFoundException.java" $'package com.champsoft.vrms.modules.registration.application.exception;\n\npublic class RegistrationNotFoundException extends RuntimeException {\n    public RegistrationNotFoundException(String message) { super(message); }\n}\n'
write_file "$BASE/modules/registration/application/exception/CrossContextValidationException.java" $'package com.champsoft.vrms.modules.registration.application.exception;\n\npublic class CrossContextValidationException extends RuntimeException {\n    public CrossContextValidationException(String message) { super(message); }\n}\n'

write_file "$BASE/modules/registration/infrastructure/persistence/RegistrationJpaEntity.java" $'package com.champsoft.vrms.modules.registration.infrastructure.persistence;\n\npublic class RegistrationJpaEntity {\n}\n'
write_file "$BASE/modules/registration/infrastructure/persistence/SpringDataRegistrationRepository.java" $'package com.champsoft.vrms.modules.registration.infrastructure.persistence;\n\npublic interface SpringDataRegistrationRepository {\n}\n'
write_file "$BASE/modules/registration/infrastructure/persistence/JpaRegistrationRepositoryAdapter.java" $'package com.champsoft.vrms.modules.registration.infrastructure.persistence;\n\npublic class JpaRegistrationRepositoryAdapter {\n}\n'

write_file "$BASE/modules/registration/infrastructure/acl/VehicleEligibilityAdapter.java" $'package com.champsoft.vrms.modules.registration.infrastructure.acl;\n\npublic class VehicleEligibilityAdapter {\n}\n'
write_file "$BASE/modules/registration/infrastructure/acl/OwnerEligibilityAdapter.java" $'package com.champsoft.vrms.modules.registration.infrastructure.acl;\n\npublic class OwnerEligibilityAdapter {\n}\n'
write_file "$BASE/modules/registration/infrastructure/acl/AgentEligibilityAdapter.java" $'package com.champsoft.vrms.modules.registration.infrastructure.acl;\n\npublic class AgentEligibilityAdapter {\n}\n'

write_file "$BASE/modules/registration/api/RegistrationController.java" $'package com.champsoft.vrms.modules.registration.api;\n\npublic class RegistrationController {\n}\n'
write_file "$BASE/modules/registration/api/RegistrationExceptionHandler.java" $'package com.champsoft.vrms.modules.registration.api;\n\npublic class RegistrationExceptionHandler {\n}\n'
write_file "$BASE/modules/registration/api/mapper/RegistrationApiMapper.java" $'package com.champsoft.vrms.modules.registration.api.mapper;\n\npublic class RegistrationApiMapper {\n}\n'

write_file "$BASE/modules/registration/api/dto/RegisterVehicleRequest.java" $'package com.champsoft.vrms.modules.registration.api.dto;\n\npublic record RegisterVehicleRequest(String vehicleId, String ownerId, String agentId) { }\n'
write_file "$BASE/modules/registration/api/dto/RenewRegistrationRequest.java" $'package com.champsoft.vrms.modules.registration.api.dto;\n\npublic record RenewRegistrationRequest(String registrationId) { }\n'
write_file "$BASE/modules/registration/api/dto/CancelRegistrationRequest.java" $'package com.champsoft.vrms.modules.registration.api.dto;\n\npublic record CancelRegistrationRequest(String registrationId) { }\n'
write_file "$BASE/modules/registration/api/dto/RegistrationResponse.java" $'package com.champsoft.vrms.modules.registration.api.dto;\n\npublic record RegistrationResponse(String id, String plateNumber, String status) { }\n'

# ==========================================================
# test
# ==========================================================
write_file "src/test/java/com/champsoft/vrms/VrmsApplicationTests.java" $'package com.champsoft.vrms;\n\nimport org.junit.jupiter.api.Test;\nimport org.springframework.boot.test.context.SpringBootTest;\n\n@SpringBootTest\nclass VrmsApplicationTests {\n\n    @Test\n    void contextLoads() {\n    }\n}\n'

echo ""
echo "✅ VRMS project structure generated successfully (main entry point untouched)"
echo ""