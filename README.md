# Personal Expense Tracker

A simple Flutter app to help users track where their money goes.

## Features

### Add Transactions
- Add both income and expense entries
- Required fields: amount, category, date
- Optional field: note

### Categories
- Predefined categories: Food, Travel, Bills, Shopping
- Optional custom categories can be added while creating transactions

### Edit and Delete
- Edit any existing transaction
- Delete any transaction with confirmation

### Monthly Summary
- Total income for selected month
- Total expenses for selected month
- Remaining balance for selected month

### Basic Charts
- Pie chart for category-wise expense distribution (monthly)
- Monthly trend chart for income vs expense

### Local Storage (Offline)
- Data is stored locally using GetStorage
- No internet required

## Tech Stack
- Flutter
- GetStorage for local persistence
- fl_chart for visualizations
- intl for date and currency formatting

## Run the App

1. Install dependencies:
	flutter pub get
2. Launch app:
	flutter run
