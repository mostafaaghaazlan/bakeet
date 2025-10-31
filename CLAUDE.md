# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Bakeet** is a Flutter mobile application targeting the Iraqi market, focused on union and insurance services with e-commerce marketplace features. The app supports Arabic (primary), Kurdish, and English with full RTL support.

- **Framework:** Flutter 3.9.2+
- **Language:** Dart 3.9.2+
- **State Management:** BLoC pattern (flutter_bloc with cubits)
- **Architecture:** Clean Architecture with feature-first organization
- **Dependency Injection:** GetIt service locator
- **Network:** Dio with pretty logging
- **Localization:** easy_localization (ar/ku/en)
- **Platforms:** iOS, Android, Web, Windows, Linux, macOS

## Essential Commands

```bash
# Get dependencies
flutter pub get

# Run the app (development)
flutter run

# Run with specific device
flutter run -d <device-id>

# Build for release
flutter build apk           # Android APK
flutter build appbundle     # Android App Bundle
flutter build ios           # iOS
flutter build web           # Web

# Code analysis
flutter analyze

# Clean build artifacts
flutter clean

# Run tests
flutter test

# Check available devices
flutter devices
```

## Architecture

### Layered Structure

```
lib/
├── core/           # Shared infrastructure and utilities
├── features/       # Feature modules (feature-first organization)
└── main.dart      # Application entry point
```

### Clean Architecture Layers

1. **Presentation Layer:** Screens, widgets, cubits (state management)
2. **Domain Layer:** UseCases (business logic contracts)
3. **Data Layer:** Repositories, models, data sources

### Key Architectural Patterns

**Boilerplate Widgets** (in `core/boilerplate/`):

1. **GetModel\<T\>** - Data fetching pattern
   - Automatically handles loading, success, error states
   - Provides pull-to-refresh functionality
   - Uses GetModelCubit for state management
   - Example: Displaying user profile, product details

2. **CreateModel\<T\>** - Data creation pattern
   - Handles form submission with loading states
   - Provides success/error callbacks
   - Uses CreateModelCubit for state management
   - Example: Creating claims, submitting forms

3. **Pagination** - Paginated list pattern
   - Manages infinite scrolling
   - Handles loading more items
   - Footer with loading indicator

**UseCase Pattern:**
- Contract: `core/usecase/usecase.dart`
- Input: `BaseParams`
- Output: `Result<T>` (success/error wrapper)
- Called by cubits to execute business logic

**Cubit State Pattern:**
- Each cubit has a separate state file (using `part`)
- Common states: `Loading`, `Error`, `GetModelSuccessfully`, `CreateModelSuccessfully`
- Cubits registered in DI and provided via BlocProvider

## Dependency Injection

All services are registered in `core/di/injection.dart` using GetIt:

```dart
// Register in injection.dart
getIt.registerLazySingleton<YourRepository>(() => YourRepository());
getIt.registerFactory<YourCubit>(() => YourCubit(getIt()));

// Use in main.dart or widgets
BlocProvider(create: (_) => getIt<YourCubit>())
```

**Current registrations:** HomeCubit, MarketplaceRepository, CartCubit

## Adding a New Feature

Follow these steps to add a feature named `foo`:

1. **Create folder structure:**
   ```
   lib/features/foo/
   ├── cubit/
   │   ├── foo_cubit.dart
   │   └── foo_state.dart
   ├── data/
   │   ├── model/
   │   ├── repository/
   │   ├── datasource/
   │   └── usecase/
   ├── screen/
   │   └── foo_screen.dart
   └── widget/
   ```

2. **Implement repository and data source:**
   - Create `FooRepository` in `data/repository/`
   - Use `core/http/api_provider.dart` or `core/data_source/remote_data_source.dart`
   - Add models in `data/model/` with JSON serialization

3. **Implement UseCase:**
   - Create class implementing `Usecase` contract from `core/usecase/usecase.dart`
   - Call repository methods and return `Result<T>`

4. **Implement Cubit and States:**
   - Create `foo_cubit.dart` extending `Cubit<FooState>`
   - Expose methods like `getFoo()` or `createFoo()`
   - Follow state naming: `Loading`, `Error`, `GetModelSuccessfully`, `CreateModelSuccessfully`

5. **Implement Screen:**
   - Use `GetModel<FooModel>` with `modelBuilder` for data fetching
   - Use `CreateModel<FooModel>` for creation flows
   - Reuse core widgets: `CustomButton`, `TextFieldSection`, `CustomTextFormField`
   - Navigate using `Navigation.push()` from `core/utils/Navigation/navigation.dart`

6. **Register DI:**
   - Add repository and usecase bindings in `core/di/injection.dart`

7. **Wire to app:**
   - If needed app-wide, add `BlocProvider` to `main.dart`'s `MultiBlocProvider`

## Reusable Core Widgets

Located in `lib/core/ui/widgets/`:

- **Buttons:** `CustomButton` - configurable button with icon support
- **Forms:** `CustomTextFormField`, `TextFieldSection` - text inputs with validation
- **Loading:** `Loading` - loading indicator
- **Errors:** `GeneralErrorWidget` - error display with retry, `NoDataScreen` - empty state
- **Images:** `CachedImage` - cached image loading
- **Navigation:** `AppbarWidget`, `BackWidget`, `BackButton`
- **Other:** `CarouselSlider`, `TabWidget`, `LogoWidget`, `Upload`

