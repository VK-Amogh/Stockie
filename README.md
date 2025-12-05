# Stockie - Inventory & Sales Management System

Stockie is a comprehensive inventory management application built with **Flutter**, designed to help businesses track stock, manage sales, and handle purchases efficiently.

## 🚀 Key Features

*   **Dashboard**: Real-time overview of total stock, sales, and purchases.
*   **Inventory Management**: 
    *   Add, edit, and delete products.
    *   Track expiry dates and quantities.
    *   Stock alerts (Implied).
*   **Sales & Billing**:
    *   Point of Sale (POS) interface.
    *   Invoice generation.
    *   Customer management.
*   **Purchase Management**:
    *   Log new stock entries.
    *   Vendor/Supplier management basics.
*   **Reporting**: Transaction logs and basic analytics.

## 📂 Project Structure

The codebase is organized as follows:

### `stockie_app/` (Main Application)
This is the core mobile/desktop application built with Flutter.

*   **`lib/main.dart`**: Entry point of the application.
*   **`lib/screens/`**: Contains all the UI pages (Login, Dashboard, Inventory, POS, etc.).
*   **`lib/services/`**: logic for Authentication, Database handling, and API calls.
*   **`lib/models/`**: Data models for Products, Invoices, Users, etc.
*   **`lib/theme/`**: App-wide styling, colors, and typography.
*   **`lib/utils/`**: Helper functions (e.g., Pricing Calculators, Formatters).

### Web Prototypes & Design mocks
The root directory also contains several HTML/CSS folders used for early prototyping and design concepts:
*   `inventory/`: HTML prototypes for inventory views.
*   `sale_menu/`: POS interface design concepts.
*   `stitch_home_dashboard/`: Dashboard layout experiments.
*   `add_purchase/`, `add_sale/`: Specific flow mockups.

## 🛠️ Getting Started

To run the main Stockie application:

1.  **Prerequisites**: Ensure you have [Flutter](https://flutter.dev/docs/get-started/install) installed.
2.  **Navigate to the app directory**:
    ```bash
    cd stockie_app
    ```
3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run the app**:
    ```bash
    flutter run
    ```

## 🔐 Credentials
*   **Test Account**: (If applicable, add default test credentials here for the user to know, or remove this section)

## 🤝 Contributing
1.  Fork the repository.
2.  Create a feature branch (`git checkout -b feature/amazing-feature`).
3.  Commit your changes.
4.  Push to the branch.
5.  Open a Pull Request.
