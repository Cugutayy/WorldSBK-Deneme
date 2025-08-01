# Cursor + n8n Integration Guide

## Overview

There are several ways to integrate Cursor with n8n, each serving different purposes:

1. **MCP (Model Context Protocol) Integration** - Allows Cursor/Claude to execute n8n workflows
2. **Development Workflow Integration** - Using Cursor as IDE for n8n custom node development
3. **API Integration** - Connecting Cursor to n8n via REST API
4. **Workflow Automation** - Using n8n to automate Cursor-related tasks

## Method 1: MCP Server Integration (Recommended)

### Prerequisites
- n8n instance (Cloud or self-hosted)
- Node.js 18.17.0+
- Cursor IDE

### Step 1: Install n8n MCP Client
```bash
# Install n8n globally if not already installed
npm install -g n8n

# Install the MCP client community node
# This will be done through n8n's community nodes interface
```

### Step 2: Create n8n MCP Server Workflow

1. **Create a new n8n workflow**
2. **Add MCP Server Trigger node**
3. **Configure webhook endpoints for Cursor communication**

Example workflow structure:
```
MCP Server Trigger → HTTP Request → Process Data → Respond to MCP Client
```

### Step 3: Configure Cursor MCP Client

Create a `.cursorrules` file in your project:

```typescript
// .cursorrules
{
  "mcp": {
    "servers": {
      "n8n": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-n8n"],
        "env": {
          "N8N_BASE_URL": "https://your-n8n-instance.com",
          "N8N_API_KEY": "your-api-key"
        }
      }
    }
  }
}
```

### Step 4: Environment Variables Setup

Create a `.env` file:
```bash
# n8n Configuration
N8N_BASE_URL=https://your-n8n-instance.com
N8N_API_KEY=your-api-key-here
N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true

# MCP Configuration
MCP_N8N_ENABLED=true
```

## Method 2: Development Workflow Integration

### Step 1: Set up Cursor for n8n Development

Install Cursor IDE extensions:
- ESLint
- EditorConfig  
- Prettier
- TypeScript

### Step 2: Create Cursor Rules for n8n Development

Create `.cursor/rules/n8n-development.mdc`:

```markdown
---
description: n8n Node Development Best Practices
globs: ["**/*.node.ts", "**/*.credentials.ts"]
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
```

### Step 3: Node Development Template

Create a starter template for new n8n nodes:

```typescript
// node-template.ts
import {
  INodeType,
  INodeTypeDescription,
  IExecuteFunctions,
  INodeExecutionData,
  IDataObject,
} from 'n8n-workflow';

export class CustomNode implements INodeType {
  description: INodeTypeDescription = {
    displayName: 'Custom Node',
    name: 'customNode',
    icon: 'file:custom.svg',
    group: ['transform'],
    version: 1,
    subtitle: '={{$parameter["operation"]}}',
    description: 'Custom node for specific operations',
    defaults: {
      name: 'Custom Node',
    },
    inputs: ['main'],
    outputs: ['main'],
    credentials: [
      {
        name: 'customApi',
        required: true,
      },
    ],
    properties: [
      {
        displayName: 'Operation',
        name: 'operation',
        type: 'options',
        noDataExpression: true,
        options: [
          {
            name: 'Process Data',
            value: 'processData',
            description: 'Process incoming data',
            action: 'Process data',
          },
        ],
        default: 'processData',
      },
    ],
  };

  async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
    const items = this.getInputData();
    const operation = this.getNodeParameter('operation', 0);
    const returnData: IDataObject[] = [];

    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      
      if (operation === 'processData') {
        // Your custom logic here
        returnData.push({
          ...item.json,
          processed: true,
          timestamp: new Date().toISOString(),
        });
      }
    }

    return [this.helpers.returnJsonArray(returnData)];
  }
}
```

## Method 3: API Integration

### Step 1: n8n Webhook Setup

Create an n8n workflow with webhook trigger:

