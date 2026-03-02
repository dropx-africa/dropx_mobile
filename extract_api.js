const fs = require('fs');

const data = JSON.parse(fs.readFileSync('docs.json', 'utf8'));

const targetPaths = [
    '/me/profile',
    '/me/preferences',
    '/me/notifications',
    '/support/tickets',
    '/support/tickets/{ticket_id}',
    '/social/contacts/sync',
    '/social/feed',
    '/social/preferences'
];

let output = '# Customer Profile Endpoints\n\n';

function resolveRef(ref) {
    if (!ref) return null;
    const parts = ref.split('/');
    let current = data;
    for (let i = 1; i < parts.length; i++) {
        current = current[parts[i]];
    }
    return current;
}

function printSchema(schema, indent = '') {
    if (!schema) return '';
    if (schema.$ref) {
        const resolved = resolveRef(schema.$ref);
        return printSchema(resolved, indent);
    }

    if (schema.type === 'object' && schema.properties) {
        let result = '{\n';
        for (const [key, prop] of Object.entries(schema.properties)) {
            result += `${indent}  "${key}": ${prop.type || (prop.$ref ? resolveRef(prop.$ref).type : 'any')} // ${prop.description || ''}\n`;
        }
        result += `${indent}}`;
        return result;
    }

    if (schema.example) {
        return JSON.stringify(schema.example, null, 2).split('\n').map((line, i) => i === 0 ? line : indent + line).join('\n');
    }

    return JSON.stringify(schema, null, 2);
}

for (const p of targetPaths) {
    const pathObj = data.paths[p];
    if (!pathObj) continue;

    output += `## Path: ${p}\n\n`;

    for (const [method, details] of Object.entries(pathObj)) {
        output += `### ${method.toUpperCase()} ${p}\n`;
        output += `**Summary**: ${details.summary || details.description || ''}\n\n`;

        if (details.requestBody && details.requestBody.content && details.requestBody.content['application/json']) {
            const schema = details.requestBody.content['application/json'].schema;
            output += `**Payload (Request Body):**\n\`\`\`json\n`;
            output += printSchema(schema) + '\n';
            output += `\`\`\`\n\n`;
        } else {
            output += `**Payload (Request):** None\n\n`;
        }

        if (details.responses['200'] || details.responses['201']) {
            const successRes = details.responses['200'] || details.responses['201'];
            if (successRes.content && successRes.content['application/json']) {
                const schema = successRes.content['application/json'].schema;
                output += `**Response (Success):**\n\`\`\`json\n`;
                output += printSchema(schema) + '\n';
                output += `\`\`\`\n\n`;
            } else {
                output += `**Response:** Empty/No Body\n\n`;
            }
        }
    }
}

fs.writeFileSync('C:\\Users\\USER\\.gemini\\antigravity\\brain\\ff03ac19-4c2f-44e6-b487-30d2aace9cec\\api_customer_profile.md', output);
console.log('API extracted to api_customer_profile.md');
