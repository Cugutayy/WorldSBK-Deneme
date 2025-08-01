# Cursor + n8n Integration Project

This project demonstrates how to integrate Cursor IDE with n8n workflow automation platform.

## What's Included

- **Complete integration guide** with multiple methods
- **Ready-to-use templates** for n8n node development
- **API client utilities** for n8n integration
- **Cursor rules** optimized for n8n development
- **Example workflows** and automation patterns

## Quick Start

1. Run the setup script:
   ```bash
   chmod +x setup-cursor-n8n.sh
   ./setup-cursor-n8n.sh
   ```

2. Configure your environment:
   ```bash
   cp .env.example .env
   # Edit .env with your n8n details
   ```

3. Install dependencies:
   ```bash
   npm install
   ```

4. Start developing:
   ```bash
   npm run dev
   ```

## Integration Methods

### 🔌 MCP Integration (Recommended)
Create an MCP server that allows Cursor/Claude to execute n8n workflows directly.

### 🛠️ Development Workflow
Use Cursor as your IDE for developing custom n8n nodes with optimized rules and templates.

### 🌐 API Integration
Connect Cursor to n8n via REST API for simple automation tasks.

### 🤖 Workflow Automation
Use n8n to automate Cursor-related tasks and development workflows.

## Documentation

- [Complete Integration Guide](cursor-n8n-integration-guide.md)
- [Setup Instructions](docs/SETUP.md)
- [API Reference](docs/API.md)
- [Examples](docs/EXAMPLES.md)

## Project Structure

```
.
├── .cursor/rules/          # Cursor IDE rules for n8n development
├── src/
│   ├── nodes/             # Custom n8n nodes
│   ├── credentials/       # n8n credentials
│   └── utils/            # Utility functions
├── docs/                 # Documentation
└── examples/             # Example workflows
```

## Features

✅ MCP server integration  
✅ Custom node templates  
✅ API client utilities  
✅ Development workflows  
✅ Error handling  
✅ Type safety  
✅ Testing setup  
✅ Documentation  

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details.
