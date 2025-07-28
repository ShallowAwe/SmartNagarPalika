# HomeScreen Documentation

## Overview
The `HomeScreen` is the main landing page of the Smart Nagarpalika application. It serves as the central hub where users can access various municipal services and view important information.

## File Location
`lib/Screens/homeScreen.dart`

## Class Structure
- **Class Name**: `HomeScreen`
- **Type**: StatefulWidget
- **State Class**: `_HomeScreenState`

## Features

### 1. Top Container
- Displays the main header section
- Uses the `TopContainer` widget for consistent branding
- Provides app title and user information

### 2. News Section
- Horizontal scrolling news cards
- Uses `Horizantalnewscard` widget
- Displays latest municipal updates and announcements

### 3. Quick Services Grid
- Grid layout of frequently used services
- Uses `ServiceGridSection` with `quickServices` data
- Provides easy access to common municipal services

### 4. Popular Services Grid
- Secondary grid of popular municipal services
- Uses `ServiceGridSection` with `popularServices` data
- Features services that are commonly accessed by users

### 5. Bottom Navigation
- Fixed bottom navigation bar
- Uses `BottomNavbar` widget
- Height: 96 pixels
- Tracks navigation state with `_isNearmeSelected` boolean

## Dependencies

### Internal Dependencies
- `package:smart_nagarpalika/Data/gridData.dart` - Service data
- `package:smart_nagarpalika/Services/servicesGridSection.dart` - Service grid widget
- `package:smart_nagarpalika/utils/bottomNavBar.dart` - Bottom navigation
- `package:smart_nagarpalika/utils/topContainer.dart` - Top header container
- `package:smart_nagarpalika/widgets/horizantalNewsCard.dart` - News cards

### External Dependencies
- `package:flutter/material.dart` - Flutter UI framework

## State Management
- Uses `StatefulWidget` for local state management
- `_isNearmeSelected` boolean tracks navigation state
- No complex state management required for this screen

## UI Layout Structure
```
Scaffold
├── SingleChildScrollView
│   └── Column
│       ├── TopContainer
│       ├── SizedBox (16px spacing)
│       ├── Horizantalnewscard
│       ├── SizedBox (20px spacing)
│       ├── ServiceGridSection (Quick Services)
│       ├── SizedBox (24px spacing)
│       ├── ServiceGridSection (Popular Services)
│       └── SizedBox (20px bottom padding)
└── BottomNavigationBar
    └── BottomNavbar
```

## Key Methods

### build(BuildContext context)
- Main build method that constructs the UI
- Returns a `Scaffold` with scrollable content
- Manages layout spacing and widget hierarchy

## Design Patterns
- **Single Responsibility**: Each section has a dedicated widget
- **Composition**: Uses multiple smaller widgets to build the screen
- **Consistent Spacing**: Uses standardized spacing values (16px, 20px, 24px)

## Accessibility Features
- Scrollable content for different screen sizes
- Clear visual hierarchy with proper spacing
- Touch-friendly button sizes in service grids

## Performance Considerations
- Uses `SingleChildScrollView` for efficient scrolling
- Lazy loading of service grids
- Minimal state updates

## Future Enhancements
- Add pull-to-refresh functionality
- Implement service search functionality
- Add user preferences for service ordering
- Include personalized content based on user history

## Related Files
- `lib/Data/gridData.dart` - Service definitions
- `lib/Services/servicesGridSection.dart` - Service grid implementation
- `lib/utils/bottomNavBar.dart` - Navigation implementation
- `lib/utils/topContainer.dart` - Header implementation
- `lib/widgets/horizantalNewsCard.dart` - News card implementation 