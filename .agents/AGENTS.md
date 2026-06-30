# Project Rules

## API Response Formatting
When displaying API responses in the terminal, logs, or chat, ALWAYS format the data using clear ASCII borders and structured blocks (like `pretty_dio_logger`), instead of plain JSON or single continuous strings. 

Example format:
╔╣ Response ║ Status: 200 OK
╚════════════════════════════════════════════
╔ Body
║ {
║    "success": true,
║    ...
║ }
╚════════════════════════════════════════════

## Temporary Test Files
Whenever you create any temporary scripts or files solely for the purpose of testing APIs, debugging, or validation, you MUST immediately delete them once the test is complete and the issue is resolved. Do not leave temporary scripts cluttering the workspace.