1. **Webhook Trigger** - Set up endpoint for Cursor to call
2. **Process Request** - Handle incoming data from Cursor
3. **Execute Logic** - Run your automation
4. **Return Response** - Send results back to Cursor

### Step 2: Cursor API Client

Create a utility for calling n8n from Cursor:

```typescript
// n8n-api-client.ts
interface N8nWorkflowRequest {
  workflowId: string;
  data: any;
}

class N8nApiClient {
  private baseUrl: string;
  private apiKey: string;

  constructor(baseUrl: string, apiKey: string) {
    this.baseUrl = baseUrl;
    this.apiKey = apiKey;
  }

  async executeWorkflow(request: N8nWorkflowRequest) {
    const response = await fetch(`${this.baseUrl}/api/v1/workflows/${request.workflowId}/execute`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-N8N-API-KEY': this.apiKey,
      },
      body: JSON.stringify(request.data),
    });

    return await response.json();
  }

  async triggerWebhook(webhookUrl: string, data: any) {
    const response = await fetch(webhookUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });

    return await response.json();
  }
}

export default N8nApiClient;
```

## Method 4: Workflow Automation Examples

### Code Generation Workflow
```
Cursor Request → n8n Webhook → OpenAI → Code Generation → Format Response → Return to Cursor
```

### Database Operations
```
Cursor Command → n8n Trigger → Database Query → Data Processing → Return Results
```

### File Processing
```
File Upload → n8n Processing → AI Analysis → Generate Summary → Update Documentation
```

## Best Practices

### Security
- Use environment variables for API keys
- Implement proper authentication
- Validate all inputs
- Use HTTPS for all communications

### Performance
- Cache frequently used data
- Implement rate limiting
- Use async operations where possible
- Monitor execution times

### Monitoring
- Set up error tracking
- Log important events
- Monitor API usage
- Track workflow performance

## Troubleshooting

### Common Issues

1. **MCP Connection Failed**
   - Check n8n instance is running
   - Verify API key is correct
   - Ensure MCP server is properly configured

2. **Webhook Not Triggering**
   - Verify webhook URL is correct
   - Check n8n workflow is active
   - Ensure proper HTTP method is used

3. **Authentication Errors**
   - Verify API key permissions
   - Check credential configuration
   - Ensure proper headers are sent

### Debug Steps
1. Check n8n execution logs
2. Verify Cursor MCP configuration
3. Test API endpoints manually
4. Review error messages in detail

## Advanced Configuration

### Custom MCP Server
For advanced use cases, you can create a custom MCP server that interfaces with n8n:

```javascript
// custom-mcp-server.js
const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');

const server = new Server(
  {
    name: 'n8n-mcp-server',
    version: '0.1.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Define tools that Cursor can use
server.setRequestHandler('tools/list', async () => {
  return {
    tools: [
      {
        name: 'execute_n8n_workflow',
        description: 'Execute an n8n workflow',
        inputSchema: {
          type: 'object',
          properties: {
            workflowId: {
              type: 'string',
              description: 'The ID of the workflow to execute',
            },
            data: {
              type: 'object',
              description: 'Input data for the workflow',
            },
          },
          required: ['workflowId'],
        },
      },
    ],
  };
});

// Handle tool execution
server.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;
  
  if (name === 'execute_n8n_workflow') {
    // Execute n8n workflow logic here
    const result = await executeN8nWorkflow(args.workflowId, args.data);
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  }
  
  throw new Error(`Unknown tool: ${name}`);
});

async function executeN8nWorkflow(workflowId, data) {
  // Implementation for executing n8n workflow
  // This would interface with n8n API
}

const transport = new StdioServerTransport();
server.connect(transport);
```

## Next Steps

1. Choose the integration method that best fits your needs
2. Set up the development environment
3. Create test workflows
4. Implement error handling and monitoring
5. Scale based on usage patterns

For more detailed information, refer to:
- [n8n Documentation](https://docs.n8n.io/)
- [MCP Documentation](https://modelcontextprotocol.io/)
- [Cursor Documentation](https://cursor.sh/docs)