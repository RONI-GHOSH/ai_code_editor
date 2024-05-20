# AI Code Editor and Compiler

Welcome to the AI Code Editor and Compiler! This is an online code editor with an integrated compiler and AI assistant feature. It's built using Flutter and leverages a remote compiler API along with the free Gemini API for AI assistance. This project is currently in its early stages but serves as a great starting point for those looking to understand API requests, BLoC architecture in Flutter, and response parsing.

## Features

- **Online Code Editing**: Write and edit code in a user-friendly online editor.
- **Remote Compilation**: Compile your code using a remote compiler API.
- **AI Assistant**: Get assistance and suggestions from the AI assistant powered by the Gemini API.
- **BLoC Architecture**: Implements BLoC (Business Logic Component) architecture in Flutter for state management.

## Getting Started

### Prerequisites

- Flutter SDK: [Installation Guide](https://flutter.dev/docs/get-started/install)
- Git: [Download and Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/RONI-GHOSH/ai_code_editor.git
   ```
2. Navigate to the project directory:
   ```bash
   cd ai_code_editor
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Usage

1. Open the app in your preferred device or emulator.
2. Write your code in the editor.
3. Click the "Compile" button to send the code to the remote compiler API and get the output.
4. Use the AI assistant feature to get code suggestions and help.

## Project Structure

- `lib/`: Contains the main Flutter code.
  - `bloc/`: Contains the BLoC components for state management.
  - `models/`: Contains data models.
  - `screens/`: Contains the UI screens.
  - `services/`: Contains services for API calls.
  - `widgets/`: Contains reusable widgets.
- `assets/`: Contains static assets like images and fonts.

## Contributing

Contributions are welcome! If you'd like to improve the project, please follow these steps:

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes and commit them:
   ```bash
   git commit -m 'Add some feature'
   ```
4. Push to the branch:
   ```bash
   git push origin feature/your-feature-name
   ```
5. Open a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgements

- Thanks to the developers of Flutter and the various open-source libraries used in this project.
- Special thanks to the providers of the remote compiler API and Gemini API.

## Contact

If you have any questions or feedback, feel free to open an issue or contact me via [GitHub](https://github.com/RONI-GHOSH).

---

Thank you for checking out the AI Code Editor and Compiler! Your contributions and feedback are highly appreciated. Happy coding!

