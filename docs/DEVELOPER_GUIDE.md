# Bakeet — Developer Guide

This document explains the project's architecture, file-and-folder conventions, common patterns (widgets, cubits, usecases), and guidance on how to add new features that match the existing structure and style. Use this as a single source of truth when asking the assistant to build components so they match the project.

## High-level architecture

- Flutter app using Bloc (cubits) for state management.
- Layers:
  - core: shared code (ui widgets, boilerplate, utils, constants, network, di)
  - features: feature-specific cubits, data, screens, widgets
  - assets: translations, icons, images, lottie, fonts
  - di: dependency injection via `core/di/injection.dart` and `getIt`

## Important entry points

- `lib/main.dart` — app bootstrap. Registers global cubits via `MultiBlocProvider`, sets theme, localization, and ScreenUtil.

## Naming & file conventions

- Feature folders under `lib/features/<feature_name>/...`
  - `cubit/` — Cubit and state files: e.g., `home_cubit.dart` and `home_state.dart`.
  - `data/` — model, repository, and data-specific code.
  - `screen/` — UI screens.
  - `widget/` — feature-level widgets.
- Shared code under `lib/core/`:
  - `ui/widgets/` — general reusable widgets (buttons, text fields, loading, errors).
  - `boilerplate/` — common widget patterns: `get_model`, `create_model`, `pagination`.
  - `usecase/` — use case contract.
  - `http/` — api provider, dio error handling.
  - `di/` — injection wiring.
  - `constant/` — theme, colors, sizes, icons, images.

## Common patterns

1. Boilerplate widgets
   - `GetModel<Model>`: creates a `GetModelCubit<Model>`, calls `getModel()` in `initState`, and builds model UI via a `modelBuilder`. Handles loading and error states.
   - `CreateModel<Model>`: wraps a tappable child, shows loading, and calls `createModel()` in cubit. Accepts callbacks for success and error.
   - `Pagination`: provides list + footer + cubit for paginated lists.

2. Widgets
   - Stateless widgets prefer composition: e.g., `CustomButton`, `TextFieldSection`, `CustomTextFormField`.
   - Visual styles pull values from: `core/constant/app_colors`, `app_text_style`, and `AppSize`.

3. Cubit pattern
   - Each cubit has a `part` file where the state is defined (e.g., `part 'home_state.dart';`).
   - Cubits emit loading / success / error states using classes like `Loading`, `Error`, `GetModelSuccessfully`, `CreateModelSuccessfully`.

4. Usecase
   - Usecase type and callback are defined in `core/usecase/usecase.dart` and used by boilerplate widgets. Usecases call repository methods and return typed results via `core/results/result.dart`.

5. DI
   - Single place for registering dependencies: `core/di/injection.dart`. Use `getIt<T>()` in `main.dart` and widgets.

## Widget inventory (selected)

Files under `lib/core/ui/widgets/` that you should reuse when adding features:
- `custom_button.dart` — configurable button with icon and rowChild override.
- `custom_text_form_field.dart` — text input with validation hooks.
- `text_field_section.dart` — labeled text field section.
- `loading.dart` — loading indicator widget.
- `general_error_widget.dart` — generic error display with retry.
- `cached_image.dart` — image helper with caching.
- `carousel_slider.dart` and `carousel_slider_new.dart` — carousel helpers.
- `tab_widget.dart`, `logo_widget.dart`, `no_data_screen.dart`, `upload.dart`, `appbar_widget.dart`, `back_widget.dart`, `back_button.dart`.

Boilerplate under `lib/core/boilerplate/`:
- `get_model/` — `GetModel`, `GetModelCubit`, `GetModelState`.
- `create_model/` — `CreateModel`, `CreateModelCubit`, `CreateModelState`.
- `pagination/` — pagination cubit and widgets.

Feature example:
- `features/home/` contains `cubit/home_cubit.dart` and `cubit/home_state.dart`.

## How to add a new feature (screen + cubit + repository + usecase)

Follow these steps to add a new feature named `foo`:

1. Create folder structure:
   - `lib/features/foo/cubit/` — `foo_cubit.dart`, `foo_state.dart`.
   - `lib/features/foo/data/` — `model/`, `repository/`, `datasource/`.
   - `lib/features/foo/screen/` — `foo_screen.dart`.
   - `lib/features/foo/widget/` — any feature-specific widgets.

2. Implement repository and data source:
   - Add `FooRepository` in `lib/features/foo/data/repository/foo_repository.dart` which uses `core/http/api_provider.dart` or `core/data_source/remote_data_source.dart`.
   - Add `foo_model.dart` in `model/` with JSON (from API) helpers.

3. Implement a Usecase:
   - Make a class in `lib/features/foo/data/usecase/` implementing `Usecase` contract from `core/usecase/usecase.dart` and call repository methods.

4. Implement Cubit and states:
   - `foo_cubit.dart` extends `Cubit<FooState>` and exposes `getFoo()` and/or `createFoo()` methods.
   - Follow existing state naming (`Loading`, `Error`, `GetModelSuccessfully`, `CreateModelSuccessfully`) or create feature-specific ones.

5. Implement the screen:
   - In `foo_screen.dart`, use `GetModel<FooModel>` with a `modelBuilder` or `CreateModel<FooModel>` for creation flows.
   - Use `CustomButton`, `TextFieldSection`, etc., for inputs and actions.
   - Use `Navigation.push()` from `core/utils/Navigation/navigation.dart` for navigation if needed.

6. Register DI:
   - Add repository and usecase bindings in `core/di/injection.dart` with `getIt.registerLazySingleton` or similar.

7. Wire to app:
   - If the feature needs a top-level cubit provided app-wide, add a `BlocProvider` to `main.dart`'s `MultiBlocProvider` using `getIt<YourCubit>()`.

## Contract examples (tiny)

- Usecase: inputs are `params` (implement `BaseParams`) and output is `Result<T>` where `Result` is from `core/results/result.dart`.
- Cubit: methods like `getModel()` emit `Loading` -> `GetModelSuccessfully(model)` or `Error(message)`.
- Widget builders: `ModelBuilder<Model> = Widget Function(Model model)`.

## Edge cases & testing

- Empty or null API data should be handled by `NoDataScreen` or `GeneralErrorWidget`.
- Network errors bubble via `Error` state — prefer showing `GeneralErrorWidget` or using `Dialogs.showSnackBar`.
- For long lists, reuse `pagination` boilerplate.

## Style and theming

- Use `AppColors`, `AppTextStyle` and `AppSize` for consistent spacing, fonts, and colors.
- Prefer `ScreenUtil` sizes like `50.h` and `AppSize.size_16` constants.

## PR checklist

- Follow folder conventions.
- Reuse boilerplate (`GetModel`, `CreateModel`, `Pagination`) where appropriate.
- Add DI registrations if new services are added.
- Add unit/widget tests for new cubits and screens (optional but recommended).

## Quick examples

- Read model pattern: see `lib/core/model/creator_model.dart`.
- Creating a button that matches app:
  - Use `CustomButton(text: 'Save', onPressed: () => cubit.save())`.

## Next steps & how I can help

- I can scaffold a new feature following these conventions (create files: cubit, state, repo, usecase, screen) if you tell me the feature name and API contract.
- I can also add unit tests and update DI wiring.

---

Generated by the assistant after inspecting `lib/` and `assets/`.
