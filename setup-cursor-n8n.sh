#!/bin/bash

# Cursor + n8n Integration Setup Script
echo "🚀 Setting up Cursor + n8n Integration..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18.17.0+ first."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2)
REQUIRED_VERSION="18.17.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "❌ Node.js version $NODE_VERSION is too old. Please update to $REQUIRED_VERSION or higher."
    exit 1
fi

echo "✅ Node.js version $NODE_VERSION is compatible"

# Install n8n globally if not already installed
if ! command -v n8n &> /dev/null; then
    echo "📦 Installing n8n globally..."
    npm install -g n8n
else
    echo "✅ n8n is already installed"
fi

# Create project directory structure
echo "📁 Creating project directory structure..."

mkdir -p .cursor/rules
mkdir -p src/nodes
mkdir -p src/credentials
mkdir -p src/utils
mkdir -p docs

# Create Cursor rules for n8n development
echo "📝 Creating Cursor rules for n8n development..."

cat > .cursor/rules/n8n-development.mdc << 'EOF'
---
description: n8n Node Development Best Practices
globs: ["**/*.node.ts", "**/*.credentials.ts", "src/**/*.ts"]
alwaysApply: true
---

# n8n Node Development Guidelines

Use these guidelines when developing n8n nodes:

1. **Node Structure**:
   - Use declarative-style for simple nodes
   - Use programmatic-style for complex logic
   - Follow n8n's file naming conventions

2. **TypeScript Best Practices**:
   - Implement INodeType interface
   - Use proper typing for node parameters
   - Define clear input/output schemas

3. **Error Handling**:
   - Use NodeApiError for API-related errors
   - Implement proper error messages
   - Handle rate limiting appropriately

4. **Testing**:
   - Write unit tests for execute methods
   - Test credential validation
   - Verify parameter handling

5. **Documentation**:
   - Include clear node descriptions
   - Document all parameters
   - Provide usage examples

6. **Code Quality**:
   - Use consistent naming conventions
   - Add proper TypeScript types
   - Follow n8n's coding standards
   - Include JSDoc comments for complex functions
EOF

# Create global Cursor rules
cat > .cursor/rules/global.mdc << 'EOF'
---
description: Global development guidelines for Cursor + n8n project
globs: ["**/*"]
alwaysApply: true
---

# Global Development Guidelines

1. **File Organization**:
   - Keep related files together
   - Use descriptive file names
   - Maintain consistent directory structure

2. **Code Style**:
   - Use TypeScript for type safety
   - Follow consistent formatting
   - Add meaningful comments

3. **Security**:
   - Never commit API keys or secrets
   - Use environment variables for configuration
   - Validate all inputs

4. **Documentation**:
   - Update README for significant changes
   - Document complex workflows
   - Include setup instructions
EOF

# Create environment variables template
echo "🔧 Creating environment configuration..."

cat > .env.example << 'EOF'
# n8n Configuration
N8N_BASE_URL=https://your-n8n-instance.com
N8N_API_KEY=your-api-key-here
N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true

# MCP Configuration
MCP_N8N_ENABLED=true

# Development Configuration
NODE_ENV=development
EOF

# Create package.json for node development
echo "📦 Creating package.json..."

cat > package.json << 'EOF'
{
  "name": "cursor-n8n-integration",
  "version": "1.0.0",
  "description": "Integration between Cursor IDE and n8n workflow automation",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "jest",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write src/**/*.ts"
  },
  "keywords": ["n8n", "cursor", "automation", "workflow"],
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "@types/node": "^18.0.0",
    "@typescript-eslint/eslint-plugin": "^5.0.0",
    "@typescript-eslint/parser": "^5.0.0",
    "eslint": "^8.0.0",
    "jest": "^29.0.0",
    "prettier": "^2.8.0",
    "typescript": "^4.9.0"
  },
  "dependencies": {
    "n8n-workflow": "latest",
    "n8n-core": "latest"
  }
}
EOF

# Create TypeScript configuration
echo "⚙️ Creating TypeScript configuration..."

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF

# Create ESLint configuration
echo "🔍 Creating ESLint configuration..."

cat > .eslintrc.js << 'EOF'
module.exports = {
  parser: '@typescript-eslint/parser',
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
  ],
  plugins: ['@typescript-eslint'],
  env: {
    node: true,
    es6: true,
  },
  rules: {
    '@typescript-eslint/no-unused-vars': 'error',
    '@typescript-eslint/explicit-function-return-type': 'warn',
    'no-console': 'warn',
  },
};
EOF

# Create Prettier configuration
echo "💅 Creating Prettier configuration..."

cat > .prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
EOF

# Create .cursorignore
echo "🚫 Creating .cursorignore..."

cat > .cursorignore << 'EOF'
# Dependencies
node_modules/
dist/
build/

# Logs
*.log
logs/

# Environment variables
.env
.env.local
.env.production

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Package locks (keep package.json)
package-lock.json
yarn.lock

# Coverage reports
coverage/

# Temporary files
*.tmp
*.temp
EOF

# Create basic n8n node template
echo "🎯 Creating n8n node template..."

