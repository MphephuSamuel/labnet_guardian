import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'profile_avatar.dart';

class ProfileInfoCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String avatarInitial;

  const ProfileInfoCard({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    this.avatarInitial = 'A',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Row(
        children: [
          ProfileAvatar(
            initial: avatarInitial,
            radius: AppConstants.avatarRadius,
          ),
          const SizedBox(width: AppConstants.paddingDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSm),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppColors.textLightSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingDefault),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppColors.textLightSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
