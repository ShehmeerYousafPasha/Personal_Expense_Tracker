# Personal Expense Tracker

A Flutter application for recording daily income and expenses, reviewing monthly cash flow, and visualizing spending trends. The app is fully offline and stores data on-device.

## Overview

This project helps users:
- Create and manage expense and income transactions.
- Navigate month-by-month financial activity.
- See monthly totals (income, expense, remaining balance).
- View category-wise and multi-month chart summaries.
- Work entirely offline using local persistence.

## Core Features

### 1. Transaction Management
- Add a transaction with:
	- Type: Expense or Income
	- Amount (positive numeric value)
	- Category or income source
	- Date and time
	- Optional note
- Edit existing transactions.
- Delete transactions with a confirmation prompt.

### 2. Category Handling
- Built-in expense categories:
	- Food
	- Travel
	- Bills
	- Shopping
- Add custom categories for expenses.
- Income always uses custom source labels (for example: Salary, Freelance, Bonus).

### 3. Monthly Summary Dashboard
- Select previous/next month from the header controls.
- Automatically computes:
	- Monthly Income
	- Monthly Expense
	- Remaining Balance

### 4. Charts and Insights
- Spending by Category (Pie Chart):
	- Shows category distribution for expenses in the selected month.
- Monthly Trend (Bar Chart):
	- Shows income vs expense for a 6-month window anchored to the selected month.

### 5. Offline-First Local Persistence
- Transactions and custom categories are persisted locally.
- App data is restored on startup.
- No backend, login, or internet connection required.

## Tech Stack and Packages

### Framework
- Flutter (Material 3)

### Key Packages
- `get_storage`:
	- Lightweight key-value storage used for local persistence.
- `fl_chart`:
	- Rendering pie and bar charts for financial analytics.
- `intl`:
	- Date/time and currency formatting.
- `cupertino_icons`:
	- iOS-style icon set support.

## Architecture and State Management

This project follows a simple layered structure with local state and a persistence service.

### Folder Structure
```
lib/
	main.dart
	models/
		expense_transaction.dart
	pages/
		expense_home_page.dart
	services/
		local_store.dart
	widgets/
		transaction_form_sheet.dart
		expense_pie_chart.dart
		monthly_trend_chart.dart
```

### Architecture Style
- Presentation Layer:
	- Screen/page widgets and UI components (`pages/`, `widgets/`).
- Domain/Data Model:
	- `ExpenseTransaction` model with map serialization helpers.
- Data/Persistence Layer:
	- `LocalStore` service encapsulating all GetStorage read/write operations.

### State Management Approach
- Current state management is `StatefulWidget + setState`.
- Main screen (`ExpenseHomePage`) owns and updates in-memory state:
	- Transactions list
	- Custom category list
	- Selected month
- Derived values are computed from state:
	- Monthly income
	- Monthly expenses
	- Monthly balance
	- Filtered monthly transaction list

This is a good fit for a focused, single-screen offline app with moderate UI complexity.

## Local Storage Design

Local persistence is implemented using GetStorage in `LocalStore`.

### Storage Keys
- `transactions_v1`
- `custom_categories_v1`

### Data Encoding Strategy
- Transactions are serialized to JSON strings.
- Each transaction includes:
	- `id`
	- `amount`
	- `category`
	- `date` (ISO-8601 string)
	- `note`
	- `type` (`income` or `expense`)
- Custom categories are stored as a list of strings.

### Load/Save Flow
1. App startup initializes GetStorage in `main()`.
2. Home page reads transactions and custom categories in `initState()`.
3. Add/edit/delete operations update in-memory state and immediately persist.
4. Transactions are sorted by date descending after load and updates.

## App Flow

1. App initializes local storage.
2. Home page loads persisted data.
3. User creates/edits/deletes transactions from a bottom sheet form.
4. UI recomputes summaries/charts based on selected month and current data.
5. Data is saved locally after each mutation.

## Validation and UX Behavior

- Amount must be a valid positive integer.
- Expense transactions can use either preset or custom categories.
- Income transactions require a custom source label.
- Date and time pickers are available in the transaction form.
- Empty-state card is shown when no transactions exist for selected month.

## Getting Started

### Prerequisites
- Flutter SDK (latest stable recommended)
- Dart SDK (managed with Flutter)
- Android Studio / VS Code and a connected device/emulator

### Install Dependencies
```bash
flutter pub get
```

### Run the App
```bash
flutter run
```

### Run Tests
```bash
flutter test
```

## Build Targets

The project includes platform folders for:
- Android
- iOS
- Web
- Windows
- macOS
- Linux

## Current Limitations

- No cloud sync or cross-device backup.
- No authentication/user accounts.
- No budget goals, recurring transactions, or notifications yet.
- Current state management is local to the main page (not using Provider/GetX/BLoC).

## Possible Next Improvements

- Introduce Provider or Riverpod for scalable state management.
- Add filtering/search by category and note.
- Add budget targets and overspending alerts.
- Add export/import (CSV/JSON).
- Add recurring transaction support.

## License

This project is currently private and intended for learning and portfolio use.

## APK Link

https://www.upload-apk.com/zOk65um5km3s9rn