# MiniCart Flutter Lab App

MiniCart is a single Flutter project built to cover all listed App Development lab experiments in one coherent app.

## App Overview

Core features implemented:
- Login screen with form validation
- Product listing with cards and dynamic list rendering
- Product details screen
- Cart with dynamic state updates
- Product fetch from REST API with JSON parsing
- Local storage for login status and cart count
- Material Design 3 theme usage across app

## Lab-wise Documentation

### Lab 1: Introduction to Flutter and Dart
Concepts:
- Flutter setup and first app execution
- Dart basics: variables, classes, functions, async methods

In this project:
- Entry point is in `lib/main.dart`.
- App bootstrap is in `lib/app.dart`.
- Dart syntax usage is spread through models, services, and screens.

### Lab 2: Flutter Project Structure and Widgets
Concepts:
- Understanding `pubspec.yaml` and `main.dart`
- Stateless and Stateful widgets

In this project:
- Dependencies are declared in `pubspec.yaml`.
- `MiniCartApp` is a `StatelessWidget` in `lib/app.dart`.
- `LoginScreen` and `HomeScreen` are `StatefulWidget` examples in `lib/screens/`.

### Lab 3: Layouts and Styling
Concepts:
- Layout widgets like `SizedBox`, `Expanded`
- Styling with themes, colors, typography
- Login screen design

In this project:
- Global Material 3 theme is configured in `lib/theme/app_theme.dart`.
- Login UI layout uses `Column`, `SizedBox`, `Card`, and constrained width in `lib/screens/login_screen.dart`.
- Product rows use `Expanded` for responsive layout in `lib/screens/product_list_screen.dart`.

### Lab 4: User Input and Forms
Concepts:
- `TextField`/`TextFormField`
- `Form` and validation

In this project:
- Login form uses `Form`, `TextFormField`, `GlobalKey<FormState>` in `lib/screens/login_screen.dart`.
- Email and password validators are implemented before navigation.

### Lab 5: Navigation and Routing
Concepts:
- Multi-screen navigation with `Navigator`
- Passing data between screens

In this project:
- Login to home navigation uses `pushReplacement`.
- Home to details and home to cart use `push`.
- Product/cart data is passed as constructor parameters.
- Main routing logic is in `lib/screens/home_screen.dart` and `lib/screens/login_screen.dart`.

### Lab 6: State Management Basics
Concepts:
- `setState` and stateful UI updates
- Interaction-driven UI changes

In this project:
- Cart count and cart items are managed in `_HomeScreenState` (`lib/screens/home_screen.dart`).
- `setState` updates badge count and in-memory cart immediately on add-to-cart.

### Lab 7: Lists and Dynamic Content
Concepts:
- `ListView` and `ListView.builder`
- Card-based item presentation

In this project:
- Product list is rendered with `ListView.separated` in `lib/screens/product_list_screen.dart`.
- Cart list is rendered with `ListView.builder` in `lib/screens/cart_screen.dart`.
- Product and cart entries use `Card` widgets.

### Lab 8: Fetching Data from APIs
Concepts:
- HTTP package usage
- REST API fetch
- JSON parsing

In this project:
- API requests use `http.get` in `lib/services/api_service.dart`.
- Endpoint: `https://fakestoreapi.com/products`.
- JSON is parsed into `Product` model objects via `Product.fromJson`.

### Lab 9: Local Data Storage
Concepts:
- `shared_preferences`
- Save/retrieve simple app state
- Basic offline support

In this project:
- Login status and cart count are persisted using `shared_preferences` in `lib/services/storage_service.dart`.
- Startup login check is done in `lib/app.dart`.
- API service has a fallback to local sample products (`lib/data/sample_products.dart`) for resilience.

### Lab 10: Final App Build and Deployment
Concepts:
- Consolidating all lab concepts into one mini-project
- Build generation and debugging

In this project:
- MiniCart combines authentication flow, navigation, API data, local storage, and state updates.
- App uses a clean folder structure suitable for viva explanation.
- Build command for Android APK:

```bash
flutter build apk
```

## Dependencies Used

- `flutter`
- `cupertino_icons`
- `http`
- `shared_preferences`

## How to Run

```bash
flutter pub get
flutter run
```

## Viva Quick Notes

- `push` adds a new page to stack; `pop` removes current page.
- `setState` triggers widget rebuild for updated UI.
- `FutureBuilder` is used to handle async startup/API states.
- `shared_preferences` stores small key-value data on device.

## Author Note

This app intentionally focuses on lab objectives and clear implementation over unnecessary complexity.
