# Vendor Registration Feature

This feature allows vendors to register themselves on the platform by adding their store information, logo, brand colors, and products.

## Files Created

### 1. Model Layer
- `lib/features/vendor managment/data/model/vendor_registration_model.dart`
  - `VendorRegistrationModel`: Contains vendor information including name, tagline, description, logo, colors, and products
  - `ProductRegistrationModel`: Contains product information including title, description, price, images, and available colors
  - `ColorOption`: Represents a color option for products

### 2. Business Logic Layer (Cubit)
- `lib/features/vendor managment/cubit/v_vendor_managment_cubit.dart`
  - Manages vendor registration state
  - Handles adding/updating/removing products
  - Validates vendor data before submission
  
- `lib/features/vendor managment/cubit/v_vendor_managment_state.dart`
  - Defines all possible states for vendor registration

### 3. Presentation Layer

#### Screens
- `lib/features/vendor managment/screen/vendor_registration_screen.dart`
  - Main registration screen with vendor information form
  - Logo upload functionality
  - Brand color selection
  - Product list management

#### Widgets
- `lib/features/vendor managment/widget/add_product_dialog.dart`
  - Dialog for adding/editing products
  - Product image upload (multiple images supported)
  - Color selection for products
  - Product details form (title, description, price, category, tags)

- `lib/features/vendor managment/widget/color_picker_widget.dart`
  - Custom color picker dialog with predefined color palette
  - Used for selecting brand colors

- `lib/features/vendor managment/widget/product_card_widget.dart`
  - Displays product information in a card format
  - Shows product image, title, description, price
  - Displays available color options
  - Edit and delete functionality

## Features

### Vendor Information
- **Vendor Name** (Required): The name of the store
- **Tagline** (Required): Brief description/slogan
- **Description** (Optional): Detailed store description
- **Logo** (Required): Store logo image upload (max 5MB)

### Brand Colors
- **Primary Color**: Main brand color
- **Secondary Color**: Supporting brand color  
- **Accent Color**: Highlighting color
- Custom color picker with predefined palette

### Product Management
- **Add Products**: Add multiple products to the vendor store
- **Product Information**:
  - Title (Required)
  - Short Description (Required)
  - Full Description (Optional)
  - Price in IQD (Required)
  - Compare At Price (Optional) - for showing discounts
  - Category (Required)
  - Tags (Optional) - comma separated
  
- **Product Images**: Upload multiple product images (max 5MB each)
- **Color Options**: Add available colors for each product with custom names

## Usage

### Navigation to Registration Screen

```dart
import 'package:flutter/material.dart';
import 'package:bakeet/features/vendor managment/screen/vendor_registration_screen.dart';

// Navigate to vendor registration
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const VendorRegistrationScreen(),
  ),
);
```

### Example: Adding a Button to Home Screen

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VendorRegistrationScreen(),
      ),
    );
  },
  child: const Text('Become a Vendor'),
)
```

## Validation Rules

1. **Vendor Name**: Must not be empty
2. **Tagline**: Must not be empty
3. **Logo**: Must be uploaded
4. **Products**: At least one product must be added
5. **Product Title**: Must not be empty
6. **Product Short Description**: Must not be empty
7. **Product Price**: Must be a valid number greater than 0
8. **Product Category**: Must not be empty

## API Integration (TODO)

The cubit currently has a placeholder for API integration. To connect to your backend:

1. Create a repository in `lib/features/vendor managment/data/repository/`
2. Create use cases in `lib/features/vendor managment/data/usecase/`
3. Update the `submitVendorRegistration()` method in the cubit to call your API:

```dart
Future<void> submitVendorRegistration() async {
  emit(VendorRegistrationLoading());
  try {
    // Validation
    if (_vendorData.vendorName.isEmpty) {
      emit(VendorRegistrationError('Vendor name is required'));
      return;
    }
    // ... other validations
    
    // Call your API
    await vendorRepository.registerVendor(_vendorData);
    
    emit(VendorRegistrationSuccess('Vendor registered successfully!'));
  } catch (e) {
    emit(VendorRegistrationError(e.toString()));
  }
}
```

## Translations

Translation keys have been added to both English and Arabic:
- `assets/translations/en.json`
- `assets/translations/ar.json`

Key translations include:
- `vendor_registration`
- `become_vendor`
- `vendor_information`
- `store_logo`
- `brand_colors`
- `add_product`
- And many more...

## Screenshots Description

The vendor registration screen includes:
1. **Header Section**: Title and description
2. **Vendor Information Section**: Name, tagline, description fields
3. **Logo Upload Section**: Image upload with preview
4. **Brand Colors Section**: Three color pickers (Primary, Secondary, Accent)
5. **Products Section**: 
   - List of added products with preview cards
   - "Add Product" button
   - Each product card shows image, title, price, and colors
   - Edit and delete buttons for each product
6. **Submit Button**: At the bottom to submit the registration

## Dependencies Used

The feature uses the following existing packages:
- `flutter_bloc` - State management
- `flutter_screenutil` - Responsive design
- `image_picker` - Image selection from gallery/camera
- `file_picker` - File selection
- `dotted_border` - Upload field styling

No additional dependencies need to be added to `pubspec.yaml`.

## Notes

- All images are stored as `File` objects during registration
- The actual upload to server needs to be implemented in the repository layer
- Color values are stored as integers (ARGB format)
- The form validates all required fields before submission
- Products can be added, edited, and removed before final submission
