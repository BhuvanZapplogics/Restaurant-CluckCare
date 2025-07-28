import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:snack_hack_app/core/services/challenge_submission_service.dart';
import 'package:snack_hack_app/data/models/challenge_submission.dart';
import 'package:snack_hack_app/app/theme.dart';
import 'package:path_provider/path_provider.dart';

class ChallengeSubmissionScreen extends StatefulWidget {
  final String challengeText;
  final DateTime date;
  const ChallengeSubmissionScreen({
    required this.challengeText,
    required this.date,
    super.key,
  });

  @override
  State<ChallengeSubmissionScreen> createState() =>
      _ChallengeSubmissionScreenState();
}

class _ChallengeSubmissionScreenState extends State<ChallengeSubmissionScreen> {
  final _controller = TextEditingController();
  File? _imageFile;
  bool _saving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      // Copy the image to the app's documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final savedImage = await File(
        picked.path,
      ).copy('${appDir.path}/$fileName');
      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  Future<void> _submit() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a picture as proof.')),
      );
      return;
    }
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description.')),
      );
      return;
    }
    setState(() => _saving = true);
    final submission = ChallengeSubmission(
      id: widget.date.toIso8601String(),
      typeId: 0, // Add the required typeId parameter
      challengeId: widget.challengeText, // You may want to use a real ID
      userId: 'local_user', // Replace with real user ID if available
      userName: 'You', // Replace with real user name if available
      submissionTitle: widget.challengeText,
      submissionDescription: _controller.text,
      imageUrl: _imageFile?.path,
      videoUrl: null,
      tags: [],
      submittedAt: widget.date,
      updatedAt: null,
      status: SubmissionStatus.pending,
      likesCount: 0,
      commentsCount: 0,
      likedBy: [],
      metadata: null,
    );
    await ChallengeSubmissionService.saveSubmission(submission);
    setState(() => _saving = false);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt, color: AppColors.primaryCTA, size: 26),
            const SizedBox(width: 10),
            Text(
              'SUBMIT PROOF',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Card(
                color: AppColors.secondary,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: AppColors.primaryCTA,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.challengeText,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: AppColors.secondary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit, color: AppColors.primaryCTA),
                          const SizedBox(width: 8),
                          const Text(
                            'Describe your proof',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'What did you do? Any details...',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                        maxLines: 3,
                        style: const TextStyle(color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_imageFile != null)
                Card(
                  color: AppColors.secondary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          _imageFile!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _imageFile = null),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.redAccent,
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo, color: AppColors.secondaryCTA),
                  label: const Text('Pick Image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondaryCTA,
                    side: const BorderSide(
                      color: AppColors.secondaryCTA,
                      width: 2,
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _saving
                  ? const CircularProgressIndicator(color: AppColors.primaryCTA)
                  : SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryCTA,
                          foregroundColor: AppColors.textLight,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
