# Proyecto 12: Serverless API

Serverless REST API con API Gateway, Lambda functions, y DynamoDB. CRUD completo con autenticación por API Key y gestión de usuarios en tiempo real.

## Descripción

Este proyecto implementa una API REST completamente serverless en AWS, demostrando mejores prácticas de arquitectura cloud-native. La solución utiliza API Gateway v1 para gestionar las solicitudes HTTP, funciones Lambda para la lógica de negocio, y DynamoDB para almacenamiento de datos escalable sin servidor.

La API está protegida con API Keys, permitiendo control granular de acceso y uso mediante plans de consumo. Todos los componentes utilizan el modelo de precios bajo demanda (pay-per-request), minimizando costos en entornos de desarrollo y escalando automáticamente con la carga de trabajo.

### Características principales

- **API REST completamente serverless** - Sin servidores que administrar
- **Autenticación con API Key** - Protección de endpoints y control de acceso
- **CRUD completo** - Operaciones de lectura, escritura, actualización y eliminación
- **DynamoDB on-demand** - Escalado automático sin capacity planning
- **CloudWatch Logs** - Monitoreo y debugging de funciones Lambda
- **IAM con principio de menor privilegio** - Roles y policies restrictivos

## Arquitectura
API Gateway (REST v1) → Lambda Functions (Python 3.11) → DynamoDB
↓
CloudWatch Logs

**Flujo de solicitud:**
1. Cliente envía solicitud HTTP con header `x-api-key`
2. API Gateway valida la API Key y enruta a la Lambda correspondiente
3. Lambda procesa la solicitud y accede a DynamoDB
4. Respuesta se retorna como JSON
5. Logs se escriben en CloudWatch para auditoría

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/users` | Lista todos los usuarios |
| POST | `/users` | Crea un nuevo usuario |
| GET | `/users/{id}` | Obtiene un usuario por ID |
| PUT | `/users/{id}` | Actualiza un usuario |
| DELETE | `/users/{id}` | Elimina un usuario |

## Stack Tecnológico

- **API Gateway**: REST API v1 con API Key y Usage Plans
- **Lambda**: 5 funciones Python 3.11 para operaciones CRUD
- **DynamoDB**: Base de datos NoSQL serverless con billing on-demand
- **CloudWatch**: Logs centralizados para todas las funciones Lambda
- **IAM**: Roles y políticas con principio de menor privilegio
- **Terraform**: Infrastructure as Code para reproducibilidad

## Uso

### Obtén tu API Key

```bash
terraform output api_key_value
```

### Prueba un endpoint

```bash
API_KEY="tu-api-key-aqui"
ENDPOINT="https://ncjvtrsuok.execute-api.us-east-1.amazonaws.com/prod"

# Crear usuario
curl -X POST "$ENDPOINT/users" \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name":"Juan","email":"juan@example.com"}'

# Listar usuarios
curl -X GET "$ENDPOINT/users" \
  -H "x-api-key: $API_KEY"

# Obtener usuario específico
curl -X GET "$ENDPOINT/users/{id}" \
  -H "x-api-key: $API_KEY"

# Actualizar usuario
curl -X PUT "$ENDPOINT/users/{id}" \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name":"Juan Updated","email":"juan.new@example.com"}'

# Eliminar usuario
curl -X DELETE "$ENDPOINT/users/{id}" \
  -H "x-api-key: $API_KEY"
```

## Deployment

```bash
# Inicializar Terraform
terraform init

# Ver plan de cambios
terraform plan

# Aplicar cambios
terraform apply

# Ver outputs
terraform output
```

## Archivos

- `main.tf` - Recursos AWS (API Gateway, Lambda, DynamoDB, IAM, CloudWatch)
- `variables.tf` - Variables de configuración (project_name, region, etc.)
- `outputs.tf` - Outputs (endpoint, API key, ARNs de funciones)
- `providers.tf` - Configuración del provider de AWS
- `terraform.tfvars` - Valores de variables
- `lambda_list_users.py` - Función para listar todos los usuarios
- `lambda_create_user.py` - Función para crear nuevo usuario
- `lambda_get_user.py` - Función para obtener usuario por ID
- `lambda_update_user.py` - Función para actualizar usuario
- `lambda_delete_user.py` - Función para eliminar usuario

## Conceptos clave aprendidos

- Serverless architecture y su escalabilidad
- API Gateway como punto de entrada serverless
- Lambda como compute serverless
- DynamoDB para almacenamiento NoSQL escalable
- API Key management y usage plans
- IAM roles y policies con least privilege
- Infrastructure as Code con Terraform
- CloudWatch Logs para observabilidad