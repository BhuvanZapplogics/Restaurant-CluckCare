import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:snack_hack_app/data/models/challenge_submission.dart';
import 'dart:io';
import 'package:snack_hack_app/app/theme.dart';
import 'package:snack_hack_app/core/services/challenge_submission_service.dart';

class SubmissionHistoryScreen extends StatefulWidget {
  final List<ChallengeSubmission> submissions;

  const SubmissionHistoryScreen({super.key, required this.submissions});

  @override
  State<SubmissionHistoryScreen> createState() =>
      _SubmissionHistoryScreenState();
}

class _SubmissionHistoryScreenState extends State<SubmissionHistoryScreen> {
  List<ChallengeSubmission> get _submissions => widget.submissions;

  @override
  void initState() {
    super.initState();
    _autoApproveOldSubmissions();
  }

  Future<void> _autoApproveOldSubmissions() async {
    bool updated = false;
    final now = DateTime.now();
    for (final submission in _submissions) {
      if (submission.status == SubmissionStatus.pending &&
          now.difference(submission.submittedAt) >
              const Duration(minutes: 10)) {
        final approvedSubmission = ChallengeSubmission(
          id: submission.id,
          typeId: submission.typeId,
          challengeId: submission.challengeId,
          userId: submission.userId,
          userName: submission.userName,
          submissionTitle: submission.submissionTitle,
          submissionDescription: submission.submissionDescription,
          imageUrl: submission.imageUrl,
          videoUrl: submission.videoUrl,
          tags: submission.tags,
          submittedAt: submission.submittedAt,
          updatedAt: DateTime.now(),
          status: SubmissionStatus.approved,
          likesCount: submission.likesCount,
          commentsCount: submission.commentsCount,
          likedBy: submission.likedBy,
          metadata: submission.metadata,
        );
        await ChallengeSubmissionService.saveSubmission(approvedSubmission);
        updated = true;
      }
    }
    if (updated && mounted) {
      final fresh = await ChallengeSubmissionService.getAllSubmissions();
      setState(() {
        widget.submissions.clear();
        widget.submissions.addAll(fresh);
      });
    }
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
            Icon(Icons.history, color: AppColors.primaryCTA, size: 26),
            const SizedBox(width: 10),
            Text(
              'SUBMISSION HISTORY',
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
      body: Container(
        color: AppColors.background,
        child: Column(
          children: [
            _buildStatsCard(),
            Expanded(
              child: _submissions.isEmpty
                  ? _buildEmptyState()
                  : _buildSubmissionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final approvedCount = _submissions
        .where((s) => s.status == SubmissionStatus.approved)
        .length;
    final pendingCount = _submissions
        .where((s) => s.status == SubmissionStatus.pending)
        .length;
    final rejectedCount = _submissions
        .where((s) => s.status == SubmissionStatus.rejected)
        .length;

    return Card(
      color: AppColors.secondary,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Approved',
              approvedCount,
              Colors.green,
              Icons.check_circle,
            ),
            _buildStatItem(
              'Pending',
              pendingCount,
              Colors.orange,
              Icons.pending,
            ),
            _buildStatItem('Rejected', rejectedCount, Colors.red, Icons.cancel),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.secondaryCTA.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No submissions yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your challenge submissions will appear here',
            style: TextStyle(fontSize: 16, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _submissions.length,
      itemBuilder: (context, index) {
        final submission = _submissions[index];
        return _buildSubmissionCard(submission);
      },
    );
  }

  Widget _buildSubmissionCard(ChallengeSubmission submission) {
    return Card(
      color: AppColors.secondary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showSubmissionDetails(submission),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        submission.submissionTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    _buildStatusChip(submission.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: AppColors.primaryCTA),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(submission.submittedAt),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                if (submission.submissionDescription.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    submission.submissionDescription,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
                if (submission.imageUrl != null &&
                    submission.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final file = File(submission.imageUrl!);
                      if (file.existsSync()) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColors.background.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.secondaryCTA,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.secondaryCTA,
                            size: 40,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(SubmissionStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case SubmissionStatus.approved:
        color = Colors.green;
        text = 'Approved';
        icon = Icons.check_circle;
        break;
      case SubmissionStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        icon = Icons.pending;
        break;
      case SubmissionStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        icon = Icons.cancel;
        break;
      case SubmissionStatus.underReview:
        color = Colors.blue;
        text = 'Under Review';
        icon = Icons.hourglass_empty;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmissionDetails(ChallengeSubmission submission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSubmissionDetailsSheet(submission),
    );
  }

  Widget _buildSubmissionDetailsSheet(ChallengeSubmission submission) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primaryCTA.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          submission.submissionTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                      _buildStatusChip(submission.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Submitted',
                    DateFormat(
                      'MMM dd, yyyy - HH:mm',
                    ).format(submission.submittedAt),
                    Icons.schedule,
                  ),
                  _buildDetailRow(
                    'Submission ID',
                    submission.id,
                    Icons.info_outline,
                  ),
                  if (submission.submissionDescription.isNotEmpty)
                    _buildDetailRow(
                      'Description',
                      submission.submissionDescription,
                      Icons.description,
                    ),
                  if (submission.imageUrl != null &&
                      submission.imageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Builder(
                        builder: (context) {
                          final file = File(submission.imageUrl!);
                          if (file.existsSync()) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                file,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            );
                          } else {
                            return Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: AppColors.background.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.secondaryCTA,
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.broken_image,
                                color: AppColors.secondaryCTA,
                                size: 48,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCTA,
                        foregroundColor: AppColors.textLight,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryCTA, size: 20),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
