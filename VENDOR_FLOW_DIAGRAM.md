# Vendor Registration Flow - Quick Reference

## Visual Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    VENDOR REGISTRATION SCREEN                    │
│                                                                   │
│  • Fill vendor name, tagline, description                        │
│  • Upload logo                                                   │
│  • Choose brand colors (Primary, Secondary, Accent)              │
│  • Add products with images and prices                           │
│                                                                   │
│                 [Submit Registration Button]                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ submitVendorRegistration()
                             │ • Validates data
                             │ • Creates preview models
                             │ • Does NOT save to database
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                  STOREFRONT PREVIEW SCREEN 🆕                    │
│                                                                   │
│  ╔═══════════════════════════════════════════════════════════╗  │
│  ║ ℹ️  PREVIEW MODE                                           ║  │
│  ║  This is how your storefront will look.                    ║  │
│  ║  Review and approve to publish.                            ║  │
│  ╚═══════════════════════════════════════════════════════════╝  │
│                                                                   │
│            ┌──────────────────────────────┐                      │
│            │      [Your Logo Image]       │                      │
│            └──────────────────────────────┘                      │
│                   Your Vendor Name                               │
│                   Your Tagline Text                              │
│                                                                   │
│            🔴 Primary  🟠 Secondary  🟡 Accent                   │
│                                                                   │
│  ┌─────────────┬─────────────┬─────────────┬─────────────┐      │
│  │  Product 1  │  Product 2  │  Product 3  │  Product 4  │      │
│  │  [Image]    │  [Image]    │  [Image]    │  [Image]    │      │
│  │  $99        │  $149       │  $79        │  $199       │      │
│  └─────────────┴─────────────┴─────────────┴─────────────┘      │
│                                                                   │
│  [ Cancel ]              [ ✓ Approve & Publish ]                 │
└────────────┬──────────────────────────┬─────────────────────────┘
             │                          │
             │ Cancel                   │ Approve
             │                          │
             ▼                          ▼
┌──────────────────────┐   ┌────────────────────────────────────┐
│  Return to           │   │  Confirmation Dialog:              │
│  Registration        │   │  "Are you sure you want to         │
│  (No changes saved)  │   │   approve and publish?"            │
└──────────────────────┘   │                                    │
                           │  [Cancel]  [✓ Approve]             │
                           └──────────┬─────────────────────────┘
                                      │
                                      │ Confirmed
                                      │
                                      ▼
                           ┌─────────────────────────────────────┐
                           │ approveAndPublishVendor()           │
                           │ • Saves vendor to database          │
                           │ • Saves all products to database    │
                           │ • Emits VendorPublished state       │
                           └──────────┬──────────────────────────┘
                                      │
                                      ▼
                           ┌─────────────────────────────────────┐
                           │  LIVE STOREFRONT SCREEN             │
                           │                                     │
                           │  ✅ Vendor is now published         │
                           │  ✅ Visible to all customers        │
                           │  ✅ Products are available          │
                           └─────────────────────────────────────┘
```

## Key States

### 1. VendorRegistrationLoading
- Shown during validation and preview preparation
- Shown during actual publish operation

### 2. VendorRegistrationSuccess
```dart
{
  message: "Review your storefront",
  vendorId: "vendor_1234567890",
  vendorData: {...},      // Original form data
  vendor: {...},          // Preview vendor model
  products: [...]         // Preview product models
}
```

### 3. VendorPublished
```dart
{
  message: "Vendor published successfully!",
  vendorId: "vendor_1234567890"
}
```

## User Actions

| Action | From Screen | Result |
|--------|-------------|--------|
| Fill form & Submit | Registration | Navigate to Preview |
| Click "Cancel" | Preview | Return to Registration (nothing saved) |
| Click "Approve & Publish" | Preview | Show confirmation dialog |
| Confirm approval | Dialog | Publish vendor & navigate to Storefront |
| Cancel approval | Dialog | Stay in Preview |

## Benefits for Your Users

✅ **See before publish** - Know exactly how the storefront looks
✅ **Catch mistakes** - Fix errors before going live
✅ **Build confidence** - Users feel more in control
✅ **Professional workflow** - Matches industry standards
✅ **No accidental publishes** - Extra confirmation step

## What Happens Behind the Scenes

### On Submit (Old Way) ❌
```
Form → Validate → Save to DB → Navigate to Storefront
                  ⚠️ Immediately visible to customers
```

### On Submit (New Way) ✅
```
Form → Validate → Create Preview Models → Show Preview Screen
                                             ↓
                              User reviews and approves
                                             ↓
                              Save to DB → Navigate to Storefront
                              ✅ Only visible after approval
```

## Code Example - How to Use

The implementation is transparent to other parts of the code. Just use as before:

```dart
// In your UI
CustomButton(
  text: 'Submit Registration',
  onPressed: () {
    if (_formKey.currentState!.validate()) {
      // This now triggers preview flow automatically
      context.read<VVendorManagmentCubit>().submitVendorRegistration();
    }
  },
)
```

The BLoC listener handles everything else automatically! 🎉
