{
  "name": "My workflow",
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "c9ad6355-e480-4404-92ed-169784b44a1e",
        "options": {}
      },
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 2.1,
      "position": [
        0,
        -144
      ],
      "id": "c8cc3b6d-d79c-435d-b2d5-c485f4a251b6",
      "name": "Webhook1",
      "webhookId": "c9ad6355-e480-4404-92ed-169784b44a1e"
    },
    {
      "parameters": {
        "resource": "table",
        "options": {
          "filterName": "",
          "sortField": "name",
          "sortDirection": "desc"
        }
      },
      "type": "n8n-nodes-base.dataTable",
      "typeVersion": 1.1,
      "position": [
        0,
        80
      ],
      "id": "c557f655-3b3d-43b6-9a37-fa9b018cf311",
      "name": "List data tables"
    },
    {
      "parameters": {
        "operation": "get",
        "dataTableId": {
          "__rl": true,
          "value": "8ffHW6zYFeOCOCgh",
          "mode": "list",
          "cachedResultName": "user_profiles",
          "cachedResultUrl": "/projects/7I8US4NTfahVV8EI/datatables/8ffHW6zYFeOCOCgh"
        },
        "filters": {
          "conditions": [
            {
              "keyName": "phone"
            }
          ]
        },
        "returnAll": true
      },
      "type": "n8n-nodes-base.dataTable",
      "typeVersion": 1.1,
      "position": [
        1792,
        624
      ],
      "id": "acb5ff5d-74e2-4f78-affd-95a8d45feb01",
      "name": "Get row(s)",
      "alwaysOutputData": true
    },
    {
      "parameters": {
        "jsCode": "const items = $input.all();\n\nconst productText = items.map(p =>\n`${p.json.title} - ₹${p.json.price}`\n).join(\"\\n\");\n\nreturn [{\n json: {\n   product_text: productText\n }\n}];\n"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        2640,
        528
      ],
      "id": "f1feedbc-63cc-4d22-92d6-5b6a9ba5aa01",
      "name": "Code in JavaScript1"
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://avotangi-luxury.myshopify.com/admin/api/2024-01/graphql.json",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "X-Shopify-Access-Token",
              "value": "*******************"
            }
          ]
        },
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "{   \"query\": \"query { products(first: 20, query: \\\"footwear\\\") { edges { node { id title handle priceRange { minVariantPrice { amount } } variants(first: 5) { edges { node { id sku title availableForSale } } } } } } }\" }",
        "options": {}
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.4,
      "position": [
        2832,
        128
      ],
      "id": "5bd611f5-5e43-470a-ba81-766333d28074",
      "name": "HTTP Request1"
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://api.groq.com/openai/v1/chat/completions",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "Authorization",
              "value": "**************************"
            }
          ]
        },
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={{\nJSON.stringify({\n  model: \"llama-3.1-8b-instant\",\n  messages: [\n    {\n      role: \"system\",\n      content: \"You are Avotangi's private luxury footwear consultant. Rank products and recommend the best matches. Return valid JSON with: recommendations: [{product_name, price, reason, confidence_score}]\"\n    },\n    {\n      role: \"user\",\n      content:\n        \"User wants minimalist luxury footwear. Available products:\\n\" +\n        $input.all().map(p =>\n          `${p.json.title} - ₹${p.json.price}`\n        ).join(\"\\n\")\n    }\n  ],\n  temperature: 0.7,\n  max_tokens: 500,\n  response_format: { type: \"json_object\" }\n})\n}}\n",
        "options": {}
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.4,
      "position": [
        3088,
        528
      ],
      "id": "103634b2-9ff3-4da8-8637-f4d5505e8c97",
      "name": "HTTP Request2"
    },
    {
      "parameters": {
        "jsCode": "const response = $input.first().json;\n\nif (!response.choices) {\n  return [{ json: { error: \"No Groq response\" } }];\n}\n\nconst content = response.choices[0].message.content;\n\nreturn [{\n json: {\n   groq_raw: content\n }\n}];\n"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        3312,
        528
      ],
      "id": "799f800a-6f35-4829-a21f-f14685d0dd14",
      "name": "Code in JavaScript2"
    },
    {
      "parameters": {
        "jsCode": "/* \n  GUCCI FORMATTER (FINAL PRODUCTION VERSION)\n*/\n\nconst groqResponse = $json.groq_raw || \"{}\";\nconst userPhone = $json.from || \"\";\n\ntry {\n\n    const data = JSON.parse(groqResponse);\n\n    const recommendations = data.recommendations || [];\n\n    let message = \"\";\n\n    // ✅ If Vision says no shoes → reject\n    if (data.reject === true) {\n\n        message = \"I appreciate your refined taste. However, I couldn't identify footwear in the image. Please share an image featuring shoes, and I will curate the perfect luxury selection for you.\";\n\n    }\n\n    // ✅ Normal recommendations\n    else if (recommendations.length > 0) {\n\n        message += \"I’ve curated a selection that aligns beautifully with your aesthetic.\\n\\n\";\n\n        for (const rec of recommendations) {\n\n            message += `👞 *${rec.product_name}*\\n`;\n\n            message += `Price: ₹${rec.price}\\n\\n`;\n\n            message += `_${rec.reasoning}_\\n\\n`;\n\n            const confidence =\n            Math.round((rec.confidence_score || 0.9) * 100);\n\n            message += `✨ Match Confidence: ${confidence}%\\n`;\n\n            message += \"------------------------------\\n\\n\";\n\n        }\n\n        message += \"Would you like to explore more options, or refine the selection further?\";\n\n    }\n\n    // ✅ No products found\n    else {\n\n        message =\n        \"I reviewed our exclusive collection, but I couldn't find the perfect match yet. Please share more details or another image for a tailored recommendation.\";\n\n    }\n\n    return [{\n\n        json: {\n\n            final_reply: message,\n\n            from: userPhone\n\n        }\n\n    }];\n\n}\n\ncatch (e) {\n\n    return [{\n\n        json: {\n\n            final_reply:\n            \"My sincere apologies — I encountered a temporary issue accessing the luxury catalog. Please try again in a moment.\",\n\n            from: userPhone\n\n        }\n\n    }];\n\n}\n"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        3536,
        528
      ],
      "id": "a1ae5890-a8df-4638-821c-63f4492b9518",
      "name": "Code in JavaScript3"
    },
    {
      "parameters": {
        "dataTableId": {
          "__rl": true,
          "value": "XmOrDTarM3sWkGKG",
          "mode": "list",
          "cachedResultName": "recommendation_history",
          "cachedResultUrl": "/projects/7I8US4NTfahVV8EI/datatables/XmOrDTarM3sWkGKG"
        },
        "columns": {
          "mappingMode": "defineBelow",
          "value": {
            "phone": "={{ $('Code in JavaScript').item.json.phone }}",
            "product_name": "={{ $('Code in JavaScript').item.json.recommendations[0].product_name }}",
            "price": "={{ $('Code in JavaScript').item.json.recommendations[0].price }}",
            "confidence_score": "={{ $('Code in JavaScript').item.json.recommendations[0].confidence_score }}",
            "recommended_at": "2026-02-12T20:53:29"
          },
          "matchingColumns": [],
          "schema": [
            {
              "id": "phone",
              "displayName": "phone",
              "required": false,
              "defaultMatch": false,
              "display": true,
              "type": "string",
              "readOnly": false,
              "removed": false
            },
            {
              "id": "product_name",
              "displayName": "product_name",
              "required": false,
              "defaultMatch": false,
              "display": true,
              "type": "string",
              "readOnly": false,
              "removed": false
            },
            {
              "id": "price",
              "displayName": "price",
              "required": false,
              "defaultMatch": false,
              "display": true,
              "type": "string",
              "readOnly": false,
              "removed": false
            },
            {
              "id": "confidence_score",
              "displayName": "confidence_score",
              "required": false,
              "defaultMatch": false,
              "display": true,
              "type": "number",
              "readOnly": false,
              "removed": false
            },
            {
              "id": "recommended_at",
              "displayName": "recommended_at",
              "required": false,
              "defaultMatch": false,
              "display": true,
              "type": "dateTime",
              "readOnly": false,
              "removed": false
            }
          ],
          "attemptToConvertTypes": false,
          "convertFieldsToString": false
        },
        "options": {}
      },
      "type": "n8n-nodes-base.dataTable",
      "typeVersion": 1.1,
      "position": [
        3984,
        528
      ],
      "id": "3dceb1e4-005e-4ecf-9436-c36a885c6128",
      "name": "Insert row",
      "retryOnFail": false,
      "onError": "continueErrorOutput"
    },
    {
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict",
            "version": 3
          },
          "conditions": [
            {
              "id": "8e6e113f-e5b5-4e5b-8006-bee2d604162a",
              "leftValue": "={{ $json.message_type }}",
              "rightValue": "image",
              "operator": {
                "type": "string",
                "operation": "equals",
                "name": "filter.operator.equals"
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "type": "n8n-nodes-base.if",
      "typeVersion": 2.3,
      "position": [
        448,
        496
      ],
      "id": "1f874d99-b650-428a-b72b-9a2560c6ff9d",
      "name": "If"
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "61f388b9-69b6-4b7e-b674-8c1a14967bfe",
              "name": "content",
              "value": "={{ $json.choices[0].message.content }}",
              "type": "string"
            },
            {
              "id": "2326907c-fc14-4435-be3a-c48ec4e9089c",
              "name": "message_type",
              "value": "text_from_image",
              "type": "string"
            }
          ]
        },
        "includeOtherFields": true,
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [
        1968,
        864
      ],
      "id": "a9be92e5-3d9a-451e-be45-6134d253c36f",
      "name": "Edit Fields"
    },
    {
      "parameters": {
        "url": "={{ $json.image_url }}",
        "options": {
          "response": {
            "response": {
              "responseFormat": "file"
            }
          }
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.4,
      "position": [
        896,
        304
      ],
      "id": "6d1192ed-29ca-499e-bd46-b46b461d9171",
      "name": "HTTP Request4",
      "alwaysOutputData": true
    },
    {
      "parameters": {
        "jsCode": "// Get binary data from the previous node\nconst items = $input.all();\nconst binaryPropertyName = 'data';\n\n// Check if binary data exists\nif (items[0].binary && items[0].binary[binaryPropertyName]) {\n  const binaryData = items[0].binary[binaryPropertyName];\n  const buffer = await this.helpers.getBinaryDataBuffer(0, binaryPropertyName);\n  \n  return [{\n    json: {\n      image_base64: buffer.toString('base64')\n    }\n  }];\n} else {\n  throw new Error('No binary data found');\n}"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1328,
        304
      ],
      "id": "4c51b50f-333e-4d08-acdc-c3d6c0e1a707",
      "name": "Code in JavaScript4"
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://api.groq.com/openai/v1/chat/completions",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "Authorization",
              "value": "**************************"
            }
          ]
        },
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={{\nJSON.stringify({\n  model: \"llama-3.3-70b-versatile\",\n  temperature: 0.4,\n  response_format: { type: \"json_object\" },\n  messages: [\n    {\n      role: \"system\",\n      content:\n        \"You are Avotangi's private luxury footwear consultant.\\n\" +\n        \"Analyze the user's request or outfit image.\\n\" +\n        \"If the image is NOT related to fashion, clothing, or outfit, politely refuse.\\n\" +\n        \"Recommend ONLY from AVAILABLE SHOES.\\n\" +\n        \"Respond ONLY in valid **json** format.\"\n    },\n    {\n      role: \"user\",\n      content:\n        \"USER REQUEST:\\n\" +\n        (\n          ($(\"Groq Vision\")?.isExecuted ? $(\"Groq Vision\").item.json.choices[0].message.content : null) ||\n          ($(\"Get row(s)\")?.isExecuted ? $(\"Get row(s)\").item.json.content : null) ||\n          ($(\"Get row(s)\")?.isExecuted ? $(\"Get row(s)\").item.json.image_description : null) ||\n          ($(\"Get row(s)\")?.isExecuted ? $(\"Get row(s)\").item.json.user_request : null) ||\n          \"Help me find luxury shoes.\"\n        ) +\n        \"\\n\\nAVAILABLE SHOES:\\n\" +\n        JSON.stringify(\n          ($(\"Shopify Search\")?.isExecuted ? $(\"Shopify Search\").item.json.data?.products?.edges : [])?.map(p => ({\n            title: p?.node?.title || \"\",\n            handle: p?.node?.handle || \"\",\n            price:\n              p?.node?.variants?.edges?.[0]?.node?.price ||\n              p?.node?.priceRange?.minVariantPrice?.amount ||\n              \"\"\n          })) || []\n        )\n    }\n  ]\n})\n}}",
        "options": {}
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.4,
      "position": [
        2384,
        528
      ],
      "id": "15d84f78-244b-4d17-ae20-ca00b6fdc3b4",
      "name": "BRAIN"
    },
    {
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict",
            "version": 3
          },
          "conditions": [
            {
              "id": "e428154f-1f7a-4d4c-ab97-08652b82c120",
              "leftValue": "={{ $json.message_type }}",
              "rightValue": "audio",
              "operator": {
                "type": "string",
                "operation": "equals",
                "name": "filter.operator.equals"
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "type": "n8n-nodes-base.if",
      "typeVersion": 2.3,
      "position": [
        672,
        592
      ],
      "id": "b45f0348-54e5-4c8e-8451-670dfd5f77bd",
      "name": "If1"
    },
    {
      "parameters": {
        "url": "https://filesamples.com/samples/audio/mp3/sample3.mp3",
        "options": {
          "response": {
            "response": {
              "responseFormat": "file"
            }
          }
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.4,
      "position": [
        880,
        736
      ],
      "id": "d4674f15-d32d-4025-b332-7cca1dd9afac",
      "name": "HTTP Request"
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "bac14fff-2f67-44b3-b170-2160223893cb",
              "name": "content",
              "value": "={{ $json.text }}",
              "type": "string"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [
        1344,
        672
      ],
      "id": "5f53ba96-8451-4b78-aea6-1b86f28b663c",
      "name": "Edit Fields1"
    },
    {
      "parameters": {
        "updates": [
          "messages"
        ],
        "options": {
          "messageStatusUpdates": [
            "all"
          ]
        }
      },
      "type": "n8n-nodes-base.whatsAppTrigger",
      "typeVersion": 1,
      "position": [
        0,
        496
      ],
      "id": "1df91428-64c8-415b-9f6d-f32f6fd51c28",
      "name": "WhatsApp Trigger",
      "webhookId": "e2bda4fe-c081-4ffb-b789-ac9e0718dc44",
      "credentials": {
        "whatsAppTriggerApi": {
          "id": "vL67qYTUJBDEGBkj",
          "name": "WhatsApp OAuth account"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "/* \n  SUPER-COLLECTOR EXTRACTOR\n*/\nconst input = $input.all()[0].json;\nconst msg = input.messages ? input.messages[0] : input;\n\n// We look for text in Text body, Image caption, OR a direct caption field\nconst userText = msg.text?.body || msg.image?.caption || msg.caption || \"\";\n\nreturn [{\n  json: {\n    message_type: msg.type || \"text\",\n    content: userText, \n    image: msg.image,\n    audio: msg.audio,\n    from: msg.from || \"919876543210\"\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        224,
        496
      ],
      "id": "2c913264-fbc6-4374-9d24-5269d3609065",
      "name": "Code in JavaScript"
    },
    {
      "parameters": {
        "operation": "send",
        "phoneNumberId": "1053563337832398",
        "recipientPhoneNumber": "+919508874742",
        "textBody": "={{ $json.final_reply }}",
        "additionalFields": {}
      },
      "type": "n8n-nodes-base.whatsApp",
      "typeVersion": 1.1,
      "position": [
        3760,
        528
      ],
      "id": "9a61e254-ae55-432b-b2df-4a1a477bb87e",
      "name": "Send message",
      "webhookId": "2e2bf8b4-8334-405b-9917-22b83af5dce4",
      "credentials": {
        "whatsAppApi": {
          "id": "Fzx5cFIKiTRpzJxK",
          "name": "WhatsApp account"
        }
      }
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://avotangi-luxury.myshopify.com/admin/api/2024-01/graphql.json",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "X-Shopify-Access-Token",
              "value": "****************************"
            },
            {
              "name": "Content-Type",
              "value": "application/json"
            }
          ]
        },
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={{\nJSON.stringify({\n  query: `{\n    products(first: 5) {\n      edges {\n        node {\n          title\n          handle\n          description\n          images(first: 1) {\n            edges {\n              node {\n                src\n              }\n            }\n          }\n          variants(first: 1) {\n            edges {\n              node {\n                price\n              }\n            }\n          }\n        }\n      }\n    }\n  }`\n})\n}}\n",
        "options": {
          "response": {
            "response": {
              "responseFormat": "json"
            }
          }
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.4,
      "position": [
        1984,
        -144
      ],
      "id": "c2bd68a9-6b41-4cfc-bb53-7e9f0ffcce59",
      "name": "Shopify Search"
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "483f1907-d8e4-42a0-b055-bc4a3ea84e6b",
              "name": "image_url",
              "value": "={{ $json.image?.link || \"https://images.unsplash.com/photo-1515372039744-b8f02a3ae446\" }}",
              "type": "string"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [
        656,
        400
      ],
      "id": "e6970332-40c3-43ea-9741-f7657b072c69",
      "name": "Edit Fields2"
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://api.groq.com/openai/v1/audio/transcriptions",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "Authorization",
              "value": "*****************************
"
            }
          ]
        },
        "sendBody": true,
        "contentType": "multipart-form-data",
        "bodyParameters": {
          "parameters": [
            {
              "name": "model",
              "value": "whisper-large-v3"
            },
            {
              "parameterType": "formBinaryData",
              "name": "file",
              "inputDataFieldName": "data"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.4,
      "position": [
        1120,
        672
      ],
      "id": "6c766af5-22fb-45f6-b967-3a3dde9442f9",
      "name": "Groq Whisper"
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://api.groq.com/openai/v1/chat/completions",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "Authorization",
              "value": "********************************"
            }
          ]
        },
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "JSON",
        "body": "={{\nJSON.stringify({\n\nmodel: \"meta-llama/llama-4-scout-17b-16e-instruct\",\n\nmessages: [\n\n{\nrole: \"system\",\n\ncontent:\n\"You are a luxury fashion stylist assistant. Describe the outfit focusing on shoe compatibility, color, and luxury aesthetic. Keep it under 30 words.\"\n\n},\n\n{\nrole: \"user\",\n\ncontent: [\n\n{\ntype: \"text\",\n\ntext:\n\"Analyze this outfit and describe the style, colors, and luxury level for recommending shoes.\"\n\n},\n\n{\n\ntype: \"image_url\",\n\nimage_url: {\n\nurl:\n\n\"data:image/jpeg;base64,\" +\n\n(\n\n$items(\"Code in JavaScript4\", 0, 0)?.[0]?.json?.image_base64\n\n|| \"\"\n\n)\n\n}\n\n}\n\n]\n\n}\n\n],\n\nmax_tokens: 150\n\n})\n}}\n",
        "options": {}
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.4,
      "position": [
        1536,
        304
      ],
      "id": "c36f1fcc-8813-4ca2-944c-4e891f376e73",
      "name": "Groq Vision"
    },
    {
      "parameters": {
        "jsCode": "/*\nFINAL PRODUCT FORMATTER\nReads Brain node safely\n*/\n\nconst input = $input.first().json;\n\n// If Brain returned recommendations JSON as string\nlet recommendations = [];\n\ntry {\n\nconst content =\ninput?.choices?.[0]?.message?.content || \"{}\";\n\nconst parsed = JSON.parse(content);\n\nrecommendations = parsed.recommendations || [];\n\n}\n\ncatch(e){\n\nrecommendations = [];\n\n}\n\n// Convert to text\nconst productText = recommendations.map(p =>\n\n`${p.product_name || p.title} - ₹${p.price || \"\"}`\n\n).join(\"\\n\");\n\nreturn [{\n\njson: {\n\nproduct_text: productText,\n\nrecommendations: recommendations\n\n}\n\n}];\n"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        2144,
        528
      ],
      "id": "4961e469-5245-4fc0-acf9-b0a9d590073b",
      "name": "Code in JavaScript5"
    },
    {
      "parameters": {
        "jsCode": "/*\nVISION OUTPUT FORMATTER\nExtracts image description safely and rejects irrelevant images\n*/\n\nconst response = $input.first().json;\n\n// Safe extraction\nconst visionText =\nresponse?.choices?.[0]?.message?.content?.trim() || \"\";\n\n// Basic validation for fashion relevance\nconst fashionKeywords = [\n  \"shoe\",\"sneaker\",\"outfit\",\"wear\",\"style\",\"fashion\",\n  \"dress\",\"jeans\",\"jacket\",\"luxury\",\"clothing\",\"boot\"\n];\n\nconst isFashionRelated = fashionKeywords.some(word =>\nvisionText.toLowerCase().includes(word)\n);\n\nlet finalDescription = \"\";\n\nif (!visionText) {\n\nfinalDescription = \"\";\n\n}\n\nelse if (!isFashionRelated) {\n\nfinalDescription =\n\"Image does not contain fashion items suitable for shoe recommendation.\";\n\n}\n\nelse {\n\nfinalDescription = visionText;\n\n}\n\nreturn [{\n\njson: {\n\nimage_description: finalDescription\n\n}\n\n}];\n"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1744,
        304
      ],
      "id": "e451cd29-eb13-43fa-a0e1-811a4c8ac617",
      "name": "Code in JavaScript Vision Output"
    },
    {
      "parameters": {
        "operation": "resize",
        "width": 800,
        "height": null,
        "options": {
          "format": "webp"
        }
      },
      "type": "n8n-nodes-base.editImage",
      "typeVersion": 1,
      "position": [
        1104,
        304
      ],
      "id": "2c752f3f-6b2c-4271-923e-cea37d2a10d4",
      "name": "Edit Image"
    }
  ],
  "pinData": {},
  "connections": {
    "Webhook1": {
      "main": [
        []
      ]
    },
    "Get row(s)": {
      "main": [
        [
          {
            "node": "Shopify Search",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Code in JavaScript1": {
      "main": [
        [
          {
            "node": "HTTP Request2",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "HTTP Request1": {
      "main": [
        []
      ]
    },
    "HTTP Request2": {
      "main": [
        [
          {
            "node": "Code in JavaScript2",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Code in JavaScript2": {
      "main": [
        [
          {
            "node": "Code in JavaScript3",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Code in JavaScript3": {
      "main": [
        [
          {
            "node": "Send message",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "If": {
      "main": [
        [
          {
            "node": "Edit Fields2",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "If1",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Edit Fields": {
      "main": [
        []
      ]
    },
    "HTTP Request4": {
      "main": [
        [
          {
            "node": "Edit Image",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Code in JavaScript4": {
      "main": [
        [
          {
            "node": "Groq Vision",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "BRAIN": {
      "main": [
        [
          {
            "node": "Code in JavaScript1",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "If1": {
      "main": [
        [
          {
            "node": "HTTP Request",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Get row(s)",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "HTTP Request": {
      "main": [
        [
          {
            "node": "Groq Whisper",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Edit Fields1": {
      "main": [
        [
          {
            "node": "Get row(s)",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "WhatsApp Trigger": {
      "main": [
        [
          {
            "node": "Code in JavaScript",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Code in JavaScript": {
      "main": [
        [
          {
            "node": "If",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Send message": {
      "main": [
        [
          {
            "node": "Insert row",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Shopify Search": {
      "main": [
        [
          {
            "node": "Code in JavaScript5",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Edit Fields2": {
      "main": [
        [
          {
            "node": "HTTP Request4",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Groq Whisper": {
      "main": [
        [
          {
            "node": "Edit Fields1",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Groq Vision": {
      "main": [
        [
          {
            "node": "Code in JavaScript Vision Output",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Code in JavaScript5": {
      "main": [
        [
          {
            "node": "BRAIN",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Code in JavaScript Vision Output": {
      "main": [
        [
          {
            "node": "Get row(s)",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Edit Image": {
      "main": [
        [
          {
            "node": "Code in JavaScript4",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "active": true,
  "settings": {
    "executionOrder": "v1",
    "binaryMode": "separate",
    "availableInMCP": false,
    "timeSavedMode": "fixed",
    "callerPolicy": "workflowsFromSameOwner"
  },
  "versionId": "0287f4b5-8458-4ce8-9eb7-55485b283984",
  "meta": {
    "templateCredsSetupCompleted": true,
    "instanceId": "7cb449c3a6026a1c94e5930cfe229545d4d8e033568335cd081e05d7f282fedc"
  },
  "id": "cExxb6aRw0pVOc78fuRoa",
  "tags": []
}
