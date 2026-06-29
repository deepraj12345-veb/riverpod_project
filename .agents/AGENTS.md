# Workspace Rules

## API Integration Strategy
- **Feature-by-Feature Implementation**: Only build models, repositories, and providers for the specific feature requested by the user. Do not generate or scaffold these layers for other features unnecessarily or prematurely. Focus strictly on what is asked (e.g., if asked for Auth API, only build Auth model, Auth provider, etc.).

## Architecture
- **Clean Architecture Principles**: Always follow strict Clean Architecture guidelines. Separate code logically into layers (Domain, Data, Presentation). Ensure that dependencies point inwards, and that UI code does not contain business logic or direct API calls. Keep the codebase modular, clean, and easily testable.