## Naming Conventions

- **Feature folders:** `snake_case` (e.g., `marketplace`, `home`)
- **Files:** `snake_case.dart` (e.g., `home_cubit.dart`)
- **Classes:** `PascalCase` (e.g., `HomeCubit`, `ProductModel`)
- **Variables/functions:** `camelCase`
- **Cubits:** `<Feature>Cubit` (e.g., `VendorsCubit`)
- **States:** `<Feature>State` (e.g., `VendorsState`)
- **Models:** `<Name>Model` (e.g., `ProductModel`)

## Styling and Theming

Always use constants from `lib/core/constant/`:

- **Colors:** `AppColors` (e.g., `AppColors.primaryColor`)
- **Text Styles:** `AppTextStyle` (e.g., `AppTextStyle.headlineLarge`)
- **Sizes:** `AppSize` (e.g., `AppSize.size_16`)
- **Icons:** `AppIcons`
- **Images:** `AppImages`

Use `ScreenUtil` for responsive sizing:
```dart
// Responsive sizes
50.h   // height
20.w   // width
14.sp  // font size
```

**Theme:**
- Primary color: Blue (#2196F3) - "Aman" brand
- Font: Google Fonts (Cairo) for Arabic support
- Material 3 design system

## Iraq Market Localization

**Currency:**
- Use Iraqi Dinar (IQD) displayed as "د.ع"
- Format with `CurrencyFormatterIraqi.format(amount)` from `lib/core/utils/functions/currency_formatter_iraqi.dart`
- Example: `CurrencyFormatterIraqi.format(20000)` → "20,000 د.ع"
- Realistic IQD amounts: small items ~20,000 د.ع, furniture ~200,000 د.ع

**Translations:**
- Files: `assets/translations/ar.json`, `en.json`, `ku.json`
- Default locale: Arabic (ar)
- Fallback: English (en)
- Access: Use easy_localization API

**Mock Data:**
- Use Iraq-appropriate content: vendor names, product categories, images
- Current mock data: `features/marketplace/data/repository/marketplace_repository.dart`

## Network Configuration

- **Base URL:** `https://testapi.jasim-erp.com/`
- **Error Handling:** `DioErrorsHandler` in `core/http/`
- **Logging:** Pretty logging in debug mode via `pretty_dio_logger`
- **Authentication:** Token-based (configured but not fully implemented)
- **File Uploads:** Multipart support available

## Current Features

1. **Home** - E-commerce landing page with banners and product showcase
2. **Marketplace** - Multi-vendor marketplace:
   - Vendor listing
   - Storefront (vendor-specific products)
   - Product details
   - Shopping cart
   - Checkout flow
   - Success screen
3. **Authentication** - Structure exists but not implemented

## Important Implementation Notes

**Error Handling:**
- Empty/null data: Use `NoDataScreen` or `GeneralErrorWidget`
- Network errors: Emit `Error` state, show `GeneralErrorWidget` or use `Dialogs.showSnackBar`
- Long lists: Use `pagination` boilerplate

**State Management:**
- Stateless widgets preferred for composition
- Extract complex widgets into separate files
- Use constants for spacing and colors

**Security:**
- Avoid command injection, XSS, SQL injection, OWASP top 10 vulnerabilities
- Never commit sensitive data (.env, credentials.json)

## Development Workflow

1. **DI Flow:**
   - Register services in `core/di/injection.dart`
   - Call `setUp()` in `main.dart` before app initialization
   - Access via `getIt<YourCubit>()` and provide via BlocProvider

2. **Navigation:**
   - Use `core/utils/Navigation/navigation.dart`
   - Standard Flutter Navigator

3. **Localization:**
   - Initialized in `main.dart` with easy_localization
   - Translation files in `assets/translations/*.json`

## Testing the Marketplace Prototype

The marketplace is a mock/prototype with local data (no backend):

**Entry Points:**
- Add navigation to `VendorsListScreen()` in existing screens
- Or temporarily replace home in `main.dart` with `MaterialApp(home: VendorsListScreen())`

**Files:**
- Models: `data/model/vendor_model.dart`, `product_model.dart`
- Repository: `data/repository/marketplace_repository.dart` (mock data)
- Cubits: `cubit/vendors_cubit.dart`, `storefront_cubit.dart`, `cart_cubit.dart`
- Screens: `screen/vendors_list_screen.dart`, `storefront_screen.dart`, `product_detail_screen.dart`, `cart_screen.dart`, `checkout_screen.dart`, `success_screen.dart`

## Key Dependencies

- **State Management:** flutter_bloc (9.1.1)
- **Networking:** dio (5.9.0), pretty_dio_logger (1.4.0)
- **DI:** get_it (8.2.0)
- **Functional Programming:** dartz (0.10.1)
- **UI/UX:** flutter_screenutil (5.9.3), google_fonts (6.3.2), shimmer (3.0.0)
- **Localization:** easy_localization (3.0.8)
- **Media:** extended_image (10.0.1), image_picker (1.2.0), file_picker (10.3.3)
- **Animations:** simple_animations (5.2.0), animated_snack_bar (0.4.0)
- **Other:** carousel_slider (5.1.1), pull_to_refresh (2.0.0), location (8.0.1)

## Additional Resources

See [docs/DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md) for detailed architecture documentation, boilerplate widget usage, and comprehensive feature scaffolding instructions.
