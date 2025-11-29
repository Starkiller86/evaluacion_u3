**📦 Paquexpress App - Sistema de Gestión de Entregas**

Este repositorio contiene la solución móvil integral desarrollada para Paquexpress S.A. de C.V., diseñada para optimizar la logística de última milla permitiendo a los agentes de campo gestionar entregas, capturar evidencias y sincronizar datos en tiempo real.

*🚀 Características Principales*
Gestión de Entregas: Visualización de lista de paquetes asignados por agente.

Geolocalización: Captura automática de coordenadas GPS al momento de la entrega.

Evidencia Fotográfica: Captura y subida de fotos como prueba de entrega (Proof of Delivery).

Mapas Interactivos: Visualización de rutas y destinos utilizando OpenStreetMap y Google Maps.

Seguridad: Autenticación mediante JWT (JSON Web Tokens) y almacenamiento seguro de credenciales.

*🛠️ Stack Tecnológico*
Frontend Móvil: Flutter (Dart)

Backend API: FastAPI (Python)

Base de Datos: MySQL

ORM: SQLAlchemy

Sensores: Cámara (image_picker), GPS (geolocator)

📂 Estructura del Repositorio
```text
app_movil/
├── lib/
│   ├── main.dart
│   ├── pages/
│   │   ├── login_page.dart
│   │   ├── deliveries_page.dart
│   │   ├── delivery_detail_page.dart
│   │   └── photo_page.dart
│   ├── services/
│   │   └── api_service.dart
│   └── models/
│       └── models.dart
└── database/
    └──paquexpress_db.sql
└── backend/
    └──env/
    └──evaluacion_u3.py

```
🔧 Instrucciones de Instalación
Prerrequisitos
Flutter SDK (3.0 o superior)

Python 3.9+

Servidor MySQL (XAMPP/WAMP o nativo)

1. Configuración de Base de Datos
Importa el script ubicado en database/init_db.sql en tu gestor MySQL.

Asegúrate de que la base de datos se llame paquexpress_db.

2. Ejecución del Backend (API)
Navega a la carpeta del backend e instala las dependencias:

```bash
cd backend_api
pip install fastapi uvicorn sqlalchemy mysql-connector-python python-multipart python-jose[cryptography] passlib[bcrypt]
Inicia el servidor (asegúrate de configurar tu IP en database.py si es necesario):
```
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```
3. Ejecución de la App Móvil
Navega a la carpeta de la app: cd app_movil

Actualiza la IP del servidor en lib/services/api_service.dart (variable baseUrl).

Instala las dependencias y ejecuta:

```bash
flutter pub get
flutter run
```
📱 Configuración de la App Móvil
pubspec.yaml
```yaml
name: evaluacion_u3
description: "A new Flutter project."

# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.9.2

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  geolocator: ^14.0.2
  http: ^1.6.0
  flutter_map: ^8.2.2
  latlong2: ^0.9.1
  image_picker: ^1.2.1
  url_launcher: ^6.3.2
  flutter_secure_storage: ^9.2.4
  shared_preferences: ^2.5.3
  geocoding: ^2.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^5.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package
```
Permisos Requeridos
Para el correcto funcionamiento de la aplicación, asegúrate de configurar los siguientes permisos:

Android (android/app/src/main/AndroidManifest.xml):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
iOS (ios/Runner/Info.plist):
```
```xml
<key>NSCameraUsageDescription</key>
<string>Esta app necesita acceso a la cámara para capturar evidencias de entrega</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Esta app necesita acceso a la ubicación para registrar coordenadas de entrega</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Esta app necesita acceso a la ubicación en segundo plano para seguimiento de rutas</string>
```
Desarrollado para la materia de Desarrollo de Aplicaciones Móviles - Noviembre 2025
