# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LVault is an iOS personal finance management app built with SwiftUI and Core Data. The app helps users track their finances through a hierarchical structure of Vaults → Chests → Transactions, with support for transaction labeling and reporting.

## Development Commands

### Building
- **Development build**: Open `lvault-ios.xcodeproj` in Xcode and select the "lvault-ios DEV" scheme
- **Production build**: Select the "lvault-ios" scheme in Xcode
- Build using Cmd+B or Product → Build

### Running
- **Development**: Use "lvault-ios DEV" scheme (creates app named "Vault DEV" with bundle ID `com.lostaf.lvault-ios.dev`)
- **Production**: Use "lvault-ios" scheme (creates app named "Vault" with bundle ID `com.lostaf.lvault-ios`)

### Testing
- **Unit tests**: Run the `lvault-iosTests` target
- **UI tests**: Run the `lvault-iosUITests` target
- Tests can be run via Xcode Test Navigator or Cmd+U

## Architecture

### High-Level Structure
The app follows a clean architecture pattern with clear separation of concerns:

```
Domain (Entities) ← Interactors ← Views
     ↓
Data (Repositories) ← Persistence (Core Data)
```

### Key Architectural Components

**Dependency Injection (`DI/DIContainer.swift`)**
- `DI.shared`: Production container with real implementations
- `DI.preview`: Preview container with stub data for SwiftUI previews
- Manages all interactor and repository dependencies

**Data Layer**
- Uses CoreStore (wrapper around Core Data) for persistence
- Database migrations handled through versioned schemas (V1, V2)
- Repository pattern abstracts data access from business logic
- Stub implementations available for testing/previews

**Domain Entities**
- `Vault`: Top-level financial containers
- `Chest`: Sub-containers within vaults (e.g., checking account, savings)
- `Transaction`: Individual financial transactions
- `TransactionLabel`: Categorization system for transactions

**Interactors (Business Logic)**
- `VaultInteractor`: Vault management operations
- `ChestInteractor`: Chest operations (requires parent vault)
- `TransactionInteractor`: Transaction CRUD (requires parent chest)
- `TransactionLabelInteractor`: Label management
- `ReportInteractor`: Financial reporting and analytics

### View Architecture
- SwiftUI with MVVM pattern
- Main navigation through `TabView` with 4 sections:
  - **Home**: Vault/Chest/Transaction management
  - **Manage**: Transaction label administration
  - **Reports**: Financial analytics and reports
  - **Settings**: App configuration

### Configuration
- Separate xcconfig files for DEV and Production environments
- DEV configuration uses simulator-specific local auth stubs
- Production uses actual local authentication on device

### Key Dependencies
- **CoreStore**: Core Data wrapper for database operations
- Uses Swift Package Manager for dependency management

## Development Notes

### Local Authentication
- Production builds use biometric authentication
- Simulator builds automatically use stub authentication (never fails)
- Authentication errors are handled with dedicated error screens

### Data Persistence
- In-memory storage for previews and testing
- SQLite storage for production
- Database initialization includes automatic example data for in-memory stores

### Error Handling
- Custom `LVaultError` enum for app-specific errors
- `Loadable<T>` wrapper for async operations with loading/error states
- Dedicated error screens for startup and authentication failures