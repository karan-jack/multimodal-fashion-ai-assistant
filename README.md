# multimodal-fashion-ai-assistant
AI-powered luxury fashion assistant integrating vision, speech, and live Shopify inventory.

# Overview
This project is a multimodal AI-powered luxury fashion assistant designed to enhance the online retail experience using advanced artificial intelligence. The system combines vision analysis, voice interaction, large language model reasoning, and live e-commerce inventory access into a unified workflow.
The goal of this project was to build a practical AI solution that understands outfit images, processes spoken user requests, and generates intelligent, inventory-aware fashion recommendations.

# Key Features
Image-based outfit analysis using a multimodal vision model
Real-time voice transcription
AI-driven fashion reasoning and recommendation generation
Live Shopify inventory integration
Structured JSON output to reduce hallucinations
Workflow orchestration using n8n

# Models Used
Meta LLaMA-4-Scout-17B-16E-Instruct
Used for multimodal vision analysis and interpreting outfit images.

Groq Whisper
Used for real-time speech-to-text transcription.

LLaMA-3.3-70B-Versatile
Used for advanced reasoning and generating structured fashion recommendations.

# System Architecture
User uploads an outfit image.
The vision model analyzes clothing type, colors, and style elements.
User voice input is transcribed using Whisper.
The reasoning model combines visual insights and user intent.
The system queries the Shopify Admin GraphQL API for live inventory.
Recommendations are generated in structured JSON format to ensure reliability.
The entire pipeline is orchestrated using n8n to maintain modularity and scalability.
Hallucination Prevention Strategy

# To ensure reliability and production-readiness:
Structured JSON output enforcement is implemented.
Strict prompt engineering limits model responses to verified inventory data.
Shopify inventory is queried in real time to avoid suggesting unavailable products.
This significantly reduces AI hallucination and improves recommendation accuracy.

# Tech Stack
LLaMA-4-Scout-17B-16E-Instruct (Vision + Multimodal)
Groq Whisper (Speech-to-Text)
LLaMA-3.3-70B-Versatile (Reasoning)
Shopify Admin GraphQL API
n8n (Workflow orchestration)

# Learning Outcomes
Through this project, I gained experience in:
Multimodal AI integration
Prompt engineering and structured outputs
API integration (GraphQL)
Workflow automation
Reducing hallucinations in large language models
Designing scalable AI systems for real-world applications

# Future Improvements    
Personalized style profiling
User history-based recommendations
Performance optimization for real-time scaling
Frontend interface for public deployment

# Author
Developed as an undergraduate AI project focused on applying multimodal intelligence to real-world luxury e-commerce systems.
