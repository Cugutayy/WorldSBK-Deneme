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
