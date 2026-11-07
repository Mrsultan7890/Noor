import 'package:flutter/material.dart';
import '../providers/user_provider.dart';

Future<int?> logActivityWithFeedback({
  required BuildContext context,
  required UserProvider userProvider,
  required String activityType,
  required int points,
  required String activityName,
  Map<String, dynamic>? metadata,
}) async {
  final pointsEarned = await userProvider.logActivity(
    activityType: activityType,
    points: points,
    metadata: metadata,
  );
  if (!context.mounted) return pointsEarned;

  final message = pointsEarned == null
      ? 'Could not sync $activityName. ${userProvider.error ?? 'Please try again.'}'
      : pointsEarned == 0
          ? '$activityName completed; its reward was already claimed.'
          : '$activityName completed! +$pointsEarned points';
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  return pointsEarned;
}