mkdir -p src/nodes
cat > src/nodes/ExampleNode.node.ts << 'EOF'
import {
  INodeType,
  INodeTypeDescription,
  IExecuteFunctions,
  INodeExecutionData,
  IDataObject,
} from 'n8n-workflow';

export class ExampleNode implements INodeType {
  description: INodeTypeDescription = {
    displayName: 'Example Node',
    name: 'exampleNode',
    icon: 'file:example.svg',
    group: ['transform'],
    version: 1,
    subtitle: '={{$parameter["operation"]}}',
    description: 'Example node for Cursor + n8n integration',
    defaults: {
      name: 'Example Node',
    },
    inputs: ['main'],
    outputs: ['main'],
    properties: [
      {
        displayName: 'Operation',
        name: 'operation',
        type: 'options',
        noDataExpression: true,
        options: [
          {
            name: 'Transform Data',
            value: 'transform',
            description: 'Transform incoming data',
            action: 'Transform data',
          },
          {
            name: 'Process Text',
            value: 'processText',
            description: 'Process text data',
            action: 'Process text',
          },
        ],
        default: 'transform',
      },
      {
        displayName: 'Message',
        name: 'message',
        type: 'string',
        default: '',
        placeholder: 'Enter your message',
        description: 'The message to process',
        displayOptions: {
          show: {
            operation: ['processText'],
          },
        },
      },
    ],
  };

  async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
    const items = this.getInputData();
    const operation = this.getNodeParameter('operation', 0);
    const returnData: IDataObject[] = [];

    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      
      if (operation === 'transform') {
        returnData.push({
          ...item.json,
          processed: true,
          timestamp: new Date().toISOString(),
          processedBy: 'Cursor + n8n Integration',
        });
      } else if (operation === 'processText') {
        const message = this.getNodeParameter('message', i) as string;
        returnData.push({
          ...item.json,
          originalMessage: message,
          processedMessage: message.toUpperCase(),
          messageLength: message.length,
          timestamp: new Date().toISOString(),
        });
      }
    }

    return [this.helpers.returnJsonArray(returnData)];
  }
}
EOF

# Create API client utility
echo "🔌 Creating n8n API client..."

mkdir -p src/utils
cat > src/utils/n8nApiClient.ts << 'EOF'
interface N8nWorkflowRequest {
  workflowId: string;
  data: any;
}

interface N8nApiConfig {
  baseUrl: string;
  apiKey: string;
}

export class N8nApiClient {
  private config: N8nApiConfig;

  constructor(config: N8nApiConfig) {
    this.config = config;
  }

  async executeWorkflow(request: N8nWorkflowRequest): Promise<any> {
    const response = await fetch(
      `${this.config.baseUrl}/api/v1/workflows/${request.workflowId}/execute`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-N8N-API-KEY': this.config.apiKey,
        },
        body: JSON.stringify(request.data),
      }
    );

    if (!response.ok) {
      throw new Error(`n8n API error: ${response.status} ${response.statusText}`);
    }

    return await response.json();
  }

  async triggerWebhook(webhookUrl: string, data: any): Promise<any> {
    const response = await fetch(webhookUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      throw new Error(`Webhook error: ${response.status} ${response.statusText}`);
    }

    return await response.json();
  }

  async getWorkflows(): Promise<any[]> {
    const response = await fetch(`${this.config.baseUrl}/api/v1/workflows`, {
      headers: {
        'X-N8N-API-KEY': this.config.apiKey,
      },
    });

    if (!response.ok) {
      throw new Error(`n8n API error: ${response.status} ${response.statusText}`);
    }

    const data = await response.json();
    return data.data || [];
  }
}

export default N8nApiClient;
EOF

# Create documentation
echo "📚 Creating documentation..."

cat > docs/SETUP.md << 'EOF'
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
EOF

# Create README update
echo "📝 Updating README..."

cat > README_CURSOR_N8N.md << 'EOF'
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
EOF

echo ""
echo "🎉 Setup complete! Here's what was created:"
echo ""
echo "📁 Directory Structure:"
echo "   ├── .cursor/rules/           # Cursor rules for n8n development"
echo "   ├── src/nodes/              # n8n node templates"
echo "   ├── src/utils/              # API client utilities"
echo "   ├── docs/                   # Documentation"
echo "   ├── package.json            # Node.js dependencies"
echo "   ├── tsconfig.json           # TypeScript configuration"
echo "   ├── .env.example            # Environment variables template"
echo "   └── cursor-n8n-integration-guide.md  # Complete integration guide"
echo ""
echo "🚀 Next Steps:"
echo "   1. Copy .env.example to .env and configure your n8n settings"
echo "   2. Run 'npm install' to install dependencies"
echo "   3. Read the integration guide: cursor-n8n-integration-guide.md"
echo "   4. Choose your integration method (MCP recommended)"
echo "   5. Start building your automation!"
echo ""
echo "📖 Documentation:"
echo "   - Main guide: cursor-n8n-integration-guide.md"
echo "   - Setup: docs/SETUP.md"
echo "   - Project README: README_CURSOR_N8N.md"
echo ""
echo "Happy automating! 🤖✨"