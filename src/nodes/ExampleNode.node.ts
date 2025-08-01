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
