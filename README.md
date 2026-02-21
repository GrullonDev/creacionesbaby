# CreacionesBaby 🍼✨

CreacionesBaby es un ecosistema de comercio electrónico robusto y listo para producción, desarrollado con **Flutter** y **Supabase**. Utiliza una base de código única para ofrecer una **Tienda Web** de alto rendimiento para clientes y una **Aplicación Móvil de Administración** integral para la gestión del negocio.

---

## 🚀 Resumen Técnico

### Stack Tecnológico
| Componente | Tecnología |
| :--- | :--- |
| **Framework** | [Flutter 3.x](https://flutter.dev/) (Dart SDK ^3.8.1) |
| **BaaS** | [Supabase](https://supabase.com/) (PostgreSQL, Real-time, Auth, Storage) |
| **Gestión de Estado** | [Provider](https://pub.dev/packages/provider) |
| **Networking** | Supabase Flutter SDK |
| **Tipografía** | Outfit & Inter (Google Fonts) |
| **Pruebas** | Flutter Test (Pruebas unitarias y de widgets) |

---

## 🏗 Arquitectura y Estructura del Proyecto

El proyecto sigue una estructura modular orientada a funcionalidades (**Feature-First**), lo que facilita la escalabilidad y el mantenimiento.

```text
lib/
├── config/             # Enrutamiento, temas y configuraciones de entorno
├── core/               # Lógica compartida entre funcionalidades
│   ├── models/         # Entidades de dominio (Producto, Pedido, etc.)
│   ├── providers/      # Lógica principal y controladores de estado
│   ├── theme/          # Tokens de tema global y estilos
│   └── widgets/        # Componentes de UI reutilizables
├── features/           # Funcionalidades modularizadas
│   ├── admin/          # Panel de gestión, stock y lógica de pedidos
│   ├── auth/           # Manejo de login y sesiones (Supabase Auth)
│   └── store/          # Catálogo para clientes y carrito de compras
└── utils/              # Helpers globales, animaciones y transiciones
```

---

## 🛠 Características Clave

### 🌐 Tienda Web
*   **Catálogo Dinámico:** Sincronización en tiempo real con los datos de productos en Supabase.
*   **Carrito Persistente:** Experiencia de compra eficiente gestionada mediante Provider.
*   **IU Estética:** Diseño moderno y amigable para bebés, con transiciones suaves y micro-animaciones.
*   **Responsive:** Optimizado tanto para escritorio como para navegadores móviles.

### 📱 App Móvil Administrativa
*   **Control de Inventario:** Operaciones CRUD completas para productos + gestión de stock en tiempo real.
*   **Gestión de Galería:** Soporte para múltiples imágenes gestionado a través de Supabase Storage.
*   **Panel de Pedidos:** Seguimiento de pedidos con filtrado por estado (Pendiente, Enviado, Entregado).
*   **Seguridad:** Acceso administrativo protegido mediante autenticación basada en JWT.

---

## 🧪 Aseguramiento de Calidad (QA)

Mantenemos un enfoque estricto en la estabilidad y el rendimiento del código:
*   **100% Cobertura en Lógica Core:** Cálculos y serialización de datos completamente verificados.
*   **Pruebas de Widgets:** Rutas críticas de la interfaz (Catálogo, Login Admin, Gestión de Productos) automatizadas.
*   **Pipeline de CI/CD:** GitHub Actions configurado para:
    *   Análisis sintáctico y linting (`flutter analyze`).
    *   Ejecución de la suite de pruebas automatizadas.
    *   Compilación de versiones web.

---

## ⚙️ Configuración de Desarrollo

### Prerrequisitos
*   [Flutter SDK](https://docs.flutter.dev/get-started/install)
*   [FVM](https://fvm.app/) (Recomendado)
*   Proyecto activo en Supabase

### Instalación
1.  **Clonar el repositorio**
    ```bash
    git clone git@github.com:GrullonDev/creacionesbaby.git
    cd creacionesbaby
    ```
2.  **Instalar Dependencias**
    ```bash
    flutter pub get
    ```
3.  **Configuración de Entorno**
    Configura tus credenciales de Supabase en `lib/config/env.dart`.
    *   `supabaseUrl`
    *   `supabaseAnonKey`

4.  **Migración de Base de Datos** (Opcional)
    Utiliza los scripts SQL en el directorio `backend/` para configurar tus tablas (Productos, Pedidos, Buckets de almacenamiento).

### Ejecución del Proyecto
*   **Tienda Web:** `flutter run -d chrome`
*   **Admin Móvil:** `flutter run -d <id_del_dispositivo>`

---

## 📦 Despliegue

### Web
```bash
# Compilar versión de producción
flutter build web --release
```

### Móvil
```bash
# Compilar APK de Android
flutter build apk --split-per-abi

# Compilar versión de iOS
flutter build ios --release
```

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT; consulta el archivo [LICENSE](LICENSE) para más detalles.

Desarrollado con ❤️ por **GrullonDev**.


