# CreacionesBaby 🍼✨

CreacionesBaby is a dual-platform project built with Flutter, providing:
1. **Web Storefront:** A beautiful, responsive e-commerce interface for customers to explore and purchase baby products.
2. **Mobile Admin App:** An administrative mobile application for store owners to manage the product catalog, stock, and pricing.

## Features

* **Cross-Platform:** Single codebase targeting Web (Store) and Mobile (Admin).
* **Modern UI:** Built using `outfit` and `inter` fonts with a cohesive, baby-friendly design system.
* **Real-time Data:** Integrated with Supabase/Firebase for backend services.
* **State Management:** Uses `provider` for robust, scalable state management across the app.

## Prerequisites

* Flutter SDK (compatible with v3.x)
* FVM (Flutter Version Management) - Optional but recommended
* Android Studio / Xcode (for mobile development)

## Getting Started

1. **Clone the repository**
   ```bash
   git clone git@github.com:GrullonDev/creacionesbaby.git
   cd creacionesbaby
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   * Create a `.env` file in the `backend/` directory or root based on your Supabase configuration.
   * Required keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`.

4. **Run the Web Storefront**
   ```bash
   flutter run -d chrome
   ```

5. **Run the Mobile Admin App**
   ```bash
   flutter run -d <emulator-id_or_device-id>
   ```

## CI/CD

This project uses **GitHub Actions** for Continuous Integration. On every push to `main` or PR, the pipeline will:
- Check formatting
- Run `flutter analyze`
- Run `flutter test`
- Build the web release

## Contributing

Please read the [CONTRIBUTING.md](CONTRIBUTING.md) file for details on our code of conduct, and the process for submitting pull requests to us.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
