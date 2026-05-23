import 'package:dio/dio.dart';
import 'package:cloudwebx_pdftool/core/utils/logger.dart';

/// OpenAI API Configuration
class OpenAIConfig {
  static const String apiKey = 'YOUR_OPENAI_API_KEY';
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String model = 'gpt-4-turbo-preview';
  static const int maxTokens = 2000;
  static const double temperature = 0.7;
}

/// AI Service - OpenAI Integration
class AIService {
  late Dio _dio;

  AIService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: OpenAIConfig.baseUrl,
        headers: {
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  /// Summarize PDF content using AI
  Future<String> summarizePDF(String pdfContent) async {
    try {
      AppLogger.info('Starting AI PDF summarization');

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': OpenAIConfig.model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an expert document analyzer. Provide concise, accurate summaries.',
            },
            {
              'role': 'user',
              'content': 'Please summarize the following PDF content:\n\n$pdfContent',
            },
          ],
          'max_tokens': OpenAIConfig.maxTokens,
          'temperature': OpenAIConfig.temperature,
        },
      );

      if (response.statusCode == 200) {
        final summary =
            response.data['choices'][0]['message']['content'] as String;
        AppLogger.info('PDF summarization completed');
        return summary;
      }

      throw Exception('Failed to summarize PDF: ${response.statusCode}');
    } catch (e) {
      AppLogger.error('PDF summarization failed', e);
      rethrow;
    }
  }

  /// Explain specific PDF content
  Future<String> explainContent(String content) async {
    try {
      AppLogger.info('Starting AI content explanation');

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': OpenAIConfig.model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful assistant that explains document content in simple terms.',
            },
            {
              'role': 'user',
              'content': 'Please explain the following content:\n\n$content',
            },
          ],
          'max_tokens': OpenAIConfig.maxTokens,
          'temperature': OpenAIConfig.temperature,
        },
      );

      if (response.statusCode == 200) {
        final explanation =
            response.data['choices'][0]['message']['content'] as String;
        AppLogger.info('Content explanation completed');
        return explanation;
      }

      throw Exception('Failed to explain content: ${response.statusCode}');
    } catch (e) {
      AppLogger.error('Content explanation failed', e);
      rethrow;
    }
  }

  /// Extract key points from PDF
  Future<List<String>> extractKeyPoints(String pdfContent) async {
    try {
      AppLogger.info('Extracting key points from PDF');

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': OpenAIConfig.model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Extract the most important key points from the document. Return as a numbered list.',
            },
            {
              'role': 'user',
              'content': 'Extract key points from:\n\n$pdfContent',
            },
          ],
          'max_tokens': OpenAIConfig.maxTokens,
          'temperature': 0.5,
        },
      );

      if (response.statusCode == 200) {
        final content =
            response.data['choices'][0]['message']['content'] as String;
        final keyPoints = content
            .split('\n')
            .where((point) => point.trim().isNotEmpty)
            .toList();
        AppLogger.info('Extracted ${keyPoints.length} key points');
        return keyPoints;
      }

      throw Exception('Failed to extract key points: ${response.statusCode}');
    } catch (e) {
      AppLogger.error('Key point extraction failed', e);
      rethrow;
    }
  }

  /// Generate MCQs from PDF content
  Future<List<MCQuestion>> generateMCQs(String pdfContent,
      {int questionCount = 5}) async {
    try {
      AppLogger.info('Generating $questionCount MCQs from PDF');

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': OpenAIConfig.model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Generate multiple choice questions with 4 options each. Return as JSON array with keys: question, options (array), correct_answer (index).',
            },
            {
              'role': 'user',
              'content':
                  'Generate $questionCount MCQs from this content:\n\n$pdfContent',
            },
          ],
          'max_tokens': OpenAIConfig.maxTokens * 2,
          'temperature': 0.7,
        },
      );

      if (response.statusCode == 200) {
        final content =
            response.data['choices'][0]['message']['content'] as String;
        final questions = _parseMCQs(content);
        AppLogger.info('Generated ${questions.length} MCQs');
        return questions;
      }

      throw Exception('Failed to generate MCQs: ${response.statusCode}');
    } catch (e) {
      AppLogger.error('MCQ generation failed', e);
      return [];
    }
  }

  /// Chat with PDF - Conversational interface
  Future<String> chatWithPDF(
    String pdfContent,
    String userMessage, {
    List<ChatMessage> conversationHistory = const [],
  }) async {
    try {
      AppLogger.info('Starting PDF chat conversation');

      final messages = [
        {
          'role': 'system',
          'content':
              'You are a helpful assistant analyzing PDF documents. Answer questions based on the provided content.',
        },
        {
          'role': 'user',
          'content': 'Context from PDF:\n\n$pdfContent\n\nNow answer: $userMessage',
        },
      ];

      // Add conversation history
      for (final msg in conversationHistory) {
        messages.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.content,
        });
      }

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': OpenAIConfig.model,
          'messages': messages,
          'max_tokens': OpenAIConfig.maxTokens,
          'temperature': OpenAIConfig.temperature,
        },
      );

      if (response.statusCode == 200) {
        final reply =
            response.data['choices'][0]['message']['content'] as String;
        AppLogger.info('PDF chat response generated');
        return reply;
      }

      throw Exception('Failed to get response: ${response.statusCode}');
    } catch (e) {
      AppLogger.error('PDF chat failed', e);
      rethrow;
    }
  }

  /// Translate PDF content
  Future<String> translateContent(String content, String targetLanguage) async {
    try {
      AppLogger.info('Translating content to $targetLanguage');

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': OpenAIConfig.model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional translator. Translate the content accurately while maintaining formatting.',
            },
            {
              'role': 'user',
              'content':
                  'Translate the following text to $targetLanguage:\n\n$content',
            },
          ],
          'max_tokens': OpenAIConfig.maxTokens,
          'temperature': 0.3,
        },
      );

      if (response.statusCode == 200) {
        final translation =
            response.data['choices'][0]['message']['content'] as String;
        AppLogger.info('Translation completed');
        return translation;
      }

      throw Exception('Failed to translate: ${response.statusCode}');
    } catch (e) {
      AppLogger.error('Translation failed', e);
      rethrow;
    }
  }

  /// Helper method to parse MCQs from response
  List<MCQuestion> _parseMCQs(String response) {
    try {
      // Parse JSON response and convert to MCQuestion objects
      // This is a placeholder - actual parsing depends on API response format
      return [];
    } catch (e) {
      AppLogger.error('Failed to parse MCQs', e);
      return [];
    }
  }
}

/// MCQ Model
class MCQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  MCQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

/// Chat Message Model
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}
