import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../state/auth_provider.dart';
import '../../widgets/vg/vg_ui.dart';

class AiKnowledgeScreen extends StatefulWidget {
  const AiKnowledgeScreen({super.key});

  @override
  State<AiKnowledgeScreen> createState() => _AiKnowledgeScreenState();
}

class _AiKnowledgeScreenState extends State<AiKnowledgeScreen> {
  bool _loading = true;
  bool _uploading = false;
  String? _errorMessage;

  Map<String, dynamic>? _knowledgeData;

  @override
  void initState() {
    super.initState();
    _fetchKnowledgeStatus();
  }

  Future<void> _fetchKnowledgeStatus() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final data = await auth.apiClient.get('/ai/knowledge');
      if (data != null && data is Map<String, dynamic>) {
        setState(() {
          _knowledgeData = data;
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Format data status tidak valid.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat status AI: $e';
        _loading = false;
      });
    }
  }

  Future<void> _pickAndUploadDocument() async {
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt', 'md'],
      );

      if (picked.isEmpty) return;

      final file = picked.first;

      setState(() {
        _uploading = true;
      });

      final auth = Provider.of<AuthProvider>(context, listen: false);
      final bytes = await file.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: file.name),
      });

      await auth.apiClient.postForm(
        '/ai/knowledge',
        formData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF22A447),
            content: Text('Dokumen berhasil diunggah dan diindeks ke dalam AI!'),
          ),
        );
      }

      await _fetchKnowledgeStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text('Gagal mengunggah dokumen: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  Future<void> _rebuildIndexManual() async {
    setState(() {
      _uploading = true;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.apiClient.post('/ai/build-index');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF22A447),
            content: Text('Indeks vektor AI berhasil disinkronkan ulang!'),
          ),
        );
      }
      await _fetchKnowledgeStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text('Gagal memperbarui indeks: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case '.pdf':
        return Icons.picture_as_pdf_rounded;
      case '.docx':
      case '.doc':
        return Icons.description_rounded;
      case '.md':
      case '.txt':
      default:
        return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final files = (_knowledgeData?['files'] as List<dynamic>?) ?? [];
    final totalChunks = _knowledgeData?['total_chunks_indexed'] ?? 0;
    final chatModel = _knowledgeData?['chat_model'] ?? 'gemini-3.5-flash-lite';
    final embeddingModel = _knowledgeData?['embedding_model'] ?? 'gemini-embedding-001';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const VgBackBar(title: 'Knowledge Base AI (RAG)'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchKnowledgeStatus,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Status Summary Card
                  VgCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.psychology_rounded, color: AppColors.primary, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Status Model AI',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            VgPill(
                              label: _knowledgeData?['index_exists'] == true ? 'Aktif' : 'Perlu Diindeks',
                              color: _knowledgeData?['index_exists'] == true ? const Color(0xFF22A447) : AppColors.danger,
                              background: _knowledgeData?['index_exists'] == true ? const Color(0xFFE8F7ED) : AppColors.dangerBg,
                              fontSize: 11,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        VgInset(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(value: '${files.length}', label: 'Dokumen'),
                              Container(height: 30, width: 1, color: Colors.black12),
                              _StatItem(value: '$totalChunks', label: 'Vektor Chunks'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Model: $chatModel • Embed: $embeddingModel',
                          style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Card: Upload & Sync
                  VgCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tambah Pengetahuan Baru',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Unggah dokumen SOP, panduan sensor, atau kebijakan. AI akan langsung memproses dan mengindeks dokumen agar chatbot dapat menjawab pertanyaan pelanggan.',
                          style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.4),
                        ),
                        const SizedBox(height: 14),
                        if (_uploading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text(
                                    'Memproses dokumen & menghasilkan vektor...',
                                    style: TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else ...[
                          VgButton(
                            label: 'Pilih & Unggah Dokumen (.pdf, .docx, .txt)',
                            icon: Icons.upload_file_rounded,
                            onPressed: _pickAndUploadDocument,
                          ),
                          const SizedBox(height: 10),
                          VgButton(
                            label: 'Perbarui / Sinkronkan Indeks Manual',
                            style: VgButtonStyle.soft,
                            icon: Icons.sync_rounded,
                            onPressed: _rebuildIndexManual,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Document List Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DOKUMEN TERINDARISIR',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 0.8),
                      ),
                      Text(
                        '${files.length} File',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (files.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Belum ada dokumen. Silakan unggah dokumen pertama Anda.',
                          style: TextStyle(fontSize: 13, color: Colors.black45),
                        ),
                      ),
                    )
                  else
                    ...files.map((file) {
                      final name = file['name']?.toString() ?? 'Dokumen';
                      final ext = file['extension']?.toString() ?? '';
                      final size = file['size_bytes'] ?? 0;
                      final sizeKb = (size / 1024).toStringAsFixed(1);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: VgCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.beige,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(_getFileIcon(ext), color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${ext.toUpperCase().replaceAll('.', '')} • $sizeKb KB',
                                      style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF22A447), size: 18),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
      ],
    );
  }
}
