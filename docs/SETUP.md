# Cursor + n8n Integration Setup

This guide will help you set up the integration between Cursor IDE and n8n.

## Prerequisites

- Node.js 18.17.0 or higher
- Cursor IDE
- n8n instance (cloud or self-hosted)

## Quick Start

1. **Clone this repository**
   ```bash
   git clone <your-repo-url>
   cd cursor-n8n-integration
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your n8n instance details
   ```

4. **Build the project**
   ```bash
   npm run build
   ```

## Integration Methods

### 1. MCP Integration
- Allows Cursor/Claude to execute n8n workflows directly
- Best for AI-driven automation

### 2. Development Workflow
- Use Cursor as IDE for n8n custom node development
- Best for building custom n8n nodes

### 3. API Integration
- Direct API calls from Cursor to n8n
- Best for simple automation tasks

## Next Steps

1. Choose your integration method
2. Follow the specific setup guide in the main documentation
3. Create your first workflow
4. Test the integration

For detailed instructions, see the main integration guide.
